import 'dart:async';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:the_solar_app/constants/bluetooth_constants.dart';
import 'package:the_solar_app/models/devices/mixins/additional_port_mixin.dart';
import 'package:the_solar_app/models/devices/mixins/device_wifi_mixin.dart';
import 'package:the_solar_app/models/network_device.dart';
import 'package:the_solar_app/models/additional_connection_info.dart';
import 'package:the_solar_app/services/devices/base_device_service.dart';
import 'package:http/http.dart' as http;

import '../../../models/devices/manufacturers/kostal/wifi_kostal_device.dart';
import 'kostal_modbus_connection.dart';

class KostalWifiService extends BaseDeviceService {
  // Connection timeout - if no data received within this time, consider disconnected
  static const int CONNECTION_TIMEOUT_MS = 65000;  // 65 seconds

  late WiFiKostalDevice wifiDevice;

  // Modbus connection for real-time data
  late KostalModbusConnection _modbusConnection;

  KostalWifiService(WiFiKostalDevice device) : super(device.fetchDataInterval, device) {
    wifiDevice = device;
    _modbusConnection = KostalModbusConnection();
  }

  /// Static method to detect if device is a Kostal inverter
  ///
  /// Uses HTTP-based detection as primary method with TCP verification
  /// Returns a NetworkDevice if Kostal device detected, null otherwise
  static Future<NetworkDevice?> isResponseFromManufacturer(
    String ipAddress,
    int ? port,
    http.Response? initialResponse,
    AdditionalConnectionInfo connectionInfo,
  ) async {
    port ??= 80;
    try {
      // ===== STAGE 1: HTTP Detection =====

      // Check if initialResponse looks like Kostal device
      if (initialResponse == null || initialResponse.statusCode != 200) {
        return null; // No HTTP response, not Kostal
      }

      final body = initialResponse.body;
      final headers = initialResponse.headers;

      // Kostal-specific identifiers in HTML:
      // 1. Title tag contains "SCB" (Solar Control Board)
      // 2. JavaScript references branding.xml
      // 3. Server header contains nginx
      final hasScbTitle = body.contains('<title>SCB</title>');
      final hasBrandingXml = body.contains('branding.xml');

      // If none of the Kostal patterns match, return early
      if (!hasScbTitle && !hasBrandingXml) {
        return null; // Not a Kostal device
      }

      debugPrint('[$ipAddress:$port] Potential Kostal device detected via HTTP (SCB=$hasScbTitle, branding=$hasBrandingXml)');

      // ===== STAGE 2: TCP Verification =====

      // Quick TCP connection test to Modbus port to confirm device is reachable
      Socket? socket;
      try {
        socket = await Socket.connect(
          ipAddress,
          1502, // Kostal Modbus port
          timeout: const Duration(seconds: 2),
        );

        debugPrint('[$ipAddress:$port] TCP connection to port 1502 successful - Kostal device confirmed');

        // Close socket immediately
        await socket.close();

        // Return confirmed Kostal device
        return NetworkDevice(
          ipAddress: ipAddress,
          hostname: 'scb', // Kostal devices typically use 'scb' as hostname
          manufacturer: DEVICE_MANUFACTURER_KOSTAL,
          deviceModel: 'Kostal Plenticore', // Generic model (branding.xml needs auth)
          serialNumber: 'kostal_$ipAddress', // Use IP-based serial
          port: port, // HTTP port for web interface
        );
      } catch (e) {
        debugPrint('[$ipAddress:$port] TCP connection to port 1502 failed: $e');
        // HTML looked like Kostal but Modbus port not accessible - likely false positive
        return null;
      } finally {
        try {
          await socket?.close();
        } catch (_) {}
      }
    } catch (e) {
      debugPrint('[$ipAddress:$port] Error detecting Kostal device: $e');
    }

    return null;
  }

  @override
  Future<void> internalDisconnect() async {
    // Disconnect Modbus connection
    await _modbusConnection.disconnect();
  }

  @override
  void dispose() {
    _modbusConnection.dispose();
    super.dispose();
  }

  @override
  Future<bool> internalConnect() async {
    device.emitStatus('Verbindungsaufbau...');

    // Connect Modbus if not already connected
    if (!_modbusConnection.isConnected) {
      device.emitStatus('Verbinde Modbus...');

      try {
        //leave it as it is it is correct!
        await wifiDevice.connectIpOrHostname((ip, port) async {
          await _modbusConnection.connect(
            wifiDevice.getCurrenHostOrIp(),
            (device as AdditionalPortMixin).additionalPort,
          );
        });

        if (!_modbusConnection.isConnected) {
          device.emitStatus('Modbus Verbindung fehlgeschlagen');
          throw Exception("Could not connect Modbus");
        }
      } catch (e) {
        device.emitStatus('Modbus Verbindung fehlgeschlagen');
        rethrow;
      }
    }

    return true;//directly fetch again
  }

  @override
  Future<void> internalFetchData() async {
    // Try Modbus connection for real-time data
    if (_modbusConnection.isConnected) {
      final data = await _fetchModbusData();
      if (data != null && data.isNotEmpty) {
        device.data["data"] = data;
        device.emitData(data);

        debugPrint('[${wifiDevice.getCurrentBaseUrl()}] Fetched Modbus data: ${data.keys.length} fields');
        lastSeen = DateTime.now().millisecondsSinceEpoch;
        return;
      } else {
        debugPrint('[${wifiDevice.getCurrentBaseUrl()}] Modbus read returned no data');
        device.emitStatus('Keine Daten');
        return;
      }
    }

    throw Exception('Nicht Verbunden');
  }

  /// Fetch all data from Modbus registers
  Future<Map<String, dynamic>?> _fetchModbusData() async {
    final data = <String, dynamic>{};

    try {
      // Batch 1: Device info (registers 6-46)
      // Article number (6) and Software version (46)
      final deviceInfoRegs = await _modbusConnection.readRegisters(6, 41, 71);
      if (deviceInfoRegs != null) {
        _parseDeviceInfo(deviceInfoRegs, data);
      }

      // Batch 2: Main data - SPLIT INTO OPTIMIZED RANGES
      // (Kostal register map has gaps - cannot read all 100-326 consecutively)

      // Range 100-124 (25 registers)
      final range1 = await _modbusConnection.readRegisters(100, 25, 71);
      if (range1 != null) {
        _parseMainDataRange1(range1, data);
      }

      // Range 144-178 (35 registers)
      final range2 = await _modbusConnection.readRegisters(144, 35, 71);
      if (range2 != null) {
        _parseMainDataRange2(range2, data);
      }

      // Range 190-216 (27 registers)
      final range3 = await _modbusConnection.readRegisters(190, 27, 71);
      if (range3 != null) {
        _parseMainDataRange3(range3, data);
      }

      // Range 218-256 (39 registers)
      final range4 = await _modbusConnection.readRegisters(218, 39, 71);
      if (range4 != null) {
        _parseMainDataRange4(range4, data);
      }

      // Range 258-260 (3 registers)
      final range5 = await _modbusConnection.readRegisters(258, 3, 71);
      if (range5 != null) {
        _parseMainDataRange5(range5, data);
      }

      // Range 266-270 (5 registers)
      final range6 = await _modbusConnection.readRegisters(266, 5, 71);
      if (range6 != null) {
        _parseMainDataRange6(range6, data);
      }

      // Range 276-280 (5 registers)
      final range7 = await _modbusConnection.readRegisters(276, 5, 71);
      if (range7 != null) {
        _parseMainDataRange7(range7, data);
      }

      // Range 286 (2 registers)
      final range8 = await _modbusConnection.readRegisters(286, 2, 71);
      if (range8 != null) {
        _parseMainDataRange8(range8, data);
      }

      // Range 320-326 (7 registers)
      final range9 = await _modbusConnection.readRegisters(320, 7, 71);
      if (range9 != null) {
        _parseMainDataRange9(range9, data);
      }

      // Batch 3: Battery details (registers 512-588)
      final batteryRegs = await _modbusConnection.readRegisters(512, 77, 71);
      if (batteryRegs != null) {
        _parseBatteryData(batteryRegs, data);
      }

      debugPrint(data.toString());

      return data.isNotEmpty ? data : null;
    } catch (e) {
      debugPrint('[KostalModbus] Error fetching data: $e');
      return null;
    }
  }

  /// Parse device info registers (6-46)
  void _parseDeviceInfo(List<int> registers, Map<String, dynamic> data) {
    // Register 6: Article number (8 registers = indices 0-7)
    data['article_number'] = KostalModbusConnection.parseString8(registers, 0);

    // Register 46: Software version (8 registers = indices 40-47, but we only have 41 regs)
    // Note: We actually have indices 0-40 (41 registers), so register 46 is at index 40
    // But we need 8 consecutive registers, so let's read it separately or adjust
    // For now, skip if not enough data
    if (registers.length >= 41) {
      // Register 46 would be at absolute position, but we start at 6
      // So register 46 = index (46-6) = 40
      // But we need 8 registers from there, which would be indices 40-47
      // We only have 41 registers (0-40), so we can't parse software version from this batch
      // Let's fetch it in a separate call in fetchData if needed
    }
  }

  /// Parse main data range 1: registers 100-124
  void _parseMainDataRange1(List<int> registers, Map<String, dynamic> data) {
    double? regFloat(int address) {
      final index = address - 100;
      if (index + 1 < registers.length) {
        return KostalModbusConnection.parseFloat(registers, index);
      }
      return null;
    }

    data['dc_power_total'] = regFloat(100);
    data['energy_manager_state'] = regFloat(104);
    data['consumption_battery'] = regFloat(106);
    data['consumption_grid'] = regFloat(108);
    data['consumption_pv_total'] = regFloat(110);
    data['consumption_grid_total'] = regFloat(112);
    data['consumption_battery_total'] = regFloat(114);
    data['consumption_pv'] = regFloat(116);
    data['consumption_total'] = regFloat(118);
    data['isolation_resistance'] = regFloat(120);
    data['power_limit_evu'] = regFloat(122);
    data['consumption_rate'] = regFloat(124);
  }

  /// Parse main data range 2: registers 144-178
  void _parseMainDataRange2(List<int> registers, Map<String, dynamic> data) {
    double? regFloat(int address) {
      final index = address - 144;
      if (index + 1 < registers.length) {
        return KostalModbusConnection.parseFloat(registers, index);
      }
      return null;
    }

    data['work_time'] = regFloat(144);
    data['cos_phi_actual'] = regFloat(150);
    data['grid_frequency'] = regFloat(152);

    // AC Phase 1
    data['ac_phase1_current'] = regFloat(154);
    data['ac_phase1_power'] = regFloat(156);
    data['ac_phase1_voltage'] = regFloat(158);

    // AC Phase 2
    data['ac_phase2_current'] = regFloat(160);
    data['ac_phase2_power'] = regFloat(162);
    data['ac_phase2_voltage'] = regFloat(164);

    // AC Phase 3
    data['ac_phase3_current'] = regFloat(166);
    data['ac_phase3_power'] = regFloat(168);
    data['ac_phase3_voltage'] = regFloat(170);

    // AC Totals
    data['ac_power_total'] = regFloat(172);
    data['ac_reactive_power_total'] = regFloat(174);
    data['ac_apparent_power_total'] = regFloat(178);
  }

  /// Parse main data range 3: registers 190-216
  void _parseMainDataRange3(List<int> registers, Map<String, dynamic> data) {
    double? regFloat(int address) {
      final index = address - 190;
      if (index + 1 < registers.length) {
        return KostalModbusConnection.parseFloat(registers, index);
      }
      return null;
    }

    data['battery_charge_current'] = regFloat(190);
    data['battery_cycles'] = regFloat(194);
    data['battery_current'] = regFloat(200);
    data['pssb_fuse_state'] = regFloat(202);
    data['battery_ready_flag'] = regFloat(208);
    data['battery_soc'] = regFloat(210);
    data['battery_state'] = regFloat(212);
    data['battery_temperature'] = regFloat(214);
    data['battery_voltage'] = regFloat(216);
  }

  /// Parse main data range 4: registers 218-256
  void _parseMainDataRange4(List<int> registers, Map<String, dynamic> data) {
    double? regFloat(int address) {
      final index = address - 218;
      if (index + 1 < registers.length) {
        return KostalModbusConnection.parseFloat(registers, index);
      }
      return null;
    }

    // Powermeter totals
    data['powermeter_cos_phi'] = regFloat(218);
    data['powermeter_frequency'] = regFloat(220);

    // Powermeter Phase 1
    data['powermeter_phase1_current'] = regFloat(222);
    data['powermeter_phase1_active_power'] = regFloat(224);
    data['powermeter_phase1_reactive_power'] = regFloat(226);
    data['powermeter_phase1_apparent_power'] = regFloat(228);
    data['powermeter_phase1_voltage'] = regFloat(230);

    // Powermeter Phase 2
    data['powermeter_phase2_current'] = regFloat(232);
    data['powermeter_phase2_active_power'] = regFloat(234);
    data['powermeter_phase2_reactive_power'] = regFloat(236);
    data['powermeter_phase2_apparent_power'] = regFloat(238);
    data['powermeter_phase2_voltage'] = regFloat(240);

    // Powermeter Phase 3
    data['powermeter_phase3_current'] = regFloat(242);
    data['powermeter_phase3_active_power'] = regFloat(244);
    data['powermeter_phase3_reactive_power'] = regFloat(246);
    data['powermeter_phase3_apparent_power'] = regFloat(248);
    data['powermeter_phase3_voltage'] = regFloat(250);

    // Powermeter Totals
    data['powermeter_active_power_total'] = regFloat(252);
    data['powermeter_reactive_power_total'] = regFloat(254);
    data['powermeter_apparent_power_total'] = regFloat(256);
  }

  /// Parse main data range 5: registers 258-260
  void _parseMainDataRange5(List<int> registers, Map<String, dynamic> data) {
    double? regFloat(int address) {
      final index = address - 258;
      if (index + 1 < registers.length) {
        return KostalModbusConnection.parseFloat(registers, index);
      }
      return null;
    }

    data['dc1_current'] = regFloat(258);
    data['dc1_power'] = regFloat(260);
  }

  /// Parse main data range 6: registers 266-270
  void _parseMainDataRange6(List<int> registers, Map<String, dynamic> data) {
    double? regFloat(int address) {
      final index = address - 266;
      if (index + 1 < registers.length) {
        return KostalModbusConnection.parseFloat(registers, index);
      }
      return null;
    }

    data['dc1_voltage'] = regFloat(266);
    data['dc2_current'] = regFloat(268);
    data['dc2_power'] = regFloat(270);
  }

  /// Parse main data range 7: registers 276-280
  void _parseMainDataRange7(List<int> registers, Map<String, dynamic> data) {
    double? regFloat(int address) {
      final index = address - 276;
      if (index + 1 < registers.length) {
        return KostalModbusConnection.parseFloat(registers, index);
      }
      return null;
    }

    data['dc2_voltage'] = regFloat(276);
    data['dc3_current'] = regFloat(278);
    data['dc3_power'] = regFloat(280);
  }

  /// Parse main data range 8: register 286
  void _parseMainDataRange8(List<int> registers, Map<String, dynamic> data) {
    if (registers.length >= 2) {
      data['dc3_voltage'] = KostalModbusConnection.parseFloat(registers, 0);
    }
  }

  /// Parse main data range 9: registers 320-326
  void _parseMainDataRange9(List<int> registers, Map<String, dynamic> data) {
    double? regFloat(int address) {
      final index = address - 320;
      if (index + 1 < registers.length) {
        return KostalModbusConnection.parseFloat(registers, index);
      }
      return null;
    }

    data['yield_total'] = regFloat(320);
    data['yield_daily'] = regFloat(322);
    data['yield_yearly'] = regFloat(324);
    data['yield_monthly'] = regFloat(326);
  }

  /// Parse battery data registers (512-588)
  void _parseBatteryData(List<int> registers, Map<String, dynamic> data) {
    // Helper functions for different types
    int? regU16(int address) {
      final index = address - 512;
      if (index >= 0 && index < registers.length) {
        return KostalModbusConnection.parseUint16(registers, index);
      }
      return null;
    }

    int? regU32(int address) {
      final index = address - 512;
      if (index + 1 < registers.length) {
        return KostalModbusConnection.parseUint32(registers, index);
      }
      return null;
    }

    int? regS16(int address) {
      final index = address - 512;
      if (index >= 0 && index < registers.length) {
        return KostalModbusConnection.parseInt16(registers, index);
      }
      return null;
    }

    double? regFloat(int address) {
      final index = address - 512;
      if (index + 1 < registers.length) {
        return KostalModbusConnection.parseFloat(registers, index);
      }
      return null;
    }

    String? regStr8(int address) {
      final index = address - 512;
      if (index + 7 < registers.length) {
        return KostalModbusConnection.parseString8(registers, index);
      }
      return null;
    }

    // Register 512: Battery Gross Capacity (U32)
    data['battery_capacity_gross'] = regU32(512);

    // Register 514: Battery actual SOC (U16)
    data['battery_soc_actual'] = regU16(514);

    // Register 515: Firmware Maincontroller (U32)
    data['firmware_maincontroller'] = regU32(515);

    // Register 517: Battery Manufacturer (Strg8)
    data['battery_manufacturer'] = regStr8(517);

    // Register 525: Battery Model ID (U32)
    data['battery_model_id'] = regU32(525);

    // Register 527: Battery Serial Number (U32)
    data['battery_serial_number'] = regU32(527);

    // Register 529: Battery Operation mode (U32)
    data['battery_operation_mode'] = regU32(529);

    // Register 531: Inverter Max Power (Float - but actually U16 according to Python)
    data['inverter_max_power'] = regU16(531);

    // Register 575: Inverter Generation Power (actual) (S16)
    data['inverter_generation_power'] = regS16(575);

    // Register 577: Generation Energy (U32)
    data['generation_energy'] = regU32(577);

    // Register 578: Total energy (U32) - Python has issues with this one
    // data['total_energy'] = regU32(578);

    // Register 580: Battery Net Capacity (U32)
    data['battery_capacity_net'] = regU32(580);

    // Register 582: Actual battery charge-discharge power (S16)
    data['battery_charge_discharge_power'] = regS16(582);

    // Register 586: Battery Firmware (U32)
    data['battery_firmware'] = regU32(586);

    // Register 588: Battery Type (U16)
    data['battery_type'] = regU16(588);
  }

  @override
  bool isConnected() {
    return (DateTime.now().millisecondsSinceEpoch - lastSeen) < CONNECTION_TIMEOUT_MS;
  }


  @override
  Future<bool> internalInitializeDevice() async {
    await internalFetchData();
    if(device.data["modbus"] != null){
      throw new Exception("failed read init data from Kostal device");
    }
    return false;//no reset needet init data is alreacy fetch
  }
}
