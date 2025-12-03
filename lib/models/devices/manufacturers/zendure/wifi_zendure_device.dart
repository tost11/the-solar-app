import 'package:flutter/cupertino.dart';
import 'package:the_solar_app/constants/bluetooth_constants.dart';
import 'package:the_solar_app/models/devices/generic_wifi_device.dart';
import 'package:the_solar_app/models/devices/manufacturers/zendure/implementations/zendure_device_implementation.dart';
import 'package:the_solar_app/models/devices/mixins/fetch_data_timeout_mixin.dart';
import 'package:the_solar_app/services/devices/zendure/zendure_wifi_service.dart';
import '../../../../constants/command_constants.dart';
import 'implementations/wifi_zendure_device_implementation.dart';

/// Zendure device connected via WiFi/Network
class WiFiZendureDevice extends GenericWiFiDevice<
    ZendureWifiService,
    ZendureDeviceImplementation> with FetchDataTimeoutMixin {

  static const Duration DEFAULT_FETCH_INTERVAL = Duration(seconds: 5);
  WiFiZendureDevice({
    required super.id,
    required super.name,
    required super.lastSeen,
    required super.deviceSn,
    String? ipAddress,
    String? hostname,
    int? port = 80,
    super.deviceModel,
  }) : super(
          deviceImpl: WifiZendureDeviceImplementation(),
          ipAddress: ipAddress,
          hostname: hostname,
          port: port,
        ) {
    fetchDataInterval = DEFAULT_FETCH_INTERVAL;
  }

  /// Named constructor for JSON deserialization
  WiFiZendureDevice.fromJsonFields({
    required Map<String, dynamic> json,
    required ZendureDeviceImplementation deviceImpl,
  }) : super.fromJsonFields(json: json, deviceImpl: deviceImpl);

  @override
  String get deviceType => DEVICE_MANUFACTURER_ZENDURE;

  @override
  ZendureWifiService createService() {
    return ZendureWifiService(this);
  }

  /// Override sendCommand to handle WiFi-specific command variations
  @override
  Future<Map<String, dynamic>?> sendCommand(
    String command,
    Map<String, dynamic> params,
  ) async {
    assertServiceIsFine();

    Map<String, dynamic>? ret;

    if (command == COMMAND_SET_LIMIT) {
      int? acMode = params["acMode"];
      if (acMode == null) {
        throw Exception("on set limit command acMode missing");
      }
      ret = await connectionService?.sendCommand({
        "acMode": acMode,
        "inputLimit": params["inputLimit"],
        "outputLimit": params["outputLimit"]
      });
    } else if (command == COMMAND_BATTERY_LIMITS) {
      // Extract battery limit parameters
      final minSoc = params["minSoc"];
      final maxSoc = params["maxSoc"];

      if (minSoc == null && maxSoc == null) {
        throw Exception("no battery limits provided");
      }

      final commandParams = <String, dynamic>{};
      if (minSoc != null) commandParams["minSoc"] = minSoc * 10;
      if (maxSoc != null) commandParams["socSet"] = maxSoc * 10;

      debugPrint("Zendure wifi set limit params:  $commandParams");

      ret = await connectionService?.sendCommand(commandParams);
    } else if (command == COMMAND_SET_POWER_CONFIG) {

      // Extract power configuration parameters
      final inverseMaxPower = params["inverseMaxPower"];
      final gridReverse = params["gridReverse"];
      final gridStandard = params["gridStandard"];

      if (inverseMaxPower == null &&
          gridReverse == null &&
          gridStandard == null) {
        throw Exception("no power config provided");
      }

      final commandParams = <String, dynamic>{};
      if (inverseMaxPower != null) {
        commandParams["inverseMaxPower"] = inverseMaxPower;
      }
      if (gridReverse != null) commandParams["gridReverse"] = gridReverse;
      if (gridStandard != null) commandParams["gridStandard"] = gridStandard;

      ret = await connectionService?.sendCommand(commandParams);
    } else if (command == COMMAND_SET_MAIN_POWER) {
      var props = <String, dynamic>{};
      props["hubState"] = (params["on"] as bool?) == true ? 1 : 0;
      ret = await connectionService?.sendCommand(props);
    } else {
      // Delegate all other commands to implementation
      return await deviceImpl.sendCommand(connectionService, command, params);
    }
    return ret;
  }

  /// Factory constructor from JSON
  factory WiFiZendureDevice.fromJson(Map<String, dynamic> json) {
    final device = WiFiZendureDevice.fromJsonFields(
      json: json,
      deviceImpl: WifiZendureDeviceImplementation(),
    );
    device.deserializeWiFi(json);
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
