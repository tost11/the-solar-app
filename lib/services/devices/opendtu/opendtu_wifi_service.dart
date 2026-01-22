import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:the_solar_app/constants/bluetooth_constants.dart';
import 'package:the_solar_app/models/device.dart';
import 'package:the_solar_app/models/network_device.dart';
import 'package:the_solar_app/models/additional_connection_info.dart';
import 'package:the_solar_app/services/devices/base_device_service.dart';
import 'package:http/http.dart' as http;

import '../../../models/devices/manufacturers/opendtu/wifi_opendtu_device.dart';
import '../../../utils/exception_utils.dart';
import 'opendtu_websocket_connection.dart';

class OpenDTUWifiService extends BaseDeviceService {
  // Connection timeout - if no data received within this time, consider disconnected
  static const int CONNECTION_TIMEOUT_MS = 40000;  // 60 seconds (1 minute)

  // WebSocket connection for real-time data
  OpenDtuWebSocketConnection? _websocketConnection;

  /// Static method to detect if HTTP response is from an OpenDTU device
  ///
  /// Returns a NetworkDevice if the response is from an OpenDTU device, null otherwise
  static Future<NetworkDevice?> isResponseFromManufacturer(
    String ipAddress,
    int ? port,
    http.Response? initialResponse,
    AdditionalConnectionInfo connectionInfo,
  ) async {
    port ??= 80;
    try {
      // Check if initial response indicates we should probe further
      // (e.g., 404 means root endpoint doesn't exist, which is expected for OpenDTU devices)
      if (initialResponse != null && (initialResponse.statusCode == 404 || initialResponse.statusCode == 200)) {
        // Step 1: Fetch system status for hostname and chipmodel
        final systemResponse = await http.get(
          Uri.parse('http://$ipAddress:$port/api/system/status'),
          headers: {'Accept': 'application/json'},
        ).timeout(connectionInfo.timeout);

        if (systemResponse.statusCode == 200) {
          // Parse JSON response
          final systemData = jsonDecode(systemResponse.body) as Map<String, dynamic>;

          // Check for OpenDTU-specific keys
          if (systemData.containsKey('hostname') &&
              systemData.containsKey('chipmodel') &&
              systemData.containsKey('git_hash')) {

            final hostname = systemData['hostname'] as String?;
            final chipModel = systemData['chipmodel'] as String?;

            // Step 2: Fetch network status for ap_mac (persistent hardware serial)
            final networkResponse = await http.get(
              Uri.parse('http://$ipAddress:$port/api/network/status'),
              headers: {'Accept': 'application/json'},
            ).timeout(connectionInfo.timeout);

            if (networkResponse.statusCode == 200) {
              final networkData = jsonDecode(networkResponse.body) as Map<String, dynamic>;

              // Extract ap_mac as the persistent serial number
              final apMac = networkData['ap_mac'] as String?;
              if (apMac == null || apMac.isEmpty) {
                debugPrint('OpenDTU device found but ap_mac is missing or empty');
                return null;
              }

              // Remove colons from MAC address for cleaner serial number
              final serialNumber = apMac.replaceAll(':', '');

              return NetworkDevice(
                ipAddress: ipAddress,
                hostname: hostname,
                manufacturer: DEVICE_MANUFACTURER_OPENDTU,
                deviceModel: chipModel ?? 'Unknown',
                serialNumber: serialNumber,  // Use MAC address without colons
                port: port
              );
            } else {
              debugPrint('OpenDTU network status endpoint returned ${networkResponse.statusCode}');
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Error detecting OpenDTU device: $e');
    }

    return null;
  }

  late WiFiOpenDTUDevice wifiDevice;

  OpenDTUWifiService(DeviceBase device):
    super((device as WiFiOpenDTUDevice).fetchDataInterval, device) {
    wifiDevice = device as WiFiOpenDTUDevice;
    // Create WebSocket connection for real-time data with callback
    _websocketConnection = OpenDtuWebSocketConnection(
      onDataReceived: _handleWebSocketData,
    );
  }

  /// Handle WebSocket data callback
  void _handleWebSocketData(Map<String, dynamic> parsedData) {
    // Calculate total DC input power from all inverters
    double totalDcPower = 0.0;
    final inverters = parsedData['inverters'] as Map<String, dynamic>?;
    if (inverters != null) {
      for (var inverter in inverters.values) {
        // Access dc_strings from the parsed inverter data
        final dcStrings = inverter['dc_strings'] as List?;
        if (dcStrings != null) {
          for (var string in dcStrings) {
            final power = string['power'];
            if (power != null && power is num) {
              totalDcPower += power.toDouble();
            }
          }
        }
      }
    }

    // Add calculated DC total to data structure for time series tracking
    if (!parsedData.containsKey('total')) {
      parsedData['total'] = {};
    }
    parsedData['total']['DC_Power_Total'] = totalDcPower;

    // Generate field groups from inverter data (only regenerates if inverters changed)
    final impl = wifiDevice.deviceImpl;
    impl.generateFieldGroupsFromData(parsedData);

    // Update device's field groups list so tracking can find them
    wifiDevice.timeSeriesFieldGroups = impl.getTimeSeriesFieldGroups();

    device.data["data"] = parsedData;
    device.emitData(parsedData);
  }

  @override
  Future<void> internalDisconnect() async {
    // Disconnect WebSocket connection
    await _websocketConnection?.disconnect();
  }

  /// Permanently dispose all connections
  @override
  void dispose() {
    // Dispose WebSocket permanently (prevents reconnection)
    _websocketConnection?.dispose();
    super.dispose();
  }

  String getBaseUri() {
    return 'http://${wifiDevice.getCurrentBaseUrl()}';
  }

  @override
  Future<bool> internalConnect() async {
    bool httpConnected = false;
    bool wsConnected = false;

    // This throws exception if either endpoint fails
    await wifiDevice.connectIpOrHostname((ip,port) async {
      // Both endpoints must succeed - both throw on failure
      await fetchSystemInfo();      // Throws if system status fails
      await fetchNetworkStatus();   // Throws if network status fails

      // Only reached if both succeed
      httpConnected = true;
    });

    device.data["data"] = {};
    device.emitData({});

    return true;//directly fetch data
  }

  @override
  Future<bool> internalInitializeDevice() async {
    // Fetch initial live data from HTTP endpoint before WebSocket takes over
    try {
      await fetchLiveDataStatus();
      debugPrint('[OpenDTU] Initial live data fetched successfully');
    } catch (e) {
      debugPrint('[OpenDTU] Failed to fetch initial live data: $e');
      // Don't throw - WebSocket will provide data later
    }

    // WebSocket connection (even when fails it will retry itself)
    try {
      await _websocketConnection?.connect(
        wifiDevice.getCurrenHostOrIp(),
        wifiDevice.netPort!,
        _buildHeaders(),
      ) ?? false;
    } catch(e){
      debugPrint('OpenDTU WebSocket connection failed: $e');
    }

    return true;
  }

  /// Build HTTP headers with optional authentication
  Map<String, String> _buildHeaders() {
    final headers = {'Accept': 'application/json'};

    // Add authentication if credentials are provided
    if (wifiDevice.authUsername != null &&
        wifiDevice.authUsername!.isNotEmpty &&
        wifiDevice.authPassword != null) {
      final credentials = base64Encode(
        utf8.encode('${wifiDevice.authUsername}:${wifiDevice.authPassword}')
      );
      headers['Authorization'] = 'Basic $credentials';
    }

    return headers;
  }

  @override
  Future<void> internalFetchData() async {

    String connectedWith = "";

    // 1. Check WebSocket health (data comes via callback)
    if (_websocketConnection?.isHealthy == true) {
      connectedWith += "WebSocket";
    }

    // 2. HTTP configuration data (always fetch for system info)
    try {
      await fetchSystemInfo();
      connectedWith += " http";
    } catch (e) {
      debugPrint('Error fetching OpenDTU HTTP data: $e');
    }

    // 3. Emit custom connection status (shows connection types)
    if (connectedWith.isNotEmpty) {
      device.emitStatus('Verbunden ($connectedWith)');
    } else {
      throw Exception('Nicht Verbunden');
    }
  }

  @override
  bool isConnected() {
    // Consider connected if either HTTP or WebSocket is healthy
    final httpHealthy = (DateTime.now().millisecondsSinceEpoch - lastSeen) < CONNECTION_TIMEOUT_MS;
    final wsHealthy = _websocketConnection?.isHealthy ?? false;
    return httpHealthy || wsHealthy;
  }

  /// Fetch system information from OpenDTU device via HTTP
  ///
  /// Returns the system info data without emitting (fetchData() handles emission)
  Future<Map<String, dynamic>?> fetchSystemInfo() async {
    try {
      var data = await sendGetCommand("/api/system/status");
      debugPrint("OpenDTU received HTTP data: $data");

      if (data == null) {
        throw Exception("System info from OpenDTU null when fetching");
      }
      device.data["config"] = data;
      device.emitDeviceInfo(data);
      return data;
    } catch (e) {
      debugPrint('Error fetching system info: $e');
      rethrow;
    }
  }

  /// Fetch network information from OpenDTU device via HTTP
  ///
  /// This method must succeed during connection - throws exception on failure
  /// Returns the network status data including ap_mac (used as persistent serial)
  Future<Map<String, dynamic>> fetchNetworkStatus() async {
    try {
      var data = await sendGetCommand("/api/network/status");
      debugPrint("OpenDTU received network status: $data");

      if (data == null) {
        throw Exception("Network status from OpenDTU null when fetching");
      }

      // Verify ap_mac exists
      final apMac = data['ap_mac'] as String?;
      if (apMac == null || apMac.isEmpty) {
        throw Exception("ap_mac field missing or empty in network status");
      }

      return data;
    } catch (e) {
      debugPrint('Error fetching network status: $e');
      rethrow;
    }
  }

  /// Fetch initial live data from HTTP endpoint
  ///
  /// Called during initialization before WebSocket provides updates
  /// Returns parsed data in same format as WebSocket updates
  Future<Map<String, dynamic>?> fetchLiveDataStatus() async {
    try {
      final response = await http.get(
        Uri.parse('${getBaseUri()}/api/livedata/status'),
        headers: _buildHeaders(),
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final rawData = jsonDecode(response.body) as Map<String, dynamic>;
        debugPrint('OpenDTU received initial live data: $rawData');

        // Parse using WebSocket connection's parser
        final parsedData = _websocketConnection?.parseRawLiveData(rawData);

        if (parsedData != null) {
          // Emit to device using same handler as WebSocket
          _handleWebSocketData(parsedData);
        }

        return parsedData;
      } else if (response.statusCode == 401) {
        throw Exception('Authentication required or invalid');
      } else {
        throw Exception('HTTP ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching initial live data: $e');
      rethrow;
    }
  }

  /// Generic command sender for OpenDTU API
  ///
  /// Sends POST request to specified endpoint with JSON data in multipart form
  /// Endpoint examples: '/api/security/config', '/api/network/config'
  /// Returns response data on success
  Future<Map<String, dynamic>?> sendCommand(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${getBaseUri()}$endpoint'),
      );

      // Add current auth header if exists
      if (wifiDevice.authPassword != null && wifiDevice.authPassword!.isNotEmpty) {
        final credentials = base64Encode(
          utf8.encode('admin:${wifiDevice.authPassword}')
        );
        request.headers['Authorization'] = 'Basic $credentials';
      }

      request.headers['Accept'] = 'application/json';

      // Add JSON as "data" field in multipart form
      request.fields['data'] = jsonEncode(data);

      debugPrint('OpenDTU: Sending command to $endpoint with data: $data');

      // Send request
      final streamedResponse = await request.send().timeout(const Duration(seconds: 5));
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body) as Map<String, dynamic>;

        // Check for success response
        if (responseData['type'] == 'success') {
          debugPrint('OpenDTU command to $endpoint successful');
          return responseData;
        } else {
          throw Exception(responseData['message'] ?? 'Unknown error');
        }
      } else if (response.statusCode == 401) {
        throw Exception('Authentication required or invalid');
      } else {
        throw Exception('Command failed: HTTP ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error sending OpenDTU command to $endpoint: $e');
      rethrow;
    }
  }

  /// Generic GET request handler for OpenDTU API
  ///
  /// Sends GET request to specified endpoint
  /// Endpoint examples: '/api/network/config', '/api/security/config', '/api/system/status'
  /// Returns response data on success
  Future<Map<String, dynamic>?> sendGetCommand(String endpoint) async {
    try {
      final response = await http.get(
        Uri.parse('${getBaseUri()}$endpoint'),
        headers: _buildHeaders(),
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        if(response.body.startsWith("<!DOCTYPE html>")){
          throw ApiException(404,"Endpoint ${getBaseUri()}$endpoint");
        }
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        debugPrint('OpenDTU GET $endpoint successful: $data');
        return data;
      } else if (response.statusCode == 401) {
        throw Exception('Authentication required or invalid');
      } else {
        throw Exception('GET request failed: HTTP ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error sending OpenDTU GET to $endpoint: $e');
      rethrow;
    }
  }

  /// Restart device using OpenDTU's maintenance API
  /// Returns true on success
  Future<bool> restartDevice() async {
    try {
      final response = await sendCommand('/api/maintenance/reboot', {
        'reboot': true,
      });

      // sendCommand() already checks response.type == 'success'
      // and throws on errors, so if we get here it succeeded
      return response != null;
    } catch (e) {
      debugPrint('OpenDTU restart failed: $e');
      rethrow;
    }
  }
}
