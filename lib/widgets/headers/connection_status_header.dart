import 'package:flutter/material.dart';
import '../../models/device.dart';

/// A header widget displaying device connection status
///
/// Shows a card with connection status icon, device name, and status text.
/// The icon and colors adapt based on connection type (WiFi/Bluetooth) and state.
///
/// Example usage:
/// ```dart
/// ConnectionStatusHeader(
///   deviceName: 'Zendure Solarflow Hub',
///   connectionStatus: 'Verbunden',
///   connectionType: ConnectionType.wifi,
///   isConnected: true,
/// )
/// ```
class ConnectionStatusHeader extends StatelessWidget {
  /// The display name of the device
  final String deviceName;

  /// The connection status text (e.g., "Verbunden", "Nicht verbunden")
  final String connectionStatus;

  /// The type of connection (WiFi or Bluetooth)
  final ConnectionType connectionType;

  /// Whether the device is currently connected
  final bool isConnected;

  const ConnectionStatusHeader({
    required this.deviceName,
    required this.connectionStatus,
    required this.connectionType,
    required this.isConnected,
    super.key,
  });

  /// Get the appropriate icon based on connection type and state
  IconData _getIcon() {
    if (connectionType == ConnectionType.wifi) {
      return isConnected ? Icons.wifi : Icons.wifi_off;
    } else {
      return isConnected ? Icons.bluetooth_connected : Icons.bluetooth_disabled;
    }
  }

  /// Get the color based on connection state
  Color _getIconColor() {
    return isConnected ? Colors.green : Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // Status Icon
            Icon(
              _getIcon(),
              size: 40,
              color: _getIconColor(),
            ),
            const SizedBox(width: 16),

            // Device Info (name + status)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Device name
                  Text(
                    deviceName.isEmpty ? 'Gerät' : deviceName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Connection status
                  Text(
                    connectionStatus,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
