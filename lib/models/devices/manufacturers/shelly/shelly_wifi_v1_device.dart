import 'package:the_solar_app/constants/bluetooth_constants.dart';
import 'package:the_solar_app/constants/command_constants.dart';
import 'package:the_solar_app/models/devices/generic_wifi_auth_device.dart';
import 'package:the_solar_app/models/devices/mixins/fetch_data_timeout_mixin.dart';
import 'package:the_solar_app/models/devices/capabilities/device_role_config.dart';
import 'package:the_solar_app/models/devices/capabilities/inverter_capability.dart';
import 'package:the_solar_app/models/devices/capabilities/smart_meter_capability.dart';
import 'package:the_solar_app/models/devices/capabilities/load_capability.dart';
import 'package:the_solar_app/models/devices/generic_rendering/device_category_config.dart';
import 'implementations/shelly_v1_device_implementation.dart';
import 'package:the_solar_app/services/device_storage_service.dart';
import 'package:the_solar_app/services/devices/shelly/shelly_wifi_v1_service.dart';

/// Shelly v1 (Gen1) WiFi device
///
/// Gen1 devices use plain HTTP (no JSON-RPC) and are detected via the
/// /shelly endpoint. Capabilities (relays, meters, emeters, temperature) are
/// derived dynamically from the /status payload, so a single implementation
/// covers Shelly 1 / 1PM / 2PM / 4Pro / EM / 3EM.
class ShellyWifiV1Device extends GenericWiFiAuthDevice<
    ShellyWifiV1Service,
    ShellyV1DeviceImplementation>
    with FetchDataTimeoutMixin,
         DeviceRoleConfig,
         InverterCapability,
         SmartMeterCapability,
         LoadCapability {

  static const Duration DEFAULT_FETCH_INTERVAL = Duration(seconds: 5);

  ShellyWifiV1Device({
    required super.id,
    required super.name,
    required super.lastSeen,
    required super.deviceSn,
    super.deviceModel,
    ShellyV1DeviceImplementation? deviceImpl,
    super.ipAddress,
    super.hostname,
    super.port = 80,
  }) : super(deviceImpl: deviceImpl ?? ShellyV1DeviceImplementation()) {
    fetchDataInterval = DEFAULT_FETCH_INTERVAL;
    authUsername = 'admin';
    fixedUserName = true;
    // Set device reference in implementation for dynamic field generation
    this.deviceImpl.setDevice(this);
  }

  /// Live category configs: derived from the /status payload (emeter count +
  /// total_power) after each data fetch, so phase categories track the device.
  @override
  List<DeviceCategoryConfig> get categoryConfigs => deviceImpl.getCategoryConfigs();

  @override
  List<DeviceRole> getConfigurableRoles() => deviceImpl.getConfigurableRoles();

  @override
  double? getSolarPVPower(Map<String, dynamic> data) => deviceImpl.getSolarPVPower(data);

  @override
  double? getSolarGridPower(Map<String, dynamic> data) => deviceImpl.getSolarGridPower(data);

  @override
  double? getGridPower(Map<String, dynamic> data) => deviceImpl.getGridPower(data);

  @override
  double? getLoadPower(Map<String, dynamic> data) => deviceImpl.getLoadPower(data);

  @override
  String get deviceType => DEVICE_MANUFACTURER_SHELLY_V1;

  @override
  String getManufacturer() => DEVICE_MANUFACTURER_SHELLY_V1;

  @override
  ShellyWifiV1Service createService() {
    return ShellyWifiV1Service(this);
  }

  /// Override sendCommand to handle COMMAND_SET_AUTH which requires device state access
  @override
  Future<Map<String, dynamic>?> sendCommand(
    String command,
    Map<String, dynamic> params,
  ) async {
    assertServiceIsFine();

    if (command == COMMAND_SET_AUTH) {
      final user = params["user"] as String?;
      final password = params["password"] as String?;

      if (user == null || user.isEmpty) {
        throw Exception('could not set auth: username is missing');
      }

      final ret = await connectionService?.sendCommand(
          ShellyWifiV1Service.CMD_SET_AUTH, {'username': user, 'password': password});

      authUsername = user;
      authPassword = (password == null || password.isEmpty) ? null : password;
      await DeviceStorageService().saveDevice(this);

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
      ...roleConfigToJson(),
    };
  }

  /// Factory constructor from JSON
  factory ShellyWifiV1Device.fromJson(Map<String, dynamic> json) {
    final device = ShellyWifiV1Device(
      id: json['id'] as String,
      name: json['name'] as String,
      lastSeen: DateTime.parse(json['lastSeen'] as String),
      deviceSn: json['deviceSn'] as String,
      deviceModel: json['deviceModel'] as String?,
    );
    device.deserializeWiFi(json); // Handles both WiFi and Auth
    device.fetchDataIntervalFromJson(json, DEFAULT_FETCH_INTERVAL);
    device.roleConfigFromJson(json);
    return device;
  }
}
