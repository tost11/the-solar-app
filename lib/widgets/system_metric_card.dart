import 'package:flutter/material.dart';

/// A card widget for displaying a single system metric
///
/// Shows a metric value with icon, title, and optional secondary value.
/// Used in the System Home Screen to display aggregated system data.
///
/// Example usage:
/// ```dart
/// SystemMetricCard(
///   title: 'Solar-Produktion',
///   value: 1250.0,
///   unit: 'W',
///   icon: Icons.wb_sunny,
///   color: Colors.orange,
/// )
/// ```
class SystemMetricCard extends StatelessWidget {
  /// Title of the metric (e.g., "Solar-Produktion", "Batterie")
  final String title;

  /// Primary value to display (e.g., power in watts)
  final double? value;

  /// Unit for the primary value (e.g., "W", "kW")
  final String unit;

  /// Icon to display in the card
  final IconData icon;

  /// Color theme for the card
  final Color color;

  /// Optional secondary value (e.g., battery SOC percentage)
  final double? secondaryValue;

  /// Optional unit for the secondary value (e.g., "%")
  final String? secondaryUnit;

  const SystemMetricCard({
    super.key,
    required this.title,
    required this.value,
    required this.unit,
    required this.icon,
    required this.color,
    this.secondaryValue,
    this.secondaryUnit,
  });

  /// Formats a numeric value for display
  ///
  /// Shows 0 decimal places for values >= 10, otherwise 1 decimal place
  String _formatValue(double value) {
    if (value.abs() >= 10) {
      return value.toStringAsFixed(0);
    } else {
      return value.toStringAsFixed(1);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 32,
                color: color,
              ),
            ),
            const SizedBox(width: 16),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    title,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.textTheme.bodySmall?.color,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Primary value
                  if (value != null)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          _formatValue(value!),
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          unit,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.textTheme.bodySmall?.color,
                          ),
                        ),
                      ],
                    )
                  else
                    Text(
                      '-',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.textTheme.bodySmall?.color,
                      ),
                    ),

                  // Secondary value (e.g., battery SOC)
                  if (secondaryValue != null && secondaryUnit != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        '${_formatValue(secondaryValue!)} $secondaryUnit',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.textTheme.bodySmall?.color,
                        ),
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
