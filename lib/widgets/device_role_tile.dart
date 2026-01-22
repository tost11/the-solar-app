import 'package:flutter/material.dart';
import 'package:the_solar_app/models/devices/capabilities/device_role_config.dart';
import 'package:the_solar_app/models/devices/device_base.dart';
import 'package:the_solar_app/services/device_storage_service.dart';
import 'package:the_solar_app/utils/localization_extension.dart';
import 'package:the_solar_app/utils/message_utils.dart';

/// A list tile widget for displaying a device with its roles
///
/// Shows the device name, icon, and active roles. If the device has
/// configurable roles, displays a settings button to let the user
/// choose which role the device should play in the system.
///
/// Example usage:
/// ```dart
/// DeviceRoleTile(device: shellyPlug)
/// ```
class DeviceRoleTile extends StatefulWidget {
  /// The device to display
  final DeviceBase device;

  const DeviceRoleTile({
    super.key,
    required this.device,
  });

  @override
  State<DeviceRoleTile> createState() => _DeviceRoleTileState();
}

class _DeviceRoleTileState extends State<DeviceRoleTile> {
  /// Formats a list of roles into a comma-separated German string
  String _formatRoles(List<DeviceRole> roles) {
    if (roles.isEmpty) return 'Keine Rolle';

    return roles.map((r) => r.displayName).join(', ');
  }

  /// Shows a dialog for selecting the device's configurable role
  Future<void> _showRoleSelector(BuildContext context) async {
    if (widget.device is! DeviceRoleConfig) return;

    final deviceWithRole = widget.device as DeviceRoleConfig;
    final configurableRoles = deviceWithRole.getConfigurableRoles();

    if (configurableRoles.isEmpty) return;

    final selectedRole = await showDialog<DeviceRole?>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Geräte-Rolle wählen'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Wählen Sie die Rolle für "${widget.device.name}":',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            ...configurableRoles.map((role) {
              final isSelected = deviceWithRole.userConfiguredRole == role;
              return RadioListTile<DeviceRole>(
                title: Text(role.displayName),
                value: role,
                groupValue: deviceWithRole.userConfiguredRole,
                selected: isSelected,
                onChanged: (value) {
                  Navigator.pop(context, value);
                },
              );
            }),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Abbrechen'),
          ),
        ],
      ),
    );

    if (selectedRole != null && context.mounted) {
      // Update the device's role
      deviceWithRole.userConfiguredRole = selectedRole;

      // Save the device
      try {
        await DeviceStorageService().saveDevice(widget.device);
        setState(() {}); // Refresh UI

        if (context.mounted) {
          MessageUtils.showSuccess(
            context,
            'Rolle erfolgreich auf "${selectedRole.displayName}" gesetzt',
          );
        }
      } catch (e) {
        if (context.mounted) {
          MessageUtils.showError(
            context,
            'Fehler beim Speichern: $e',
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (widget.device is! DeviceRoleConfig) {
      // Device doesn't have role config, show basic tile
      return ListTile(
        leading: Icon(widget.device.deviceIcon),
        title: Text(widget.device.name),
        subtitle: Text(context.l10n.noRoleSupport),
      );
    }

    final deviceWithRole = widget.device as DeviceRoleConfig;
    final roles = deviceWithRole.activeRoles;
    final hasConfigurableRoles = deviceWithRole.hasConfigurableRoles;

    return ListTile(
      leading: Icon(widget.device.deviceIcon),
      title: Text(widget.device.name),
      subtitle: Row(
        children: [
          Icon(
            Icons.label,
            size: 14,
            color: theme.textTheme.bodySmall?.color,
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              _formatRoles(roles),
              style: theme.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
      trailing: hasConfigurableRoles
          ? IconButton(
              icon: const Icon(Icons.settings),
              tooltip: 'Rolle konfigurieren',
              onPressed: () => _showRoleSelector(context),
            )
          : null,
    );
  }
}
