import 'package:the_solar_app/constants/bluetooth_constants.dart';
import 'package:the_solar_app/constants/command_constants.dart';
import 'package:the_solar_app/models/devices/generic_wifi_auth_device.dart';
import 'package:the_solar_app/models/devices/manufacturers/opendtu/implementations/opendtu_device_implementation.dart';
import 'package:the_solar_app/models/devices/mixins/fetch_data_timeout_mixin.dart';
import 'package:the_solar_app/services/device_storage_service.dart';
import 'package:the_solar_app/services/devices/opendtu/opendtu_wifi_service.dart';

/// OpenDTU device connected via WiFi/Network
class WiFiOpenDTUDevice extends GenericWiFiAuthDevice<
    OpenDTUWifiService,
    OpenDTUDeviceImplementation> with FetchDataTimeoutMixin {

  static const Duration DEFAULT_FETCH_INTERVAL = Duration(seconds: 30);
  WiFiOpenDTUDevice({
    required super.id,
    required super.name,
    required super.lastSeen,
    required super.deviceSn,
    super.ipAddress,
    super.hostname,
    super.port = 80,
    super.deviceModel,
  }) : super(deviceImpl: OpenDTUDeviceImplementation()) {
    authUsername = 'admin';
    authPassword = 'openDTU42';
    fetchDataInterval = DEFAULT_FETCH_INTERVAL;
  }

  /// Named constructor for JSON deserialization
  WiFiOpenDTUDevice.fromJsonFields({
    required Map<String, dynamic> json,
    required OpenDTUDeviceImplementation deviceImpl,
  }) : super.fromJsonFields(json: json, deviceImpl: deviceImpl);

  @override
  String get deviceType => DEVICE_MANUFACTURER_OPENDTU;

  @override
  OpenDTUWifiService createService() {
    return OpenDTUWifiService(this);
  }

  /// Override sendCommand to handle COMMAND_SET_AUTH which requires device state
  @override
  Future<Map<String, dynamic>?> sendCommand(
    String command,
    Map<String, dynamic> params,
  ) async {
    assertServiceIsFine();

    if (command == COMMAND_SET_AUTH) {
      // Set or disable authentication (requires device state access)
      String? password = params['password'] ?? authPassword ?? "openDTU42";

      final Map<String, dynamic> payload = {
        'password': password,
        'allow_readonly': params['password'] != null,
      };

      await connectionService?.sendCommand('/api/security/config', payload);

      // Update local credentials
      authUsername = 'admin';
      authPassword = password;

      // Save to persistent storage
      await DeviceStorageService().saveDevice(this);

      // Reconnect WebSocket with new credentials
      if (connectionService != null) {
        await connectionService!.disconnect();
        await connectionService!.connect();
      }

      return {'success': true};
    }

    // Delegate all other commands to implementation
    return await deviceImpl.sendCommand(connectionService, command, params);
  }

  /// Factory constructor from JSON
  factory WiFiOpenDTUDevice.fromJson(Map<String, dynamic> json) {
    final device = WiFiOpenDTUDevice.fromJsonFields(
      json: json,
      deviceImpl: OpenDTUDeviceImplementation(),
    );
    device.deserializeWiFi(json); // Handles both WiFi and Auth
    device.fetchDataIntervalFromJson(json, DEFAULT_FETCH_INTERVAL);
    return device;
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      ...fetchDataIntervalToJson(),
    };
  }
}
