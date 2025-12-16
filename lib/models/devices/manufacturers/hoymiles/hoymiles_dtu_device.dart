import 'package:flutter/material.dart';
import 'package:the_solar_app/constants/command_constants.dart';
import 'package:the_solar_app/screens/configuration/wifi_configuration_screen.dart';
import 'package:the_solar_app/screens/configuration/wifi_ap_configuration_screen.dart';
import 'package:the_solar_app/screens/device_info_screen.dart';
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
        subtitle: 'Detaillierte Geräteinformationen anzeigen',
        icon: Icons.info_outline,
        iconColor: Colors.blue,
        onTap: (ctx) async {
          final context = ctx.context;
          final device = ctx.device;

          final info = await DialogUtils.executeWithLoading(
            context,
            loadingMessage: 'Lade Geräteinformationen...',
            operation: () => device.sendCommand(COMMAND_FETCH_DEVICE_INFO, {}),
            onError: (e) => MessageUtils.showError(context, 'Fehler: $e'),
          );

          if (info != null && context.mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DeviceInfoScreen(data: info),
              ),
            );
          }
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
            operation: () => device.sendCommand(COMMAND_FETCH_SYS_CONFIG, {}),
            onError: (e) => MessageUtils.showError(context, 'Fehler beim Laden der Konfiguration: $e'),
          );

          if (wifiConfig == null || !context.mounted) return;

          // Parse current SSID
          final currentSsid = wifiConfig['wifiSsid'] as String?;

          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => WiFiConfigurationScreen(
                device: device,
                currentSsid: currentSsid,
              ),
            ),
          );

          if (result == true) {
            MessageUtils.showSuccess(context, 'WiFi-Konfiguration abgeschlossen');
          }
        },
      ),
      DeviceMenuItem(
        name: 'Access Point konfigurieren',
        subtitle: 'AP WiFi einrichten',
        icon: Icons.router,
        iconColor: Colors.orange,
        onTap: (ctx) async {
          final context = ctx.context;
          final device = ctx.device;

          final apConfig = await DialogUtils.executeWithLoading(
            context,
            loadingMessage: 'Lade aktuelle Konfiguration...',
            operation: () => device.sendCommand(COMMAND_FETCH_SYS_CONFIG, {}),
            onError: (e) => MessageUtils.showError(context, 'Fehler beim Laden der Konfiguration: $e'),
          );

          if (apConfig == null || !context.mounted) return;

          // Parse current AP SSID
          final currentApSsid = apConfig['dtuApSsid'] as String?;

          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => WiFiApConfigurationScreen(
                device: device,
                currentSsid: currentApSsid,
                showSsidOption: true,
                showEnabledOption: false,
                showOpenOption: false,
                showRangeExtenderOption: false,
              ),
            ),
          );

          if (result == true) {
            MessageUtils.showSuccess(context, 'Access Point erfolgreich konfiguriert');
          }
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

  /// Organize flat device info into sections for UI
  Map<String, dynamic> _organizeDeviceInfo(Map<String, dynamic> data) {
    final result = <String, dynamic>{};

    // Netzwerk section
    final network = <String, dynamic>{};
    if (data['ip_address'] != null) network['IP-Adresse'] = data['ip_address'];
    if (data['mac_address'] != null) network['MAC-Adresse'] = data['mac_address'];
    if (data['gateway'] != null) network['Standard-Gateway'] = data['gateway'];
    if (data['subnet_mask'] != null) network['Subnetzmaske'] = data['subnet_mask'];
    if (data['dns_server'] != null && data['dns_server'] != '0.0.0.0') {
      network['DNS-Server'] = data['dns_server'];
    }
    if (data['dhcp_enabled'] != null) network['DHCP'] = data['dhcp_enabled'] ? 'Ja' : 'Nein';
    if (network.isNotEmpty) result['Netzwerk'] = network;

    // WiFi section
    final wifi = <String, dynamic>{};
    if (data['wifi_ssid'] != null && data['wifi_ssid'].toString().isNotEmpty) {
      wifi['SSID'] = data['wifi_ssid'];
    }
    if (data['network_mode'] != null) wifi['Netzwerkmodus'] = data['network_mode'];
    if (data['ap_ssid'] != null && data['ap_ssid'].toString().isNotEmpty) {
      wifi['AP SSID'] = data['ap_ssid'];
    }
    if (data['ap_password_set'] == true) wifi['AP Passwort'] = '••••••••';
    if (wifi.isNotEmpty) result['WiFi'] = wifi;

    // Gerät section
    final device = <String, dynamic>{};
    if (data['dtu_serial'] != null && data['dtu_serial'].toString().isNotEmpty) {
      device['DTU Seriennummer'] = data['dtu_serial'];
    }
    if (data['access_model'] != null) device['Zugriffsmodus'] = data['access_model'].toString();
    if (data['inverter_type'] != null) device['Inverter Typ'] = data['inverter_type'].toString();
    if (device.isNotEmpty) result['Gerät'] = device;

    // Server section
    final server = <String, dynamic>{};
    if (data['server_domain'] != null && data['server_domain'].toString().isNotEmpty) {
      server['Server Domain'] = data['server_domain'];
    }
    if (data['server_port'] != null) server['Server Port'] = data['server_port'].toString();
    if (data['send_interval'] != null) server['Sendeintervall'] = '${data['send_interval']} s';
    if (server.isNotEmpty) result['Server'] = server;

    // Einstellungen section
    final settings = <String, dynamic>{};
    if (data['power_limit_percent'] != null) {
      settings['Leistungslimit'] = '${data['power_limit_percent']} %';
    }
    if (data['lock_password_set'] != null) {
      settings['Sperrpasswort gesetzt'] = data['lock_password_set'] ? 'Ja' : 'Nein';
    }
    if (data['lock_time_minutes'] != null && data['lock_time_minutes'] != 0) {
      settings['Sperrzeit'] = '${data['lock_time_minutes']} min';
    }
    if (data['zero_export_enabled'] != null) {
      settings['Nulleinspeisung'] = data['zero_export_enabled'] ? 'Ja' : 'Nein';
    }
    if (data['zero_export_address'] != null && data['zero_export_address'] != 0) {
      settings['Nulleinspeisung Adresse'] = data['zero_export_address'].toString();
    }
    if (data['channel'] != null) settings['Kanal'] = data['channel'].toString();
    if (data['meter_kind'] != null && data['meter_kind'].toString().isNotEmpty) {
      settings['Zählerart'] = data['meter_kind'];
    }
    if (data['meter_interface'] != null && data['meter_interface'].toString().isNotEmpty) {
      settings['Zähler Schnittstelle'] = data['meter_interface'];
    }
    if (settings.isNotEmpty) result['Einstellungen'] = settings;

    // APN section
    final apn = <String, dynamic>{};
    if (data['apn_set'] != null && data['apn_set'].toString().isNotEmpty) {
      apn['APN Set'] = data['apn_set'];
    }
    if (data['apn_name'] != null && data['apn_name'].toString().isNotEmpty) {
      apn['APN Name'] = data['apn_name'];
    }
    if (data['apn_password_set'] == true) apn['APN Passwort'] = '••••••••';
    if (apn.isNotEmpty) result['APN'] = apn;

    // Sub1G section
    final sub1g = <String, dynamic>{};
    if (data['sub1g_sweep_switch'] != null) {
      sub1g['Sweep Switch'] = data['sub1g_sweep_switch'] ? 'Ja' : 'Nein';
    }
    if (data['sub1g_work_channel'] != null) {
      sub1g['Arbeitskanal'] = data['sub1g_work_channel'].toString();
    }
    if (sub1g.isNotEmpty) result['Sub1G'] = sub1g;

    return result;
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
    } else if (command == COMMAND_FETCH_DEVICE_INFO) {
      // Get flat parsed data from service
      final flatData = await connectionService?.getDeviceInformation();
      if (flatData == null) return null;

      // Organize into sections for UI
      return _organizeDeviceInfo(flatData);
    } else if (command == COMMAND_SET_WIFI) {
      final ssid = params['ssid'] as String;
      final password = params['password'] as String;
      await connectionService?.setWifiConfig(ssid, password);
      return {'success': true};
    } else if (command == COMMAND_SET_AP_CONFIG) {
      final ssid = params['ssid'] as String;
      final password = params['password'] as String;
      await connectionService?.setApWifiConfig(ssid, password);
      return {'success': true};
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
