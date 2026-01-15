import 'package:flutter/material.dart';
import 'package:the_solar_app/models/devices/device_implementation.dart';
import 'package:the_solar_app/models/devices/device_base.dart';

import 'package:the_solar_app/constants/command_constants.dart';
import 'package:the_solar_app/constants/shelly_constants.dart';
import 'package:the_solar_app/models/shelly_script.dart';
import 'package:the_solar_app/screens/configuration/authentication_screen.dart';
import 'package:the_solar_app/screens/configuration/general_settings_screen.dart';
import 'package:the_solar_app/screens/configuration/port_configuration_screen.dart';
import 'package:the_solar_app/screens/configuration/shelly_scripts/shelly_scripts_screen.dart';
import 'package:the_solar_app/screens/configuration/wifi_ap_configuration_screen.dart';
import 'package:the_solar_app/screens/configuration/wifi_configuration_screen.dart';
import 'package:the_solar_app/services/devices/shelly/shelly_service.dart';
import 'package:the_solar_app/services/devices/shelly/shelly_bluetooth_service.dart';
import 'package:the_solar_app/services/devices/shelly/shelly_wifi_service.dart';
import 'package:the_solar_app/utils/dialog_utils.dart';
import 'package:the_solar_app/utils/navigation_utils.dart';
import 'package:the_solar_app/utils/map_utils.dart';
import 'package:the_solar_app/utils/message_utils.dart';
import '../../../generic_rendering/device_control_item.dart';
import '../../../generic_rendering/device_custom_section.dart';
import '../../../generic_rendering/device_data_field.dart';
import '../../../generic_rendering/device_menu_item.dart';
import '../../../generic_rendering/device_category_config.dart';
import '../../../generic_rendering/general_setting_item.dart';
import '../../../mixins/device_authentication_mixin.dart';
import '../../../time_series_field_config.dart';
import '../shelly_module_registry.dart';

class ShellyDeviceBaseImplementation extends DeviceImplementation {

  static const int CODE_CHUNK_LENGTH = 1000;
  static const int CODE_CHUNK_LENGTH_WIFI = 4000;

  // Reference to the device (set after construction)
  DeviceBase? _device;

  // Cache detected modules for performance
  Map<String, List<int>>? _cachedModules;

  /// Set the device reference (called by device constructor)
  void setDevice(DeviceBase device) {
    _device = device;
    _cachedModules = null; // Clear cache when device changes
  }

  @override
  List<DeviceMenuItem> getMenuItems(){
    return [
      DeviceMenuItem(
        name: 'Allgemeine Einstellungen',
        subtitle: 'Grundlegende Geräteeinstellungen verwalten',
        icon: Icons.settings,
        iconColor: Colors.purple,
        onTap: (ctx) async {
          final context = ctx.context;
          final device = ctx.device;

          final resp = await DialogUtils.executeWithLoading(
            context,
            loadingMessage: 'Lade Gerätedaten...',
            operation: () => device.sendCommand(COMMAND_FETCH_SYS_CONFIG, {}),
            showErrorDialog: false,
          );

          if (resp == null || !context.mounted) return;

          // Get current settings
          final settings = getGeneralSettings(resp);

          // Navigate to general settings screen
          await NavigationUtils.pushConfigurationScreen(
            context,
            GeneralSettingsScreen(
              device: device,
              settings: settings,
            ),
          );
        },
      ),
      DeviceMenuItem(
        name: 'WiFi konfigurieren',
        subtitle: 'Netzwerkverbindung einrichten',
        icon: Icons.wifi,
        iconColor: Colors.green,
        onTap: (ctx) async {
          final context = ctx.context;
          final device = ctx.device;

          final resp = await DialogUtils.executeWithLoading(
            context,
            loadingMessage: 'Lade aktuelle Konfiguration...',
            operation: () => device.sendCommand(COMMAND_FETCH_WIFI_CONFIG, {}),
            onError: (e) => MessageUtils.showError(context, 'Konnte WiFi-Konfiguration nicht laden: $e'),
          );

          if (resp == null || !context.mounted) return;

          // Extract current SSID from sta attribute
          String? currentSsid = MapUtils.OMas<String?>(resp, ["sta", "ssid"], null);

          final result = await NavigationUtils.pushConfigurationScreen(
            context,
            WiFiConfigurationScreen(
              device: device,
              currentSsid: currentSsid,
            ),
          );

          if (result == true && context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('WiFi-Konfiguration abgeschlossen'),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
      ),
      DeviceMenuItem(
        name: 'Access Point konfigurieren',
        subtitle: 'WiFi Access Point einrichten',
        icon: Icons.router,
        iconColor: Colors.blue,
        onTap: (ctx) async {
          final context = ctx.context;
          final device = ctx.device;

          final resp = await DialogUtils.executeWithLoading(
            context,
            loadingMessage: 'Lade Gerätedaten...',
            operation: () => device.sendCommand(COMMAND_FETCH_WIFI_CONFIG, {}),
            onError: (e) => MessageUtils.showError(context, 'Konnte Gerätedaten nicht abrufen: $e'),
          );

          if (resp == null || !context.mounted) return;

          final result = await NavigationUtils.pushConfigurationScreen(
            context,
            WiFiApConfigurationScreen(
              device: device,
              currentIsOpen: MapUtils.OMas(resp,["ap","is_open"],true),
              currentRangeExtender: MapUtils.OMas(resp,["ap","range_extender","enable"],true),
              currentEnabled: MapUtils.OMas(resp,["ap","enable"],true),
              showSsidOption: false,
              showEnabledOption: true,
                showOpenOption: true,
                showRangeExtenderOption: true,
            ),
          );

          if (result == true) {
            MessageUtils.showSuccess(context, 'Access Point erfolgreich konfiguriert');
          }
        },
      ),
      DeviceMenuItem(
        name: 'Configure rpc Port',
        subtitle: 'RPC UDP Port konfigurieren',
        icon: Icons.settings_ethernet,
        iconColor: Colors.purple,
        onTap: (ctx) async {
          final context = ctx.context;
          final device = ctx.device;

          final resp = await DialogUtils.executeWithLoading(
            context,
            loadingMessage: 'Lade Systemkonfiguration...',
            operation: () => device.sendCommand(COMMAND_FETCH_SYS_CONFIG, {}),
            onError: (e) => MessageUtils.showError( context, 'Konnte Systemkonfiguration nicht laden: $e'),
          );

          if (resp == null || !context.mounted) return;

          // Extract current port from rpc_udp.listen_port
          int? currentPort = MapUtils.OMas<int?>(resp, ["rpc_udp", "listen_port"], null);

          final result = await NavigationUtils.pushConfigurationScreen(
            context,
            PortConfigurationScreen(
              device: device,
              portName: 'RPC UDP Port',
              portDescription: 'Konfigurieren Sie den UDP Port für RPC Kommunikation, nach der Konfiguration muss das Gerät neugestartet werden um die Änderrungen zu übernehmen.',
              currentPort: currentPort,
              commandParameterName: 'port',
            ),
          );

          if (result == true && context.mounted) {
            MessageUtils.showSuccess(context, 'RPC Port erfolgreich konfiguriert');
          }
        },
      ),
      DeviceMenuItem(
        name: 'Gerät neustarten',
        subtitle: 'Startet das Gerät neu',
        icon: Icons.restart_alt,
        iconColor: Colors.orange,
        onTap: (ctx) async {
          final context = ctx.context;
          final device = ctx.device;

          // Show confirmation dialog
          final confirmed = await showDialog<bool>(
            context: context,
            builder: (BuildContext dialogContext) => AlertDialog(
              title: const Text('Gerät neustarten?'),
              content: const Text(
                  'Das Gerät wird. Möchten Sie fortfahren?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, false),
                  child: const Text('Abbrechen'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, true),
                  child: const Text('Neustarten'),
                ),
              ],
            ),
          );

          if (confirmed != true) return;

          await DialogUtils.executeWithLoading(
            context,
            loadingMessage: 'Gerät wird neu gestartet...',
            operation: () async {
              await device.sendCommand(COMMAND_RESTART, {});
              await Future.delayed(const Duration(seconds: 1));
              return true;
            },
            onSuccess: (_) => MessageUtils.showSuccess( context, 'Gerät wird neu gestartet'),
            onError: (e) => MessageUtils.showError(context, 'Fehler beim Neustarten des Geräts: $e'),
          );
        },
      ),
      DeviceMenuItem(
        name: 'Authentifizierung konfigurieren',
        subtitle: 'Benutzername und Passwort einrichten',
        icon: Icons.lock,
        iconColor: Colors.orange,
        onTap: (ctx) async {
          final context = ctx.context;
          final device = ctx.device;

          await DialogUtils.executeWithLoading(
            context,
            loadingMessage: 'Lade Gerätedaten...',
            operation: () => device.sendCommand(COMMAND_FETCH_DEVICE_INFO, {"id": 0}),
            showErrorDialog: false,
          );

          if (!context.mounted) return;

          final authDev = device as DeviceAuthenticationMixin;

          await NavigationUtils.pushConfigurationScreen(
            context,
            AuthenticationScreen(
              device: device,
              currentUsername: 'admin',
              currentPassword: null,
              currentEnabled: MapUtils.OMas(device.data,["config","auth_en"],false),
              usernameEditable: !authDev.fixedUserName,
            ),
          );
        },
      ),
      DeviceMenuItem(
        name: 'Automatisierung konfigurieren',
        subtitle: 'Scripts und Automationen verwalten',
        icon: Icons.auto_awesome,
        iconColor: Colors.teal,
        onTap: (ctx) async {
          final context = ctx.context;
          final device = ctx.device;
          final systemId = ctx.systemId;

          final resp = await DialogUtils.executeWithLoading(
            context,
            loadingMessage: 'Lade Scripts...',
            operation: () => device.sendCommand(COMMAND_FETCH_SCRIPTS, {}),
            onError: (e) => MessageUtils.showError(context, 'Konnte Scripts nicht laden: $e'),
          );

          if (resp == null || !context.mounted) return;

          // Parse scripts array from response
          final scriptsData = resp['scripts'] as List<dynamic>?;
          if (scriptsData == null || scriptsData.isEmpty) {
            MessageUtils.showWarning(context, 'Keine Scripts gefunden');
            return;
          }

          final scripts = scriptsData
              .map((s) => ShellyScript.fromJson(s as Map<String, dynamic>))
              .toList();

          // Navigate to scripts screen with systemId
          await NavigationUtils.pushConfigurationScreen(
            context,
            ShellyScriptsScreen(
              device: device,
              scripts: scripts,
              systemId: systemId,  // Pass systemId for device filtering
            ),
          );
        },
      ),
    ];
  }

  @override
  List<DeviceControlItem> getControlItems() {
    final modules = _getDetectedModules();
    if (modules.isEmpty) return [];

    final controls = <DeviceControlItem>[];

    for (final entry in modules.entries) {
      final moduleType = entry.key;
      final instances = entry.value;
      final config = ShellyModuleRegistry.configs[moduleType];

      if (config == null || config.controls.isEmpty) continue;

      for (final instanceId in instances) {
        for (final template in config.controls) {
          controls.add(_buildControlItem(
            template: template,
            moduleType: moduleType,
            instanceId: instanceId,
            instanceCount: instances.length,
          ));
        }
      }
    }

    return controls;
  }

  @override
  List<DeviceDataField> getDataFields() {
    final modules = _getDetectedModules();
    if (modules.isEmpty) return [];

    final fields = <DeviceDataField>[];

    // Generate fields for each detected module
    for (final entry in modules.entries) {
      final moduleType = entry.key;
      final instances = entry.value;
      final config = ShellyModuleRegistry.configs[moduleType];

      if (config == null) continue; // Unknown module type

      for (final instanceId in instances) {
        for (final template in config.fields) {
          fields.add(_buildDataField(
            template: template,
            moduleType: moduleType,
            instanceId: instanceId,
            instanceCount: instances.length,
          ));
        }
      }
    }

    // Add calculated total fields for EM1 modules (multiple instances)
    if (modules.containsKey('em1') && modules['em1']!.length > 1) {
      final em1Instances = modules['em1']!;

      // Total Active Power (Gesamt Wirkleistung)
      fields.add(DeviceDataField(
        name: 'Gesamt Wirkleistung',
        type: DataFieldType.watt,
        valueExtractor: (data) {
          double total = 0.0;
          for (final id in em1Instances) {
            final power = MapUtils.OM(data, ['data', 'em1:$id', 'act_power']);
            if (power is num) {
              total += power.toDouble();
            }
          }
          return total;
        },
        icon: Icons.power_settings_new,
        expertMode: false,
        category: 'em1_kombiniert',
      ));

      // Total Apparent Power (Gesamt Scheinleistung)
      fields.add(DeviceDataField(
        name: 'Gesamt Scheinleistung',
        type: DataFieldType.watt,
        valueExtractor: (data) {
          double total = 0.0;
          for (final id in em1Instances) {
            final power = MapUtils.OM(data, ['data', 'em1:$id', 'aprt_power']);
            if (power is num) {
              total += power.toDouble();
            }
          }
          return total;
        },
        icon: Icons.power_outlined,
        expertMode: true,
        category: 'em1_kombiniert',
      ));
    }

    // Add calculated total fields for EM1Data modules (multiple instances)
    if (modules.containsKey('em1data') && modules['em1data']!.length > 1) {
      final em1dataInstances = modules['em1data']!;

      // Total Energy Consumption (Gesamt Energie Bezug)
      fields.add(DeviceDataField(
        name: 'EM1 Gesamt Energie (Bezug)',
        type: DataFieldType.energy,
        valueExtractor: (data) {
          double total = 0.0;
          for (final id in em1dataInstances) {
            final energy = MapUtils.OM(data, ['data', 'em1data:$id', 'total_act_energy']);
            if (energy is num) {
              total += energy.toDouble();
            }
          }
          return total;
        },
        icon: Icons.energy_savings_leaf,
        expertMode: false,
        category: 'em1_kombiniert',
      ));

      // Total Energy Return/Export (Gesamt Energie Einspeisung)
      fields.add(DeviceDataField(
        name: 'EM1 Gesamt Energie (Einspeisung)',
        type: DataFieldType.energy,
        valueExtractor: (data) {
          double total = 0.0;
          for (final id in em1dataInstances) {
            final energy = MapUtils.OM(data, ['data', 'em1data:$id', 'total_act_ret_energy']);
            if (energy is num) {
              total += energy.toDouble();
            }
          }
          return total;
        },
        icon: Icons.arrow_circle_up,
        expertMode: false,
        category: 'em1_kombiniert',
      ));
    }

    // Add calculated total fields for PM1 modules (multiple instances)
    if (modules.containsKey('pm1') && modules['pm1']!.length > 1) {
      final pm1Instances = modules['pm1']!;

      // Total Active Power (Gesamt Wirkleistung)
      fields.add(DeviceDataField(
        name: 'PM Gesamt Wirkleistung',
        type: DataFieldType.watt,
        valueExtractor: (data) {
          double total = 0.0;
          for (final id in pm1Instances) {
            final power = MapUtils.OM(data, ['data', 'pm1:$id', 'apower']);
            if (power is num) {
              total += power.toDouble();
            }
          }
          return total;
        },
        icon: Icons.power_settings_new,
        expertMode: false,
        category: 'pm1_kombiniert',
      ));

      // Total Current (Gesamt Strom)
      fields.add(DeviceDataField(
        name: 'PM Gesamt Strom',
        type: DataFieldType.current,
        valueExtractor: (data) {
          double total = 0.0;
          for (final id in pm1Instances) {
            final current = MapUtils.OM(data, ['data', 'pm1:$id', 'current']);
            if (current is num) {
              total += current.toDouble();
            }
          }
          return total;
        },
        icon: Icons.flash_on,
        expertMode: false,
        category: 'pm1_kombiniert',
      ));

      // Total Energy Import (Gesamt Energie Bezug)
      fields.add(DeviceDataField(
        name: 'PM Gesamt Energie (Bezug)',
        type: DataFieldType.energy,
        valueExtractor: (data) {
          double total = 0.0;
          for (final id in pm1Instances) {
            final energy = MapUtils.OM(data, ['data', 'pm1:$id', 'aenergy', 'total']);
            if (energy is num) {
              total += energy.toDouble();
            }
          }
          return total;
        },
        icon: Icons.energy_savings_leaf,
        expertMode: false,
        category: 'pm1_kombiniert',
      ));

      // Total Energy Export (Gesamt Energie Einspeisung)
      fields.add(DeviceDataField(
        name: 'PM Gesamt Energie (Einspeisung)',
        type: DataFieldType.energy,
        valueExtractor: (data) {
          double total = 0.0;
          for (final id in pm1Instances) {
            final energy = MapUtils.OM(data, ['data', 'pm1:$id', 'ret_aenergy', 'total']);
            if (energy is num) {
              total += energy.toDouble();
            }
          }
          return total;
        },
        icon: Icons.arrow_circle_up,
        expertMode: false,
        category: 'pm1_kombiniert',
      ));
    }

    // Add calculated total fields for Switch modules (multiple instances)
    if (modules.containsKey('switch') && modules['switch']!.length > 1) {
      final switchInstances = modules['switch']!;

      // Total Active Power (Gesamt Leistung)
      fields.add(DeviceDataField(
        name: 'Switch Gesamt Leistung',
        type: DataFieldType.watt,
        valueExtractor: (data) {
          double total = 0.0;
          for (final id in switchInstances) {
            final power = MapUtils.OM(data, ['data', 'switch:$id', 'apower']);
            if (power is num) {
              total += power.toDouble();
            }
          }
          return total;
        },
        icon: Icons.power_settings_new,
        expertMode: false,
        category: 'switch_kombiniert',
      ));

      // Total Energy (Gesamt Energie)
      fields.add(DeviceDataField(
        name: 'Switch Gesamt Energie',
        type: DataFieldType.energy,
        valueExtractor: (data) {
          double total = 0.0;
          for (final id in switchInstances) {
            final energy = MapUtils.OM(data, ['data', 'switch:$id', 'aenergy', 'total']);
            if (energy is num) {
              total += energy.toDouble();
            }
          }
          return total;
        },
        icon: Icons.energy_savings_leaf,
        expertMode: false,
        category: 'switch_kombiniert',
      ));

      // Average Temperature (Durchschnitts Temperatur)
      fields.add(DeviceDataField(
        name: 'Switch Durchschnitts Temperatur',
        type: DataFieldType.temperature,
        valueExtractor: (data) {
          double sum = 0.0;
          int count = 0;
          for (final id in switchInstances) {
            final temp = MapUtils.OM(data, ['data', 'switch:$id', 'temperature', 'tC']);
            if (temp is num) {
              sum += temp.toDouble();
              count++;
            }
          }
          return count > 0 ? sum / count : null;
        },
        icon: Icons.thermostat,
        expertMode: true,
        category: 'switch_kombiniert',
      ));

      // Total Current (Gesamt Strom)
      fields.add(DeviceDataField(
        name: 'Switch Gesamt Strom',
        type: DataFieldType.current,
        valueExtractor: (data) {
          double total = 0.0;
          for (final id in switchInstances) {
            final current = MapUtils.OM(data, ['data', 'switch:$id', 'current']);
            if (current is num) {
              total += current.toDouble();
            }
          }
          return total;
        },
        icon: Icons.flash_on,
        expertMode: true,
        category: 'switch_kombiniert',
      ));
    }

    return fields;
  }

  @override
  List<DeviceCustomSection> getCustomSections() => [];

  @override
  IconData getDeviceIcon() {
    final modules = _getDetectedModules();

    // Priority: em > em1 > pm1 > switch > cover > default
    if (modules.containsKey('em')) return Icons.electric_meter;
    if (modules.containsKey('em1')) return Icons.electric_meter;
    if (modules.containsKey('pm1')) return Icons.electric_meter;
    if (modules.containsKey('switch')) return Icons.power;
    if (modules.containsKey('cover')) return Icons.roller_shades;
    return Icons.broadcast_on_home;
  }

  @override
  List<TimeSeriesFieldConfig> getTimeSeriesFields() {
    final modules = _getDetectedModules();
    final fields = <TimeSeriesFieldConfig>[];

    // Auto-configure time series for switch modules
    if (modules.containsKey('switch')) {
      for (final id in modules['switch']!) {
        final suffix = modules['switch']!.length > 1 ? ' ${id + 1}' : '';
        fields.addAll([
          TimeSeriesFieldConfig(
            name: 'Leistung$suffix',
            type: DataFieldType.watt,
            mapping: ['switch:$id', 'apower'],
            expertMode: false,
            hideIfEmpty: true,
          ),
          TimeSeriesFieldConfig(
            name: 'Spannung$suffix',
            type: DataFieldType.voltage,
            mapping: ['switch:$id', 'voltage'],
            expertMode: true,
            hideIfEmpty: true,
          ),
          TimeSeriesFieldConfig(
            name: 'Strom$suffix',
            type: DataFieldType.current,
            mapping: ['switch:$id', 'current'],
            expertMode: true,
            hideIfEmpty: true,
          ),
        ]);
      }
    }

    // Auto-configure time series for EM modules (3-phase)
    if (modules.containsKey('em')) {
      fields.addAll([
        // Phase A
        TimeSeriesFieldConfig(
          name: 'Phase 1 Leistung',
          type: DataFieldType.watt,
          mapping: ['em:0', 'a_act_power'],
          expertMode: false,
        ),
        TimeSeriesFieldConfig(
          name: 'Phase 1 Spannung',
          type: DataFieldType.voltage,
          mapping: ['em:0', 'a_voltage'],
          expertMode: true,
        ),
        TimeSeriesFieldConfig(
          name: 'Phase 1 Strom',
          type: DataFieldType.current,
          mapping: ['em:0', 'a_current'],
          expertMode: true,
        ),

        // Phase B
        TimeSeriesFieldConfig(
          name: 'Phase 2 Leistung',
          type: DataFieldType.watt,
          mapping: ['em:0', 'b_act_power'],
          expertMode: false,
        ),
        TimeSeriesFieldConfig(
          name: 'Phase 2 Spannung',
          type: DataFieldType.voltage,
          mapping: ['em:0', 'b_voltage'],
          expertMode: true,
        ),
        TimeSeriesFieldConfig(
          name: 'Phase 2 Strom',
          type: DataFieldType.current,
          mapping: ['em:0', 'b_current'],
          expertMode: true,
        ),

        // Phase C
        TimeSeriesFieldConfig(
          name: 'Phase 3 Leistung',
          type: DataFieldType.watt,
          mapping: ['em:0', 'c_act_power'],
          expertMode: false,
        ),
        TimeSeriesFieldConfig(
          name: 'Phase 3 Spannung',
          type: DataFieldType.voltage,
          mapping: ['em:0', 'c_voltage'],
          expertMode: true,
        ),
        TimeSeriesFieldConfig(
          name: 'Phase 3 Strom',
          type: DataFieldType.current,
          mapping: ['em:0', 'c_current'],
          expertMode: true,
        ),

        // Total
        TimeSeriesFieldConfig(
          name: 'Gesamt Leistung',
          type: DataFieldType.watt,
          mapping: ['em:0', 'total_act_power'],
          expertMode: false,
        ),
      ]);
    }

    // Auto-configure time series for EM1 modules (single-phase, multi-instance)
    if (modules.containsKey('em1')) {
      for (final id in modules['em1']!) {
        final suffix = modules['em1']!.length > 1 ? ' ${id + 1}' : '';
        fields.addAll([
          TimeSeriesFieldConfig(
            name: 'EM1 Wirkleistung$suffix',
            type: DataFieldType.watt,
            mapping: ['em1:$id', 'act_power'],
            expertMode: false,
          ),
          TimeSeriesFieldConfig(
            name: 'EM1 Spannung$suffix',
            type: DataFieldType.voltage,
            mapping: ['em1:$id', 'voltage'],
            expertMode: true,
          ),
          TimeSeriesFieldConfig(
            name: 'EM1 Strom$suffix',
            type: DataFieldType.current,
            mapping: ['em1:$id', 'current'],
            expertMode: true,
          ),
        ]);
      }
    }

    // Auto-configure time series for PM1 modules (power meter Gen3, multi-instance)
    if (modules.containsKey('pm1')) {
      for (final id in modules['pm1']!) {
        final suffix = modules['pm1']!.length > 1 ? ' ${id + 1}' : '';
        fields.addAll([
          TimeSeriesFieldConfig(
            name: 'PM1 Wirkleistung$suffix',
            type: DataFieldType.watt,
            mapping: ['pm1:$id', 'apower'],
            expertMode: false,
          ),
          TimeSeriesFieldConfig(
            name: 'PM1 Spannung$suffix',
            type: DataFieldType.voltage,
            mapping: ['pm1:$id', 'voltage'],
            expertMode: true,
          ),
          TimeSeriesFieldConfig(
            name: 'PM1 Strom$suffix',
            type: DataFieldType.current,
            mapping: ['pm1:$id', 'current'],
            expertMode: true,
          ),
          TimeSeriesFieldConfig(
            name: 'PM1 Frequenz$suffix',
            type: DataFieldType.frequency,
            mapping: ['pm1:$id', 'freq'],
            expertMode: true,
          ),
        ]);
      }
    }

    return fields;
  }

  @override
  List<DeviceCategoryConfig> getCategoryConfigs() {
    final modules = _getDetectedModules();
    final configs = <DeviceCategoryConfig>[];

    // 3-Phase EM Categories (Phase 1, 2, 3, Totals)
    if (modules.containsKey('em')) {
      configs.addAll([
        DeviceCategoryConfig(
          category: 'phase1',
          displayName: 'Phase 1',
          order: 10,
          layout: CategoryLayout.standard,
        ),
        DeviceCategoryConfig(
          category: 'phase2',
          displayName: 'Phase 2',
          order: 20,
          layout: CategoryLayout.standard,
        ),
        DeviceCategoryConfig(
          category: 'phase3',
          displayName: 'Phase 3',
          order: 30,
          layout: CategoryLayout.standard,
        ),
        DeviceCategoryConfig(
          category: 'totals',
          displayName: 'Totals',
          order: 40,
          layout: CategoryLayout.standard,
        ),
      ]);
    }

    // EM1 Categories (always create, even for single instance)
    if (modules.containsKey('em1')) {
      final instances = modules['em1']!;
      for (int i = 0; i < instances.length; i++) {
        final instanceNum = i + 1;
        configs.add(DeviceCategoryConfig(
          category: 'messung_$instanceNum',
          displayName: 'Messung $instanceNum',
          order: 50 + i,
          layout: CategoryLayout.standard,
          hideWhenAllZero: i > 0,  // Hide Messung 2, Messung 3 if all values are zero
        ));
      }

      // Add EM1 combined category if multiple instances
      if (instances.length > 1) {
        configs.add(DeviceCategoryConfig(
          category: 'em1_kombiniert',
          displayName: 'Kombiniert',
          order: 50 + instances.length,
          layout: CategoryLayout.standard,
        ));
      }
    }

    // PM1 Categories (always create, even for single instance)
    if (modules.containsKey('pm1')) {
      final instances = modules['pm1']!;
      for (int i = 0; i < instances.length; i++) {
        final instanceNum = i + 1;
        configs.add(DeviceCategoryConfig(
          category: 'pm_messung_$instanceNum',
          displayName: 'PM Messung $instanceNum',
          order: 70 + i,
          layout: CategoryLayout.standard,
          hideWhenAllZero: i > 0,
        ));
      }

      if (instances.length > 1) {
        configs.add(DeviceCategoryConfig(
          category: 'pm1_kombiniert',
          displayName: 'PM Kombiniert',
          order: 70 + instances.length,
          layout: CategoryLayout.standard,
        ));
      }
    }

    // Multi-instance Switch Categories
    if (modules.containsKey('switch')) {
      final instances = modules['switch']!;
      for (int i = 0; i < instances.length; i++) {
        final instanceNum = i + 1;
        configs.add(DeviceCategoryConfig(
          category: 'switch_$instanceNum',
          displayName: 'Switch $instanceNum',
          order: 90 + i,
          layout: CategoryLayout.standard,
          hideWhenAllZero: i > 0,
        ));
      }

      // Add Switch Kombiniert category if multiple switches
      if (instances.length > 1) {
        configs.add(DeviceCategoryConfig(
          category: 'switch_kombiniert',
          displayName: 'Switch Kombiniert',
          order: 90 + instances.length,
          layout: CategoryLayout.standard,
        ));
      }
    }

    // Temperature and other general fields stay uncategorized (null category)
    // They will appear first in the UI before categorized sections

    return configs;
  }

  /// Returns the list of general settings available for this Shelly device
  List<GeneralSettingItem> getGeneralSettings(Map<String,dynamic> config) {
    print(config.toString());
    return [
      GeneralSettingItem(
        name: 'Eco Mode',
        commandName: GENERAL_SETTGINS_ECO_MODE,
        currentStatus: MapUtils.OM(config,['device','eco_mode']) as bool? ?? false,
        popUpOnChange: true,
        description: 'Energiesparmodus für das Gerät',
        icon: Icons.eco,
        confirmationTitle: 'Eco Mode ändern?',
        confirmationMessage: 'Möchten Sie den Eco Mode wirklich ändern? Dies kann die Geräteleistung beeinflussen.',
      ),
      GeneralSettingItem(
        name: 'Sichtbar',
        commandName: GENERAL_SETTINGS_DISCOVERABLE,
        currentStatus: MapUtils.OM(config,['device','discoverable']) as bool? ?? true,
        popUpOnChange: true,
        description: 'Gerät ist sichtbar',
        icon: Icons.visibility,
        confirmationMessage: 'Möchten Sie den Sichtbarkeit wirklich ändern?',
      ),
      GeneralSettingItem(
        name: 'Debug MQTT',
        commandName: GENERAL_SETTINGS_DEBUG_MQTT,
        currentStatus: MapUtils.OM(config,['debug','mqtt','enable']) as bool? ?? false,
        popUpOnChange: true,
        description: 'MQTT Debug-Protokollierung aktivieren',
        icon: Icons.bug_report,
        confirmationTitle: 'Debug MQTT ändern?',
        confirmationMessage: 'Möchten Sie MQTT Debug-Protokollierung wirklich ändern? Dies kann die Leistung beeinflussen und zusätzliche Logs erzeugen.',
      ),
      GeneralSettingItem(
        name: 'Debug Websocket',
        commandName: GENERAL_SETTINGS_DEBUG_WEBSOCKET,
        currentStatus: MapUtils.OM(config,['debug','websocket','enable']) as bool? ?? false,
        popUpOnChange: true,
        description: 'Websocket Debug-Protokollierung aktivieren',
        icon: Icons.bug_report,
        confirmationTitle: 'Debug Websocket ändern?',
        confirmationMessage: 'Möchten Sie Websocket Debug-Protokollierung wirklich ändern? Dies kann die Leistung beeinflussen und zusätzliche Logs erzeugen.',
      ),
    ];
  }

  @override
  Future<Map<String,dynamic>?> sendCommand(
    dynamic connectionService,
    String command,
    Map<String, dynamic> params,
  ) async {
    // Cast to ShellyService for type safety
    final service = connectionService as ShellyService;

    Map<String,dynamic>? ret;

    if(command == COMMAND_FETCH_DATA){
      ret = await service.sendCommand(ShellyCommands.emGetStatus,{"id":0});
    }else if(command == COMMAND_FETCH_DEVICE_INFO){
      ret = await service.sendCommand(ShellyCommands.getDeviceInfo,{"id":0});
    }else if(command == COMMAND_SET_WIFI){
      String ? ssid = params["ssid"];
      String ? password = params["password"];
      if(ssid == null || password == null){
        throw Exception("could not config wlan ssid or password empty");
      }
      ret = await service.sendCommand(ShellyCommands.wifiSetConfig,{"config": {"sta":{"ssid":ssid,"pass":password,"enable":true}}});
    }else if(command == COMMAND_SET_AP_CONFIG){
      var commandParams = <String,dynamic>{};
      commandParams["ssid"] = "whatever";//will not be accepted but when null wifi will be reset
      MapUtils.addIfAvailable(params,commandParams,"isOpen","is_open");
      MapUtils.addIfAvailable(params,commandParams,"enable");
      if(params.containsKey("rangeExtenderEnable")){
        commandParams["range_extender"] = {"enable":params["rangeExtenderEnable"]};
      }
      MapUtils.addIfAvailable(params,commandParams,"password","pass");
      if(commandParams["is_open"] == true){
        commandParams["pass"] = null;
      }
      // Send command: {"config": {"ap": {...}}}
      ret = await service.sendCommand(ShellyCommands.wifiSetConfig,{"config": {"ap": commandParams}});
    }else if(command == COMMAND_FETCH_WIFI_CONFIG) {
      ret = await service.sendCommand(ShellyCommands.wifiGetConfig, {});
    }else if(command == COMMAND_FETCH_SYS_CONFIG) {
      ret = await service.sendCommand(ShellyCommands.sysGetConfig, {});
    }else if(command == COMMAND_CONFIG_PORT) {
      int? port = params["port"];
      if(port == null){
        throw Exception("could not config port: port value is missing");
      }
      ret = await service.sendCommand(ShellyCommands.sysSetConfig,{"config": {"rpc_udp": {"listen_port": port}}});
    }else if(command == COMMAND_RESTART) {
      ret = await service.sendCommand(ShellyCommands.reboot,{"delay_ms": 5000});//wait for 5sec so bluetooth connection is terminated nicely
    }else if(command == COMMAND_SET_GENERAL_SETTING) {
      String? name = params["name"];
      bool? value = params["value"];

      if(name == null || value == null){
        throw Exception("could not set general setting: name or value is missing");
      }

      if(name == GENERAL_SETTINGS_DISCOVERABLE){
        ret = await service.sendCommand(ShellyCommands.sysSetConfig,{"config": {"device": {"discoverable": value}}});
      }else if(name == GENERAL_SETTGINS_ECO_MODE){
        ret = await service.sendCommand(ShellyCommands.sysSetConfig,{"config": {"device": {"eco_mode": value}}});
      }else if(name == GENERAL_SETTINGS_DEBUG_MQTT){
        ret = await service.sendCommand(ShellyCommands.sysSetConfig,{"config": {"debug": {"mqtt": {"enable": value}}}});
      }else if(name == GENERAL_SETTINGS_DEBUG_WEBSOCKET){
        ret = await service.sendCommand(ShellyCommands.sysSetConfig,{"config": {"debug": {"websocket": {"enable": value}}}});
      }
      ret = {"success": true, "setting": name, "value": value};
    }else if(command == COMMAND_SET_AUTH) {
      // This command requires access to device fields (authPassword, authUsername, deviceScr, data)
      // We need the device instance here
      throw UnimplementedError("COMMAND_SET_AUTH must be handled in device class due to required state access");
    }else if(command == COMMAND_FETCH_SCRIPTS) {
      ret = await service.sendCommand(ShellyCommands.scriptList, {});
    }else if(command == COMMAND_GET_SCRIPT_STATUS) {
      int? scriptId = params["id"];
      if(scriptId == null) throw Exception("Script ID missing");
      ret = await service.sendCommand(ShellyCommands.scriptGetStatus, {"id": scriptId});
    }else if(command == COMMAND_SET_SCRIPT_ENABLE) {
      int? scriptId = params["id"];
      bool? enable = params["enable"];
      if(scriptId == null || enable == null) throw Exception("Script ID or enable value missing");
      ret = await service.sendCommand(ShellyCommands.scriptSetConfig, {"id": scriptId, "config": {"enable": enable}});
    }else if(command == COMMAND_START_SCRIPT) {
      int? scriptId = params["id"];
      if(scriptId == null) throw Exception("Script ID missing");
      ret = await service.sendCommand(ShellyCommands.scriptStart, {"id": scriptId});
    }else if(command == COMMAND_STOP_SCRIPT) {
      int? scriptId = params["id"];
      if(scriptId == null) throw Exception("Script ID missing");
      ret = await service.sendCommand(ShellyCommands.scriptStop, {"id": scriptId});
    }else if(command == COMMAND_DELETE_SCRIPT) {
      int? scriptId = params["id"];
      if(scriptId == null) throw Exception("Script ID missing");
      ret = await service.sendCommand(ShellyCommands.scriptDelete, {"id": scriptId});
    }else if(command == COMMAND_CREATE_SCRIPT) {
      String? name = params["name"];
      if(name == null) throw Exception("Script name missing");
      ret = await service.sendCommand(ShellyCommands.scriptCreate, {"name": name});
      // Returns: {"id": 0}  (new script ID)
    }else if(command == COMMAND_RENAME_SCRIPT) {
      int? scriptId = params["id"];
      String? newName = params["name"];
      if(scriptId == null || newName == null) throw Exception("Script ID or name missing");
      ret = await service.sendCommand(ShellyCommands.scriptSetConfig, {
        "id": scriptId,
        "config": {"name": newName}
      });
    }else if(command == COMMAND_PUT_SCRIPT_CODE) {
      int? scriptId = params["id"];
      String? code = params["code"];
      bool? append = params["append"];  // default false
      if(scriptId == null || code == null) throw Exception("Script ID or code missing");

      // Check if we need to chunk (Bluetooth service + code > CODE_CHUNK_LENGTH chars)
      if ((service is ShellyBluetoothService && code.length > CODE_CHUNK_LENGTH) ||
          (code.length > CODE_CHUNK_LENGTH_WIFI)) {
        // Chunk the code into pieces of max CODE_CHUNK_LENGTH characters
        List<String> chunks = _chunkStringUtf8Safe(code,service is ShellyBluetoothService ? CODE_CHUNK_LENGTH : CODE_CHUNK_LENGTH_WIFI);

        // Send chunks sequentially
        // First chunk: append=false, subsequent chunks: append=true
        for (int i = 0; i < chunks.length; i++) {
          bool shouldAppend = i > 0;
          await service.sendCommand(ShellyCommands.scriptPutCode, {
            "id": scriptId,
            "code": chunks[i],
            "append": shouldAppend,
          });
          // If any chunk fails, the exception will propagate and stop the loop
        }

        ret = {"success": true, "chunks": chunks.length};
      } else {
        // Send as single chunk (WiFi service or code <= CODE_CHUNK_LENGTH chars)
        ret = await service.sendCommand(ShellyCommands.scriptPutCode, {
          "id": scriptId,
          "code": code,
          "append": append ?? false,
        });
      }
    }else if(command == COMMAND_GET_SCRIPT_CODE) {
      int? scriptId = params["id"];
      if(scriptId == null) throw Exception("Script ID missing");

      // Shelly Script.GetCode returns code in chunks
      // We need to call multiple times with offset until all code is retrieved
      String fullCode = "";
      int offset = 0;

      while (true) {
        // Build parameters based on service type
        Map<String, dynamic> getCodeParams = {
          "id": scriptId,
          "offset": offset,
        };

        // For Bluetooth, limit chunk size to CODE_CHUNK_LENGTH characters to match write chunk size
        if (service is ShellyBluetoothService) {
          getCodeParams["len"] = CODE_CHUNK_LENGTH;
        }else{
          getCodeParams["len"] = CODE_CHUNK_LENGTH_WIFI;
        }

        final response = await service.sendCommand(ShellyCommands.scriptGetCode, getCodeParams);

        if (response == null || response['data'] == null) break;

        final chunk = response['data'] as String;
        if (chunk.isEmpty) break;

        fullCode += chunk;
        offset += chunk.length;

        // Check if we've reached the end
        final left = response['left'] as int? ?? 0;
        if (left == 0) break;
      }

      ret = {"code": fullCode};
    }else if(command == COMMAND_SET_MAIN_POWER) {
      // Handle switch control (multi-instance support)
      int? id = params["id"] ?? 0; // Default to first instance
      bool? on = params["on"];
      if(on == null) throw Exception("'on' parameter missing for switch control");
      ret = await service.sendCommand('Switch.Set', {"id": id, "on": on});
    }else{
      throw UnimplementedError('Command not implemented: $command');
    }

    return ret;
  }

  /// Splits a string into chunks with a maximum size, respecting UTF-8 character boundaries
  ///
  /// This method ensures that multi-byte Unicode characters are never split across chunks.
  /// It uses Dart's runes (Unicode code points) to properly handle all characters.
  ///
  /// @param text - The string to split into chunks
  /// @param maxChunkSize - Maximum number of characters per chunk (default CODE_CHUNK_LENGTH)
  /// @return List of string chunks, each with at most maxChunkSize characters
  List<String> _chunkStringUtf8Safe(String text, int maxChunkSize) {
    if (text.length <= maxChunkSize) {
      return [text];
    }

    List<String> chunks = [];
    List<int> runes = text.runes.toList();
    int currentIndex = 0;

    while (currentIndex < runes.length) {
      // Calculate end index for this chunk
      int endIndex = currentIndex + maxChunkSize;
      if (endIndex > runes.length) {
        endIndex = runes.length;
      }

      // Extract chunk and convert back to string
      List<int> chunkRunes = runes.sublist(currentIndex, endIndex);
      String chunk = String.fromCharCodes(chunkRunes);
      chunks.add(chunk);

      currentIndex = endIndex;
    }

    return chunks;
  }

  /// Get detected modules from device data
  Map<String, List<int>> _getDetectedModules() {
    if (_device == null) return {};

    // Use cached modules if available
    if (_cachedModules != null) return _cachedModules!;

    // Extract from device.data['_detectedModules']
    final stored = _device!.data['_detectedModules'];
    if (stored is Map<String, dynamic>) {
      // Convert to Map<String, List<int>>
      final result = <String, List<int>>{};
      stored.forEach((key, value) {
        if (key is String && value is List) {
          result[key] = value.cast<int>();
        }
      });
      _cachedModules = result;
      return result;
    }

    return {};
  }

  /// Build data field from template
  DeviceDataField _buildDataField({
    required FieldTemplate template,
    required String moduleType,
    required int instanceId,
    required int instanceCount,
  }) {
    final suffix = instanceCount > 1 ? ' ${instanceId + 1}' : '';

    // Determine category based on template and instance
    String? category;
    if (template.category != null) {
      // Special handling: phase and totals categories always use template as-is
      if (template.category == 'totals' || template.category!.startsWith('phase')) {
        category = template.category;
      }
      // EM1/EM1data modules: ALWAYS assign instance categories
      else if (moduleType == 'em1' || moduleType == 'em1data') {
        category = 'messung_${instanceId + 1}';
      }
      // PM1 modules: ALWAYS assign instance categories
      else if (moduleType == 'pm1') {
        category = 'pm_messung_${instanceId + 1}';
      }
      // Switch modules: ALWAYS assign instance categories
      else if (moduleType == 'switch') {
        category = 'switch_${instanceId + 1}';
      }
      // Other multi-instance modules
      else if (instanceCount > 1) {
        category = '${moduleType}_${instanceId + 1}';
      }
      // Single instance of other modules: use template category
      else {
        category = template.category;
      }
    }

    return DeviceDataField(
      name: '${template.name}$suffix',
      type: template.type,
      valueExtractor: (data) {
        // Split path by '.' for nested fields (e.g., "temperature.tC")
        final pathParts = template.path.split('.');
        final value = pathParts.length > 1
          // Nested path: data -> module:id -> first_key -> second_key
          ? MapUtils.OM(data, ['data', '$moduleType:$instanceId', ...pathParts])
          // Simple path: data -> module:id -> key
          : MapUtils.OM(data, ['data', '$moduleType:$instanceId', template.path]);

        // Apply custom formatter if provided
        if (template.formatter != null) {
          return template.formatter!(value);
        }
        return value;
      },
      icon: template.icon,
      expertMode: template.isExpert,
      category: category,
      hideIfEmpty: template.hideIfEmpty,
    );
  }

  /// Build control item from template
  DeviceControlItem _buildControlItem({
    required ControlTemplate template,
    required String moduleType,
    required int instanceId,
    required int instanceCount,
  }) {
    final suffix = instanceCount > 1 ? ' ${instanceId + 1}' : '';

    return DeviceControlItem(
      name: '${template.name}$suffix',
      type: template.type,
      icon: template.icon,
      valueExtractor: (data) => MapUtils.OM(data,
          ['data', '$moduleType:$instanceId', template.statePath]),
      onChanged: (context, device, newValue) async {
        await DialogUtils.executeWithLoading(
          context,
          loadingMessage: template.getLoadingMessage(newValue),
          operation: () async {
            await device.sendCommand(template.commandName, {
              "id": instanceId,
              ...template.buildParams(newValue),
            });

            // Update local state
            if (device.data.containsKey('data')) {
              final moduleData = device.data['data']!['$moduleType:$instanceId'];
              if (moduleData is Map) {
                moduleData[template.statePath] = newValue;
                device.emitData(device.data['data']!);
              }
            }
          },
          showErrorDialog: true,
        );
      },
    );
  }
}