import 'shelly_bluetooth_device.dart';
import 'shelly_wifi_device.dart';

import 'implementations/shelly_device_plug_implementation.dart';

class ShellyDevicePlugWifi extends ShellyWifiDeviceTemplate{
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
    return device;
  }
}

class ShellyDevicePlugBluetooth extends ShellyBluetoothDeviceTemplate{
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
    return device;
  }
}
