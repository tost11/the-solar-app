import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:the_solar_app/models/devices/device_base.dart';

/// Utility class for Bluetooth device connection logic
///
/// Provides reusable methods for scanning and connecting to Bluetooth devices.
/// Used by DeviceDetailScreen and SystemDetailScreen.
class BluetoothConnectionUtils {
  /// Scans for a Bluetooth device by serial number and connects it
  ///
  /// [device] - The device to connect
  /// [timeout] - Scan timeout (default: 5 seconds)
  ///
  /// Returns true if device was found and connected, false otherwise
  static Future<bool> scanAndConnect(
    DeviceBase device, {
    Duration timeout = const Duration(seconds: 5),
  }) async {
    try {
      // Start Bluetooth scan
      await FlutterBluePlus.startScan(timeout: timeout);

      BluetoothDevice? foundDevice;

      // Listen to scan results
      final subscription = FlutterBluePlus.scanResults.listen((results) {
        for (var result in results) {
          if (result.device.remoteId.toString() == device.deviceSn) {
            foundDevice = result.device;
            break;
          }
        }
      });

      // Wait for scan to complete
      await Future.delayed(timeout);
      await subscription.cancel();
      await FlutterBluePlus.stopScan();

      // Connect if device was found
      if (foundDevice != null) {
        device.setUpServiceConnection(foundDevice);
        return true;
      }

      return false;
    } catch (e) {
      debugPrint('Error scanning/connecting to Bluetooth device ${device.name}: $e');
      return false;
    }
  }

  /// Scans for multiple Bluetooth devices in parallel
  ///
  /// [devices] - List of devices to find
  /// [timeout] - Scan timeout (default: 5 seconds)
  ///
  /// Connects all found devices during a single scan
  static Future<void> scanAndConnectMultiple(
    List<DeviceBase> devices, {
    Duration timeout = const Duration(seconds: 5),
  }) async {
    if (devices.isEmpty) return;

    try {
      // Create map of deviceSn -> device for quick lookup
      final deviceMap = {for (var d in devices) d.deviceSn: d};
      final foundDevices = <String, BluetoothDevice>{};

      // Start scan
      await FlutterBluePlus.startScan(timeout: timeout);

      // Listen to scan results
      final subscription = FlutterBluePlus.scanResults.listen((results) {
        for (var result in results) {
          final sn = result.device.remoteId.toString();
          if (deviceMap.containsKey(sn) && !foundDevices.containsKey(sn)) {
            foundDevices[sn] = result.device;
          }
        }
      });

      // Wait for scan to complete
      await Future.delayed(timeout);
      await subscription.cancel();
      await FlutterBluePlus.stopScan();

      // Connect all found devices
      for (var entry in foundDevices.entries) {
        final device = deviceMap[entry.key]!;
        final bluetoothDevice = entry.value;
        try {
          device.setUpServiceConnection(bluetoothDevice);
        } catch (e) {
          debugPrint('Error connecting device ${device.name}: $e');
        }
      }
    } catch (e) {
      debugPrint('Error during batch Bluetooth scan: $e');
    }
  }
}
