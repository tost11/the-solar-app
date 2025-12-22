import 'package:flutter/material.dart';
import '../../utils/responsive_breakpoints.dart';

/// A builder widget that adapts its child based on screen size
///
/// Provides different builder functions for mobile, tablet, and desktop
/// screen sizes. Rebuilds automatically when screen size changes.
///
/// Example usage:
/// ```dart
/// ResponsiveBuilder(
///   mobile: (context) => MobileLayout(),
///   tablet: (context) => TabletLayout(),
///   desktop: (context) => DesktopLayout(),
/// )
/// ```
///
/// If tablet or desktop builders are not provided, they fall back to mobile.
class ResponsiveBuilder extends StatelessWidget {
  /// Builder for mobile screens (< 600px)
  final Widget Function(BuildContext context) mobile;

  /// Optional builder for tablet screens (600-840px)
  /// Falls back to mobile if not provided
  final Widget Function(BuildContext context)? tablet;

  /// Optional builder for desktop screens (>= 840px)
  /// Falls back to tablet or mobile if not provided
  final Widget Function(BuildContext context)? desktop;

  const ResponsiveBuilder({
    required this.mobile,
    this.tablet,
    this.desktop,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenSize = ResponsiveBreakpoints.getScreenSize(context);

        switch (screenSize) {
          case ScreenSize.mobile:
            return mobile(context);

          case ScreenSize.tablet:
            return (tablet ?? mobile)(context);

          case ScreenSize.desktop:
            return (desktop ?? tablet ?? mobile)(context);
        }
      },
    );
  }
}

/// A simplified responsive builder that takes a single builder function
/// with screen size information
///
/// Example usage:
/// ```dart
/// ResponsiveValue(
///   builder: (context, screenSize, width) {
///     if (screenSize == ScreenSize.mobile) {
///       return MobileLayout();
///     }
///     return DesktopLayout();
///   },
/// )
/// ```
class ResponsiveValue extends StatelessWidget {
  /// Builder function that receives screen size information
  final Widget Function(
    BuildContext context,
    ScreenSize screenSize,
    double width,
  ) builder;

  const ResponsiveValue({
    required this.builder,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenSize = ResponsiveBreakpoints.getScreenSize(context);
        final width = constraints.maxWidth;
        return builder(context, screenSize, width);
      },
    );
  }
}
