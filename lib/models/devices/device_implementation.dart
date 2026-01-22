import 'package:flutter/material.dart';
import 'generic_rendering/device_category_config.dart';
import 'generic_rendering/device_control_item.dart';
import 'generic_rendering/device_custom_section.dart';
import 'generic_rendering/device_data_field.dart';
import 'generic_rendering/device_menu_item.dart';
import 'time_series_field_config.dart';
import 'time_series_field_group.dart';

/// Base interface for device-specific implementations
/// Following Shelly's successful strategy pattern
///
/// This interface defines the contract for device-specific behavior that is
/// shared between Bluetooth and WiFi variants of the same device type.
///
/// Implementations provide:
/// - UI elements (menu items, data fields, control items, custom sections)
/// - Device icon
/// - Fetch command name
/// - Device-specific command handling
///
/// Example:
/// ```dart
/// class ZendureDeviceImplementation extends DeviceImplementation {
///   @override
///   List<DeviceMenuItem> getMenuItems() => [
///     DeviceMenuItem(name: 'Power Settings', ...),
///   ];
///
///   @override
///   Future<Map<String, dynamic>?> sendCommand(
///     dynamic connectionService,
///     String command,
///     Map<String, dynamic> params,
///   ) async {
///     final service = connectionService as ZendureBluetoothService;
///     // Handle device-specific commands
///   }
/// }
/// ```
abstract class DeviceImplementation {
  /// Returns the list of menu items displayed in the device detail screen
  List<DeviceMenuItem> getMenuItems();

  /// Returns the list of control items (switches, sliders, etc.)
  /// Default implementation returns empty list
  List<DeviceControlItem> getControlItems() => [];

  /// Returns the list of data fields displayed in the device detail screen
  List<DeviceDataField> getDataFields();

  /// Returns the list of custom UI sections to inject into the device detail screen
  /// Default implementation returns empty list
  List<DeviceCustomSection> getCustomSections() => [];

  /// Returns the list of category configurations for grouping data fields
  /// Default implementation returns empty list
  List<DeviceCategoryConfig> getCategoryConfigs() => [];

  /// Returns the list of time series fields to track for graphing
  /// Default implementation returns empty list (no tracking)
  List<TimeSeriesFieldConfig> getTimeSeriesFields() => [];

  /// Returns the list of time series field groups for multi-series graphs
  /// Default implementation returns empty list (no grouped graphs)
  List<TimeSeriesFieldGroup> getTimeSeriesFieldGroups() => [];

  /// Returns the icon to display for this device type
  /// Returns null to use manufacturer-based fallback icon
  IconData? getDeviceIcon() => null;  // Default returns null (triggers manufacturer fallback)

  /// Handle device-specific commands
  ///
  /// The connectionService parameter is typed as dynamic to allow
  /// different service types (ShellyService, ZendureBluetoothService, etc.)
  /// Implementations should cast to the appropriate type for type safety.
  ///
  /// Example:
  /// ```dart
  /// @override
  /// Future<Map<String, dynamic>?> sendCommand(
  ///   dynamic connectionService,
  ///   String command,
  ///   Map<String, dynamic> params,
  /// ) async {
  ///   final service = connectionService as ShellyService;
  ///
  ///   if (command == COMMAND_FETCH_DATA) {
  ///     return await service.sendCommand('Shelly.GetStatus', {});
  ///   }
  ///   // ... handle other commands
  ///
  ///   throw UnimplementedError('Command not implemented: $command');
  /// }
  /// ```
  Future<Map<String, dynamic>?> sendCommand(
    dynamic connectionService,
    String command,
    Map<String, dynamic> params,
  ) {
    throw UnimplementedError('Command not implemented: $command');
  }
}
