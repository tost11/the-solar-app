import 'package:flutter/material.dart';
import '../device_base.dart';
import 'device_menu_item_context.dart';
import '../../to.dart';

/// Generic menu item definition for device actions
///
/// This class defines a menu entry in the device's "More Functions" menu,
/// including its name, icon, and action to perform when tapped.
class DeviceMenuItem {
  /// Display name shown to the user (Translation Object)
  final TO name;

  /// Optional subtitle/description (Translation Object)
  final TO? subtitle;

  /// Icon to display with this menu item
  final IconData icon;

  /// Color for the icon (optional)
  final Color? iconColor;

  /// Callback function when menu item is tapped
  /// Receives DeviceMenuItemContext containing context, device, and extra parameters
  final void Function(DeviceMenuItemContext context) onTap;

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

  /// Get localized name
  String getName(BuildContext context) => name.getText(context);

  /// Get localized subtitle
  String? getSubtitle(BuildContext context) => subtitle?.getText(context);
}
