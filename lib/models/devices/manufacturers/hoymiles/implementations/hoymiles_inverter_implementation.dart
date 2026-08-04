import 'package:flutter/material.dart';
import 'package:the_solar_app/constants/command_constants.dart';
import 'package:the_solar_app/constants/translation_keys.dart';
import 'package:the_solar_app/models/to.dart';
import 'package:the_solar_app/screens/configuration/authentication_screen.dart';
import 'package:the_solar_app/screens/configuration/hoymiles_control_screen.dart';
import 'package:the_solar_app/screens/configuration/hoymiles_history_screen.dart';
import 'package:the_solar_app/screens/configuration/percentage_power_limit_screen.dart';
import 'package:the_solar_app/screens/configuration/wifi_configuration_screen.dart';
import 'package:the_solar_app/screens/device_info_screen.dart';
import 'package:the_solar_app/models/devices/manufacturers/hoymiles/hoymiles_bluetooth_device.dart';
import 'package:the_solar_app/utils/dialog_utils.dart';
import 'package:the_solar_app/utils/localization_extension.dart';
import 'package:the_solar_app/utils/map_utils.dart';
import 'package:the_solar_app/utils/message_utils.dart';
import 'package:the_solar_app/utils/navigation_utils.dart';
import '../../../device_implementation.dart';
import '../../../device_base.dart';
import '../../../generic_rendering/device_category_config.dart';
import '../../../generic_rendering/device_data_field.dart';
import '../../../generic_rendering/device_menu_item.dart';
import '../../../time_series_field_config.dart';
import '../../../../../services/devices/hoymiles/hoymiles_command_helper.dart';
import '../../../../../services/devices/hoymiles/hoymiles_wifi_service.dart';

/// Shared implementation for Hoymiles HMS inverter devices (WiFi and BLE).
///
/// Provides data fields, menu items, time series configs, and command handling
/// shared between WiFi and Bluetooth device variants.
class HoymilesInverterImplementation extends DeviceImplementation {

  @override
  List<DeviceMenuItem> getMenuItems() => [
    DeviceMenuItem(
      name: TO(key: MenuTranslationKeys.deviceInfo),
      subtitle: TO(key: MenuSubtitleKeys.deviceInfoSubtitle),
      icon: Icons.info_outline,
      iconColor: Colors.blue,
      onTap: (ctx) async {
        final context = ctx.context;
        final device = ctx.device;

        final info = await DialogUtils.executeWithLoading(
          context,
          loadingMessage: context.l10n.loadingDeviceInfo,
          operation: () => device.sendCommand(COMMAND_FETCH_DEVICE_INFO, {}),
          onError: (e) => MessageUtils.showError(context, '${context.l10n.error}: $e'),
        );

        if (info != null && context.mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DeviceInfoScreen(data: info),
            ),
          );
        }
      },
    ),
    DeviceMenuItem(
      name: TO(key: MenuTranslationKeys.wifiConfiguration),
      subtitle: TO(key: MenuSubtitleKeys.wifiConfigurationSubtitle),
      icon: Icons.wifi,
      iconColor: Colors.green,
      onTap: (ctx) async {
        final context = ctx.context;
        final device = ctx.device;

        final wifiConfig = await DialogUtils.executeWithLoading(
          context,
          loadingMessage: context.l10n.loadingConfiguration,
          operation: () => device.sendCommand(COMMAND_FETCH_SYS_CONFIG, {}),
          onError: (e) => MessageUtils.showError(context, context.l10n.errorLoadingConfiguration(e.toString())),
        );

        if (wifiConfig == null || !context.mounted) return;

        final currentSsid = wifiConfig['wifiSsid'] as String?;

        final result = await NavigationUtils.pushConfigurationScreen(
          context,
          WiFiConfigurationScreen(
            device: device,
            currentSsid: currentSsid,
          ),
        );

        if (result == true) {
          MessageUtils.showSuccess(context, context.l10n.wifiConfigurationCompleted);
        }
      },
    ),
    DeviceMenuItem(
      name: TO(key: MenuTranslationKeys.powerLimit),
      subtitle: TO(key: MenuSubtitleKeys.powerLimitSubtitle),
      icon: Icons.speed,
      iconColor: Colors.orange,
      onTap: (ctx) async {
        final context = ctx.context;
        final device = ctx.device;

        final config = await DialogUtils.executeWithLoading(
          context,
          loadingMessage: context.l10n.loadingConfiguration,
          operation: () => device.sendCommand(COMMAND_FETCH_SYS_CONFIG, {}),
          onError: (e) => MessageUtils.showError(context, context.l10n.errorLoadingConfiguration(e.toString())),
        );

        if (config == null || !context.mounted) return;

        final currentLimit = config['power_limit_percent'] as int;

        var powerRating = MapUtils.OM(device.data, ['data', 'inverter', 'sgs', 'power_rating']) as int?;

        final result = await NavigationUtils.pushConfigurationScreen(
          context,
          PercentagePowerLimitScreen(
            device: device,
            currentLimit: currentLimit,
            totalPower: powerRating,
          ),
        );

        if (result == true && context.mounted) {
          MessageUtils.showSuccess(context, context.l10n.powerLimitSet);
        }
      },
    ),
    DeviceMenuItem(
      name: TO(key: MenuTranslationKeys.deviceControl),
      subtitle: TO(key: MenuSubtitleKeys.deviceControlSubtitle),
      icon: Icons.settings_remote,
      iconColor: Colors.deepOrange,
      onTap: (ctx) async {
        final context = ctx.context;
        final device = ctx.device;

        await NavigationUtils.pushConfigurationScreen(
          context,
          HoymilesControlScreen(
            device: device,
            inverterSerial: resolveInverterSerial(device),
          ),
        );
      },
    ),
    DeviceMenuItem(
      name: TO(key: MenuTranslationKeys.deviceHistory),
      subtitle: TO(key: MenuSubtitleKeys.deviceHistorySubtitle),
      icon: Icons.show_chart,
      iconColor: Colors.indigo,
      onTap: (ctx) async {
        final context = ctx.context;
        final device = ctx.device;

        await NavigationUtils.pushConfigurationScreen(
          context,
          HoymilesHistoryScreen(
            device: device,
            inverterSerial: resolveInverterSerial(device),
          ),
        );
      },
    ),
  ];

  /// Resolve the inverter serial (hex string) for control commands.
  ///
  /// BLE devices expose it directly; for WiFi devices we derive it from the
  /// live data (`device_serial_number`).
  static String? resolveInverterSerial(DeviceBase device) {
    if (device is HoymilesBluetoothDevice) {
      return device.inverterSerial;
    }
    final sn = MapUtils.OM(device.data, ['data', 'device_serial_number']);
    if (sn is String && sn.isNotEmpty) return sn;
    return null;
  }

  /// Menu item for managing the BLE connection PIN (submitted during handshake).
  /// Only relevant for [HoymilesBluetoothDevice].
  static DeviceMenuItem buildAuthenticationMenuItem() {
    return DeviceMenuItem(
      name: TO(key: MenuTranslationKeys.authentication),
      subtitle: TO(key: MenuSubtitleKeys.authenticationSubtitle),
      icon: Icons.lock,
      iconColor: Colors.orange,
      onTap: (ctx) async {
        final context = ctx.context;
        final device = ctx.device as HoymilesBluetoothDevice;

        await NavigationUtils.pushConfigurationScreen(
          context,
          AuthenticationScreen(
            device: device,
            currentUsername: 'admin',
            currentPassword: device.authPassword,
            currentEnabled: true,
            usernameEditable: false,
            showEnableToggle: false,
          ),
        );
      },
    );
  }

  @override
  List<DeviceDataField> getDataFields() => [
    DeviceDataField(
      name: TO(key: FieldTranslationKeys.currentPower),
      type: DataFieldType.watt,
      valueExtractor: (data) =>
          MapUtils.OM(data, ['data', 'inverter', 'sgs', 'active_power']),
      icon: Icons.bolt,
      expertMode: false,
    ),
    DeviceDataField(
      name: TO(key: FieldTranslationKeys.currentPvPower),
      type: DataFieldType.watt,
      valueExtractor: (data) =>
          MapUtils.OM(data, ['data', 'inverter', 'pv', 'power']),
      icon: Icons.bolt,
      expertMode: false,
    ),
    DeviceDataField(
      name: TO(key: FieldTranslationKeys.dailyYield),
      type: DataFieldType.energy,
      valueExtractor: (data) => MapUtils.OM(data, ['data', 'dtu_daily_energy']),
      icon: Icons.wb_sunny,
      expertMode: false,
      precision: 2,
    ),
    DeviceDataField(
      name: TO(key: FieldTranslationKeys.gridVoltage),
      type: DataFieldType.voltage,
      valueExtractor: (data) =>
          MapUtils.OM(data, ['data', 'inverter', 'sgs', 'voltage']),
      icon: Icons.electric_bolt,
      expertMode: false,
      category: 'ac',
    ),
    DeviceDataField(
      name: TO(key: FieldTranslationKeys.gridFrequency),
      type: DataFieldType.frequency,
      valueExtractor: (data) => MapUtils.OM(data, ['data', 'inverter', 'sgs', 'frequency']),
      icon: Icons.waves,
      expertMode: true,
      category: 'ac',
    ),
    DeviceDataField(
      name: TO(key: FieldTranslationKeys.temperature),
      type: DataFieldType.temperature,
      valueExtractor: (data) =>
          MapUtils.OM(data, ['data', 'inverter', 'sgs', 'temperature']),
      icon: Icons.thermostat,
      expertMode: false,
      category: 'ac',
    ),
    for (var i = 1; i <= 4; i++) ...[
      DeviceDataField(
        name: TO(key: FieldTranslationKeys.pvPower, params: {'num': i}),
        type: DataFieldType.watt,
        valueExtractor: (data) =>
            MapUtils.OM(data, ['data', 'inverter', 'pv', i.toString(), 'power']),
        icon: Icons.solar_power,
        expertMode: false,
        category: 'pv$i',
      ),
      DeviceDataField(
        name: TO(key: FieldTranslationKeys.pvVoltage, params: {'num': i}),
        type: DataFieldType.voltage,
        valueExtractor: (data) =>
            MapUtils.OM(data, ['data', 'inverter', 'pv', i.toString(), 'voltage']),
        icon: Icons.electrical_services,
        expertMode: true,
        category: 'pv$i',
      ),
      DeviceDataField(
        name: TO(key: FieldTranslationKeys.pvCurrent, params: {'num': i}),
        type: DataFieldType.current,
        valueExtractor: (data) =>
            MapUtils.OM(data, ['data', 'inverter', 'pv', i.toString(), 'current']),
        icon: Icons.electrical_services,
        expertMode: true,
        category: 'pv$i',
      ),
      DeviceDataField(
        name: TO(key: FieldTranslationKeys.pvTotalYield, params: {'num': i}),
        type: DataFieldType.energy,
        valueExtractor: (data) => MapUtils.OM(data, ['data', 'inverter', 'pv', i.toString(), 'energy_total']),
        icon: Icons.analytics,
        expertMode: false,
        category: 'pv$i',
        precision: 1,
      ),
      DeviceDataField(
        name: TO(key: FieldTranslationKeys.pvDailyYield, params: {'num': i}),
        type: DataFieldType.energy,
        valueExtractor: (data) => MapUtils.OM(data, ['data', 'inverter', 'pv', i.toString(), 'energy_daily']),
        icon: Icons.analytics,
        expertMode: false,
        category: 'pv$i',
        precision: 1,
      )
    ],
  ];

  @override
  List<DeviceCategoryConfig> getCategoryConfigs() => [
    const DeviceCategoryConfig(
      category: 'pv1',
      displayName: 'PV1',
      displayNameKey: CategoryTranslationKeys.pv1,
      layout: CategoryLayout.standard,
      order: 10,
    ),
    const DeviceCategoryConfig(
      category: 'pv2',
      displayName: 'PV2',
      displayNameKey: CategoryTranslationKeys.pv2,
      layout: CategoryLayout.standard,
      order: 20,
      hideWhenAllNull: true,
      hideWhenAllZero: true,
    ),
    const DeviceCategoryConfig(
      category: 'pv3',
      displayName: 'PV3',
      displayNameKey: CategoryTranslationKeys.pv3,
      layout: CategoryLayout.standard,
      order: 30,
      hideWhenAllNull: true,
      hideWhenAllZero: true,
    ),
    const DeviceCategoryConfig(
      category: 'pv4',
      displayName: 'PV4',
      displayNameKey: CategoryTranslationKeys.pv4,
      layout: CategoryLayout.standard,
      order: 40,
      hideWhenAllNull: true,
      hideWhenAllZero: true,
    ),
    const DeviceCategoryConfig(
      category: 'ac',
      displayName: 'AC (Netz)',
      displayNameKey: CategoryTranslationKeys.acGrid,
      layout: CategoryLayout.standard,
      order: 50,
      hideWhenAllNull: true,
      hideWhenAllZero: true,
    ),
  ];

  @override
  List<TimeSeriesFieldConfig> getTimeSeriesFields() => [
    TimeSeriesFieldConfig(
      name: TO(key: FieldTranslationKeys.pvPower, params: {'num': ''}),
      type: DataFieldType.watt,
      mapping:  ['inverter', 'pv', 'power'],
    ),
    TimeSeriesFieldConfig(
      name: TO(key: FieldTranslationKeys.activePower),
      type: DataFieldType.watt,
      mapping:  ['inverter', 'sgs', 'active_power'],
    ),
    TimeSeriesFieldConfig(
      name: TO(key: FieldTranslationKeys.gridFrequency),
      type: DataFieldType.none,
      mapping: ['inverter', 'sgs', 'frequency'],
    ),
    TimeSeriesFieldConfig(
      name: TO(key: FieldTranslationKeys.gridVoltage),
      type: DataFieldType.voltage,
      mapping: ['inverter', 'sgs', 'voltage'],
      formatter: (value) => value,
    ),
  ];

  @override
  Future<Map<String, dynamic>?> sendCommand(
    dynamic connectionService,
    String command,
    Map<String, dynamic> params,
  ) async {
    final service = connectionService as HoymilesWifiService;

    if (command == COMMAND_FETCH_DATA) {
      return await service.getRealDataNew();
    } else if (command == COMMAND_FETCH_SYS_CONFIG) {
      return await service.getConfig();
    } else if (command == COMMAND_FETCH_WIFI_CONFIG) {
      return await service.getNetworkInfo();
    } else if (command == COMMAND_FETCH_DEVICE_INFO) {
      final flatData = await service.getDeviceInformation();
      return HoymilesCommandHelper.organizeDeviceInfo(flatData);
    } else if (command == COMMAND_SET_LIMIT) {
      final limit = params['limit'] as int?;
      if (limit == null) {
        throw Exception('limit parameter required (0-100)');
      }
      await service.setPowerLimit(limit);
      return {'success': true, 'limit': limit};
    } else if (command == COMMAND_SET_WIFI) {
      final ssid = params['ssid'] as String;
      final password = params['password'] as String;
      await service.setWifiConfig(ssid, password);
      return {'success': true};
    } else if (command == COMMAND_SET_AP_CONFIG) {
      final ssid = params['ssid'] as String;
      final password = params['password'] as String;
      await service.setApWifiConfig(ssid, password);
      return {'success': true};
    } else if (command == COMMAND_RESTART) {
      await service.restartDtu();
      return {'success': true};
    } else if (command == COMMAND_RESTART_INVERTER) {
      final serial = params['inverterSerial'] as String?;
      if (serial == null || serial.isEmpty) {
        throw Exception('inverterSerial parameter required');
      }
      await service.rebootInverter(serial);
      return {'success': true};
    } else if (command == COMMAND_TURN_ON_INVERTER) {
      final serial = params['inverterSerial'] as String?;
      if (serial == null || serial.isEmpty) {
        throw Exception('inverterSerial parameter required');
      }
      await service.turnOnInverter(serial);
      return {'success': true};
    } else if (command == COMMAND_TURN_OFF_INVERTER) {
      final serial = params['inverterSerial'] as String?;
      if (serial == null || serial.isEmpty) {
        throw Exception('inverterSerial parameter required');
      }
      await service.turnOffInverter(serial);
      return {'success': true};
    } else if (command == COMMAND_FETCH_HIST_POWER) {
      return await service.getHistPower();
    } else if (command == COMMAND_FETCH_HIST_ENERGY) {
      return await service.getHistEnergy();
    }
    throw UnimplementedError('Command not yet implemented: $command');
  }
}
