import 'package:meta/meta.dart';
import 'package:the_solar_app/services/devices/base_device_service.dart';
import 'mixins/device_authentication_mixin.dart';
import 'device_implementation.dart';
import 'generic_wifi_device.dart';

/// Generic template for WiFi devices with authentication
///
/// Extends GenericWiFiDevice to add automatic authentication support.
/// Used by devices that require username/password authentication
/// (OpenDTU, DeyeSun, Shelly).
///
/// Provides automatic:
/// - WiFi serialization (IP, hostname, port)
/// - Authentication serialization (username, password)
/// - Service setup pattern
/// - Icon and command delegation
/// - Helper method for WiFi + Auth deserialization
///
/// Type Parameters:
/// - [TService]: The service type (e.g., OpenDTUWifiService)
/// - [TImpl]: The implementation type (extends DeviceImplementation)
///
/// Example Usage:
/// ```dart
/// class WiFiOpenDTUDevice extends GenericWiFiAuthDevice<
///     OpenDTUWifiService,
///     OpenDTUDeviceImplementation> {
///
///   WiFiOpenDTUDevice({
///     required super.id,
///     required super.name,
///     required super.lastSeen,
///     required super.deviceSn,
///     super.ipAddress,
///     super.hostname,
///     super.port = 80,
///     super.deviceModel,
///   }) : super(deviceImpl: OpenDTUDeviceImplementation()) {
///     authUsername = "admin";
///     authPassword = "openDTU42";
///   }
///
///   @override
///   String get deviceType => DEVICE_MANUFACTURER_OPENDTU;
///
///   @override
///   OpenDTUWifiService createService() {
///     return OpenDTUWifiService(this);
///   }
///
///   factory WiFiOpenDTUDevice.fromJson(Map<String, dynamic> json) {
///     final device = WiFiOpenDTUDevice(
///       id: json['id'] as String,
///       name: json['name'] as String,
///       lastSeen: DateTime.parse(json['lastSeen'] as String),
///       deviceSn: json['deviceSn'] as String,
///       deviceModel: json['deviceModel'] as String?,
///     );
///     device.deserializeWiFi(json); // Handles both WiFi and Auth
///     return device;
///   }
/// }
/// ```
abstract class GenericWiFiAuthDevice<TService extends BaseDeviceService, TImpl extends DeviceImplementation>
    extends GenericWiFiDevice<TService, TImpl>
    with DeviceAuthenticationMixin {

  GenericWiFiAuthDevice({
    required super.id,
    required super.name,
    required super.lastSeen,
    required super.deviceSn,
    required super.deviceImpl,
    super.ipAddress,
    super.hostname,
    super.port,
    super.deviceModel,
  });

  /// Protected named constructor for JSON deserialization
  ///
  /// This constructor parses common fields from JSON and delegates to parent.
  /// Subclasses only need to pass the JSON map and device implementation.
  ///
  /// Example usage in subclass:
  /// ```dart
  /// factory WiFiOpenDTUDevice.fromJson(Map<String, dynamic> json) {
  ///   final device = WiFiOpenDTUDevice.fromJsonFields(
  ///     json: json,
  ///     deviceImpl: OpenDTUDeviceImplementation(),
  ///   );
  ///   device.deserializeWiFi(json); // Handles WiFi + Auth
  ///   return device;
  /// }
  /// ```
  @protected
  GenericWiFiAuthDevice.fromJsonFields({
    required Map<String, dynamic> json,
    required TImpl deviceImpl,
  }) : super.fromJsonFields(
    json: json,
    deviceImpl: deviceImpl,
  );

  /// Automatic serialization with deviceType, WiFi fields, and authentication
  ///
  /// Automatically includes the deviceType, WiFi connection data,
  /// and authentication credentials in JSON serialization.
  /// Override in subclasses only if you need additional fields.
  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json.addAll(authToJson());
    return json;
  }

  /// Common WiFi + Auth deserialization helper
  ///
  /// Call this method in your fromJson factory to automatically
  /// deserialize both WiFi connection data and authentication credentials.
  /// This overrides the base deserializeWiFi() to also handle auth data.
  ///
  /// Example:
  /// ```dart
  /// factory WiFiOpenDTUDevice.fromJson(Map<String, dynamic> json) {
  ///   final device = WiFiOpenDTUDevice(...);
  ///   device.deserializeWiFi(json); // Now handles both WiFi and Auth
  ///   return device;
  /// }
  /// ```
  @override
  void deserializeWiFi(Map<String, dynamic> json) {
    super.deserializeWiFi(json);
    authFromJson(json);
  }
}
