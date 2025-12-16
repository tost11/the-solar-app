import 'package:flutter/material.dart';
import 'package:the_solar_app/models/devices/device_implementation.dart';

import 'package:the_solar_app/constants/command_constants.dart';
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
import 'package:the_solar_app/utils/map_utils.dart';
import 'package:the_solar_app/utils/message_utils.dart';
import '../../../generic_rendering/device_control_item.dart';
import '../../../generic_rendering/device_custom_section.dart';
import '../../../generic_rendering/device_data_field.dart';
import '../../../generic_rendering/device_menu_item.dart';
import '../../../generic_rendering/general_setting_item.dart';

class ShellyDeviceBaseImplementation extends DeviceImplementation {

  static const int CODE_CHUNK_LENGTH = 1000;
  static const int CODE_CHUNK_LENGTH_WIFI = 4000;

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
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ShellyScriptsScreen(
                device: device,
                scripts: scripts,
                systemId: systemId,  // Pass systemId for device filtering
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
    }else if(command == COMMAND_FETCH_SCRIPTS) {
      ret = await service.sendCommand('Script.List', {});
    }else if(command == COMMAND_GET_SCRIPT_STATUS) {
      int? scriptId = params["id"];
      if(scriptId == null) throw Exception("Script ID missing");
      ret = await service.sendCommand('Script.GetStatus', {"id": scriptId});
    }else if(command == COMMAND_SET_SCRIPT_ENABLE) {
      int? scriptId = params["id"];
      bool? enable = params["enable"];
      if(scriptId == null || enable == null) throw Exception("Script ID or enable value missing");
      ret = await service.sendCommand('Script.SetConfig', {"id": scriptId, "config": {"enable": enable}});
    }else if(command == COMMAND_START_SCRIPT) {
      int? scriptId = params["id"];
      if(scriptId == null) throw Exception("Script ID missing");
      ret = await service.sendCommand('Script.Start', {"id": scriptId});
    }else if(command == COMMAND_STOP_SCRIPT) {
      int? scriptId = params["id"];
      if(scriptId == null) throw Exception("Script ID missing");
      ret = await service.sendCommand('Script.Stop', {"id": scriptId});
    }else if(command == COMMAND_DELETE_SCRIPT) {
      int? scriptId = params["id"];
      if(scriptId == null) throw Exception("Script ID missing");
      ret = await service.sendCommand('Script.Delete', {"id": scriptId});
    }else if(command == COMMAND_CREATE_SCRIPT) {
      String? name = params["name"];
      if(name == null) throw Exception("Script name missing");
      ret = await service.sendCommand('Script.Create', {"name": name});
      // Returns: {"id": 0}  (new script ID)
    }else if(command == COMMAND_RENAME_SCRIPT) {
      int? scriptId = params["id"];
      String? newName = params["name"];
      if(scriptId == null || newName == null) throw Exception("Script ID or name missing");
      ret = await service.sendCommand('Script.SetConfig', {
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
          await service.sendCommand('Script.PutCode', {
            "id": scriptId,
            "code": chunks[i],
            "append": shouldAppend,
          });
          // If any chunk fails, the exception will propagate and stop the loop
        }

        ret = {"success": true, "chunks": chunks.length};
      } else {
        // Send as single chunk (WiFi service or code <= CODE_CHUNK_LENGTH chars)
        ret = await service.sendCommand('Script.PutCode', {
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

        final response = await service.sendCommand('Script.GetCode', getCodeParams);

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
}