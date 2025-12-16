import 'package:the_solar_app/models/devices/capabilities/inverter_capability.dart';

import '../../capabilities/device_role_config.dart';
import '../../capabilities/load_capability.dart';
import '../../capabilities/smart_meter_capability.dart';
import 'shelly_bluetooth_device.dart';
import 'shelly_wifi_device.dart';

import 'implementations/shelly_device_plug_implementation.dart';
import 'package:the_solar_app/utils/map_utils.dart';

/// Shelly Plug WiFi device with configurable role
///
/// Configurable roles: Smart Meter OR Load
/// The user chooses which role this plug serves in the system.
class ShellyDevicePlugWifi extends ShellyWifiDeviceTemplate
    with SmartMeterCapability, LoadCapability, DeviceRoleConfig, InverterCapability {
  ShellyDevicePlugWifi({
    required super.id,
    required super.name,
    required super.lastSeen,
    required super.deviceSn,
    super.deviceModel,
    super.ipAddress,
    super.port,
    super.hostname,
  }):
  super(deviceImpl: ShellyDevicePlugImplementation());

  /// Factory constructor from JSON
  factory ShellyDevicePlugWifi.fromJson(Map<String, dynamic> json) {
    final device = ShellyDevicePlugWifi(
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
  List<DeviceRole> getConfigurableRoles() => [
        DeviceRole.smartMeter,
        DeviceRole.inverter,
        DeviceRole.load,
      ];

  // ===== SmartMeterCapability implementation =====

  @override
  double? getGridPower(Map<String, dynamic> data) {
    final value = MapUtils.OM(data, ['data', 'apower']);
    if (value == null) return null;
    return (value as num).toDouble();
  }

  // ===== LoadCapability implementation =====

  @override
  double? getLoadPower(Map<String, dynamic> data) {
    final value = MapUtils.OM(data, ['data', 'apower']);
    if (value == null) return null;
    return (value as num).toDouble();
  }


  @override
  double? getSolarPVPower(Map<String, dynamic> data) {
    var p = getSolarGridPower(data);
    if(p == null){
      return null;
    }
    return p * 0.95;//use fixte value
  }

  @override
  double? getSolarGridPower(Map<String, dynamic> data) {
    final value = MapUtils.OM(data, ['data', 'apower']);
    if (value == null) return null;
    return (value as num).toDouble();
  }
}

/// Shelly Plug Bluetooth device with configurable role
///
/// Configurable roles: Smart Meter OR Load
/// The user chooses which role this plug serves in the system.
class ShellyDevicePlugBluetooth extends ShellyBluetoothDeviceTemplate
    with SmartMeterCapability, LoadCapability, DeviceRoleConfig, InverterCapability {
  ShellyDevicePlugBluetooth({
    required super.id,
    required super.name,
    required super.lastSeen,
    required super.deviceSn,
    super.deviceModel,
  }):
  super(deviceImpl: ShellyDevicePlugImplementation());

  /// Factory constructor from JSON
  factory ShellyDevicePlugBluetooth.fromJson(Map<String, dynamic> json) {
    final device = ShellyDevicePlugBluetooth(
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
  List<DeviceRole> getConfigurableRoles() => [
        DeviceRole.smartMeter,
        DeviceRole.load,
      ];

  // ===== SmartMeterCapability implementation =====

  @override
  double? getGridPower(Map<String, dynamic> data) {
    final value = MapUtils.OM(data, ['data', 'apower']);
    if (value == null) return null;
    return (value as num).toDouble();
  }

  @override
  double? getSolarPVPower(Map<String, dynamic> data) {
    var p = getSolarGridPower(data);
    if(p == null){
      return null;
    }
    return p * 0.95;//use fixte value
  }

  @override
  double? getSolarGridPower(Map<String, dynamic> data) {
    final value = MapUtils.OM(data, ['data', 'apower']);
    if (value == null) return null;
    return (value as num).toDouble();
  }

  // ===== LoadCapability implementation =====

  @override
  double? getLoadPower(Map<String, dynamic> data) {
    final value = MapUtils.OM(data, ['data', 'apower']);
    if (value == null) return null;
    return (value as num).toDouble();
  }
}
