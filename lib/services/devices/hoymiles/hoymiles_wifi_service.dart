import 'dart:io';

import 'package:fixnum/fixnum.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:the_solar_app/constants/bluetooth_constants.dart';
import 'package:the_solar_app/models/device.dart';
import 'package:the_solar_app/models/network_device.dart';
import 'package:the_solar_app/models/additional_connection_info.dart';
import 'package:the_solar_app/services/devices/base_device_service.dart';

import 'package:the_solar_app/models/devices/manufacturers/hoymiles/hoymiles_device.dart';
import 'package:the_solar_app/models/devices/manufacturers/hoymiles/protobuf/RealDataNew.pb.dart';
import 'package:the_solar_app/models/devices/manufacturers/hoymiles/protobuf/GetConfig.pb.dart';
import 'package:the_solar_app/models/devices/manufacturers/hoymiles/protobuf/NetworkInfo.pb.dart';
import 'package:the_solar_app/models/devices/manufacturers/hoymiles/protobuf/CommandPB.pb.dart';
import 'hoymiles_protocol.dart';
import 'hoymiles_tcp_connection.dart';

class HoymilesWifiService extends BaseDeviceService {
  final HoymilesProtocol _protocol = HoymilesProtocol();
  HoymilesTcpConnection? _connection;
  int lastSeen = 0;
  bool fetchDataEnabled = true;
  late HoymilesDevice hoymilesDevice;

  /// Power mapping table from Hoymiles serial number prefix to power rating
  /// Based on hoymiles-wifi Python reference implementation
  static const Map<int, String> _powerMapping = {
    0x1011: "100W",
    0x1020: "250W",
    0x1021: "300W/350W/400W",  // ambiguous range
    0x1121: "300W/350W/400W",  // ambiguous range
    0x1125: "400W",
    0x1403: "400W/500W",       // ambiguous range
    0x1040: "500W",
    0x1041: "600W/700W/800W",  // ambiguous range
    0x1042: "600W/700W/800W",  // ambiguous range
    0x1141: "600W/700W/800W",  // ambiguous range
    0x1144: "1000W",
    0x1060: "1000W",
    0x1061: "1200W/1500W",     // ambiguous range
    0x1161: "1000W/1200W/1500W", // ambiguous range
    0x1164: "1600W/1800W/2000W", // ambiguous range
    0x1412: "800W/1000W",      // ambiguous range
    0x1382: "2250W",
    0x2821: "1000W",
    0x1222: "2000DW",
  };

  /// DTU type mapping table from serial number prefix to DTU model
  /// Based on hoymiles-wifi Python reference implementation
  static const Map<int, String> _dtuTypeMapping = {
    0x10F7: "DTU-PRO", 0x10FB: "DTU-PRO", 0x4101: "DTU-PRO",
    0x10FC: "DTU-PRO", 0x4120: "DTU-PRO", 0x10F8: "DTU-PRO",
    0x4100: "DTU-PRO", 0x10FD: "DTU-PRO", 0x4121: "DTU-PRO",
    0x10D3: "DTU-W100/Lite-S", 0x4110: "DTU-W100/Lite-S",
    0x10D8: "DTU-W100/Lite-S", 0x4130: "DTU-W100/Lite-S",
    0x4132: "DTU-W100/Lite-S", 0x4133: "DTU-W100/Lite-S",
    0x10D9: "DTU-W100/Lite-S", 0x4111: "DTU-W100/Lite-S",
    0x10D2: "DTU-G100",
    0x10D6: "DTU-Lite", 0x10D7: "DTU-Lite", 0x4131: "DTU-Lite",
    0x1124: "DTUBI", 0x1125: "DTUBI", 0x1403: "DTUBI",
    0x1144: "DTUBI", 0x1143: "DTUBI", 0x1145: "DTUBI",
    0x1412: "DTUBI", 0x1164: "DTUBI", 0x1165: "DTUBI",
    0x1166: "DTUBI", 0x1167: "DTUBI", 0x1222: "DTUBI",
    0x1422: "DTUBI", 0x1423: "DTUBI", 0x1361: "DTUBI",
    0x1362: "DTUBI", 0x1381: "DTUBI", 0x1382: "DTUBI",
    0x4141: "DTUBI", 0x4143: "DTUBI", 0x4144: "DTUBI",
    0xD030: "DTU-SLS",
    0x4301: "DTS-WIFI-G1",
  };

  HoymilesWifiService(DeviceBase device)
      : super((device as HoymilesDevice).fetchDataInterval, device) {
    hoymilesDevice = device as HoymilesDevice;
    // Fetch first data
    fetchData();
  }

  /// Detect if serial is a DTU (not an inverter)
  /// Returns DTU type string (e.g., "DTUBI", "DTU-PRO") or null if not a DTU
  static String? getDtuType(String? serialNumber) {
    if (serialNumber == null || serialNumber.isEmpty) return null;

    try {
      final serialBytes = <int>[];
      for (int i = 0; i < serialNumber.length && i < 4; i += 2) {
        final byteString = serialNumber.substring(i, i + 2);
        serialBytes.add(int.parse(byteString, radix: 16));
      }

      if (serialBytes.length < 2) return null;

      final dtuKey = (serialBytes[0] << 8) | serialBytes[1];
      return _dtuTypeMapping[dtuKey];
    } catch (e) {
      debugPrint('[Hoymiles] Error detecting DTU type: $e');
      return null;
    }
  }

  /// Get inverter tracker type from serial number bytes
  /// Returns tracker count string (1T, 2T, 4T, 6T) or null if unknown
  static String? _getInverterType(List<int> serialBytes) {
    if (serialBytes.length < 2) return null;

    final byte0 = serialBytes[0];
    final byte1 = serialBytes[1];

    if (byte0 == 0x10) {
      if (byte1 == 0x14) return "2T";
    } else if (byte0 == 0x11) {
      if ([0x25, 0x24, 0x22, 0x21].contains(byte1)) return "1T";
      if ([0x44, 0x42, 0x41].contains(byte1)) return "2T";
      if ([0x64, 0x62, 0x61].contains(byte1)) return "4T";
    } else if (byte0 == 0x12) {
      if (byte1 == 0x22) return "4T";
    } else if (byte0 == 0x13) {
      return "6T";
    } else if (byte0 == 0x14) {
      if (byte1 == 0x03) return "1T";
      if ([0x10, 0x12].contains(byte1)) return "2T";
    } else if (byte0 == 0x28) {
      if (byte1 == 0x21) return "2T";
    }

    return null;
  }

  /// Get inverter series from serial number bytes
  /// Returns series string (HM, HMS, HMT, SOL-H) or null if unknown
  static String? _getInverterSeries(List<int> serialBytes) {
    if (serialBytes.length < 2) return null;

    final byte0 = serialBytes[0];
    final byte1 = serialBytes[1];

    if (byte0 == 0x10) {
      // Check bit pattern: if (byte1 & 0x03) == 0x02, it's HM, else HMS
      return (byte1 & 0x03) == 0x02 ? "HM" : "HMS";
    } else if (byte0 == 0x11) {
      // Check bit pattern: if (byte1 & 0x0F) == 0x04, it's HMS, else HM
      return (byte1 & 0x0F) == 0x04 ? "HMS" : "HM";
    } else if (byte0 == 0x12) {
      return "HMS";
    } else if (byte0 == 0x13) {
      return "HMT";
    } else if (byte0 == 0x14) {
      return "HMS";
    } else if (byte0 == 0x28) {
      return "SOL-H";
    }

    return null;
  }

  /// Get inverter power rating string from serial number bytes
  /// Returns power string (e.g., "800W", "600W/700W/800W") or null if unknown
  static String? _getInverterPower(List<int> serialBytes) {
    if (serialBytes.length < 2) return null;

    // Combine first 2 bytes into 16-bit integer (big-endian)
    final key = (serialBytes[0] << 8) | serialBytes[1];
    return _powerMapping[key];
  }

  /// Generate complete model name from serial number
  /// Returns model string (e.g., "HMS-800W-2T") or null if parsing fails
  static String? getModelFromSerial(String? serialNumber) {
    if (serialNumber == null || serialNumber.isEmpty) return null;

    try {
      // Convert hex string to bytes
      final serialBytes = <int>[];
      for (int i = 0; i < serialNumber.length && i < 4; i += 2) {
        final byteString = serialNumber.substring(i, i + 2);
        serialBytes.add(int.parse(byteString, radix: 16));
      }

      if (serialBytes.length < 2) return null;

      // Get components
      final series = _getInverterSeries(serialBytes);
      final power = _getInverterPower(serialBytes);
      final type = _getInverterType(serialBytes);

      // All components must be present
      if (series == null || power == null || type == null) return null;

      // Construct model name: SERIES-POWER-TYPE
      return "$series-$power-$type";
    } catch (e) {
      debugPrint('[Hoymiles] Error parsing serial number: $e');
      return null;
    }
  }

  /// Extract numeric power rating from model name
  /// Returns power in watts or null if ambiguous/unknown
  static int? getPowerRatingForModel(String? model) {
    if (model == null) return null;

    // If model contains "/" it's an ambiguous range, return null
    if (model.contains('/')) {
      return null;
    }

    // Extract first numeric value from model name
    // Example: "HMS-800W-2T" -> 800
    // Example: "HMS-2000DW-4T" -> 2000
    final matches = RegExp(r'(\d+)W').allMatches(model);
    if (matches.length != 1) {
      return null;
    }

    return int.tryParse(matches.first.group(1)!);
  }

  /// Static method to detect if response is from a Hoymiles device
  ///
  /// Since Hoymiles uses TCP on port 10081, not HTTP, we need to probe the port directly
  static Future<NetworkDevice?> isResponseFromManufacturer(
    String ipAddress,
    http.Response? initialResponse,
    AdditionalConnectionInfo connectionInfo,
  ) async {
    try {
      debugPrint('[Hoymiles] Probing $ipAddress:${HoymilesProtocol.DTU_PORT}');

      // Attempt to connect to Hoymiles port
      final socket = await Socket.connect(
        ipAddress,
        HoymilesProtocol.DTU_PORT,
        timeout: connectionInfo.timeout,
      );

      // Send RealDataNew request to identify device
      final protocol = HoymilesProtocol();
      final request = RealDataNewResDTO(); // Use empty request message

      final message = protocol.generateMessage(
        HoymilesProtocol.CMD_REAL_RES_DTO,
        request,
      );

      socket.add(message);
      await socket.flush();

      // Wait for response with timeout
      final response = await socket.first.timeout(
        connectionInfo.timeout,
        onTimeout: () => Uint8List(0),
      );

      await socket.close();

      if (response.isEmpty) {
        debugPrint('[Hoymiles] No response from $ipAddress');
        return null;
      }

      // Parse response
      final parsed = protocol.parseResponse(response);
      if (parsed == null) {
        debugPrint('[Hoymiles] Invalid response from $ipAddress');
        return null;
      }

      debugPrint('[Hoymiles] Found Hoymiles device at $ipAddress');

      // Try to determine device model by fetching real data
      String deviceModel = 'Unknown';
      String serialNumber = 'hoymiles_$ipAddress';

      try {
        // Quick attempt to get device serial from real data
        final realDataSocket = await Socket.connect(
          ipAddress,
          HoymilesProtocol.DTU_PORT,
          timeout: connectionInfo.timeout,
        );

        final realDataRequest = RealDataNewResDTO()
          ..timeYmdHms = DateTime.now()
              .toIso8601String()
              .replaceAll('T', ' ')
              .substring(0, 19)
              .codeUnits
          ..offset = HoymilesProtocol.OFFSET
          ..time = (DateTime.now().millisecondsSinceEpoch / 1000).floor()
          ..cp = 0;

        final realDataMessage = protocol.generateMessage(
          HoymilesProtocol.CMD_REAL_RES_DTO,
          realDataRequest,
        );

        realDataSocket.add(realDataMessage);
        await realDataSocket.flush();

        final realDataResponse = await realDataSocket.first.timeout(
          connectionInfo.timeout,
          onTimeout: () => Uint8List(0),
        );

        await realDataSocket.close();

        if(realDataResponse.isEmpty){
          throw Exception("[Hoymiles]: could not parse init data");
        }
        final realDataParsed = protocol.parseResponse(realDataResponse);
        if(realDataParsed == null){
          throw Exception("[Hoymiles]: could not parse init data");
        }

        final realData = RealDataNewReqDTO.fromBuffer(realDataParsed['data'] as List<int>);
        if(realData.deviceSerialNumber.isEmpty){
          throw Exception("[Hoymiles]: could not parse init data");
        }
        serialNumber = realData.deviceSerialNumber;

        debugPrint(realData.toString());
        debugPrint("serial to use: $serialNumber");

        // Check if DTU type
        final dtuType = getDtuType(serialNumber);
        if (dtuType != null) {
          // It's a DTU - for DTUBI, get inverter model from sgsData/tgsData
          if (dtuType == "DTUBI" && (realData.sgsData.isNotEmpty || realData.tgsData.isNotEmpty)) {
            // Get first inverter serial and convert to hex
            String? inverterSerial;
            if (realData.sgsData.isNotEmpty) {
              inverterSerial = realData.sgsData.first.serialNumber.toRadixString(16);
            } else if (realData.tgsData.isNotEmpty) {
              inverterSerial = realData.tgsData.first.serialNumber.toRadixString(16);
            }

            if (inverterSerial != null) {
              deviceModel = getModelFromSerial(inverterSerial) ?? dtuType;
            } else {
              deviceModel = dtuType;
            }
          } else {
            // Other DTU types just use DTU type name
            deviceModel = dtuType;
          }
        } else {
          // Not a DTU, treat as standalone inverter
          deviceModel = getModelFromSerial(serialNumber) ?? 'Unknown';

          // If model detection fails, fall back to generic type
          if (deviceModel == 'Unknown') {
            if (realData.sgsData.isNotEmpty || realData.tgsData.isNotEmpty) {
              deviceModel = 'HMS-Inverter';
            } else {
              deviceModel = 'DTU';
            }
          }
        }
      } catch (e) {
        debugPrint('[Hoymiles] Could not fetch detailed info: $e');
      }

      return NetworkDevice(
        ipAddress: ipAddress,
        manufacturer: DEVICE_MANUFACTURER_HOYMILES,
        deviceModel: deviceModel,
        serialNumber: serialNumber,
        port: HoymilesProtocol.DTU_PORT
      );
    } catch (e) {
      debugPrint('[Hoymiles] Error probing $ipAddress: $e');
      return null;
    }
  }

  @override
  Future<void> connect() async {
    device.emitStatus("Verbindungsaufbau...");

    try {
      // Create persistent connection if not exists
      _connection ??= HoymilesTcpConnection(
        host: hoymilesDevice.netIpAddress ?? '',
        port: hoymilesDevice.netPort ?? HoymilesProtocol.DTU_PORT,
        protocol: _protocol,
      );

      // Establish connection
      final connected = await _connection!.connect();
      if (!connected) {
        device.emitStatus("Verbindung fehlgeschlagen");
        throw Exception('Failed to connect to Hoymiles device');
      }

      // Test connection by fetching real data
      final result = await getRealDataNew();
      if (result != null) {
        device.emitStatus("Verbunden");
        lastSeen = DateTime.now().millisecondsSinceEpoch;
        device.data["data"] = result;
        device.emitData(result);

        resetTimer();
      } else {
        device.emitStatus("Verbindung fehlgeschlagen");
        throw Exception('Failed to connect to Hoymiles device');
      }
    } catch (e) {
      device.emitStatus("Verbindung fehlgeschlagen");
      debugPrint('[Hoymiles] Connection error: $e');
      rethrow;
    }
  }

  @override
  Future<void> disconnect() async {
    fetchDataEnabled = false;
    await _connection?.disconnect();
    device.emitStatus("Getrennt");
  }

  @override
  void dispose() {
    fetchDataEnabled = false;
    _connection?.dispose();
    super.dispose();
  }

  @override
  bool isConnected() {
    return _connection?.isConnected ?? false;
  }

  @override
  bool isInitialized() {
    return device.data["data"] != null;
  }

  @override
  void fetchData() async {
    if (!fetchDataEnabled) return;

    try {
      // Fetch real-time data
      final realData = await getRealDataNew();
      if (realData != null) {
        device.data["data"] = realData;
        device.emitData(realData);
        lastSeen = DateTime.now().millisecondsSinceEpoch;
        device.emitStatus("Verbunden");
      } else {
        device.emitStatus("Keine Daten");
      }
    } catch (e) {
      debugPrint('[Hoymiles] Error fetching data: $e');
      device.emitStatus("Fehler beim Abrufen der Daten");
    }
  }

  /// Get real-time data from device (RealDataNew command)
  Future<Map<String, dynamic>?> getRealDataNew() async {
    if (_connection == null || !_connection!.isConnected) {
      debugPrint('[Hoymiles] Not connected');
      return null;
    }

    try {
      final request = RealDataNewResDTO()
        ..timeYmdHms = DateTime.now()
            .toIso8601String()
            .replaceAll('T', ' ')
            .substring(0, 19)
            .codeUnits
        ..offset = HoymilesProtocol.OFFSET
        ..time = (DateTime.now().millisecondsSinceEpoch / 1000).floor()
        ..cp = 0;

      final parsed = await _connection!.sendRequest(
        request,
        HoymilesProtocol.CMD_REAL_RES_DTO,
      );

      if (parsed == null) {
        debugPrint('[Hoymiles] No response from device');
        return null;
      }

      final response = RealDataNewReqDTO.fromBuffer(parsed['data'] as List<int>);

      debugPrint("Received: ${response.toString()}");

      // Convert protobuf response to Map for easier access in UI
      final result = <String, dynamic>{
        'device_serial_number': response.deviceSerialNumber,
        'timestamp': response.timestamp,
        'dtu_power': response.dtuPower.toInt(),
        'dtu_daily_energy': response.dtuDailyEnergy.toInt() / 1000.0, // Wh → kWh
        'firmware_version': response.firmwareVersion,
      };

      var inverters = <String,dynamic>{};

      for (var sgs in response.sgsData) {
        // Convert int64 serial number to hex string
        String sn = sgs.serialNumber.toRadixString(16);

        var powerRating = getPowerRatingForModel(getModelFromSerial(sn));

        if(!inverters.containsKey(sn)){
          inverters[sn] = <String,dynamic>{};
        }

        // Validate and clamp power limit (zero is likely a sensor error)
        var powerLimit = sgs.powerLimit / 10;
        if (powerLimit <= 0 || powerLimit > 100) {
          powerLimit = 100;
        }

        inverters[sn]["sgs"] = {
          'firmware_version': sgs.firmwareVersion,
          'voltage': sgs.voltage / 10.0,        // Protobuf 0.1V → V
          'frequency': sgs.frequency / 100.0,   // Protobuf 0.01Hz → Hz
          'active_power': sgs.activePower / 10,
          'reactive_power': sgs.reactivePower,
          'current': sgs.current,
          'power_factor': sgs.powerFactor,
          'temperature': sgs.temperature / 10.0, // Protobuf 0.1°C → °C
          'warning_number': sgs.warningNumber,
          'link_status': sgs.linkStatus,
          'power_limit': powerLimit,             // Validated + scaled
          'power_rating': powerRating
        };
      }

      for (var tgs in response.tgsData) {
        // Convert int64 serial number to hex string
        String sn = tgs.serialNumber.toRadixString(16);

        if(!inverters.containsKey(sn)){
          inverters[sn] = <String,dynamic>{};
        }
        inverters[sn]["tgs"] = {
            'firmware_version': tgs.firmwareVersion,
            'voltage_phase_a': tgs.voltagePhaseA,
            'voltage_phase_b': tgs.voltagePhaseB,
            'voltage_phase_c': tgs.voltagePhaseC,
            'frequency': tgs.frequency,
            'active_power': tgs.activePower  / 10,
            'reactive_power': tgs.reactivePower,
            'current_phase_a': tgs.currentPhaseA,
            'current_phase_b': tgs.currentPhaseB,
            'current_phase_c': tgs.currentPhaseC,
            'power_factor': tgs.powerFactor,
            'temperature': tgs.temperature,
            'warning_number': tgs.warningNumber,
            'link_status': tgs.linkStatus,
          };
        }

      for (var pv in response.pvData) {
        // Convert int64 serial number to hex string
        String sn = pv.serialNumber.toRadixString(16);
        if (!inverters.containsKey(sn)) {
          inverters[sn] = <String, dynamic>{};
        }
        var inv = inverters[sn];
        if (!inv.containsKey("pv")) {
          inv["pv"] = <String, dynamic>{};
        }
        var pvRes = inv["pv"] as Map<String, dynamic>;
        String portNumber = pv.portNumber.toString();
        pvRes[portNumber] = {
            'voltage': pv.voltage / 10.0,           // Protobuf 0.1V → V
            'current': pv.current / 100.0,          // Protobuf 0.01A → A
            'power': pv.power / 10.0,               // Protobuf 0.1W → W
            'energy_total': pv.energyTotal / 1000.0, // Wh → kWh
            'energy_daily': pv.energyDaily / 1000.0, // Wh → kWh
            'error_code': pv.errorCode,
          };
      }

      result["inverters"] = inverters;

      if(inverters.length == 1){
        result["inverter"] = inverters.entries.first.value;
      }

      // Determine device model and power rating
      String? deviceModel;

      // Check if DTU serial is a DTU type
      final dtuType = getDtuType(response.deviceSerialNumber);
      if (dtuType != null) {
        // It's a DTU - for DTUBI, get inverter model from sgsData/tgsData
        if (dtuType == "DTUBI" && inverters.isNotEmpty) {
          // Get first inverter serial (already converted to hex in loop above)
          final inverterSerial = inverters.keys.first;
          deviceModel = getModelFromSerial(inverterSerial);
        }

        // Store DTU type separately
        result['dtu_type'] = dtuType;
      } else {
        // Not a DTU, treat device_serial_number as inverter
        deviceModel = getModelFromSerial(response.deviceSerialNumber);
      }

      debugPrint('[Hoymiles] Fetched real data: ${result.toString()}');
      return result;
    } catch (e) {
      debugPrint('[Hoymiles] Error in getRealDataNew: $e');
      return null;
    }
  }

  /// Get device configuration
  Future<Map<String, dynamic>?> getConfig() async {
    if (_connection == null || !_connection!.isConnected) {
      debugPrint('[Hoymiles] Not connected');
      return null;
    }

    try {
      final request = GetConfigResDTO()
        ..offset = HoymilesProtocol.OFFSET
        ..time = (DateTime.now().millisecondsSinceEpoch / 1000).floor() - 60;

      final parsed = await _connection!.sendRequest(
        request,
        HoymilesProtocol.CMD_GET_CONFIG,
      );

      if (parsed == null) {
        debugPrint('[Hoymiles] No response from device');
        return null;
      }

      final response = GetConfigReqDTO.fromBuffer(parsed['data'] as List<int>);

      // Extract power limit (divide by 10 to get percentage)
      final limitPowerMypower = response.limitPowerMypower;
      final powerLimitPercent = limitPowerMypower != 0
          ? (limitPowerMypower / 10).round()
          : null;

      // Convert to Map with power limit
      final configMap = response.toProto3Json() as Map<String, dynamic>;
      configMap['power_limit_percent'] = powerLimitPercent;

      return configMap;
    } catch (e) {
      debugPrint('[Hoymiles] Error in getConfig: $e');
      return null;
    }
  }

  /// Get network information
  Future<Map<String, dynamic>?> getNetworkInfo() async {
    if (_connection == null || !_connection!.isConnected) {
      debugPrint('[Hoymiles] Not connected');
      return null;
    }

    try {
      final request = NetworkInfoResDTO()
        ..offset = HoymilesProtocol.OFFSET
        ..time = (DateTime.now().millisecondsSinceEpoch / 1000).floor();

      final parsed = await _connection!.sendRequest(
        request,
        HoymilesProtocol.CMD_NETWORK_INFO_RES,
      );

      if (parsed == null) {
        debugPrint('[Hoymiles] No response from device');
        return null;
      }

      final response = NetworkInfoReqDTO.fromBuffer(parsed['data'] as List<int>);

      // Convert to Map
      return response.toProto3Json() as Map<String, dynamic>;
    } catch (e) {
      debugPrint('[Hoymiles] Error in getNetworkInfo: $e');
      return null;
    }
  }

  /// Set power limit (percentage 0-100)
  Future<bool> setPowerLimit(int limitPercent) async {
    if (_connection == null || !_connection!.isConnected) {
      debugPrint('[Hoymiles] Not connected');
      return false;
    }

    // Validate input (0-100%)
    if (limitPercent < 0 || limitPercent > 100) {
      debugPrint('[Hoymiles] Invalid limit: $limitPercent% (must be 0-100)');
      return false;
    }

    try {
      // Convert percentage to protocol format (multiply by 10)
      final limitLevel = limitPercent * 10;

      // Build data string: "A:{limitLevel},B:0,C:0\r"
      final dataString = 'A:$limitLevel,B:0,C:0\r';

      // Create CommandResDTO request
      final timestamp = (DateTime.now().millisecondsSinceEpoch / 1000).floor();
      final request = CommandResDTO()
        ..time = timestamp
        ..action = 8  // CMD_ACTION_LIMIT_POWER
        ..packageNub = 1
        ..packageNow = 0
        ..tid = Int64(timestamp)
        ..data = dataString;

      final parsed = await _connection!.sendRequest(
        request,
        HoymilesProtocol.CMD_COMMAND_RES_DTO,
      );

      if (parsed == null) {
        debugPrint('[Hoymiles] No response from setPowerLimit');
        return false;
      }

      // Parse response
      final response = CommandReqDTO.fromBuffer(parsed['data'] as List<int>);

      if (response.errCode == 0) {
        debugPrint('[Hoymiles] Power limit set successfully to $limitPercent%');
        return true;
      } else {
        debugPrint('[Hoymiles] Power limit failed with error code: ${response.errCode}');
        return false;
      }
    } catch (e) {
      debugPrint('[Hoymiles] Error in setPowerLimit: $e');
      return false;
    }
  }
}
