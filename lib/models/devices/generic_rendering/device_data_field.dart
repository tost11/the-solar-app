import 'package:flutter/material.dart';

/// Enum defining different types of data fields with their units
enum DataFieldType {
  watt,         // Power (W → kW → MW auto-converts)
  percentage,   // Percentage (%)
  voltage,      // Voltage (V)
  current,      // Current (A)
  temperature,  // Temperature (°C)
  time,         // Time duration (s/min/h auto-formatted)
  energy,       // Energy (Wh → kWh → MWh auto-converts)
  frequency,    // Frequency (Hz)
  apparentPower,// Apparent power (VA → kVA auto-converts)
  reactivePower,// Reactive power (VAR → kVAR auto-converts)
  powerFactor,  // Power factor (dimensionless, 0.000-1.000)
  resistance,   // Resistance (Ω → kΩ → MΩ auto-converts)
  count,        // Integer count (no unit, no decimals)
  none,         // No formatting (returns as-is)
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

  /// Custom decimal places (overrides type defaults)
  final int? precision;

  /// Scale factor to divide the value by before formatting (e.g., 10 for 0.1V → V)
  final num? divisor;

  /// Disable automatic unit conversion for large values (e.g., W → kW)
  final bool disableAutoConversion;

  /// Hide this field when valueExtractor returns null (default: false)
  /// When true, the field card will not be rendered at all if the value is null
  final bool hideIfEmpty;

  const DeviceDataField({
    required this.name,
    required this.type,
    required this.valueExtractor,
    this.icon,
    this.expertMode = false,
    this.showDetailButton = false,
    this.category,
    this.precision,
    this.divisor,
    this.disableAutoConversion = false,
    this.hideIfEmpty = false,
  });

  /// Get the unit string based on the field type
  /// Note: For auto-converting types, use getUnit(value) instead for dynamic units
  String get unit {
    switch (type) {
      case DataFieldType.percentage:
        return '%';
      case DataFieldType.voltage:
        return 'V';
      case DataFieldType.current:
        return 'A';
      case DataFieldType.temperature:
        return '°C';
      case DataFieldType.frequency:
        return 'Hz';
      case DataFieldType.watt:
        return 'W';
      case DataFieldType.energy:
        return 'Wh';
      case DataFieldType.apparentPower:
        return 'VA';
      case DataFieldType.reactivePower:
        return 'VAR';
      case DataFieldType.resistance:
        return 'Ω';
      case DataFieldType.time:
        return 's';
      case DataFieldType.powerFactor:
      case DataFieldType.count:
      case DataFieldType.none:
        return '';
    }
  }

  /// Get the appropriate unit for a given value (handles auto-conversion)
  /// For auto-converting types, this returns the scaled unit (W/kW/MW, Wh/kWh/MWh, etc.)
  /// For other types, this returns the same as the unit getter
  String getUnit(Object? value) {
    if (value == null) return unit;

    // Parse numeric value and apply divisor
    num numValue = value is num ? value : (num.tryParse(value.toString()) ?? 0);
    if (divisor != null && divisor != 0) {
      numValue = numValue / divisor!;
    }

    // For auto-converting types, determine the appropriate unit based on magnitude
    if (!disableAutoConversion) {
      final absValue = numValue.abs();

      switch (type) {
        case DataFieldType.watt:
          if (absValue >= 1000000) return 'MW';
          if (absValue >= 1000) return 'kW';
          return 'W';

        case DataFieldType.energy:
          if (absValue >= 1000000) return 'MWh';
          if (absValue >= 1000) return 'kWh';
          return 'Wh';

        case DataFieldType.apparentPower:
          if (absValue >= 1000) return 'kVA';
          return 'VA';

        case DataFieldType.reactivePower:
          if (absValue >= 1000) return 'kVAR';
          return 'VAR';

        case DataFieldType.resistance:
          if (absValue >= 1000000) return 'MΩ';
          if (absValue >= 1000) return 'kΩ';
          return 'Ω';

        case DataFieldType.time:
          final seconds = absValue;
          if (seconds >= 3600) return 'h';
          if (seconds >= 60) return 'min';
          return 's';

        default:
          break;
      }
    }

    // For non-auto-converting types or when disabled, return the base unit
    return unit;
  }

  /// Format the value based on the field type with auto-conversion support
  String formatValue(Object ? value) {
    if (value == null) {
      return '-';
    }

    // Parse numeric value
    num numValue = value is num ? value : (num.tryParse(value.toString()) ?? 0);

    // Apply divisor if specified
    if (divisor != null && divisor != 0) {
      numValue = numValue / divisor!;
    }

    switch (type) {
      case DataFieldType.watt:
        return _formatAutoConvertNumber(
          numValue,
          basePrecision: precision ?? 0,
          kiloPrecision: precision ?? 2,
          megaPrecision: precision ?? 2,
        );

      case DataFieldType.energy:
        return _formatAutoConvertNumber(
          numValue,
          basePrecision: precision ?? 0,
          kiloPrecision: precision ?? 2,
          megaPrecision: precision ?? 2,
        );

      case DataFieldType.apparentPower:
        return _formatAutoConvertNumber(
          numValue,
          basePrecision: precision ?? 0,
          kiloPrecision: precision ?? 2,
        );

      case DataFieldType.reactivePower:
        return _formatAutoConvertNumber(
          numValue,
          basePrecision: precision ?? 0,
          kiloPrecision: precision ?? 2,
        );

      case DataFieldType.resistance:
        return _formatAutoConvertNumber(
          numValue,
          basePrecision: precision ?? 0,
          kiloPrecision: precision ?? 2,
          megaPrecision: precision ?? 2,
        );

      case DataFieldType.voltage:
        return numValue.toStringAsFixed(precision ?? 1);

      case DataFieldType.current:
        return numValue.toStringAsFixed(precision ?? 2);

      case DataFieldType.percentage:
        return numValue.toStringAsFixed(precision ?? 0);

      case DataFieldType.temperature:
        return numValue.toStringAsFixed(precision ?? 1);

      case DataFieldType.frequency:
        return numValue.toStringAsFixed(precision ?? 2);

      case DataFieldType.powerFactor:
        return numValue.toStringAsFixed(precision ?? 3);

      case DataFieldType.count:
        return numValue.toInt().toString();

      case DataFieldType.time:
        // Time - auto-format based on magnitude
        final seconds = numValue.abs();
        if (seconds >= 3600) {
          return (numValue / 3600).toStringAsFixed(precision ?? 1);
        } else if (seconds >= 60) {
          return (numValue / 60).toStringAsFixed(precision ?? 0);
        } else {
          return numValue.toStringAsFixed(precision ?? 0);
        }

      case DataFieldType.none:
        return value.toString();

      default:
        return value.toString();
    }
  }

  /// Helper method for auto-conversion to larger units (returns number only, no unit)
  String _formatAutoConvertNumber(
    num value, {
    required int basePrecision,
    int? kiloPrecision,
    int? megaPrecision,
  }) {
    if (disableAutoConversion) {
      return value.toStringAsFixed(basePrecision);
    }

    final absValue = value.abs();

    // Check for mega unit conversion (>= 1,000,000)
    if (megaPrecision != null && absValue >= 1000000) {
      final converted = value / 1000000;
      return converted.toStringAsFixed(megaPrecision);
    }

    // Check for kilo unit conversion (>= 1,000)
    if (kiloPrecision != null && absValue >= 1000) {
      final converted = value / 1000;
      return converted.toStringAsFixed(kiloPrecision);
    }

    // Use base unit
    return value.toStringAsFixed(basePrecision);
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
