import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:the_solar_app/models/device.dart';

import 'base_device_service.dart';

/// Abstract base class for Bluetooth device services
///
/// Provides common functionality for BLE device communication including:
/// - Connection management
/// - Characteristic discovery based on UUIDs
/// - Stream-based state management
/// - Error handling and status updates
abstract class BluetoothDeviceService extends BaseDeviceService {
  // Bluetooth connection
  BluetoothDevice bluetoothDevice;

  // Characteristics - to be found based on UUIDs provided in constructor
  BluetoothCharacteristic? _notifyCharacteristic;
  BluetoothCharacteristic? _writeCharacteristic;
  BluetoothCharacteristic? _rwCharacteristic;
  BluetoothCharacteristic? _readNotifyCharacteristic;

  // Configuration - UUIDs for service and characteristics
  final String serviceUuid;
  final String? serviceUuidShort;
  final String? notifyCharacteristicUuid;
  final String? notifyCharacteristicUuidShort;
  final String? writeCharacteristicUuid;
  final String? writeCharacteristicUuidShort;
  final String? rwCharacteristicUuid;
  final String? rwCharacteristicUuidShort;
  final String? readNotifyCharacteristicUuid;
  final String? readNotifyCharacteristicUuidShort;

  @override
  bool isConnected(){
    return bluetoothDevice.isConnected;
  }

  BluetoothDevice? get connectedDevice => bluetoothDevice;
  //String? get deviceId => _deviceId;

  // Protected getters for subclasses
  BluetoothCharacteristic? get notifyCharacteristic => _notifyCharacteristic;
  BluetoothCharacteristic? get writeCharacteristic => _writeCharacteristic;
  BluetoothCharacteristic? get rwCharacteristic => _rwCharacteristic;
  BluetoothCharacteristic? get readNotifyCharacteristic => _readNotifyCharacteristic;

  // Protected setters for subclasses
  //set deviceId(String? id) => _deviceId = id;

  /// Constructor with characteristic UUIDs configuration
  BluetoothDeviceService({
    Duration ? updateTime,
    required this.bluetoothDevice,
    required DeviceBase baseDevice,
    required this.serviceUuid,
    this.serviceUuidShort,
    this.notifyCharacteristicUuid,
    this.notifyCharacteristicUuidShort,
    this.writeCharacteristicUuid,
    this.writeCharacteristicUuidShort,
    this.rwCharacteristicUuid,
    this.rwCharacteristicUuidShort,
    this.readNotifyCharacteristicUuid,
    this.readNotifyCharacteristicUuidShort,
  }):super(updateTime,baseDevice);

  /// Connect to a Bluetooth device - device-specific connection logic
  @override
  Future<bool> internalConnect() async {
    debugPrint('\n═══════════════════════════════════════════════════════════════');
    debugPrint('CONNECTING TO DEVICE');
    debugPrint('═══════════════════════════════════════════════════════════════');
    debugPrint('Device: ${bluetoothDevice.platformName}');
    debugPrint('ID: ${bluetoothDevice.remoteId}');

    // Connect to device
    await bluetoothDevice.connect(timeout: const Duration(seconds: 15));
    debugPrint('Connected successfully!');

    device.emitStatus('Verbunden');

    // Allow device-specific optimizations (e.g., MTU negotiation, GATT cache clear)
    await onDeviceConnected();

    // Discover services
    debugPrint('\nDiscovering services...');
    List<BluetoothService> services = await bluetoothDevice.discoverServices();
    debugPrint('Found ${services.length} services');

    // Find the device-specific service
    BluetoothService? deviceService = _findService(services);
    if (deviceService == null) {
      await bluetoothDevice.disconnect();
      throw Exception('Device service not found');
    }

    // Find characteristics based on provided UUIDs
    _findCharacteristics(services);

    // Validate that required characteristics were found
    if (!validateCharacteristics()) {
      await bluetoothDevice.disconnect();
      throw Exception('Required characteristics not found');
    }

    debugPrint('All required characteristics found');

    // Allow subclasses to setup characteristics (e.g., enable notifications)
    await setupCharacteristics();

    debugPrint('Device ready!');
    debugPrint('═══════════════════════════════════════════════════════════════\n');

    return true;
  }

  /// Device-specific Bluetooth disconnection logic
  @override
  Future<void> internalDisconnect() async {
    // Disconnect Bluetooth device
    await bluetoothDevice.disconnect();

    // Clear characteristic references
    _notifyCharacteristic = null;
    _writeCharacteristic = null;
    _rwCharacteristic = null;
    _readNotifyCharacteristic = null;
  }

  /// Find the device-specific service from discovered services
  BluetoothService? _findService(List<BluetoothService> services) {
    for (var service in services) {
      String serviceUuidStr = service.uuid.toString().toLowerCase();
      debugPrint('Service: $serviceUuidStr');

      if (serviceUuidStr == serviceUuid.toLowerCase() ||
          (serviceUuidShort != null && serviceUuidStr == serviceUuidShort!.toLowerCase())) {
        debugPrint('Found device service!');
        return service;
      }
    }
    return null;
  }

  /// Find and store characteristics based on UUIDs provided in constructor
  void _findCharacteristics(List<BluetoothService> services) {
    for (var service in services) {
      for (var char in service.characteristics) {
        String charUuid = char.uuid.toString().toLowerCase();
        debugPrint('Characteristic: $charUuid');

        // Check notify characteristic
        if (notifyCharacteristicUuid != null &&
            (charUuid == notifyCharacteristicUuid!.toLowerCase() ||
             (notifyCharacteristicUuidShort != null && charUuid == notifyCharacteristicUuidShort!.toLowerCase()))) {
          _notifyCharacteristic = char;
          debugPrint('Found notify characteristic!');
        }

        // Check write characteristic
        if (writeCharacteristicUuid != null &&
            (charUuid == writeCharacteristicUuid!.toLowerCase() ||
             (writeCharacteristicUuidShort != null && charUuid == writeCharacteristicUuidShort!.toLowerCase()))) {
          _writeCharacteristic = char;
          debugPrint('Found write characteristic!');
        }

        // Check RW characteristic (used by Shelly)
        if (rwCharacteristicUuid != null &&
            (charUuid == rwCharacteristicUuid!.toLowerCase() ||
             (rwCharacteristicUuidShort != null && charUuid == rwCharacteristicUuidShort!.toLowerCase()))) {
          _rwCharacteristic = char;
          debugPrint('Found RW characteristic!');
        }

        // Check read/notify characteristic (used by Shelly)
        if (readNotifyCharacteristicUuid != null &&
            (charUuid == readNotifyCharacteristicUuid!.toLowerCase() ||
             (readNotifyCharacteristicUuidShort != null && charUuid == readNotifyCharacteristicUuidShort!.toLowerCase()))) {
          _readNotifyCharacteristic = char;
          debugPrint('Found read/notify characteristic!');
        }
      }
    }
  }

  /// Clean up resources
  @override
  void dispose() {
    super.dispose();
  }

  // Hook methods for subclass customization

  /// Override to perform device-specific optimizations after connection
  /// but before service discovery.
  ///
  /// Examples:
  /// - Clear GATT cache (Shelly)
  /// - Negotiate MTU size
  /// - Set connection priority
  ///
  /// Default implementation does nothing.
  Future<void> onDeviceConnected() async {
    // Default: no optimization needed
  }

  // Abstract methods to be implemented by subclasses

  /// Validate that all required characteristics were found
  /// Override this to specify which characteristics are required for your device
  bool validateCharacteristics();

  /// Setup characteristics after discovery (e.g., enable notifications)
  Future<void> setupCharacteristics();
}
