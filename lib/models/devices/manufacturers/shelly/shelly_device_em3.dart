import '../../capabilities/device_role_config.dart';
import '../../capabilities/smart_meter_capability.dart';
import 'shelly_bluetooth_device.dart';
import 'implementations/shelly_device_em3_implementation.dart';
import 'shelly_wifi_device.dart';
import 'package:the_solar_app/utils/map_utils.dart';

/// Shelly EM3 WiFi device (3-phase energy meter)
///
/// Fixed role: Smart Meter
/// This device always acts as a smart meter for grid power measurement.
class ShellyDeviceEm3Wifi extends ShellyWifiDeviceTemplate
    with SmartMeterCapability, DeviceRoleConfig {
  ShellyDeviceEm3Wifi({
    required super.id,
    required super.name,
    required super.lastSeen,
    required super.deviceSn,
    super.deviceModel,
    super.ipAddress,
    super.port,
    super.hostname,
  }):
  super(deviceImpl: ShellyDeviceEm3Implementation());

  /// Factory constructor from JSON
  factory ShellyDeviceEm3Wifi.fromJson(Map<String, dynamic> json) {
    final device = ShellyDeviceEm3Wifi(
        id: json['id'] as String,
        name: json['name'] as String,
        lastSeen: DateTime.parse(json['lastSeen'] as String),
        deviceSn: json['deviceSn'] as String,
        deviceModel: json['deviceModel'] as String?
    );
    device.wifiFromJson(json);
    device.authFromJson(json);
    device.roleConfigFromJson(json);
    return device;
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      ...roleConfigToJson(),
    };
  }

  // ===== DeviceRoleConfig implementation =====

  @override
  List<DeviceRole> getFixedRoles() => [DeviceRole.smartMeter];

  // ===== SmartMeterCapability implementation =====

  @override
  double? getGridPower(Map<String, dynamic> data) {
    final value = MapUtils.OM(data, ['data', 'total_act_power']);
    if (value == null) return null;
    return (value as num).toDouble();
  }
}

/// Shelly EM3 Bluetooth device (3-phase energy meter)
///
/// Fixed role: Smart Meter
/// This device always acts as a smart meter for grid power measurement.
class ShellyDeviceEm3Bluetooth extends ShellyBluetoothDeviceTemplate
    with SmartMeterCapability, DeviceRoleConfig {
  ShellyDeviceEm3Bluetooth({
    required super.id,
    required super.name,
    required super.lastSeen,
    required super.deviceSn,
    super.deviceModel,
  }):
  super(deviceImpl: ShellyDeviceEm3Implementation());

  /// Factory constructor from JSON
  factory ShellyDeviceEm3Bluetooth.fromJson(Map<String, dynamic> json) {
    final device = ShellyDeviceEm3Bluetooth(
        id: json['id'] as String,
        name: json['name'] as String,
        lastSeen: DateTime.parse(json['lastSeen'] as String),
        deviceSn: json['deviceSn'] as String,
        deviceModel: json['deviceModel'] as String?
    );
    device.authFromJson(json);
    device.roleConfigFromJson(json);
    return device;
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      ...roleConfigToJson(),
    };
  }

  // ===== DeviceRoleConfig implementation =====

  @override
  List<DeviceRole> getFixedRoles() => [DeviceRole.smartMeter];

  // ===== SmartMeterCapability implementation =====

  @override
  double? getGridPower(Map<String, dynamic> data) {
    final value = MapUtils.OM(data, ['data', 'total_act_power']);
    if (value == null) return null;
    return (value as num).toDouble();
  }
}
