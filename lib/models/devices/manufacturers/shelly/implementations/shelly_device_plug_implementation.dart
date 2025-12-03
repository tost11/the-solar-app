import 'package:flutter/material.dart';
import '../../../generic_rendering/device_control_item.dart';
import '../../../generic_rendering/device_data_field.dart';
import 'shelly_device_base_implementation.dart';
import 'package:the_solar_app/constants/command_constants.dart';
import 'package:the_solar_app/services/devices/shelly/shelly_service.dart';
import 'package:the_solar_app/utils/dialog_utils.dart';
import 'package:the_solar_app/utils/map_utils.dart';

/// Shelly Pro 3EM device supporting both Bluetooth and WiFi/Network connections
///
/// Supports 3-phase energy monitoring with voltage, current, and power measurements
/// for each phase plus total power consumption.
///
/// Model: SPEM-003CEBEU (Shelly Pro 3EM)
class ShellyDevicePlugImplementation extends ShellyDeviceBaseImplementation {
  
  @override
  List<DeviceDataField> getDataFields() {
    return [
      // Output state
      DeviceDataField(
        name: 'Status',
        type: DataFieldType.none,
        valueExtractor: (data) {
          final output = MapUtils.OM(data, ['data', 'output']);
          if (output is bool) {
            return output ? 'Ein' : 'Aus';
          }
          return output;
        },
        icon: Icons.power_settings_new,
        expertMode: false,
      ),

      // Active power
      DeviceDataField(
        name: 'Leistung',
        type: DataFieldType.watt,
        valueExtractor: (data) => MapUtils.OM(data, ['data', 'apower']),
        icon: Icons.power,
        expertMode: false,
      ),

      // Voltage
      DeviceDataField(
        name: 'Spannung',
        type: DataFieldType.voltage,
        valueExtractor: (data) => MapUtils.OM(data, ['data', 'voltage']),
        icon: Icons.electric_bolt,
        expertMode: false,
      ),

      // Current
      DeviceDataField(
        name: 'Strom',
        type: DataFieldType.current,
        valueExtractor: (data) => MapUtils.OM(data, ['data', 'current']),
        icon: Icons.flash_on,
        expertMode: true,
      ),

      // Temperature
      DeviceDataField(
        name: 'Temperatur',
        type: DataFieldType.temperature,
        valueExtractor: (data) =>
            MapUtils.OM(data, ['data', 'temperature', 'tC']),
        icon: Icons.thermostat,
        expertMode: false,
      ),

      // Total energy
      DeviceDataField(
        name: 'Gesamt Energie',
        type: DataFieldType.watt,
        valueExtractor: (data) =>
            MapUtils.OM(data, ['data', 'aenergy', 'total']),
        icon: Icons.bar_chart,
        expertMode: true,
      ),
    ];
  }

  @override
  List<DeviceControlItem> getControlItems() {
    return [
      // Switch control
      DeviceControlItem(
        name: 'Steckdose',
        type: ControlType.switchToggle,
        icon: Icons.power,
        valueExtractor: (data) {
          final output = MapUtils.OM(data, ['data', 'output']);
          return output is bool ? output : false;
        },
        onChanged: (context, device, newValue) async {
          await DialogUtils.executeWithLoading(
            context,
            loadingMessage: 'Schalte Steckdose ${newValue ? 'ein' : 'aus'}...',
            operation: () async {
              await device.sendCommand(COMMAND_SET_MAIN_POWER, {
                "on": newValue,
              });

              // Update local data after successful toggle
              if (device.data.containsKey('data')) {
                device.data['data']!['output'] = newValue;
                device.emitData(device.data['data']!);
              }
            },
            showErrorDialog: true,
          );
        },
      ),
    ];
  }

  @override
  Future<Map<String,dynamic>?> sendCommand(dynamic connectionService, String command, Map<String, dynamic> params) async {
    final service = connectionService as ShellyService?;
    if(command == COMMAND_SET_MAIN_POWER) {
      bool? on = params["on"];
      if(on == null){
        throw Exception("could not set main power: id or on parameter is missing");
      }
      return await service?.sendCommand('Switch.Set', {"id": 0, "on": on});
    }
    return super.sendCommand(connectionService,command,params);
  }

  @override
  String getFetchCommand() {
    return  "Switch.GetStatus";
  }
  
  @override
  IconData getDeviceIcon() {
    return Icons.power;
  }
}
