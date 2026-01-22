import 'dart:async';
import 'package:flutter/material.dart';
import '../models/device.dart';
import '../models/devices/time_series_field_config.dart';
import '../models/devices/time_series_field_group.dart';
import '../utils/globals.dart';
import '../utils/localization_extension.dart';
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

    // Add listener for expert mode changes
    Globals.expertModeNotifier.addListener(_onExpertModeChanged);
  }

  // Callback when expert mode changes
  void _onExpertModeChanged() {
    if (mounted) {
      setState(() {
        // Force rebuild to show/hide expert-only graphs
      });
    }
  }

  @override
  void dispose() {
    // IMPORTANT: Remove listener to prevent memory leaks
    Globals.expertModeNotifier.removeListener(_onExpertModeChanged);

    _updateTimer?.cancel();
    _dataSubscription?.cancel();
    super.dispose();
  }

  /// Get time series fields visible based on expert mode
  List<TimeSeriesFieldConfig> _getVisibleTimeSeriesFields() {
    return widget.device.timeSeriesFields
        .where((field) => !field.expertMode || Globals.expertMode)
        .toList();
  }

  /// Get time series field groups visible based on expert mode
  List<TimeSeriesFieldGroup> _getVisibleTimeSeriesFieldGroups() {
    return widget.device.timeSeriesFieldGroups
            .where((group) => !group.expertMode || Globals.expertMode)
            .toList();
  }

  /// Get total count of visible graphs (fields + groups with data)
  int _getVisibleGraphCount() {
    final fields = _getVisibleTimeSeriesFields();
    final groups = _getVisibleTimeSeriesFieldGroups().where((g) => g.hasData).toList();
    return fields.length + groups.length;
  }

  // Removed: _buildChart - now using TimeSeriesChartCard widget

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBarWidget(
        title: context.l10n.screenLiveGraphs,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _getVisibleGraphCount() == 0
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text(
                  context.l10n.infoNoGraphFields,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
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
                    context.l10n.infoDataRange,
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
                      final availableWidth = constraints.maxWidth;
                      final columns = ResponsiveBreakpoints.getGraphColumnsFromWidth(availableWidth);
                      final spacing = ResponsiveBreakpoints.getCardSpacingFromWidth(availableWidth);

                      // Calculate width per column
                      final columnWidth = (availableWidth - (spacing * (columns - 1))) / columns;

                      // Calculate aspect ratio to ensure minimum 200px height
                      // aspectRatio = width / height, so for minHeight = 200:
                      // aspectRatio = columnWidth / 200
                      const minHeight = 250.0;
                      final calculatedRatio = columnWidth / minHeight;

                      // Use the calculated ratio, but cap at reasonable values
                      final aspectRatio = calculatedRatio.clamp(1.2, 2.5);

                      // Get visible graphs (filtered by expert mode)
                      final visibleFields = _getVisibleTimeSeriesFields();
                      final visibleGroups = _getVisibleTimeSeriesFieldGroups()
                          .where((g) => g.hasData)
                          .toList();

                      // Combine fields and groups into a single list
                      // Groups first, then single fields
                      final totalGraphs = visibleGroups.length + visibleFields.length;

                      return ResponsiveGraphGrid(
                        itemCount: totalGraphs,
                        aspectRatio: aspectRatio,
                        itemBuilder: (context, index) {
                          // First render all groups, then single fields
                          if (index < visibleGroups.length) {
                            return TimeSeriesChartCard(
                              group: visibleGroups[index],
                            );
                          } else {
                            final fieldIndex = index - visibleGroups.length;
                            return TimeSeriesChartCard(
                              field: visibleFields[fieldIndex],
                            );
                          }
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
