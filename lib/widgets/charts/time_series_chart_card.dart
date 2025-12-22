import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../models/devices/time_series_field_config.dart';

/// A card widget displaying a time-series line chart
///
/// Shows a line chart for a single time series field with automatic scaling,
/// time axis labels, and interactive tooltips. Displays data from the last 5 minutes.
///
/// Example usage:
/// ```dart
/// TimeSeriesChartCard(
///   field: TimeSeriesFieldConfig(
///     name: 'Solar Power',
///     unit: 'W',
///     values: [...],
///   ),
/// )
/// ```
class TimeSeriesChartCard extends StatelessWidget {
  /// The time series field configuration containing name, unit, and data points
  final TimeSeriesFieldConfig field;

  /// Optional fixed height for the chart (default: 200)
  final double chartHeight;

  const TimeSeriesChartCard({
    required this.field,
    this.chartHeight = 200,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // Check if we have data
    if (field.values.isEmpty) {
      return _buildEmptyCard('Keine Daten verfügbar');
    }

    // Find min and max time for the chart
    final now = DateTime.now();
    final fiveMinutesAgo = now.subtract(const Duration(minutes: 5));

    // Convert data points to FlSpot (x = seconds from start, y = value)
    final spots = field.values.map((point) {
      final secondsFromStart = point.timestamp.difference(fiveMinutesAgo).inSeconds.toDouble();
      return FlSpot(secondsFromStart, point.value.toDouble());
    }).toList();

    // Check if spots list is empty (can happen even if field.values has data)
    if (spots.isEmpty) {
      return _buildEmptyCard('Keine Daten im Zeitfenster');
    }

    // Find min and max values for Y axis (safe version)
    final values = spots.map((spot) => spot.y).toList();
    final minY = values.reduce((a, b) => a < b ? a : b);
    final maxY = values.reduce((a, b) => a > b ? a : b);

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
                Text(
                  field.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (field.unit.isNotEmpty)
                  Text(
                    field.unit,
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
                  lineBarsData: [
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
                  ],
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
                          return LineTooltipItem(
                            '${DateFormat('HH:mm:ss').format(time)}\n${spot.y.toStringAsFixed(1)} ${field.unit}',
                            const TextStyle(
                              color: Colors.white,
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

            // Current value display
            if (field.values.isNotEmpty) ...[
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
                    '${field.values.last.value.toStringAsFixed(1)} ${field.unit}',
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
  Widget _buildEmptyCard(String message) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              field.name,
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
}
