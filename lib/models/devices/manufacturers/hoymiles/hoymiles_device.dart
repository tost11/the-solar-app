import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:the_solar_app/constants/bluetooth_constants.dart';
import 'package:the_solar_app/models/devices/manufacturers/hoymiles/hoymiles_dtu_device.dart';
import 'package:the_solar_app/models/devices/manufacturers/hoymiles/hoymiles_inverter_device.dart';
import 'package:the_solar_app/services/devices/hoymiles/hoymiles_protocol.dart';
import '../../device_base.dart';
import '../../mixins/device_wifi_mixin.dart';
import '../../mixins/fetch_data_timeout_mixin.dart';
import '../../../../services/devices/hoymiles/hoymiles_wifi_service.dart';

/// Abstract base class for all Hoymiles devices
///
/// Follows the Shelly device pattern with WiFi mixin support
abstract class HoymilesDevice extends DeviceBase<HoymilesWifiService> with DeviceWifiMixin, FetchDataTimeoutMixin  {

  static const Duration DEFAULT_FETCH_INTERVAL = Duration(seconds: 31);
  HoymilesDevice({
    required super.id,
    required super.name,
    required super.lastSeen,
    required super.deviceSn,
    required super.connectionType,
    required super.dataFields,
    required super.menuItems,
    super.customSections = const [],
    super.categoryConfigs = const [],
    super.deviceModel,
    String? ipAddress,
    String? hostname,
    int? port = 10081,
  }) : super() {
    netIpAddress = ipAddress;
    netHostname = hostname;
    netPort = port ?? HoymilesProtocol.DTU_PORT;
    fetchDataInterval = DEFAULT_FETCH_INTERVAL;
  }

  // Common sendCommand implementation - uses generic commands:
  // - COMMAND_FETCH_DATA → getRealDataNew()
  // - COMMAND_FETCH_SYS_CONFIG → getConfig()
  // - COMMAND_FETCH_WIFI_CONFIG → getNetworkInfo()
  @override
  Future<Map<String, dynamic>?> sendCommand(
    String command,
    Map<String, dynamic> params,
  );

  // Factory from JSON - determines device type from model
  static HoymilesDevice fromJson(Map<String, dynamic> json) {
    final String? deviceModel = json['deviceModel'] as String?;
    final modelLower = deviceModel?.toLowerCase() ?? '';

    // Import device types dynamically to avoid circular dependencies
    // This will be implemented in concrete classes

    // DTU devices (manage multiple inverters)
    HoymilesDevice hoymilesDevice;

    if (modelLower.contains('dtu-wlite') ||
        modelLower.contains('dtu-pro') ||
        modelLower.contains('dtu-lite') ||
        modelLower == 'dtu') {
      // Will be implemented in hoymiles_dtu_device.dart
      hoymilesDevice = HoymilesDTUDevice(
          id: json['id'] as String,
          name: json['name'] as String,
          lastSeen: DateTime.parse(json['lastSeen'] as String),
          deviceSn: json['deviceSn'] as String,
          deviceModel: json['deviceModel'] as String?
      );
    } else {
      hoymilesDevice = HoymilesInverterDevice(
          id: json['id'] as String,
          name: json['name'] as String,
          lastSeen: DateTime.parse(json['lastSeen'] as String),
          deviceSn: json['deviceSn'] as String,
          deviceModel: json['deviceModel'] as String?
      );
    }

    hoymilesDevice.wifiFromJson(json);
    hoymilesDevice.fetchDataIntervalFromJson(json, DEFAULT_FETCH_INTERVAL);
    return hoymilesDevice;
  }

  @override
  IconData get deviceIcon => Icons.solar_power;

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json['deviceType'] = DEVICE_MANUFACTURER_HOYMILES;
    json.addAll(wifiToJson());
    json.addAll(fetchDataIntervalToJson());
    return json;
  }

  @override
  void setUpServiceConnection(BluetoothDevice? device) {
    removeServiceConnection();
    connectionService = HoymilesWifiService(this);
  }
}
