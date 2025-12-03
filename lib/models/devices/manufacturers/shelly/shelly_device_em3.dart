import 'shelly_bluetooth_device.dart';
import 'implementations/shelly_device_em3_implementation.dart';
import 'shelly_wifi_device.dart';

class ShellyDeviceEm3Wifi extends ShellyWifiDeviceTemplate{
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
    return device;
  }
}

class ShellyDeviceEm3Bluetooth extends ShellyBluetoothDeviceTemplate{
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
    return device;
  }
}
