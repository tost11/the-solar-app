import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:the_solar_app/constants/bluetooth_constants.dart';
import 'package:the_solar_app/models/devices/capabilities/battery_capability.dart';
import 'package:the_solar_app/models/devices/capabilities/device_role_config.dart';
import 'package:the_solar_app/models/devices/capabilities/inverter_capability.dart';
import 'package:the_solar_app/models/devices/capabilities/load_capability.dart';
import 'package:the_solar_app/models/devices/generic_bluetooth_device.dart';
import 'package:the_solar_app/models/devices/manufacturers/zendure/implementations/bluetooth_zendure_device_implementation.dart';
import '../../../../constants/command_constants.dart';
import '../../../../services/devices/zendure/zendure_bluetooth_service.dart';
import '../../../../utils/map_utils.dart';
import '../../../../utils/utils.dart';

const int ZENDURE_FIRMWARE_OLD_VERSION = 4367;

/// Zendure device connected via Bluetooth Low Energy
///
/// Fixed roles: Inverter + Battery
/// Zendure devices always act as both solar inverter and battery storage.
class BluetoothZendureDevice extends GenericBluetoothDevice<
    ZendureBluetoothService,
    BluetoothZendureDeviceImplementation>
    with InverterCapability, BatteryCapability, DeviceRoleConfig, LoadCapability {
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
      String? ssid = params["ssid"];
      String? password = params["password"];

      if (ssid == null || password == null ) {
        throw Exception("could not config wifi password or ssid missing");
      }

      var wifiParams = {
        'messageId': 1002,
        'method': 'token',
        'password': password,
        'ssid': ssid,
        'timeZone': 'GMT+01:00',
        'token': Utils.generateRandomToken(16),
      };
      await connectionService?.sendPlainCommand(wifiParams);
      return null;
    }else if (command == COMMAND_SET_MQTT) {
      throw Exception("Not implemented yet");
    }

    // Delegate all other commands to implementation
    return await deviceImpl.sendCommand(connectionService, command, params);
  }

  /// Factory constructor from JSON
  factory BluetoothZendureDevice.fromJson(Map<String, dynamic> json) {
    final device = BluetoothZendureDevice.fromJsonFields(
      json: json,
      deviceImpl: BluetoothZendureDeviceImplementation(),
    );
    device.roleConfigFromJson(json);
    return device;
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      ...roleConfigToJson(),
    };
  }

  // ===== DeviceRoleConfig implementation =====

  @override
  List<DeviceRole> getFixedRoles() => [
        DeviceRole.inverter,
        DeviceRole.battery,
        DeviceRole.load
      ];

  // ===== InverterCapability implementation =====


  // ===== InverterCapability implementation =====

  @override
  double? getSolarPVPower(Map<String, dynamic> data) {
    final value = MapUtils.OM(data, ['data', 'properties', 'solarInputPower']);
    if (value == null) return null;
    return (value as num).toDouble();
  }

  @override
  double? getSolarGridPower(Map<String, dynamic> data) {
    final value = MapUtils.OM(data, ['data', 'properties', 'outputHomePower']);
    if (value == null) return null;
    return (value as num).toDouble();
  }

  @override
  double? getLoadPower(Map<String, dynamic> data) {
    final value = MapUtils.OM(data, ['data', 'properties', 'gridInputPower']);
    if (value == null) return null;
    return (value as num).toDouble();
  }

  // ===== BatteryCapability implementation =====

  @override
  double? getBatteryPower(Map<String, dynamic> data) {
    final input = MapUtils.OM(data, ['data', 'properties', 'outputPackPower']);//needs to be swapped because zendure handle data other way around
    final output = MapUtils.OM(data, ['data', 'properties', 'packInputPower']);//needs to be swapped because zendure handle data other way around
    if (input != null && output != null) {
      // Positive = charging, negative = discharging
      return ((input as num) - (output as num)).toDouble();
    }
    return null;
  }

  @override
  double? getBatterySOC(Map<String, dynamic> data) {
    final value = MapUtils.OM(data, ['data', 'properties', 'electricLevel']);
    if (value == null) return null;
    return (value as num).toDouble();
  }
}
