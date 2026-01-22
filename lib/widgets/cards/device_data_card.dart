import 'package:flutter/material.dart';

/// A card widget for displaying a single device data field
///
/// Shows a data field with title, value, unit, optional icon, and optional detail button.
/// Used throughout the app for displaying device metrics in a consistent format.
///
/// Example usage:
/// ```dart
/// DeviceDataCard(
///   title: 'Solar Power',
///   value: '450',
///   unit: 'W',
///   icon: Icons.wb_sunny,
///   showDetailButton: true,
///   onDetailTap: () => showDialog(...),
/// )
/// ```
class DeviceDataCard extends StatelessWidget {
  /// The label/name of the data field (e.g., "Solar Power", "Battery Level")
  final String title;

  /// The formatted value to display (e.g., "450", "85.2")
  final String value;

  /// The unit of measurement (e.g., "W", "%", "°C")
  final String unit;

  /// Optional icon to display next to the title
  final IconData? icon;

  /// Whether to show the detail/visibility button
  final bool showDetailButton;

  /// Callback when the detail button is tapped
  final VoidCallback? onDetailTap;

  const DeviceDataCard({
    required this.title,
    required this.value,
    required this.unit,
    this.icon,
    this.showDetailButton = false,
    this.onDetailTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title row with optional icon and detail button
            Row(
              children: [
                // Optional icon
                if (icon != null) ...[
                  Icon(
                    icon,
                    size: 16,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 6),
                ],

                // Title text
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                // Optional detail button
                if (showDetailButton) ...[
                  const SizedBox(width: 2),
                  InkWell(
                    onTap: onDetailTap,
                    borderRadius: BorderRadius.circular(10),
                    child: Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: Icon(
                        Icons.visibility,
                        size: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                ],
              ],
            ),

            const SizedBox(height: 8),

            // Value row with unit
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Value text
                Expanded(
                  child: Text(
                    value,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                // Unit text
                if (unit.isNotEmpty) ...[
                  const SizedBox(width: 4),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4.0),
                    child: Text(
                      unit,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
