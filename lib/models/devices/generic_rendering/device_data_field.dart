import 'package:flutter/material.dart';

/// Enum defining different types of data fields with their units
enum DataFieldType {
  watt,        // Power in Watts (W)
  percentage,  // Percentage (%)
  voltage,     // Voltage (V)
  current,     // Current (A)
  temperature, // Temperature (°C)
  time,        // Time duration (minutes/hours)
  none,        // empty
}

/// Generic data field definition for device properties
///
/// This class defines how a specific property should be displayed,
/// including its name, type, data extraction logic, and formatting.
class DeviceDataField {
  /// Display name shown to the user
  final String name;

  /// Type of data field (determines unit and formatting)
  final DataFieldType type;

  /// Function to extract and optionally transform the value from raw data
  final Object ? Function(Map<String, dynamic> data) valueExtractor;

  /// Optional icon to display with this field
  final IconData? icon;

  /// Whether this field should only be shown in expert mode
  final bool expertMode;

  /// Whether to show an eye icon button for viewing full details
  final bool showDetailButton;

  /// Category for grouping related fields together (null = uncategorized)
  final String? category;

  const DeviceDataField({
    required this.name,
    required this.type,
    required this.valueExtractor,
    this.icon,
    this.expertMode = false,
    this.showDetailButton = false,
    this.category,
  });

  /// Get the unit string based on the field type
  String get unit {
    switch (type) {
      case DataFieldType.watt:
        return 'W';
      case DataFieldType.percentage:
        return '%';
      case DataFieldType.voltage:
        return 'V';
      case DataFieldType.current:
        return 'A';
      case DataFieldType.temperature:
        return '°C';
      case DataFieldType.time:
        return 'min';
      default:
        return '';
    }
  }

  /// Format the value based on the field type
  String formatValue(Object ? value) {
    if (value == null) {
      return '-';
    }

    //print("Parse type: $type with value: $value");

    switch (type) {
      case DataFieldType.watt:
        final num numValue = value is num ? value : num.tryParse(value.toString()) ?? 0;
        return numValue.toStringAsFixed(0);
      case DataFieldType.voltage:
        final num numValue = value is num ? value : num.tryParse(value.toString()) ?? 0;
        return numValue.toStringAsFixed(1);
      case DataFieldType.current:
        final num numValue = value is num ? value : num.tryParse(value.toString()) ?? 0;
        return numValue.toStringAsFixed(2);

      case DataFieldType.percentage:
        // Percentage - ensure it's between 0-100
        final num numValue = value is num ? value : num.tryParse(value.toString()) ?? 0;
        return numValue.toStringAsFixed(0);

      case DataFieldType.temperature:
        // Temperature - show with 1 decimal place
        final num numValue = value is num ? value : num.tryParse(value.toString()) ?? 0;
        return numValue.toStringAsFixed(1);

      case DataFieldType.time:
        // Time - convert seconds to minutes
        final num seconds = value is num ? value : num.tryParse(value.toString()) ?? 0;
        if (seconds >= 3600) {
          return '${(seconds / 3600).toStringAsFixed(1)}h';
        } else if (seconds >= 60) {
          return '${(seconds / 60).toStringAsFixed(0)}min';
        } else {
          return '${seconds}s';
        }

      case DataFieldType.none:
        // State - return as string
        return value.toString();
      default:
        return value.toString();
    }
  }
}

/// Layout style for data field categories
enum CategoryLayout {
  /// Standard 2-column grid with full cards (default)
  standard,

  /// One-line list layout - compact horizontal cards with smaller height
  oneLine,

  /// Single column full-width cards
  singleColumn,
}
