import 'package:flutter/material.dart';
import '../device_base.dart';

/// Context object passed to menu item callbacks
///
/// Contains all information needed to handle a menu item tap, including:
/// - BuildContext for navigation
/// - DeviceBase for device access
/// - Optional extra parameters (e.g., systemId from parent screen)
class DeviceMenuItemContext {
  /// BuildContext for navigation and showing dialogs
  final BuildContext context;

  /// Device instance that the menu item is operating on
  final DeviceBase device;

  /// Optional extra parameters passed from parent screen
  /// Can contain keys like:
  /// - 'systemId': String? - ID of the system the device belongs to
  final Map<String, dynamic> extraParameters;

  const DeviceMenuItemContext({
    required this.context,
    required this.device,
    this.extraParameters = const {},
  });

  /// Convenience getter for systemId from extra parameters
  String? get systemId => extraParameters['systemId'] as String?;
}
