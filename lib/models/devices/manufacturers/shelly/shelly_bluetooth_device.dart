import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:the_solar_app/constants/bluetooth_constants.dart';
import 'package:the_solar_app/constants/command_constants.dart';
import 'package:the_solar_app/models/devices/generic_bluetooth_device.dart';
import 'package:the_solar_app/models/devices/generic_rendering/device_category_config.dart';
import 'implementations/shelly_device_base_implementation.dart';
import 'package:the_solar_app/services/device_storage_service.dart';
import '../../mixins/device_authentication_mixin.dart';
import '../../mixins/fetch_data_timeout_mixin.dart';
import 'package:the_solar_app/services/devices/shelly/shelly_bluetooth_service.dart';

/// Generic Shelly Bluetooth device template
///
/// Extends GenericBluetoothDevice and adds authentication support
/// Used as base class for specific Shelly Bluetooth device types
class ShellyBluetoothDeviceTemplate extends GenericBluetoothDevice<
    ShellyBluetoothService,
    ShellyDeviceBaseImplementation>
    with DeviceAuthenticationMixin, FetchDataTimeoutMixin {

  static const Duration DEFAULT_FETCH_INTERVAL = Duration(seconds: 10);

  String? deviceScr;

  ShellyBluetoothDeviceTemplate({
    required super.id,
    required super.name,
    required super.lastSeen,
    required super.deviceSn,
    super.deviceModel,
    required super.deviceImpl,
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
  ShellyBluetoothDeviceTemplate.fromJsonFields({
    required Map<String, dynamic> json,
    required ShellyDeviceBaseImplementation deviceImpl,
  }) : super.fromJsonFields(json: json, deviceImpl: deviceImpl);

  @override
  String get deviceType => DEVICE_MANUFACTURER_SHELLY;

  @override
  String getManufacturer() => DEVICE_MANUFACTURER_SHELLY;

  /// Override to compute category configs dynamically
  /// This ensures category configs are updated when device data changes
  @override
  List<DeviceCategoryConfig> get categoryConfigs => deviceImpl.getCategoryConfigs();

  @override
  ShellyBluetoothService createService(BluetoothDevice device) {
    return ShellyBluetoothService(this, device);
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
    final json = super.toJson();
    json.addAll(authToJson());
    json.addAll(fetchDataIntervalToJson());
    return json;
  }
}

/// Concrete Shelly Bluetooth device
///
/// Generic Shelly device supporting Bluetooth connection
class ShellyBluetoothDevice extends ShellyBluetoothDeviceTemplate {
  ShellyBluetoothDevice({
    required super.id,
    required super.name,
    required super.lastSeen,
    required super.deviceSn,
    super.deviceModel,
  }) : super(deviceImpl: ShellyDeviceBaseImplementation()) {
    // Set device reference in implementation for dynamic field generation
    deviceImpl.setDevice(this);
  }

  /// Named constructor for JSON deserialization
  ShellyBluetoothDevice.fromJsonFields({
    required Map<String, dynamic> json,
    required ShellyDeviceBaseImplementation deviceImpl,
  }) : super.fromJsonFields(json: json, deviceImpl: deviceImpl) {
    // Set device reference in implementation for dynamic field generation
    deviceImpl.setDevice(this);
  }

  /// Factory constructor from JSON
  factory ShellyBluetoothDevice.fromJson(Map<String, dynamic> json) {
    final impl = ShellyDeviceBaseImplementation();
    final device = ShellyBluetoothDevice.fromJsonFields(
      json: json,
      deviceImpl: impl,
    );
    device.authFromJson(json);
    device.fetchDataIntervalFromJson(json, ShellyBluetoothDeviceTemplate.DEFAULT_FETCH_INTERVAL);
    return device;
  }
}
