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
  static const int CONNECTION_TIMEOUT_MS = 60000;  // 60 seconds (1 minute)

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
        // Make request to OpenDTU-specific endpoint
        final response = await http.get(
          Uri.parse('http://$ipAddress:$port/api/system/status'),
          headers: {'Accept': 'application/json'},
        ).timeout(connectionInfo.timeout);

        if (response.statusCode == 200) {
          // Parse JSON response
          final responseData = jsonDecode(response.body) as Map<String, dynamic>;

          // Check for OpenDTU-specific keys
          if (responseData.containsKey('hostname') &&
              responseData.containsKey('chipmodel') &&
              responseData.containsKey('git_hash')) {

            final hostname = responseData['hostname'] as String?;
            final chipModel = responseData['chipmodel'] as String?;

            //real serial not possible (find a way to get chip number of device)
            var fakeSerial = "";
            if(hostname != null){
              fakeSerial += '${hostname}_';
            }
            fakeSerial += ipAddress;

            return NetworkDevice(
              ipAddress: ipAddress,
              hostname: hostname ?? 'OpenDTU',
              manufacturer: DEVICE_MANUFACTURER_OPENDTU,
              deviceModel: chipModel ?? 'Unknown',
              serialNumber: fakeSerial,
              port: port
            );
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
    device.emitStatus("Verbindungsaufbau...");

    bool httpConnected = false;
    bool wsConnected = false;

    //this throws exception if not working
    await wifiDevice.connectIpOrHostname((ip,port) async {
      await fetchSystemInfo();
      httpConnected = true;
    });

    isInitialized = true;

    //todo maybe retry if http not working
    try {
      wsConnected = await _websocketConnection?.connect(
        wifiDevice.getCurrenHostOrIp(),
        wifiDevice.netPort!,
        _buildHeaders(),
      ) ?? false;
    } catch(e){
      debugPrint('OpenDTU WebSocket connection failed: $e');
    }

    // Report connection status
    if (!httpConnected && !wsConnected) {
      device.emitStatus("nicht Verbunden");
      throw Exception('Failed to connect via HTTP or WebSocket');
    }

    final connectedWith = [
      if (wsConnected) 'WebSocket',
      if (httpConnected) 'http',
    ].join(',');

    device.emitStatus("Verbunden ($connectedWith)");
    device.data["data"] = {};
    device.emitData({});

    return true;//directly fetch data
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
    } catch (e) {
      debugPrint('Error fetching system info: $e');
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

  /// Set inverter power state (on/off) - mock/stub for future implementation
  /// Returns true on success
  Future<bool> setPowerState(bool powerOn) async {
    // TODO: Implement actual power control API when available
    debugPrint('OpenDTU setPowerState called with powerOn=$powerOn (mock implementation)');

    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Mock success response
    return true;
  }

  /// Restart device (mock/stub for future implementation)
  /// Returns true on success
  Future<bool> restartDevice() async {
    // TODO: Implement actual restart API when available
    debugPrint('OpenDTU restartDevice called (mock implementation)');

    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Mock success response
    return true;
  }
}
