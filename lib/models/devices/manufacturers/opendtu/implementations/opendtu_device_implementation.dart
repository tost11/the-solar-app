import 'package:flutter/material.dart';
import 'package:the_solar_app/constants/command_constants.dart';
import 'package:the_solar_app/constants/translation_keys.dart';
import 'package:the_solar_app/models/devices/device_implementation.dart';
import 'package:the_solar_app/models/to.dart';
import 'package:the_solar_app/screens/configuration/authentication_screen.dart';
import 'package:the_solar_app/screens/configuration/opendtu_online_monitoring_screen.dart';
import 'package:the_solar_app/screens/configuration/percentage_power_limit_screen.dart';
import 'package:the_solar_app/screens/configuration/wifi_configuration_screen.dart';
import 'package:the_solar_app/services/devices/opendtu/opendtu_wifi_service.dart';
import 'package:the_solar_app/utils/dialog_utils.dart';
import 'package:the_solar_app/utils/exception_utils.dart';
import 'package:the_solar_app/utils/localization_extension.dart';
import 'package:the_solar_app/utils/map_utils.dart';
import 'package:the_solar_app/utils/message_utils.dart';
import 'package:the_solar_app/utils/navigation_utils.dart';
import 'package:the_solar_app/utils/url_utils.dart';
import 'package:the_solar_app/widgets/opendtu_inverter_list_widget.dart';
import '../../../generic_rendering/device_category_config.dart';
import '../../../generic_rendering/device_control_item.dart';
import '../../../generic_rendering/device_custom_section.dart';
import '../../../generic_rendering/device_data_field.dart';
import '../../../mixins/device_authentication_mixin.dart';
import '../../../generic_rendering/device_menu_item.dart';
import '../../../time_series_field_config.dart';
import '../../../time_series_field_group.dart';

/// Simple implementation for OpenDTU devices
///
/// No future device types expected, so kept minimal and straightforward
class OpenDTUDeviceImplementation extends DeviceImplementation {
  // Dynamic field groups generated from runtime inverter data
  List<TimeSeriesFieldGroup>? _dynamicFieldGroups;

  // Track current inverter serials to detect changes
  Set<String> _cachedInverterSerials = {};
  @override
  List<DeviceMenuItem> getMenuItems() {
    return [
      DeviceMenuItem(
        name: TO(key: MenuTranslationKeys.authentication),
        subtitle: TO(key: MenuSubtitleKeys.authenticationSubtitle),
        icon: Icons.lock,
        iconColor: Colors.blue,
        onTap: (ctx) async {
          final context = ctx.context;
          final device = ctx.device;

          final config = await DialogUtils.executeWithLoading(
            context,
            loadingMessage: context.l10n.loadingConfiguration,
            operation: () => device.sendCommand(COMMAND_FETCH_AUTH, {}),
            onError: (e) => MessageUtils.showError(
                context, context.l10n.errorLoadingAuthConfig(e.toString())),
          );

          if (config == null || !context.mounted) return;

          final allowReadonly = config['allow_readonly'] as bool? ?? false;
          var authDev = device as DeviceAuthenticationMixin;
          authDev.authPassword = config['password'] as String?;

          final result = await NavigationUtils.pushConfigurationScreen(
            context,
            AuthenticationScreen(
              device: device,
              currentUsername: 'admin',
              currentPassword: authDev.authPassword,
              currentEnabled: allowReadonly,
              usernameEditable: !authDev.fixedUserName,
            ),
          );

          if (result == true && context.mounted) {
            MessageUtils.showSuccess(
                context, context.l10n.authenticationConfigured);
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

          final config = await DialogUtils.executeWithLoading(
            context,
            loadingMessage: context.l10n.loadingConfiguration,
            operation: () => device.sendCommand(COMMAND_FETCH_WIFI_CONFIG, {}),
            onError: (e) => MessageUtils.showError(
                context, context.l10n.errorLoadingWifiConfig(e.toString())),
          );

          if (config == null || !context.mounted) return;

          String? currentSsid = config['ssid'] as String?;

          final result = await NavigationUtils.pushConfigurationScreen(
            context,
            WiFiConfigurationScreen(device: device, currentSsid: currentSsid),
          );

          if (result == true && context.mounted) {
            MessageUtils.showSuccess(context, context.l10n.wifiConfigurationCompleted);
          }
        },
      ),
      DeviceMenuItem(
        name: TO(key: MenuTranslationKeys.onlineMonitoringConfiguration),
        subtitle: TO(key: MenuSubtitleKeys.onlineMonitoringSubtitle),
        icon: Icons.cloud_upload,
        iconColor: Colors.blue,
        onTap: (ctx) async {
          final context = ctx.context;
          final device = ctx.device;

          final config = await DialogUtils.executeWithLoading(
            context,
            loadingMessage: context.l10n.loadingConfiguration,
            operation: () => device.sendCommand(COMMAND_FETCH_ONLINE_MONITORING, {}),
            onError: (e) async {
              if(e is ApiException){
                if(e.statusCode == 404){
                  // Show custom dialog with firmware download link
                  showDialog(
                    context: context,
                    builder: (dialogContext) => AlertDialog(
                      title: Text(context.l10n.firmwareNotSupported),
                      content: SelectableText(context.l10n.firmwareNotSupportedMessage),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(dialogContext),
                          child: Text(context.l10n.cancel),
                        ),
                        ElevatedButton.icon(
                          onPressed: () async {
                            Navigator.pop(dialogContext);
                            await UrlUtils.openUrl(
                              context,
                              'https://github.com/tost11/OpenDTU-Push-Rest-API-and-Deye-Sun/releases',
                            );
                          },
                          icon: const Icon(Icons.download),
                          label: Text(context.l10n.downloadFirmware),
                        ),
                      ],
                    ),
                  );
                  return;
                }
              }
              MessageUtils.showError(context, context.l10n.errorLoadingConfiguration(e.toString()));
            });

          if (config == null || !context.mounted) return;

          // Parse URLs to extract protocol and host
          // Primary URL
          String? primaryProtocol;
          String? primaryHost;
          final primaryUrl = config['tost_url'] as String?;
          if (primaryUrl != null && primaryUrl.isNotEmpty) {
            if (primaryUrl.startsWith('https://')) {
              primaryProtocol = 'https';
              primaryHost = primaryUrl.substring(8);
            } else if (primaryUrl.startsWith('http://')) {
              primaryProtocol = 'http';
              primaryHost = primaryUrl.substring(7);
            } else {
              // Fallback: assume it's just the host
              primaryProtocol = 'https';
              primaryHost = primaryUrl;
            }
          }

          // Secondary URL (handle missing for old versions)
          String? secondaryProtocol;
          String? secondaryHost;
          final secondaryUrl = config['tost_second_url'] as String?;
          if (secondaryUrl != null && secondaryUrl.isNotEmpty) {
            if (secondaryUrl.startsWith('https://')) {
              secondaryProtocol = 'https';
              secondaryHost = secondaryUrl.substring(8);
            } else if (secondaryUrl.startsWith('http://')) {
              secondaryProtocol = 'http';
              secondaryHost = secondaryUrl.substring(7);
            } else {
              secondaryProtocol = 'https';
              secondaryHost = secondaryUrl;
            }
          }

          // Navigate to configuration screen
          final result = await NavigationUtils.pushConfigurationScreen(
            context,
            OpenDTUOnlineMonitoringScreen(
              device: device,
              currentEnabled: config['tost_enabled'] as bool?,
              currentPrimaryProtocol: primaryProtocol,
              currentPrimaryHost: primaryHost,
              currentSecondaryProtocol: secondaryProtocol,
              currentSecondaryHost: secondaryHost,
              currentSystemId: config['tost_system_id'] as String?,
              currentToken: config['tost_token'] as String?,
              currentDuration: config['tost_duration'] as int?,
            ),
          );

          if (result == true && context.mounted) {
            MessageUtils.showSuccess(context, context.l10n.onlineMonitoringConfigured);
          }
        },
      ),
      DeviceMenuItem(
        name: TO(key: MenuTranslationKeys.percentagePowerLimit),
        subtitle: TO(key: MenuSubtitleKeys.percentagePowerLimitSubtitle),
        icon: Icons.bolt,
        iconColor: Colors.orange,
        onTap: (ctx) async {
          final context = ctx.context;
          final device = ctx.device;

          // Get inverters data
          final invertersData = device.data['data']?['inverters'] as Map<String, dynamic>?;
          if (invertersData == null || invertersData.isEmpty) {
            MessageUtils.showWarning(context, context.l10n.noInvertersFound);
            return;
          }

          final inverterCount = invertersData.length;

          if (inverterCount == 1) {
            // Single inverter: extract data and navigate directly
            await _handleSingleInverterLimit(context, device, invertersData);
          } else {
            // Multiple inverters: show selection dialog
            await _handleMultipleInverterLimit(context, device, invertersData);
          }
        },
      ),
      DeviceMenuItem(
        name: TO(key: MenuTranslationKeys.inverterToggle),
        subtitle: TO(key: MenuSubtitleKeys.inverterToggleSubtitle),
        icon: Icons.power_settings_new,
        iconColor: Colors.red,
        onTap: (ctx) async {
          final context = ctx.context;
          final device = ctx.device;

          final invertersData = device.data['data']?['inverters'] as Map<String,dynamic>?;
          if (invertersData == null || invertersData.isEmpty) {
            MessageUtils.showWarning(
                context, context.l10n.noInvertersFound);
            return;
          }

          final inverterCount = invertersData.length;

          if (inverterCount == 1) {
            // Single inverter: show confirmation dialog
            await _handleSingleInverterToggle(context, device, invertersData);
          } else {
            // Multiple inverters: show selection dialog
            await _handleMultipleInverterToggle(context, device, invertersData);
          }
        },
      ),
      DeviceMenuItem(
        name: TO(key: MenuTranslationKeys.restartDevice),
        subtitle: TO(key: MenuSubtitleKeys.restartDeviceSubtitle),
        icon: Icons.restart_alt,
        iconColor: Colors.purple,
        onTap: (ctx) async {
          final context = ctx.context;
          final device = ctx.device;

          final confirmed = await showDialog<bool>(
            context: context,
            builder: (dialogContext) => AlertDialog(
              title: Text(context.l10n.menuRestartDevice),
              content: Text(context.l10n.restartDeviceConfirm),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, false),
                  child: Text(context.l10n.cancel),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, true),
                  child: Text(context.l10n.menuRestartDevice),
                ),
              ],
            ),
          );

          if (confirmed != true) return;

          await DialogUtils.executeWithLoading(
            context,
            loadingMessage: context.l10n.deviceRestarting,
            operation: () => device.sendCommand(COMMAND_RESTART, {}),
            onSuccess: (_) =>
                MessageUtils.showSuccess(context, context.l10n.deviceRestarting),
            onError: (e) =>
                MessageUtils.showError(context, context.l10n.errorRestartingDevice(e.toString())),
          );
        },
      ),
      DeviceMenuItem(
        name: TO(key: MenuTranslationKeys.restartInverter),
        subtitle: TO(key: MenuSubtitleKeys.restartInverterSubtitle),
        icon: Icons.restart_alt,
        iconColor: Colors.orange,
        onTap: (ctx) async {
          final context = ctx.context;
          final device = ctx.device;

          final invertersData = device.data['data']?['inverters'] as Map<String,dynamic>?;
          if (invertersData == null || invertersData.isEmpty) {
            MessageUtils.showWarning(
                context, context.l10n.noInvertersFound);
            return;
          }

          final inverterCount = invertersData.length;

          if (inverterCount == 1) {
            // Single inverter: show confirmation dialog
            await _handleSingleInverterRestart(context, device, invertersData);
          } else {
            // Multiple inverters: show selection dialog
            await _handleMultipleInverterRestart(context, device, invertersData);
          }
        },
      ),
    ];
  }

  @override
  List<DeviceControlItem> getControlItems() => [];

  @override
  List<DeviceDataField> getDataFields() {
    return [
      DeviceDataField(
        name: TO(key: FieldTranslationKeys.totalPower),
        type: DataFieldType.watt,
        valueExtractor: (data) => MapUtils.OM(data, ['data', 'total', 'Power', 'v']),
        icon: Icons.bolt,
        expertMode: false,
        category: 'inverter',
      ),
      DeviceDataField(
        name: TO(key: FieldTranslationKeys.dcTotalPower),
        type: DataFieldType.watt,
        valueExtractor: (data) => MapUtils.OM(data, ['data', 'total', 'DC_Power_Total']),
        icon: Icons.solar_power,
        expertMode: false,
        category: 'inverter',
      ),
      DeviceDataField(
        name: TO(key: FieldTranslationKeys.dailyYield),
        type: DataFieldType.energy,
        valueExtractor: (data) => MapUtils.OM(data, ['data', 'total', 'YieldDay', 'v']),
        icon: Icons.wb_sunny,
        expertMode: false,
        category: 'inverter',
      ),
      DeviceDataField(
        name: TO(key: FieldTranslationKeys.totalYield),
        type: DataFieldType.energy,
        valueExtractor: (data) => MapUtils.OM(data, ['data', 'total', 'YieldTotal', 'v']),
        icon: Icons.energy_savings_leaf,
        expertMode: false,
        category: 'inverter',
        precision: 3,
      ),
      DeviceDataField(
        name: TO(key: FieldTranslationKeys.chipModel),
        type: DataFieldType.none,
        valueExtractor: (data) => MapUtils.OM(data, ['config', 'chipmodel']),
        icon: Icons.memory,
        expertMode: true,
        showDetailButton: true,
        category: 'system',
      ),
      DeviceDataField(
        name: TO(key: FieldTranslationKeys.uptime),
        type: DataFieldType.none,
        valueExtractor: (data) {
          final uptime = MapUtils.OM(data, ['config', 'uptime']);
          if (uptime != null) {
            final seconds = uptime as int;
            final hours = seconds ~/ 3600;
            final minutes = (seconds % 3600) ~/ 60;
            return '${hours}h ${minutes}m';
          }
          return null;
        },
        icon: Icons.access_time,
        expertMode: false,
        showDetailButton: true,
        category: 'system',
      ),
      DeviceDataField(
        name: TO(key: FieldTranslationKeys.temperature),
        type: DataFieldType.temperature,
        valueExtractor: (data) => MapUtils.OM(data, ['config', 'cputemp']),
        icon: Icons.thermostat,
        expertMode: true,
        category: 'system',
      ),
      DeviceDataField(
        name: TO(key: FieldTranslationKeys.heap),
        type: DataFieldType.none,
        valueExtractor: (data) {
          final heapTotal = MapUtils.OM(data, ['config', 'heap_total']);
          final heapUsed = MapUtils.OM(data, ['config', 'heap_used']);

          if (heapTotal != null && heapUsed != null) {
            final totalKB = (heapTotal as num) ~/ 1024;
            final usedKB = (heapUsed as num) ~/ 1024;
            final percentage = ((heapUsed / heapTotal) * 100).toStringAsFixed(1);
            return '$usedKB/$totalKB KB ($percentage%)';
          }
          return null;
        },
        icon: Icons.memory,
        expertMode: true,
        showDetailButton: true,
        category: 'memory',
      ),
      DeviceDataField(
        name: TO(key: FieldTranslationKeys.sketch),
        type: DataFieldType.none,
        valueExtractor: (data) {
          final sketchTotal = MapUtils.OM(data, ['config', 'sketch_total']);
          final sketchUsed = MapUtils.OM(data, ['config', 'sketch_used']);

          if (sketchTotal != null && sketchUsed != null) {
            final totalKB = (sketchTotal as num) ~/ 1024;
            final usedKB = (sketchUsed as num) ~/ 1024;
            final percentage = ((sketchUsed / sketchTotal) * 100).toStringAsFixed(1);
            return '$usedKB/$totalKB KB ($percentage%)';
          }
          return null;
        },
        icon: Icons.code,
        expertMode: true,
        showDetailButton: true,
        category: 'memory',
      ),
      DeviceDataField(
        name: TO(key: FieldTranslationKeys.littleFs),
        type: DataFieldType.none,
        valueExtractor: (data) {
          final littlefsTotal = MapUtils.OM(data, ['config', 'littlefs_total']);
          final littlefsUsed = MapUtils.OM(data, ['config', 'littlefs_used']);

          if (littlefsTotal != null && littlefsUsed != null) {
            final totalKB = (littlefsTotal as num) ~/ 1024;
            final usedKB = (littlefsUsed as num) ~/ 1024;
            final percentage = ((littlefsUsed / littlefsTotal) * 100).toStringAsFixed(1);
            return '$usedKB/$totalKB KB ($percentage%)';
          }
          return null;
        },
        icon: Icons.folder,
        expertMode: true,
        showDetailButton: true,
        category: 'memory',
      ),
    ];
  }

  @override
  List<DeviceCustomSection> getCustomSections() {
    return [
      DeviceCustomSection(
        title: TO(key: CategoryTranslationKeys.inverter),
        position: CustomSectionPosition.afterConnectionControls,
        requiresConnection: true,
        builder: (context, device, data) {
          return OpenDTUInverterListWidget(data: data);
        },
      ),
    ];
  }

  @override
  List<DeviceCategoryConfig> getCategoryConfigs() {
    return [
      const DeviceCategoryConfig(
        category: 'inverter',
        displayName: 'Wechselrichter',
        displayNameKey: CategoryTranslationKeys.inverter,
        layout: CategoryLayout.standard,
        order: 5,
      ),
      const DeviceCategoryConfig(
        category: 'system',
        displayName: 'System',
        displayNameKey: CategoryTranslationKeys.system,
        layout: CategoryLayout.standard,
        order: 10,
      ),
      const DeviceCategoryConfig(
        category: 'memory',
        displayName: 'Speicher',
        displayNameKey: CategoryTranslationKeys.memory,
        layout: CategoryLayout.oneLine,
        order: 20,
      ),
    ];
  }

  @override
  List<TimeSeriesFieldConfig> getTimeSeriesFields() {
    // Total power graphs are now part of dynamic field groups for better ordering control
    return [];
  }

  @override
  List<TimeSeriesFieldGroup> getTimeSeriesFieldGroups() {
    return _dynamicFieldGroups ?? [];
  }

  /// Generate field groups dynamically from inverter data
  ///
  /// Only regenerates if the set of inverters has changed (detected by comparing serials).
  /// Call this method on every WebSocket data receive.
  void generateFieldGroupsFromData(Map<String, dynamic> data) {
    final invertersMap = data['inverters'] as Map<String, dynamic>?;
    if (invertersMap == null) return;

    // Check if inverter set has changed
    final currentSerials = invertersMap.keys.toSet();

    // Compare set contents (not reference equality)
    final isUnchanged = _cachedInverterSerials.isNotEmpty &&
                        currentSerials.length == _cachedInverterSerials.length &&
                        currentSerials.containsAll(_cachedInverterSerials);

    if (isUnchanged) {
      // No change in inverters, skip regeneration
      return;
    }

    // Update cache and regenerate
    debugPrint('[OpenDTU] Generating field groups for ${currentSerials.length} inverters');
    _cachedInverterSerials = currentSerials;
    _dynamicFieldGroups = [];

    // Add total power graphs at the top
    _dynamicFieldGroups!.add(TimeSeriesFieldGroup(
      name: TO(key: FieldTranslationKeys.dcTotalPower),
      fields: [
        TimeSeriesFieldConfig(
          name: TO(key: FieldTranslationKeys.dcTotalPower),
          type: DataFieldType.watt,
          mapping: ['total', 'DC_Power_Total'],
          expertMode: false,
        ),
      ],
      expertMode: false,
    ));

    _dynamicFieldGroups!.add(TimeSeriesFieldGroup(
      name: TO(key: FieldTranslationKeys.acPower),
      fields: [
        TimeSeriesFieldConfig(
          name: TO(key: FieldTranslationKeys.acPower),
          type: DataFieldType.watt,
          mapping: ['total', 'Power', 'v'],
          expertMode: true,
        ),
      ],
      expertMode: true,
    ));

    // Temporary storage for per-inverter graphs (to control ordering)
    final perInverterPowerGroups = <TimeSeriesFieldGroup>[];
    final perInverterVoltageGroups = <TimeSeriesFieldGroup>[];

    // First pass: collect per-inverter graphs
    for (var entry in invertersMap.entries) {
      final serial = entry.key;
      final inverter = entry.value as Map<String, dynamic>;
      final name = inverter['name'] ?? 'Wechselrichter $serial';
      final dcStrings = inverter['dc_strings'] as List?;

      if (dcStrings != null && dcStrings.isNotEmpty) {
        // Power graph (default visibility)
        final powerFields = <TimeSeriesFieldConfig>[];
        for (int i = 0; i < dcStrings.length; i++) {
          final stringData = dcStrings[i] as Map<String, dynamic>;
          final stringName = stringData['name'] ?? 'String ${i + 1}';
          powerFields.add(TimeSeriesFieldConfig(
            name: stringName,
            type: DataFieldType.watt,
            mapping: ['inverters', serial, 'dc_strings', '$i', 'power'],
          ));
        }
        perInverterPowerGroups.add(TimeSeriesFieldGroup(
          name: TO(key: FieldTranslationKeys.dcStringPower, params: {'name': name}),
          fields: powerFields,
          expertMode: false, // Visible by default
        ));

        // Voltage graph (expert mode only)
        final voltageFields = <TimeSeriesFieldConfig>[];
        for (int i = 0; i < dcStrings.length; i++) {
          final stringData = dcStrings[i] as Map<String, dynamic>;
          final stringName = stringData['name'] ?? 'String ${i + 1}';
          voltageFields.add(TimeSeriesFieldConfig(
            name: stringName,
            type: DataFieldType.voltage,
            mapping: ['inverters', serial, 'dc_strings', '$i', 'voltage'],
          ));
        }
        perInverterVoltageGroups.add(TimeSeriesFieldGroup(
          name: TO(key: FieldTranslationKeys.dcStringVoltage, params: {'name': name}),
          fields: voltageFields,
          expertMode: true, // Expert mode only
        ));

      }
    }

    // Add combined graphs FIRST (only if multiple inverters present)
    if (currentSerials.length > 1) {

      // Combined DC Input Power Graph (one line per inverter)
      final combinedDcPowerFields = <TimeSeriesFieldConfig>[];
      for (var entry in invertersMap.entries) {
        final serial = entry.key;
        final inverter = entry.value as Map<String, dynamic>;
        final name = inverter['name'] ?? 'Wechselrichter $serial';

        combinedDcPowerFields.add(TimeSeriesFieldConfig(
          name: name,  // Uses configured inverter name from OpenDTU
          type: DataFieldType.watt,
          mapping: ['inverters', serial, 'dc_power'],  // Total DC power for this inverter
        ));
      }

      _dynamicFieldGroups!.add(TimeSeriesFieldGroup(
        name: TO(key: FieldTranslationKeys.dcInputPower, params: {'prefix': 'Alle Wechselrichter'}),
        fields: combinedDcPowerFields,
        expertMode: false,  // Visible by default
      ));

      // Combined AC Output Power Graph (one line per inverter, expert mode)
      final combinedAcPowerFields = <TimeSeriesFieldConfig>[];
      for (var entry in invertersMap.entries) {
        final serial = entry.key;
        final inverter = entry.value as Map<String, dynamic>;
        final name = inverter['name'] ?? 'Wechselrichter $serial';

        combinedAcPowerFields.add(TimeSeriesFieldConfig(
          name: name,
          type: DataFieldType.watt,
          mapping: ['inverters', serial, 'ac_power'],  // AC output power for this inverter
        ));
      }

      _dynamicFieldGroups!.add(TimeSeriesFieldGroup(
        name: TO(key: FieldTranslationKeys.acOutputPower, params: {'prefix': 'Alle Wechselrichter'}),
        fields: combinedAcPowerFields,
        expertMode: true,  // Expert mode only
      ));
    }

    // Add per-inverter graphs in order: power first, then voltage
    _dynamicFieldGroups!.addAll(perInverterPowerGroups);
    _dynamicFieldGroups!.addAll(perInverterVoltageGroups);
  }

  @override
  Future<Map<String, dynamic>?> sendCommand(
    dynamic connectionService,
    String command,
    Map<String, dynamic> params,
  ) async {
    final service = connectionService as OpenDTUWifiService;

    if (command == COMMAND_FETCH_DATA) {
      return await service.fetchSystemInfo();
    } else if (command == COMMAND_FETCH_AUTH) {
      return await service.sendGetCommand('/api/security/config');
    } else if (command == COMMAND_SET_AUTH) {
      // Implementation requires access to device state, handled in device class
      throw UnimplementedError('COMMAND_SET_AUTH must be handled in device class');
    } else if (command == COMMAND_SET_WIFI) {
      String? ssid = params['ssid'];
      String? password = params['password'];

      if (ssid == null || ssid.isEmpty) {
        throw Exception('SSID required');
      }

      final payload = {
        'hostname': params['hostname'] ?? 'solar',
        'dhcp': params['dhcp'] ?? true,
        'ipaddress': params['ipaddress'] ?? '0.0.0.0',
        'netmask': params['netmask'] ?? '0.0.0.0',
        'gateway': params['gateway'] ?? '0.0.0.0',
        'dns1': params['dns1'] ?? '0.0.0.0',
        'dns2': params['dns2'] ?? '0.0.0.0',
        'ssid': ssid,
        'password': password ?? '',
        'aptimeout': params['aptimeout'] ?? 0,
        'mdnsenabled': params['mdnsenabled'] ?? false,
      };

      await service.sendCommand('/api/network/config', payload);
      return {'success': true};
    } else if (command == COMMAND_FETCH_WIFI_CONFIG) {
      return await service.sendGetCommand('/api/network/config');
    } else if (command == COMMAND_SET_LIMIT) {
      final serial = params['serial'] as String?;
      final manufacturer = params['manufacturer'] as String?;
      final limit = params['limit'] as int?;

      if (serial == null || manufacturer == null || limit == null) {
        throw Exception('serial, manufacturer, and limit parameters required');
      }

      return await service.sendCommand('/api/limit/config', {
        'serial': serial,
        'limit_value': limit,
        'manufacturer': manufacturer,
        'limit_type': 3,
      });
    } else if (command == COMMAND_SET_MAIN_POWER) {
      final serial = params['serial'] as String?;
      final manufacturer = params['manufacturer'] as String?;
      final power = params['power'] as bool?;

      if (serial == null || manufacturer == null || power == null) {
        throw Exception('serial, manufacturer, and power parameters required');
      }

      return await service.sendCommand('/api/power/config', {
        'serial': serial,
        'manufacturer': manufacturer,
        'power': power,
      });
    } else if (command == COMMAND_RESTART) {
      final success = await service.restartDevice();
      return {'success': success};
    } else if (command == COMMAND_RESTART_INVERTER) {
      final serial = params['serial'] as String?;
      final manufacturer = params['manufacturer'] as String?;

      if (serial == null) {
        throw Exception('serial parameter required');
      }

      // Build payload with restart flag
      final payload = <String, dynamic>{
        'serial': serial,
        'restart': true,
      };

      // Only add manufacturer if present
      if (manufacturer != null) {
        payload['manufacturer'] = manufacturer;
      }

      return await service.sendCommand('/api/power/config', payload);
    } else if (command == COMMAND_FETCH_ONLINE_MONITORING) {
      return await service.sendGetCommand('/api/tost/config');
    } else if (command == COMMAND_SET_ONLINE_MONITORING) {
      // Extract parameters
      final enabled = params['enabled'] as bool? ?? false;

      // Build full URLs from protocol + host
      final primaryProtocol = params['primary_protocol'] as String? ?? 'https';
      final primaryHost = params['primary_host'] as String? ?? '';
      final primaryUrl = primaryHost.isNotEmpty ? '$primaryProtocol://$primaryHost' : '';

      final secondaryProtocol = params['secondary_protocol'] as String? ?? 'https';
      final secondaryHost = params['secondary_host'] as String? ?? '';
      final secondaryUrl = secondaryHost.isNotEmpty ? '$secondaryProtocol://$secondaryHost' : '';

      final systemId = params['system_id'] as String? ?? '';
      final token = params['token'] as String? ?? '';
      final duration = params['duration'] as int? ?? 30;

      // Build payload matching OpenDTU API
      final payload = {
        'tost_enabled': enabled,
        'tost_url': primaryUrl,
        'tost_second_url': secondaryUrl,
        'tost_system_id': systemId,
        'tost_token': token,
        'tost_duration': duration,
      };

      return await service.sendCommand('/api/tost/config', payload);
    } else {
      throw UnimplementedError('Command not yet implemented: $command');
    }
  }

  /// Handle toggle for single inverter (shows confirmation dialog)
  Future<void> _handleSingleInverterToggle(
    BuildContext context,
    device,
    Map<String, dynamic> invertersData,
  ) async {
    final inverter = invertersData.values.first;
    final serial = inverter['serial'] as String?;
    final name = inverter['name'] as String?;
    final isOn = inverter['producing'] as bool? ?? false;
    final manufacturer = inverter['manufacturer'] as String?;

    if (serial == null) return;

    // Show confirmation dialog with current state
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(name ?? 'Wechselrichter'),
        content: Text(
          isOn
            ? context.l10n.inverterCurrentlyOn
            : context.l10n.inverterCurrentlyOff
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(context.l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(isOn ? context.l10n.turnOff : context.l10n.turnOn),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    // Toggle to opposite state
    final newState = !isOn;

    if (!context.mounted) return;

    await DialogUtils.executeWithLoading(
      context,
      loadingMessage: newState
        ? context.l10n.turningOnInverters
        : context.l10n.turningOffInverters,
      operation: () {
        // Build command map dynamically
        final commandParams = <String, dynamic>{
          'serial': serial,
          'power': newState,
        };

        // Only add manufacturer if present
        if (manufacturer != null) {
          commandParams['manufacturer'] = manufacturer;
        }

        return device.sendCommand(COMMAND_SET_MAIN_POWER, commandParams);
      },
      onSuccess: (_) => MessageUtils.showSuccess(
        context,
        newState
          ? context.l10n.invertersTurnedOn
          : context.l10n.invertersTurnedOff
      ),
      onError: (e) => MessageUtils.showError(
        context,
        '${context.l10n.error}: $e'
      ),
    );
  }

  /// Handle toggle for multiple inverters (shows selection dialog)
  Future<void> _handleMultipleInverterToggle(
    BuildContext context,
    device,
    Map<String, dynamic> invertersData,
  ) async {
    // Build options map: serial number -> display name
    final options = <String, String>{};
    for (var entry in invertersData.entries) {
      final serial = entry.key;
      final inverter = entry.value as Map<String, dynamic>;
      final name = inverter['name'] as String? ?? 'Wechselrichter $serial';
      final isOn = inverter['producing'] as bool? ?? false;

      // Add state indicator to name
      options[serial] = '$name (${isOn ? "AN" : "AUS"})';
    }

    // Show selection dialog
    final selectedSerial = await MessageUtils.showSelectionDialog<String>(
      context,
      title: context.l10n.selectInverterToToggle,
      options: options,
      cancelable: true,
    );

    if (selectedSerial == null) return;

    // Get selected inverter's current state and manufacturer
    final selectedInverter = invertersData[selectedSerial] as Map<String, dynamic>;
    final isOn = selectedInverter['producing'] as bool? ?? false;
    final newState = !isOn;
    final manufacturer = selectedInverter['manufacturer'] as String?;

    if (!context.mounted) return;

    // Toggle selected inverter
    await DialogUtils.executeWithLoading(
      context,
      loadingMessage: newState
        ? context.l10n.turningOnInverters
        : context.l10n.turningOffInverters,
      operation: () {
        // Build command map dynamically
        final commandParams = <String, dynamic>{
          'serial': selectedSerial,
          'power': newState,
        };

        // Only add manufacturer if present
        if (manufacturer != null) {
          commandParams['manufacturer'] = manufacturer;
        }

        return device.sendCommand(COMMAND_SET_MAIN_POWER, commandParams);
      },
      onSuccess: (_) => MessageUtils.showSuccess(
        context,
        newState
          ? context.l10n.invertersTurnedOn
          : context.l10n.invertersTurnedOff
      ),
      onError: (e) => MessageUtils.showError(
        context,
        '${context.l10n.error}: $e'
      ),
    );
  }

  /// Handle restart for single inverter (shows confirmation dialog)
  Future<void> _handleSingleInverterRestart(
    BuildContext context,
    device,
    Map<String, dynamic> invertersData,
  ) async {
    final inverter = invertersData.values.first;
    final serial = inverter['serial'] as String?;
    final name = inverter['name'] as String?;
    final manufacturer = inverter['manufacturer'] as String?;

    if (serial == null) return;

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(context.l10n.restartInverterConfirm),
        content: Text(name ?? 'Wechselrichter $serial'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(context.l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(context.l10n.actionRestart),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    if (!context.mounted) return;

    await DialogUtils.executeWithLoading(
      context,
      loadingMessage: context.l10n.restartingInverter,
      operation: () {
        // Build command map dynamically
        final commandParams = <String, dynamic>{
          'serial': serial,
        };

        // Only add manufacturer if present
        if (manufacturer != null) {
          commandParams['manufacturer'] = manufacturer;
        }

        return device.sendCommand(COMMAND_RESTART_INVERTER, commandParams);
      },
      onSuccess: (_) => MessageUtils.showSuccess(
        context,
        context.l10n.inverterRestarted
      ),
      onError: (e) => MessageUtils.showError(
        context,
        '${context.l10n.error}: $e'
      ),
    );
  }

  /// Handle restart for multiple inverters (shows selection dialog then restarts immediately)
  Future<void> _handleMultipleInverterRestart(
    BuildContext context,
    device,
    Map<String, dynamic> invertersData,
  ) async {
    // Build options map: serial number -> display name
    final options = <String, String>{};
    for (var entry in invertersData.entries) {
      final serial = entry.key;
      final inverter = entry.value as Map<String, dynamic>;
      final name = inverter['name'] as String? ?? 'Wechselrichter $serial';
      options[serial] = name;
    }

    // Show selection dialog
    final selectedSerial = await MessageUtils.showSelectionDialog<String>(
      context,
      title: context.l10n.selectInverterToRestart,
      options: options,
      cancelable: true,
    );

    if (selectedSerial == null) return;

    // Get selected inverter's info
    final selectedInverter = invertersData[selectedSerial] as Map<String, dynamic>;
    final manufacturer = selectedInverter['manufacturer'] as String?;

    if (!context.mounted) return;

    // Restart selected inverter immediately (no confirmation dialog)
    await DialogUtils.executeWithLoading(
      context,
      loadingMessage: context.l10n.restartingInverter,
      operation: () {
        // Build command map dynamically
        final commandParams = <String, dynamic>{
          'serial': selectedSerial,
        };

        // Only add manufacturer if present
        if (manufacturer != null) {
          commandParams['manufacturer'] = manufacturer;
        }

        return device.sendCommand(COMMAND_RESTART_INVERTER, commandParams);
      },
      onSuccess: (_) => MessageUtils.showSuccess(
        context,
        context.l10n.inverterRestarted
      ),
      onError: (e) => MessageUtils.showError(
        context,
        '${context.l10n.error}: $e'
      ),
    );
  }

  /// Handle power limit for single inverter (navigates directly)
  Future<void> _handleSingleInverterLimit(
    BuildContext context,
    device,
    Map<String, dynamic> invertersData,
  ) async {
    final inverter = invertersData.values.first;
    final serial = inverter['serial'] as String?;
    final manufacturer = inverter['manufacturer'] as String?;
    final currentLimit = inverter['limit_relative'] as int?;

    if (serial == null) {
      MessageUtils.showWarning(context, context.l10n.noInvertersFound);
      return;
    }

    // Build additional params with inverter-specific data
    final additionalParams = <String, dynamic>{
      'serial': serial,
    };

    // Only add manufacturer if present
    if (manufacturer != null) {
      additionalParams['manufacturer'] = manufacturer;
    }

    // Navigate to power limit screen with additional params
    await NavigationUtils.pushConfigurationScreen(
      context,
      PercentagePowerLimitScreen(
        device: device,
        additionalParams: additionalParams,
        currentLimit: currentLimit,
      ),
    );
  }

  /// Handle power limit for multiple inverters (shows selection dialog)
  Future<void> _handleMultipleInverterLimit(
    BuildContext context,
    device,
    Map<String, dynamic> invertersData,
  ) async {
    // Build options map: serial number -> display name
    final options = <String, String>{};
    for (var entry in invertersData.entries) {
      final serial = entry.key;
      final inverter = entry.value as Map<String, dynamic>;
      final name = inverter['name'] as String? ?? 'Wechselrichter $serial';
      final currentLimit = inverter['limit_relative'] as int?;

      // Add current limit to display name
      if (currentLimit != null) {
        options[serial] = '$name ($currentLimit%)';
      } else {
        options[serial] = name;
      }
    }

    // Show selection dialog
    final selectedSerial = await MessageUtils.showSelectionDialog<String>(
      context,
      title: context.l10n.selectInverterToSetLimit,
      options: options,
      cancelable: true,
    );

    if (selectedSerial == null) return;

    // Get selected inverter's data
    final selectedInverter = invertersData[selectedSerial] as Map<String, dynamic>;
    final manufacturer = selectedInverter['manufacturer'] as String?;
    final currentLimit = selectedInverter['limit_relative'] as int?;

    if (!context.mounted) return;

    // Build additional params with selected inverter data
    final additionalParams = <String, dynamic>{
      'serial': selectedSerial,
    };

    // Only add manufacturer if present
    if (manufacturer != null) {
      additionalParams['manufacturer'] = manufacturer;
    }

    // Navigate to power limit screen with additional params
    await NavigationUtils.pushConfigurationScreen(
      context,
      PercentagePowerLimitScreen(
        device: device,
        additionalParams: additionalParams,
        currentLimit: currentLimit,
      ),
    );
  }
}
