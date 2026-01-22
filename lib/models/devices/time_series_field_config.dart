import 'package:flutter/material.dart';
import 'package:the_solar_app/models/devices/generic_rendering/device_data_field.dart';
import 'package:the_solar_app/models/to.dart';
import 'time_series_data_point.dart';

/// Configuration for a time series field to track for graphing
///
/// Defines which data field to track, how to extract it from device data,
/// and how to transform/format the values. Stores historical data points
/// for the last 5 minutes.
class TimeSeriesFieldConfig {
  /// Display name for the graph (Translation Object)
  final TO name;

  /// Type of data field (determines unit and formatting)
  final DataFieldType type;

  /// Path to data in nested map structure
  /// Example: ['data', 'properties', 'solarInputPower']
  final List<String> mapping;

  /// Optional function to transform values before storing
  /// Example: (value) => value / 10 to convert from 0.1V to V
  final num Function(num)? formatter;

  /// Whether this field requires expert mode to be visible
  /// Set to true for technical fields like voltage/current
  final bool expertMode;

  /// Hide this field when no historical data points exist (default: false)
  /// When true, the chart card will not be rendered at all if values.isEmpty
  final bool hideIfEmpty;

  /// Runtime storage for historical data points
  /// Only data from the last 5 minutes is kept
  final List<TimeSeriesDataPoint> values = [];

  /// Maximum age of data points in milliseconds (5 minutes)
  static const int maxDataAgeMs = 5 * 60 * 1000;

  TimeSeriesFieldConfig({
    required this.name,
    required this.type,
    required this.mapping,
    this.formatter,
    this.expertMode = false,
    this.hideIfEmpty = false,
  });

  /// Get the localized name for this field
  String getLocalizedName(BuildContext context) {
    return name.getText(context);
  }

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
      case DataFieldType.energy:
        return 'Wh';
      case DataFieldType.frequency:
        return 'Hz';
      case DataFieldType.apparentPower:
        return 'VA';
      case DataFieldType.reactivePower:
        return 'VAR';
      case DataFieldType.powerFactor:
        return '';
      case DataFieldType.resistance:
        return 'Ω';
      case DataFieldType.count:
        return '';
      case DataFieldType.none:
        return '';
    }
  }

  /// Get localized name
  String getName(BuildContext context) => name.getText(context);

  /// Add a new data point to the time series
  void addValue(DateTime timestamp, num value) {
    values.add(TimeSeriesDataPoint(
      timestamp: timestamp,
      value: value,
    ));
  }

  /// Remove data points older than 5 minutes
  void pruneOldData() {
    final cutoffTime = DateTime.now().subtract(
      const Duration(milliseconds: maxDataAgeMs),
    );

    values.removeWhere((point) => point.timestamp.isBefore(cutoffTime));
  }

  /// Extract value from nested map data using the mapping path
  /// Returns null if the path doesn't exist or value is invalid
  num? extractValue(Map<String, dynamic> data) {
    try {
      dynamic value = data;

      // Navigate through nested map/list structure using mapping path
      for (var key in mapping) {
        if (value is Map<String, dynamic>) {
          // Navigate through map
          value = value[key];
        } else if (value is List) {
          // Navigate through list using integer index
          final index = int.tryParse(key);
          if (index == null || index < 0 || index >= value.length) {
            return null; // Invalid list index
          }
          value = value[index];
        } else {
          return null; // Path doesn't exist
        }
      }

      // Convert to num
      if (value == null) return null;

      num numValue;
      if (value is num) {
        numValue = value;
      } else {
        numValue = num.parse(value.toString());
      }

      // Apply formatter if exists
      if (formatter != null) {
        numValue = formatter!(numValue);
      }

      return numValue;
    } catch (e) {
      return null; // Extraction or parsing failed
    }
  }
}
