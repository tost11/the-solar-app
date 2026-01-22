import 'package:flutter/material.dart';
import 'package:the_solar_app/models/devices/generic_rendering/device_data_field.dart';
import 'package:the_solar_app/models/devices/generic_rendering/device_control_item.dart';
import 'package:the_solar_app/constants/command_constants.dart';
import 'package:the_solar_app/constants/translation_keys.dart';
import 'package:the_solar_app/models/to.dart';

/// Template for data field configuration
class FieldTemplate {
  final TO name;                     // Translation object for field name
  final bool needsInstanceParam;     // Whether to add {instanceNum} parameter at runtime
  final String path;                 // JSON path (e.g., "a_voltage")
  final DataFieldType type;          // voltage, current, watt, etc.
  final IconData icon;
  final bool isExpert;               // Requires expert mode
  final String? Function(dynamic)? formatter; // Optional value formatter
  final String? category;            // Optional category for grouping (e.g., "phase1", "totals")
  final bool hideIfEmpty;            // Hide field when value is null

  const FieldTemplate({
    required this.name,
    this.needsInstanceParam = false,
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
  final String name;                 // Display name (e.g., "Steckdose") - legacy field
  final String? nameKey;             // Translation key (e.g., FieldTranslationKeys.socket)
  final bool needsInstanceParam;     // Whether name needs {instanceNum} param
  final ControlType type;            // switchToggle, slider, etc.
  final String commandName;          // RPC method (e.g., "Switch.Set")
  final String statePath;            // JSON path for current value
  final IconData icon;
  final Map<String, dynamic> Function(dynamic) buildParams;  // Build command parameters
  final String Function(dynamic) getLoadingMessage;         // Loading message formatter

  const ControlTemplate({
    required this.name,
    this.nameKey,
    this.needsInstanceParam = false,
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
        name: TO(key: FieldTranslationKeys.voltagePhase1),
        path: 'a_voltage',
        type: DataFieldType.voltage,
        icon: Icons.electric_bolt,
        isExpert: false,
        category: 'phase1',
      ),
      FieldTemplate(
        name: TO(key: FieldTranslationKeys.currentPhase1),
        path: 'a_current',
        type: DataFieldType.current,
        icon: Icons.flash_on,
        isExpert: true,
        category: 'phase1',
      ),
      FieldTemplate(
        name: TO(key: FieldTranslationKeys.powerPhase1),
        path: 'a_act_power',
        type: DataFieldType.watt,
        icon: Icons.power,
        isExpert: false,
        category: 'phase1',
      ),

      // Phase B
      FieldTemplate(
        name: TO(key: FieldTranslationKeys.voltagePhase2),
        path: 'b_voltage',
        type: DataFieldType.voltage,
        icon: Icons.electric_bolt,
        isExpert: false,
        category: 'phase2',
      ),
      FieldTemplate(
        name: TO(key: FieldTranslationKeys.currentPhase2),
        path: 'b_current',
        type: DataFieldType.current,
        icon: Icons.flash_on,
        isExpert: true,
        category: 'phase2',
      ),
      FieldTemplate(
        name: TO(key: FieldTranslationKeys.powerPhase2),
        path: 'b_act_power',
        type: DataFieldType.watt,
        icon: Icons.power,
        isExpert: false,
        category: 'phase2',
      ),

      // Phase C
      FieldTemplate(
        name: TO(key: FieldTranslationKeys.voltagePhase3),
        path: 'c_voltage',
        type: DataFieldType.voltage,
        icon: Icons.electric_bolt,
        isExpert: false,
        category: 'phase3',
      ),
      FieldTemplate(
        name: TO(key: FieldTranslationKeys.currentPhase3),
        path: 'c_current',
        type: DataFieldType.current,
        icon: Icons.flash_on,
        isExpert: true,
        category: 'phase3',
      ),
      FieldTemplate(
        name: TO(key: FieldTranslationKeys.powerPhase3),
        path: 'c_act_power',
        type: DataFieldType.watt,
        icon: Icons.power,
        isExpert: false,
        category: 'phase3',
      ),

      // Totals
      FieldTemplate(
        name: TO(key: FieldTranslationKeys.totalPower),
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
        name: TO(key: FieldTranslationKeys.statusInstance),
        needsInstanceParam: true,
        path: 'output',
        type: DataFieldType.none,
        icon: Icons.power_settings_new,
        isExpert: false,
        formatter: _formatBooleanStatus,
        category: 'instance',
      ),
      FieldTemplate(
        name: TO(key: FieldTranslationKeys.powerInstance),
        needsInstanceParam: true,
        path: 'apower',
        type: DataFieldType.watt,
        icon: Icons.power,
        isExpert: false,
        category: 'instance',
        hideIfEmpty: true,
      ),
      FieldTemplate(
        name: TO(key: FieldTranslationKeys.voltageInstance),
        needsInstanceParam: true,
        path: 'voltage',
        type: DataFieldType.voltage,
        icon: Icons.electric_bolt,
        isExpert: false,
        category: 'instance',
        hideIfEmpty: true,
      ),
      FieldTemplate(
        name: TO(key: FieldTranslationKeys.currentInstance),
        needsInstanceParam: true,
        path: 'current',
        type: DataFieldType.current,
        icon: Icons.flash_on,
        isExpert: true,
        category: 'instance',
        hideIfEmpty: true,
      ),
      FieldTemplate(
        name: TO(key: FieldTranslationKeys.temperatureInstance),
        needsInstanceParam: true,
        path: 'temperature.tC',
        type: DataFieldType.temperature,
        icon: Icons.thermostat,
        isExpert: false,
        category: 'instance',
        hideIfEmpty: true,
      ),
      FieldTemplate(
        name: TO(key: FieldTranslationKeys.totalEnergy),
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
        name: TO(key: FieldTranslationKeys.voltageInstance),
        needsInstanceParam: true,
        path: 'voltage',
        type: DataFieldType.voltage,
        icon: Icons.electric_bolt,
        isExpert: false,
        category: 'instance',  // Will be converted to messung_X
      ),
      FieldTemplate(
        name: TO(key: FieldTranslationKeys.currentInstance),
        needsInstanceParam: true,
        path: 'current',
        type: DataFieldType.current,
        icon: Icons.flash_on,
        isExpert: true,
        category: 'instance',
      ),
      FieldTemplate(
        name: TO(key: FieldTranslationKeys.activePowerInstance),
        needsInstanceParam: true,
        path: 'act_power',
        type: DataFieldType.watt,
        icon: Icons.power,
        isExpert: false,
        category: 'instance',
      ),
      FieldTemplate(
        name: TO(key: FieldTranslationKeys.apparentPowerInstance),
        needsInstanceParam: true,
        path: 'aprt_power',
        type: DataFieldType.watt,
        icon: Icons.power_outlined,
        isExpert: true,
        category: 'instance',
      ),
      FieldTemplate(
        name: TO(key: FieldTranslationKeys.powerFactorInstance),
        needsInstanceParam: true,
        path: 'pf',
        type: DataFieldType.none,
        icon: Icons.analytics,
        isExpert: true,
        category: 'instance',
      ),
      FieldTemplate(
        name: TO(key: FieldTranslationKeys.frequencyInstance),
        needsInstanceParam: true,
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
        name: TO(key: FieldTranslationKeys.totalEnergyImport),
        needsInstanceParam: true,
        path: 'total_act_energy',
        type: DataFieldType.energy,
        icon: Icons.arrow_downward,
        isExpert: false,
        category: 'instance',  // Will be converted to messung_X
      ),
      FieldTemplate(
        name: TO(key: FieldTranslationKeys.totalEnergyExport),
        needsInstanceParam: true,
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
        name: TO(key: FieldTranslationKeys.totalEnergyImport),
        path: 'a_total_act_energy',
        type: DataFieldType.energy,
        icon: Icons.arrow_downward,
        isExpert: false,
        category: 'phase1',
      ),
      FieldTemplate(
        name: TO(key: FieldTranslationKeys.totalEnergyExport),
        path: 'a_total_act_ret_energy',
        type: DataFieldType.energy,
        icon: Icons.arrow_upward,
        isExpert: true,
        category: 'phase1',
      ),

      // Phase B Energy
      FieldTemplate(
        name: TO(key: FieldTranslationKeys.totalEnergyImport),
        path: 'b_total_act_energy',
        type: DataFieldType.energy,
        icon: Icons.arrow_downward,
        isExpert: false,
        category: 'phase2',
      ),
      FieldTemplate(
        name: TO(key: FieldTranslationKeys.totalEnergyExport),
        path: 'b_total_act_ret_energy',
        type: DataFieldType.energy,
        icon: Icons.arrow_upward,
        isExpert: true,
        category: 'phase2',
      ),

      // Phase C Energy
      FieldTemplate(
        name: TO(key: FieldTranslationKeys.totalEnergyImport),
        path: 'c_total_act_energy',
        type: DataFieldType.energy,
        icon: Icons.arrow_downward,
        isExpert: false,
        category: 'phase3',
      ),
      FieldTemplate(
        name: TO(key: FieldTranslationKeys.totalEnergyExport),
        path: 'c_total_act_ret_energy',
        type: DataFieldType.energy,
        icon: Icons.arrow_upward,
        isExpert: true,
        category: 'phase3',
      ),

      // Total Energy
      FieldTemplate(
        name: TO(key: FieldTranslationKeys.totalEnergyImport),
        path: 'total_act',
        type: DataFieldType.energy,
        icon: Icons.energy_savings_leaf,
        isExpert: false,
        category: 'totals',
      ),
      FieldTemplate(
        name: TO(key: FieldTranslationKeys.totalEnergyExport),
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
        name: TO(key: FieldTranslationKeys.temperature),
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
        name: TO(key: FieldTranslationKeys.voltageInstance),
        needsInstanceParam: true,
        path: 'voltage',
        type: DataFieldType.voltage,
        icon: Icons.bolt,
        isExpert: false,
        category: 'instance',  // Will be converted to pm_messung_X
      ),
      FieldTemplate(
        name: TO(key: FieldTranslationKeys.currentInstance),
        needsInstanceParam: true,
        path: 'current',
        type: DataFieldType.current,
        icon: Icons.flash_on,
        isExpert: false,
        category: 'instance',
      ),
      FieldTemplate(
        name: TO(key: FieldTranslationKeys.powerInstance),
        needsInstanceParam: true,
        path: 'apower',
        type: DataFieldType.watt,
        icon: Icons.power,
        isExpert: false,
        category: 'instance',
      ),
      FieldTemplate(
        name: TO(key: FieldTranslationKeys.frequencyInstance),
        needsInstanceParam: true,
        path: 'freq',
        type: DataFieldType.frequency,
        icon: Icons.waves,
        isExpert: false,
        category: 'instance',
      ),
      FieldTemplate(
        name: TO(key: FieldTranslationKeys.totalEnergyImport),
        needsInstanceParam: true,
        path: 'aenergy.total',
        type: DataFieldType.energy,
        icon: Icons.energy_savings_leaf,
        isExpert: false,
        category: 'instance',
      ),
      FieldTemplate(
        name: TO(key: FieldTranslationKeys.totalEnergyExport),
        needsInstanceParam: true,
        path: 'ret_aenergy.total',
        type: DataFieldType.energy,
        icon: Icons.arrow_circle_up,
        isExpert: false,
        category: 'instance',
      ),
      FieldTemplate(
        name: TO(key: FieldTranslationKeys.energyPerMinuteImport),
        needsInstanceParam: true,
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
        name: TO(key: FieldTranslationKeys.energyPerMinuteExport),
        needsInstanceParam: true,
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
