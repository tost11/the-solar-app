import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:meta/meta.dart';
import 'package:the_solar_app/services/devices/base_device_service.dart';
import 'device_base.dart';
import 'device_implementation.dart';
import 'generic_rendering/device_data_field.dart';

/// Generic template for Bluetooth devices
///
/// Eliminates code duplication across Bluetooth device implementations by
/// providing automatic:
/// - Service setup pattern
/// - Serialization (deviceType)
/// - Icon delegation to implementation
/// - Command delegation to implementation
///
/// Type Parameters:
/// - [TService]: The service type (e.g., ZendureBluetoothService)
/// - [TImpl]: The implementation type (extends DeviceImplementation)
///
/// Example Usage:
/// ```dart
/// class BluetoothZendureDevice extends GenericBluetoothDevice<
///     ZendureBluetoothService,
///     ZendureDeviceImplementation> {
///
///   BluetoothZendureDevice({
///     required super.id,
///     required super.name,
///     required super.lastSeen,
///     required super.deviceSn,
///     super.deviceModel,
///   }) : super(deviceImpl: ZendureDeviceImplementation());
///
///   @override
///   String get deviceType => DEVICE_MANUFACTURER_ZENDURE;
///
///   @override
///   ZendureBluetoothService createService(BluetoothDevice device) {
///     return ZendureBluetoothService(device: this, bluetoothDvice: device);
///   }
///
///   factory BluetoothZendureDevice.fromJson(Map<String, dynamic> json) {
///     return BluetoothZendureDevice(
///       id: json['id'] as String,
///       name: json['name'] as String,
///       lastSeen: DateTime.parse(json['lastSeen'] as String),
///       deviceSn: json['deviceSn'] as String,
///       deviceModel: json['deviceModel'] as String?,
///     );
///   }
/// }
/// ```
abstract class GenericBluetoothDevice<TService extends BaseDeviceService, TImpl extends DeviceImplementation>
    extends DeviceBase<TService> {

  /// Device-specific implementation providing UI elements and command handling
  final TImpl deviceImpl;

  GenericBluetoothDevice({
    required super.id,
    required super.name,
    required super.lastSeen,
    required super.deviceSn,
    required this.deviceImpl,
    super.deviceModel,
  }) : super(
    connectionType: ConnectionType.bluetooth,
    menuItems: deviceImpl.getMenuItems(),
    controlItems: deviceImpl.getControlItems(),
    customSections: deviceImpl.getCustomSections(),
    categoryConfigs: deviceImpl.getCategoryConfigs(),
    timeSeriesFields: deviceImpl.getTimeSeriesFields(),
  );

  /// Dynamically compute data fields based on current device state
  @override
  List<DeviceDataField> get dataFields => deviceImpl.getDataFields();

  /// Protected named constructor for JSON deserialization
  ///
  /// This constructor parses common fields from JSON and delegates to the main constructor.
  /// Subclasses only need to pass the JSON map and device implementation.
  ///
  /// Example usage in subclass:
  /// ```dart
  /// factory BluetoothZendureDevice.fromJson(Map<String, dynamic> json) {
  ///   return BluetoothZendureDevice.fromJsonFields(
  ///     json: json,
  ///     deviceImpl: ZendureDeviceImplementation(),
  ///   );
  /// }
  /// ```
  @protected
  GenericBluetoothDevice.fromJsonFields({
    required Map<String, dynamic> json,
    required TImpl deviceImpl,
  }) : this(
    id: json['id'] as String,
    name: json['name'] as String,
    lastSeen: DateTime.parse(json['lastSeen'] as String),
    deviceSn: json['deviceSn'] as String,
    deviceModel: json['deviceModel'] as String?,
    deviceImpl: deviceImpl,
  );

  /// Returns device icon from implementation
  @override
  IconData get deviceIcon => deviceImpl.getDeviceIcon();

  /// Common Bluetooth service setup pattern
  ///
  /// Automatically handles null check and service cleanup before
  /// calling the device-specific createService() method.
  @override
  Future<void> setUpServiceConnection(BluetoothDevice? device) async {
    if (device == null) {
      throw Exception("Bluetooth device required for $runtimeType");
    }
    await removeServiceConnection();
    connectionService = createService(device);
  }

  /// Create the device-specific service
  ///
  /// Override this method in subclasses to instantiate the appropriate
  /// service type for your device.
  ///
  /// Example:
  /// ```dart
  /// @override
  /// ZendureBluetoothService createService(BluetoothDevice device) {
  ///   return ZendureBluetoothService(device: this, bluetoothDvice: device);
  /// }
  /// ```
  TService createService(BluetoothDevice device);

  /// Device manufacturer identifier for serialization
  ///
  /// Override this getter to return the device type constant.
  /// Example: DEVICE_MANUFACTURER_ZENDURE, DEVICE_MANUFACTURER_SHELLY
  String get deviceType;

  /// Default command handler - delegates to implementation
  ///
  /// This provides automatic delegation to the device implementation's
  /// sendCommand() method. Override in subclasses only if you need
  /// connection-type-specific command handling.
  @override
  Future<Map<String, dynamic>?> sendCommand(
    String command,
    Map<String, dynamic> params,
  ) async {
    assertServiceIsFine();
    return await deviceImpl.sendCommand(connectionService, command, params);
  }

  /// Automatic serialization with deviceType
  ///
  /// Automatically includes the deviceType in JSON serialization.
  /// Override in subclasses only if you need additional fields.
  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json['deviceType'] = deviceType;
    return json;
  }
}
