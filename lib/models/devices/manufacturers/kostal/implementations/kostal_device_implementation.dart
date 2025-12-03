import 'package:flutter/material.dart';
import 'package:the_solar_app/constants/command_constants.dart';
import 'package:the_solar_app/models/devices/device_implementation.dart';
import 'package:the_solar_app/utils/map_utils.dart';
import '../../../generic_rendering/device_category_config.dart';
import '../../../generic_rendering/device_control_item.dart';
import '../../../generic_rendering/device_custom_section.dart';
import '../../../generic_rendering/device_data_field.dart';
import '../../../generic_rendering/device_menu_item.dart';

/// Implementation for Kostal solar inverter devices
///
/// Supports Kostal Plenticore and compatible inverters via Modbus TCP
class KostalDeviceImplementation extends DeviceImplementation {
  /// Helper method to format numeric values from data
  static String? _formatNumber(dynamic value, int decimals, String unit) {
    if (value == null) return null;
    final numValue = value is num ? value : double.tryParse(value.toString());
    if (numValue == null) return null;
    // Only show non-zero values or always show if it's a percentage/status
    if (numValue == 0 && !unit.contains('%')) return null;
    return '${numValue.toStringAsFixed(decimals)} $unit';
  }

  @override
  List<DeviceMenuItem> getMenuItems() {
    return [
      // Future: Add device restart, power limit configuration, etc.
      // when write operations are fully tested
    ];
  }

  @override
  List<DeviceControlItem> getControlItems() {
    return [
      // Future: Add power on/off, limit control, etc.
      // when write operations are supported
    ];
  }

  @override
  List<DeviceDataField> getDataFields() {
    return [
      // ===== Main Data (no category, always visible) =====

      DeviceDataField(
        name: 'DC Gesamtleistung',
        type: DataFieldType.watt,
        valueExtractor: (data) {
          final value = MapUtils.OM(data, ['data', 'dc_power_total']);
          return _formatNumber(value, 1, 'W');
        },
        icon: Icons.electrical_services,
        expertMode: false,
      ),

      DeviceDataField(
        name: 'AC Gesamtleistung',
        type: DataFieldType.watt,
        valueExtractor: (data) {
          final value = MapUtils.OM(data, ['data', 'ac_power_total']);
          return _formatNumber(value, 1, 'W');
        },
        icon: Icons.bolt,
        expertMode: false,
      ),

      DeviceDataField(
        name: 'Tagesertrag',
        type: DataFieldType.none,
        valueExtractor: (data) {
          final value = MapUtils.OM(data, ['data', 'yield_daily']);
          return _formatNumber(value, 2, 'kWh');
        },
        icon: Icons.wb_sunny,
        expertMode: false,
      ),

      DeviceDataField(
        name: 'Monatsertrag',
        type: DataFieldType.none,
        valueExtractor: (data) {
          final value = MapUtils.OM(data, ['data', 'yield_monthly']);
          return _formatNumber(value, 1, 'kWh');
        },
        icon: Icons.calendar_month,
        expertMode: false,
      ),

      DeviceDataField(
        name: 'Jahresertrag',
        type: DataFieldType.none,
        valueExtractor: (data) {
          final value = MapUtils.OM(data, ['data', 'yield_yearly']);
          return _formatNumber(value, 1, 'kWh');
        },
        icon: Icons.calendar_today,
        expertMode: false,
      ),

      DeviceDataField(
        name: 'Gesamtertrag',
        type: DataFieldType.none,
        valueExtractor: (data) {
          final value = MapUtils.OM(data, ['data', 'yield_total']);
          return _formatNumber(value, 1, 'kWh');
        },
        icon: Icons.show_chart,
        expertMode: false,
      ),

      DeviceDataField(
        name: 'Netzfrequenz',
        type: DataFieldType.none,
        valueExtractor: (data) {
          final value = MapUtils.OM(data, ['data', 'grid_frequency']);
          return _formatNumber(value, 2, 'Hz');
        },
        icon: Icons.waves,
        expertMode: false,
      ),

      // ===== DC String 1 =====

      DeviceDataField(
        name: 'Spannung',
        type: DataFieldType.none,
        valueExtractor: (data) {
          final value = MapUtils.OM(data, ['data', 'dc1_voltage']);
          return _formatNumber(value, 1, 'V');
        },
        icon: Icons.solar_power,
        expertMode: false,
        category: 'dc1',
      ),

      DeviceDataField(
        name: 'Strom',
        type: DataFieldType.none,
        valueExtractor: (data) {
          final value = MapUtils.OM(data, ['data', 'dc1_current']);
          return _formatNumber(value, 2, 'A');
        },
        icon: Icons.solar_power,
        expertMode: false,
        category: 'dc1',
      ),

      DeviceDataField(
        name: 'Leistung',
        type: DataFieldType.none,
        valueExtractor: (data) {
          final value = MapUtils.OM(data, ['data', 'dc1_power']);
          return _formatNumber(value, 1, 'W');
        },
        icon: Icons.solar_power,
        expertMode: false,
        category: 'dc1',
      ),

      // ===== DC String 2 =====

      DeviceDataField(
        name: 'Spannung',
        type: DataFieldType.none,
        valueExtractor: (data) {
          final value = MapUtils.OM(data, ['data', 'dc2_voltage']);
          return _formatNumber(value, 1, 'V');
        },
        icon: Icons.solar_power,
        expertMode: false,
        category: 'dc2',
      ),

      DeviceDataField(
        name: 'Strom',
        type: DataFieldType.none,
        valueExtractor: (data) {
          final value = MapUtils.OM(data, ['data', 'dc2_current']);
          return _formatNumber(value, 2, 'A');
        },
        icon: Icons.solar_power,
        expertMode: false,
        category: 'dc2',
      ),

      DeviceDataField(
        name: 'Leistung',
        type: DataFieldType.none,
        valueExtractor: (data) {
          final value = MapUtils.OM(data, ['data', 'dc2_power']);
          return _formatNumber(value, 1, 'W');
        },
        icon: Icons.solar_power,
        expertMode: false,
        category: 'dc2',
      ),

      // ===== DC String 3 =====

      DeviceDataField(
        name: 'Spannung',
        type: DataFieldType.none,
        valueExtractor: (data) {
          final value = MapUtils.OM(data, ['data', 'dc3_voltage']);
          return _formatNumber(value, 1, 'V');
        },
        icon: Icons.solar_power,
        expertMode: false,
        category: 'dc3',
      ),

      DeviceDataField(
        name: 'Strom',
        type: DataFieldType.none,
        valueExtractor: (data) {
          final value = MapUtils.OM(data, ['data', 'dc3_current']);
          return _formatNumber(value, 2, 'A');
        },
        icon: Icons.solar_power,
        expertMode: false,
        category: 'dc3',
      ),

      DeviceDataField(
        name: 'Leistung',
        type: DataFieldType.none,
        valueExtractor: (data) {
          final value = MapUtils.OM(data, ['data', 'dc3_power']);
          return _formatNumber(value, 1, 'W');
        },
        icon: Icons.solar_power,
        expertMode: false,
        category: 'dc3',
      ),

      // ===== AC Phase 1 =====

      DeviceDataField(
        name: 'Spannung',
        type: DataFieldType.none,
        valueExtractor: (data) {
          final value = MapUtils.OM(data, ['data', 'ac_phase1_voltage']);
          return _formatNumber(value, 1, 'V');
        },
        icon: Icons.electric_bolt,
        expertMode: false,
        category: 'ac1',
      ),

      DeviceDataField(
        name: 'Strom',
        type: DataFieldType.none,
        valueExtractor: (data) {
          final value = MapUtils.OM(data, ['data', 'ac_phase1_current']);
          return _formatNumber(value, 2, 'A');
        },
        icon: Icons.flash_on,
        expertMode: false,
        category: 'ac1',
      ),

      DeviceDataField(
        name: 'Leistung',
        type: DataFieldType.none,
        valueExtractor: (data) {
          final value = MapUtils.OM(data, ['data', 'ac_phase1_power']);
          return _formatNumber(value, 1, 'W');
        },
        icon: Icons.bolt,
        expertMode: false,
        category: 'ac1',
      ),

      // ===== AC Phase 2 =====

      DeviceDataField(
        name: 'Spannung',
        type: DataFieldType.none,
        valueExtractor: (data) {
          final value = MapUtils.OM(data, ['data', 'ac_phase2_voltage']);
          return _formatNumber(value, 1, 'V');
        },
        icon: Icons.electric_bolt,
        expertMode: false,
        category: 'ac2',
      ),

      DeviceDataField(
        name: 'Strom',
        type: DataFieldType.none,
        valueExtractor: (data) {
          final value = MapUtils.OM(data, ['data', 'ac_phase2_current']);
          return _formatNumber(value, 2, 'A');
        },
        icon: Icons.flash_on,
        expertMode: false,
        category: 'ac2',
      ),

      DeviceDataField(
        name: 'Leistung',
        type: DataFieldType.none,
        valueExtractor: (data) {
          final value = MapUtils.OM(data, ['data', 'ac_phase2_power']);
          return _formatNumber(value, 1, 'W');
        },
        icon: Icons.bolt,
        expertMode: false,
        category: 'ac2',
      ),

      // ===== AC Phase 3 =====

      DeviceDataField(
        name: 'Spannung',
        type: DataFieldType.none,
        valueExtractor: (data) {
          final value = MapUtils.OM(data, ['data', 'ac_phase3_voltage']);
          return _formatNumber(value, 1, 'V');
        },
        icon: Icons.electric_bolt,
        expertMode: false,
        category: 'ac3',
      ),

      DeviceDataField(
        name: 'Strom',
        type: DataFieldType.none,
        valueExtractor: (data) {
          final value = MapUtils.OM(data, ['data', 'ac_phase3_current']);
          return _formatNumber(value, 2, 'A');
        },
        icon: Icons.flash_on,
        expertMode: false,
        category: 'ac3',
      ),

      DeviceDataField(
        name: 'Leistung',
        type: DataFieldType.none,
        valueExtractor: (data) {
          final value = MapUtils.OM(data, ['data', 'ac_phase3_power']);
          return _formatNumber(value, 1, 'W');
        },
        icon: Icons.bolt,
        expertMode: false,
        category: 'ac3',
      ),

      // ===== AC Totals (expert mode) =====

      DeviceDataField(
        name: 'Blindleistung gesamt',
        type: DataFieldType.none,
        valueExtractor: (data) {
          final value = MapUtils.OM(data, ['data', 'ac_reactive_power_total']);
          return _formatNumber(value, 1, 'VAR');
        },
        icon: Icons.bolt_outlined,
        expertMode: true,
        category: 'ac_totals',
      ),

      DeviceDataField(
        name: 'Scheinleistung gesamt',
        type: DataFieldType.none,
        valueExtractor: (data) {
          final value = MapUtils.OM(data, ['data', 'ac_apparent_power_total']);
          return _formatNumber(value, 1, 'VA');
        },
        icon: Icons.bolt_outlined,
        expertMode: true,
        category: 'ac_totals',
      ),

      // ===== Battery =====

      DeviceDataField(
        name: 'Ladezustand',
        type: DataFieldType.none,
        valueExtractor: (data) {
          // Try both SOC fields
          var value = MapUtils.OM(data, ['data', 'battery_soc']);
          value ??= MapUtils.OM(data, ['data', 'battery_soc_actual']);
          return _formatNumber(value, 1, '%');
        },
        icon: Icons.battery_charging_full,
        expertMode: false,
        category: 'battery',
      ),

      DeviceDataField(
        name: 'Spannung',
        type: DataFieldType.none,
        valueExtractor: (data) {
          final value = MapUtils.OM(data, ['data', 'battery_voltage']);
          return _formatNumber(value, 1, 'V');
        },
        icon: Icons.battery_std,
        expertMode: false,
        category: 'battery',
      ),

      DeviceDataField(
        name: 'Strom',
        type: DataFieldType.none,
        valueExtractor: (data) {
          final value = MapUtils.OM(data, ['data', 'battery_current']);
          return _formatNumber(value, 2, 'A');
        },
        icon: Icons.flash_on,
        expertMode: false,
        category: 'battery',
      ),

      DeviceDataField(
        name: 'Lade-/Entladeleistung',
        type: DataFieldType.none,
        valueExtractor: (data) {
          final value = MapUtils.OM(data, ['data', 'battery_charge_discharge_power']);
          return _formatNumber(value, 1, 'W');
        },
        icon: Icons.power,
        expertMode: false,
        category: 'battery',
      ),

      DeviceDataField(
        name: 'Temperatur',
        type: DataFieldType.none,
        valueExtractor: (data) {
          final value = MapUtils.OM(data, ['data', 'battery_temperature']);
          return _formatNumber(value, 1, '°C');
        },
        icon: Icons.thermostat,
        expertMode: false,
        category: 'battery',
      ),

      DeviceDataField(
        name: 'Zyklen',
        type: DataFieldType.none,
        valueExtractor: (data) {
          final value = MapUtils.OM(data, ['data', 'battery_cycles']);
          return _formatNumber(value, 0, '');
        },
        icon: Icons.loop,
        expertMode: true,
        category: 'battery',
      ),

      DeviceDataField(
        name: 'Kapazität (brutto)',
        type: DataFieldType.none,
        valueExtractor: (data) {
          final value = MapUtils.OM(data, ['data', 'battery_capacity_gross']);
          return _formatNumber(value, 0, 'Wh');
        },
        icon: Icons.battery_full,
        expertMode: true,
        category: 'battery',
      ),

      DeviceDataField(
        name: 'Kapazität (netto)',
        type: DataFieldType.none,
        valueExtractor: (data) {
          final value = MapUtils.OM(data, ['data', 'battery_capacity_net']);
          return _formatNumber(value, 0, 'Wh');
        },
        icon: Icons.battery_full,
        expertMode: true,
        category: 'battery',
      ),

      DeviceDataField(
        name: 'Hersteller',
        type: DataFieldType.none,
        valueExtractor: (data) => MapUtils.OM(data, ['data', 'battery_manufacturer']),
        icon: Icons.business,
        expertMode: true,
        showDetailButton: true,
        category: 'battery',
      ),

      // ===== Home Consumption =====

      DeviceDataField(
        name: 'Gesamtverbrauch',
        type: DataFieldType.none,
        valueExtractor: (data) {
          final value = MapUtils.OM(data, ['data', 'consumption_total']);
          return _formatNumber(value, 1, 'W');
        },
        icon: Icons.home,
        expertMode: false,
        category: 'consumption',
      ),

      DeviceDataField(
        name: 'Verbrauch aus PV',
        type: DataFieldType.none,
        valueExtractor: (data) {
          final value = MapUtils.OM(data, ['data', 'consumption_pv']);
          return _formatNumber(value, 1, 'W');
        },
        icon: Icons.solar_power,
        expertMode: false,
        category: 'consumption',
      ),

      DeviceDataField(
        name: 'Verbrauch aus Netz',
        type: DataFieldType.none,
        valueExtractor: (data) {
          final value = MapUtils.OM(data, ['data', 'consumption_grid']);
          return _formatNumber(value, 1, 'W');
        },
        icon: Icons.grid_on,
        expertMode: false,
        category: 'consumption',
      ),

      DeviceDataField(
        name: 'Verbrauch aus Batterie',
        type: DataFieldType.none,
        valueExtractor: (data) {
          final value = MapUtils.OM(data, ['data', 'consumption_battery']);
          return _formatNumber(value, 1, 'W');
        },
        icon: Icons.battery_charging_full,
        expertMode: false,
        category: 'consumption',
      ),

      // ===== Powermeter =====

      DeviceDataField(
        name: 'Wirkleistung gesamt',
        type: DataFieldType.none,
        valueExtractor: (data) {
          final value = MapUtils.OM(data, ['data', 'powermeter_active_power_total']);
          return _formatNumber(value, 1, 'W');
        },
        icon: Icons.bolt,
        expertMode: false,
        category: 'powermeter',
      ),

      DeviceDataField(
        name: 'Blindleistung gesamt',
        type: DataFieldType.none,
        valueExtractor: (data) {
          final value = MapUtils.OM(data, ['data', 'powermeter_reactive_power_total']);
          return _formatNumber(value, 1, 'VAR');
        },
        icon: Icons.bolt_outlined,
        expertMode: true,
        category: 'powermeter',
      ),

      DeviceDataField(
        name: 'Scheinleistung gesamt',
        type: DataFieldType.none,
        valueExtractor: (data) {
          final value = MapUtils.OM(data, ['data', 'powermeter_apparent_power_total']);
          return _formatNumber(value, 1, 'VA');
        },
        icon: Icons.bolt_outlined,
        expertMode: true,
        category: 'powermeter',
      ),

      DeviceDataField(
        name: 'Frequenz',
        type: DataFieldType.none,
        valueExtractor: (data) {
          final value = MapUtils.OM(data, ['data', 'powermeter_frequency']);
          return _formatNumber(value, 2, 'Hz');
        },
        icon: Icons.waves,
        expertMode: true,
        category: 'powermeter',
      ),

      DeviceDataField(
        name: 'Cos Phi',
        type: DataFieldType.none,
        valueExtractor: (data) {
          final value = MapUtils.OM(data, ['data', 'powermeter_cos_phi']);
          return _formatNumber(value, 3, '');
        },
        icon: Icons.functions,
        expertMode: true,
        category: 'powermeter',
      ),

      // Powermeter Phase 1
      DeviceDataField(
        name: 'Spannung',
        type: DataFieldType.none,
        valueExtractor: (data) {
          final value = MapUtils.OM(data, ['data', 'powermeter_phase1_voltage']);
          return _formatNumber(value, 1, 'V');
        },
        icon: Icons.electric_bolt,
        expertMode: true,
        category: 'powermeter_phase1',
      ),

      DeviceDataField(
        name: 'Strom',
        type: DataFieldType.none,
        valueExtractor: (data) {
          final value = MapUtils.OM(data, ['data', 'powermeter_phase1_current']);
          return _formatNumber(value, 2, 'A');
        },
        icon: Icons.flash_on,
        expertMode: true,
        category: 'powermeter_phase1',
      ),

      DeviceDataField(
        name: 'Wirkleistung',
        type: DataFieldType.none,
        valueExtractor: (data) {
          final value = MapUtils.OM(data, ['data', 'powermeter_phase1_active_power']);
          return _formatNumber(value, 1, 'W');
        },
        icon: Icons.bolt,
        expertMode: true,
        category: 'powermeter_phase1',
      ),

      // Powermeter Phase 2
      DeviceDataField(
        name: 'Spannung',
        type: DataFieldType.none,
        valueExtractor: (data) {
          final value = MapUtils.OM(data, ['data', 'powermeter_phase2_voltage']);
          return _formatNumber(value, 1, 'V');
        },
        icon: Icons.electric_bolt,
        expertMode: true,
        category: 'powermeter_phase2',
      ),

      DeviceDataField(
        name: 'Strom',
        type: DataFieldType.none,
        valueExtractor: (data) {
          final value = MapUtils.OM(data, ['data', 'powermeter_phase2_current']);
          return _formatNumber(value, 2, 'A');
        },
        icon: Icons.flash_on,
        expertMode: true,
        category: 'powermeter_phase2',
      ),

      DeviceDataField(
        name: 'Wirkleistung',
        type: DataFieldType.none,
        valueExtractor: (data) {
          final value = MapUtils.OM(data, ['data', 'powermeter_phase2_active_power']);
          return _formatNumber(value, 1, 'W');
        },
        icon: Icons.bolt,
        expertMode: true,
        category: 'powermeter_phase2',
      ),

      // Powermeter Phase 3
      DeviceDataField(
        name: 'Spannung',
        type: DataFieldType.none,
        valueExtractor: (data) {
          final value = MapUtils.OM(data, ['data', 'powermeter_phase3_voltage']);
          return _formatNumber(value, 1, 'V');
        },
        icon: Icons.electric_bolt,
        expertMode: true,
        category: 'powermeter_phase3',
      ),

      DeviceDataField(
        name: 'Strom',
        type: DataFieldType.none,
        valueExtractor: (data) {
          final value = MapUtils.OM(data, ['data', 'powermeter_phase3_current']);
          return _formatNumber(value, 2, 'A');
        },
        icon: Icons.flash_on,
        expertMode: true,
        category: 'powermeter_phase3',
      ),

      DeviceDataField(
        name: 'Wirkleistung',
        type: DataFieldType.none,
        valueExtractor: (data) {
          final value = MapUtils.OM(data, ['data', 'powermeter_phase3_active_power']);
          return _formatNumber(value, 1, 'W');
        },
        icon: Icons.bolt,
        expertMode: true,
        category: 'powermeter_phase3',
      ),

      // ===== System Info =====

      DeviceDataField(
        name: 'Artikelnummer',
        type: DataFieldType.none,
        valueExtractor: (data) => MapUtils.OM(data, ['data', 'article_number']),
        icon: Icons.tag,
        expertMode: true,
        showDetailButton: true,
        category: 'system',
      ),

      DeviceDataField(
        name: 'Max. Wechselrichterleistung',
        type: DataFieldType.none,
        valueExtractor: (data) {
          final value = MapUtils.OM(data, ['data', 'inverter_max_power']);
          return _formatNumber(value, 0, 'W');
        },
        icon: Icons.power,
        expertMode: true,
        category: 'system',
      ),

      DeviceDataField(
        name: 'Wechselrichter-Erzeugungsleistung',
        type: DataFieldType.none,
        valueExtractor: (data) {
          final value = MapUtils.OM(data, ['data', 'inverter_generation_power']);
          return _formatNumber(value, 1, 'W');
        },
        icon: Icons.bolt,
        expertMode: true,
        category: 'system',
      ),

      DeviceDataField(
        name: 'Betriebszeit',
        type: DataFieldType.none,
        valueExtractor: (data) {
          final value = MapUtils.OM(data, ['data', 'work_time']);
          return _formatNumber(value, 0, 'h');
        },
        icon: Icons.timer,
        expertMode: true,
        category: 'system',
      ),

      DeviceDataField(
        name: 'Isolationswiderstand',
        type: DataFieldType.none,
        valueExtractor: (data) {
          final value = MapUtils.OM(data, ['data', 'isolation_resistance']);
          return _formatNumber(value, 0, 'Ω');
        },
        icon: Icons.shield,
        expertMode: true,
        category: 'system',
      ),

      DeviceDataField(
        name: 'Cos Phi (aktuell)',
        type: DataFieldType.none,
        valueExtractor: (data) {
          final value = MapUtils.OM(data, ['data', 'cos_phi_actual']);
          return _formatNumber(value, 3, '');
        },
        icon: Icons.functions,
        expertMode: true,
        category: 'system',
      ),

      DeviceDataField(
        name: 'EVU Leistungslimit',
        type: DataFieldType.none,
        valueExtractor: (data) {
          final value = MapUtils.OM(data, ['data', 'power_limit_evu']);
          return _formatNumber(value, 1, 'W');
        },
        icon: Icons.speed,
        expertMode: true,
        category: 'system',
      ),
    ];
  }

  @override
  List<DeviceCustomSection> getCustomSections() => [];

  @override
  List<DeviceCategoryConfig> getCategoryConfigs() {
    return [
      const DeviceCategoryConfig(
        category: 'dc1',
        displayName: 'DC String 1',
        layout: CategoryLayout.standard,
        order: 10,
      ),
      const DeviceCategoryConfig(
        category: 'dc2',
        displayName: 'DC String 2',
        layout: CategoryLayout.standard,
        order: 20,
      ),
      const DeviceCategoryConfig(
        category: 'dc3',
        displayName: 'DC String 3',
        layout: CategoryLayout.standard,
        order: 30,
      ),
      const DeviceCategoryConfig(
        category: 'ac1',
        displayName: 'AC Phase 1',
        layout: CategoryLayout.standard,
        order: 40,
      ),
      const DeviceCategoryConfig(
        category: 'ac2',
        displayName: 'AC Phase 2',
        layout: CategoryLayout.standard,
        order: 50,
      ),
      const DeviceCategoryConfig(
        category: 'ac3',
        displayName: 'AC Phase 3',
        layout: CategoryLayout.standard,
        order: 60,
      ),
      const DeviceCategoryConfig(
        category: 'ac_totals',
        displayName: 'AC Gesamt',
        layout: CategoryLayout.standard,
        order: 65,
      ),
      const DeviceCategoryConfig(
        category: 'battery',
        displayName: 'Batterie',
        layout: CategoryLayout.standard,
        order: 70,
      ),
      const DeviceCategoryConfig(
        category: 'consumption',
        displayName: 'Hausverbrauch',
        layout: CategoryLayout.standard,
        order: 80,
      ),
      const DeviceCategoryConfig(
        category: 'powermeter',
        displayName: 'Leistungsmesser',
        layout: CategoryLayout.standard,
        order: 90,
      ),
      const DeviceCategoryConfig(
        category: 'powermeter_phase1',
        displayName: 'Leistungsmesser Phase 1',
        layout: CategoryLayout.standard,
        order: 91,
      ),
      const DeviceCategoryConfig(
        category: 'powermeter_phase2',
        displayName: 'Leistungsmesser Phase 2',
        layout: CategoryLayout.standard,
        order: 92,
      ),
      const DeviceCategoryConfig(
        category: 'powermeter_phase3',
        displayName: 'Leistungsmesser Phase 3',
        layout: CategoryLayout.standard,
        order: 93,
      ),
      const DeviceCategoryConfig(
        category: 'system',
        displayName: 'System',
        layout: CategoryLayout.oneLine,
        order: 100,
      ),
    ];
  }

  @override
  IconData getDeviceIcon() => Icons.solar_power;

  @override
  String getFetchCommand() => COMMAND_FETCH_DATA;

  @override
  Future<Map<String, dynamic>?> sendCommand(
    dynamic connectionService,
    String command,
    Map<String, dynamic> params,
  ) async {
    // final service = connectionService as KostalWifiService;

    if (command == COMMAND_FETCH_DATA) {
      // Data is fetched automatically by service, just return success
      return {'success': true};
    } else {
      throw UnimplementedError(
        'Command type not yet implemented for Kostal: $command',
      );
    }
  }
}
