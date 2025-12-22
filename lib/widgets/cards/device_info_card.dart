import 'package:flutter/material.dart';

/// A card widget for displaying device information/metadata
///
/// Shows a horizontal card with an icon and title/value pair.
/// Typically used for displaying device properties like serial number,
/// connection type, firmware version, etc.
///
/// Example usage:
/// ```dart
/// DeviceInfoCard(
///   title: 'Serial Number',
///   value: 'A8K1J2H3G4',
///   icon: Icons.tag,
/// )
/// ```
class DeviceInfoCard extends StatelessWidget {
  /// The label/title of the information field
  final String title;

  /// The value/content to display
  final String value;

  /// Icon to display on the left side
  final IconData icon;

  /// Optional custom color for the icon
  final Color? iconColor;

  const DeviceInfoCard({
    required this.title,
    required this.value,
    required this.icon,
    this.iconColor,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // Icon
            Icon(
              icon,
              size: 32,
              color: iconColor ?? Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 16),

            // Content (title + value)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Value
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
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
