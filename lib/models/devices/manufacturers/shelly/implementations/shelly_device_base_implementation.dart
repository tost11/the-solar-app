import 'package:flutter/material.dart';
import 'package:the_solar_app/models/devices/device_implementation.dart';

import 'package:the_solar_app/constants/command_constants.dart';
import 'package:the_solar_app/screens/configuration/authentication_screen.dart';
import 'package:the_solar_app/screens/configuration/general_settings_screen.dart';
import 'package:the_solar_app/screens/configuration/port_configuration_screen.dart';
import 'package:the_solar_app/screens/configuration/wifi_ap_configuration_screen.dart';
import 'package:the_solar_app/screens/configuration/wifi_configuration_screen.dart';
import 'package:the_solar_app/services/devices/shelly/shelly_service.dart';
import 'package:the_solar_app/utils/dialog_utils.dart';
import 'package:the_solar_app/utils/map_utils.dart';
import 'package:the_solar_app/utils/message_utils.dart';
import '../../../generic_rendering/device_control_item.dart';
import '../../../generic_rendering/device_custom_section.dart';
import '../../../generic_rendering/device_data_field.dart';
import '../../../generic_rendering/device_menu_item.dart';
import '../../../generic_rendering/general_setting_item.dart';

class ShellyDeviceBaseImplementation extends DeviceImplementation {

  @override
  List<DeviceMenuItem> getMenuItems(){
    return [
      DeviceMenuItem(
        name: 'Allgemeine Einstellungen',
        subtitle: 'Grundlegende Geräteeinstellungen verwalten',
        icon: Icons.settings,
        iconColor: Colors.purple,
        onTap: (context, device) async {
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
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => GeneralSettingsScreen(
                device: device,
                settings: settings,
              ),
            ),
          );
        },
      ),
      DeviceMenuItem(
        name: 'WiFi konfigurieren',
        subtitle: 'Netzwerkverbindung einrichten',
        icon: Icons.wifi,
        iconColor: Colors.green,
        onTap: (context, device) async {
          final resp = await DialogUtils.executeWithLoading(
            context,
            loadingMessage: 'Lade aktuelle Konfiguration...',
            operation: () => device.sendCommand(COMMAND_FETCH_WIFI_CONFIG, {}),
            onError: (e) => MessageUtils.showError(context, 'Konnte WiFi-Konfiguration nicht laden: $e'),
          );

          if (resp == null || !context.mounted) return;

          // Extract current SSID from sta attribute
          String? currentSsid = MapUtils.OMas<String?>(resp, ["sta", "ssid"], null);

          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => WiFiConfigurationScreen(
                device: device,
                currentSsid: currentSsid,
              ),
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
        onTap: (context, device) async {
          final resp = await DialogUtils.executeWithLoading(
            context,
            loadingMessage: 'Lade Gerätedaten...',
            operation: () => device.sendCommand(COMMAND_FETCH_WIFI_CONFIG, {}),
            onError: (e) => MessageUtils.showError(context, 'Konnte Gerätedaten nicht abrufen: $e'),
          );

          if (resp == null || !context.mounted) return;

          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => WiFiApConfigurationScreen(
                device: device,
                currentIsOpen: MapUtils.OMas(resp,["ap","is_open"],true),
                currentRangeExtender: MapUtils.OMas(resp,["ap","range_extender","enable"],true),
                currentEnabled: MapUtils.OMas(resp,["ap","enable"],true),
                showSsidOption: false,
                showEnabledOption: true,
                showOpenOption: true,
                showRangeExtenderOption: true,
              ),
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
        onTap: (context, device) async {
          final resp = await DialogUtils.executeWithLoading(
            context,
            loadingMessage: 'Lade Systemkonfiguration...',
            operation: () => device.sendCommand(COMMAND_FETCH_SYS_CONFIG, {}),
            onError: (e) => MessageUtils.showError( context, 'Konnte Systemkonfiguration nicht laden: $e'),
          );

          if (resp == null || !context.mounted) return;

          // Extract current port from rpc_udp.listen_port
          int? currentPort = MapUtils.OMas<int?>(resp, ["rpc_udp", "listen_port"], null);

          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PortConfigurationScreen(
                device: device,
                portName: 'RPC UDP Port',
                portDescription: 'Konfigurieren Sie den UDP Port für RPC Kommunikation, nach der Konfiguration muss das Gerät neugestartet werden um die Änderrungen zu übernehmen.',
                currentPort: currentPort,
                commandParameterName: 'port',
              ),
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
        onTap: (context, device) async {
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
        onTap: (context, device) async {
          await DialogUtils.executeWithLoading(
            context,
            loadingMessage: 'Lade Gerätedaten...',
            operation: () => device.sendCommand(COMMAND_FETCH_DEVICE_INFO, {"id": 0}),
            showErrorDialog: false,
          );

          if (!context.mounted) return;

          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AuthenticationScreen(
                device: device,
                currentUsername: 'admin',
                currentPassword: null,
                currentEnabled: MapUtils.OMas(device.data,["config","auth_en"],false),
                usernameEditable: false,
              ),
            ),
          );
        },
      ),
    ];
  }

  @override
  List<DeviceControlItem> getControlItems(){return [];}

  @override
  List<DeviceDataField> getDataFields(){return [];}

  @override
  List<DeviceCustomSection> getCustomSections() => [];

  @override
  String getFetchCommand(){
    return "Shelly.GetStatus";
  }

  @override
  IconData getDeviceIcon(){
    return Icons.broadcast_on_home;
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
      ret = await service.sendCommand('EM.GetStatus',{"id":0});
    }else if(command == COMMAND_FETCH_DEVICE_INFO){
      ret = await service.sendCommand('Shelly.GetDeviceInfo',{"id":0});
    }else if(command == COMMAND_SET_WIFI){
      String ? ssid = params["ssid"];
      String ? password = params["password"];
      if(ssid == null || password == null){
        throw Exception("could not config wlan ssid or password empty");
      }
      ret = await service.sendCommand('WiFi.SetConfig',{"config": {"sta":{"ssid":ssid,"pass":password,"enable":true}}});
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
      ret = await service.sendCommand('WiFi.SetConfig',{"config": {"ap": commandParams}});
    }else if(command == COMMAND_FETCH_WIFI_CONFIG) {
      ret = await service.sendCommand('WiFi.GetConfig', {});
    }else if(command == COMMAND_FETCH_SYS_CONFIG) {
      ret = await service.sendCommand('Sys.GetConfig', {});
    }else if(command == COMMAND_CONFIG_PORT) {
      int? port = params["port"];
      if(port == null){
        throw Exception("could not config port: port value is missing");
      }
      ret = await service.sendCommand('Sys.SetConfig',{"config": {"rpc_udp": {"listen_port": port}}});
    }else if(command == COMMAND_RESTART) {
      ret = await service.sendCommand('Shelly.Reboot',{"delay_ms": 5000});//wait for 5sec so bluetooth connection is terminated nicely
    }else if(command == COMMAND_SET_GENERAL_SETTING) {
      String? name = params["name"];
      bool? value = params["value"];

      if(name == null || value == null){
        throw Exception("could not set general setting: name or value is missing");
      }

      if(name == GENERAL_SETTINGS_DISCOVERABLE){
        ret = await service.sendCommand('Sys.SetConfig',{"config": {"device": {"discoverable": value}}});
      }else if(name == GENERAL_SETTGINS_ECO_MODE){
        ret = await service.sendCommand('Sys.SetConfig',{"config": {"device": {"eco_mode": value}}});
      }else if(name == GENERAL_SETTINGS_DEBUG_MQTT){
        ret = await service.sendCommand('Sys.SetConfig',{"config": {"debug": {"mqtt": {"enable": value}}}});
      }else if(name == GENERAL_SETTINGS_DEBUG_WEBSOCKET){
        ret = await service.sendCommand('Sys.SetConfig',{"config": {"debug": {"websocket": {"enable": value}}}});
      }
      ret = {"success": true, "setting": name, "value": value};
    }else if(command == COMMAND_SET_AUTH) {
      // This command requires access to device fields (authPassword, authUsername, deviceScr, data)
      // We need the device instance here
      throw UnimplementedError("COMMAND_SET_AUTH must be handled in device class due to required state access");
    }else{
      throw UnimplementedError('Command not implemented: $command');
    }

    return ret;
  }
}