import 'package:flutter/material.dart';
import 'package:the_solar_app/constants/command_constants.dart';
import 'package:the_solar_app/constants/translation_keys.dart';
import 'package:the_solar_app/models/devices/device_implementation.dart';
import 'package:the_solar_app/models/to.dart';
import 'package:the_solar_app/screens/configuration/battery_soc_screen.dart';
import 'package:the_solar_app/screens/configuration/general_settings_screen.dart';
import 'package:the_solar_app/screens/configuration/power_limit_screen.dart';
import 'package:the_solar_app/screens/configuration/power_screen.dart';
import 'package:the_solar_app/utils/globals.dart';
import 'package:the_solar_app/utils/map_utils.dart';
import 'package:the_solar_app/utils/message_utils.dart';
import 'package:the_solar_app/utils/navigation_utils.dart';
import 'package:the_solar_app/widgets/zendure_battery_pack_list_widget.dart';
import '../../../generic_rendering/device_control_item.dart';
import '../../../generic_rendering/device_custom_section.dart';
import '../../../generic_rendering/device_data_field.dart';
import '../../../generic_rendering/device_menu_item.dart';
import '../../../generic_rendering/general_setting_item.dart';
import '../../../time_series_field_config.dart';

/// Shared implementation for all Zendure devices (Bluetooth and WiFi)
///
/// Contains menu items, data fields, control items, and command handling
/// that is common between Bluetooth and WiFi variants.
class ZendureDeviceImplementation extends DeviceImplementation {
  @override
  List<DeviceMenuItem> getMenuItems() {
    return [
      DeviceMenuItem(
        name: TO(key: MenuTranslationKeys.powerSettings),
        subtitle: TO(key: MenuSubtitleKeys.powerSettingsSubtitle),
        icon: Icons.power_settings_new,
        iconColor: Colors.blue,
        onTap: (ctx) async {
          final context = ctx.context;
          final device = ctx.device;

          try {
            // Fetch current properties from device
            final properties = device.data["data"]?["properties"] ?? {};

            // Extract limits from properties
            final inputLimit = properties['inputLimit'] as int? ?? 0;
            final outputLimit = properties['outputLimit'] as int? ?? 0;

            // Define max limits (can be adjusted based on device specs)
            const maxInputLimit = 1200; // Example: 1200W max
            const maxOutputLimit = 1200; // Example: 1200W max

            // Navigate to PowerLimitScreen
            if (!context.mounted) return;

            final result = await NavigationUtils.pushConfigurationScreen(
              context,
              PowerScreen(
                  device: device,
                  currentInputLimit: inputLimit,
                  currentOutputLimit: outputLimit,
                  maxInputLimit: maxInputLimit,
                  maxOutputLimit: maxOutputLimit,
                  currentLimitMode: properties['acMode'] == 1
                      ? LimitMode.input
                      : LimitMode.output),
            );

            if (result == true && context.mounted) {
              MessageUtils.showSuccess(
                  context, 'Leistungslimit erfolgreich aktualisiert');
            }
          } catch (e) {
            MessageUtils.showError(
                context, 'Konnte Gerätedaten nicht abrufen: $e');
          }
        },
      ),
      DeviceMenuItem(
        name: TO(key: MenuTranslationKeys.batteryLimits),
        subtitle: TO(key: MenuSubtitleKeys.batteryLimitsSubtitle),
        icon: Icons.battery_std,
        iconColor: Colors.orange,
        onTap: (ctx) async {
          final context = ctx.context;
          final device = ctx.device;

          try {
            // Fetch current properties from device
            final properties = device.data["data"]?["properties"] ?? {};

            // Extract SOC values from properties (convert from 0.1% to %)
            final minSoc =
                (properties['minSoc'] as int? ?? 200) ~/ 10; // Default 20%
            final socSet =
                (properties['socSet'] as int? ?? 900) ~/ 10; // Default 90%

            // Define ranges for SOC sliders
            const minSocRangeMin = 5; // Minimum SOC can be 5-40%
            const minSocRangeMax = 40;
            const maxSocRangeMin = 80; // Maximum SOC can be 80-100%
            const maxSocRangeMax = 100;

            // Navigate to BatterySocScreen
            if (!context.mounted) return;

            final result = await NavigationUtils.pushConfigurationScreen(
              context,
              BatterySocScreen(
                device: device,
                currentMinSoc: minSoc,
                currentMaxSoc: socSet,
                minSocRangeMin: minSocRangeMin,
                minSocRangeMax: minSocRangeMax,
                maxSocRangeMin: maxSocRangeMin,
                maxSocRangeMax: maxSocRangeMax,
              ),
            );

            if (result == true && context.mounted) {
              MessageUtils.showSuccess(
                  context, 'Batterie-Limits erfolgreich aktualisiert');
            }
          } catch (e) {
            MessageUtils.showError(
                context, 'Konnte Gerätedaten nicht abrufen: $e');
          }
        },
      ),
      DeviceMenuItem(
        name: TO(key: MenuTranslationKeys.advancedPowerSettings),
        subtitle: TO(key: MenuSubtitleKeys.advancedPowerSettingsSubtitle),
        icon: Icons.settings_suggest,
        iconColor: Colors.purple,
        onTap: (ctx) async {
          final context = ctx.context;
          final device = ctx.device;

          try {
            // Fetch current properties from device
            final properties = device.data["data"]?["properties"] ?? {};

            // Extract configuration values from properties
            final inverseMaxPower = properties['inverseMaxPower'] as int? ?? 800;
            final gridReverse = properties['gridReverse'] as int? ?? 1;
            final gridStandard = properties['gridStandard'] as int? ?? 0;

            // Define max limit for inverse max power
            const maxInverseMaxPower = 1200; // Example: 1200W max

            // Navigate to PowerLimitScreen
            if (!context.mounted) return;

            final result = await NavigationUtils.pushConfigurationScreen(
              context,
              PowerLimitScreen(
                device: device,
                currentInverseMaxPower: inverseMaxPower,
                maxInverseMaxPower: maxInverseMaxPower,
                currentGridReverse: gridReverse,
                currentGridStandard: gridStandard,
              ),
            );

            if (result == true && context.mounted) {
              MessageUtils.showSuccess(
                  context, 'Leistungseinstellungen erfolgreich aktualisiert');
            }
          } catch (e) {
            MessageUtils.showError(
                context, 'Konnte Gerätedaten nicht abrufen: $e');
          }
        },
      ),
      DeviceMenuItem(
        name: TO(key: MenuTranslationKeys.generalSettings),
        subtitle: TO(key: MenuSubtitleKeys.generalSettingsSubtitle),
        icon: Icons.settings,
        iconColor: Colors.purple,
        onTap: (ctx) async {
          final context = ctx.context;
          final device = ctx.device;

          final settings = getGeneralSettings(device.data);

          await NavigationUtils.pushConfigurationScreen(
            context,
            GeneralSettingsScreen(
              device: device,
              settings: settings,
            ),
          );
        },
      ),
    ];
  }

  @override
  List<DeviceControlItem> getControlItems() {
    return [/*
      //TODO check  if working
      // Power on/off control
      DeviceControlItem(
        name: 'Wechselrichter',
        type: ControlType.switchToggle,
        icon: Icons.power_settings_new,
        valueExtractor: (data) {
          final status = MapUtils.OM(data, ['data', 'limit_status']);
          if (status == null) return false;
          final statusValue = int.tryParse(status.toString());
          return statusValue == 1; // 1 = on, 2 = off
        },
        onChanged: (context, device, newValue) async {
          // Show confirmation dialog only when turning OFF
          if (newValue == false) {
            final confirmed = await showDialog<bool>(
              context: context,
              builder: (dialogContext) => AlertDialog(
                title: const Text('Wechselrichter ausschalten'),
                content: const Text(
                    'Sind Sie sicher, dass Sie den Wechselrichter ausschalten möchten?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(dialogContext, false),
                    child: const Text('Abbrechen'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(dialogContext, true),
                    child: const Text('Ausschalten'),
                  ),
                ],
              ),
            );

            if (confirmed != true) return;
          }

          await DialogUtils.executeWithLoading(
            context,
            loadingMessage: newValue
                ? 'Schalte Wechselrichter ein...'
                : 'Schalte Wechselrichter aus...',
            operation: () async {
              await device.sendCommand(COMMAND_SET_MAIN_POWER, {
                'on': newValue,
              });

              // Update local data after successful toggle
              if (device.data.containsKey('data')) {
                device.data['data']!['limit_status'] = newValue ? 1 : 2;
                device.emitData(device.data['data']!);
              }
            },
            showErrorDialog: true,
          );
        },
      ),
   */ ];
  }

  @override
  List<DeviceDataField> getDataFields() {
    return [
      DeviceDataField(
        name: TO(key: FieldTranslationKeys.solarInputPower),
        type: DataFieldType.watt,
        valueExtractor: (data) =>
            MapUtils.OM(data, ['data', 'properties', 'solarInputPower']),
        icon: Icons.wb_sunny,
        expertMode: false,
      ),
      DeviceDataField(
        name: TO(key: FieldTranslationKeys.acMode),
        type: DataFieldType.none,
        valueExtractor: (data) {
          final state = MapUtils.OM(data, ['data', 'properties', 'acMode']);
          if (state == 1) return 'from Grid';
          if (state == 2) return 'to Grid';
          return 'Deaktivated';
        },
        icon: Icons.power,
        expertMode: false,
      ),
      DeviceDataField(
        name: TO(key: FieldTranslationKeys.homeOutputPower),
        type: DataFieldType.watt,
        valueExtractor: (data) =>
            MapUtils.OM(data, ['data', 'properties', 'outputHomePower']),
        icon: Icons.home,
        expertMode: false,
      ),
      DeviceDataField(
        name: TO(key: FieldTranslationKeys.batteryLevel),
        type: DataFieldType.percentage,
        valueExtractor: (data) =>
            MapUtils.OM(data, ['data', 'properties', 'electricLevel']),
        icon: Icons.battery_charging_full,
        expertMode: false,
      ),
      DeviceDataField(
        name: TO(key: FieldTranslationKeys.outputLimit),
        type: DataFieldType.watt,
        valueExtractor: (data) =>
            MapUtils.OM(data, ['data', 'properties', 'outputLimit']),
        icon: Icons.power,
        expertMode: false,
      ),
      DeviceDataField(
        name: TO(key: FieldTranslationKeys.batteryPower),
        type: DataFieldType.watt,
        valueExtractor: (data) =>
            MapUtils.OM(data, ['data', 'properties', 'packInputPower']),
        icon: Icons.arrow_downward,
        expertMode: false,
      ),
      DeviceDataField(
        name: TO(key: FieldTranslationKeys.batteryPower),
        type: DataFieldType.watt,
        valueExtractor: (data) =>
            MapUtils.OM(data, ['data', 'properties', 'outputPackPower']),
        icon: Icons.arrow_upward,
        expertMode: false,
      ),
      DeviceDataField(
        name: TO(key: FieldTranslationKeys.packState),
        type: DataFieldType.none,
        valueExtractor: (data) {
          final state = MapUtils.OM(data, ['data', 'properties', 'packState']);
          if (state == 0) return 'Idle';
          if (state == 1) return 'Charging';
          if (state == 2) return 'Discharging';
          return state?.toString() ?? '-';
        },
        icon: Icons.info_outline,
        expertMode: false,
      ),
      DeviceDataField(
        name: TO(key: FieldTranslationKeys.packCount),
        type: DataFieldType.none,
        valueExtractor: (data) =>
            MapUtils.OM(data, ['data', 'properties', 'packNum']),
        icon: Icons.battery_std,
        expertMode: false,
      ),
      // Additional properties from device
      DeviceDataField(
        name: TO(key: FieldTranslationKeys.inputLimit),
        type: DataFieldType.watt,
        valueExtractor: (data) =>
            MapUtils.OM(data, ['data', 'properties', 'inputLimit']),
        icon: Icons.input,
        expertMode: true,
      ),
      DeviceDataField(
        name: TO(key: FieldTranslationKeys.socSet),
        type: DataFieldType.percentage,
        valueExtractor: (data) {
          final socSet = MapUtils.OM(data, ['data', 'properties', 'socSet']);
          return socSet != null
              ? (socSet as num) / 10.0
              : null; // Convert from 0.1% to %
        },
        icon: Icons.battery_charging_full,
        expertMode: true,
      ),
      DeviceDataField(
        name: TO(key: FieldTranslationKeys.minSoc),
        type: DataFieldType.percentage,
        valueExtractor: (data) {
          final minSoc = MapUtils.OM(data, ['data', 'properties', 'minSoc']);
          return minSoc != null
              ? (minSoc as num) / 10.0
              : null; // Convert from 0.1% to %
        },
        icon: Icons.battery_alert,
        expertMode: true,
      ),
      DeviceDataField(
        name: TO(key: FieldTranslationKeys.gridReverse),
        type: DataFieldType.none,
        valueExtractor: (data) {
          final state =
              MapUtils.OM(data, ['data', 'properties', 'gridReverse']);
          return state == 1 ? 'Enabled' : 'Disabled';
        },
        icon: Icons.sync_alt,
        expertMode: true,
      ),
      DeviceDataField(
        name: TO(key: FieldTranslationKeys.maxInverterPower),
        type: DataFieldType.watt,
        valueExtractor: (data) =>
            MapUtils.OM(data, ['data', 'properties', 'inverseMaxPower']),
        icon: Icons.power_settings_new,
        expertMode: true,
      ),
      DeviceDataField(
        name: TO(key: FieldTranslationKeys.lampSwitch),
        type: DataFieldType.none,
        valueExtractor: (data) {
          final state = MapUtils.OM(data, ['data', 'properties', 'lampSwitch']);
          return state == 1 ? 'On' : 'Off';
        },
        icon: Icons.lightbulb,
        expertMode: true,
      ),
      DeviceDataField(
        name: TO(key: FieldTranslationKeys.gridOffMode),
        type: DataFieldType.none,
        valueExtractor: (data) {
          final state =
              MapUtils.OM(data, ['data', 'properties', 'gridOffMode']);
          return state == 1 ? 'Enabled' : 'Disabled';
        },
        icon: Icons.power_off,
        expertMode: true,
      ),
      DeviceDataField(
        name: TO(key: FieldTranslationKeys.wifiState),
        type: DataFieldType.none,
        valueExtractor: (data) {
          final state = MapUtils.OM(data, ['data', 'properties', 'IOTState']);
          if (state == 0) return 'Disconnected';
          if (state == 1) return 'Connecting';
          if (state == 2) return 'Connected';
          return state?.toString() ?? '-';
        },
        icon: Icons.cloud,
        expertMode: false,
      ),
      DeviceDataField(
        name: TO(key: FieldTranslationKeys.fanMode),
        type: DataFieldType.none,
        valueExtractor: (data) =>
            MapUtils.OM(data, ['data', 'properties', 'Fanmode']),
        icon: Icons.air,
        expertMode: true,
      ),
      DeviceDataField(
        name: TO(key: FieldTranslationKeys.fanSpeed),
        type: DataFieldType.none,
        valueExtractor: (data) =>
            MapUtils.OM(data, ['data', 'properties', 'Fanspeed']),
        icon: Icons.speed,
        expertMode: true,
      ),
      DeviceDataField(
        name: TO(key: FieldTranslationKeys.smartMode),
        type: DataFieldType.none,
        valueExtractor: (data) {
          final state = MapUtils.OM(data, ['data', 'properties', 'smartMode']);
          return state == 1 ? 'Enabled' : 'Disabled';
        },
        icon: Icons.smart_toy,
        expertMode: true,
      ),
      DeviceDataField(
        name: TO(key: FieldTranslationKeys.chargeMaxLimit),
        type: DataFieldType.watt,
        valueExtractor: (data) =>
            MapUtils.OM(data, ['data', 'properties', 'chargeMaxLimit']),
        icon: Icons.battery_charging_full,
        expertMode: false,
      ),
      DeviceDataField(
        name: TO(key: FieldTranslationKeys.timestamp),
        type: DataFieldType.none,
        valueExtractor: (data) {
          final ts = MapUtils.OM(data, ['data', 'properties', 'ts']);
          if (ts != null) {
            final date =
                DateTime.fromMillisecondsSinceEpoch((ts as int) * 1000);
            return '${date.day}.${date.month}.${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
          }
          return null;
        },
        icon: Icons.access_time,
        expertMode: true,
      ),
      DeviceDataField(
        name: TO(key: FieldTranslationKeys.timezone),
        type: DataFieldType.none,
        valueExtractor: (data) {
          final zone = MapUtils.OM(data, ['data', 'properties', 'tsZone']);
          return zone != null ? 'GMT+$zone' : null;
        },
        icon: Icons.public,
        expertMode: true,
      ),
    ];
  }

  @override
  List<GeneralSettingItem> getGeneralSettings(Map<String, dynamic> data) {
    // Extract current lamp switch state (0=off, 1=on)
    final lampState = MapUtils.OM(data, ['data', 'properties', 'lampSwitch']) as int? ?? 0;
    final lampStatus = lampState == 1;

    // Extract current grid off mode state (0=normal, 1=power-saving, 2=off)
    final gridOffMode = MapUtils.OM(data, ['data', 'properties', 'gridOffMode']) as int? ?? 0;

    return [
      // Existing lamp toggle
      GeneralSettingItem(
        name: TO(key: FieldTranslationKeys.lamp),
        commandName: GENERAL_SETTINGS_LAMP_SWITCH,
        type: SettingType.toggle,
        currentStatus: lampStatus,
        popUpOnChange: false,
        description: TO(key: FieldTranslationKeys.deviceLightingDescription),
        icon: Icons.lightbulb,
      ),

      // NEW: Grid power supply dropdown
      GeneralSettingItem(
        name: TO(key: FieldTranslationKeys.emergencyPowerSupply),
        commandName: GENERAL_SETTINGS_GRID_OFF_MODE,
        type: SettingType.dropdown,
        currentValue: gridOffMode,
        options: const [
          SettingOption(
            label: 'Ein - Normalmodus',
            value: 0,
            description: 'Normale Leistung',
          ),
          SettingOption(
            label: 'Ein - Energiesparmodus',
            value: 1,
            description: 'Reduzierte Leistung',
          ),
          SettingOption(
            label: 'Aus',
            value: 2,
            description: 'Notstromversorgung deaktiviert',
          ),
        ],
        popUpOnChange: false,
        description: TO(key: FieldTranslationKeys.gridPowerModeDescription),
        icon: Icons.power,
      ),
    ];
  }

  @override
  List<DeviceCustomSection> getCustomSections() {
    return [
      DeviceCustomSection(
        title: TO(key: FieldTranslationKeys.batteryPacks),
        position: CustomSectionPosition.afterLiveData,
        requiresConnection: true,
        builder: (context, device, data) {
          // Read expert mode directly from Globals instead of data map
          return ZendureBatteryPackListWidget(
            data: data,
            expertMode: Globals.expertMode,
          );
        },
      ),
    ];
  }

  @override
  String getFetchCommand() {
    return 'getData'; // Zendure devices don't use named commands
  }

  @override
  List<TimeSeriesFieldConfig> getTimeSeriesFields() {
    return [
      TimeSeriesFieldConfig(
        name: TO(key: FieldTranslationKeys.solarInput),
        type: DataFieldType.watt,
        mapping: ['properties', 'solarInputPower'],
      ),
      TimeSeriesFieldConfig(
        name: TO(key: CategoryTranslationKeys.battery),
        type: DataFieldType.percentage,
        mapping: ['properties', 'electricLevel'],
      ),
      TimeSeriesFieldConfig(
        name: TO(key: FieldTranslationKeys.outputPower),
        type: DataFieldType.watt,
        mapping: ['properties', 'outputHomePower'],
      ),
      TimeSeriesFieldConfig(
        name: TO(key: FieldTranslationKeys.inputVoltage),
        type: DataFieldType.voltage,
        mapping: ['properties', 'inputVolt'],
        formatter: (value) => value / 10, // Convert from 0.1V to V
      ),
    ];
  }

  @override
  Future<Map<String, dynamic>?> sendCommand(
    dynamic connectionService,
    String command,
    Map<String, dynamic> params,
  ) async {
    // Common command handling for both Bluetooth and WiFi
    if (command == COMMAND_SET_LIMIT) {
      var props = <String, dynamic>{};
      //i know is same but if i rename variable and command interface it will change
      if (params["inputLimit"] != null) {
        props["inputLimit"] = params["inputLimit"];
      }
      if (params["outputLimit"] != null) {
        props["outputLimit"] = params["outputLimit"];
      }
      if (params["acMode"] != null) {
        props["acMode"] = params["acMode"];
      }

      if (props.isEmpty) {
        throw Exception("props to send are empty no limit set");
      }

      // Delegate to service (works for both Bluetooth and WiFi)
      await connectionService.sendCommand(params);
    } else if (command == COMMAND_BATTERY_LIMITS) {
      var props = <String, dynamic>{};

      // Extract battery limit parameters
      if (params["minSoc"] != null) {
        props["minSoc"] = params["minSoc"] * 10;
      }
      if (params["maxSoc"] != null) {
        props["socSet"] = params["maxSoc"] * 10;
      }

      if (props.isEmpty) {
        throw Exception("props to send are empty, no battery limits set");
      }

      await connectionService.sendCommand(props);
    } else if (command == COMMAND_SET_POWER_CONFIG) {
      var props = <String, dynamic>{};

      // Extract power configuration parameters
      if (params["inverseMaxPower"] != null) {
        props["inverseMaxPower"] = params["inverseMaxPower"];
      }
      if (params["gridReverse"] != null) {
        props["gridReverse"] = params["gridReverse"];
      }
      if (params["gridStandard"] != null) {
        props["gridStandard"] = params["gridStandard"];
      }

      if (props.isEmpty) {
        throw Exception("props to send are empty, no power config set");
      }

      await connectionService.sendCommand(props);
    } else if (command == COMMAND_SET_GENERAL_SETTING) {
      // Handle general settings (toggle and dropdown types)
      final settingName = params["name"] as String?;
      final settingValue = params["value"]; // Can be bool or int

      if (settingName == GENERAL_SETTINGS_LAMP_SWITCH) {
        // Lamp switch: boolean → 0/1
        var props = <String, dynamic>{};
        props["lampSwitch"] = settingValue == true ? 1 : 0;
        await connectionService.sendCommand(props);
      } else if (settingName == GENERAL_SETTINGS_GRID_OFF_MODE) {
        // Grid off mode: integer value (0, 1, or 2)
        var props = <String, dynamic>{};
        props["gridOffMode"] = settingValue as int;
        await connectionService.sendCommand(props);
      } else {
        throw UnimplementedError('General setting not implemented: $settingName');
      }
    } /*else if (command == COMMAND_SET_MAIN_POWER) { //TODO check if working
      var props = <String, dynamic>{};

      props["hubState"] = (params["on"] as bool?) == true ? 1 : 0;

      await (connectionService as dynamic).sendCommand(props);
    } */else {
      throw UnimplementedError(
        'Command type not yet implemented: $command',
      );
    }
    return null; //TODO get response
  }
}
