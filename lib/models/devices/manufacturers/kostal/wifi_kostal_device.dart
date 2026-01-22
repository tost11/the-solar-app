import 'package:the_solar_app/constants/bluetooth_constants.dart';
import 'package:the_solar_app/models/devices/capabilities/battery_capability.dart';
import 'package:the_solar_app/models/devices/capabilities/device_role_config.dart';
import 'package:the_solar_app/models/devices/capabilities/inverter_capability.dart';
import 'package:the_solar_app/models/devices/capabilities/smart_meter_capability.dart';
import 'package:the_solar_app/models/devices/manufacturers/kostal/implementations/kostal_device_implementation.dart';
import 'package:the_solar_app/models/devices/generic_wifi_device.dart';
import 'package:the_solar_app/models/devices/mixins/additional_port_mixin.dart';
import 'package:the_solar_app/models/devices/mixins/fetch_data_timeout_mixin.dart';
import 'package:the_solar_app/services/devices/kostal/kostal_wifi_service.dart';
import 'package:the_solar_app/utils/map_utils.dart';

import '../../../../services/devices/kostal/kostal_modbus_connection.dart';

/// Kostal solar inverter device connected via WiFi/Network
///
/// Supports Kostal Plenticore and compatible inverters via Modbus TCP on port 1502
///
/// Fixed roles: Inverter + Battery + SmartMeter
/// Kostal devices provide solar production, battery storage, and grid power measurement.
class WiFiKostalDevice extends GenericWiFiDevice<KostalWifiService, KostalDeviceImplementation>
    with AdditionalPortMixin, FetchDataTimeoutMixin, InverterCapability, BatteryCapability, SmartMeterCapability, DeviceRoleConfig {

  static const Duration DEFAULT_FETCH_INTERVAL = Duration(seconds: 20);

  WiFiKostalDevice({
    required super.id,
    required super.name,
    required super.lastSeen,
    required super.deviceSn,
    String? ipAddress,
    String? hostname,
    int? port = 1502,  // Kostal default Modbus TCP port
    super.deviceModel,
    int? modbusPort,
  }) : super(deviceImpl: KostalDeviceImplementation()) {
    netPort = port;
    netHostname = hostname;
    netIpAddress = ipAddress;
    additionalPort = modbusPort ?? KostalModbusConnection.DEFAULT_PORT;
    fetchDataInterval = DEFAULT_FETCH_INTERVAL;
  }

  /// Named constructor for JSON deserialization
  WiFiKostalDevice.fromJsonFields({
    required Map<String, dynamic> json,
    required KostalDeviceImplementation deviceImpl,
  }) : super.fromJsonFields(json: json, deviceImpl: deviceImpl);

  @override
  String get deviceType => DEVICE_MANUFACTURER_KOSTAL;

  @override
  String getManufacturer() => DEVICE_MANUFACTURER_KOSTAL;

  @override
  KostalWifiService createService() {
    return KostalWifiService(this);
  }

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json.addAll(additionalPortToJson());
    json.addAll(fetchDataIntervalToJson());
    json.addAll(roleConfigToJson());
    return json;
  }

  /// Factory constructor from JSON
  factory WiFiKostalDevice.fromJson(Map<String, dynamic> json) {
    final device = WiFiKostalDevice.fromJsonFields(
      json: json,
      deviceImpl: KostalDeviceImplementation(),
    );
    device.deserializeWiFi(json);
    device.additionalPortFromJson(json,KostalModbusConnection.DEFAULT_PORT);
    device.fetchDataIntervalFromJson(json, DEFAULT_FETCH_INTERVAL);
    device.roleConfigFromJson(json);
    return device;
  }

  // ===== DeviceRoleConfig implementation =====

  @override
  List<DeviceRole> getFixedRoles() => [
        DeviceRole.inverter,
        DeviceRole.battery,
        DeviceRole.smartMeter,
      ];

  // ===== InverterCapability implementation =====

  @override
  double? getSolarPVPower(Map<String, dynamic> data) {
    final value = MapUtils.OM(data, ['data', 'dc_power_total']);
    if (value == null) return null;
    return (value as num).toDouble();
  }

  @override
  double? getSolarGridPower(Map<String, dynamic> data) {
    //TODO make better
    final value = MapUtils.OM(data, ['data', 'dc_power_total']);
    if (value == null) return null;
    return (value as num).toDouble();
  }

  // ===== BatteryCapability implementation =====

  @override
  double? getBatteryPower(Map<String, dynamic> data) {
    final value = MapUtils.OM(data, ['data', 'battery_charge_discharge_power']);
    if (value == null) return null;
    return (value as num).toDouble();
  }

  @override
  double? getBatterySOC(Map<String, dynamic> data) {
    // Try battery_soc first, fallback to battery_soc_actual
    final soc = MapUtils.OM(data, ['data', 'battery_soc']) ??
                MapUtils.OM(data, ['data', 'battery_soc_actual']);
    if (soc == null) return null;
    return (soc as num).toDouble();
  }

  // ===== SmartMeterCapability implementation =====

  @override
  double? getGridPower(Map<String, dynamic> data) {
    final value = MapUtils.OM(data, ['data', 'consumption_grid']);
    if (value == null) return null;
    return (value as num).toDouble();
  }
}
