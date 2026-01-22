import 'package:flutter/material.dart';
import 'package:the_solar_app/constants/translation_keys.dart';
import 'package:the_solar_app/models/devices/generic_rendering/device_menu_item.dart';
import 'package:the_solar_app/models/devices/manufacturers/zendure/implementations/zendure_device_implementation.dart';
import 'package:the_solar_app/models/to.dart';
import 'package:the_solar_app/screens/configuration/zendure_wifi_mqtt_configuration_screen.dart';
import 'package:the_solar_app/utils/map_utils.dart';
import 'package:the_solar_app/utils/message_utils.dart';
import 'package:the_solar_app/utils/navigation_utils.dart';

const int ZENDURE_FIRMWARE_OLD_VERSION = 4367;

/// Bluetooth-specific implementation for Zendure devices
///
/// Extends the base ZendureDeviceImplementation to add Bluetooth-specific
/// menu items, particularly WiFi configuration which is only available
/// on Bluetooth-connected devices.
class BluetoothZendureDeviceImplementation extends ZendureDeviceImplementation {

  @override
  List<DeviceMenuItem> getMenuItems() {
    final baseItems = super.getMenuItems(); // Get shared menu items

    // Add Bluetooth-specific WiFi configuration item
    baseItems.add(DeviceMenuItem(
      name: TO(key: MenuTranslationKeys.wifiConfiguration),
      subtitle: TO(key: MenuSubtitleKeys.wifiConfigurationSubtitle),
      icon: Icons.wifi,
      iconColor: Colors.green,
      onTap: (ctx) async {
        final context = ctx.context;
        final device = ctx.device;

        int? firmware = MapUtils.OM(device.data, ["firmwares", "MASTER"]) as int?;
        if (firmware == null) {
          MessageUtils.showInfo(context,"Nicht möglich da die aktuelle Firmware unbekannt ist, in einem moment noch mal versuchen (warte noch auf daten)");
          return;
        }
        bool result;
        result = await NavigationUtils.pushConfigurationScreen(
          context,
          ZendureWifiMqttConfigurationScreen(
            device: device,
            currentMqtt: firmware < ZENDURE_FIRMWARE_OLD_VERSION ? "mq.zen-iot.com":"mqtteu.zen-iot.com"
          ),
        );
        if (result == true && context.mounted) {
          MessageUtils.showSuccess(
              context, 'WiFi-Konfiguration abgeschlossen');
        }
      },
    ));

    baseItems.add(DeviceMenuItem(
      name: TO(key: MenuTranslationKeys.mqttConfiguration),
      subtitle: TO(key: MenuSubtitleKeys.mqttConfigurationSubtitle),
      disabled: (device){
        int? firmware = MapUtils.OM(device.data, ["firmwares", "MASTER"]) as int?;
        if (firmware == null || firmware <= ZENDURE_FIRMWARE_OLD_VERSION) {
          return true;
        }
        return false;
      },
      icon: Icons.storage,
      iconColor: Colors.green,
      onTap: (ctx) async {
        final context = ctx.context;
        final device = ctx.device;

        int? firmware = MapUtils.OM(device.data, ["firmwares", "MASTER"]) as int?;
        if (firmware == null) {
          MessageUtils.showInfo(context,"Nicht möglich da die aktuelle Firmware unbekannt ist, in einem moment noch mal versuchen (warte noch auf daten)");
          return;
        }
        bool result;
        if(firmware <= ZENDURE_FIRMWARE_OLD_VERSION){
          result = await NavigationUtils.pushConfigurationScreen(
            context,
            ZendureWifiMqttConfigurationScreen(
                device: device,
                currentMqtt: firmware < ZENDURE_FIRMWARE_OLD_VERSION ? "mq.zen-iot.com":"mqtteu.zen-iot.com"
            ),
          );
        }else{
          throw Exception("Setting mqtt with this firmware is not possible");
        }

        if (result == true && context.mounted) {
          MessageUtils.showSuccess(
              context, 'WiFi-Konfiguration abgeschlossen');
        }
      },
    ));

    return baseItems;
  }
}
