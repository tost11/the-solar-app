import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:the_solar_app/constants/bluetooth_constants.dart';
import 'devices/device_base.dart';
import 'devices/manufacturers/shelly/shelly_bluetooth_device.dart';
import 'devices/manufacturers/shelly/shelly_wifi_device.dart';
import 'devices/manufacturers/zendure/bluetooth_zendure_device.dart';
import 'devices/manufacturers/zendure/wifi_zendure_device.dart';
import 'devices/manufacturers/deyesun/wifi_deyesun_device.dart';
import 'devices/manufacturers/opendtu/wifi_opendtu_device.dart';
import 'devices/manufacturers/hoymiles/hoymiles_device.dart';
import 'devices/manufacturers/hoymiles/hoymiles_inverter_device.dart';
import 'devices/manufacturers/hoymiles/hoymiles_dtu_device.dart';
import 'devices/manufacturers/kostal/wifi_kostal_device.dart';

/// Factory class for creating device instances
class DeviceFactory {
  /// Create a device from JSON storage data
  static DeviceBase ? fromJson(Map<String, dynamic> json) {
    final connectionType = json['connectionType'] != null
        ? ConnectionType.fromJson(json['connectionType'] as String)
        : ConnectionType.bluetooth;

    // Check device type (for multi-brand support)
    final deviceType = json['deviceType'] as String?;

    switch (connectionType) {
      case ConnectionType.bluetooth:
         if(deviceType == DEVICE_MANUFACTURER_ZENDURE) {
          return BluetoothZendureDevice.fromJson(json);
        } else if(deviceType == DEVICE_MANUFACTURER_SHELLY) {
          // All Shelly devices use the generic implementation with dynamic module detection
          return ShellyBluetoothDevice.fromJson(json);
        }else{
          return null;
        }

      case ConnectionType.wifi:
        // Determine WiFi device type
        if (deviceType == DEVICE_MANUFACTURER_DEYE_SUN) {
          return WiFiDeyeSunDevice.fromJson(json);
        }else if(deviceType == DEVICE_MANUFACTURER_ZENDURE){
          // Default to Zendure for backward compatibility
          return WiFiZendureDevice.fromJson(json);
        } else if(deviceType == DEVICE_MANUFACTURER_SHELLY) {
          // All Shelly devices use the generic implementation with dynamic module detection
          return ShellyWifiDevice.fromJson(json);
        } else if(deviceType == DEVICE_MANUFACTURER_OPENDTU){
          return WiFiOpenDTUDevice.fromJson(json);
        } else if(deviceType == DEVICE_MANUFACTURER_HOYMILES){
          return HoymilesDevice.fromJson(json);
        } else if(deviceType == DEVICE_MANUFACTURER_KOSTAL){
          return WiFiKostalDevice.fromJson(json);
        }else{
          return null;
        }
    }
  }

  /// Create a Bluetooth device from discovered BluetoothDevice
  static DeviceBase createBluetoothDevice({
    required BluetoothDevice bluetoothDevice,
    required String id,
    required String name,
    required String deviceSn,
    required String manufacturer,
    required String ? deviceModel,
  }) {
    final deviceType = manufacturer.toLowerCase();

    if(deviceType == DEVICE_MANUFACTURER_ZENDURE){
      return BluetoothZendureDevice(
          id: id,
          name: name,
          lastSeen: DateTime.now(),
          deviceSn: deviceSn,
          deviceModel: deviceModel
      );
    }else if(deviceType == DEVICE_MANUFACTURER_SHELLY){
      // All Shelly devices use the generic implementation with dynamic module detection
      return ShellyBluetoothDevice(
        id: id,
        name: name,
        lastSeen: DateTime.now(),
        deviceSn: deviceSn,
        deviceModel: deviceModel
      );
    }
    throw Exception("could not create bluetooth device $deviceType doese not exist");
  }

  /// Create a Hoymiles device (WiFi only)
  ///
  /// Automatically detects device type (DTU vs HMS inverter) based on model.
  static HoymilesDevice createHoymilesDevice({
    required String id,
    required String name,
    required String deviceSn,
    required String deviceModel,
    String? ipAddress,
    String? hostname,
    int? port,
  }) {
    // Determine device type from model string
    final modelLower = deviceModel.toLowerCase();

    // DTU devices (manage multiple inverters)
    if (modelLower.contains('dtu-wlite') ||
        modelLower.contains('dtu-pro') ||
        modelLower.contains('dtu-lite') ||
        modelLower == 'dtu') {
      return HoymilesDTUDevice(
        id: id,
        name: name,
        lastSeen: DateTime.now(),
        deviceSn: deviceSn,
        deviceModel: deviceModel,
        ipAddress: ipAddress,
        hostname: hostname,
        port: port,
      );
    }

    // HMS standalone inverters (built-in WiFi)
    return HoymilesInverterDevice(
      id: id,
      name: name,
      lastSeen: DateTime.now(),
      deviceSn: deviceSn,
      deviceModel: deviceModel,
      ipAddress: ipAddress,
      hostname: hostname,
      port: port,
    );
  }

  /// Create a WiFi device from discovered network device
  static DeviceBase createWiFiDevice({
    required String id,
    required String deviceSn,
    String? ipAddress,
    String? hostname,
    required String name,
    required String manufacturer,
    String? deviceModel,
    int? port,
  }) {
    // Determine device type based on manufacturer
    final deviceType = manufacturer.toLowerCase();

    if (deviceType == DEVICE_MANUFACTURER_DEYE_SUN) {
      return WiFiDeyeSunDevice(
        id: id,
        name: name,
        lastSeen: DateTime.now(),
        deviceSn: deviceSn,
        ipAddress: ipAddress,
        hostname: hostname,
        port: port,
        deviceModel: deviceModel
      );
    } else if (deviceType == DEVICE_MANUFACTURER_SHELLY) {
      // All Shelly devices use the generic implementation with dynamic module detection
      return ShellyWifiDevice(
        id: id,
        name: name,
        lastSeen: DateTime.now(),
        deviceSn: deviceSn,
        deviceModel: deviceModel,
        ipAddress: ipAddress,
        hostname: hostname,
        port: port,
      );
    } else if (deviceType == DEVICE_MANUFACTURER_ZENDURE) {
      return WiFiZendureDevice(
        id: id,
        name: name,
        lastSeen: DateTime.now(),
        deviceSn: deviceSn,
        deviceModel: deviceModel,
        ipAddress: ipAddress,
        hostname: hostname,
        port: port,
      );
    } else if (deviceType == DEVICE_MANUFACTURER_OPENDTU) {
      return WiFiOpenDTUDevice(
        id: id,
        name: name,
        lastSeen: DateTime.now(),
        deviceSn: deviceSn,
        deviceModel: deviceModel,
        ipAddress: ipAddress,
        hostname: hostname,
        port: port,
      );
    } else if (deviceType == DEVICE_MANUFACTURER_HOYMILES) {
      return createHoymilesDevice(
        id: id,
        name: name,
        deviceSn: deviceSn,
        deviceModel: deviceModel ?? "Unknown",
        ipAddress: ipAddress,
        hostname: hostname,
        port: port,
      );
    }else if (deviceType == DEVICE_MANUFACTURER_KOSTAL) {
      return WiFiKostalDevice(
        id: id,
        name: name,
        deviceSn: deviceSn,
        deviceModel: deviceModel ?? "Unknown",
        ipAddress: ipAddress,
        hostname: hostname,
        port: port,
        lastSeen: DateTime.now(),
      );
    }
    throw Exception("could not create netowrk device $deviceType doese not exist");
  }
}
