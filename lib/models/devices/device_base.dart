import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:the_solar_app/services/devices/base_device_service.dart';

import 'generic_rendering/device_category_config.dart';
import 'generic_rendering/device_data_field.dart';
import 'generic_rendering/device_menu_item.dart';
import 'generic_rendering/device_control_item.dart';
import 'generic_rendering/device_custom_section.dart';
import 'time_series_field_config.dart';

/// Error payload with background/foreground routing flag
class DeviceError {
  final String message;
  final bool isBackgroundError;  // true = footer, false = overlay
  final DateTime timestamp;

  DeviceError({
    required this.message,
    required this.isBackgroundError,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

enum ConnectionType {
  bluetooth,
  wifi;

  String toJson() => name;

  static ConnectionType fromJson(String value) {
    return ConnectionType.values.firstWhere(
      (type) => type.name == value,
      orElse: () => ConnectionType.bluetooth,
    );
  }

  String get displayName {
    switch (this) {
      case ConnectionType.bluetooth:
        return 'Bluetooth';
      case ConnectionType.wifi:
        return 'WiFi';
    }
  }
}

/// Abstract base class for all Zendure devices
///
/// Provides common properties and abstract methods for device communication
abstract class DeviceBase<ServiceType extends BaseDeviceService> {
  final String id;
  String name;
  final DateTime lastSeen;
  final String deviceSn;
  String? deviceModel;
  final ConnectionType connectionType;

  /// Dynamically compute data fields based on current device state
  /// This ensures fields reflect detected modules/components after connection
  List<DeviceDataField> get dataFields;

  late List<DeviceMenuItem> menuItems;
  late List<DeviceControlItem> controlItems;  // Removed final to allow dynamic updates
  late List<DeviceCustomSection> customSections;
  late List<DeviceCategoryConfig> categoryConfigs;
  late List<TimeSeriesFieldConfig> timeSeriesFields;  // Removed final to allow dynamic updates
  Map<String,Map<String,dynamic>> data = {};
  ServiceType ? connectionService;

  String? getDeviceModelGroup(){
    return deviceModel;
  }

  // Stream controllers for state management
  final _connectionStatusController = StreamController<String>.broadcast();
  final _dataController = StreamController<Map<String,dynamic>>.broadcast();
  final _errorController = StreamController<DeviceError>.broadcast();
  final _deviceInfoController = StreamController<Map<String, dynamic>>.broadcast();

  // Public streams
  Stream<String> get connectionStatus => _connectionStatusController.stream;
  Stream<Map<String,dynamic>> get dataStream => _dataController.stream;
  Stream<DeviceError> get errors => _errorController.stream;
  Stream<Map<String, dynamic>> get deviceInfo => _deviceInfoController.stream;

  void emitStatus(String status){
    _connectionStatusController.add(status);
  }

  void emitData(Map<String,dynamic> data){
    _dataController.add(data);
    _trackTimeSeriesData(data);
  }

  /// Emit an error (defaults to foreground/overlay for backward compatibility)
  ///
  /// Use this for command errors that should show in global overlay
  void emitError(String error) {
    emitErrorWithFlag(error, false);  // false = global overlay (default)
  }

  /// Emit error with routing flag
  ///
  /// [error] - Error message to emit
  /// [isBackgroundError] - If true, show in detail screen footer (connection errors)
  ///                       If false, show in global overlay (command errors)
  void emitErrorWithFlag(String error, bool isBackgroundError) {
    _errorController.add(DeviceError(
      message: error,
      isBackgroundError: isBackgroundError,
    ));
  }

  /// Track time series data for graphing
  /// Extracts values from received data and stores them in time series fields
  void _trackTimeSeriesData(Map<String, dynamic> receivedData) {
    final now = DateTime.now();

    for (var field in timeSeriesFields) {
      try {
        // Extract value using the field's built-in extraction method
        final numValue = field.extractValue(receivedData);

        if (numValue != null) {
          // Add to time series
          field.addValue(now, numValue);

          // Prune old data (>5 minutes)
          field.pruneOldData();
        }
      } catch (e) {
        // Silently skip if field extraction fails
        debugPrint('Failed to track field ${field.name}: $e');
      }
    }
  }

  void emitDeviceInfo(Map<String,dynamic> data){
    _deviceInfoController.add(data);
  }

  // Device-specific icon for display in lists
  // Override in subclasses to provide custom icons
  IconData get deviceIcon => Icons.solar_power;

  DeviceBase({
    required this.id,
    required this.name,
    required this.lastSeen,
    required this.deviceSn,
    required this.connectionType,
    required this.menuItems,
    this.controlItems = const [],
    this.customSections = const [],
    this.categoryConfigs = const [],
    this.timeSeriesFields = const [],
    this.deviceModel,
  });

  ServiceType ? getServiceConnection(){
    return connectionService;
  }

  Future<void> setUpServiceConnection(BluetoothDevice ? device);

  /// Serialize to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'lastSeen': lastSeen.toIso8601String(),
      'deviceSn': deviceSn,
      'deviceModel': deviceModel,
      'connectionType': connectionType.toJson(),
    };
  }

  /// Factory method to create device from JSON and connection type
  static DeviceBase fromJson(Map<String, dynamic> json) {
    // Import will be added when we create the concrete classes
    // For now, we'll handle this in the concrete implementations
    throw UnimplementedError(
      'fromJson must be implemented in DeviceBase subclass factory',
    );
  }

  Future<void> removeServiceConnection() async {
    final cs = this.connectionService;
    if(cs != null){
      await cs.disconnect();
      cs.dispose();
    }

    connectionService = null;
  }

  //this function sets generic commands into specific device commands
  Future<Map<String,dynamic>?> sendCommand(String command,Map<String, dynamic> params);

  void assertServiceIsFine(){
    if(connectionService == null || connectionService?.isConnected() != true || connectionService?.isServiceInitialized() != true){
      throw Exception("device no ready to send commands");
    }
  }
}
