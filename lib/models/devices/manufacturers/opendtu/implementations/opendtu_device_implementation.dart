import 'package:flutter/material.dart';
import 'package:the_solar_app/constants/command_constants.dart';
import 'package:the_solar_app/models/devices/device_implementation.dart';
import 'package:the_solar_app/screens/configuration/authentication_screen.dart';
import 'package:the_solar_app/screens/configuration/percentage_power_limit_screen.dart';
import 'package:the_solar_app/screens/configuration/wifi_configuration_screen.dart';
import 'package:the_solar_app/services/devices/opendtu/opendtu_wifi_service.dart';
import 'package:the_solar_app/utils/dialog_utils.dart';
import 'package:the_solar_app/utils/map_utils.dart';
import 'package:the_solar_app/utils/message_utils.dart';
import 'package:the_solar_app/widgets/opendtu_inverter_list_widget.dart';
import '../../../generic_rendering/device_category_config.dart';
import '../../../generic_rendering/device_control_item.dart';
import '../../../generic_rendering/device_custom_section.dart';
import '../../../generic_rendering/device_data_field.dart';
import '../../../mixins/device_authentication_mixin.dart';
import '../../../generic_rendering/device_menu_item.dart';

/// Simple implementation for OpenDTU devices
///
/// No future device types expected, so kept minimal and straightforward
class OpenDTUDeviceImplementation extends DeviceImplementation {
  @override
  List<DeviceMenuItem> getMenuItems() {
    return [
      DeviceMenuItem(
        name: 'Authentifizierung',
        subtitle: 'Passwort konfigurieren',
        icon: Icons.lock,
        iconColor: Colors.blue,
        onTap: (context, device) async {
          final config = await DialogUtils.executeWithLoading(
            context,
            loadingMessage: 'Lade Authentifizierungs-Konfiguration...',
            operation: () => device.sendCommand(COMMAND_FETCH_AUTH, {}),
            onError: (e) => MessageUtils.showError(
                context, 'Konnte Authentifizierungs-Konfiguration nicht laden: $e'),
          );

          if (config == null || !context.mounted) return;

          final allowReadonly = config['allow_readonly'] as bool? ?? false;
          var authDev = device as DeviceAuthenticationMixin;
          authDev.authPassword = config['password'] as String?;

          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AuthenticationScreen(
                device: device,
                currentUsername: 'admin',
                currentPassword: authDev.authPassword,
                currentEnabled: allowReadonly,
                usernameEditable: false,
              ),
            ),
          );

          if (result == true && context.mounted) {
            MessageUtils.showSuccess(
                context, 'Authentifizierung erfolgreich konfiguriert');
          }
        },
      ),
      DeviceMenuItem(
        name: 'WiFi-Konfiguration',
        subtitle: 'WLAN-Verbindung einrichten',
        icon: Icons.wifi,
        iconColor: Colors.green,
        onTap: (context, device) async {
          final config = await DialogUtils.executeWithLoading(
            context,
            loadingMessage: 'Lade aktuelle Konfiguration...',
            operation: () => device.sendCommand(COMMAND_FETCH_WIFI_CONFIG, {}),
            onError: (e) => MessageUtils.showError(
                context, 'Konnte WiFi-Konfiguration nicht laden: $e'),
          );

          if (config == null || !context.mounted) return;

          String? currentSsid = config['ssid'] as String?;

          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  WiFiConfigurationScreen(device: device, currentSsid: currentSsid),
            ),
          );

          if (result == true && context.mounted) {
            MessageUtils.showSuccess(context, 'WiFi erfolgreich konfiguriert');
          }
        },
      ),
      DeviceMenuItem(
        name: 'Leistungslimit (Prozent)',
        subtitle: 'Wechselrichterleistung begrenzen',
        icon: Icons.bolt,
        iconColor: Colors.orange,
        onTap: (context, device) async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PercentagePowerLimitScreen(device: device),
            ),
          );
        },
      ),
      DeviceMenuItem(
        name: 'Wechselrichter ein-/ausschalten',
        subtitle: 'Schaltet alle Wechselrichter',
        icon: Icons.power_settings_new,
        iconColor: Colors.red,
        onTap: (context, device) async {
          final invertersData = device.data['data']?['inverters'] as List?;
          if (invertersData == null || invertersData.isEmpty) {
            MessageUtils.showWarning(
                context, 'Keine Wechselrichter gefunden');
            return;
          }

          final confirmed = await showDialog<bool>(
            context: context,
            builder: (dialogContext) => AlertDialog(
              title: const Text('Wechselrichter schalten'),
              content: const Text(
                  'Möchten Sie alle Wechselrichter ein- oder ausschalten?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, false),
                  child: const Text('Abbrechen'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, true),
                  child: const Text('Ausschalten'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, null),
                  child: const Text('Einschalten'),
                ),
              ],
            ),
          );

          if (confirmed == false) return;

          final power = confirmed == null;

          await DialogUtils.executeWithLoading(
            context,
            loadingMessage:
                power ? 'Schalte Wechselrichter ein...' : 'Schalte Wechselrichter aus...',
            operation: () async {
              for (var inverter in invertersData) {
                final serial = inverter['serial'] as String?;
                if (serial != null) {
                  await device.sendCommand(COMMAND_SET_MAIN_POWER, {
                    'serial': serial,
                    'manufacturer': 'hoymiles',
                    'power': power,
                  });
                }
              }
            },
            onSuccess: (_) => MessageUtils.showSuccess(
                context, power ? 'Wechselrichter eingeschaltet' : 'Wechselrichter ausgeschaltet'),
            onError: (e) => MessageUtils.showError(
                context, 'Fehler beim Schalten: $e'),
          );
        },
      ),
      DeviceMenuItem(
        name: 'Gerät neustarten',
        subtitle: 'OpenDTU neu starten',
        icon: Icons.restart_alt,
        iconColor: Colors.purple,
        onTap: (context, device) async {
          final confirmed = await showDialog<bool>(
            context: context,
            builder: (dialogContext) => AlertDialog(
              title: const Text('Gerät neustarten?'),
              content:
                  const Text('Das Gerät wird neugestartet. Fortfahren?'),
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
            operation: () => device.sendCommand(COMMAND_RESTART, {}),
            onSuccess: (_) =>
                MessageUtils.showSuccess(context, 'Gerät wird neu gestartet'),
            onError: (e) =>
                MessageUtils.showError(context, 'Fehler beim Neustarten: $e'),
          );
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
        name: 'Chip Model',
        type: DataFieldType.none,
        valueExtractor: (data) => MapUtils.OM(data, ['config', 'chipmodel']),
        icon: Icons.memory,
        expertMode: true,
        showDetailButton: true,
        category: 'system',
      ),
      DeviceDataField(
        name: 'Uptime',
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
        name: 'CPU Temperature',
        type: DataFieldType.temperature,
        valueExtractor: (data) => MapUtils.OM(data, ['config', 'cputemp']),
        icon: Icons.thermostat,
        expertMode: true,
        category: 'system',
      ),
      DeviceDataField(
        name: 'Heap',
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
        name: 'Sketch',
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
        name: 'LittleFS',
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
        title: 'Wechselrichter',
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
        category: 'system',
        displayName: 'System',
        layout: CategoryLayout.standard,
        order: 10,
      ),
      const DeviceCategoryConfig(
        category: 'memory',
        displayName: 'Speicher',
        layout: CategoryLayout.oneLine,
        order: 20,
      ),
    ];
  }

  @override
  IconData getDeviceIcon() => Icons.router;

  @override
  String getFetchCommand() => 'fetchSystemInfo';

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
    } else {
      throw UnimplementedError('Command not yet implemented: $command');
    }
  }
}
