import 'package:flutter/material.dart';

/// Configuration for Bluetooth scanning
class BluetoothScanConfiguration {
  final bool showAllDevices;

  BluetoothScanConfiguration({required this.showAllDevices});

  factory BluetoothScanConfiguration.defaults() {
    return BluetoothScanConfiguration(showAllDevices: false);
  }
}

/// Advanced options widget for Bluetooth scanning
///
/// Provides UI controls for:
/// - Show all devices toggle (filtered vs unfiltered scanning)
class BluetoothAdvancedOptionsWidget extends StatefulWidget {
  const BluetoothAdvancedOptionsWidget({super.key});

  @override
  State<BluetoothAdvancedOptionsWidget> createState() =>
      BluetoothAdvancedOptionsWidgetState();
}

class BluetoothAdvancedOptionsWidgetState
    extends State<BluetoothAdvancedOptionsWidget> {
  bool _isExpanded = false;
  bool _showAllDevices = false; // Default: filtered (backward compatible)

  /// Public method for parent screen to read configuration
  BluetoothScanConfiguration getCurrentConfiguration() {
    return BluetoothScanConfiguration(showAllDevices: _showAllDevices);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Expand/collapse button
        SizedBox(
          height: 40,
          child: TextButton.icon(
            onPressed: () => setState(() => _isExpanded = !_isExpanded),
            icon: Icon(_isExpanded
                ? Icons.keyboard_arrow_up
                : Icons.keyboard_arrow_down),
            label: const Text('Erweiterte Optionen'),
          ),
        ),

        // Expandable content
        AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: _isExpanded
              ? _buildAdvancedOptionsContent()
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildAdvancedOptionsContent() {
    return Material(
      color: Colors.white,
      elevation: 2,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // "Show All Devices" checkbox
            _buildShowAllDevicesCheckbox(),
          ],
        ),
      ),
    );
  }

  Widget _buildShowAllDevicesCheckbox() {
    return Row(
      children: [
        Checkbox(
          value: _showAllDevices,
          onChanged: (value) =>
              setState(() => _showAllDevices = value ?? false),
        ),
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _showAllDevices = !_showAllDevices),
            child: const Text('Alle Geräte anzeigen'),
          ),
        ),
        Tooltip(
          message:
              'Zeigt alle BLE-Geräte, nicht nur bekannte Hersteller (Zendure, Shelly)',
          child: Icon(Icons.info_outline, size: 16, color: Colors.grey[600]),
        ),
      ],
    );
  }
}
