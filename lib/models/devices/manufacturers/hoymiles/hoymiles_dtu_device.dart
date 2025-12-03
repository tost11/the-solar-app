import 'package:flutter/material.dart';
import 'package:the_solar_app/constants/command_constants.dart';
import 'package:the_solar_app/services/devices/hoymiles/hoymiles_protocol.dart';
import 'package:the_solar_app/utils/dialog_utils.dart';
import 'package:the_solar_app/utils/map_utils.dart';
import 'package:the_solar_app/utils/message_utils.dart';
import '../../../../widgets/hoymiles_inverter_list_widget.dart';
import '../../device_base.dart';
import '../../generic_rendering/device_custom_section.dart';
import '../../generic_rendering/device_data_field.dart';
import '../../generic_rendering/device_menu_item.dart';
import 'hoymiles_device.dart';

/// Hoymiles DTU gateway device managing multiple inverters
///
/// Examples: DTU-WLite, DTU-Pro, DTU-Lite-S
class HoymilesDTUDevice extends HoymilesDevice {
  HoymilesDTUDevice({
    required super.id,
    required super.name,
    required super.lastSeen,
    required super.deviceSn,
    String? ipAddress,
    String? hostname,
    int? port = 10081,
    super.deviceModel,
  }) : super(
    connectionType: ConnectionType.wifi,
    dataFields: [
      // Aggregate power
      DeviceDataField(
        name: 'Gesamtleistung',
        type: DataFieldType.watt,
        valueExtractor: (data) {
          final power = MapUtils.OM(data, ['realtime', 'dtu_power']);
          if (power != null && power is num) {
            return power.toInt();
          }
          return null;
        },
        icon: Icons.bolt,
        expertMode: false,
      ),
      // Daily energy
      DeviceDataField(
        name: 'Tagesertrag',
        type: DataFieldType.none,
        valueExtractor: (data) {
          final daily = MapUtils.OM(data, ['realtime', 'dtu_daily_energy']);
          if (daily != null && daily is num) {
            return '${(daily / 1000).toStringAsFixed(2)} kWh';
          }
          return null;
        },
        icon: Icons.wb_sunny,
        expertMode: false,
      ),
      // Number of inverters
      DeviceDataField(
        name: 'Anzahl Wechselrichter',
        type: DataFieldType.none,
        valueExtractor: (data) {
          final inverters = MapUtils.OM(data, ['realtime', 'inverters']) as Map?;
          return inverters?.length.toString() ?? '0';
        },
        icon: Icons.dashboard,
        expertMode: false,
      ),
      // Device serial number
      DeviceDataField(
        name: 'Seriennummer',
        type: DataFieldType.none,
        valueExtractor: (data) =>
            MapUtils.OM(data, ['realtime', 'device_serial_number']),
        icon: Icons.qr_code,
        expertMode: true,
      ),
      // Firmware version
      DeviceDataField(
        name: 'Firmware-Version',
        type: DataFieldType.none,
        valueExtractor: (data) {
          final version = MapUtils.OM(data, ['realtime', 'firmware_version']);
          return version?.toString();
        },
        icon: Icons.system_update,
        expertMode: true,
      ),
    ],
    menuItems: [
      DeviceMenuItem(
        name: 'Geräteinformationen',
        subtitle: 'Konfiguration anzeigen',
        icon: Icons.info,
        iconColor: Colors.blue,
        onTap: (context, device) async {
          await DialogUtils.executeWithLoading(
            context,
            loadingMessage: 'Lade Konfiguration...',
            operation: () => device.sendCommand(COMMAND_FETCH_SYS_CONFIG, {}),
            onSuccess: (config) {
              if (config != null) {
                MessageUtils.showInfo(context, 'Konfiguration geladen');
              }
            },
            onError: (e) => MessageUtils.showError(context, 'Fehler: $e'),
          );
        },
      ),
      DeviceMenuItem(
        name: 'Netzwerkinformationen',
        subtitle: 'WiFi-Konfiguration anzeigen',
        icon: Icons.wifi,
        iconColor: Colors.green,
        onTap: (context, device) async {
          await DialogUtils.executeWithLoading(
            context,
            loadingMessage: 'Lade Netzwerkinformationen...',
            operation: () => device.sendCommand(COMMAND_FETCH_WIFI_CONFIG, {}),
            onSuccess: (info) {
              if (info != null) {
                MessageUtils.showInfo(context, 'Netzwerkinformationen geladen');
              }
            },
            onError: (e) => MessageUtils.showError(context, 'Fehler: $e'),
          );
        },
      ),
    ],
    customSections: [
      // Inverter list section (like OpenDTU)
      DeviceCustomSection(
        title: 'Wechselrichter',
        position: CustomSectionPosition.afterConnectionControls,
        requiresConnection: true,
        builder: (context, device, data) {
          return HoymilesInverterListWidget(data: data);
        },
      ),
    ],
  ){
    netHostname = hostname;
    netPort = port;
    netIpAddress = ipAddress;
    netPort ??= HoymilesProtocol.DTU_PORT;
  }

  @override
  Future<Map<String, dynamic>?> sendCommand(
    String command,
    Map<String, dynamic> params,
  ) async {
    assertServiceIsFine();

    if (command == COMMAND_FETCH_DATA) {
      return await connectionService?.getRealDataNew();
    } else if (command == COMMAND_FETCH_SYS_CONFIG) {
      return await connectionService?.getConfig();
    } else if (command == COMMAND_FETCH_WIFI_CONFIG) {
      return await connectionService?.getNetworkInfo();
    }
    throw UnimplementedError('Command not yet implemented: $command');
  }

  /// Factory constructor from JSON
  factory HoymilesDTUDevice.fromJson(Map<String, dynamic> json) {
    final device = HoymilesDTUDevice(
      id: json['id'] as String,
      name: json['name'] as String,
      lastSeen: DateTime.parse(json['lastSeen'] as String),
      deviceSn: json['deviceSn'] as String,
      deviceModel: json['deviceModel'] as String?,
    );

    // Restore WiFi fields
    device.wifiFromJson(json);

    return device;
  }
}
