import 'dart:async';
import '../../utils/debug_log.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart' hide LogLevel;
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
    DebugLog.bluetooth('═══════════════════════════════════════════════════════════════', level: LogLevel.debug);
    DebugLog.bluetooth('CONNECTING TO DEVICE', level: LogLevel.debug);
    DebugLog.bluetooth('═══════════════════════════════════════════════════════════════', level: LogLevel.debug);
    DebugLog.bluetooth('Device: ${bluetoothDevice.platformName}', level: LogLevel.debug);
    DebugLog.bluetooth('ID: ${bluetoothDevice.remoteId}', level: LogLevel.debug);

    // Connect to device
    // On Linux/Windows, the device must be in the BLE adapter's device list
    // (via a real scan) before connect() works. If "No element" occurs, we
    // trigger a quick scan to rediscover the device, then retry once.
    try {
      await bluetoothDevice.connect(license: License.nonprofit, timeout: const Duration(seconds: 15));
    } catch (e) {
      if (e.toString().contains('No element')) {
        DebugLog.bluetooth('Device not in adapter list, scanning to rediscover...', level: LogLevel.info);
        try {
          await FlutterBluePlus.startScan(timeout: const Duration(seconds: 5));
          await Future.delayed(const Duration(seconds: 5));
          await FlutterBluePlus.stopScan();
        } catch (scanError) {
          DebugLog.bluetooth('Recovery scan failed: $scanError', level: LogLevel.warning);
        }

        // Retry connect once after scan
        await bluetoothDevice.connect(license: License.nonprofit, timeout: const Duration(seconds: 15));
      } else {
        rethrow;
      }
    }
    DebugLog.bluetooth('Connected successfully!', level: LogLevel.debug);

    device.emitStatus('Verbunden');

    // Allow device-specific optimizations (e.g., MTU negotiation, GATT cache clear)
    await onDeviceConnected();

    // Discover services
    DebugLog.bluetooth('\nDiscovering services...', level: LogLevel.debug);
    List<BluetoothService> services = await bluetoothDevice.discoverServices();
    DebugLog.bluetooth('Found ${services.length} services', level: LogLevel.debug);

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

    DebugLog.bluetooth('All required characteristics found', level: LogLevel.debug);

    // Allow subclasses to setup characteristics (e.g., enable notifications)
    // If setup fails, disconnect the BLE link to avoid a zombie connection
    // where isConnected() returns true but characteristics are unusable.
    try {
      await setupCharacteristics();
    } catch (e) {
      DebugLog.bluetooth('setupCharacteristics() failed: $e — disconnecting BLE link', level: LogLevel.error);
      try { await bluetoothDevice.disconnect(); } catch (_) {}
      rethrow;
    }

    DebugLog.bluetooth('Device ready!', level: LogLevel.debug);
    DebugLog.bluetooth('═══════════════════════════════════════════════════════════════\n', level: LogLevel.debug);

    return true;
  }

  /// Device-specific Bluetooth disconnection logic
  @override
  Future<void> internalDisconnect() async {
    // Only call disconnect if the device is still physically connected.
    // Calling disconnect() on an already-disconnected device causes FBP to wait
    // up to 35s for a BlueZ confirmation that never arrives (device already gone).
    try {
      if (bluetoothDevice.isConnected) {
        await bluetoothDevice.disconnect();
      }
    } catch (e) {
      DebugLog.bluetooth('BLE disconnect error (non-critical): $e', level: LogLevel.debug);
    }

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
      DebugLog.bluetooth('Service: $serviceUuidStr', level: LogLevel.verbose);

      if (serviceUuidStr == serviceUuid.toLowerCase() ||
          (serviceUuidShort != null && serviceUuidStr == serviceUuidShort!.toLowerCase())) {
        DebugLog.bluetooth('Found device service!', level: LogLevel.debug);
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
        DebugLog.bluetooth('Characteristic: $charUuid', level: LogLevel.verbose);

        // Check notify characteristic
        if (notifyCharacteristicUuid != null &&
            (charUuid == notifyCharacteristicUuid!.toLowerCase() ||
             (notifyCharacteristicUuidShort != null && charUuid == notifyCharacteristicUuidShort!.toLowerCase()))) {
          _notifyCharacteristic = char;
          DebugLog.bluetooth('Found notify characteristic!', level: LogLevel.debug);
        }

        // Check write characteristic
        if (writeCharacteristicUuid != null &&
            (charUuid == writeCharacteristicUuid!.toLowerCase() ||
             (writeCharacteristicUuidShort != null && charUuid == writeCharacteristicUuidShort!.toLowerCase()))) {
          _writeCharacteristic = char;
          DebugLog.bluetooth('Found write characteristic!', level: LogLevel.debug);
        }

        // Check RW characteristic (used by Shelly)
        if (rwCharacteristicUuid != null &&
            (charUuid == rwCharacteristicUuid!.toLowerCase() ||
             (rwCharacteristicUuidShort != null && charUuid == rwCharacteristicUuidShort!.toLowerCase()))) {
          _rwCharacteristic = char;
          DebugLog.bluetooth('Found RW characteristic!', level: LogLevel.debug);
        }

        // Check read/notify characteristic (used by Shelly)
        if (readNotifyCharacteristicUuid != null &&
            (charUuid == readNotifyCharacteristicUuid!.toLowerCase() ||
             (readNotifyCharacteristicUuidShort != null && charUuid == readNotifyCharacteristicUuidShort!.toLowerCase()))) {
          _readNotifyCharacteristic = char;
          DebugLog.bluetooth('Found read/notify characteristic!', level: LogLevel.debug);
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
