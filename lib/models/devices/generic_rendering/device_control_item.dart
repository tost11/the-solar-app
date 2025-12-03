import 'package:flutter/material.dart';
import '../device_base.dart';

/// Enum defining different types of control widgets
enum ControlType {
  switchToggle,  // On/Off switch
  textField,     // Text input field
  slider,        // Slider for numeric values
  button,        // Action button
}

/// Generic control item definition for device controls
///
/// This class defines an interactive control widget that allows users to
/// modify device settings or trigger actions directly from the device detail screen.
class DeviceControlItem {
  /// Display name shown to the user (left side)
  final String name;

  /// Type of control widget to display (right side)
  final ControlType type;

  /// Optional icon to display with this control
  final IconData? icon;

  /// Function to extract the current value from device data
  /// Returns the current state/value to display in the control
  final Object? Function(Map<String, dynamic> data) valueExtractor;

  /// Callback function when control value changes
  /// Receives BuildContext, DeviceBase, and the new value
  /// Should typically call device.sendCommand() to update the device
  final Future<void> Function(BuildContext context, DeviceBase device, dynamic newValue) onChanged;

  /// Optional minimum value for slider type
  final double? min;

  /// Optional maximum value for slider type
  final double? max;

  /// Optional divisions for slider type
  final int? divisions;

  const DeviceControlItem({
    required this.name,
    required this.type,
    this.icon,
    required this.valueExtractor,
    required this.onChanged,
    this.min,
    this.max,
    this.divisions,
  });
}
