import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:the_solar_app/constants/bluetooth_constants.dart';
import 'package:the_solar_app/models/devices/mixins/additional_port_mixin.dart';
import 'package:the_solar_app/models/devices/mixins/device_wifi_mixin.dart';
import 'package:the_solar_app/models/network_device.dart';
import 'package:the_solar_app/models/additional_connection_info.dart';
import 'package:the_solar_app/services/devices/base_device_service.dart';
import 'package:http/http.dart' as http;

import '../../../models/devices/manufacturers/deyesun/wifi_deyesun_device.dart';
import 'deyesun_modbus_connection.dart';

class DeyeSunWifiService extends BaseDeviceService {

  int lastSeen = 0;
  bool fetchDataEnabled = true;
  late WiFiDeyeSunDevice wifiDevice;

  // Modbus connection for real-time data
  late DeyeSunModbusConnection _modbusConnection;


  DeyeSunWifiService(WiFiDeyeSunDevice device):
        super((device as WiFiDeyeSunDevice).fetchDataInterval, device) {

    wifiDevice = device;

    _modbusConnection = DeyeSunModbusConnection();

    // Fetch first data
    fetchData();
  }

  /// Static method to detect if HTTP response is from a DeyeSun device
  ///
  /// Returns a NetworkDevice if the response is from a DeyeSun device, null otherwise
  static Future<NetworkDevice?> isResponseFromManufacturer(
    String ipAddress,
    http.Response? initialResponse,
    AdditionalConnectionInfo connectionInfo,
  ) async {
    try {
      if(initialResponse != null){
        final serverHeader = initialResponse.headers['server']?.toLowerCase();
        final wwwAuthHeader = initialResponse.headers['www-authenticate'];

        debugPrint(serverHeader.toString());
        debugPrint(wwwAuthHeader.toString());
        debugPrint(initialResponse.statusCode.toString());
      // Check for DeyeSun-specific 401 response pattern
      if ((initialResponse.statusCode == 401 && serverHeader == 'httpd' && wwwAuthHeader != null && wwwAuthHeader.contains('Basic realm="USER LOGIN"')) || //not authenticated
          (initialResponse.statusCode == 200 && serverHeader != null &&  serverHeader.startsWith("microsoft-iis/"))){//already authenticated (device stores ip and status of authentication)

          debugPrint('[$ipAddress] DeyeSun device detected, authenticating...');

          // Authenticate and fetch device info from status page
          // Use provided credentials or defaults
          final response = await _fetchWithAuth(
            'http://$ipAddress/status.html',
            timeoutSeconds: connectionInfo.timeout.inSeconds,
            username: connectionInfo.username ?? 'admin',
            password: connectionInfo.password ?? 'admin',
          );
          final statusCode = response.statusCode;

          debugPrint('[$ipAddress] Response status: $statusCode');

          if (statusCode == 200) {
            // Read response body
            final body = await response.transform(utf8.decoder).join();

            // Parse JavaScript variables from HTML
            final jsVars = _parseJavaScriptVariables(body);
            debugPrint('[$ipAddress] Parsed ${jsVars.length} variables');

            final serialNumber = jsVars['cover_mid'];
            //final firmwareVersion = jsVars['cover_ver'];

            final model = getModelFromSerial(serialNumber) ?? "Unknown";

            if (serialNumber != null && serialNumber.isNotEmpty) {
              debugPrint('[$ipAddress] DeyeSun device verified: SN=$serialNumber');
              return NetworkDevice(
                ipAddress: ipAddress,
                hostname: null,
                manufacturer: DEVICE_MANUFACTURER_DEYE_SUN,
                deviceModel: model,
                serialNumber: serialNumber,
                port: 80
              );
            } else {
              debugPrint('[$ipAddress] DeyeSun device found but no serial number');
              debugPrint('[$ipAddress] Available variables: ${jsVars.keys.join(", ")}');
            }
          } else {
            final body = await response.transform(utf8.decoder).join();
            debugPrint('[$ipAddress] DeyeSun authentication failed: $statusCode');
            debugPrint('[$ipAddress] Response body preview: ${body.substring(0, body.length > 200 ? 200 : body.length)}');
          }
        }
      }
    } catch (e) {
      debugPrint('[$ipAddress] Error detecting DeyeSun device: $e');
    }

    return null;
  }

  /// Fetches URL with Basic authentication using HttpClient with preserveHeaderCase
  static Future<HttpClientResponse> _fetchWithAuth(
    String url, {
    int timeoutSeconds = 2,
    String username = 'admin',
    String password = 'admin',
  }) async {
    final client = HttpClient();
    try {
      final uri = Uri.parse(url);
      final request = await client.getUrl(uri).timeout(Duration(seconds: timeoutSeconds));

      // Set exact headers with proper casing
      final credentials = base64Encode(utf8.encode('$username:$password'));
      request.headers.set('Authorization', 'Basic $credentials',preserveHeaderCase: true);
      request.headers.set('Accept', 'text/html,application/xhtml+xml',preserveHeaderCase: true);

      final response = await request.close().timeout(Duration(seconds: timeoutSeconds));
      return response;
    } finally {
      client.close();
    }
  }

  /// Posts form data with Basic authentication using HttpClient with preserveHeaderCase
  static Future<HttpClientResponse> _postWithAuth(String url, Map<String, String> formData, {int timeoutSeconds = 5}) async {
    final client = HttpClient();
    try {
      final uri = Uri.parse(url);
      final request = await client.postUrl(uri).timeout(Duration(seconds: timeoutSeconds));

      // Set exact headers with proper casing
      final credentials = base64Encode(utf8.encode('admin:admin'));
      request.headers.set('Authorization', 'Basic $credentials', preserveHeaderCase: true);
      request.headers.set('Content-Type', 'application/x-www-form-urlencoded', preserveHeaderCase: true);
      request.headers.set('Accept', 'text/html,application/xhtml+xml', preserveHeaderCase: true);

      // Build form-urlencoded body
      final body = formData.entries
          .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
          .join('&');

      request.write(body);

      final response = await request.close().timeout(Duration(seconds: timeoutSeconds));
      return response;
    } finally {
      client.close();
    }
  }

  /// Parses JavaScript variables from HTML response
  /// Extracts variables in format: var variable_name = "value";
  static Map<String, dynamic> _parseJavaScriptVariables(String html) {
    final Map<String, dynamic> variables = {};

    // Match pattern: var variable_name = "value";
    final regex = RegExp(r'var\s+(\w+)\s*=\s*"([^"]*)";');
    final matches = regex.allMatches(html);

    for (final match in matches) {
      final varName = match.group(1);
      final varValue = match.group(2);
      if (varName != null && varValue != null) {
        variables[varName] = varValue.trim();
      }
    }

    return variables;
  }

  /// Detect inverter model from serial number
  static String? getModelFromSerial(String? serialNumber) {
    if (serialNumber == null || serialNumber.isEmpty) return null;

    if (serialNumber.startsWith("415") ||
        serialNumber.startsWith("414") ||
        serialNumber.startsWith("221")) {
      return "SUN600G3-EU-230";
    } else if (serialNumber.startsWith("413") ||
               serialNumber.startsWith("411")) {
      return "SUN300G3-EU-230";
    } else if (serialNumber.startsWith("384") ||
               serialNumber.startsWith("385") ||
               serialNumber.startsWith("386")) {
      return "SUN-M60/80/100G4-EU-Q0";
    }
    return null; // Unknown model
  }

  /// Get power rating for model in watts
  static int? getPowerRatingForModel(String? model) {
    if (model == null) return null;

    switch (model) {
      case "SUN600G3-EU-230":
        return 600;
      case "SUN300G3-EU-230":
        return 300;
      case "SUN-M60/80/100G4-EU-Q0":
        return 800;
      default:
        return null;
    }
  }

  /// Generic command sender for DeyeSun API endpoints
  /// Sends POST request with Basic auth and optional additional headers
  Future<Map<String, dynamic>?> _sendCommand(
    String path,
    Map<String, String> formData,
    {Map<String, String>? additionalHeaders,
    int timeoutSeconds = 5}
  ) async {
    final client = HttpClient();
    try {
      debugPrint('[${wifiDevice.getCurrentBaseUrl()}] Sending command to $path...');

      final uri = Uri.parse('${getBaseUri()}$path');
      final request = await client.postUrl(uri).timeout(Duration(seconds: timeoutSeconds));

      // Set base headers with preserveHeaderCase
      final credentials = base64Encode(utf8.encode('admin:admin'));
      request.headers.set('Authorization', 'Basic $credentials', preserveHeaderCase: true);
      request.headers.set('Content-Type', 'application/x-www-form-urlencoded', preserveHeaderCase: true);
      //request.headers.set('Accept', 'text/html,application/xhtml+xml', preserveHeaderCase: true);

      // Add any additional headers if provided
      if (additionalHeaders != null) {
        additionalHeaders.forEach((key, value) {
          request.headers.set(key, value, preserveHeaderCase: true);
        });
      }

      // Build form-urlencoded body
      var body = formData.entries
          .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
          .join('&');

      request.headers.set('Content-Length', body.length, preserveHeaderCase: true);

      debugPrint(body);
      debugPrint(request.headers.toString());

      request.write(body);

      final response = await request.close().timeout(Duration(seconds: timeoutSeconds));

      if (response.statusCode == 200) {
        debugPrint('[${wifiDevice.getCurrentBaseUrl()}] Command to $path successful');
        return {'success': true};
      } else {
        final responseBody = await response.transform(utf8.decoder).join();
        debugPrint('[${wifiDevice.getCurrentBaseUrl()}] Command to $path failed: ${response.statusCode}');
        debugPrint('[${wifiDevice.getCurrentBaseUrl()}] Response: ${responseBody.substring(0, responseBody.length > 200 ? 200 : responseBody.length)}');
        return null;
      }
    } catch (e) {
      debugPrint('[${wifiDevice.getCurrentBaseUrl()}] Error sending command to $path: $e');
      return null;
    } finally {
      client.close();
    }
  }

  /// Public API for sending commands to DeyeSun device
  /// Automatically adds / prefix and .html suffix to command
  /// Automatically builds full referer URL from base URI
  Future<Map<String, dynamic>?> sendCommand(
    String command,
    String referer,
    Map<String, String> formData,
  ) async {
    final path = '/$command.html';
    final fullReferer = '${getBaseUri()}/$referer.html';

    return await _sendCommand(
      path,
      formData,
      additionalHeaders: {'Referer': fullReferer},
    );
  }

  /// Fetch device status data (used for COMMAND_FETCH_DATA)
  Future<Map<String, dynamic>?> fetchStatus() async {
    try {
      final response = await _fetchWithAuth('${getBaseUri()}/status.html', timeoutSeconds: 5);
      if (response.statusCode == 200) {
        final body = await response.transform(utf8.decoder).join();
        final jsVars = _parseJavaScriptVariables(body);
        return jsVars.cast<String, dynamic>();
      }
    } catch (e) {
      debugPrint('[${wifiDevice.getCurrentBaseUrl()}] Error fetching status: $e');
    }
    return null;
  }

  /// Fetch configuration data from different pages
  /// Takes page name as parameter (e.g., 'wirepoint', 'wireless', 'remote')
  /// Returns parsed JavaScript variables as Map
  Future<Map<String, dynamic>?> fetchConfig(String page) async {
    try {
      final response = await _fetchWithAuth('${getBaseUri()}/$page.html', timeoutSeconds: 5);
      if (response.statusCode == 200) {
        final body = await response.transform(utf8.decoder).join();
        final jsVars = _parseJavaScriptVariables(body);
        return jsVars.cast<String, dynamic>();
      }
    } catch (e) {
      debugPrint('[${wifiDevice.getCurrentBaseUrl()}] Error fetching config from $page: $e');
    }
    return null;
  }

  @override
  Future<void> disconnect() async {
    fetchDataEnabled = false;
    await _modbusConnection.disconnect();
  }

  @override
  void dispose() {
    _modbusConnection.dispose();
    super.dispose();
  }

  String getBaseUri(){
    return 'http://${wifiDevice.getCurrentBaseUrl()}';
  }

  @override
  Future<void> connect() async {

    try {
      await (device as DeviceWifiMixin).connectIpOrHostname((ip, port) async {
        await fetchData();//fetch data without socket connection
        //fetch data will also connect modbus if needed
      });
    }catch (ex){
      throw new Exception("Could not connect to deye sun device");
    }

    //This have to be done twice... fist read always fails no idea why... buffer seems ok and cleared after connect (even delay wont work)
    //mbay a helly message is nessesary
    await fetchData();
    resetTimer();
  }

  @override
  Future<void> fetchData() async {
    if (!fetchDataEnabled) return;

    String connectedWith = "";

    try {
      final response = await _fetchWithAuth('${getBaseUri()}/status.html', timeoutSeconds: 5);

      if (response.statusCode == 200) {
        // Read response body
        final body = await response.transform(utf8.decoder).join();

        // Parse JavaScript variables from HTML
        final jsVars = _parseJavaScriptVariables(body);

        var model = getModelFromSerial(device.deviceSn);
        if (model != null) {
          jsVars['model'] = model;
          final powerRating = getPowerRatingForModel(model);
          if (powerRating != null) {
            jsVars['power_rating'] = powerRating;
          }
        }

        // Store all parsed variables in config (HTTP is for configuration)
        device.data["config"] = jsVars;

        //debugPrint("jsVars extracted deye sun: ${jsVars.toString()}");

        device.emitData(jsVars);

        debugPrint('[${wifiDevice.getCurrentBaseUrl()}] Fetched HTTP data');
        lastSeen = DateTime.now().millisecondsSinceEpoch;
        if(connectedWith.isNotEmpty){
          connectedWith+=",";
        }
        connectedWith += "http";
      } else {
        debugPrint('[${wifiDevice.getCurrentBaseUrl()}] DeyeSun fetch data error: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('[${wifiDevice.getCurrentBaseUrl()}] DeyeSun fetch data exception: $e');
    }

    // Try Modbus connection first for real-time data
    try {
      // Connect Modbus if available
      if (!_modbusConnection.isConnected) {
        await _modbusConnection.connect(
          wifiDevice.getCurrenHostOrIp(),
          (device as AdditionalPortMixin).additionalPort ??  DeyeSunModbusConnection.DEFAULT_PORT,
          wifiDevice.deviceSn,
        );
      }

      // Read registers 40-116 (77 registers total)
      final registers = await _modbusConnection.readRegisters(40, 77);

      if (registers != null && registers.isNotEmpty) {
        // Parse register data and store in device.data['data']
        final modbusData = _parseModbusRegisters(registers);
        device.data["data"] = modbusData;
        device.emitData(modbusData);

        debugPrint('[${wifiDevice.getCurrentBaseUrl()}] Fetched Modbus data: ${registers.length} registers');
        connectedWith += "Modbus";
      } else {
        debugPrint('[${wifiDevice.getCurrentBaseUrl()}] Modbus read failed');
      }
    } catch (e) {
      debugPrint('[${wifiDevice.getCurrentBaseUrl()}] Modbus fetch error: $e');
    }

    if(connectedWith.isNotEmpty){
      device.emitStatus('Verbunden ($connectedWith)');
    }else{
      device.emitStatus('Nicht Verbunden');
    }
  }

  @override
  bool isConnected() {
    return (DateTime.now().millisecondsSinceEpoch - lastSeen) < 1000 * 30;
  }

  @override
  bool isInitialized() {
    return device.data["config"] != null || device.data["data"] != null;
  }

  /// Parse Modbus register data into usable format
  ///
  /// Based on official Deye micro inverter register mapping
  /// Registers 40-116 (77 registers total, indexed 0-76 in array)
  Map<String, dynamic> _parseModbusRegisters(List<int> registers) {
    if (registers.length < 77) {
      debugPrint('[DeyeModbus] Invalid register count: ${registers.length}');
      return {};
    }

    final data = <String, dynamic>{};

    // Helper function to get register value by register address
    int reg(int address) {
      final index = address - 40;
      return (index >= 0 && index < registers.length) ? registers[index] : 0;
    }

    // Helper function to parse DWORD (32-bit value from two consecutive registers)
    int regDword(int lowAddress) {
      final low = reg(lowAddress);
      final high = reg(lowAddress + 1);
      return (high << 16) | low;
    }

    // Power Limit Control
    data['limit_percentage'] = reg(40);  // Current power limit (0-100%)
    data['limit_status'] = reg(43);  // Limit status (1=on, 2=off)

    // Production Data
    data['day_energy'] = reg(60) * 0.1;  // kWh
    data['total_energy'] = regDword(63) * 0.1;  // kWh

    // Grid AC Data
    data['ac_voltage'] = reg(73) * 0.1;  // V
    data['ac_current'] = reg(76) * 0.1;  // A
    data['ac_frequency'] = reg(79) * 0.01;  // Hz
    data['ac_power'] = regDword(86) * 0.1;  // W

    // Uptime and Operating Power
    data['uptime'] = reg(62);  // minutes
    data['operating_power'] = reg(80) * 0.1;  // W

    // Radiator Temperature
    data['radiator_temp'] = reg(90) * 0.01;  // °C

    // PV1 Data
    final pv1Voltage = reg(109) * 0.1;
    final pv1Current = reg(110) * 0.1;
    data['pv1_voltage'] = pv1Voltage;  // V
    data['pv1_current'] = pv1Current;  // A
    data['pv1_power'] = pv1Voltage * pv1Current;  // W (computed)
    data['pv1_day_energy'] = reg(65) * 0.1;  // kWh
    data['pv1_total_energy'] = regDword(69) * 0.1;  // kWh

    // PV2 Data
    final pv2Voltage = reg(111) * 0.1;
    final pv2Current = reg(112) * 0.1;
    data['pv2_voltage'] = pv2Voltage;  // V
    data['pv2_current'] = pv2Current;  // A
    data['pv2_power'] = pv2Voltage * pv2Current;  // W (computed)
    data['pv2_day_energy'] = reg(66) * 0.1;  // kWh
    data['pv2_total_energy'] = regDword(71) * 0.1;  // kWh

    // PV3 Data
    final pv3Voltage = reg(113) * 0.1;
    final pv3Current = reg(114) * 0.1;
    data['pv3_voltage'] = pv3Voltage;  // V
    data['pv3_current'] = pv3Current;  // A
    data['pv3_power'] = pv3Voltage * pv3Current;  // W (computed)
    data['pv3_day_energy'] = reg(67) * 0.1;  // kWh
    data['pv3_total_energy'] = regDword(74) * 0.1;  // kWh

    // PV4 Data
    final pv4Voltage = reg(115) * 0.1;
    final pv4Current = reg(116) * 0.1;
    data['pv4_voltage'] = pv4Voltage;  // V
    data['pv4_current'] = pv4Current;  // A
    data['pv4_power'] = pv4Voltage * pv4Current;  // W (computed)
    data['pv4_day_energy'] = reg(68) * 0.1;  // kWh
    data['pv4_total_energy'] = regDword(77) * 0.1;  // kWh

    // DC Total Power (sum of all PV powers)
    final dcTotalPower = (pv1Voltage * pv1Current) +
                         (pv2Voltage * pv2Current) +
                         (pv3Voltage * pv3Current) +
                         (pv4Voltage * pv4Current);
    data['dc_total_power'] = dcTotalPower;  // W

    // Add raw register data for debugging
    data['_raw_registers'] = registers;

    // Print all registers for debugging
    /*debugPrint('[DeyeModbus] === Register Dump ===');
    for (int i = 0; i < registers.length; i++) {
      final address = 40 + i;
      final value = registers[i];
      debugPrint('[DeyeModbus] Reg $address (0x${address.toRadixString(16).padLeft(2, '0').toUpperCase()}): $value (0x${value.toRadixString(16).padLeft(4, '0').toUpperCase()})');
    }
    debugPrint('[DeyeModbus] === End Register Dump ===');*/

    return data;
  }

  /// Write power limit via Modbus
  ///
  /// Register 0x0028 (40 decimal) contains power limit percentage
  Future<bool> writeModbusPowerLimit(int percentage) async {
    if (_modbusConnection == null || !_modbusConnection!.isConnected) {
      debugPrint('[DeyeModbus] Cannot write power limit - not connected');
      return false;
    }

    if (percentage < 0 || percentage > 100) {
      debugPrint('[DeyeModbus] Invalid power limit: $percentage');
      return false;
    }

    try {
      debugPrint('[DeyeModbus] Writing power limit: $percentage%');
      final success = await _modbusConnection!.writeRegister(0x0028, percentage);

      if (success) {
        debugPrint('[DeyeModbus] Power limit set successfully');
      } else {
        debugPrint('[DeyeModbus] Failed to set power limit');
      }

      return success;
    } catch (e) {
      debugPrint('[DeyeModbus] Error writing power limit: $e');
      return false;
    }
  }

  /// Write power status (on/off) via Modbus
  ///
  /// Register 0x002B (43 decimal) contains power status
  /// 1 = on, 2 = off
  Future<bool> writeModbusPowerStatus(bool on) async {
    if (_modbusConnection == null || !_modbusConnection!.isConnected) {
      debugPrint('[DeyeModbus] Cannot write power status - not connected');
      return false;
    }

    final value = on ? 1 : 2;

    try {
      debugPrint('[DeyeModbus] Writing power status: ${on ? "on" : "off"} (value: $value)');
      final success = await _modbusConnection!.writeRegister(0x002B, value);

      if (success) {
        debugPrint('[DeyeModbus] Power status set successfully');
      } else {
        debugPrint('[DeyeModbus] Failed to set power status');
      }

      return success;
    } catch (e) {
      debugPrint('[DeyeModbus] Error writing power status: $e');
      return false;
    }
  }
}
