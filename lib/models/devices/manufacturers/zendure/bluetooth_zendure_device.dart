import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:the_solar_app/constants/bluetooth_constants.dart';
import 'package:the_solar_app/models/devices/generic_bluetooth_device.dart';
import 'package:the_solar_app/models/devices/manufacturers/zendure/implementations/bluetooth_zendure_device_implementation.dart';
import '../../../../constants/command_constants.dart';
import '../../../../services/devices/zendure/zendure_bluetooth_service.dart';
import '../../../../utils/map_utils.dart';
import '../../../../utils/utils.dart';

const int ZENDURE_FIRMWARE_OLD_VERSION = 4367;

/// Zendure device connected via Bluetooth Low Energy
class BluetoothZendureDevice extends GenericBluetoothDevice<
    ZendureBluetoothService,
    BluetoothZendureDeviceImplementation> {
  BluetoothZendureDevice({
    required super.id,
    required super.name,
    required super.lastSeen,
    required super.deviceSn,
    String? deviceModel,
  }) : super(deviceImpl: BluetoothZendureDeviceImplementation()) {
    this.deviceModel = deviceModel;
  }

  /// Named constructor for JSON deserialization
  BluetoothZendureDevice.fromJsonFields({
    required Map<String, dynamic> json,
    required BluetoothZendureDeviceImplementation deviceImpl,
  }) : super.fromJsonFields(json: json, deviceImpl: deviceImpl);

  @override
  String get deviceType => DEVICE_MANUFACTURER_ZENDURE;

  @override
  ZendureBluetoothService createService(BluetoothDevice device) {
    return ZendureBluetoothService(device: this, bluetoothDvice: device);
  }

  /// Override sendCommand to handle Bluetooth-specific WiFi configuration
  @override
  Future<Map<String, dynamic>?> sendCommand(
    String command,
    Map<String, dynamic> params,
  ) async {
    assertServiceIsFine();

    if (command == COMMAND_SET_WIFI_MQTT) {
      String? ssid = params["ssid"];
      String? password = params["password"];
      String? mqtt = params["mqtt"];

      if (ssid == null || password == null || mqtt == null) {
        throw Exception("could not config wifi password or ssid missing");
      }

      int? firmware = MapUtils.OM(data, ["firmwares", "MASTER"]) as int?;
      if (firmware == null) {
        throw Exception("could not set wifi current firmware is unknown");
      }

      var wifiParams = {
        'iotUrl': mqtt,
        'messageId': 1002,
        'method': 'token',
        'password': password,
        'ssid': ssid,
        'timeZone': 'GMT+01:00',
        'token': Utils.generateRandomToken(16),
      };
      await connectionService?.sendPlainCommand(wifiParams);
      if (firmware < ZENDURE_FIRMWARE_OLD_VERSION) {
        //old firmwares need that
        await connectionService?.sendPlainCommand(
            {"messageId": "1003", "method": "station"});
      }
      return null;
    }else if (command == COMMAND_SET_WIFI) {
      throw Exception("Not implemented yet");
    }else if (command == COMMAND_SET_MQTT) {
      throw Exception("Not implemented yet");
    }

    // Delegate all other commands to implementation
    return await deviceImpl.sendCommand(connectionService, command, params);
  }

  /// Factory constructor from JSON
  factory BluetoothZendureDevice.fromJson(Map<String, dynamic> json) {
    return BluetoothZendureDevice.fromJsonFields(
      json: json,
      deviceImpl: BluetoothZendureDeviceImplementation(),
    );
  }
}
