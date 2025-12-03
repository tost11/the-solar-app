import 'package:flutter/material.dart';
import 'package:the_solar_app/constants/command_constants.dart';
import 'package:the_solar_app/screens/configuration/percentage_power_limit_screen.dart';
import 'package:the_solar_app/utils/dialog_utils.dart';
import 'package:the_solar_app/utils/map_utils.dart';
import 'package:the_solar_app/utils/message_utils.dart';
import '../../../../services/devices/hoymiles/hoymiles_protocol.dart';
import '../../device_base.dart';
import '../../generic_rendering/device_category_config.dart';
import '../../generic_rendering/device_data_field.dart';
import '../../generic_rendering/device_menu_item.dart';
import 'hoymiles_device.dart';

/// Hoymiles HMS-series standalone inverter with built-in WiFi
///
/// Examples: HMS-400W-1T, HMS-800W-2T, HMS-1000W-2T, HMS-2000DW-4T
class HoymilesInverterDevice extends HoymilesDevice {
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
      // Daily energy
      DeviceDataField(
        name: 'Tagesertrag',
        type: DataFieldType.none,
        valueExtractor: (data) {
          final daily = MapUtils.OM(data, ['data', 'dtu_daily_energy']);
          if (daily != null && daily is num) {
            return '${daily.toStringAsFixed(2)} kWh'; // Service already in kWh
          }
          return null;
        },
        icon: Icons.wb_sunny,
        expertMode: false,
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
        type: DataFieldType.none,
        valueExtractor: (data) {
          final freq = MapUtils.OM(data, ['data', 'inverter', 'sgs', 'frequency']);
          if (freq != null && freq is num) {
            return '${freq.toStringAsFixed(2)} Hz'; // Service already in Hz
          }
          return null;
        },
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
      // Power limit
      DeviceDataField(
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
      ),
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
          type: DataFieldType.none,
          valueExtractor: (data) {
            final total = MapUtils.OM(data, ['data', 'inverter', 'pv', i.toString(), 'energy_total']);
            if (total != null && total is num) {
              return '${total.toStringAsFixed(1)} kWh'; // Service already in kWh
            }
            return null;
          },
          icon: Icons.analytics,
          expertMode: false,
          category: 'pv$i',
        ),
        // Daily energy
        DeviceDataField(
          name: 'PV$i Tagesertrag',
          type: DataFieldType.none,
          valueExtractor: (data) {
            final total = MapUtils.OM(data, ['data', 'inverter', 'pv', i.toString(), 'energy_daily']);
            if (total != null && total is num) {
              return '${total.toStringAsFixed(1)} kWh'; // Service already in kWh
            }
            return null;
          },
          icon: Icons.analytics,
          expertMode: false,
          category: 'pv$i',
        )
      ],
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
      DeviceMenuItem(
        name: 'Leistungslimit',
        subtitle: 'Wechselrichterleistung begrenzen',
        icon: Icons.speed,
        iconColor: Colors.orange,
        onTap: (context, device) async {
          // Extract current limit from existing data (default to 100% if not found)
          // Service already validates and clamps invalid values
          var currentLimit =
              (MapUtils.OM(device.data, ['data', 'inverter', 'sgs', 'power_limit']) as num?)?.toInt() ?? 100;
          var powerRating = MapUtils.OM(device.data, ['data', 'inverter', 'sgs', 'power_rating']) as int?;

          // Navigate to percentage power limit screen
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PercentagePowerLimitScreen(
                device: device,
                currentLimit: currentLimit,
                totalPower: powerRating,
              ),
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
    } else if (command == COMMAND_SET_LIMIT) {
      // Extract limit from params
      final limit = params['limit'] as int?;
      if (limit == null) {
        throw Exception('limit parameter required (0-100)');
      }

      // Call setPowerLimit on service
      final success = await connectionService?.setPowerLimit(limit);
      if (success == null || !success) {
        throw Exception('Failed to set power limit');
      }

      return {'success': true, 'limit': limit};
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
}
