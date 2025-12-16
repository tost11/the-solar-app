import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../models/device.dart';
import '../models/devices/time_series_field_config.dart';
import '../widgets/app_bar_widget.dart';
import '../widgets/app_scaffold.dart';

/// Screen displaying live time-series graphs for device data
///
/// Shows vertically stacked graphs for each configured time series field.
/// Graphs auto-update every 5 seconds and display data from the last 5 minutes.
class DeviceGraphScreen extends StatefulWidget {
  final Device device;

  const DeviceGraphScreen({super.key, required this.device});

  @override
  State<DeviceGraphScreen> createState() => _DeviceGraphScreenState();
}

class _DeviceGraphScreenState extends State<DeviceGraphScreen> {
  Timer? _updateTimer;
  StreamSubscription<Map<String, dynamic>>? _dataSubscription;

  @override
  void initState() {
    super.initState();

    // Subscribe to data stream to trigger updates when new data arrives
    _dataSubscription = widget.device.dataStream.listen((_) {
      if (mounted) {
        setState(() {
          // Rebuild to show new data points
        });
      }
    });

    // Set up timer to refresh graphs every 5 seconds
    _updateTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (mounted) {
        setState(() {
          // Periodic refresh to update time axis and animations
        });
      }
    });
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    _dataSubscription?.cancel();
    super.dispose();
  }

  /// Build a chart for a single time series field
  Widget _buildChart(TimeSeriesFieldConfig field) {
    // Check if we have data
    if (field.values.isEmpty) {
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
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Text(
                    'Keine Daten verfügbar',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
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
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Text(
                    'Keine Daten im Zeitfenster',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
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

            // Chart
            SizedBox(
              height: 200,
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

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBarWidget(
        title: 'Live-Diagramme',
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: widget.device.timeSeriesFields.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: Text(
                  'Dieses Gerät hat keine konfigurierten Diagrammfelder.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Info text
                  Text(
                    'Datenbereich: Letzte 5 Minuten | Aktualisierung: alle 5 Sekunden',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),

                  // Build a chart for each time series field
                  ...widget.device.timeSeriesFields.map((field) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: _buildChart(field),
                    );
                  }),
                ],
              ),
            ),
    );
  }
}
