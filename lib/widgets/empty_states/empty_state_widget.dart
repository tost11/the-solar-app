import 'package:flutter/material.dart';

/// A widget for displaying empty states with icon, message, and optional action
///
/// Shows a centered empty state with a large icon, title, message, and optional
/// action button. Used throughout the app for empty lists, no data scenarios, etc.
///
/// Example usage:
/// ```dart
/// EmptyStateWidget(
///   icon: Icons.solar_power_outlined,
///   title: 'Keine Geräte',
///   message: 'Fügen Sie Ihr erstes Gerät hinzu',
///   actionLabel: 'Gerät hinzufügen',
///   onActionPressed: () => navigateToAddDevice(),
/// )
/// ```
class EmptyStateWidget extends StatelessWidget {
  /// The icon to display (typically a large Material icon)
  final IconData icon;

  /// The main title/heading for the empty state
  final String title;

  /// The descriptive message explaining the empty state
  final String message;

  /// Optional label for the action button
  final String? actionLabel;

  /// Optional callback when the action button is pressed
  final VoidCallback? onActionPressed;

  /// Optional custom icon size (default: 80)
  final double iconSize;

  const EmptyStateWidget({
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onActionPressed,
    this.iconSize = 80.0,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon
          Icon(
            icon,
            size: iconSize,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),

          // Title
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              color: Colors.grey[600],
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),

          // Message
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),

          // Optional action button
          if (actionLabel != null && onActionPressed != null) ...[
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: onActionPressed,
              icon: const Icon(Icons.add),
              label: Text(actionLabel!),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
