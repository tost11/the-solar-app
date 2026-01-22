import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../models/devices/time_series_field_config.dart';
import '../../models/devices/time_series_field_group.dart';

/// A card widget displaying a time-series line chart
///
/// Supports both single-field and multi-series charts:
/// - Single field: Shows one line chart (legacy behavior)
/// - Field group: Shows multiple colored lines with legend
///
/// Example usage:
/// ```dart
/// // Single field (legacy)
/// TimeSeriesChartCard(
///   field: TimeSeriesFieldConfig(
///     name: 'Solar Power',
///     unit: 'W',
///     values: [...],
///   ),
/// )
///
/// // Multi-series group
/// TimeSeriesChartCard(
///   group: TimeSeriesFieldGroup(
///     name: 'DC String Power',
///     fields: [field1, field2, field3, field4],
///   ),
/// )
/// ```
class TimeSeriesChartCard extends StatelessWidget {
  /// The time series field configuration (for single-line charts)
  final TimeSeriesFieldConfig? field;

  /// The time series field group (for multi-line charts)
  final TimeSeriesFieldGroup? group;

  /// Optional fixed height for the chart (default: 200)
  final double chartHeight;

  const TimeSeriesChartCard({
    this.field,
    this.group,
    this.chartHeight = 200,
    super.key,
  }) : assert(field != null || group != null, 'Either field or group must be provided'),
       assert(field == null || group == null, 'Cannot provide both field and group');

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // Determine if we're rendering a single field or a group
    final isGroup = group != null;
    final displayName = isGroup ? group!.getName(context) : field!.getLocalizedName(context);
    final displayUnit = isGroup ? group!.unit : field!.unit;

    // Check if we have data
    if (isGroup) {
      if (!group!.hasData) {
        return _buildEmptyCard(displayName, 'Keine Daten verfügbar');
      }
    } else {
      if (field!.values.isEmpty) {
        return _buildEmptyCard(displayName, 'Keine Daten verfügbar');
      }
    }

    // Find min and max time for the chart
    final now = DateTime.now();
    final fiveMinutesAgo = now.subtract(const Duration(minutes: 5));

    // Build line data for single field or multiple fields
    final List<LineChartBarData> lineBarsData;
    final double minY;
    final double maxY;

    if (isGroup) {
      // Multi-series rendering
      final lineDataList = <LineChartBarData>[];
      final allYValues = <double>[];

      for (int i = 0; i < group!.fields.length; i++) {
        final fieldConfig = group!.fields[i];
        if (fieldConfig.values.isEmpty) continue;

        final spots = fieldConfig.values.map((point) {
          final secondsFromStart = point.timestamp.difference(fiveMinutesAgo).inSeconds.toDouble();
          return FlSpot(secondsFromStart, point.value.toDouble());
        }).toList();

        if (spots.isEmpty) continue;

        // Collect all Y values for min/max calculation
        allYValues.addAll(spots.map((spot) => spot.y));

        // Create line with color from group
        lineDataList.add(LineChartBarData(
          spots: spots,
          isCurved: true,
          color: group!.colors[i],
          barWidth: 2.5,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(show: false), // No fill for multi-series
        ));
      }

      lineBarsData = lineDataList;

      // Calculate min/max across all series
      if (allYValues.isEmpty) {
        return _buildEmptyCard(displayName, 'Keine Daten im Zeitfenster');
      }
      minY = allYValues.reduce((a, b) => a < b ? a : b);
      maxY = allYValues.reduce((a, b) => a > b ? a : b);
    } else {
      // Single-series rendering (legacy)
      final spots = field!.values.map((point) {
        final secondsFromStart = point.timestamp.difference(fiveMinutesAgo).inSeconds.toDouble();
        return FlSpot(secondsFromStart, point.value.toDouble());
      }).toList();

      if (spots.isEmpty) {
        return _buildEmptyCard(displayName, 'Keine Daten im Zeitfenster');
      }

      lineBarsData = [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          color: Colors.blue,
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            color: Colors.blue.withOpacity(0.1),
          ),
        ),
      ];

      // Calculate min/max for single series
      final values = spots.map((spot) => spot.y).toList();
      minY = values.reduce((a, b) => a < b ? a : b);
      maxY = values.reduce((a, b) => a > b ? a : b);
    }

    // Handle constant value case (minY == maxY)
    final yRange = maxY - minY;
    final yPadding = yRange > 0 ? yRange * 0.1 : maxY.abs() * 0.1; // 10% padding
    final safeMinY = yRange > 0 ? minY - yPadding : minY - 10;
    final safeMaxY = yRange > 0 ? maxY + yPadding : maxY + 10;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Field name and unit
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    displayName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (displayUnit.isNotEmpty)
                  Text(
                    displayUnit,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // Chart - Flexible to adapt to available space
            Flexible(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // Use available width, adapt height to constraints
                  // If maxHeight is finite and positive, use it; otherwise use chartHeight
                  final availableHeight = constraints.maxHeight.isFinite && constraints.maxHeight > 0
                      ? constraints.maxHeight
                      : chartHeight;
                  // Use the smaller of chartHeight or available space
                  final height = availableHeight < chartHeight ? availableHeight : chartHeight;

                  return SizedBox(
                    width: double.infinity,
                    height: height,
                    child: LineChart(
                LineChartData(
                  minX: 0,
                  maxX: 300, // 5 minutes = 300 seconds
                  minY: safeMinY.isFinite ? safeMinY : 0,
                  maxY: safeMaxY.isFinite ? safeMaxY : 100,
                  lineBarsData: lineBarsData,
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toStringAsFixed(1),
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        interval: 60, // Show label every minute
                        getTitlesWidget: (value, meta) {
                          final time = fiveMinutesAgo.add(Duration(seconds: value.toInt()));
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              DateFormat('HH:mm').format(time),
                              style: const TextStyle(fontSize: 10),
                            ),
                          );
                        },
                      ),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: true,
                    horizontalInterval: yRange > 0 ? yRange / 4 : 1,
                    verticalInterval: 60,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Colors.grey.withOpacity(0.3),
                        strokeWidth: 1,
                      );
                    },
                    getDrawingVerticalLine: (value) {
                      return FlLine(
                        color: Colors.grey.withOpacity(0.3),
                        strokeWidth: 1,
                      );
                    },
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(
                      color: Colors.grey.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  lineTouchData: LineTouchData(
                    enabled: true,
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipItems: (touchedSpots) {
                        return touchedSpots.map((spot) {
                          final time = fiveMinutesAgo.add(Duration(seconds: spot.x.toInt()));

                          // For multi-series, show the field name
                          String label = '';
                          if (isGroup && spot.barIndex < group!.fields.length) {
                            label = '${group!.fields[spot.barIndex].getLocalizedName(context)}\n';
                          }

                          return LineTooltipItem(
                            '$label${DateFormat('HH:mm:ss').format(time)}\n${spot.y.toStringAsFixed(1)} $displayUnit',
                            TextStyle(
                              color: isGroup ? group!.colors[spot.barIndex] : Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          );
                        }).toList();
                      },
                    ),
                  ),
                ),
                    ),
                  );
                },
              ),
            ),

            // Legend for multi-series or current value for single series
            if (isGroup) ...[
              const SizedBox(height: 12),
              _buildLegend(context, group!),
            ] else if (field!.values.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Aktuell:',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    '${field!.values.last.value.toStringAsFixed(1)} ${field!.unit}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Build an empty card with a message
  Widget _buildEmptyCard(String name, String message) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text(
                  message,
                  style: const TextStyle(color: Colors.grey),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build legend for multi-series graphs
  Widget _buildLegend(BuildContext context, TimeSeriesFieldGroup group) {
    final l10n = AppLocalizations.of(context)!;

    return Wrap(
      spacing: 16,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: List.generate(group.fields.length, (i) {
        final fieldConfig = group.fields[i];
        final color = group.colors[i];

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 16,
              height: 3,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 4),
            Text(
              fieldConfig.getLocalizedName(context),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        );
      }),
    );
  }
}
