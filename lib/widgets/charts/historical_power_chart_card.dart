import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

/// A card displaying an intraday historical power curve as a line chart.
///
/// Expects the parsed result from `COMMAND_FETCH_HIST_POWER`:
/// ```
/// {
///   'start_time': int (epoch seconds),
///   'step_time': int (seconds),
///   'daily_energy': double (kWh),
///   'points': [ {'time': epochSeconds, 'power': int (W)}, ... ],
/// }
/// ```
class HistoricalPowerChartCard extends StatelessWidget {
  final String title;
  final Map<String, dynamic>? data;
  final String emptyMessage;
  final double chartHeight;

  const HistoricalPowerChartCard({
    super.key,
    required this.title,
    required this.data,
    required this.emptyMessage,
    this.chartHeight = 240,
  });

  @override
  Widget build(BuildContext context) {
    final points = (data?['points'] as List?)?.cast<Map<String, dynamic>>() ?? const [];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                if (data?['daily_energy'] != null)
                  Text(
                    '${(data!['daily_energy'] as num).toStringAsFixed(2)} kWh',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: chartHeight,
              width: double.infinity,
              child: points.isEmpty
                  ? Center(
                      child: Text(
                        emptyMessage,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    )
                  : _buildChart(points),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChart(List<Map<String, dynamic>> points) {
    final spots = <FlSpot>[];
    double maxPower = 0;
    final firstTime = (points.first['time'] as num).toDouble();
    final lastTime = (points.last['time'] as num).toDouble();

    for (final p in points) {
      final t = (p['time'] as num).toDouble();
      final power = (p['power'] as num).toDouble();
      spots.add(FlSpot(t, power));
      if (power > maxPower) maxPower = power;
    }

    final span = (lastTime - firstTime);
    final yMax = maxPower > 0 ? maxPower * 1.15 : 100.0;
    final labelInterval = span > 0 ? span / 4 : 3600;

    return LineChart(
      LineChartData(
        minX: firstTime,
        maxX: lastTime,
        minY: 0,
        maxY: yMax,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            barWidth: 2,
            color: Colors.orange,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: Colors.orange.withOpacity(0.15),
            ),
          ),
        ],
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 44,
              getTitlesWidget: (value, meta) => Text(
                '${value.toInt()}',
                style: const TextStyle(fontSize: 10),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: labelInterval.toDouble(),
              getTitlesWidget: (value, meta) {
                final seconds = value.toInt() - firstTime.toInt();
                final h = seconds ~/ 3600;
                final m = (seconds % 3600) ~/ 60;
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    '${h}:${m.toString().padLeft(2, '0')}',
                    style: const TextStyle(fontSize: 10),
                  ),
                );
              },
            ),
          ),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: yMax > 0 ? yMax / 4 : 1,
          getDrawingHorizontalLine: (value) =>
              FlLine(color: Colors.grey.withOpacity(0.3), strokeWidth: 1),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: Colors.grey.withOpacity(0.3), width: 1),
        ),
        lineTouchData: LineTouchData(
          enabled: true,
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                final seconds = spot.x.toInt() - firstTime.toInt();
                final h = seconds ~/ 3600;
                final m = (seconds % 3600) ~/ 60;
                return LineTooltipItem(
                  '${h}:${m.toString().padLeft(2, '0')}\n${spot.y.toStringAsFixed(0)} W',
                  const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                );
              }).toList();
            },
          ),
        ),
      ),
    );
  }
}
