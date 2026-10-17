import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../utils/debug_log.dart';
import '../../../constants/bluetooth_constants.dart';
import '../../../models/devices/device_base.dart';
import '../../../models/devices/mixins/device_wifi_mixin.dart';
import '../../../models/devices/mixins/device_authentication_mixin.dart';
import '../../../models/devices/manufacturers/shelly/shelly_wifi_v1_device.dart';
import '../../../models/network_device.dart';
import '../../../models/additional_connection_info.dart';
import '../base_device_service.dart';
import 'shelly_service.dart';

/// Service for communicating with Shelly v1 (Gen1) devices via WiFi/Network
///
/// Uses plain HTTP protocol (no JSON-RPC, unlike Gen2/3):
/// - GET /shelly                    - device info (mac, type, fw)
/// - GET /status                    - live data (relays, meters, temperature)
/// - GET /relay/{id}?turn=on|off    - relay control
/// - GET /reboot                    - device restart
/// - GET /settings                  - device configuration
/// - GET /settings/sta              - current WiFi station config
/// - GET /settings/sta?enabled=1|0&ssid=..&key=..&ipv4_method=dhcp - set WiFi station (1: store+activate, 0: store only)
/// - GET /settings/ap?enabled=1|0&key=.. - set WiFi access point (name is fixed by firmware)
 /// - GET /settings?field=true|false - set boolean general settings (discoverable, eco_mode_enabled, debug_enable, led_status_disable, pon_wifi_reset)
 /// - GET /settings/relay/{id}?<param>=<value> - set per-relay settings (btn_type, default_state, auto_on, auto_off, ...)
 /// - GET /settings/cloud?enabled=true|false - set cloud connection
/// - GET /settings/login?enabled=1&username=..&password=.. - enable/set device login (requires current credentials when already protected)
/// - GET /settings/login?enabled=0 - disable device login
///
/// Authentication: HTTP Basic (optional, when device login is enabled).
/// The /shelly endpoint is open even when protected and reports "auth": true.
/// Set-endpoints (/settings/*) require the current credentials once login is enabled.
class ShellyWifiV1Service extends BaseDeviceService implements ShellyService {
  // Connection timeout - if no data received within this time, consider disconnected
  static const int CONNECTION_TIMEOUT_MS = 15000;  // 15 seconds

  // Logical command names (mapped to HTTP endpoints in sendCommand)
  static const String CMD_GET_DEVICE_INFO = 'v1.getDeviceInfo';
  static const String CMD_GET_STATUS = 'v1.getStatus';
  static const String CMD_SET_RELAY = 'v1.setRelay';
  static const String CMD_RESTART = 'v1.restart';
  static const String CMD_GET_SETTINGS = 'v1.getSettings';
  static const String CMD_SET_WIFI = 'v1.setWifi';
  static const String CMD_SET_AP = 'v1.setAp';
  static const String CMD_SET_AUTH = 'v1.setAuth';

  /// Set a per-relay setting: GET /settings/relay/{id}?<param>=<value>
  static const String CMD_SET_RELAY_PARAM = 'v1.setRelayParam';

  /// Set a boolean general setting: GET <path>?<param>=true|false
  ///
  /// Note: /settings/* is a catch-all on v1.14 (any sub-path returns 200 with
  /// the full settings JSON), so the caller must verify the echoed value.
  static const String CMD_SET_BOOL_SETTING = 'v1.setBoolSetting';

  late DeviceWifiMixin wifiDevice;

  /// Static method to detect if a device is a Shelly v1 (Gen1) device
  ///
  /// Gen1 devices expose a JSON endpoint at /shelly (Gen2/3 return 404 there).
  /// Returns a NetworkDevice if the response is from a Shelly v1 device, null otherwise
  static Future<NetworkDevice?> isResponseFromManufacturer(
    String ipAddress,
    int? port,
    http.Response? initialResponse,
    AdditionalConnectionInfo connectionInfo,
  ) async {
    port ??= 80;
    try {
      // Cheap prefilter: only probe /shelly when the start page looks like Shelly.
      // A protected device answers the start page with a 401 challenge
      // (WWW-Authenticate: Basic realm="Shelly") instead of HTML.
      if (initialResponse != null) {
        final responseBody = initialResponse.body;
        final isShellyChallenge = initialResponse.statusCode == 401 &&
            (initialResponse.headers['www-authenticate'] ?? '')
                .toLowerCase()
                .contains('shelly');
        if (!responseBody.toLowerCase().contains('shelly') && !isShellyChallenge) {
          return null;
        }
      }

      DebugLog.device('[$ipAddress:$port] Probing /shelly for Shelly v1 detection...', level: LogLevel.debug);

      final response = await http.get(
        Uri.parse('http://$ipAddress:$port/shelly'),
        headers: {
          'Accept': 'application/json',
        },
      ).timeout(connectionInfo.timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;

        final mac = data['mac'] as String?;
        final deviceModel = data['type'] as String?;

        if (mac != null && deviceModel != null) {
          DebugLog.device('[$ipAddress:$port] Shelly v1 device verified: Model=$deviceModel, MAC=$mac', level: LogLevel.debug);
          return NetworkDevice(
            ipAddress: ipAddress,
            hostname: null,
            manufacturer: DEVICE_MANUFACTURER_SHELLY_V1,
            deviceModel: deviceModel,
            serialNumber: mac,
            port: port,
          );
        }
      } else {
        DebugLog.device('Shelly v1 probe on $ipAddress:$port failed, status: ${response.statusCode}', level: LogLevel.verbose);
      }
    } catch (e) {
      DebugLog.device('Error detecting Shelly v1 device $ipAddress:$port: $e', level: LogLevel.error);
    }

    return null;
  }

  ShellyWifiV1Service(DeviceBase device)
      : super((device as ShellyWifiV1Device).fetchDataInterval, device) {
    wifiDevice = device as DeviceWifiMixin;
  }

  @override
  Future<bool> internalConnect() async {
    await wifiDevice.connectIpOrHostname((ip, port) async {
      device.emitStatus('Lese Geräteinfo...');
      final info = await _get('/shelly');
      device.data['config'] = info;
      device.emitData(info);
      device.emitStatus('Geräteinfo erhalten');
    });

    isInitialized = true;
    return true;
  }

  @override
  Future<void> internalFetchData() async {
    final data = await _get('/status');

    _handleStatus(data);

    lastSeen = DateTime.now().millisecondsSinceEpoch;
  }

  @override
  bool isConnected() {
    return (DateTime.now().millisecondsSinceEpoch - lastSeen) < CONNECTION_TIMEOUT_MS;
  }

  /// Handle /status response: detect capabilities and update UI elements if changed
  void _handleStatus(Map<String, dynamic> data) {
    // Store live data first - the implementation reads it when generating
    // controls/fields during _updateDeviceElements()
    device.data['data'] = data;

    final capabilities = _detectCapabilities(data);

    final currentCapabilities = device.data['_v1capabilities'];
    if (!_mapsEqual(currentCapabilities, capabilities)) {
      device.data['_v1capabilities'] = capabilities;
      DebugLog.device("Detected Shelly v1 capabilities: $capabilities", level: LogLevel.debug);

      // Regenerate dynamic controls and time series based on new capabilities
      _updateDeviceElements();
    }

    device.emitData(data);
    device.emitStatus('Daten empfangen');
  }

  /// Update device UI elements after capability detection
  void _updateDeviceElements() {
    final impl = (wifiDevice as dynamic).deviceImpl;
    device.controlItems = impl.getControlItems();
    device.timeSeriesFields = impl.getTimeSeriesFields();
  }

  /// Detect capabilities from the /status payload (dynamic, no model table)
  Map<String, dynamic> _detectCapabilities(Map<String, dynamic> data) {
    final relays = data['relays'] is List ? (data['relays'] as List).length : 0;
    final meters = data['meters'] is List ? (data['meters'] as List).length : 0;
    final emeters = data['emeters'] is List ? (data['emeters'] as List).length : 0;
    return {
      'relays': relays,
      'meters': meters,
      'emeters': emeters,
      'temp': data['tmp'] is Map,
    };
  }

  /// Compare two maps for equality
  bool _mapsEqual(Map<dynamic, dynamic>? map1, Map<dynamic, dynamic>? map2) {
    if (map1 == null && map2 == null) return true;
    if (map1 == null || map2 == null) return false;
    if (map1.length != map2.length) return false;

    for (final key in map1.keys) {
      if (!map2.containsKey(key)) return false;
      if (map1[key] != map2[key]) return false;
    }

    return true;
  }

  /// Build HTTP Basic auth headers if credentials are configured
  Map<String, String> _buildAuthHeaders() {
    final auth = device as DeviceAuthenticationMixin;
    final user = auth.authUsername;
    final password = auth.authPassword;

    if (user == null || password == null || password.isEmpty) {
      return const {};
    }

    final token = base64Encode(utf8.encode('$user:$password'));
    return {'Authorization': 'Basic $token'};
  }

  /// Perform an HTTP GET request against the device
  Future<Map<String, dynamic>> _get(String path) async {
    final url = 'http://${wifiDevice.getCurrentBaseUrl()}$path';
    DebugLog.device('Sending HTTP GET: $url', level: LogLevel.verbose);

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Accept': 'application/json',
        ..._buildAuthHeaders(),
      },
    ).timeout(const Duration(seconds: 5));

    if (response.statusCode == 401) {
      throw _buildAuthError();
    }

    if (response.statusCode != 200) {
      throw Exception('HTTP Error: ${response.statusCode}');
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  /// Perform an HTTP GET request against the device and return the raw body
  ///
  /// Gen1 set-endpoints (e.g. /settings/sta) return plain text ("OK") instead of JSON.
  Future<String> _getRaw(String path) async {
    final url = 'http://${wifiDevice.getCurrentBaseUrl()}$path';
    DebugLog.device('Sending HTTP GET: $url', level: LogLevel.verbose);

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Accept': 'application/json',
        ..._buildAuthHeaders(),
      },
    ).timeout(const Duration(seconds: 5));

    if (response.statusCode == 401) {
      throw _buildAuthError();
    }

    if (response.statusCode != 200) {
      throw Exception('HTTP Error: ${response.statusCode}');
    }

    return response.body;
  }

  /// Build a 401 error with a hint that depends on the stored credentials
  Exception _buildAuthError() {
    final auth = device as DeviceAuthenticationMixin;
    if (auth.authPassword == null || auth.authPassword!.isEmpty) {
      return Exception(
          'Device requires authentication. Please add the device password (manual add) or set the password in the device menu (Authentication).');
    }
    return Exception('Authentication failed. Please check username and password.');
  }

  /// Send a command to the device (mapped to plain HTTP endpoints)
  @override
  Future<Map<String, dynamic>?> sendCommand(
    String method,
    Map<String, dynamic> params, {
    Duration? timeout,
  }) async {
    try {
      Map<String, dynamic> data;

      switch (method) {
        case CMD_GET_DEVICE_INFO:
          data = await _get('/shelly');
          device.data['config'] = data;
          device.emitData(data);
          break;
        case CMD_GET_STATUS:
          data = await _get('/status');
          _handleStatus(data);
          break;
        case CMD_SET_RELAY:
          final id = params['id'] as int? ?? 0;
          final on = params['on'] as bool? ?? true;
          data = await _get('/relay/$id?turn=${on ? 'on' : 'off'}');
          break;
        case CMD_RESTART:
          data = await _get('/reboot');
          break;
        case CMD_GET_SETTINGS:
          data = await _get('/settings');
          break;
        case CMD_SET_WIFI:
          final ssid = params['ssid'] as String?;
          final password = params['password'] as String?;
          final enabled = params['enabled'] as bool? ?? true;
          if (ssid == null || ssid.isEmpty) {
            throw Exception('SSID missing for WiFi configuration');
          }
          // enabled=1: store and activate client mode, enabled=0: store only
          final path = '/settings/sta?enabled=${enabled ? 1 : 0}'
              '&ssid=${Uri.encodeQueryComponent(ssid)}'
              '&key=${Uri.encodeQueryComponent(password ?? '')}'
              '&ipv4_method=dhcp';
          final body = (await _getRaw(path)).trim();
          if (body == 'OK') {
            data = {'status': 'ok'};
          } else {
            // fw v1.14+ returns the applied configuration as JSON
            final applied = jsonDecode(body) as Map<String, dynamic>;
            final appliedSsid = applied['ssid'] as String?;
            if (appliedSsid != ssid) {
              throw Exception('WiFi configuration was not applied. Device SSID: $appliedSsid');
            }
            data = applied;
          }
          break;
        case CMD_SET_AP:
          final key = params['key'] as String? ?? '';
          final enabled = params['enabled'] as bool?;
          // Omit enabled entirely when absent (merge API = store only, mode unchanged)
          final enabledParam = enabled == null ? '' : 'enabled=${enabled ? 1 : 0}&';
          final path = '/settings/ap?${enabledParam}key=${Uri.encodeQueryComponent(key)}';
          final body = (await _getRaw(path)).trim();
          if (body == 'OK') {
            data = {'status': 'ok'};
          } else {
            final applied = jsonDecode(body) as Map<String, dynamic>;
            final appliedKey = applied['key'] as String?;
            if (appliedKey != key) {
              throw Exception('AP configuration was not applied');
            }
            data = applied;
          }
          break;
        case CMD_SET_AUTH:
          final username = params['username'] as String? ?? 'admin';
          final newPassword = params['password'] as String?;
          final enabling = newPassword != null && newPassword.isNotEmpty;
          final path = enabling
              ? '/settings/login?enabled=1&username=${Uri.encodeQueryComponent(username)}&password=${Uri.encodeQueryComponent(newPassword)}'
              : '/settings/login?enabled=0';
          final authBody = (await _getRaw(path)).trim();
          final login = jsonDecode(authBody) as Map<String, dynamic>;
          if ((login['enabled'] as bool?) != enabling) {
            throw Exception('Authentication was not applied. Device state: ${login['enabled']}');
          }
          if (enabling && (login['username'] as String?) != username) {
            throw Exception('Authentication username was not applied. Device state: ${login['username']}');
          }
          data = login;
          break;
        case CMD_SET_BOOL_SETTING:
          final path = params['path'] as String?;
          final param = params['param'] as String?;
          final value = params['value'] as bool?;
          if (path == null || param == null || value == null) {
            throw Exception('path, param and value are required');
          }
          final body = (await _getRaw('$path?$param=${value ? 'true' : 'false'}')).trim();
          if (body == 'OK' || body.isEmpty) {
            data = {'status': 'ok'};
          } else {
            data = jsonDecode(body) as Map<String, dynamic>;
          }
          break;
        case CMD_SET_RELAY_PARAM:
          final id = params['id'] as int? ?? 0;
          final param = params['param'] as String?;
          final value = params['value'] as String?;
          if (param == null || value == null) {
            throw Exception('param and value are required for relay setting');
          }
          final body = (await _getRaw('/settings/relay/$id?$param=${Uri.encodeQueryComponent(value)}')).trim();
          if (body == 'OK' || body.isEmpty) {
            data = {'status': 'ok'};
          } else {
            data = jsonDecode(body) as Map<String, dynamic>;
          }
          break;
        default:
          throw Exception('Command not implemented: $method');
      }

      return data;
    } catch (e) {
      DebugLog.device("Error sending command $method: $e", level: LogLevel.error);
      if (method != CMD_GET_STATUS && method != CMD_GET_DEVICE_INFO) {
        // only when command from user show info in foreground
        device.emitError('Command failed: $e');
      }
      rethrow;
    }
  }
}
