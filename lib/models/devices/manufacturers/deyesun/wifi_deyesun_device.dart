import 'package:the_solar_app/constants/bluetooth_constants.dart';
import 'package:the_solar_app/models/devices/capabilities/inverter_capability.dart';
import '../../../../utils/map_utils.dart';
import '../../capabilities/device_role_config.dart';
import '../../mixins/additional_port_mixin.dart';
import '../../mixins/fetch_data_timeout_mixin.dart';
import 'implementations/deyesun_device_implementation.dart';
import 'package:the_solar_app/models/devices/generic_wifi_auth_device.dart';
import 'package:the_solar_app/services/devices/deyesun/deyesun_modbus_connection.dart';
import 'package:the_solar_app/services/devices/deyesun/deyesun_wifi_service.dart';
import '../../../../constants/command_constants.dart';

/// DeyeSun device connected via WiFi/Network
class WiFiDeyeSunDevice extends GenericWiFiAuthDevice<DeyeSunWifiService, DeyeSunDeviceImplementation> with AdditionalPortMixin, FetchDataTimeoutMixin, InverterCapability, DeviceRoleConfig {

  static const Duration DEFAULT_FETCH_INTERVAL = Duration(seconds: 20);

  WiFiDeyeSunDevice({
    required super.id,
    required super.name,
    required super.lastSeen,
    required super.deviceSn,
    String? ipAddress,
    String? hostname,
    int? port = 80,
    int? modbusPort,
    super.deviceModel,
  }) : super(deviceImpl: DeyeSunDeviceImplementation()) {
    netPort = port;
    netHostname = hostname;
    netIpAddress = ipAddress;
    additionalPort = modbusPort ?? DeyeSunModbusConnection.DEFAULT_PORT;
    fetchDataInterval = DEFAULT_FETCH_INTERVAL;
  }

  /// Named constructor for JSON deserialization
  WiFiDeyeSunDevice.fromJsonFields({
    required super.json,
    required super.deviceImpl,
  }) : super.fromJsonFields();

  @override
  String get deviceType => DEVICE_MANUFACTURER_DEYE_SUN;

  @override
  DeyeSunWifiService createService() {
    return DeyeSunWifiService(this);
  }

  /// Override sendCommand to handle commands requiring device state access
  @override
  Future<Map<String, dynamic>?> sendCommand(
    String command,
    Map<String, dynamic> params,
  ) async {
    assertServiceIsFine();

    if (command == COMMAND_SET_LIMIT) {
      // Set power limit via Modbus
      final limit = params['limit'] as int?;
      if (limit == null) {
        throw Exception('Limit parameter is required');
      }

      final success = await connectionService?.writeModbusPowerLimit(limit);
      final ret = {'success': success == true};

      if (success != true) {
        throw Exception('Failed to set power limit via Modbus');
      }

      // Update local data field with new limit value
      if (data['data'] == null) {
        data['data'] = <String, dynamic>{};
      }
      (data['data'] as Map<String, dynamic>)['limit_percentage'] = limit;

      // Emit updated data to trigger UI refresh
      emitData(data['data'] as Map<String, dynamic>);

      return ret;
    } else if (command == COMMAND_SET_MAIN_POWER) {
      // Set power status (on/off) via Modbus
      final on = params['on'] as bool?;
      if (on == null) {
        throw Exception('On parameter is required');
      }

      final success = await connectionService?.writeModbusPowerStatus(on);
      final ret = {'success': success == true};

      if (success != true) {
        throw Exception('Failed to set power status via Modbus');
      }

      // Update local data field with new status value
      if (data['data'] == null) {
        data['data'] = <String, dynamic>{};
      }
      (data['data'] as Map<String, dynamic>)['limit_status'] = on ? 1 : 2;

      // Emit updated data to trigger UI refresh
      emitData(data['data'] as Map<String, dynamic>);

      return ret;
    } else if (command == COMMAND_SET_WIFI) {
      // Extract parameters
      final ssid = params['ssid'] as String?;
      final password = params['password'] as String?;

      if (ssid == null || password == null) {
        throw Exception('SSID and password are required');
      }

      // Build form data matching DeyeSun API
      final formData = {
        'sta_setting_ssid': ssid,
        'sta_setting_wpakey': password,
        'sta_setting_auth': 'WPA2PSK',
        'sta_setting_encry': 'AES',
        'sta_setting_auth_sel': 'WPA2PSK',
        'sta_setting_encry_sel': 'AES',
        'wifi_mode': 'STA',
        'wan_setting_dhcp': 'DHCP'
      };

      await connectionService?.sendCommand('do_step_neth', 'wireless', formData);

      await sendCommand(COMMAND_RESTART, {});

      return {'success': true};
    } else if (command == COMMAND_SET_AP_CONFIG) {
      // Extract parameters
      final ssid = params['ssid'] as String?;
      final password = params['password'] as String?;
      final isOpen = params['isOpen'] as bool?;
      final enable = params['enable'] as bool?;

      // 1. Set SSID and security configuration in one call
      final Map<String, String> combinedFormData = {};

      // Add SSID parameters if provided
      if (ssid != null && ssid.isNotEmpty) {
        combinedFormData.addAll({
          'ap_setting_net_mode': '11bgn',
          'ap_setting_net_mode_sel': '2',
          'ap_setting_ssid': ssid,
          'ap_setting_freq': '0',
        });
      }

      // Add security parameters
      if (isOpen == true) {
        // Open network
        combinedFormData.addAll({
          'ap_setting_auth': 'OPEN',
          'ap_setting_encryp': 'NONE',
          'ap_setting_auth_sel': 'CLOSE',
          'name_ap_setting_encryp': 'on',
        });
      } else {
        // Secured network with password
        if (password == null || password.isEmpty) {
          throw Exception('Password is required for secured network');
        }
        combinedFormData.addAll({
          'ap_setting_auth': 'WPA2PSK',
          'ap_setting_encryp': 'AES',
          'ap_setting_auth_sel': 'WPA2PSK',
          'name_ap_setting_encryp': 'on',
          'ap_setting_wpakey': password,
        });
      }

      // Send combined SSID + security configuration
      final configResult = await connectionService?.sendCommand(
        'do_cmd',
        'wirepoint',
        combinedFormData,
      );

      if (configResult == null) {
        return null; // Failed to set AP configuration
      }

      // 2. Enable/Disable AP if specified
      if (enable != null) {
        final enableValue = enable ? '0' : '1';
        final enableResult = await connectionService?.sendCommand(
          'do_cmd',
          'hide_set_edit',
          {
            'apsta_mode': enableValue,
            'mode_sel': enableValue,
          },
        );

        if (enableResult == null) {
          return null; // Failed to set enable state
        }
      }

      await sendCommand(COMMAND_RESTART, {});

      return {'success': true};
    }

    // Delegate all other commands to implementation
    return await deviceImpl.sendCommand(connectionService, command, params);
  }

  /// Factory constructor from JSON
  factory WiFiDeyeSunDevice.fromJson(Map<String, dynamic> json) {
    final device = WiFiDeyeSunDevice.fromJsonFields(
      json: json,
      deviceImpl: DeyeSunDeviceImplementation(),
    );
    device.deserializeWiFi(json); // Handles both WiFi and Auth
    device.additionalPortFromJson(json,DeyeSunModbusConnection.DEFAULT_PORT);
    device.fetchDataIntervalFromJson(json, DEFAULT_FETCH_INTERVAL);
    return device;
  }

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json.addAll(additionalPortToJson());
    json.addAll(fetchDataIntervalToJson());
    return json;
  }

  @override
  List<DeviceRole> getFixedRoles() => [
    DeviceRole.inverter
  ];

  @override
  double? getSolarPVPower(Map<String, dynamic> data) {
    final value = MapUtils.OM(data, ['config', 'webdata_now_p']);
    if (value == null) return null;
    return (value as num).toDouble();
  }

  @override
  double? getSolarGridPower(Map<String, dynamic> data) {
    final value = MapUtils.OM(data, ['data', 'dc_total_power']);//this is not correct but other value is always more so it looks good (maby naming from soruce lib wrong)
    if (value == null) return null;
    return (value as num).toDouble();
  }

}
