import 'dart:convert';
import '../utils/debug_log.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/device.dart';

/// Device storage service with in-memory registry
///
/// This singleton service maintains devices in memory after initial load,
/// eliminating constant recreation of device instances and preventing
/// orphaned service connections.
///
/// Key features:
/// - Loads devices from storage ONLY on app start
/// - Keeps devices in memory using Map for fast O(1) lookups
/// - Updates both RAM and storage on device changes
/// - Never reloads from storage after initialization
/// - Properly cleans up device instances on removal
class DeviceStorageService {
  // Singleton pattern
  static final DeviceStorageService _instance = DeviceStorageService._internal();
  factory DeviceStorageService() => _instance;
  DeviceStorageService._internal();

  static const String _devicesKey = 'known_devices';

  // In-memory device registry (single source of truth)
  // Key: device ID (id) for fast lookup
  final Map<String, DeviceBase> _deviceRegistry = {};
  bool _isInitialized = false;

  /// Initialize device registry from storage
  ///
  /// MUST be called once on app startup before using any other methods.
  /// Subsequent calls are no-ops (safe to call multiple times).
  ///
  /// This loads all devices from SharedPreferences into memory
  /// and builds the device registry Map for fast lookups.
  Future<void> initialize() async {
    if (_isInitialized) {
      DebugLog.storage('[DeviceStorage] Already initialized, skipping reload', level: LogLevel.debug);
      return;
    }

    DebugLog.storage('[DeviceStorage] Initializing device registry from storage...', level: LogLevel.debug);

    final prefs = await SharedPreferences.getInstance();
    final String? devicesJson = prefs.getString(_devicesKey);

    if (devicesJson == null) {
      DebugLog.storage('[DeviceStorage] No devices in storage, starting with empty registry', level: LogLevel.debug);
      _isInitialized = true;
      return;
    }

    try {
      final List<dynamic> decoded = jsonDecode(devicesJson);
      final List<DeviceBase> devices = [];

      for (final json in decoded) {
        try {
          final deviceJson = json as Map<String, dynamic>;
          var dev = DeviceFactory.fromJson(deviceJson);
          if (dev != null) {
            devices.add(dev);
          }
        } catch (e) {
          DebugLog.storage('[DeviceStorage] Error loading device: $e', level: LogLevel.error);
          // Continue with next device
        }
      }

      // Build registry Map with device ID as key for O(1) lookup
      _deviceRegistry.clear();
      for (var device in devices) {
        _deviceRegistry[device.id] = device;
      }

      DebugLog.storage('[DeviceStorage] Loaded ${_deviceRegistry.length} devices into registry', level: LogLevel.debug);
      _isInitialized = true;
    } catch (e) {
      DebugLog.storage('[DeviceStorage] Error initializing registry: $e', level: LogLevel.error);
      _deviceRegistry.clear();
      _isInitialized = true;
    }
  }

  /// Get all devices from in-memory registry
  ///
  /// Returns the current list of devices held in memory.
  /// Does NOT reload from storage - uses cached instances.
  ///
  /// IMPORTANT: Must call initialize() first on app startup!
  List<DeviceBase> getKnownDevices() {
    if (!_isInitialized) {
      DebugLog.storage('[DeviceStorage] WARNING: getKnownDevices() called before initialize()!', level: LogLevel.warning);
      return [];
    }
    return _deviceRegistry.values.toList();
  }

  /// Get single device by ID (fast O(1) lookup)
  ///
  /// Returns device instance from registry or null if not found.
  /// Much faster than iterating through getKnownDevices() list.
  DeviceBase? getDevice(String deviceId) {
    return _deviceRegistry[deviceId];
  }


  /// Save or update device in registry and persist to storage
  ///
  /// Updates the device in memory (registry) and saves entire registry to storage.
  /// If device already exists (by ID), replaces it in place.
  /// If device is new, adds it to registry.
  ///
  /// This ensures both RAM and storage are kept in sync.
  Future<void> saveDevice(DeviceBase device) async {
    if (!_isInitialized) {
      DebugLog.storage('[DeviceStorage] WARNING: saveDevice() called before initialize()!', level: LogLevel.warning);
      return;
    }

    final isNew = !_deviceRegistry.containsKey(device.id);

    // If replacing an existing device, check if it's a different instance
    if (!isNew) {
      final existingDevice = _deviceRegistry[device.id]!;

      // Only dispose if it's a DIFFERENT instance (not same object reference)
      if (!identical(existingDevice, device)) {
        DebugLog.storage('[DeviceStorage] Replacing device instance, disposing old one: ${existingDevice.name}', level: LogLevel.debug);
        try {
          await existingDevice.dispose();
          DebugLog.storage('[DeviceStorage] Old device instance disposed successfully', level: LogLevel.debug);
        } catch (e) {
          DebugLog.storage('[DeviceStorage] Error disposing replaced device: $e', level: LogLevel.error);
          // Continue with replacement even if dispose fails
        }
      }
    }

    // Update in-memory registry
    _deviceRegistry[device.id] = device;

    DebugLog.storage('[DeviceStorage] ${isNew ? "Added new" : "Updated"} device: ${device.name} (ID: ${device.id})', level: LogLevel.debug);

    // Persist entire registry to storage
    await _persistToStorage();
  }

  /// Remove device from registry with proper cleanup
  ///
  /// 1. Calls dispose() on device to cleanup service connections and streams
  /// 2. Removes from in-memory registry
  /// 3. Persists updated registry to storage
  ///
  /// This prevents memory leaks from orphaned service connections.
  Future<void> removeDevice(String deviceId) async {
    if (!_isInitialized) {
      DebugLog.storage('[DeviceStorage] WARNING: removeDevice() called before initialize()!', level: LogLevel.warning);
      return;
    }

    // Direct O(1) lookup by device ID
    final device = _deviceRegistry[deviceId];
    if (device == null) {
      DebugLog.storage('[DeviceStorage] Device not found for removal: $deviceId', level: LogLevel.warning);
      return;
    }

    DebugLog.storage('[DeviceStorage] Removing device: ${device.name} (ID: $deviceId)', level: LogLevel.debug);

    // Cleanup device resources (service connections, streams)
    try {
      await device.dispose();
      DebugLog.storage('[DeviceStorage] Device disposed successfully', level: LogLevel.debug);
    } catch (e) {
      DebugLog.storage('[DeviceStorage] Error disposing device: $e', level: LogLevel.error);
      // Continue with removal even if dispose fails
    }

    // Remove from in-memory registry
    _deviceRegistry.remove(deviceId);

    // Persist updated registry to storage
    await _persistToStorage();
  }

  /// Private: Persist current in-memory registry to SharedPreferences
  Future<void> _persistToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final devicesJson = jsonEncode(
        _deviceRegistry.values.map((d) => d.toJson()).toList(),
      );
      await prefs.setString(_devicesKey, devicesJson);
      DebugLog.storage('[DeviceStorage] Persisted ${_deviceRegistry.length} devices to storage', level: LogLevel.debug);
    } catch (e) {
      DebugLog.storage('[DeviceStorage] Error persisting to storage: $e', level: LogLevel.error);
      // Don't throw - registry is still valid in memory
    }
  }

  /// Clear all devices from registry and storage (for testing/reset)
  Future<void> clearAll() async {
    // Dispose all devices first
    for (final device in _deviceRegistry.values) {
      try {
        await device.dispose();
      } catch (e) {
        DebugLog.storage('[DeviceStorage] Error disposing device during clearAll: $e', level: LogLevel.error);
      }
    }

    _deviceRegistry.clear();
    await _persistToStorage();
    DebugLog.storage('[DeviceStorage] Cleared all devices from registry and storage', level: LogLevel.debug);
  }
}
