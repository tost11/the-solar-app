import 'package:the_solar_app/constants/bluetooth_constants.dart';
import 'package:the_solar_app/models/devices/manufacturers/kostal/implementations/kostal_device_implementation.dart';
import 'package:the_solar_app/models/devices/generic_wifi_device.dart';
import 'package:the_solar_app/models/devices/mixins/additional_port_mixin.dart';
import 'package:the_solar_app/models/devices/mixins/fetch_data_timeout_mixin.dart';
import 'package:the_solar_app/services/devices/kostal/kostal_wifi_service.dart';

import '../../../../services/devices/kostal/kostal_modbus_connection.dart';

/// Kostal solar inverter device connected via WiFi/Network
///
/// Supports Kostal Plenticore and compatible inverters via Modbus TCP on port 1502
class WiFiKostalDevice extends GenericWiFiDevice<KostalWifiService, KostalDeviceImplementation> with AdditionalPortMixin, FetchDataTimeoutMixin{

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
  KostalWifiService createService() {
    return KostalWifiService(this);
  }

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json.addAll(additionalPortToJson());
    json.addAll(fetchDataIntervalToJson());
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
    return device;
  }
}
