import 'package:flutter/material.dart';
import 'package:the_solar_app/constants/command_constants.dart';
import 'package:the_solar_app/models/devices/capabilities/inverter_capability.dart';
import 'package:the_solar_app/screens/configuration/percentage_power_limit_screen.dart';
import 'package:the_solar_app/screens/configuration/wifi_configuration_screen.dart';
import 'package:the_solar_app/screens/configuration/wifi_ap_configuration_screen.dart';
import 'package:the_solar_app/screens/device_info_screen.dart';
import 'package:the_solar_app/utils/dialog_utils.dart';
import 'package:the_solar_app/utils/map_utils.dart';
import 'package:the_solar_app/utils/message_utils.dart';
import 'package:the_solar_app/utils/navigation_utils.dart';
import '../../../../services/devices/hoymiles/hoymiles_protocol.dart';
import '../../capabilities/device_role_config.dart';
import '../../device_base.dart';
import '../../generic_rendering/device_category_config.dart';
import '../../generic_rendering/device_data_field.dart';
import '../../generic_rendering/device_menu_item.dart';
import '../../time_series_field_config.dart';
import 'hoymiles_device.dart';

/// Hoymiles HMS-series standalone inverter with built-in WiFi
///
/// Examples: HMS-400W-1T, HMS-800W-2T, HMS-1000W-2T, HMS-2000DW-4T
class HoymilesInverterDevice extends HoymilesDevice with DeviceRoleConfig, InverterCapability {
  HoymilesInverterDevice({
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
      // Current power from SGSMO
      DeviceDataField(
        name: 'Aktuelle Leistung',
        type: DataFieldType.watt,
        valueExtractor: (data) =>
            MapUtils.OM(data, ['data', 'inverter', 'sgs', 'active_power']),
        icon: Icons.bolt,
        expertMode: false,
      ),
      DeviceDataField(
        name: 'Aktuelle Leistung PV',
        type: DataFieldType.watt,
        valueExtractor: (data) =>
            MapUtils.OM(data, ['data', 'inverter', 'pv', 'power']),
        icon: Icons.bolt,
        expertMode: false,
      ),
      // Daily energy
      DeviceDataField(
        name: 'Tagesertrag',
        type: DataFieldType.energy,
        valueExtractor: (data) => MapUtils.OM(data, ['data', 'dtu_daily_energy']),
        icon: Icons.wb_sunny,
        expertMode: false,
        precision: 2,
      ),
      // Grid voltage
      DeviceDataField(
        name: 'Netzspannung',
        type: DataFieldType.voltage,
        valueExtractor: (data) =>
            MapUtils.OM(data, ['data', 'inverter', 'sgs', 'voltage']),
        icon: Icons.electric_bolt,
        expertMode: false,
        category: 'ac',
      ),
      // Grid frequency
      DeviceDataField(
        name: 'Netzfrequenz',
        type: DataFieldType.frequency,
        valueExtractor: (data) => MapUtils.OM(data, ['data', 'inverter', 'sgs', 'frequency']),
        icon: Icons.waves,
        expertMode: true,
        category: 'ac',
      ),
      // Temperature
      DeviceDataField(
        name: 'Temperatur',
        type: DataFieldType.temperature,
        valueExtractor: (data) =>
            MapUtils.OM(data, ['data', 'inverter', 'sgs', 'temperature']),
        icon: Icons.thermostat,
        expertMode: false,
        category: 'ac',
      ),
      // Power limit TODO this is in config fetch on regular basis
      /*DeviceDataField(
        name: 'Leistungslimit',
        type: DataFieldType.none,
        valueExtractor: (data) {
          var limit = MapUtils.OM(data, ['data', 'inverter', 'sgs', 'power_limit']);
          if (limit != null && limit is num) {
            return '$limit %'; // Service already validated
          }
          return null;
        },
        icon: Icons.speed,
        expertMode: false,
        category: 'ac',
      ),*/
      for (var i = 1; i <= 4; i++) ...[
        DeviceDataField(
          name: 'PV$i Leistung',
          type: DataFieldType.watt,
          valueExtractor: (data) =>
              MapUtils.OM(data, ['data', 'inverter', 'pv', i.toString(), 'power']),
          icon: Icons.solar_power,
          expertMode: false,
          category: 'pv$i',
        ),
        DeviceDataField(
          name: 'PV$i Spannung',
          type: DataFieldType.voltage,
          valueExtractor: (data) =>
              MapUtils.OM(data, ['data', 'inverter', 'pv', i.toString(), 'voltage']),
          icon: Icons.electrical_services,
          expertMode: true,
          category: 'pv$i',
        ),
        DeviceDataField(
          name: 'PV$i Strom',
          type: DataFieldType.current,
          valueExtractor: (data) =>
              MapUtils.OM(data, ['data', 'inverter', 'pv', i.toString(), 'current']),
          icon: Icons.electrical_services,
          expertMode: true,
          category: 'pv$i',
        ),
        // Total energy
        DeviceDataField(
          name: 'PV$i Gesamtertrag',
          type: DataFieldType.energy,
          valueExtractor: (data) => MapUtils.OM(data, ['data', 'inverter', 'pv', i.toString(), 'energy_total']),
          icon: Icons.analytics,
          expertMode: false,
          category: 'pv$i',
          precision: 1,
        ),
        // Daily energy
        DeviceDataField(
          name: 'PV$i Tagesertrag',
          type: DataFieldType.energy,
          valueExtractor: (data) => MapUtils.OM(data, ['data', 'inverter', 'pv', i.toString(), 'energy_daily']),
          icon: Icons.analytics,
          expertMode: false,
          category: 'pv$i',
          precision: 1,
        )
      ],
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
      /*TODO find out why the send command ist working
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
          final currentPassword = apConfig['dtuApPass'] as String?;

          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => WiFiApConfigurationScreen(
                device: device,
                currentSsid: currentApSsid,
                currentPassword: currentPassword,
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
      ),*/
      DeviceMenuItem(
        name: 'Leistungslimit',
        subtitle: 'Wechselrichterleistung begrenzen',
        icon: Icons.speed,
        iconColor: Colors.orange,
        onTap: (ctx) async {
          final context = ctx.context;
          final device = ctx.device;

          final config = await DialogUtils.executeWithLoading(
            context,
            loadingMessage: 'Lade aktuelle Konfiguration...',
            operation: () => device.sendCommand(COMMAND_FETCH_SYS_CONFIG, {}),
            onError: (e) => MessageUtils.showError(context, 'Fehler beim Laden der Konfiguration: $e'),
          );

          if (config == null || !context.mounted) return;

          // Parse current SSID
          final currentLimit = config['power_limit_percent'] as int;

          var powerRating = MapUtils.OM(device.data, ['data', 'inverter', 'sgs', 'power_rating']) as int?;

          // Navigate to percentage power limit screen
          final result = await NavigationUtils.pushConfigurationScreen(
            context,
            PercentagePowerLimitScreen(
              device: device,
              currentLimit: currentLimit,
              totalPower: powerRating,
            ),
          );

          if (result == true && context.mounted) {
            MessageUtils.showSuccess(context, 'Leistungslimit erfolgreich gesetzt');
          }
        },
      ),
    ],
    categoryConfigs: [
      const DeviceCategoryConfig(
        category: 'ac',
        displayName: 'AC (Netz)',
        layout: CategoryLayout.standard,
        order: 10,
      ),
      const DeviceCategoryConfig(
        category: 'pv1',
        displayName: 'PV1',
        layout: CategoryLayout.standard,
        order: 20,
      ),
      const DeviceCategoryConfig(
        category: 'pv2',
        displayName: 'PV2',
        layout: CategoryLayout.standard,
        order: 30,
      ),
      const DeviceCategoryConfig(
        category: 'pv3',
        displayName: 'PV3',
        layout: CategoryLayout.standard,
        order: 40,
      ),
      const DeviceCategoryConfig(
        category: 'pv4',
        displayName: 'PV4',
        layout: CategoryLayout.standard,
        order: 50,
      ),
    ],
    timeSeriesFields: [
      TimeSeriesFieldConfig(
        name: 'Pv Leistung',
        type: DataFieldType.watt,
        mapping:  ['inverter', 'pv', 'power'],
      ),
      TimeSeriesFieldConfig(
        name: 'Aktuelle Leistung',
        type: DataFieldType.watt,
        mapping:  ['inverter', 'sgs', 'active_power'],
      ),
      TimeSeriesFieldConfig(
        name: 'Netzfrequenz',
        type: DataFieldType.none,
        mapping: ['inverter', 'sgs', 'frequency'],
      ),
      TimeSeriesFieldConfig(
        name: 'Netzspannung',
        type: DataFieldType.voltage,
        mapping: ['inverter', 'sgs', 'voltage'],
        formatter: (value) => value,
      ),
    ]
  ){
    netHostname = hostname;
    netPort = port;
    netIpAddress = ipAddress;
    netPort ??= HoymilesProtocol.DTU_PORT;
  }

  @override
  List<DeviceCategoryConfig> get categoryConfigs => [
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
  ];

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
    if (data['ap_password'] != null && data['ap_password'].toString().isNotEmpty) {
      wifi['AP ap_password'] = data['ap_password'];
    }
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
    if (data['apn_password'] != null && data['apn_password'].toString().isNotEmpty) {
      apn['APN Name'] = data['apn_password'];
    }
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
    } else if (command == COMMAND_SET_LIMIT) {
      // Extract limit from params
      final limit = params['limit'] as int?;
      if (limit == null) {
        throw Exception('limit parameter required (0-100)');
      }

      // Call setPowerLimit on service
      await connectionService?.setPowerLimit(limit);
      return {'success': true, 'limit': limit};
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
  factory HoymilesInverterDevice.fromJson(Map<String, dynamic> json) {
    final device = HoymilesInverterDevice(
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

  @override
  List<DeviceRole> getFixedRoles() => [
    DeviceRole.inverter
  ];

  @override
  double? getSolarPVPower(Map<String, dynamic> data) {
    final value = MapUtils.OM(data, ['data', 'inverter', 'pv', 'power']);
    if (value == null) return null;
    return (value as num).toDouble();
  }

  @override
  double? getSolarGridPower(Map<String, dynamic> data) {
    final value = MapUtils.OM(data, ['data', 'inverter', 'sgs', 'active_power']);
    if (value == null) return null;
    return (value as num).toDouble();
  }
}
