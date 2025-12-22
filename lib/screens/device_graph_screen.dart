import 'dart:async';
import 'package:flutter/material.dart';
import '../models/device.dart';
import '../utils/responsive_breakpoints.dart';
import '../widgets/app_bar_widget.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/charts/time_series_chart_card.dart';
import '../widgets/layouts/responsive_data_grid.dart';

/// Screen displaying live time-series graphs for device data
///
/// Shows responsive grid of graphs:
/// - Mobile: 1 column (vertical stacking)
/// - Tablet: 2 columns
/// - Desktop: 3 columns
///
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

  // Removed: _buildChart - now using TimeSeriesChartCard widget

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
              padding: EdgeInsets.all(ResponsiveBreakpoints.getPadding(context)),
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

                  // Responsive graph grid (mobile: 1 col, tablet: 2 cols, desktop: 3 cols)
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final screenWidth = constraints.maxWidth;
                      final columns = ResponsiveBreakpoints.getGraphColumns(context);
                      final spacing = ResponsiveBreakpoints.getCardSpacing(context);

                      // Calculate width per column
                      final columnWidth = (screenWidth - (spacing * (columns - 1))) / columns;

                      // Calculate aspect ratio to ensure minimum 200px height
                      // aspectRatio = width / height, so for minHeight = 200:
                      // aspectRatio = columnWidth / 200
                      const minHeight = 250.0;
                      final calculatedRatio = columnWidth / minHeight;

                      // Use the calculated ratio, but cap at reasonable values
                      final aspectRatio = calculatedRatio.clamp(1.2, 2.5);

                      return ResponsiveGraphGrid(
                        itemCount: widget.device.timeSeriesFields.length,
                        aspectRatio: aspectRatio,
                        itemBuilder: (context, index) {
                          return TimeSeriesChartCard(
                            field: widget.device.timeSeriesFields[index],
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
    );
  }
}
