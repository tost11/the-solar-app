import 'package:flutter/material.dart';
import '../../utils/responsive_breakpoints.dart';

/// A responsive grid widget that automatically adjusts column count
///
/// Adapts the number of columns based on screen size:
/// - Mobile: 2 columns
/// - Tablet: 3 columns
/// - Desktop: 4 columns
///
/// Can be customized with optional column count overrides.
///
/// Example usage:
/// ```dart
/// ResponsiveDataGrid(
///   itemCount: fields.length,
///   itemBuilder: (context, index) {
///     return DeviceDataCard(...);
///   },
/// )
/// ```
class ResponsiveDataGrid extends StatelessWidget {
  /// Number of items to display
  final int itemCount;

  /// Builder function for each grid item
  final Widget Function(BuildContext context, int index) itemBuilder;

  /// Optional fixed column count (overrides responsive behavior)
  final int? columnCount;

  /// Optional custom aspect ratio (overrides responsive behavior)
  final double? aspectRatio;

  /// Cross axis spacing between items
  final double? crossAxisSpacing;

  /// Main axis spacing between items
  final double? mainAxisSpacing;

  /// Whether the grid should shrink-wrap its content
  final bool shrinkWrap;

  /// Physics for the grid scroll behavior
  final ScrollPhysics? physics;

  /// Padding around the grid
  final EdgeInsetsGeometry? padding;

  /// Minimum card width (default: 130px)
  final double? minCardWidth;

  /// Maximum card width (default: 180px)
  final double? maxCardWidth;

  const ResponsiveDataGrid({
    required this.itemCount,
    required this.itemBuilder,
    this.columnCount,
    this.aspectRatio,
    this.crossAxisSpacing,
    this.mainAxisSpacing,
    this.shrinkWrap = true,
    this.physics = const NeverScrollableScrollPhysics(),
    this.padding,
    this.minCardWidth = 130.0,
    this.maxCardWidth = 180.0,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // Use LayoutBuilder to calculate optimal column count based on min/max constraints
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;

        // Get responsive values based on available width
        final spacing = crossAxisSpacing ?? ResponsiveBreakpoints.getCardSpacingFromWidth(availableWidth);
        final mainSpacing = mainAxisSpacing ?? spacing;
        final minWidth = minCardWidth ?? 130.0;
        final maxWidth = maxCardWidth ?? 180.0;

        // Calculate optimal column count
        // Start with max width and see how many columns fit
        int columns = (availableWidth / maxWidth).floor();
        if (columns < 1) columns = 1;

        // Check if cards would be too small with this column count
        final cardWidth = (availableWidth - (spacing * (columns - 1))) / columns;
        if (cardWidth < minWidth && columns > 1) {
          columns--;
        }

        return GridView.builder(
          shrinkWrap: shrinkWrap,
          physics: physics,
          padding: padding,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            mainAxisExtent: 100.0,  // Fixed height instead of aspect ratio
            crossAxisSpacing: spacing,
            mainAxisSpacing: mainSpacing,
          ),
          itemCount: itemCount,
          itemBuilder: itemBuilder,
        );
      },
    );
  }
}

/// A responsive grid widget specifically for graph/chart layouts
///
/// Adapts the number of columns based on screen size:
/// - Mobile: 1 column (vertical stacking)
/// - Tablet: 2 columns
/// - Desktop: 3 columns
///
/// Example usage:
/// ```dart
/// ResponsiveGraphGrid(
///   itemCount: charts.length,
///   itemBuilder: (context, index) {
///     return TimeSeriesChartCard(...);
///   },
/// )
/// ```
class ResponsiveGraphGrid extends StatelessWidget {
  /// Number of items to display
  final int itemCount;

  /// Builder function for each grid item
  final Widget Function(BuildContext context, int index) itemBuilder;

  /// Optional fixed column count (overrides responsive behavior)
  final int? columnCount;

  /// Optional custom aspect ratio (overrides responsive behavior)
  final double? aspectRatio;

  /// Cross axis spacing between items
  final double? crossAxisSpacing;

  /// Main axis spacing between items
  final double? mainAxisSpacing;

  /// Whether the grid should shrink-wrap its content
  final bool shrinkWrap;

  /// Physics for the grid scroll behavior
  final ScrollPhysics? physics;

  /// Padding around the grid
  final EdgeInsetsGeometry? padding;

  const ResponsiveGraphGrid({
    required this.itemCount,
    required this.itemBuilder,
    this.columnCount,
    this.aspectRatio,
    this.crossAxisSpacing,
    this.mainAxisSpacing,
    this.shrinkWrap = true,
    this.physics = const NeverScrollableScrollPhysics(),
    this.padding,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Use available width instead of screen width for responsive decisions
        final availableWidth = constraints.maxWidth;

        // Get responsive values based on available width
        final columns = columnCount ?? ResponsiveBreakpoints.getGraphColumnsFromWidth(availableWidth);
        final ratio = aspectRatio ?? ResponsiveBreakpoints.getGraphAspectRatio(context);
        final spacing = crossAxisSpacing ?? ResponsiveBreakpoints.getCardSpacingFromWidth(availableWidth);
        final mainSpacing = mainAxisSpacing ?? spacing;

        return GridView.builder(
          shrinkWrap: shrinkWrap,
          physics: physics,
          padding: padding,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            childAspectRatio: ratio,
            crossAxisSpacing: spacing,
            mainAxisSpacing: mainSpacing,
          ),
          itemCount: itemCount,
          itemBuilder: itemBuilder,
        );
      },
    );
  }
}
