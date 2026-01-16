import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:meta/meta.dart';
import 'package:the_solar_app/services/devices/base_device_service.dart';
import 'device_base.dart';
import 'device_implementation.dart';
import 'generic_rendering/device_data_field.dart';
import 'mixins/device_wifi_mixin.dart';

/// Generic template for WiFi devices
///
/// Eliminates code duplication across WiFi device implementations by
/// providing automatic:
/// - WiFi serialization (IP, hostname, port via DeviceWifiMixin)
/// - Service setup pattern
/// - Serialization (deviceType)
/// - Icon delegation to implementation
/// - Command delegation to implementation
/// - Helper method for WiFi deserialization
///
/// Type Parameters:
/// - [TService]: The service type (e.g., ZendureWifiService)
/// - [TImpl]: The implementation type (extends DeviceImplementation)
///
/// Example Usage:
/// ```dart
/// class WiFiZendureDevice extends GenericWiFiDevice<
///     ZendureWifiService,
///     ZendureDeviceImplementation> {
///
///   WiFiZendureDevice({
///     required super.id,
///     required super.name,
///     required super.lastSeen,
///     required super.deviceSn,
///     super.ipAddress,
///     super.hostname,
///     super.port = 80,
///     super.deviceModel,
///   }) : super(deviceImpl: ZendureDeviceImplementation());
///
///   @override
///   String get deviceType => DEVICE_MANUFACTURER_ZENDURE;
///
///   @override
///   ZendureWifiService createService() {
///     return ZendureWifiService(this);
///   }
///
///   factory WiFiZendureDevice.fromJson(Map<String, dynamic> json) {
///     final device = WiFiZendureDevice(
///       id: json['id'] as String,
///       name: json['name'] as String,
///       lastSeen: DateTime.parse(json['lastSeen'] as String),
///       deviceSn: json['deviceSn'] as String,
///       deviceModel: json['deviceModel'] as String?,
///     );
///     device.deserializeWiFi(json);
///     return device;
///   }
/// }
/// ```
abstract class GenericWiFiDevice<TService extends BaseDeviceService, TImpl extends DeviceImplementation>
    extends DeviceBase<TService>
    with DeviceWifiMixin {

  /// Device-specific implementation providing UI elements and command handling
  final TImpl deviceImpl;

  GenericWiFiDevice({
    required super.id,
    required super.name,
    required super.lastSeen,
    required super.deviceSn,
    required this.deviceImpl,
    String? ipAddress,
    String? hostname,
    int? port,
    super.deviceModel,
  }) : super(
    connectionType: ConnectionType.wifi,
    menuItems: deviceImpl.getMenuItems(),
    controlItems: deviceImpl.getControlItems(),
    customSections: deviceImpl.getCustomSections(),
    categoryConfigs: deviceImpl.getCategoryConfigs(),
    timeSeriesFields: deviceImpl.getTimeSeriesFields(),
  ) {
    netIpAddress = ipAddress;
    netHostname = hostname;
    netPort = port;
  }

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
  /// factory WiFiZendureDevice.fromJson(Map<String, dynamic> json) {
  ///   final device = WiFiZendureDevice.fromJsonFields(
  ///     json: json,
  ///     deviceImpl: ZendureDeviceImplementation(),
  ///   );
  ///   device.deserializeWiFi(json);
  ///   return device;
  /// }
  /// ```
  @protected
  GenericWiFiDevice.fromJsonFields({
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

  /// Common WiFi service setup pattern
  ///
  /// Automatically handles service cleanup before calling the
  /// device-specific createService() method.
  @override
  Future<void> setUpServiceConnection(BluetoothDevice? device) async {
    await removeServiceConnection();
    connectionService = createService();
  }

  /// Create the device-specific service
  ///
  /// Override this method in subclasses to instantiate the appropriate
  /// service type for your device.
  ///
  /// Example:
  /// ```dart
  /// @override
  /// ZendureWifiService createService() {
  ///   return ZendureWifiService(this);
  /// }
  /// ```
  TService createService();

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

  /// Automatic serialization with deviceType and WiFi fields
  ///
  /// Automatically includes the deviceType and WiFi connection data
  /// (IP, hostname, port) in JSON serialization.
  /// Override in subclasses only if you need additional fields.
  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json['deviceType'] = deviceType;
    json.addAll(wifiToJson());
    return json;
  }

  /// Common WiFi deserialization helper
  ///
  /// Call this method in your fromJson factory to automatically
  /// deserialize WiFi connection data (IP, hostname, port).
  ///
  /// Example:
  /// ```dart
  /// factory WiFiZendureDevice.fromJson(Map<String, dynamic> json) {
  ///   final device = WiFiZendureDevice(...);
  ///   device.deserializeWiFi(json);
  ///   return device;
  /// }
  /// ```
  void deserializeWiFi(Map<String, dynamic> json) {
    wifiFromJson(json);
  }
}
