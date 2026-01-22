import 'package:flutter/material.dart';
import '../../models/device.dart';
import '../../utils/time_format_utils.dart';

/// A list item widget for displaying a device in a list
///
/// Shows device name, serial number, connection type, and last seen time.
/// Includes a delete button and tap handler for navigation.
///
/// Example usage:
/// ```dart
/// DeviceListItem(
///   device: device,
///   onTap: () => navigateToDeviceDetail(device),
///   onDelete: () => deleteDevice(device),
/// )
/// ```
class DeviceListItem extends StatelessWidget {
  /// The device to display
  final Device device;

  /// Callback when the list item is tapped
  final VoidCallback onTap;

  /// Callback when the delete button is pressed
  final VoidCallback onDelete;

  /// Callback when the connect button is pressed
  final VoidCallback onConnect;

  /// Callback when the disconnect button is pressed
  final VoidCallback onDisconnect;

  /// Whether the device is currently connected
  final bool isConnected;

  /// Whether the device is auto-reconnecting
  final bool isAutoReconnecting;

  const DeviceListItem({
    required this.device,
    required this.onTap,
    required this.onDelete,
    required this.onConnect,
    required this.onDisconnect,
    required this.isConnected,
    required this.isAutoReconnecting,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Use compact layout if width is less than 320px
          if (constraints.maxWidth < 320) {
            return _buildCompactLayout(context);
          } else {
            return _buildStandardLayout(context);
          }
        },
      ),
    );
  }

  /// Standard layout for wider spaces (ListTile with leading/trailing)
  Widget _buildStandardLayout(BuildContext context) {
    return ListTile(
      // Device icon
      leading: CircleAvatar(
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        child: Icon(
          device.deviceIcon,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),

      // Device name
      title: Text(
        device.name.isEmpty ? 'Zendure Gerät' : device.name,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),

      // Device details (serial number, connection type, last seen)
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Serial number (if available)
          if (device.deviceSn != null) Text('SN: ${device.deviceSn}'),

          // Connection type and last seen
          Row(
            children: [
              // Connection type icon
              Icon(
                device.connectionType == ConnectionType.bluetooth
                    ? Icons.bluetooth
                    : Icons.wifi,
                size: 14,
                color: Colors.grey[600],
              ),
              const SizedBox(width: 4),

              // Connection type label
              Text(
                device.connectionType.displayName,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(width: 8),

              // Last seen timestamp
              Text(
                '• ${TimeFormatUtils.formatLastSeen(device.lastSeen)}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),

      // Connect/Disconnect and Delete buttons
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Connect/Disconnect button
          Container(
            decoration: BoxDecoration(
              color: isConnected
                  ? Colors.green.withOpacity(0.2)  // Green background when connected
                  : (isAutoReconnecting
                      ? Colors.orange.withOpacity(0.2)  // Orange background when auto-reconnecting
                      : null),  // No background when disconnected
              borderRadius: BorderRadius.circular(8),
            ),
            child: IconButton(
              icon: Icon(
                isConnected
                    ? (device.connectionType == ConnectionType.bluetooth
                        ? Icons.bluetooth_connected
                        : Icons.wifi)
                    : (device.connectionType == ConnectionType.bluetooth
                        ? Icons.bluetooth_disabled
                        : Icons.wifi_off),
              ),
              color: isConnected
                  ? Colors.green.shade700  // Dark green icon when connected
                  : (isAutoReconnecting
                      ? Colors.orange.shade700  // Dark orange icon when reconnecting
                      : Colors.grey),  // Grey icon when disconnected
              onPressed: (isConnected || isAutoReconnecting) ? onDisconnect : onConnect,
              tooltip: isConnected
                  ? 'Trennen'
                  : (isAutoReconnecting ? 'Auto-Verbindung aktiv - Tippen zum Stoppen' : 'Verbinden'),
            ),
          ),
          // Delete button
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: onDelete,
          ),
        ],
      ),

      // Navigate to device detail on tap
      onTap: onTap,
    );
  }

  /// Compact layout for narrow spaces (stacked vertically)
  Widget _buildCompactLayout(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top row: icon, connect/disconnect button, and delete button
            Row(
              children: [
                // Device icon
                Icon(
                  device.deviceIcon,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
                const Spacer(),
                // Connect/Disconnect button
                Container(
                  decoration: BoxDecoration(
                    color: isConnected
                        ? Colors.green.withOpacity(0.2)  // Green background when connected
                        : (isAutoReconnecting
                            ? Colors.orange.withOpacity(0.2)  // Orange background when auto-reconnecting
                            : null),  // No background when disconnected
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: IconButton(
                    icon: Icon(
                      isConnected
                          ? (device.connectionType == ConnectionType.bluetooth
                              ? Icons.bluetooth_connected
                              : Icons.wifi)
                          : (device.connectionType == ConnectionType.bluetooth
                              ? Icons.bluetooth_disabled
                              : Icons.wifi_off),
                      size: 20,
                    ),
                    color: isConnected
                        ? Colors.green.shade700  // Dark green icon when connected
                        : (isAutoReconnecting
                            ? Colors.orange.shade700  // Dark orange icon when reconnecting
                            : Colors.grey),  // Grey icon when disconnected
                    onPressed: (isConnected || isAutoReconnecting) ? onDisconnect : onConnect,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    tooltip: isConnected
                        ? 'Trennen'
                        : (isAutoReconnecting ? 'Auto-Verbindung aktiv' : 'Verbinden'),
                  ),
                ),
                const SizedBox(width: 4),
                // Delete button (smaller)
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 20),
                  onPressed: onDelete,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 4),

            // Device name (full width)
            Text(
              device.name.isEmpty ? 'Zendure Gerät' : device.name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            // Serial number (if available)
            if (device.deviceSn != null) ...[
              const SizedBox(height: 2),
              Text(
                'SN: ${device.deviceSn}',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[600],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],

            const SizedBox(height: 4),

            // Connection type and last seen (stacked on separate lines if needed)
            Row(
              children: [
                // Connection type icon
                Icon(
                  device.connectionType == ConnectionType.bluetooth
                      ? Icons.bluetooth
                      : Icons.wifi,
                  size: 12,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 4),

                // Connection type label
                Expanded(
                  child: Text(
                    device.connectionType.displayName,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[600],
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),

            // Last seen on separate line
            Text(
              TimeFormatUtils.formatLastSeen(device.lastSeen),
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
