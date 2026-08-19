import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:the_solar_app/constants/bluetooth_constants.dart';
import 'package:the_solar_app/constants/command_constants.dart';
import 'package:the_solar_app/models/devices/capabilities/inverter_capability.dart';
import 'package:the_solar_app/models/devices/generic_bluetooth_device.dart';
import 'package:the_solar_app/models/devices/mixins/device_authentication_mixin.dart';
import 'package:the_solar_app/models/devices/mixins/fetch_data_timeout_mixin.dart';

import 'package:the_solar_app/services/devices/hoymiles/hoymiles_bluetooth_service.dart';
import 'package:the_solar_app/services/devices/hoymiles/hoymiles_command_helper.dart';
import 'package:the_solar_app/utils/map_utils.dart';
import '../../capabilities/device_role_config.dart';
import 'implementations/hoymiles_inverter_implementation.dart';

/// Hoymiles HMS-WB (HiFlow Pro) Bluetooth inverter device.
///
/// Connects to HMS-WB series inverters via Bluetooth Low Energy using
/// the Hoymiles BLE protocol with AES-128-CBC/GCM encryption.
///
/// Uses [DeviceAuthenticationMixin] to store the BLE PIN:
/// - `authUsername` = 'admin' (fixed, not editable)
/// - `authPassword` = BLE PIN (default: '12345678')
///
/// Stores `encRand` (16-byte device secret extracted during V0 pairing)
/// persistently to avoid re-pairing on reconnect.
class HoymilesBluetoothDevice extends GenericBluetoothDevice<
    HoymilesBluetoothService,
    HoymilesInverterImplementation>
    with DeviceAuthenticationMixin, FetchDataTimeoutMixin, DeviceRoleConfig, InverterCapability {

  static const Duration _defaultFetchInterval = Duration(seconds: 31);

  /// Encrypted random key extracted during V0 BLE pairing.
  /// Stored as hex string (32 chars = 16 bytes).
  /// If null, pairing will be performed on next connect.
  String? encRand;

  /// BLE identity string used in the CommCmd handshake.
  /// Once whitelisted on the device, reusing this avoids PIN re-entry.
  /// Generated once and persisted across sessions.
  String? bleId;

  /// The actual inverter serial number extracted from BLE advertised name "RMI-{serial}".
  /// Used for V0 encryption key derivation (AES-CBC key = tripleSHA256(serial + salt)).
  /// Example: "4161A02AD21D"
  final String inverterSerial;

  HoymilesBluetoothDevice({
    required super.id,
    required super.name,
    required super.lastSeen,
    required super.deviceSn,
    required this.inverterSerial,
    super.deviceModel,
    this.encRand,
    this.bleId,
    String? pin,
  }) : super(deviceImpl: HoymilesInverterImplementation()) {
    // Auth mixin: store PIN as password with fixed admin username
    fixedUserName = true;
    authUsername = 'admin';
    authPassword = pin ?? HOYMILES_BLE_DEFAULT_PIN;
    fetchDataInterval = _defaultFetchInterval;

    // Menu items: all inverter menus (Device Info, WiFi Config, Power Limit,
    // Control) plus BLE-specific Authentication for PIN management.
    menuItems = [
      ...deviceImpl.getMenuItems(),
      HoymilesInverterImplementation.buildAuthenticationMenuItem(),
    ];
  }

  @override
  String get deviceType => DEVICE_MANUFACTURER_HOYMILES;

  @override
  String getManufacturer() => DEVICE_MANUFACTURER_HOYMILES;

  @override
  HoymilesBluetoothService createService(BluetoothDevice device) {
    return HoymilesBluetoothService(this, device);
  }

  /// Override sendCommand for BLE — delegates to BLE service methods.
  /// Uses [HoymilesCommandHelper] for response formatting (same as WiFi).
  @override
  Future<Map<String, dynamic>?> sendCommand(
    String command,
    Map<String, dynamic> params,
  ) async {
    assertServiceIsFine();
    final service = connectionService as HoymilesBluetoothService;

    if (command == COMMAND_FETCH_DATA) {
      return await service.getRealDataNew();
    } else if (command == COMMAND_FETCH_SYS_CONFIG) {
      return await service.getConfig();
    } else if (command == COMMAND_FETCH_WIFI_CONFIG) {
      return await service.getNetworkInfo();
    } else if (command == COMMAND_FETCH_DEVICE_INFO) {
      final flatData = await service.getDeviceInformation();
      if (flatData == null) return null;
      return HoymilesCommandHelper.organizeDeviceInfo(flatData);
    } else if (command == COMMAND_SET_LIMIT) {
      final limit = params['limit'] as int?;
      if (limit == null) throw Exception('limit parameter required (0-100)');
      await service.setPowerLimit(limit);
      return {'success': true, 'limit': limit};
    } else if (command == COMMAND_SET_WIFI) {
      final ssid = params['ssid'] as String;
      final password = params['password'] as String;
      await service.setWifiConfig(ssid, password);
      return {'success': true};
    } else if (command == COMMAND_RESTART) {
      await service.restartDtu();
      return {'success': true};
    } else if (command == COMMAND_RESTART_INVERTER) {
      final serial = (params['inverterSerial'] as String?) ?? inverterSerial;
      await service.rebootInverter(serial);
      return {'success': true};
    } else if (command == COMMAND_TURN_ON_INVERTER) {
      final serial = (params['inverterSerial'] as String?) ?? inverterSerial;
      await service.turnOnInverter(serial);
      return {'success': true};
    } else if (command == COMMAND_TURN_OFF_INVERTER) {
      final serial = (params['inverterSerial'] as String?) ?? inverterSerial;
      await service.turnOffInverter(serial);
      return {'success': true};
    } else if (command == COMMAND_FETCH_HIST_POWER) {
      return await service.getHistPower();
    } else if (command == COMMAND_FETCH_HIST_ENERGY) {
      return await service.getHistEnergy();
    } else if (command == COMMAND_SET_AUTH) {
      // this command is not documented yet (need to find out id)
      // TODO: enable when implemented
      return {'success': false};

      //TODO enable this if implmented
      /*final password = params['password'] as String?;
      authUsername = 'admin';
      authPassword = (password == null || password.isEmpty)
          ? HOYMILES_BLE_DEFAULT_PIN
          : password;
      await DeviceStorageService().saveDevice(this);
      // Drop the connection; BaseDeviceService / detail screen re-establishes
      // it, re-running the handshake with the updated PIN.
      await connectionService?.disconnect();
      return {'success': true};*/
    }
    throw UnimplementedError('Command "$command" not supported over Bluetooth');
  }

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json.addAll(authToJson());
    json.addAll(fetchDataIntervalToJson());
    json['inverterSerial'] = inverterSerial;
    if (encRand != null) {
      json['encRand'] = encRand;
    }
    if (bleId != null) {
      json['bleId'] = bleId;
    }
    return json;
  }

  factory HoymilesBluetoothDevice.fromJson(Map<String, dynamic> json) {
    final device = HoymilesBluetoothDevice(
      id: json['id'] as String,
      name: json['name'] as String,
      lastSeen: DateTime.parse(json['lastSeen'] as String),
      deviceSn: json['deviceSn'] as String,
      inverterSerial: json['inverterSerial'] as String? ?? json['deviceSn'] as String,
      deviceModel: json['deviceModel'] as String?,
      encRand: json['encRand'] as String?,
      bleId: json['bleId'] as String?,
    );

    device.authFromJson(json);
    device.fetchDataIntervalFromJson(json, _defaultFetchInterval);

    return device;
  }

  @override
  List<DeviceRole> getFixedRoles() => [
    DeviceRole.inverter,
  ];

  @override
  double? getSolarPVPower(Map<String, dynamic> data) {
    final value = MapUtils.OM(data, ['data', 'inverter', 'pv', 'power']);
    if (value == null) return null;
    return (value as num).toDouble();
  }

  @override
  double? getSolarGridPower(Map<String, dynamic> data) {
    final value = MapUtils.OM(data, ['data', 'inverter', 'sgs', 'active_power']);
    if (value == null) return null;
    return (value as num).toDouble();
  }
}
