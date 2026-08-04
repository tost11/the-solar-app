import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

/// A card displaying historical daily energy production as a bar chart.
///
/// Expects the parsed result from `COMMAND_FETCH_HIST_ENERGY`:
/// ```
/// {
///   'days': [ {'time': epochSeconds, 'energy': double (kWh)}, ... ],
/// }
/// ```
class HistoricalEnergyBarChartCard extends StatelessWidget {
  final String title;
  final Map<String, dynamic>? data;
  final String emptyMessage;
  final double chartHeight;

  const HistoricalEnergyBarChartCard({
    super.key,
    required this.title,
    required this.data,
    required this.emptyMessage,
    this.chartHeight = 240,
  });

  @override
  Widget build(BuildContext context) {
    final days = (data?['days'] as List?)?.cast<Map<String, dynamic>>() ?? const [];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: chartHeight,
              width: double.infinity,
              child: days.isEmpty
                  ? Center(
                      child: Text(
                        emptyMessage,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    )
                  : _buildChart(days),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChart(List<Map<String, dynamic>> days) {
    double maxEnergy = 0;
    final groups = <BarChartGroupData>[];

    for (var i = 0; i < days.length; i++) {
      final energy = (days[i]['energy'] as num).toDouble();
      if (energy > maxEnergy) maxEnergy = energy;
      groups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: energy,
              color: Colors.green,
              width: days.length > 20 ? 6 : 14,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(3)),
            ),
          ],
        ),
      );
    }

    final yMax = maxEnergy > 0 ? maxEnergy * 1.15 : 1.0;
    // Show at most ~6 x-axis labels to avoid clutter.
    final labelStep = (days.length / 6).ceil().clamp(1, days.length);

    return BarChart(
      BarChartData(
        maxY: yMax,
        minY: 0,
        barGroups: groups,
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 44,
              getTitlesWidget: (value, meta) => Text(
                value.toStringAsFixed(1),
                style: const TextStyle(fontSize: 10),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= days.length) return const SizedBox.shrink();
                if (index % labelStep != 0) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    '${index + 1}',
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
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                '${rod.toY.toStringAsFixed(3)} kWh',
                const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
              );
            },
          ),
        ),
      ),
    );
  }
}
