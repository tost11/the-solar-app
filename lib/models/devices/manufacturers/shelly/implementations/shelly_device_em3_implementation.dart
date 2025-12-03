import 'package:flutter/material.dart';
import 'package:the_solar_app/models/devices/manufacturers/shelly/implementations/shelly_device_base_implementation.dart';
import 'package:the_solar_app/utils/map_utils.dart';

import '../../../generic_rendering/device_data_field.dart';

/// Shelly Pro 3EM device supporting both Bluetooth and WiFi/Network connections
///
/// Supports 3-phase energy monitoring with voltage, current, and power measurements
/// for each phase plus total power consumption.
///
/// Model: SPEM-003CEBEU (Shelly Pro 3EM)
class ShellyDeviceEm3Implementation extends ShellyDeviceBaseImplementation {

  @override
  List<DeviceDataField> getDataFields() {
    return [
      // Phase 1 data
      DeviceDataField(
        name: 'Phase 1 Spannung',
        type: DataFieldType.voltage,
        valueExtractor: (data) => MapUtils.OM(data, ['data', 'a_voltage']),
        icon: Icons.electric_bolt,
        expertMode: false,
      ),
      DeviceDataField(
        name: 'Phase 1 Strom',
        type: DataFieldType.current,
        valueExtractor: (data) => MapUtils.OM(data, ['data', 'a_current']),
        icon: Icons.flash_on,
        expertMode: true,
      ),
      DeviceDataField(
        name: 'Phase 1 Leistung',
        type: DataFieldType.watt,
        valueExtractor: (data) => MapUtils.OM(data, ['data', 'a_act_power']),
        icon: Icons.power,
        expertMode: false,
      ),

      // Phase 2 data
      DeviceDataField(
        name: 'Phase 2 Spannung',
        type: DataFieldType.voltage,
        valueExtractor: (data) => MapUtils.OM(data, ['data', 'b_voltage']),
        icon: Icons.electric_bolt,
        expertMode: false,
      ),
      DeviceDataField(
        name: 'Phase 2 Strom',
        type: DataFieldType.current,
        valueExtractor: (data) => MapUtils.OM(data, ['data', 'b_current']),
        icon: Icons.flash_on,
        expertMode: true,
      ),
      DeviceDataField(
        name: 'Phase 2 Leistung',
        type: DataFieldType.watt,
        valueExtractor: (data) => MapUtils.OM(data, ['data', 'b_act_power']),
        icon: Icons.power,
        expertMode: false,
      ),

      // Phase 3 data
      DeviceDataField(
        name: 'Phase 3 Spannung',
        type: DataFieldType.voltage,
        valueExtractor: (data) => MapUtils.OM(data, ['data', 'c_voltage']),
        icon: Icons.electric_bolt,
        expertMode: false,
      ),
      DeviceDataField(
        name: 'Phase 3 Strom',
        type: DataFieldType.current,
        valueExtractor: (data) => MapUtils.OM(data, ['data', 'c_current']),
        icon: Icons.flash_on,
        expertMode: true,
      ),
      DeviceDataField(
        name: 'Phase 3 Leistung',
        type: DataFieldType.watt,
        valueExtractor: (data) => MapUtils.OM(data, ['data', 'c_act_power']),
        icon: Icons.power,
        expertMode: false,
      ),

      // Total data
      DeviceDataField(
        name: 'Gesamt Leistung',
        type: DataFieldType.watt,
        valueExtractor: (data) =>
            MapUtils.OM(data, ['data', 'total_act_power']),
        icon: Icons.power_settings_new,
        expertMode: false,
      ),
    ];
  }

  @override
  String getFetchCommand(){
    return "EM.GetStatus";
  }

  @override
  IconData getDeviceIcon(){
    return Icons.electric_meter;
  }
}
