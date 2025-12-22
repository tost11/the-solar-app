import 'package:flutter/material.dart';
import '../models/device.dart';
import '../models/devices/generic_rendering/device_menu_item_context.dart';

/// Reusable bottom sheet widget that displays device menu items
///
/// Shows a modal bottom sheet with all menu items from device.menuItems.
/// Each menu item is displayed as a ListTile with icon, name, subtitle, and
/// handles disabled state.
class DeviceMenuBottomSheet extends StatelessWidget {
  final Device device;
  final Map<String, dynamic> extraParameters;
  final BuildContext screenContext;

  const DeviceMenuBottomSheet({
    super.key,
    required this.device,
    required this.screenContext,
    this.extraParameters = const {},
  });

  /// Show the device menu bottom sheet
  ///
  /// [context] - The BuildContext to show the modal from
  /// [device] - The device whose menu items to display
  /// [screenContext] - The parent screen's context for navigation after closing
  /// [extraParameters] - Optional parameters (e.g., systemId) passed to menu item callbacks
  static Future<void> show({
    required BuildContext context,
    required Device device,
    Map<String, dynamic> extraParameters = const {},
  }) {
    return showModalBottomSheet(
      context: context,
      builder: (BuildContext bottomSheetContext) => DeviceMenuBottomSheet(
        device: device,
        screenContext: context, // Use the parent context for navigation
        extraParameters: extraParameters,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'Weitere Funktionen',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          const Divider(),

          // Menu items in scrollable area
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Dynamically build menu items from device configuration
                  ...device.menuItems.map((menuItem) {
                    final isDisabled = menuItem.disabled?.call(device) ?? false;
                    return ListTile(
                      leading: Icon(
                        menuItem.icon,
                        color: menuItem.iconColor,
                      ),
                      title: Text(menuItem.name),
                      subtitle: menuItem.subtitle != null ? Text(menuItem.subtitle!) : null,
                      enabled: !isDisabled,
                      onTap: isDisabled
                          ? null
                          : () {
                              Navigator.pop(context); // Close bottom sheet
                              menuItem.onTap(
                                DeviceMenuItemContext(
                                  context: screenContext, // Use parent screen context
                                  device: device,
                                  extraParameters: extraParameters,
                                ),
                              );
                            },
                    );
                  }),

                  // Bottom padding for safe area
                  SizedBox(height: MediaQuery.of(context).padding.bottom),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
