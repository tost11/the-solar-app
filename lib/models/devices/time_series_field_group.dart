import 'package:flutter/material.dart';
import 'time_series_field_config.dart';
import 'generic_rendering/device_data_field.dart';
import '../to.dart';

/// Groups multiple time series fields to be displayed in a single chart
class TimeSeriesFieldGroup {
  final TO name;
  final List<TimeSeriesFieldConfig> fields;
  final List<Color> colors;
  final bool expertMode;

  TimeSeriesFieldGroup({
    required this.name,
    required this.fields,
    List<Color>? colors,
    this.expertMode = false,
  }) : colors = colors ?? _generateDefaultColors(fields.length);

  static List<Color> _generateDefaultColors(int count) {
    const defaultColors = [
      Colors.blue,
      Colors.orange,
      Colors.green,
      Colors.red,
      Colors.purple,
      Colors.cyan,
      Colors.amber,
      Colors.teal,
    ];

    return List.generate(
        count, (i) => defaultColors[i % defaultColors.length]);
  }

  /// Check if group has any data to display
  bool get hasData => fields.any((f) => f.values.isNotEmpty);

  /// Get unit from first field (all fields should have same type)
  String get unit => fields.isNotEmpty ? fields.first.unit : '';

  /// Get data type from first field
  DataFieldType get type =>
      fields.isNotEmpty ? fields.first.type : DataFieldType.none;

  /// Get localized name
  String getName(BuildContext context) => name.getText(context);
}
