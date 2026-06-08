import 'package:flutter/material.dart';
import '../constants/bluetooth_constants.dart';
import '../models/device_factory.dart';

/// Utility functions for Bluetooth device operations
class BluetoothDeviceUtils {
  /// Shows dialog to select device manufacturer type
  ///
  /// [detectedManufacturer] - Pre-selected manufacturer if known, null for unknown
  /// Returns selected manufacturer constant or null if cancelled
  static Future<String?> showManufacturerSelectionDialog(
    BuildContext context, {
    String? detectedManufacturer,
  }) async {
    // List of supported Bluetooth manufacturers
    final manufacturers = [
      DEVICE_MANUFACTURER_ZENDURE,
      DEVICE_MANUFACTURER_SHELLY,
    ];

    return showDialog<String>(
      context: context,
      builder: (BuildContext dialogContext) {
        String? selectedManufacturer = detectedManufacturer;

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Gerätetyp auswählen'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Info box (green for detected, orange for unknown)
                  if (detectedManufacturer == null)
                    _buildWarningInfo()
                  else
                    _buildDetectedInfo(),

                  const SizedBox(height: 12),
                  const Text('Hersteller:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),

                  // Dropdown with manufacturer icons
                  DropdownButtonFormField<String>(
                    value: selectedManufacturer,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    items: manufacturers.map<DropdownMenuItem<String>>((mfg) {
                      return DropdownMenuItem<String>(
                        value: mfg,
                        child: Row(
                          children: [
                            Icon(
                              _getManufacturerIcon(mfg),
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(_getManufacturerDisplayName(mfg)),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) =>
                        setState(() => selectedManufacturer = value),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Abbrechen'),
                ),
                ElevatedButton(
                  onPressed: selectedManufacturer != null
                      ? () =>
                          Navigator.pop(dialogContext, selectedManufacturer)
                      : null,
                  child: const Text('Bestätigen'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  static Widget _buildWarningInfo() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.orange.shade300),
      ),
      child: Row(
        children: [
          Icon(Icons.warning, size: 16, color: Colors.orange.shade700),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Hersteller nicht erkannt.',
              style: TextStyle(fontSize: 12, color: Colors.orange.shade900),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildDetectedInfo() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.green.shade300),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle, size: 16, color: Colors.green.shade700),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Hersteller erkannt. Sie können diesen ändern.',
              style: TextStyle(fontSize: 12, color: Colors.green.shade900),
            ),
          ),
        ],
      ),
    );
  }

  static String _getManufacturerDisplayName(String manufacturer) {
    switch (manufacturer) {
      case DEVICE_MANUFACTURER_ZENDURE:
        return 'Zendure';
      case DEVICE_MANUFACTURER_SHELLY:
        return 'Shelly';
      default:
        return manufacturer;
    }
  }

  static IconData _getManufacturerIcon(String manufacturer) {
    // Reuse existing device icons from DeviceFactory
    return DeviceFactory.getDefaultIconByManufacturer(manufacturer);
  }
}
