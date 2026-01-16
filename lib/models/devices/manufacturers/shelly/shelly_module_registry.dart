import 'package:flutter/material.dart';
import 'package:the_solar_app/models/devices/generic_rendering/device_data_field.dart';
import 'package:the_solar_app/models/devices/generic_rendering/device_control_item.dart';
import 'package:the_solar_app/constants/command_constants.dart';

/// Template for data field configuration
class FieldTemplate {
  final String name;                 // Display name (e.g., "Phase 1 Spannung")
  final String path;                 // JSON path (e.g., "a_voltage")
  final DataFieldType type;          // voltage, current, watt, etc.
  final IconData icon;
  final bool isExpert;               // Requires expert mode
  final String? Function(dynamic)? formatter; // Optional value formatter
  final String? category;            // Optional category for grouping (e.g., "phase1", "totals")
  final bool hideIfEmpty;            // Hide field when value is null

  const FieldTemplate({
    required this.name,
    required this.path,
    required this.type,
    required this.icon,
    this.isExpert = false,
    this.formatter,
    this.category,
    this.hideIfEmpty = false,
  });
}

/// Template for control item configuration
class ControlTemplate {
  final String name;                 // Display name (e.g., "Steckdose")
  final ControlType type;            // switchToggle, slider, etc.
  final String commandName;          // RPC method (e.g., "Switch.Set")
  final String statePath;            // JSON path for current value
  final IconData icon;
  final Map<String, dynamic> Function(dynamic) buildParams;  // Build command parameters
  final String Function(dynamic) getLoadingMessage;         // Loading message formatter

  const ControlTemplate({
    required this.name,
    required this.type,
    required this.commandName,
    required this.statePath,
    required this.icon,
    required this.buildParams,
    required this.getLoadingMessage,
  });
}

/// Configuration for a Shelly module type
class ShellyModuleConfig {
  final String moduleType;          // e.g., "em", "switch", "cover"
  final IconData icon;               // Device icon
  final List<FieldTemplate> fields;  // Data field templates
  final List<ControlTemplate> controls; // Control item templates
  final bool supportsTimeSeries;     // Time series tracking enabled

  const ShellyModuleConfig({
    required this.moduleType,
    required this.icon,
    required this.fields,
    this.controls = const [],
    this.supportsTimeSeries = false,
  });
}

/// Registry of Shelly module configurations
class ShellyModuleRegistry {
  /// EM (Energy Meter) Module Configuration
  /// 3-phase energy monitoring with voltage, current, and power measurements
  static const emConfig = ShellyModuleConfig(
    moduleType: 'em',
    icon: Icons.electric_meter,
    fields: [
      // Phase A
      FieldTemplate(
        name: 'Phase 1 Spannung',
        path: 'a_voltage',
        type: DataFieldType.voltage,
        icon: Icons.electric_bolt,
        isExpert: false,
        category: 'phase1',
      ),
      FieldTemplate(
        name: 'Phase 1 Strom',
        path: 'a_current',
        type: DataFieldType.current,
        icon: Icons.flash_on,
        isExpert: true,
        category: 'phase1',
      ),
      FieldTemplate(
        name: 'Phase 1 Leistung',
        path: 'a_act_power',
        type: DataFieldType.watt,
        icon: Icons.power,
        isExpert: false,
        category: 'phase1',
      ),

      // Phase B
      FieldTemplate(
        name: 'Phase 2 Spannung',
        path: 'b_voltage',
        type: DataFieldType.voltage,
        icon: Icons.electric_bolt,
        isExpert: false,
        category: 'phase2',
      ),
      FieldTemplate(
        name: 'Phase 2 Strom',
        path: 'b_current',
        type: DataFieldType.current,
        icon: Icons.flash_on,
        isExpert: true,
        category: 'phase2',
      ),
      FieldTemplate(
        name: 'Phase 2 Leistung',
        path: 'b_act_power',
        type: DataFieldType.watt,
        icon: Icons.power,
        isExpert: false,
        category: 'phase2',
      ),

      // Phase C
      FieldTemplate(
        name: 'Phase 3 Spannung',
        path: 'c_voltage',
        type: DataFieldType.voltage,
        icon: Icons.electric_bolt,
        isExpert: false,
        category: 'phase3',
      ),
      FieldTemplate(
        name: 'Phase 3 Strom',
        path: 'c_current',
        type: DataFieldType.current,
        icon: Icons.flash_on,
        isExpert: true,
        category: 'phase3',
      ),
      FieldTemplate(
        name: 'Phase 3 Leistung',
        path: 'c_act_power',
        type: DataFieldType.watt,
        icon: Icons.power,
        isExpert: false,
        category: 'phase3',
      ),

      // Totals
      FieldTemplate(
        name: 'Gesamt Leistung',
        path: 'total_act_power',
        type: DataFieldType.watt,
        icon: Icons.power_settings_new,
        isExpert: false,
        category: 'totals',
      ),
    ],
    supportsTimeSeries: true,
  );

  /// Switch Module Configuration
  /// Smart switch with on/off control + power monitoring
  static final switchConfig = ShellyModuleConfig(
    moduleType: 'switch',
    icon: Icons.power,
    fields: const [
      FieldTemplate(
        name: 'Status',
        path: 'output',
        type: DataFieldType.none,
        icon: Icons.power_settings_new,
        isExpert: false,
        formatter: _formatBooleanStatus,
        category: 'instance',
      ),
      FieldTemplate(
        name: 'Leistung',
        path: 'apower',
        type: DataFieldType.watt,
        icon: Icons.power,
        isExpert: false,
        category: 'instance',
        hideIfEmpty: true,
      ),
      FieldTemplate(
        name: 'Spannung',
        path: 'voltage',
        type: DataFieldType.voltage,
        icon: Icons.electric_bolt,
        isExpert: false,
        category: 'instance',
        hideIfEmpty: true,
      ),
      FieldTemplate(
        name: 'Strom',
        path: 'current',
        type: DataFieldType.current,
        icon: Icons.flash_on,
        isExpert: true,
        category: 'instance',
        hideIfEmpty: true,
      ),
      FieldTemplate(
        name: 'Temperatur',
        path: 'temperature.tC',
        type: DataFieldType.temperature,
        icon: Icons.thermostat,
        isExpert: false,
        category: 'instance',
        hideIfEmpty: true,
      ),
      FieldTemplate(
        name: 'Gesamt Energie',
        path: 'aenergy.total',
        type: DataFieldType.watt,
        icon: Icons.bar_chart,
        isExpert: true,
        category: 'instance',
        hideIfEmpty: true,
      ),
    ],
    controls: [
      ControlTemplate(
        name: 'Steckdose',
        type: ControlType.switchToggle,
        commandName: COMMAND_SET_MAIN_POWER,
        statePath: 'output',
        icon: Icons.power,
        buildParams: (val) => {"on": val as bool},
        getLoadingMessage: (val) => 'Schalte Steckdose ${(val as bool) ? "ein" : "aus"}...',
      ),
    ],
    supportsTimeSeries: true,
  );

  /// EM1 (Single-Phase Energy Meter) Module Configuration
  /// Single-phase energy monitoring per instance
  static const em1Config = ShellyModuleConfig(
    moduleType: 'em1',
    icon: Icons.electric_meter,
    fields: [
      FieldTemplate(
        name: 'Spannung',
        path: 'voltage',
        type: DataFieldType.voltage,
        icon: Icons.electric_bolt,
        isExpert: false,
        category: 'instance',  // Will be converted to messung_X
      ),
      FieldTemplate(
        name: 'Strom',
        path: 'current',
        type: DataFieldType.current,
        icon: Icons.flash_on,
        isExpert: true,
        category: 'instance',
      ),
      FieldTemplate(
        name: 'Wirkleistung',
        path: 'act_power',
        type: DataFieldType.watt,
        icon: Icons.power,
        isExpert: false,
        category: 'instance',
      ),
      FieldTemplate(
        name: 'Scheinleistung',
        path: 'aprt_power',
        type: DataFieldType.watt,
        icon: Icons.power_outlined,
        isExpert: true,
        category: 'instance',
      ),
      FieldTemplate(
        name: 'Leistungsfaktor',
        path: 'pf',
        type: DataFieldType.none,
        icon: Icons.analytics,
        isExpert: true,
        category: 'instance',
      ),
      FieldTemplate(
        name: 'Frequenz',
        path: 'freq',
        type: DataFieldType.none,
        icon: Icons.waves,
        isExpert: true,
        category: 'instance',
      ),
    ],
    supportsTimeSeries: true,
  );

  /// EM1Data Module Configuration
  /// Energy totals per EM1 instance
  static const em1dataConfig = ShellyModuleConfig(
    moduleType: 'em1data',
    icon: Icons.bar_chart,
    fields: [
      FieldTemplate(
        name: 'Gesamt Energie (Bezug)',
        path: 'total_act_energy',
        type: DataFieldType.energy,
        icon: Icons.arrow_downward,
        isExpert: false,
        category: 'instance',  // Will be converted to messung_X
      ),
      FieldTemplate(
        name: 'Gesamt Energie (Einspeisung)',
        path: 'total_act_ret_energy',
        type: DataFieldType.energy,
        icon: Icons.arrow_upward,
        isExpert: true,
        category: 'instance',
      ),
    ],
    supportsTimeSeries: false,
  );

  /// EMData Module Configuration
  /// Energy totals for 3-phase EM module
  static const emdataConfig = ShellyModuleConfig(
    moduleType: 'emdata',
    icon: Icons.bar_chart,
    fields: [
      // Phase A Energy
      FieldTemplate(
        name: 'Phase 1 Energie (Bezug)',
        path: 'a_total_act_energy',
        type: DataFieldType.energy,
        icon: Icons.arrow_downward,
        isExpert: false,
        category: 'phase1',
      ),
      FieldTemplate(
        name: 'Phase 1 Energie (Einspeisung)',
        path: 'a_total_act_ret_energy',
        type: DataFieldType.energy,
        icon: Icons.arrow_upward,
        isExpert: true,
        category: 'phase1',
      ),

      // Phase B Energy
      FieldTemplate(
        name: 'Phase 2 Energie (Bezug)',
        path: 'b_total_act_energy',
        type: DataFieldType.energy,
        icon: Icons.arrow_downward,
        isExpert: false,
        category: 'phase2',
      ),
      FieldTemplate(
        name: 'Phase 2 Energie (Einspeisung)',
        path: 'b_total_act_ret_energy',
        type: DataFieldType.energy,
        icon: Icons.arrow_upward,
        isExpert: true,
        category: 'phase2',
      ),

      // Phase C Energy
      FieldTemplate(
        name: 'Phase 3 Energie (Bezug)',
        path: 'c_total_act_energy',
        type: DataFieldType.energy,
        icon: Icons.arrow_downward,
        isExpert: false,
        category: 'phase3',
      ),
      FieldTemplate(
        name: 'Phase 3 Energie (Einspeisung)',
        path: 'c_total_act_ret_energy',
        type: DataFieldType.energy,
        icon: Icons.arrow_upward,
        isExpert: true,
        category: 'phase3',
      ),

      // Total Energy
      FieldTemplate(
        name: 'Gesamt Energie (Bezug)',
        path: 'total_act',
        type: DataFieldType.energy,
        icon: Icons.energy_savings_leaf,
        isExpert: false,
        category: 'totals',
      ),
      FieldTemplate(
        name: 'Gesamt Energie (Einspeisung)',
        path: 'total_act_ret',
        type: DataFieldType.energy,
        icon: Icons.arrow_circle_up,
        isExpert: false,
        category: 'totals',
      ),
    ],
    supportsTimeSeries: false,
  );

  /// Temperature Module Configuration
  /// Temperature sensor reading
  static const temperatureConfig = ShellyModuleConfig(
    moduleType: 'temperature',
    icon: Icons.thermostat,
    fields: [
      FieldTemplate(
        name: 'Temperatur',
        path: 'tC',
        type: DataFieldType.temperature,
        icon: Icons.thermostat,
        isExpert: false,
      ),
    ],
    supportsTimeSeries: false,
  );

  /// PM1 Module (Power Meter Gen3) Configuration
  /// Single-phase power monitoring with bidirectional energy tracking
  static final pm1Config = ShellyModuleConfig(
    moduleType: 'pm1',
    icon: Icons.electric_meter,
    fields: [
      FieldTemplate(
        name: 'Spannung',
        path: 'voltage',
        type: DataFieldType.voltage,
        icon: Icons.bolt,
        isExpert: false,
        category: 'instance',  // Will be converted to pm_messung_X
      ),
      FieldTemplate(
        name: 'Strom',
        path: 'current',
        type: DataFieldType.current,
        icon: Icons.flash_on,
        isExpert: false,
        category: 'instance',
      ),
      FieldTemplate(
        name: 'Wirkleistung',
        path: 'apower',
        type: DataFieldType.watt,
        icon: Icons.power,
        isExpert: false,
        category: 'instance',
      ),
      FieldTemplate(
        name: 'Frequenz',
        path: 'freq',
        type: DataFieldType.frequency,
        icon: Icons.waves,
        isExpert: false,
        category: 'instance',
      ),
      FieldTemplate(
        name: 'Gesamtenergie (Bezug)',
        path: 'aenergy.total',
        type: DataFieldType.energy,
        icon: Icons.energy_savings_leaf,
        isExpert: false,
        category: 'instance',
      ),
      FieldTemplate(
        name: 'Gesamtenergie (Einspeisung)',
        path: 'ret_aenergy.total',
        type: DataFieldType.energy,
        icon: Icons.arrow_circle_up,
        isExpert: false,
        category: 'instance',
      ),
      FieldTemplate(
        name: 'Energie pro Minute (Bezug)',
        path: 'aenergy.by_minute',
        type: DataFieldType.none,
        icon: Icons.show_chart,
        isExpert: true,
        category: 'instance',
        formatter: (value) {
          if (value is List && value.isNotEmpty) {
            final latest = value.last;
            return '${latest.toStringAsFixed(1)} Wh/min';
          }
          return 'N/A';
        },
      ),
      FieldTemplate(
        name: 'Energie pro Minute (Einspeisung)',
        path: 'ret_aenergy.by_minute',
        type: DataFieldType.none,
        icon: Icons.show_chart,
        isExpert: true,
        category: 'instance',
        formatter: (value) {
          if (value is List && value.isNotEmpty) {
            final latest = value.last;
            return '${latest.toStringAsFixed(1)} Wh/min';
          }
          return 'N/A';
        },
      ),
    ],
    supportsTimeSeries: true,
  );

  /// Registry of all module configurations
  static final Map<String, ShellyModuleConfig> configs = {
    'em': emConfig,
    'em1': em1Config,
    'em1data': em1dataConfig,
    'emdata': emdataConfig,
    'switch': switchConfig,
    'temperature': temperatureConfig,
    'pm1': pm1Config,
    // Future: 'cover', 'input', 'light', etc.
  };

  /// Helper: Format boolean value as Ein/Aus
  static String? _formatBooleanStatus(dynamic value) {
    if (value is bool) {
      return value ? 'Ein' : 'Aus';
    }
    return value?.toString();
  }
}
