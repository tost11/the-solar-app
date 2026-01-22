 import 'package:flutter/material.dart';
import 'package:the_solar_app/constants/translation_keys.dart';
import 'package:the_solar_app/models/devices/generic_rendering/device_menu_item.dart';
import 'package:the_solar_app/models/devices/manufacturers/zendure/implementations/zendure_device_implementation.dart';
import 'package:the_solar_app/models/to.dart';
import 'package:the_solar_app/screens/configuration/mqtt_configuration_screen.dart';
import 'package:the_solar_app/services/devices/zendure/zendure_wifi_service.dart';
import 'package:the_solar_app/utils/localization_extension.dart';
import 'package:the_solar_app/utils/message_utils.dart';
import 'package:the_solar_app/utils/navigation_utils.dart';

import '../../../../../constants/command_constants.dart';
import '../../../../../utils/dialog_utils.dart';

const int ZENDURE_FIRMWARE_OLD_VERSION = 4367;

/// Bluetooth-specific implementation for Zendure devices
///
/// Extends the base ZendureDeviceImplementation to add Bluetooth-specific
/// menu items, particularly WiFi configuration which is only available
/// on Bluetooth-connected devices.
class WifiZendureDeviceImplementation extends ZendureDeviceImplementation {

  @override
  List<DeviceMenuItem> getMenuItems() {
    final baseItems = super.getMenuItems(); // Get shared menu items

    baseItems.add(DeviceMenuItem(
      name: TO(key: MenuTranslationKeys.mqttConfiguration),
      subtitle: TO(key: MenuSubtitleKeys.mqttConfigurationSubtitle),
      icon: Icons.storage,
      iconColor: Colors.green,
      onTap: (ctx) async {
        final context = ctx.context;
        final device = ctx.device;

        // Fetch current MQTT configuration
        final mqttConfig = await DialogUtils.executeWithLoading(
          context,
          loadingMessage: context.l10n.loadingConfiguration,
          operation: () => device.sendCommand(COMMAND_FETCH_MQTT, {}),
          onError: (e) => MessageUtils.showError(context, context.l10n.errorLoadingConfiguration(e.toString())),
        );

        if (mqttConfig == null || !context.mounted) return;

        debugPrint("curren mqtt cnfig is: ${mqttConfig.toString()}");

        // Parse server URL: "mqtt://192.168.178.223:1883"
        String? server;
        int port = 1883;

        final serverUrl = mqttConfig['server'] as String?;
        if (serverUrl != null && serverUrl.isNotEmpty) {
          final uri = Uri.tryParse(serverUrl);
          if (uri != null) {
            server = uri.host;
            port = uri.port;
          }
        }

        // Navigate to MQTT configuration screen
        final result = await NavigationUtils.pushConfigurationScreen(
          context,
          MqttConfigurationScreen(
            device: device,
            currentEnabled: mqttConfig['enable'] == true,
            currentServer: server,
            currentPort: port,
          ),
        );

        if (result == true && context.mounted) {
          MessageUtils.showSuccess(context, context.l10n.mqttConfigurationUpdated);
        }
      },
    ));

    return baseItems;
  }

  @override
  Future<Map<String, dynamic>?> sendCommand(dynamic connectionService,
      String command, Map<String, dynamic> params) async {
    if (command == COMMAND_SET_MQTT) {
      var props = <String, dynamic>{};

      final enabled = params["enable"] == true;
      props["enable"] = enabled;

      if (enabled) {
        // When enabled, server and port are required
        if (params["server"] == null || params["port"] == null) {
          throw Exception("Server and port required when MQTT is enabled");
        }

        props["server"] = params["server"];
        props["protocol"] = "mqtt";
        props["port"] = params["port"];

        // Optional authentication
        if (params["username"] != null && params["password"] != null) {
          props["username"] = params["username"];
          props["password"] = params["password"];
        }
      } else {
        // When disabled, use placeholder values
        props["server"] = "localhost";
        props["protocol"] = "mqtt";
        props["port"] = 1883;
      }

      return await (connectionService as ZendureWifiService).sendRPCCommand(
          "HA.Mqtt.SetConfig", props);
    }else if (command == COMMAND_FETCH_MQTT) {
      return await (connectionService as ZendureWifiService).setRPCGetCommand("HA.Mqtt.GetConfig");
    }else{
      return super.sendCommand(connectionService,command,params);
    }
  }
}
