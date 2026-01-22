import 'package:flutter/material.dart';
import 'package:the_solar_app/constants/command_constants.dart';
import 'package:the_solar_app/constants/translation_keys.dart';
import 'package:the_solar_app/models/devices/device_implementation.dart';
import 'package:the_solar_app/models/to.dart';
import 'package:the_solar_app/utils/map_utils.dart';
import '../../../generic_rendering/device_category_config.dart';
import '../../../generic_rendering/device_control_item.dart';
import '../../../generic_rendering/device_custom_section.dart';
import '../../../generic_rendering/device_data_field.dart';
import '../../../generic_rendering/device_menu_item.dart';
import '../../../time_series_field_config.dart';

/// Implementation for Kostal solar inverter devices
///
/// Supports Kostal Plenticore and compatible inverters via Modbus TCP
class KostalDeviceImplementation extends DeviceImplementation {
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
  List<TimeSeriesFieldConfig> getTimeSeriesFields() {
    return [
      TimeSeriesFieldConfig(
        name: TO(key: FieldTranslationKeys.solarPower),
        type: DataFieldType.watt,
        mapping: ['dc_power_total'],
      ),
      TimeSeriesFieldConfig(
        name: TO(key: FieldTranslationKeys.consumption),
        type: DataFieldType.watt,
        mapping: ['ac_power_total'],
      ),
      TimeSeriesFieldConfig(
        name: TO(key: FieldTranslationKeys.gridImport),
        type: DataFieldType.watt,
        mapping: ['consumption_grid'],
      ),
      TimeSeriesFieldConfig(
        name: TO(key: FieldTranslationKeys.batteryChargeDischargePower),
        type: DataFieldType.watt,
        mapping: ['battery_charge_discharge_power'],
      ),
    ];
  }

  @override
  List<DeviceDataField> getDataFields() {
    return [
      // ===== Main Data (no category, always visible) =====

      DeviceDataField(
        name: TO(key: FieldTranslationKeys.dcTotalPower),
        type: DataFieldType.watt,
        valueExtractor: (data) => MapUtils.OM(data, ['data', 'dc_power_total']),
        icon: Icons.electrical_services,
        expertMode: false,
        precision: 1,
      ),

      DeviceDataField(
        name: TO(key: FieldTranslationKeys.acPower),
        type: DataFieldType.watt,
        valueExtractor: (data) => MapUtils.OM(data, ['data', 'ac_power_total']),
        icon: Icons.bolt,
        expertMode: false,
        precision: 1,
      ),

      DeviceDataField(
        name: TO(key: FieldTranslationKeys.dailyYield),
        type: DataFieldType.energy,
        valueExtractor: (data) => MapUtils.OM(data, ['data', 'yield_daily']),
        icon: Icons.wb_sunny,
        expertMode: false,
      ),

      DeviceDataField(
        name: TO(key: FieldTranslationKeys.monthlyYield),
        type: DataFieldType.energy,
        valueExtractor: (data) => MapUtils.OM(data, ['data', 'yield_monthly']),
        icon: Icons.calendar_month,
        expertMode: false,
      ),

      DeviceDataField(
        name: TO(key: FieldTranslationKeys.yearlyYield),
        type: DataFieldType.energy,
        valueExtractor: (data) => MapUtils.OM(data, ['data', 'yield_yearly']),
        icon: Icons.calendar_today,
        expertMode: false,
      ),

      DeviceDataField(
        name: TO(key: FieldTranslationKeys.totalYield),
        type: DataFieldType.energy,
        valueExtractor: (data) => MapUtils.OM(data, ['data', 'yield_total']),
        icon: Icons.show_chart,
        expertMode: false,
      ),

      DeviceDataField(
        name: TO(key: FieldTranslationKeys.gridFrequency),
        type: DataFieldType.frequency,
        valueExtractor: (data) => MapUtils.OM(data, ['data', 'grid_frequency']),
        icon: Icons.waves,
        expertMode: false,
      ),

      // ===== DC String 1 =====

      DeviceDataField(
        name: TO(key: FieldTranslationKeys.pvVoltage, params: {'num': 1}),
        type: DataFieldType.voltage,
        valueExtractor: (data) => MapUtils.OM(data, ['data', 'dc1_voltage']),
        icon: Icons.solar_power,
        expertMode: false,
        category: 'dc1',
      ),

      DeviceDataField(
        name: TO(key: FieldTranslationKeys.pvCurrent, params: {'num': 1}),
        type: DataFieldType.current,
        valueExtractor: (data) => MapUtils.OM(data, ['data', 'dc1_current']),
        icon: Icons.solar_power,
        expertMode: false,
        category: 'dc1',
      ),

      DeviceDataField(
        name: TO(key: FieldTranslationKeys.pvPower, params: {'num': 1}),
        type: DataFieldType.watt,
        valueExtractor: (data) => MapUtils.OM(data, ['data', 'dc1_power']),
        icon: Icons.solar_power,
        expertMode: false,
        category: 'dc1',
        precision: 1,
      ),

      // ===== DC String 2 =====

      DeviceDataField(
        name: TO(key: FieldTranslationKeys.pvVoltage, params: {'num': 2}),
        type: DataFieldType.voltage,
        valueExtractor: (data) => MapUtils.OM(data, ['data', 'dc2_voltage']),
        icon: Icons.solar_power,
        expertMode: false,
        category: 'dc2',
      ),

      DeviceDataField(
        name: TO(key: FieldTranslationKeys.pvCurrent, params: {'num': 2}),
        type: DataFieldType.current,
        valueExtractor: (data) => MapUtils.OM(data, ['data', 'dc2_current']),
        icon: Icons.solar_power,
        expertMode: false,
        category: 'dc2',
      ),

      DeviceDataField(
        name: TO(key: FieldTranslationKeys.pvPower, params: {'num': 2}),
        type: DataFieldType.watt,
        valueExtractor: (data) => MapUtils.OM(data, ['data', 'dc2_power']),
        icon: Icons.solar_power,
        expertMode: false,
        category: 'dc2',
        precision: 1,
      ),

      // ===== DC String 3 =====

      DeviceDataField(
        name: TO(key: FieldTranslationKeys.pvVoltage, params: {'num': 3}),
        type: DataFieldType.voltage,
        valueExtractor: (data) => MapUtils.OM(data, ['data', 'dc3_voltage']),
        icon: Icons.solar_power,
        expertMode: false,
        category: 'dc3',
      ),

      DeviceDataField(
        name: TO(key: FieldTranslationKeys.pvCurrent, params: {'num': 3}),
        type: DataFieldType.current,
        valueExtractor: (data) => MapUtils.OM(data, ['data', 'dc3_current']),
        icon: Icons.solar_power,
        expertMode: false,
        category: 'dc3',
      ),

      DeviceDataField(
        name: TO(key: FieldTranslationKeys.pvPower, params: {'num': 3}),
        type: DataFieldType.watt,
        valueExtractor: (data) => MapUtils.OM(data, ['data', 'dc3_power']),
        icon: Icons.solar_power,
        expertMode: false,
        category: 'dc3',
        precision: 1,
      ),

      // ===== AC Phase 1 =====

      DeviceDataField(
        name: TO(key: FieldTranslationKeys.voltagePhase1),
        type: DataFieldType.voltage,
        valueExtractor: (data) => MapUtils.OM(data, ['data', 'ac_phase1_voltage']),
        icon: Icons.electric_bolt,
        expertMode: false,
        category: 'ac1',
      ),

      DeviceDataField(
        name: TO(key: FieldTranslationKeys.currentPhase1),
        type: DataFieldType.current,
        valueExtractor: (data) => MapUtils.OM(data, ['data', 'ac_phase1_current']),
        icon: Icons.flash_on,
        expertMode: false,
        category: 'ac1',
      ),

      DeviceDataField(
        name: TO(key: FieldTranslationKeys.activePowerPhase1),
        type: DataFieldType.watt,
        valueExtractor: (data) => MapUtils.OM(data, ['data', 'ac_phase1_power']),
        icon: Icons.bolt,
        expertMode: false,
        category: 'ac1',
        precision: 1,
      ),

      // ===== AC Phase 2 =====

      DeviceDataField(
        name: TO(key: FieldTranslationKeys.voltagePhase2),
        type: DataFieldType.voltage,
        valueExtractor: (data) => MapUtils.OM(data, ['data', 'ac_phase2_voltage']),
        icon: Icons.electric_bolt,
        expertMode: false,
        category: 'ac2',
      ),

      DeviceDataField(
        name: TO(key: FieldTranslationKeys.currentPhase2),
        type: DataFieldType.current,
        valueExtractor: (data) => MapUtils.OM(data, ['data', 'ac_phase2_current']),
        icon: Icons.flash_on,
        expertMode: false,
        category: 'ac2',
      ),

      DeviceDataField(
        name: TO(key: FieldTranslationKeys.activePowerPhase2),
        type: DataFieldType.watt,
        valueExtractor: (data) => MapUtils.OM(data, ['data', 'ac_phase2_power']),
        icon: Icons.bolt,
        expertMode: false,
        category: 'ac2',
        precision: 1,
      ),

      // ===== AC Phase 3 =====

      DeviceDataField(
        name: TO(key: FieldTranslationKeys.voltagePhase3),
        type: DataFieldType.voltage,
        valueExtractor: (data) => MapUtils.OM(data, ['data', 'ac_phase3_voltage']),
        icon: Icons.electric_bolt,
        expertMode: false,
        category: 'ac3',
      ),

      DeviceDataField(
        name: TO(key: FieldTranslationKeys.currentPhase3),
        type: DataFieldType.current,
        valueExtractor: (data) => MapUtils.OM(data, ['data', 'ac_phase3_current']),
        icon: Icons.flash_on,
        expertMode: false,
        category: 'ac3',
      ),

      DeviceDataField(
        name: TO(key: FieldTranslationKeys.activePowerPhase3),
        type: DataFieldType.watt,
        valueExtractor: (data) => MapUtils.OM(data, ['data', 'ac_phase3_power']),
        icon: Icons.bolt,
        expertMode: false,
        category: 'ac3',
        precision: 1,
      ),

      // ===== AC Totals (expert mode) =====

      DeviceDataField(
        name: TO(key: FieldTranslationKeys.reactivePowerTotal),
        type: DataFieldType.reactivePower,
        valueExtractor: (data) => MapUtils.OM(data, ['data', 'ac_reactive_power_total']),
        icon: Icons.bolt_outlined,
        expertMode: true,
        category: 'ac_totals',
        precision: 1,
      ),

      DeviceDataField(
        name: TO(key: FieldTranslationKeys.apparentPowerTotal),
        type: DataFieldType.apparentPower,
        valueExtractor: (data) => MapUtils.OM(data, ['data', 'ac_apparent_power_total']),
        icon: Icons.bolt_outlined,
        expertMode: true,
        category: 'ac_totals',
        precision: 1,
      ),

      // ===== Battery =====

      DeviceDataField(
        name: TO(key: FieldTranslationKeys.batterySoc),
        type: DataFieldType.percentage,
        valueExtractor: (data) {
          // Try both SOC fields
          var value = MapUtils.OM(data, ['data', 'battery_soc']);
          value ??= MapUtils.OM(data, ['data', 'battery_soc_actual']);
          return value;
        },
        icon: Icons.battery_charging_full,
        expertMode: false,
        category: 'battery',
        precision: 1,
      ),

      DeviceDataField(
        name: TO(key: FieldTranslationKeys.voltage),
        type: DataFieldType.voltage,
        valueExtractor: (data) => MapUtils.OM(data, ['data', 'battery_voltage']),
        icon: Icons.battery_std,
        expertMode: false,
        category: 'battery',
      ),

      DeviceDataField(
        name: TO(key: FieldTranslationKeys.current),
        type: DataFieldType.current,
        valueExtractor: (data) => MapUtils.OM(data, ['data', 'battery_current']),
        icon: Icons.flash_on,
        expertMode: false,
        category: 'battery',
      ),

      DeviceDataField(
        name: TO(key: FieldTranslationKeys.batteryPower),
        type: DataFieldType.watt,
        valueExtractor: (data) => MapUtils.OM(data, ['data', 'battery_charge_discharge_power']),
        icon: Icons.power,
        expertMode: false,
        category: 'battery',
        precision: 1,
      ),

      DeviceDataField(
        name: TO(key: FieldTranslationKeys.temperature),
        type: DataFieldType.temperature,
        valueExtractor: (data) => MapUtils.OM(data, ['data', 'battery_temperature']),
        icon: Icons.thermostat,
        expertMode: false,
        category: 'battery',
      ),

      DeviceDataField(
        name: TO(key: FieldTranslationKeys.batteryCycles),
        type: DataFieldType.count,
        valueExtractor: (data) => MapUtils.OM(data, ['data', 'battery_cycles']),
        icon: Icons.loop,
        expertMode: true,
        category: 'battery',
      ),

      DeviceDataField(
        name: TO(key: FieldTranslationKeys.batteryCapacityGross),
        type: DataFieldType.energy,
        valueExtractor: (data) => MapUtils.OM(data, ['data', 'battery_capacity_gross']),
        icon: Icons.battery_full,
        expertMode: true,
        category: 'battery',
      ),

      DeviceDataField(
        name: TO(key: FieldTranslationKeys.batteryCapacityNet),
        type: DataFieldType.energy,
        valueExtractor: (data) => MapUtils.OM(data, ['data', 'battery_capacity_net']),
        icon: Icons.battery_full,
        expertMode: true,
        category: 'battery',
      ),

      DeviceDataField(
        name: TO(key: FieldTranslationKeys.manufacturer),
        type: DataFieldType.none,
        valueExtractor: (data) => MapUtils.OM(data, ['data', 'battery_manufacturer']),
        icon: Icons.business,
        expertMode: true,
        showDetailButton: true,
        category: 'battery',
      ),

      // ===== Home Consumption =====

      DeviceDataField(
        name: TO(key: FieldTranslationKeys.totalConsumption),
        type: DataFieldType.watt,
        valueExtractor: (data) => MapUtils.OM(data, ['data', 'consumption_total']),
        icon: Icons.home,
        expertMode: false,
        category: 'consumption',
        precision: 1,
      ),

      DeviceDataField(
        name: TO(key: FieldTranslationKeys.consumptionFromPv),
        type: DataFieldType.watt,
        valueExtractor: (data) => MapUtils.OM(data, ['data', 'consumption_pv']),
        icon: Icons.solar_power,
        expertMode: false,
        category: 'consumption',
        precision: 1,
      ),

      DeviceDataField(
        name: TO(key: FieldTranslationKeys.consumptionFromGrid),
        type: DataFieldType.watt,
        valueExtractor: (data) => MapUtils.OM(data, ['data', 'consumption_grid']),
        icon: Icons.grid_on,
        expertMode: false,
        category: 'consumption',
        precision: 1,
      ),

      DeviceDataField(
        name: TO(key: FieldTranslationKeys.consumptionFromBattery),
        type: DataFieldType.watt,
        valueExtractor: (data) => MapUtils.OM(data, ['data', 'consumption_battery']),
        icon: Icons.battery_charging_full,
        expertMode: false,
        category: 'consumption',
        precision: 1,
      ),

      // ===== Powermeter =====

      DeviceDataField(
        name: TO(key: FieldTranslationKeys.activePowerTotal),
        type: DataFieldType.watt,
        valueExtractor: (data) => MapUtils.OM(data, ['data', 'powermeter_active_power_total']),
        icon: Icons.bolt,
        expertMode: false,
        category: 'powermeter',
        precision: 1,
      ),

      DeviceDataField(
        name: TO(key: FieldTranslationKeys.reactivePowerTotal),
        type: DataFieldType.reactivePower,
        valueExtractor: (data) => MapUtils.OM(data, ['data', 'powermeter_reactive_power_total']),
        icon: Icons.bolt_outlined,
        expertMode: true,
        category: 'powermeter',
        precision: 1,
      ),

      DeviceDataField(
        name: TO(key: FieldTranslationKeys.apparentPowerTotal),
        type: DataFieldType.apparentPower,
        valueExtractor: (data) => MapUtils.OM(data, ['data', 'powermeter_apparent_power_total']),
        icon: Icons.bolt_outlined,
        expertMode: true,
        category: 'powermeter',
        precision: 1,
      ),

      DeviceDataField(
        name: TO(key: FieldTranslationKeys.frequency),
        type: DataFieldType.frequency,
        valueExtractor: (data) => MapUtils.OM(data, ['data', 'powermeter_frequency']),
        icon: Icons.waves,
        expertMode: true,
        category: 'powermeter',
      ),

      DeviceDataField(
        name: TO(key: FieldTranslationKeys.powerFactor),
        type: DataFieldType.powerFactor,
        valueExtractor: (data) => MapUtils.OM(data, ['data', 'powermeter_cos_phi']),
        icon: Icons.functions,
        expertMode: true,
        category: 'powermeter',
      ),

      // Powermeter Phase 1
      DeviceDataField(
        name: TO(key: FieldTranslationKeys.voltage),
        type: DataFieldType.voltage,
        valueExtractor: (data) => MapUtils.OM(data, ['data', 'powermeter_phase1_voltage']),
        icon: Icons.electric_bolt,
        expertMode: true,
        category: 'powermeter_phase1',
      ),

      DeviceDataField(
        name: TO(key: FieldTranslationKeys.current),
        type: DataFieldType.current,
        valueExtractor: (data) => MapUtils.OM(data, ['data', 'powermeter_phase1_current']),
        icon: Icons.flash_on,
        expertMode: true,
        category: 'powermeter_phase1',
      ),

      DeviceDataField(
        name: TO(key: FieldTranslationKeys.activePowerPhase1),
        type: DataFieldType.watt,
        valueExtractor: (data) => MapUtils.OM(data, ['data', 'powermeter_phase1_active_power']),
        icon: Icons.bolt,
        expertMode: true,
        category: 'powermeter_phase1',
        precision: 1,
      ),

      // Powermeter Phase 2
      DeviceDataField(
        name: TO(key: FieldTranslationKeys.voltagePhase2),
        type: DataFieldType.voltage,
        valueExtractor: (data) => MapUtils.OM(data, ['data', 'powermeter_phase2_voltage']),
        icon: Icons.electric_bolt,
        expertMode: true,
        category: 'powermeter_phase2',
      ),

      DeviceDataField(
        name: TO(key: FieldTranslationKeys.currentPhase2),
        type: DataFieldType.current,
        valueExtractor: (data) => MapUtils.OM(data, ['data', 'powermeter_phase2_current']),
        icon: Icons.flash_on,
        expertMode: true,
        category: 'powermeter_phase2',
      ),

      DeviceDataField(
        name: TO(key: FieldTranslationKeys.activePowerPhase2),
        type: DataFieldType.watt,
        valueExtractor: (data) => MapUtils.OM(data, ['data', 'powermeter_phase2_active_power']),
        icon: Icons.bolt,
        expertMode: true,
        category: 'powermeter_phase2',
        precision: 1,
      ),

      // Powermeter Phase 3
      DeviceDataField(
        name: TO(key: FieldTranslationKeys.voltagePhase3),
        type: DataFieldType.voltage,
        valueExtractor: (data) => MapUtils.OM(data, ['data', 'powermeter_phase3_voltage']),
        icon: Icons.electric_bolt,
        expertMode: true,
        category: 'powermeter_phase3',
      ),

      DeviceDataField(
        name: TO(key: FieldTranslationKeys.currentPhase3),
        type: DataFieldType.current,
        valueExtractor: (data) => MapUtils.OM(data, ['data', 'powermeter_phase3_current']),
        icon: Icons.flash_on,
        expertMode: true,
        category: 'powermeter_phase3',
      ),

      DeviceDataField(
        name: TO(key: FieldTranslationKeys.activePowerPhase3),
        type: DataFieldType.watt,
        valueExtractor: (data) => MapUtils.OM(data, ['data', 'powermeter_phase3_active_power']),
        icon: Icons.bolt,
        expertMode: true,
        category: 'powermeter_phase3',
        precision: 1,
      ),

      // ===== System Info =====

      DeviceDataField(
        name: TO(key: FieldTranslationKeys.articleNumber),
        type: DataFieldType.none,
        valueExtractor: (data) => MapUtils.OM(data, ['data', 'article_number']),
        icon: Icons.tag,
        expertMode: true,
        showDetailButton: true,
        category: 'system',
      ),

      DeviceDataField(
        name: TO(key: FieldTranslationKeys.maxInverterPower),
        type: DataFieldType.watt,
        valueExtractor: (data) => MapUtils.OM(data, ['data', 'inverter_max_power']),
        icon: Icons.power,
        expertMode: true,
        category: 'system',
      ),

      DeviceDataField(
        name: TO(key: FieldTranslationKeys.inverterGenerationPower),
        type: DataFieldType.watt,
        valueExtractor: (data) => MapUtils.OM(data, ['data', 'inverter_generation_power']),
        icon: Icons.bolt,
        expertMode: true,
        category: 'system',
        precision: 1,
      ),

      DeviceDataField(
        name: TO(key: FieldTranslationKeys.uptime),
        type: DataFieldType.none,
        valueExtractor: (data) {
          final value = MapUtils.OM(data, ['data', 'work_time']);
          if (value == null) return null;
          final hours = value is num ? value : num.tryParse(value.toString());
          return hours != null ? '$hours h' : null;
        },
        icon: Icons.timer,
        expertMode: true,
        category: 'system',
      ),

      DeviceDataField(
        name: TO(key: FieldTranslationKeys.isolationResistance),
        type: DataFieldType.resistance,
        valueExtractor: (data) => MapUtils.OM(data, ['data', 'isolation_resistance']),
        icon: Icons.shield,
        expertMode: true,
        category: 'system',
      ),

      DeviceDataField(
        name: TO(key: FieldTranslationKeys.powerFactor),
        type: DataFieldType.powerFactor,
        valueExtractor: (data) => MapUtils.OM(data, ['data', 'cos_phi_actual']),
        icon: Icons.functions,
        expertMode: true,
        category: 'system',
      ),

      DeviceDataField(
        name: TO(key: FieldTranslationKeys.powerLimit),
        type: DataFieldType.watt,
        valueExtractor: (data) => MapUtils.OM(data, ['data', 'power_limit_evu']),
        icon: Icons.speed,
        expertMode: true,
        category: 'system',
        precision: 1,
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
        displayNameKey: CategoryTranslationKeys.dcString1,
        layout: CategoryLayout.standard,
        order: 10,
      ),
      const DeviceCategoryConfig(
        category: 'dc2',
        displayName: 'DC String 2',
        displayNameKey: CategoryTranslationKeys.dcString2,
        layout: CategoryLayout.standard,
        order: 20,
      ),
      const DeviceCategoryConfig(
        category: 'dc3',
        displayName: 'DC String 3',
        displayNameKey: CategoryTranslationKeys.dcString3,
        layout: CategoryLayout.standard,
        order: 30,
      ),
      const DeviceCategoryConfig(
        category: 'ac1',
        displayName: 'AC Phase 1',
        displayNameKey: CategoryTranslationKeys.acPhase1,
        layout: CategoryLayout.standard,
        order: 40,
      ),
      const DeviceCategoryConfig(
        category: 'ac2',
        displayName: 'AC Phase 2',
        displayNameKey: CategoryTranslationKeys.acPhase2,
        layout: CategoryLayout.standard,
        order: 50,
      ),
      const DeviceCategoryConfig(
        category: 'ac3',
        displayName: 'AC Phase 3',
        displayNameKey: CategoryTranslationKeys.acPhase3,
        layout: CategoryLayout.standard,
        order: 60,
      ),
      const DeviceCategoryConfig(
        category: 'ac_totals',
        displayName: 'AC Gesamt',
        displayNameKey: CategoryTranslationKeys.acTotal,
        layout: CategoryLayout.standard,
        order: 65,
      ),
      const DeviceCategoryConfig(
        category: 'battery',
        displayName: 'Batterie',
        displayNameKey: CategoryTranslationKeys.battery,
        layout: CategoryLayout.standard,
        order: 70,
      ),
      const DeviceCategoryConfig(
        category: 'consumption',
        displayName: 'Hausverbrauch',
        displayNameKey: CategoryTranslationKeys.homeConsumption,
        layout: CategoryLayout.standard,
        order: 80,
      ),
      const DeviceCategoryConfig(
        category: 'powermeter',
        displayName: 'Leistungsmesser',
        displayNameKey: CategoryTranslationKeys.powerMeter,
        layout: CategoryLayout.standard,
        order: 90,
      ),
      const DeviceCategoryConfig(
        category: 'powermeter_phase1',
        displayName: 'Leistungsmesser Phase 1',
        displayNameKey: CategoryTranslationKeys.powerMeterPhase1,
        layout: CategoryLayout.standard,
        order: 91,
      ),
      const DeviceCategoryConfig(
        category: 'powermeter_phase2',
        displayName: 'Leistungsmesser Phase 2',
        displayNameKey: CategoryTranslationKeys.powerMeterPhase2,
        layout: CategoryLayout.standard,
        order: 92,
      ),
      const DeviceCategoryConfig(
        category: 'powermeter_phase3',
        displayName: 'Leistungsmesser Phase 3',
        displayNameKey: CategoryTranslationKeys.powerMeterPhase3,
        layout: CategoryLayout.standard,
        order: 93,
      ),
      const DeviceCategoryConfig(
        category: 'system',
        displayName: 'System',
        displayNameKey: CategoryTranslationKeys.system,
        layout: CategoryLayout.oneLine,
        order: 100,
      ),
    ];
  }

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
