import 'package:flutter/material.dart';
import '../device_base.dart';

/// Generic menu item definition for device actions
///
/// This class defines a menu entry in the device's "More Functions" menu,
/// including its name, icon, and action to perform when tapped.
class DeviceMenuItem {
  /// Display name shown to the user
  final String name;

  /// Optional subtitle/description
  final String? subtitle;

  /// Icon to display with this menu item
  final IconData icon;

  /// Color for the icon (optional)
  final Color? iconColor;

  /// Callback function when menu item is tapped
  /// Receives BuildContext for navigation and DeviceBase for device access
  final void Function(BuildContext context, DeviceBase device) onTap;

  /// Optional callback to determine if this menu item should be disabled
  /// Receives DeviceBase and returns true if the item should be disabled
  final bool Function(DeviceBase device)? disabled;

  const DeviceMenuItem({
    required this.name,
    this.subtitle,
    required this.icon,
    this.iconColor,
    required this.onTap,
    this.disabled,
  });
}
