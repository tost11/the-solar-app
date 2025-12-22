import 'package:flutter/material.dart';
import '../../models/device.dart';
import '../../models/devices/generic_rendering/device_control_item.dart';
import '../../utils/message_utils.dart';

/// A widget that renders device control items based on their type
///
/// Supports multiple control types: switch toggle, text field, slider, and button.
/// Handles error states and displays appropriate error messages.
///
/// Example usage:
/// ```dart
/// DeviceControlWidget(
///   controlItem: DeviceControlItem(
///     name: 'Power Limit',
///     type: ControlType.slider,
///     min: 0,
///     max: 100,
///     ...
///   ),
///   device: device,
///   currentValue: 50,
///   isEnabled: true,
/// )
/// ```
class DeviceControlWidget extends StatelessWidget {
  /// The control item definition containing type, name, and callbacks
  final DeviceControlItem controlItem;

  /// The device this control is for
  final Device device;

  /// The current value to display in the control
  final dynamic currentValue;

  /// Whether the control is enabled (disabled when value is null)
  final bool isEnabled;

  const DeviceControlWidget({
    required this.controlItem,
    required this.device,
    required this.currentValue,
    required this.isEnabled,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    switch (controlItem.type) {
      case ControlType.switchToggle:
        return _buildSwitch(context);

      case ControlType.textField:
        return _buildTextField(context);

      case ControlType.slider:
        return _buildSlider(context);

      case ControlType.button:
        return _buildButton(context);

      default:
        return const SizedBox.shrink();
    }
  }

  /// Build a switch toggle control
  Widget _buildSwitch(BuildContext context) {
    return Switch(
      value: currentValue is bool ? currentValue : false,
      onChanged: isEnabled
          ? (newValue) async {
              try {
                await controlItem.onChanged(context, device, newValue);
              } catch (e) {
                MessageUtils.showError(context, 'Fehler beim Umschalten: $e');
              }
            }
          : null,
    );
  }

  /// Build a text field control
  Widget _buildTextField(BuildContext context) {
    return SizedBox(
      width: 150,
      child: TextField(
        controller: TextEditingController(text: currentValue?.toString() ?? ''),
        enabled: isEnabled,
        textAlign: TextAlign.right,
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        ),
        onSubmitted: (newValue) async {
          try {
            await controlItem.onChanged(context, device, newValue);
          } catch (e) {
            MessageUtils.showError(context, 'Fehler beim Speichern: $e');
          }
        },
      ),
    );
  }

  /// Build a slider control
  Widget _buildSlider(BuildContext context) {
    return SizedBox(
      width: 150,
      child: Slider(
        value: (currentValue is num ? currentValue.toDouble() : 0.0)
            .clamp(controlItem.min ?? 0.0, controlItem.max ?? 100.0),
        min: controlItem.min ?? 0.0,
        max: controlItem.max ?? 100.0,
        divisions: controlItem.divisions,
        onChanged: isEnabled
            ? (newValue) async {
                try {
                  await controlItem.onChanged(context, device, newValue);
                } catch (e) {
                  MessageUtils.showError(context, 'Fehler beim Anpassen: $e');
                }
              }
            : null,
      ),
    );
  }

  /// Build a button control
  Widget _buildButton(BuildContext context) {
    return ElevatedButton(
      onPressed: isEnabled
          ? () async {
              try {
                await controlItem.onChanged(context, device, null);
              } catch (e) {
                MessageUtils.showError(context, 'Fehler beim Ausführen: $e');
              }
            }
          : null,
      child: const Text('Ausführen'),
    );
  }
}
