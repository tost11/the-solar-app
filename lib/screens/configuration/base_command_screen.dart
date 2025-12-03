import 'package:flutter/material.dart';
import '../../models/device.dart';

/// Abstract base class for configuration screens that send commands to devices
///
/// Provides common functionality for merging additional parameters with command params
///
/// Usage:
/// - Extend this class instead of StatefulWidget
/// - Pass device and optional additionalParams to super constructor
/// - Use sendCommandToDevice() instead of device.sendCommand() directly
abstract class BaseCommandScreen extends StatefulWidget {
  /// The device to send commands to
  final DeviceBase device;

  /// Additional parameters to merge with all command calls
  /// These will be automatically added to every sendCommandToDevice() call
  final Map<String, dynamic> additionalParams;

  const BaseCommandScreen({
    super.key,
    required this.device,
    this.additionalParams = const {},
  });

  /// Helper method to send command to device with merged parameters
  ///
  /// Merges additionalParams with provided params before sending command to device.
  /// The additionalParams will override any matching keys in params.
  ///
  /// Parameters:
  /// - command: The command constant to send
  /// - params: Command-specific parameters
  ///
  /// Returns: Response from device.sendCommand()
  Future<Map<String, dynamic>?> sendCommandToDevice(
    String command,
    Map<String, dynamic> params,
  ) async {
    // Create merged params map
    final mergedParams = Map<String, dynamic>.from(params);

    // Add all additional params (overrides matching keys)
    mergedParams.addAll(additionalParams);

    // Send command with merged params
    return await device.sendCommand(command, mergedParams);
  }
}
