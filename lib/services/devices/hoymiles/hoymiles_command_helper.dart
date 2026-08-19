import 'package:fixnum/fixnum.dart';

import 'package:the_solar_app/models/devices/manufacturers/hoymiles/protobuf/AppGetHistED.pb.dart';
import 'package:the_solar_app/models/devices/manufacturers/hoymiles/protobuf/AppGetHistPower.pb.dart';
import 'package:the_solar_app/models/devices/manufacturers/hoymiles/protobuf/CommandPB.pb.dart';
import 'package:the_solar_app/models/devices/manufacturers/hoymiles/protobuf/GetConfig.pb.dart';
import 'package:the_solar_app/models/devices/manufacturers/hoymiles/protobuf/NetworkInfo.pb.dart';
import 'package:the_solar_app/models/devices/manufacturers/hoymiles/protobuf/RealDataNew.pb.dart';
import 'package:the_solar_app/models/devices/manufacturers/hoymiles/protobuf/SetConfig.pb.dart';
import 'package:the_solar_app/services/devices/hoymiles/hoymiles_wifi_service.dart';
import 'package:the_solar_app/utils/debug_log.dart';

import 'hoymiles_protocol.dart';

/// Shared command helper for Hoymiles devices.
///
/// Contains protobuf request building, response parsing, and data formatting
/// logic used by both [HoymilesWifiService] and [HoymilesBluetoothService].
///
/// This is a pure utility class — transport (TCP vs BLE+encryption) is handled
/// by the calling service.
class HoymilesCommandHelper {
  // ============================================================
  // Request builders (create protobuf messages)
  // ============================================================

  /// Build a RealDataNew request protobuf.
  /// [offset] defaults to WiFi protocol offset (28800), pass local timezone
  /// offset for BLE usage.
  static RealDataNewResDTO buildRealDataNewRequest({int cp = 0, int? offset}) {
    return RealDataNewResDTO()
      ..timeYmdHms = DateTime.now()
          .toIso8601String()
          .replaceAll('T', ' ')
          .substring(0, 19)
          .codeUnits
      ..offset = offset ?? HoymilesProtocol.OFFSET
      ..time = (DateTime.now().millisecondsSinceEpoch / 1000).floor()
      ..cp = cp;
  }

  /// Build a GetConfig request protobuf.
  /// [offset] defaults to WiFi protocol offset (28800), pass local timezone
  /// offset for BLE usage.
  static GetConfigResDTO buildGetConfigRequest({int? offset}) {
    return GetConfigResDTO()
      ..offset = offset ?? HoymilesProtocol.OFFSET
      ..time = (DateTime.now().millisecondsSinceEpoch / 1000).floor() - 60;
  }

  /// Build a NetworkInfo request protobuf.
  /// [offset] defaults to WiFi protocol offset (28800), pass local timezone
  /// offset for BLE usage.
  static NetworkInfoResDTO buildNetworkInfoRequest({int? offset}) {
    return NetworkInfoResDTO()
      ..offset = offset ?? HoymilesProtocol.OFFSET
      ..time = (DateTime.now().millisecondsSinceEpoch / 1000).floor();
  }

  // ============================================================
  // Historical data builders / parsers
  // ============================================================

  /// Build a historical power-curve request for the given page [cp].
  /// [offset] defaults to WiFi protocol offset (28800), pass local timezone
  /// offset for BLE usage.
  static AppGetHistPowerResDTO buildGetHistPowerRequest({int cp = 0, int? offset}) {
    return AppGetHistPowerResDTO()
      ..cp = cp
      ..offset = offset ?? HoymilesProtocol.OFFSET
      ..requestedTime = (DateTime.now().millisecondsSinceEpoch / 1000).floor()
      ..requestedDay = 0;
  }

  /// Build a historical daily-energy request.
  /// [offset] defaults to WiFi protocol offset (28800), pass local timezone
  /// offset for BLE usage.
  static AppGetHistEDResDTO buildGetHistEDRequest({int? offset}) {
    return AppGetHistEDResDTO()
      ..cp = 0
      ..oft = offset ?? HoymilesProtocol.OFFSET
      ..time = (DateTime.now().millisecondsSinceEpoch / 1000).floor();
  }

  /// Parse a single historical-power page into a [AppGetHistPowerReqDTO].
  static AppGetHistPowerReqDTO parseHistPowerProto(List<int> responseBytes) {
    return AppGetHistPowerReqDTO.fromBuffer(responseBytes);
  }

  /// Convert one or more historical-power pages into a normalized map.
  ///
  /// Returns:
  /// ```
  /// {
  ///   'serial_number': String,
  ///   'start_time': int (epoch seconds of first sample),
  ///   'step_time': int (seconds between samples),
  ///   'daily_energy': double (kWh),
  ///   'total_energy': double (kWh),
  ///   'points': [ {'time': epochSeconds, 'power': int (W)}, ... ],
  /// }
  /// ```
  static Map<String, dynamic> buildHistPowerResult(AppGetHistPowerReqDTO response) {
    final startTime = response.startTime;
    final stepTime = response.stepTime > 0 ? response.stepTime : 900;

    final points = <Map<String, dynamic>>[];
    for (var i = 0; i < response.powerArray.length; i++) {
      points.add({
        'time': startTime + i * stepTime,
        'power': response.powerArray[i] / 10.0,
      });
    }

    return {
      'serial_number': response.serialNumber.toRadixString(16),
      'start_time': startTime,
      'step_time': stepTime,
      'daily_energy': response.dailyEnergy / 1000.0,
      'total_energy': response.totalEnergy / 1000.0,
      'points': points,
    };
  }

  /// Parse a historical daily-energy response into a normalized map.
  ///
  /// Returns:
  /// ```
  /// {
  ///   'serial_number': String,
  ///   'days': [ {'time': epochSeconds, 'energy': double (kWh)}, ... ],
  /// }
  /// ```
  static Map<String, dynamic> parseHistEDResponse(List<int> responseBytes) {
    final response = AppGetHistEDReqDTO.fromBuffer(responseBytes);

    final days = <Map<String, dynamic>>[];
    for (final e in response.energ) {
      days.add({
        'time': e.rTime,
        'energy': e.ed / 1000.0,
      });
    }

    return {
      'serial_number': response.sn.toRadixString(16),
      'days': days,
    };
  }

  /// Build a SetPowerLimit command protobuf.
  ///
  /// [limitPercent] must be 0-100.
  static CommandResDTO buildSetPowerLimitRequest(int limitPercent) {
    if (limitPercent < 0 || limitPercent > 100) {
      throw Exception('Invalid limit: $limitPercent% (must be 0-100)');
    }
    final limitLevel = limitPercent * 10;
    final timestamp = (DateTime.now().millisecondsSinceEpoch / 1000).floor();

    return CommandResDTO()
      ..time = timestamp
      ..action = 8 // CMD_ACTION_LIMIT_POWER
      ..packageNub = 1
      ..packageNow = 0
      ..tid = Int64(timestamp)
      ..data = 'A:$limitLevel,B:0,C:0\r';
  }

  // ============================================================
  // Control command builders (restart / power on / off)
  // ============================================================

  /// CMD_ACTION_DTU_REBOOT
  static const int _actionDtuReboot = 1;
  /// CMD_ACTION_MI_REBOOT
  static const int _actionMiReboot = 3;
  /// CMD_ACTION_MI_START
  static const int _actionMiStart = 6;
  /// CMD_ACTION_MI_SHUTDOWN
  static const int _actionMiShutdown = 7;

  /// Base CommandResDTO with common fields set.
  static CommandResDTO _buildCommandBase(int action) {
    final timestamp = (DateTime.now().millisecondsSinceEpoch / 1000).floor();
    return CommandResDTO()
      ..time = timestamp
      ..action = action
      ..packageNub = 1
      ..packageNow = 0
      ..tid = Int64(timestamp);
  }

  /// Parse a hex-string inverter serial into an Int64 for the `mi_to_sn` field.
  static Int64 _parseInverterSerial(String inverterSerial) {
    final cleaned = inverterSerial.trim();
    // Serials from the device are hex strings (e.g. from pv_data.serial_number).
    return Int64.parseHex(cleaned);
  }

  /// Build a request to reboot the DTU (action 1). BLE link drops during reboot.
  static CommandResDTO buildRestartDtuRequest() {
    return _buildCommandBase(_actionDtuReboot);
  }

  /// Build a request to reboot a specific inverter (action 3).
  static CommandResDTO buildRebootInverterRequest(String inverterSerial) {
    return _buildCommandBase(_actionMiReboot)
      ..miToSn.add(_parseInverterSerial(inverterSerial));
  }

  /// Build a request to turn on (re-enable output of) a specific inverter (action 6).
  static CommandResDTO buildTurnOnInverterRequest(String inverterSerial) {
    return _buildCommandBase(_actionMiStart)
      ..miToSn.add(_parseInverterSerial(inverterSerial));
  }

  /// Build a request to turn off (shut down output of) a specific inverter (action 7).
  static CommandResDTO buildTurnOffInverterRequest(String inverterSerial) {
    return _buildCommandBase(_actionMiShutdown)
      ..miToSn.add(_parseInverterSerial(inverterSerial));
  }

  /// Build a SetConfig request with WiFi credentials updated.
  ///
  /// Copies ALL fields from the current config (read-modify-write pattern),
  /// then sets the new SSID and password.
  static SetConfigResDTO buildSetWifiConfigRequest(
    GetConfigReqDTO currentConfig,
    String ssid,
    String password,
  ) {
    return _buildSetConfigFromCurrent(currentConfig)
      ..netmodeSelect = 1 // Force WiFi mode
      ..wifiSsid = ssid
      ..wifiPassword = password;
  }

  /// Build a SetConfig request with AP WiFi credentials updated.
  static SetConfigResDTO buildSetApWifiConfigRequest(
    GetConfigReqDTO currentConfig,
    String ssid,
    String password,
  ) {
    return _buildSetConfigFromCurrent(currentConfig)
      ..dtuApSsid = ssid
      ..dtuApPass = password;
  }

  /// Copy all fields from GetConfigReqDTO to SetConfigResDTO.
  static SetConfigResDTO _buildSetConfigFromCurrent(GetConfigReqDTO config) {
    return SetConfigResDTO()
      ..offset = HoymilesProtocol.OFFSET
      ..time = (DateTime.now().millisecondsSinceEpoch / 1000).floor()
      ..appPage = 1
      ..netmodeSelect = config.netmodeSelect
      ..lockPassword = config.lockPassword
      ..lockTime = config.lockTime
      ..limitPowerMypower = config.limitPowerMypower
      ..zeroExport433Addr = config.zeroExport433Addr
      ..zeroExportEnable = config.zeroExportEnable
      ..channelSelect = config.channelSelect
      ..serverSendTime = config.serverSendTime
      ..serverport = config.serverport
      ..apnSet = config.apnSet
      ..meterKind = config.meterKind
      ..meterInterface = config.meterInterface
      ..wifiSsid = config.wifiSsid
      ..wifiPassword = config.wifiPassword
      ..serverDomainName = config.serverDomainName
      ..invType = config.invType
      ..dtuSn = config.dtuSn
      ..accessModel = config.accessModel
      ..mac0 = config.mac0
      ..mac1 = config.mac1
      ..mac2 = config.mac2
      ..mac3 = config.mac3
      ..dhcpSwitch = config.dhcpSwitch
      ..ipAddr0 = config.ipAddr0
      ..ipAddr1 = config.ipAddr1
      ..ipAddr2 = config.ipAddr2
      ..ipAddr3 = config.ipAddr3
      ..subnetMask0 = config.subnetMask0
      ..subnetMask1 = config.subnetMask1
      ..subnetMask2 = config.subnetMask2
      ..subnetMask3 = config.subnetMask3
      ..defaultGateway0 = config.defaultGateway0
      ..defaultGateway1 = config.defaultGateway1
      ..defaultGateway2 = config.defaultGateway2
      ..defaultGateway3 = config.defaultGateway3
      ..apnName = config.apnName
      ..apnPassword = config.apnPassword
      ..sub1gSweepSwitch = config.sub1gSweepSwitch
      ..sub1gWorkChannel = config.sub1gWorkChannel
      ..cableDns0 = config.cableDns0
      ..cableDns1 = config.cableDns1
      ..cableDns2 = config.cableDns2
      ..cableDns3 = config.cableDns3
      ..mac4 = config.mac4
      ..mac5 = config.mac5
      ..dtuApSsid = config.dtuApSsid
      ..dtuApPass = config.dtuApPass;
  }

  // ============================================================
  // Response parsers
  // ============================================================

  /// Parse RealDataNew response protobuf into a normalized map.
  ///
  /// Returns the same map structure used by the UI (inverters, sgs, pv, etc.)
  static Map<String, dynamic>? parseRealDataNewResponse(List<int> responseBytes) {
    try {
      final response = RealDataNewReqDTO.fromBuffer(responseBytes);

      final result = <String, dynamic>{
        'device_serial_number': response.deviceSerialNumber,
        'timestamp': response.timestamp,
        'dtu_power': response.dtuPower.toInt(),
        'dtu_daily_energy': response.dtuDailyEnergy.toInt() / 1000.0,
        'firmware_version': response.firmwareVersion,
      };

      var inverters = <String, dynamic>{};

      for (var sgs in response.sgsData) {
        String sn = sgs.serialNumber.toRadixString(16);
        var powerRating = HoymilesWifiService.getPowerRatingForModel(
          HoymilesWifiService.getModelFromSerial(sn),
        );

        if (!inverters.containsKey(sn)) {
          inverters[sn] = <String, dynamic>{};
        }

        var powerLimit = sgs.powerLimit / 10;
        if (powerLimit <= 0 || powerLimit > 100) {
          powerLimit = 100;
        }

        inverters[sn]["sgs"] = {
          'firmware_version': sgs.firmwareVersion,
          'voltage': sgs.voltage / 10.0,
          'frequency': sgs.frequency / 100.0,
          'active_power': sgs.activePower / 10,
          'reactive_power': sgs.reactivePower,
          'current': sgs.current,
          'power_factor': sgs.powerFactor,
          'temperature': sgs.temperature / 10.0,
          'warning_number': sgs.warningNumber,
          'link_status': sgs.linkStatus,
          'power_limit': powerLimit,
          'power_rating': powerRating,
        };
      }

      for (var tgs in response.tgsData) {
        String sn = tgs.serialNumber.toRadixString(16);
        if (!inverters.containsKey(sn)) {
          inverters[sn] = <String, dynamic>{};
        }
        inverters[sn]["tgs"] = {
          'firmware_version': tgs.firmwareVersion,
          'voltage_phase_a': tgs.voltagePhaseA,
          'voltage_phase_b': tgs.voltagePhaseB,
          'voltage_phase_c': tgs.voltagePhaseC,
          'frequency': tgs.frequency,
          'active_power': tgs.activePower / 10,
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
        String sn = pv.serialNumber.toRadixString(16);
        if (!inverters.containsKey(sn)) {
          inverters[sn] = <String, dynamic>{};
        }
        var inv = inverters[sn];
        if (!inv.containsKey("pv")) {
          inv["pv"] = <String, dynamic>{};
          inv["pv"]["power"] = 0.0;
        }
        var pvRes = inv["pv"] as Map<String, dynamic>;
        String portNumber = pv.portNumber.toString();
        pvRes[portNumber] = {
          'voltage': pv.voltage / 10.0,
          'current': pv.current / 100.0,
          'power': pv.power / 10.0,
          'energy_total': pv.energyTotal / 1000.0,
          'energy_daily': pv.energyDaily / 1000.0,
          'error_code': pv.errorCode,
        };
        inv["pv"]["power"] += pvRes[portNumber]["power"];
      }

      result["inverters"] = inverters;

      if (inverters.length == 1) {
        result["inverter"] = inverters.entries.first.value;
      }

      // Determine device model
      final dtuType = HoymilesWifiService.getDtuType(response.deviceSerialNumber);
      if (dtuType != null) {
        if (dtuType == "DTUBI" && inverters.isNotEmpty) {
          final inverterSerial = inverters.keys.first;
          HoymilesWifiService.getModelFromSerial(inverterSerial);
        }
        result['dtu_type'] = dtuType;
      }

      return result;
    } catch (e) {
      DebugLog.device('[HoymilesCommandHelper] Error parsing RealDataNew: $e', level: LogLevel.error);
      return null;
    }
  }

  /// Parse GetConfig response and extract power limit percentage.
  static Map<String, dynamic> parseGetConfigResponse(List<int> responseBytes) {
    final response = GetConfigReqDTO.fromBuffer(responseBytes);

    final limitPowerMypower = response.limitPowerMypower;
    final powerLimitPercent = limitPowerMypower != 0
        ? (limitPowerMypower / 10).round()
        : null;

    final configMap = response.toProto3Json() as Map<String, dynamic>;
    configMap['power_limit_percent'] = powerLimitPercent;
    return configMap;
  }

  /// Parse SetPowerLimit response — throws on error.
  static void validateCommandResponse(List<int> responseBytes) {
    final response = CommandReqDTO.fromBuffer(responseBytes);
    if (response.errCode != 0) {
      throw Exception('Fehler bei verarbeiten des Befehls, fehlercode: ${response.errCode}');
    }
  }

  /// Parse SetConfig response — throws on error.
  static void validateSetConfigResponse(List<int> responseBytes) {
    final response = SetConfigReqDTO.fromBuffer(responseBytes);
    if (response.errorCode != 0) {
      throw Exception('Fehler bei verarbeiten des Befehls, fehlercode: ${response.errorCode}');
    }
  }

  /// Parse NetworkInfo response into a map.
  static Map<String, dynamic> parseNetworkInfoResponse(List<int> responseBytes) {
    final response = NetworkInfoReqDTO.fromBuffer(responseBytes);
    return response.toProto3Json() as Map<String, dynamic>;
  }

  /// Parse GetConfig response into GetConfigReqDTO (for read-modify-write).
  static GetConfigReqDTO parseGetConfigProto(List<int> responseBytes) {
    return GetConfigReqDTO.fromBuffer(responseBytes);
  }

  // ============================================================
  // Device information formatting
  // ============================================================

  /// Format raw config data into organized sections for the device info screen.
  ///
  /// Takes the flat map from [parseGetConfigResponse] or [getDeviceInformation]
  /// and organizes it into sections (Netzwerk, WiFi, Gerät, Server, etc.)
  static Map<String, dynamic> organizeDeviceInfo(Map<String, dynamic> data) {
    final result = <String, dynamic>{};

    // Netzwerk section
    final network = <String, dynamic>{};
    if (data['ip_address'] != null) network['IP-Adresse'] = data['ip_address'];
    if (data['mac_address'] != null) network['MAC-Adresse'] = data['mac_address'];
    if (data['gateway'] != null) network['Standard-Gateway'] = data['gateway'];
    if (data['subnet_mask'] != null) network['Subnetzmaske'] = data['subnet_mask'];
    if (data['dns_server'] != null && data['dns_server'] != '0.0.0.0') {
      network['DNS-Server'] = data['dns_server'];
    }
    if (data['dhcp_enabled'] != null) network['DHCP'] = data['dhcp_enabled'] ? 'Ja' : 'Nein';
    if (network.isNotEmpty) result['Netzwerk'] = network;

    // WiFi section
    final wifi = <String, dynamic>{};
    if (data['wifi_ssid'] != null && data['wifi_ssid'].toString().isNotEmpty) {
      wifi['SSID'] = data['wifi_ssid'];
    }
    if (data['network_mode'] != null) wifi['Netzwerkmodus'] = data['network_mode'];
    if (data['ap_ssid'] != null && data['ap_ssid'].toString().isNotEmpty) {
      wifi['AP SSID'] = data['ap_ssid'];
    }
    if (data['ap_password'] != null && data['ap_password'].toString().isNotEmpty) {
      wifi['AP Passwort'] = data['ap_password'];
    }
    if (wifi.isNotEmpty) result['WiFi'] = wifi;

    // Gerät section
    final device = <String, dynamic>{};
    if (data['dtu_serial'] != null && data['dtu_serial'].toString().isNotEmpty) {
      device['DTU Seriennummer'] = data['dtu_serial'];
    }
    if (data['access_model'] != null) device['Zugriffsmodus'] = data['access_model'].toString();
    if (data['inverter_type'] != null) device['Inverter Typ'] = data['inverter_type'].toString();
    if (device.isNotEmpty) result['Gerät'] = device;

    // Server section
    final server = <String, dynamic>{};
    if (data['server_domain'] != null && data['server_domain'].toString().isNotEmpty) {
      server['Server Domain'] = data['server_domain'];
    }
    if (data['server_port'] != null) server['Server Port'] = data['server_port'].toString();
    if (data['send_interval'] != null) server['Sendeintervall'] = '${data['send_interval']} s';
    if (server.isNotEmpty) result['Server'] = server;

    // Einstellungen section
    final settings = <String, dynamic>{};
    if (data['power_limit_percent'] != null) {
      settings['Leistungslimit'] = '${data['power_limit_percent']} %';
    }
    if (data['lock_password_set'] != null) {
      settings['Sperrpasswort gesetzt'] = data['lock_password_set'] ? 'Ja' : 'Nein';
    }
    if (data['lock_time_minutes'] != null && data['lock_time_minutes'] != 0) {
      settings['Sperrzeit'] = '${data['lock_time_minutes']} min';
    }
    if (data['zero_export_enabled'] != null) {
      settings['Nulleinspeisung'] = data['zero_export_enabled'] ? 'Ja' : 'Nein';
    }
    if (data['zero_export_address'] != null && data['zero_export_address'] != 0) {
      settings['Nulleinspeisung Adresse'] = data['zero_export_address'].toString();
    }
    if (data['channel'] != null) settings['Kanal'] = data['channel'].toString();
    if (data['meter_kind'] != null && data['meter_kind'].toString().isNotEmpty) {
      settings['Zählerart'] = data['meter_kind'];
    }
    if (data['meter_interface'] != null && data['meter_interface'].toString().isNotEmpty) {
      settings['Zähler Schnittstelle'] = data['meter_interface'];
    }
    if (settings.isNotEmpty) result['Einstellungen'] = settings;

    // APN section
    final apn = <String, dynamic>{};
    if (data['apn_set'] != null && data['apn_set'].toString().isNotEmpty) {
      apn['APN Set'] = data['apn_set'];
    }
    if (data['apn_name'] != null && data['apn_name'].toString().isNotEmpty) {
      apn['APN Name'] = data['apn_name'];
    }
    if (data['apn_password'] != null && data['apn_password'].toString().isNotEmpty) {
      apn['APN Passwort'] = data['apn_password'];
    }
    if (apn.isNotEmpty) result['APN'] = apn;

    // Sub1G section
    final sub1g = <String, dynamic>{};
    if (data['sub1g_sweep_switch'] != null) {
      sub1g['Sweep Switch'] = data['sub1g_sweep_switch'] ? 'Ja' : 'Nein';
    }
    if (data['sub1g_work_channel'] != null) {
      sub1g['Arbeitskanal'] = data['sub1g_work_channel'].toString();
    }
    if (sub1g.isNotEmpty) result['Sub1G'] = sub1g;

    return result;
  }

  /// Extract flat device information fields from config response.
  ///
  /// Formats IP addresses, MAC addresses, and other fields from the raw
  /// GetConfig protobuf response into human-readable strings.
  static Map<String, dynamic> extractDeviceInformation(Map<String, dynamic> config) {
    final result = <String, dynamic>{};

    // Network fields
    if (config.containsKey('ipAddr0') && config.containsKey('ipAddr1') &&
        config.containsKey('ipAddr2') && config.containsKey('ipAddr3')) {
      result['ip_address'] = _formatIpAddress(
        config['ipAddr0'] as int, config['ipAddr1'] as int,
        config['ipAddr2'] as int, config['ipAddr3'] as int,
      );
    }
    if (config.containsKey('mac0') && config.containsKey('mac1') &&
        config.containsKey('mac2') && config.containsKey('mac3') &&
        config.containsKey('mac4') && config.containsKey('mac5')) {
      result['mac_address'] = _formatMacAddress(
        config['mac0'] as int, config['mac1'] as int,
        config['mac2'] as int, config['mac3'] as int,
        config['mac4'] as int, config['mac5'] as int,
      );
    }
    if (config.containsKey('defaultGateway0') && config.containsKey('defaultGateway1') &&
        config.containsKey('defaultGateway2') && config.containsKey('defaultGateway3')) {
      result['gateway'] = _formatIpAddress(
        config['defaultGateway0'] as int, config['defaultGateway1'] as int,
        config['defaultGateway2'] as int, config['defaultGateway3'] as int,
      );
    }
    if (config.containsKey('subnetMask0') && config.containsKey('subnetMask1') &&
        config.containsKey('subnetMask2') && config.containsKey('subnetMask3')) {
      result['subnet_mask'] = _formatIpAddress(
        config['subnetMask0'] as int, config['subnetMask1'] as int,
        config['subnetMask2'] as int, config['subnetMask3'] as int,
      );
    }
    if (config.containsKey('cableDns0') && config.containsKey('cableDns1') &&
        config.containsKey('cableDns2') && config.containsKey('cableDns3')) {
      result['dns_server'] = _formatIpAddress(
        config['cableDns0'] as int, config['cableDns1'] as int,
        config['cableDns2'] as int, config['cableDns3'] as int,
      );
    }
    if (config.containsKey('dhcpSwitch')) {
      result['dhcp_enabled'] = (config['dhcpSwitch'] as int) != 0;
    }

    // WiFi fields
    if (config.containsKey('wifiSsid')) result['wifi_ssid'] = config['wifiSsid'];
    if (config.containsKey('netmodeSelect')) {
      result['network_mode'] = _formatNetmodeSelect(config['netmodeSelect'] as int);
    }
    if (config.containsKey('dtuApSsid')) result['ap_ssid'] = config['dtuApSsid'];
    if (config.containsKey('dtuApPass')) result['ap_password'] = config['dtuApPass'] as String;

    // Device fields
    if (config.containsKey('dtuSn')) result['dtu_serial'] = config['dtuSn'];
    if (config.containsKey('accessModel')) result['access_model'] = config['accessModel'];
    if (config.containsKey('invType')) result['inverter_type'] = config['invType'];

    // Server fields
    if (config.containsKey('serverDomainName')) result['server_domain'] = config['serverDomainName'];
    if (config.containsKey('serverport')) result['server_port'] = config['serverport'];
    if (config.containsKey('serverSendTime')) result['send_interval'] = config['serverSendTime'];

    // Settings fields
    if (config.containsKey('power_limit_percent')) result['power_limit_percent'] = config['power_limit_percent'];
    if (config.containsKey('lockPassword')) result['lock_password_set'] = (config['lockPassword'] as int) != 0;
    if (config.containsKey('lockTime')) result['lock_time_minutes'] = config['lockTime'];
    if (config.containsKey('zeroExportEnable')) result['zero_export_enabled'] = (config['zeroExportEnable'] as int) != 0;
    if (config.containsKey('zeroExport433Addr')) result['zero_export_address'] = config['zeroExport433Addr'];
    if (config.containsKey('channelSelect')) result['channel'] = config['channelSelect'];
    if (config.containsKey('meterKind')) result['meter_kind'] = config['meterKind'];
    if (config.containsKey('meterInterface')) result['meter_interface'] = config['meterInterface'];

    // APN fields
    if (config.containsKey('apnSet')) result['apn_set'] = config['apnSet'];
    if (config.containsKey('apnName')) result['apn_name'] = config['apnName'];
    if (config.containsKey('apnPassword')) result['apn_password'] = config['apnPassword'] as String;

    // Sub1G fields
    if (config.containsKey('sub1gSweepSwitch')) result['sub1g_sweep_switch'] = (config['sub1gSweepSwitch'] as int) != 0;
    if (config.containsKey('sub1gWorkChannel')) result['sub1g_work_channel'] = config['sub1gWorkChannel'];

    return result;
  }

  // ============================================================
  // Private formatting helpers
  // ============================================================

  static String _formatIpAddress(int a, int b, int c, int d) => '$a.$b.$c.$d';

  static String _formatMacAddress(int m0, int m1, int m2, int m3, int m4, int m5) {
    return '${m0.toRadixString(16).padLeft(2, '0').toUpperCase()}:'
        '${m1.toRadixString(16).padLeft(2, '0').toUpperCase()}:'
        '${m2.toRadixString(16).padLeft(2, '0').toUpperCase()}:'
        '${m3.toRadixString(16).padLeft(2, '0').toUpperCase()}:'
        '${m4.toRadixString(16).padLeft(2, '0').toUpperCase()}:'
        '${m5.toRadixString(16).padLeft(2, '0').toUpperCase()}';
  }

  static String _formatNetmodeSelect(int mode) {
    switch (mode) {
      case 1: return 'WiFi';
      case 2: return 'SIM';
      case 3: return 'LAN';
      default: return 'Unbekannt ($mode)';
    }
  }
}
