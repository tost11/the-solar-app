import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:the_solar_app/constants/bluetooth_constants.dart';
import '../../../constants/shelly_constants.dart';
import 'package:the_solar_app/models/devices/device_base.dart';
import 'package:the_solar_app/models/network_device.dart';
import 'package:the_solar_app/models/additional_connection_info.dart';
import '../../../models/devices/mixins/device_wifi_mixin.dart';
import '../../../models/devices/manufacturers/shelly/shelly_wifi_device.dart';
import '../base_device_service.dart';
import 'shelly_auth_mixin.dart';
import 'shelly_service.dart';
import '../../../utils/shelly_auth_utils.dart';

/// Service for communicating with Shelly devices via WiFi/Network
///
/// Uses HTTP RPC protocol:
/// - Endpoint: http://{ipAddress}:{port}/rpc/{method}
/// - POST request with JSON-RPC payload
class ShellyWifiService extends BaseDeviceService with ShellyAuthMixin implements ShellyService {
  // Connection timeout - if no data received within this time, consider disconnected
  static const int CONNECTION_TIMEOUT_MS = 15000;  // 15 seconds

  late DeviceWifiMixin wifiDevice;

  /// Static method to detect if HTTP response is from a Shelly device
  ///
  /// Returns a NetworkDevice if the response is from a Shelly device, null otherwise
  static Future<NetworkDevice?> isResponseFromManufacturer(
    String ipAddress,
    int ? port,
    http.Response? initialResponse,
    AdditionalConnectionInfo connectionInfo,
  ) async {
    port ??= 80;
    try {
      // First, check if initialResponse contains Shelly Web Admin HTML
      if (initialResponse != null) {
        final responseBody = initialResponse.body;

        if (responseBody.contains('<!DOCTYPE html>') &&
            responseBody.contains('data-theme="dark"') &&
            responseBody.contains('<title>Shelly Web Admin</title>')) {

          debugPrint('[$ipAddress:$port] Shelly Web Admin HTML detected, fetching device info...');

          // Confirmed Shelly device - now get device details via JSON-RPC API
          final response = await http.get(
            Uri.parse('http://$ipAddress:$port/rpc/${ShellyCommands.getDeviceInfo}'),
            headers: {
              'Accept': 'application/json',
            },
          ).timeout(connectionInfo.timeout);

          if (response.statusCode == 200) {
            // Parse JSON-RPC response
            final responseData = jsonDecode(response.body) as Map<String, dynamic>;

            if (responseData.containsKey('id') &&
                responseData.containsKey('model')) {
              final mac = responseData['mac'] as String?;
              final deviceId = responseData['id'] as String?;
              final deviceModel = responseData['model'] as String?;

              if (mac != null) {
                debugPrint('[$ipAddress:$port] Shelly device verified: Model=$deviceModel, ID=$mac');
                return NetworkDevice(
                  ipAddress: ipAddress,
                  hostname: null,
                  manufacturer: DEVICE_MANUFACTURER_SHELLY,
                  deviceModel: deviceModel ?? 'Unknown',
                  serialNumber: mac,
                  port: port
                );
              }
            }
          }else{
            debugPrint('Error detecting Shelly device $ipAddress:$port status code: ${response.statusCode} body: ${response.body}');
          }
        }
      }
    } catch (e) {
      debugPrint('Error detecting Shelly device $ipAddress:$port: $e');
    }

    return null;
  }

  ShellyWifiService(DeviceBase device)
      :super((device as ShellyWifiDeviceTemplate).fetchDataInterval, device) {
    wifiDevice = device as DeviceWifiMixin;
  }

  @override
  Future<bool> internalConnect() async {
    await wifiDevice.connectIpOrHostname((ip,port) async {
      device.emitStatus('Lese Geräteinfo...');
      await sendCommand(ShellyCommands.getDeviceInfo, {"id": 0});
    });

    isInitialized = true;
    return true;//direclty fetch data
  }

  @override
  Future<void> internalDisconnect() async {
    // Clear Shelly-specific auth cache
    resetAuthCache();
    // Note: device.data (including config) is cleared by wrapper
  }

  @override
  bool isConnected() {
    return (DateTime.now().millisecondsSinceEpoch - lastSeen) < CONNECTION_TIMEOUT_MS;
  }

  /// Fetch data from the device (called periodically)
  @override
  Future<void> internalFetchData() async {
    var data = await sendCommand(ShellyCommands.getStatus, {});

    if(data == null){
      throw Exception("Shelly rest fetch data failed no data received");
    }

    //data already set in result handling
    lastSeen = DateTime.now().millisecondsSinceEpoch;
  }

  void _handleResponse(String methode, Map<String,dynamic> data){
    if(methode == ShellyCommands.getDeviceInfo){
      var src = data["auth_domain"] as String?;
      if(src != null){
        //TODO make this better
        debugPrint("set realm to: $src");
        (device as dynamic).deviceScr = src;
      }
      device.data['config'] = data;
      device.emitData(data);
      device.emitStatus('Geräteinfo erhalten');
    }else if(methode == ShellyCommands.getStatus){
      // Detect modules in response
      final detectedModules = _detectModules(data);

      // Update cached modules and regenerate fields if modules changed
      final currentModules = device.data['_detectedModules'];
      if (currentModules == null || !_mapsEqual(currentModules as Map?, detectedModules)) {
        device.data['_detectedModules'] = detectedModules;
        debugPrint('Detected Shelly modules: $detectedModules');

        // Regenerate dynamic fields, controls, and time series based on new modules
        _updateDeviceElements();
      }

      device.data['data'] = data;
      device.emitData(data);
      device.emitStatus('Daten empfangen');
    }
  }

  /// Update device UI elements after module detection
  void _updateDeviceElements() {
    final impl = (wifiDevice as dynamic).deviceImpl;
    // dataFields is now a computed getter - no need to update
    device.controlItems = impl.getControlItems();
    device.timeSeriesFields = impl.getTimeSeriesFields();
  }

  /// Detect Shelly modules in the response data
  Map<String, List<int>> _detectModules(Map<String, dynamic> data) {
    final modules = <String, List<int>>{};
    final regex = RegExp(r'^(em|em1|em1data|emdata|pm1|switch|cover|input|light|temperature):(\d+)$');

    for (final key in data.keys) {
      final match = regex.firstMatch(key);
      if (match != null) {
        final moduleType = match.group(1)!;
        final instanceId = int.parse(match.group(2)!);
        modules.putIfAbsent(moduleType, () => []).add(instanceId);
      }
    }

    // Sort instance IDs
    modules.forEach((key, value) => value.sort());

    return modules;
  }

  /// Compare two maps for equality (deep comparison of structure)
  bool _mapsEqual(Map<dynamic, dynamic>? map1, Map<dynamic, dynamic>? map2) {
    if (map1 == null && map2 == null) return true;
    if (map1 == null || map2 == null) return false;
    if (map1.length != map2.length) return false;

    for (final key in map1.keys) {
      if (!map2.containsKey(key)) return false;
      final val1 = map1[key];
      final val2 = map2[key];

      if (val1 is List && val2 is List) {
        if (val1.length != val2.length) return false;
        for (int i = 0; i < val1.length; i++) {
          if (val1[i] != val2[i]) return false;
        }
      } else if (val1 != val2) {
        return false;
      }
    }

    return true;
  }

  /// Send a JSON-RPC command to the device via HTTP
  @override
  Future<Map<String, dynamic>?> sendCommand(
    String method,
    Map<String, dynamic> params,
  ) async {
    return await _sendCommandWithAuth(method, params, retryOnAuth: true);
  }

  /// Internal method to send command with optional authentication retry
  Future<Map<String, dynamic>?> _sendCommandWithAuth(
    String method,
    Map<String, dynamic> params, {
    required bool retryOnAuth,
  }) async {
    try {
      debugPrint('Sending HTTP RPC: $method to http://${wifiDevice.getCurrentBaseUrl()}/rpc');

      // Build request body
      int id = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      Map<String, dynamic> requestBody = {
        "id": id,
        "src": "flutter_app",
        "method": method
      };
      if (params.isNotEmpty) {
        requestBody["params"] = Map.from(params);
      }

      // Add authentication if cached (proactive auth)
      if (cachedAuthObject != null) {
        requestBody['auth'] = cachedAuthObject;
      }

      final response = await http.post(
        Uri.parse('http://${wifiDevice.getCurrentBaseUrl()}/rpc'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(requestBody),
      ).timeout(const Duration(seconds: 2));

      // Handle HTTP 401 status code
      if (response.statusCode == 401) {
        if (!retryOnAuth) {
          throw Exception('Authentifizierung fehlgeschlagen. Bitte überprüfen Sie Benutzername und Passwort.');
        }

        debugPrint('Received HTTP 401, attempting authentication...');
        return await _handleHttpAuthChallenge(method, params, response);
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;

        debugPrint('Received response: $data',wrapWidth: 1024);

        // Handle JSON-RPC 401 error code (even with HTTP 200)
        if (data.containsKey('error')) {
          final error = data['error'];

          throw Exception('RPC Error: $error');
        }

        // Return the result
        if (data.containsKey('result')) {
          _handleResponse(method,data["result"] as Map<String,dynamic>);
          return data["result"];
        }
        return Map<String,dynamic>();
      } else {
        throw Exception('HTTP Error: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error sending command $method: $e');
      if(method != ShellyCommands.getStatus && method != ShellyCommands.getDeviceInfo) {
        //ony when command from user show inf forderground
        device.emitError('Befehl fehlgeschlagen: $e');
      }
      rethrow;
    }
  }

  /// Handle HTTP 401 authentication challenge
  Future<Map<String, dynamic>?> _handleHttpAuthChallenge(
    String method,
    Map<String, dynamic> params,
    http.Response response,
  ) async {
    try {
      // Try to parse challenge from response body
      String? challengeJson;

      // Check if response body contains JSON error message
      if (response.body.isNotEmpty) {
        try {
          final errorData = jsonDecode(response.body);
          if (errorData is Map && errorData.containsKey('error')) {
            final error = errorData['error'];
            challengeJson = error is Map ? error['message'] as String? : null;
          }
        } catch (e) {
          debugPrint('Failed to parse 401 response body: $e');
        }
      }

      // If no challenge in body, check WWW-Authenticate header
      Map<String, dynamic>? authObject;

      if (challengeJson != null) {
        // Parse challenge from JSON error message
        authObject = parseAndBuildAuth(challengeJson);
        if (authObject == null) {
          throw Exception('Failed to build authentication object from JSON');
        }
      } else {
        // Try to parse WWW-Authenticate header
        final wwwAuth = response.headers['www-authenticate'];
        if (wwwAuth != null) {
          debugPrint('WWW-Authenticate header: $wwwAuth');

          // Parse Digest header
          final challenge = ShellyAuthUtils.parseWWWAuthenticateHeader(wwwAuth);
          if (challenge == null) {
            throw Exception('Failed to parse WWW-Authenticate header');
          }

          // Build auth object from header challenge
          authObject = buildAuthFromChallenge(challenge);
          debugPrint('Auth object built from WWW-Authenticate header');
        } else {
          throw Exception('No authentication challenge found in 401 response');
        }
      }

      debugPrint('Auth object built, retrying HTTP request...');

      // Retry with authentication (retryOnAuth: false to prevent infinite loop)
      return await _sendCommandWithAuth(method, params, retryOnAuth: false);
    } catch (e) {
      debugPrint('Error handling HTTP auth challenge: $e');
      resetAuthCache();
      rethrow;
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}
