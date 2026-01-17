import 'package:flutter/material.dart';
import 'package:the_solar_app/constants/command_constants.dart';
import 'package:the_solar_app/models/devices/device_implementation.dart';
import 'package:the_solar_app/screens/configuration/percentage_power_limit_screen.dart';
import 'package:the_solar_app/screens/configuration/wifi_configuration_screen.dart';
import 'package:the_solar_app/screens/configuration/wifi_ap_configuration_screen.dart';
import 'package:the_solar_app/screens/configuration/online_monitoring_configuration_screen.dart';
import 'package:the_solar_app/services/devices/deyesun/deyesun_wifi_service.dart';
import 'package:the_solar_app/utils/dialog_utils.dart';
import 'package:the_solar_app/utils/map_utils.dart';
import 'package:the_solar_app/utils/message_utils.dart';
import 'package:the_solar_app/utils/navigation_utils.dart';
import '../../../generic_rendering/device_category_config.dart';
import '../../../generic_rendering/device_control_item.dart';
import '../../../generic_rendering/device_custom_section.dart';
import '../../../generic_rendering/device_data_field.dart';
import '../../../generic_rendering/device_menu_item.dart';
import '../../../generic_rendering/general_setting_item.dart';
import 'package:the_solar_app/screens/configuration/general_settings_screen.dart';

/// Simple implementation for DeyeSun devices
///
/// No future device types expected, so kept minimal and straightforward
class DeyeSunDeviceImplementation extends DeviceImplementation {
  @override
  List<DeviceMenuItem> getMenuItems() {
    return [
      DeviceMenuItem(
        name: 'Allgemeine Einstellungen',
        subtitle: 'Grundlegende Geräteeinstellungen verwalten',
        icon: Icons.settings,
        iconColor: Colors.purple,
        onTap: (ctx) async {
          final context = ctx.context;
          final device = ctx.device;

          // Build settings list with current device data
          final settings = getGeneralSettings(device.data);

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

          final wifiConfig = await DialogUtils.executeWithLoading(
            context,
            loadingMessage: 'Lade aktuelle Konfiguration...',
            operation: () => device.sendCommand(COMMAND_FETCH_WIFI_CONFIG, {}),
            onError: (e) => MessageUtils.showError(context, 'Fehler beim Laden der Konfiguration: $e'),
          );

          if (wifiConfig == null || !context.mounted) return;

          // Parse current SSID
          final currentSsid = wifiConfig['sta_setting_ssid'] as String?;

          final result = await NavigationUtils.pushConfigurationScreen(
            context,
            WiFiConfigurationScreen(
              device: device,
              currentSsid: currentSsid,
            ),
          );

          if (result == true) {
            MessageUtils.showSuccess(context, 'WiFi-Konfiguration abgeschlossen');
          }
        },
      ),
      DeviceMenuItem(
        name: 'Online-Monitoring konfigurieren',
        subtitle: 'Server für Datenübertragung einrichten',
        icon: Icons.cloud_upload,
        iconColor: Colors.blue,
        onTap: (ctx) async {
          final context = ctx.context;
          final device = ctx.device;

          final monitoringConfig = await DialogUtils.executeWithLoading(
            context,
            loadingMessage: 'Lade aktuelle Konfiguration...',
            operation: () => device.sendCommand(COMMAND_FETCH_ONLINE_MONITORING, {}),
            onError: (e) => MessageUtils.showError(context, 'Fehler beim Laden der Konfiguration: $e'),
          );

          if (monitoringConfig == null || !context.mounted) return;

          // Parse fetched data
          String? currentIpA;
          String? currentDomainA;
          String? currentPortA;
          String? currentProtocolA;
          String? currentIpB;
          String? currentDomainB;
          String? currentPortB;
          String? currentProtocolB;

          final serverA = monitoringConfig['server_a'] as Map<String, dynamic>?;
          if (serverA != null) {
            currentIpA = serverA['ip'] as String?;
            currentDomainA = serverA['domain'] as String?;
            currentPortA = serverA['port'] as String?;
            currentProtocolA = serverA['protocol'] as String?;
          }

          final serverB = monitoringConfig['server_b'] as Map<String, dynamic>?;
          if (serverB != null) {
            currentIpB = serverB['ip'] as String?;
            currentDomainB = serverB['domain'] as String?;
            currentPortB = serverB['port'] as String?;
            currentProtocolB = serverB['protocol'] as String?;
          }

          final result = await NavigationUtils.pushConfigurationScreen(
            context,
            OnlineMonitoringConfigurationScreen(
              device: device,
              currentIpA: currentIpA,
              currentDomainA: currentDomainA,
              currentPortA: currentPortA,
              currentProtocolA: currentProtocolA,
              currentIpB: currentIpB,
              currentDomainB: currentDomainB,
              currentPortB: currentPortB,
              currentProtocolB: currentProtocolB,
            ),
          );

          if (result == true) {
            MessageUtils.showSuccess(context, 'Online-Monitoring erfolgreich konfiguriert');
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
            builder: (dialogContext) => AlertDialog(
              title: const Text('Gerät neustarten'),
              content: const Text('Möchten Sie das Gerät wirklich neu starten?'),
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
            onSuccess: (_) => MessageUtils.showSuccess(context, 'Gerät wird neu gestartet'),
            onError: (e) => MessageUtils.showError(context, 'Fehler beim Neustarten des Geräts: $e'),
          );
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

          final apConfig = await DialogUtils.executeWithLoading(
            context,
            loadingMessage: 'Lade aktuelle Konfiguration...',
            operation: () => device.sendCommand(COMMAND_FETCH_AP_CONFIG, {}),
            onError: (e) => MessageUtils.showError(context, 'Fehler beim Laden der Konfiguration: $e'),
          );

          if (apConfig == null || !context.mounted) return;

          // Parse fetched data
          String? currentSsid = apConfig['ap_setting_ssid'] as String?;
          String? currentPassword = apConfig['ap_setting_wpakey'] as String?;
          bool currentEnabled = apConfig['ap_enabled'] as bool? ?? true;

          // Check if network is open (no authentication)
          final auth = apConfig['ap_setting_auth'] as String?;
          bool currentIsOpen = auth?.toUpperCase() == 'OPEN';

          final result = await NavigationUtils.pushConfigurationScreen(
            context,
            WiFiApConfigurationScreen(
              device: device,
              showSsidOption: true,
              showEnabledOption: true,
              showOpenOption: true,
              showRangeExtenderOption: false,
              currentSsid: currentSsid,
              currentPassword: currentPassword,
              currentIsOpen: currentIsOpen,
              currentEnabled: currentEnabled,
            ),
          );

          if (result == true) {
            MessageUtils.showSuccess(context, 'Access Point erfolgreich konfiguriert');
          }
        },
      ),
      DeviceMenuItem(
        name: 'Leistungsbegrenzung',
        subtitle: 'Ausgangsleistung begrenzen',
        icon: Icons.speed,
        iconColor: Colors.orange,
        onTap: (ctx) async {
          final context = ctx.context;
          final device = ctx.device;

          try {
            var powerRating = MapUtils.OM(device.data, ['config', 'power_rating']) as int?;
            if (powerRating == null || powerRating <= 0) {
              powerRating = MapUtils.OM(device.data, ['data', 'operating_power']) as int?;
              if (powerRating != null && powerRating <= 0) {
                powerRating = null;
              }
            }

            // Get current limit from Modbus data
            var currentLimit = MapUtils.OM(device.data, ['data', 'limit_percentage']) as int?;

            debugPrint("Current power rating is: $powerRating");
            debugPrint("Current limit is: $currentLimit");

            if (context.mounted) {
              final result = await NavigationUtils.pushConfigurationScreen(
                context,
                PercentagePowerLimitScreen(
                  device: device,
                  currentLimit: currentLimit,
                  totalPower: powerRating,
                ),
              );

              if (result == true && context.mounted) {
                MessageUtils.showSuccess(context, 'Leistungsbegrenzung erfolgreich gesetzt');
              }
            }
          } catch (e) {
            if (context.mounted) {
              MessageUtils.showError(context, 'Fehler: $e');
            }
          }
        },
      ),
    ];
  }

  /// Returns the list of general settings available for this DeyeSun device
  List<GeneralSettingItem> getGeneralSettings(Map<String, dynamic> data) {
    // Extract current power status from Modbus data
    // Check both device.data structure and direct structure
    var limitStatus = MapUtils.OM(data, ['data', 'limit_status']);

    // Fallback: if not found in nested structure, try direct access
    limitStatus ??= MapUtils.OM(data, ['limit_status']);

    // Default to false (off) if status cannot be determined
    final currentStatus = limitStatus == 1; // 1 = on, 2 = off

    return [
      GeneralSettingItem(
        name: 'Wechselrichter',
        commandName: GENERAL_SETTINGS_INVERTER_POWER,
        currentStatus: currentStatus,
        popUpOnChange: true,
        description: 'Wechselrichter ein- oder ausschalten',
        icon: Icons.power_settings_new,
      ),
    ];
  }

  @override
  List<DeviceControlItem> getControlItems() {
    return [];
  }

  @override
  List<DeviceDataField> getDataFields() {
    return [
      // Main production data (Modbus or HTTP fallback)
      /* //currently not working all times zero reported but included in other projects (doku)
      DeviceDataField(
        name: 'Aktuelle Leistung',
        type: DataFieldType.watt,
        valueExtractor: (data) {
          // Try Modbus data first, fall back to HTTP config
          final value = MapUtils.OM(data, ['data', 'ac_power']) ??
              MapUtils.OM(data, ['config', 'webdata_now_p']);
          return value;
        },
        icon: Icons.bolt,
        expertMode: false,
        precision: 1,
      ),*/
      DeviceDataField(
        name: 'Tagesertrag',
        type: DataFieldType.energy,
        valueExtractor: (data) {
          final value = MapUtils.OM(data, ['data', 'day_energy']) ??
              MapUtils.OM(data, ['config', 'webdata_today_e']);
          return value;
        },
        icon: Icons.wb_sunny,
        expertMode: false,
      ),
      DeviceDataField(
        name: 'Gesamtertrag',
        type: DataFieldType.energy,
        valueExtractor: (data) {
          final value = MapUtils.OM(data, ['data', 'total_energy']) ??
              MapUtils.OM(data, ['config', 'webdata_total_e']);
          return value;
        },
        divisor: 0.001,  // Convert kWh to Wh (divide by 0.001 = multiply by 1000)
        icon: Icons.show_chart,
        expertMode: false,
      ),

      // Grid AC data
      DeviceDataField(
        name: 'Netzspannung',
        type: DataFieldType.voltage,
        valueExtractor: (data) => MapUtils.OM(data, ['data', 'ac_voltage']),
        icon: Icons.electric_bolt,
        expertMode: false,
        category: 'ac',
      ),
      DeviceDataField(
        name: 'Netzstrom',
        type: DataFieldType.current,
        valueExtractor: (data) => MapUtils.OM(data, ['data', 'ac_current']),
        icon: Icons.flash_on,
        expertMode: false,
        category: 'ac',
      ),
      DeviceDataField(
        name: 'Netzfrequenz',
        type: DataFieldType.frequency,
        valueExtractor: (data) => MapUtils.OM(data, ['data', 'ac_frequency']),
        icon: Icons.waves,
        expertMode: true,
        category: 'ac',
      ),
      DeviceDataField(
        name: 'AC Leistung',
        type: DataFieldType.watt,
        valueExtractor: (data) {
          var value = MapUtils.OM(data, ['data', 'ac_power']);
          if(value == null || value == 0){
            value = MapUtils.OM(data, ['config', 'webdata_now_p']);
          }
          return value;
        },
        icon: Icons.bolt,
        expertMode: false,
        category: 'ac',
        precision: 1,
      ),

      // PV1 String
      DeviceDataField(
        name: 'PV1 Spannung',
        type: DataFieldType.voltage,
        valueExtractor: (data) => MapUtils.OM(data, ['data', 'pv1_voltage']),
        icon: Icons.solar_power,
        expertMode: true,
        category: 'pv1',
      ),
      DeviceDataField(
        name: 'PV1 Strom',
        type: DataFieldType.current,
        valueExtractor: (data) => MapUtils.OM(data, ['data', 'pv1_current']),
        icon: Icons.solar_power,
        expertMode: true,
        category: 'pv1',
      ),
      DeviceDataField(
        name: 'PV1 Leistung',
        type: DataFieldType.watt,
        valueExtractor: (data) => MapUtils.OM(data, ['data', 'pv1_power']),
        icon: Icons.solar_power,
        expertMode: true,
        category: 'pv1',
        precision: 1,
      ),
      DeviceDataField(
        name: 'PV1 Gesamtertrag',
        type: DataFieldType.energy,
        valueExtractor: (data) => MapUtils.OM(data, ['data', 'pv1_total_energy']),
        divisor: 0.001,  // Convert kWh to Wh (divide by 0.001 = multiply by 1000)
        icon: Icons.show_chart,
        expertMode: true,
        category: 'pv1',
      ),

      // PV2 String
      DeviceDataField(
        name: 'PV2 Spannung',
        type: DataFieldType.voltage,
        valueExtractor: (data) => MapUtils.OM(data, ['data', 'pv2_voltage']),
        icon: Icons.solar_power,
        expertMode: true,
        category: 'pv2',
      ),
      DeviceDataField(
        name: 'PV2 Strom',
        type: DataFieldType.current,
        valueExtractor: (data) => MapUtils.OM(data, ['data', 'pv2_current']),
        icon: Icons.solar_power,
        expertMode: true,
        category: 'pv2',
      ),
      DeviceDataField(
        name: 'PV2 Leistung',
        type: DataFieldType.watt,
        valueExtractor: (data) => MapUtils.OM(data, ['data', 'pv2_power']),
        icon: Icons.solar_power,
        expertMode: true,
        category: 'pv2',
        precision: 1,
      ),
      DeviceDataField(
        name: 'PV2 Gesamtertrag',
        type: DataFieldType.energy,
        valueExtractor: (data) => MapUtils.OM(data, ['data', 'pv2_total_energy']),
        divisor: 0.001,  // Convert kWh to Wh (divide by 0.001 = multiply by 1000)
        icon: Icons.show_chart,
        expertMode: true,
        category: 'pv2',
      ),

      // PV3 String
      DeviceDataField(
        name: 'PV3 Spannung',
        type: DataFieldType.voltage,
        valueExtractor: (data) => MapUtils.OM(data, ['data', 'pv3_voltage']),
        icon: Icons.solar_power,
        expertMode: true,
        category: 'pv3',
      ),
      DeviceDataField(
        name: 'PV3 Strom',
        type: DataFieldType.current,
        valueExtractor: (data) => MapUtils.OM(data, ['data', 'pv3_current']),
        icon: Icons.solar_power,
        expertMode: true,
        category: 'pv3',
      ),
      DeviceDataField(
        name: 'PV3 Leistung',
        type: DataFieldType.watt,
        valueExtractor: (data) => MapUtils.OM(data, ['data', 'pv3_power']),
        icon: Icons.solar_power,
        expertMode: true,
        category: 'pv3',
        precision: 1,
      ),
      DeviceDataField(
        name: 'PV3 Gesamtertrag',
        type: DataFieldType.energy,
        valueExtractor: (data) => MapUtils.OM(data, ['data', 'pv3_total_energy']),
        divisor: 0.001,  // Convert kWh to Wh (divide by 0.001 = multiply by 1000)
        icon: Icons.show_chart,
        expertMode: true,
        category: 'pv3',
      ),

      // PV4 String
      DeviceDataField(
        name: 'PV4 Spannung',
        type: DataFieldType.voltage,
        valueExtractor: (data) => MapUtils.OM(data, ['data', 'pv4_voltage']),
        icon: Icons.solar_power,
        expertMode: true,
        category: 'pv4',
      ),
      DeviceDataField(
        name: 'PV4 Strom',
        type: DataFieldType.current,
        valueExtractor: (data) => MapUtils.OM(data, ['data', 'pv4_current']),
        icon: Icons.solar_power,
        expertMode: true,
        category: 'pv4',
      ),
      DeviceDataField(
        name: 'PV4 Leistung',
        type: DataFieldType.watt,
        valueExtractor: (data) => MapUtils.OM(data, ['data', 'pv4_power']),
        icon: Icons.solar_power,
        expertMode: true,
        category: 'pv4',
        precision: 1,
      ),
      DeviceDataField(
        name: 'PV4 Gesamtertrag',
        type: DataFieldType.energy,
        valueExtractor: (data) => MapUtils.OM(data, ['data', 'pv4_total_energy']),
        divisor: 0.001,  // Convert kWh to Wh (divide by 0.001 = multiply by 1000)
        icon: Icons.show_chart,
        expertMode: true,
        category: 'pv4',
      ),

      // Total DC Power
      DeviceDataField(
        name: 'DC Gesamtleistung',
        type: DataFieldType.watt,
        valueExtractor: (data) => MapUtils.OM(data, ['data', 'dc_total_power']),
        icon: Icons.electrical_services,
        expertMode: false,
        precision: 1,
      ),

      // System information
      DeviceDataField(
        name: 'Temperatur',
        type: DataFieldType.temperature,
        valueExtractor: (data) => MapUtils.OM(data, ['data', 'radiator_temp']),
        icon: Icons.thermostat,
        expertMode: true,
        category: 'system',
      ),
      DeviceDataField(
        name: 'Betriebszeit',
        type: DataFieldType.none,
        valueExtractor: (data) {
          final value = MapUtils.OM(data, ['data', 'uptime']);
          if (value == null) return null;
          final minutes = int.tryParse(value.toString()) ?? 0;
          final hours = minutes ~/ 60;
          final mins = minutes % 60;
          return '${hours}h ${mins}min';
        },
        icon: Icons.timer,
        expertMode: true,
        category: 'system',
      ),

      DeviceDataField(
        name: 'Limit-Status',
        type: DataFieldType.none,
        valueExtractor: (data) {
          final value = MapUtils.OM(data, ['data', 'limit_status']);
          if (value == null) return null;
          final status = int.tryParse(value.toString());
          if (status == 1) return 'Ein';
          if (status == 2) return 'Aus';
          return 'Unbekannt';
        },
        icon: Icons.power_settings_new,
        expertMode: false,
      ),

      // Power Limit Control - Percentage
      DeviceDataField(
        name: 'Leistungsbegrenzung',
        type: DataFieldType.percentage,
        valueExtractor: (data) => MapUtils.OM(data, ['data', 'limit_percentage']),
        icon: Icons.speed,
        expertMode: false,
      ),

      // Power Limit Control - Watt
      DeviceDataField(
        name: 'Leistungsbegrenzung',
        type: DataFieldType.watt,
        valueExtractor: (data) {
          final value = MapUtils.OM(data, ['data', 'limit_percentage']) as num?;
          final powerRating = MapUtils.OM(data, ['config', 'power_rating']) as num?;
          // Calculate watt value, DataFieldType.watt handles formatting
          return (value != null && powerRating != null) ? value * powerRating * 0.01 : null;
        },
        icon: Icons.speed,
        expertMode: false,
      ),

      // Device information
      DeviceDataField(
        name: 'Modell',
        type: DataFieldType.none,
        valueExtractor: (data) => MapUtils.OM(data, ['config', 'model']),
        icon: Icons.device_hub,
        expertMode: false,
        showDetailButton: true,
        category: 'device_info',
      ),
      DeviceDataField(
        name: 'Nennleistung',
        type: DataFieldType.none,
        valueExtractor: (data) {
          final value = MapUtils.OM(data, ['config', 'power_rating']);
          return value != null ? '$value W' : null;
        },
        icon: Icons.bolt_outlined,
        expertMode: true,
        category: 'device_info',
      ),

      // HTTP-only configuration fields
      DeviceDataField(
        name: 'Firmware Version',
        type: DataFieldType.none,
        valueExtractor: (data) => MapUtils.OM(data, ['config', 'cover_ver']),
        icon: Icons.info,
        expertMode: true,
        showDetailButton: true,
        category: 'device_info',
      )
    ];
  }

  @override
  List<DeviceCustomSection> getCustomSections() => [];

  @override
  List<DeviceCategoryConfig> getCategoryConfigs() {
    return [
      const DeviceCategoryConfig(
        category: 'pv1',
        displayName: 'PV1',
        layout: CategoryLayout.standard,
        order: 10,
        // PV1 always shown - use defaults (both false)
      ),
      const DeviceCategoryConfig(
        category: 'pv2',
        displayName: 'PV2',
        layout: CategoryLayout.standard,
        order: 20,
        hideWhenAllNull: true,
        hideWhenAllZero: true,
      ),
      const DeviceCategoryConfig(
        category: 'pv3',
        displayName: 'PV3',
        layout: CategoryLayout.standard,
        order: 30,
        hideWhenAllNull: true,
        hideWhenAllZero: true,
      ),
      const DeviceCategoryConfig(
        category: 'pv4',
        displayName: 'PV4',
        layout: CategoryLayout.standard,
        order: 40,
        hideWhenAllNull: true,
        hideWhenAllZero: true,
      ),
      const DeviceCategoryConfig(
        category: 'ac',
        displayName: 'AC (Netz)',
        layout: CategoryLayout.standard,
        order: 50,
        hideWhenAllNull: true,
        hideWhenAllZero: true,
      ),
      const DeviceCategoryConfig(
        category: 'system',
        displayName: 'System',
        layout: CategoryLayout.standard,
        order: 60,
        hideWhenAllNull: true,
        hideWhenAllZero: true,
      ),
      const DeviceCategoryConfig(
        category: 'device_info',
        displayName: 'Geräteinformationen',
        layout: CategoryLayout.oneLine,
        order: 70,
        hideWhenAllNull: true,
        hideWhenAllZero: true,
      ),
    ];
  }

  @override
  IconData getDeviceIcon() => Icons.solar_power;

  @override
  String getFetchCommand() => 'fetchStatus';

  @override
  Future<Map<String, dynamic>?> sendCommand(
    dynamic connectionService,
    String command,
    Map<String, dynamic> params,
  ) async {
    final service = connectionService as DeyeSunWifiService;

    if (command == COMMAND_FETCH_DATA) {
      return await service.fetchStatus();
    } else if (command == COMMAND_FETCH_AP_CONFIG) {
      // Fetch Access Point configuration from wirepoint.html (SSID, auth, encryption, etc.)
      final apConfig = await service.fetchConfig('wirepoint');

      // Fetch enabled status from hide_set_edit.html (apsta_mode)
      final apEnabled = await service.fetchConfig('hide_set_edit');

      // Merge both results
      return {
        ...?apConfig,
        'apsta_mode': apEnabled?['apsta_mode'],
        'ap_enabled': apEnabled?['apsta_mode'] == '0', // true if "0" (AP+STA mode)
      };
    } else if (command == COMMAND_FETCH_WIFI_CONFIG) {
      // Fetch WiFi/STA configuration from wireless.html
      return await service.fetchConfig('wireless');
    } else if (command == COMMAND_RESTART) {
      return await service.sendCommand(
        'up_succ',
        'autorestart',
        {'HF_PROCESS_CMD': 'RESTART'},
      );
    } else if (command == COMMAND_FETCH_ONLINE_MONITORING) {
      // Fetch online monitoring configuration from hide_set_edit.html
      final config = await service.fetchConfig('hide_set_edit');

      if (config != null) {
        // Parse server_a: format is "{ip},{domain},{port},{protocol}"
        final serverA = config['server_a'] as String?;
        Map<String, String> serverAData = {};
        if (serverA != null && serverA.isNotEmpty) {
          final parts = serverA.split(',');
          if (parts.length >= 4) {
            serverAData = {
              'ip': parts[0].trim(),
              'domain': parts[1].trim(),
              'port': parts[2].trim(),
              'protocol': parts[3].trim(),
            };
          }
        }

        // Parse server_b: format is "{ip},{domain},{port},{protocol}"
        final serverB = config['server_b'] as String?;
        Map<String, String> serverBData = {};
        if (serverB != null && serverB.isNotEmpty) {
          final parts = serverB.split(',');
          if (parts.length >= 4) {
            serverBData = {
              'ip': parts[0].trim(),
              'domain': parts[1].trim(),
              'port': parts[2].trim(),
              'protocol': parts[3].trim(),
            };
          }
        }

        return {
          'server_a': serverAData,
          'server_b': serverBData,
        };
      }
    } else if (command == COMMAND_SET_ONLINE_MONITORING) {
      // Extract parameters for Server A
      final ipA = params['ip_a'] as String? ?? '';
      final domainA = params['domain_a'] as String? ?? '';
      final portA = params['port_a'] as String? ?? '';
      final protocolA = params['protocol_a'] as String? ?? 'TCP';

      // Extract parameters for Server B
      final ipB = params['ip_b'] as String? ?? '';
      final domainB = params['domain_b'] as String? ?? '';
      final portB = params['port_b'] as String? ?? '';
      final protocolB = params['protocol_b'] as String? ?? 'TCP';

      // Build form data for Server A
      final formData = {
        'server_a': '$ipA,$domainA,$portA,$protocolA',
        'cnmo_ip_a': ipA,
        'cnmo_ds_a': domainA,
        'cnmo_pt_a': portA,
        'cnmo_tp_a': protocolA,
        'server_b': '$ipB,$domainB,$portB,$protocolB',
        'cnmo_ip_b': ipB,
        'cnmo_ds_b': domainB,
        'cnmo_pt_b': portB,
        'cnmo_tp_b': protocolB,
      };

      // Send Server A configuration
      final result = await service.sendCommand(
        'do_cmd',
        'hide_set_edit',
        formData,
      );

      if (result == null) {
        throw Exception('Failed to configure Server A');
      }

      return {'success': true};
    } else {
      throw UnimplementedError(
        'Command type not yet implemented for DeyeSun: $command',
      );
    }

    return null;
  }
}
