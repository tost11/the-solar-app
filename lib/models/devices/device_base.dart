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
  late final List<DeviceDataField> dataFields;
  late final List<DeviceMenuItem> menuItems;
  late final List<DeviceControlItem> controlItems;
  late final List<DeviceCustomSection> customSections;
  late final List<DeviceCategoryConfig> categoryConfigs;
  late final List<TimeSeriesFieldConfig> timeSeriesFields;
  Map<String,Map<String,dynamic>> data = {};
  ServiceType ? connectionService;

  String? getDeviceModelGroup(){
    return deviceModel;
  }

  // Stream controllers for state management
  final _connectionStatusController = StreamController<String>.broadcast();
  final _dataController = StreamController<Map<String,dynamic>>.broadcast();
  final _errorController = StreamController<String>.broadcast();
  final _deviceInfoController = StreamController<Map<String, dynamic>>.broadcast();

  // Public streams
  Stream<String> get connectionStatus => _connectionStatusController.stream;
  Stream<Map<String,dynamic>> get dataStream => _dataController.stream;
  Stream<String> get errors => _errorController.stream;
  Stream<Map<String, dynamic>> get deviceInfo => _deviceInfoController.stream;

  void emitStatus(String status){
    _connectionStatusController.add(status);
  }

  void emitData(Map<String,dynamic> data){
    _dataController.add(data);
    _trackTimeSeriesData(data);
  }

  void emitError(String status){
    _errorController.add(status);
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
    required this.dataFields,
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

  void setUpServiceConnection(BluetoothDevice ? device);

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

  void removeServiceConnection(){
    if(connectionService != null){
      connectionService?.disconnect();
      connectionService?.dispose();
    }

    connectionService = null;
  }

  //this function sets generic commands into specific device commands
  Future<Map<String,dynamic>?> sendCommand(String command,Map<String, dynamic> params);

  void assertServiceIsFine(){
    if(connectionService == null || connectionService?.isConnected() != true || connectionService?.isInitialized() != true){
      throw Exception("device no ready to send commands");
    }
  }
}
