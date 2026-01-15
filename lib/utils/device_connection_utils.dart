import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../models/device.dart';
import './message_utils.dart';

/// Utility class for device connection operations
///
/// Provides centralized logic for connecting and disconnecting devices
/// across all screens (device_list, device_detail, system_view, etc.)
class DeviceConnectionUtils {
  /// Connect to a device (handles both WiFi and Bluetooth)
  ///
  /// Returns true if connection was successful, false otherwise
  static Future<bool> connectDevice(
    BuildContext context,
    Device device, {
    bool showMessages = true,
  }) async {
    try {
      // Check if device is already connected - if so, skip reconnection
      final service = device.getServiceConnection();
      if (service != null && service.isConnected()) {
        // Device is already connected, no need to reconnect
        return true;
      }

      if (device.connectionType == ConnectionType.bluetooth) {
        return await _connectBluetoothDevice(
          context,
          device,
          fullConnection: true,
          timeout: const Duration(seconds: 5),
          showMessages: showMessages,
        );
      } else {
        return await _connectWiFiDevice(
          context,
          device,
          fullConnection: true,
          showMessages: showMessages,
        );
      }
    } catch (e) {
      if (showMessages && context.mounted) {
        MessageUtils.showError(context, 'Verbindungsfehler: $e');
      }
      return false;
    }
  }

  /// Connect to WiFi device
  static Future<bool> _connectWiFiDevice(
    BuildContext? context,
    Device device, {
    required bool fullConnection,
    required bool showMessages,
  }) async {
    try {
      await device.setUpServiceConnection(null);

      if (fullConnection) {
        await device.getServiceConnection()?.connect();
      }

      return true;
    } catch (e) {
      device.emitErrorWithFlag('WiFi-Verbindungsfehler: $e',true);
      return false;
    }
  }

  /// Connect to Bluetooth device (scans for device first)
  static Future<bool> _connectBluetoothDevice(
    BuildContext? context,
    Device device, {
    required bool fullConnection,
    required Duration timeout,
    required bool showMessages,
  }) async {
    try {
      if (showMessages && context != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Suche ${device.name}...'),
            duration: Duration(seconds: timeout.inSeconds),
          ),
        );
      }

      device.emitStatus("Suche nach Gerät...");

      final foundDevices = await _scanForBluetoothDevices([device.deviceSn], timeout: timeout);
      final bluetoothDevice = foundDevices[device.deviceSn];

      if (bluetoothDevice != null) {
        final success = await _setupBluetoothDevice(device, bluetoothDevice, fullConnection: fullConnection);

        if (success) {
          _showMessage(context, '${device.name} verbunden', showMessages: showMessages);
        }
        return success;
      } else {
        _showMessage(context, 'Gerät nicht gefunden', isError: true, showMessages: showMessages);
        device.emitStatus("Nicht Verbunden");
        return false;
      }
    } catch (e) {
      _showMessage(context, 'BLE-Verbindungsfehler: $e', isError: true, showMessages: showMessages);
      return false;
    }
  }

  /// Disconnect from a device
  ///
  /// Returns true if disconnection was successful, false otherwise
  static Future<bool> disconnectDevice(
    BuildContext context,
    Device device, {
    bool showMessages = true,
  }) async {
    try {
      device.getServiceConnection()?.disconnect();
      if (showMessages && context.mounted) {
        MessageUtils.showSuccess(context, '${device.name} getrennt');
      }
      return true;
    } catch (e) {
      if (showMessages && context.mounted) {
        MessageUtils.showError(context, 'Fehler beim Trennen: $e');
      }
      return false;
    }
  }

  /// Connect multiple devices efficiently (batch BLE scan + parallel WiFi)
  ///
  /// Handles both WiFi and Bluetooth devices in a single call:
  /// - WiFi devices connect in parallel
  /// - BLE devices use single efficient batch scan
  ///
  /// Returns map of device IDs to connection success status
  static Future<Map<String, bool>> connectMultipleDevices(
    List<Device> devices, {
    bool fullConnection = true,
    Duration timeout = const Duration(seconds: 5),
    BuildContext? context,
    bool showMessages = false,
  }) async {
    if (devices.isEmpty) return {};

    final results = <String, bool>{};

    // Separate by connection type
    final wifiDevices = devices.where((d) => d.connectionType == ConnectionType.wifi).toList();
    final bleDevices = devices.where((d) => d.connectionType == ConnectionType.bluetooth).toList();

    // Connect WiFi devices in parallel
    await Future.wait(wifiDevices.map((device) async {
      results[device.id] = await _connectWiFiDevice(
        context,
        device,
        fullConnection: fullConnection,
        showMessages: showMessages,
      );
    }));

    // Batch scan for BLE devices (efficient single scan)
    if (bleDevices.isNotEmpty) {
      final disconnected = bleDevices.where((d) {
        final service = d.getServiceConnection();
        return service == null || !service.isConnected();
      }).toList();

      if (disconnected.isNotEmpty) {

        for (final device in disconnected) {
          device.emitStatus("Suche nach Gerät...");
        }

        final serialNumbers = disconnected.map((d) => d.deviceSn).toList();
        final foundDevices = await _scanForBluetoothDevices(serialNumbers, timeout: timeout);

        for (final device in disconnected) {
          final bleDevice = foundDevices[device.deviceSn];
          if (bleDevice != null) {
            results[device.id] = await _setupBluetoothDevice(
              device,
              bleDevice,
              fullConnection: fullConnection,
            );
          } else {
            results[device.id] = false;
            device.emitStatus("Nicht Verbunden");
          }
        }
      }

      // Mark already connected devices as successful
      for (final device in bleDevices) {
        if (!results.containsKey(device.id)) {
          results[device.id] = true;
        }
      }
    }

    return results;
  }

  /// Core BLE scanning logic - shared by all Bluetooth methods
  static Future<Map<String, BluetoothDevice>> _scanForBluetoothDevices(
    List<String> deviceSerialNumbers, {
    required Duration timeout,
  }) async {
    if (deviceSerialNumbers.isEmpty) return {};

    final snSet = deviceSerialNumbers.toSet();
    final foundDevices = <String, BluetoothDevice>{};

    try {
      await FlutterBluePlus.startScan(timeout: timeout);

      final subscription = FlutterBluePlus.scanResults.listen((results) {
        for (var result in results) {
          final sn = result.device.remoteId.toString();
          if (snSet.contains(sn) && !foundDevices.containsKey(sn)) {
            foundDevices[sn] = result.device;

            // Early exit if all devices found
            if (foundDevices.length == snSet.length) {
              FlutterBluePlus.stopScan();
              break;
            }
          }
        }
      });

      await Future.delayed(timeout);
      await subscription.cancel();
      await FlutterBluePlus.stopScan();
    } catch (e) {
      debugPrint('BLE scan error: $e');
    }

    return foundDevices;
  }

  /// Setup BLE device after scan
  static Future<bool> _setupBluetoothDevice(
    Device device,
    BluetoothDevice bluetoothDevice, {
    required bool fullConnection,
  }) async {
    try {
      await device.setUpServiceConnection(bluetoothDevice);

      if (fullConnection) {
        await device.getServiceConnection()?.connect();
      }

      return true;
    } catch (e) {
      debugPrint('BLE setup error for ${device.name}: $e');
      return false;
    }
  }

  /// Show UI message helper
  static void _showMessage(
    BuildContext? context,
    String message, {
    bool isError = false,
    required bool showMessages,
  }) {
    if (!showMessages || context == null || !context.mounted) return;

    if (isError) {
      MessageUtils.showError(context, message);
    } else {
      MessageUtils.showSuccess(context, message);
    }
  }
}
