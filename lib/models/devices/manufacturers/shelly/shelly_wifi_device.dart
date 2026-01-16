import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:the_solar_app/constants/bluetooth_constants.dart';
import 'package:the_solar_app/constants/command_constants.dart';
import 'package:the_solar_app/models/devices/generic_wifi_auth_device.dart';
import 'package:the_solar_app/models/devices/mixins/fetch_data_timeout_mixin.dart';
import 'implementations/shelly_device_base_implementation.dart';
import 'package:the_solar_app/services/device_storage_service.dart';
import 'package:the_solar_app/services/devices/shelly/shelly_wifi_service.dart';

/// Generic Shelly WiFi device template
///
/// Extends GenericWiFiAuthDevice and adds Shelly-specific functionality
/// Used as base class for specific Shelly WiFi device types
class ShellyWifiDeviceTemplate extends GenericWiFiAuthDevice<
    ShellyWifiService,
    ShellyDeviceBaseImplementation> with FetchDataTimeoutMixin {

  static const Duration DEFAULT_FETCH_INTERVAL = Duration(seconds: 5);

  String? deviceScr;

  ShellyWifiDeviceTemplate({
    required super.id,
    required super.name,
    required super.lastSeen,
    required super.deviceSn,
    super.deviceModel,
    required super.deviceImpl,
    super.ipAddress,
    super.hostname,
    super.port = 80,
  }) {
    fetchDataInterval = DEFAULT_FETCH_INTERVAL;
    fixedUserName = true;
    authUsername = 'admin';
  }

  @override
  String? getDeviceModelGroup(){
    if(deviceModel != null){
      return deviceModel?.split("-").elementAt(0);
    }
    return deviceModel;
  }

  /// Named constructor for JSON deserialization
  ShellyWifiDeviceTemplate.fromJsonFields({
    required Map<String, dynamic> json,
    required ShellyDeviceBaseImplementation deviceImpl,
  }) : super.fromJsonFields(json: json, deviceImpl: deviceImpl);

  @override
  String get deviceType => DEVICE_MANUFACTURER_SHELLY;

  @override
  ShellyWifiService createService() {
    return ShellyWifiService(this);
  }

  /// Computes HA1 hash for authentication: SHA256("user:realm:password")
  String _computeHA1(String user, String realm, String password) {
    final input = '$user:$realm:$password';
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Override sendCommand to handle COMMAND_SET_AUTH which requires device state access
  @override
  Future<Map<String, dynamic>?> sendCommand(
    String command,
    Map<String, dynamic> params,
  ) async {
    assertServiceIsFine();

    if (command == COMMAND_SET_AUTH) {
      String? user = params["user"];
      String? realm = deviceScr;
      String? password = params["password"]; // Plain password or null

      if (user == null || realm == null) {
        throw Exception(
            "could not set auth: user or realm is missing, realm: $deviceScr");
      }

      // Compute HA1 hash if password is provided, otherwise null to disable auth
      final ha1 = password != null ? _computeHA1(user, realm, password) : null;

      // Send Shelly.SetAuth command with user, realm, and computed ha1
      final ret = await connectionService?.sendCommand('Shelly.SetAuth', {
        "user": user,
        "realm": realm,
        "ha1": ha1,
      });

      //worked correct now change password in config
      if (password != null) {
        authPassword = password;
        authUsername = user;
        await DeviceStorageService().saveDevice(this);
      }

      connectionService?.resetAuthCache();
      (data["config"] as Map<String, dynamic>)["auth_en"] = password != null;

      return ret;
    }

    // Delegate all other commands to implementation
    return await deviceImpl.sendCommand(connectionService, command, params);
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      ...fetchDataIntervalToJson(),
    };
  }
}

/// Concrete Shelly WiFi device
///
/// Generic Shelly device supporting WiFi/Network connection
class ShellyWifiDevice extends ShellyWifiDeviceTemplate {
  ShellyWifiDevice({
    required super.id,
    required super.name,
    required super.lastSeen,
    required super.deviceSn,
    super.deviceModel,
    super.ipAddress,
    super.port,
    super.hostname,
  }) : super(deviceImpl: ShellyDeviceBaseImplementation()) {
    // Set device reference in implementation for dynamic field generation
    deviceImpl.setDevice(this);
  }

  /// Named constructor for JSON deserialization
  ShellyWifiDevice.fromJsonFields({
    required Map<String, dynamic> json,
    required ShellyDeviceBaseImplementation deviceImpl,
  }) : super.fromJsonFields(json: json, deviceImpl: deviceImpl) {
    // Set device reference in implementation for dynamic field generation
    deviceImpl.setDevice(this);
  }

  /// Factory constructor from JSON
  factory ShellyWifiDevice.fromJson(Map<String, dynamic> json) {
    final impl = ShellyDeviceBaseImplementation();
    final device = ShellyWifiDevice.fromJsonFields(
      json: json,
      deviceImpl: impl,
    );
    device.deserializeWiFi(json); // Handles both WiFi and Auth
    device.fetchDataIntervalFromJson(json, ShellyWifiDeviceTemplate.DEFAULT_FETCH_INTERVAL);
    return device;
  }
}
