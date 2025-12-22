import 'package:flutter/material.dart';

/// Screen size categories based on Material Design 3 breakpoints
enum ScreenSize {
  /// Mobile devices (< 600px width)
  mobile,

  /// Tablet devices (600-840px width)
  tablet,

  /// Desktop devices (>= 840px width)
  desktop,
}

/// Responsive breakpoint utility class
///
/// Provides breakpoint definitions and helper methods for responsive design
/// based on Material Design 3 breakpoint system.
///
/// Breakpoints:
/// - Mobile: < 600px
/// - Tablet: 600-840px
/// - Desktop: >= 840px
///
/// Example usage:
/// ```dart
/// final screenSize = ResponsiveBreakpoints.getScreenSize(context);
/// final columns = ResponsiveBreakpoints.getGridColumns(context);
/// if (ResponsiveBreakpoints.useMasterDetail(context)) {
///   // Show split-screen layout
/// }
/// ```
class ResponsiveBreakpoints {
  // Breakpoint values (Material Design 3)
  static const double mobileMax = 600.0;
  static const double tabletMax = 840.0;

  /// Get the current screen size category
  static ScreenSize getScreenSize(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < mobileMax) return ScreenSize.mobile;
    if (width < tabletMax) return ScreenSize.tablet;
    return ScreenSize.desktop;
  }

  /// Get the current screen width
  static double getScreenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  /// Get adaptive number of columns for data field grid
  ///
  /// Returns:
  /// - Mobile: 2 columns
  /// - Tablet: 3 columns
  /// - Desktop: 4 columns
  static int getGridColumns(BuildContext context) {
    switch (getScreenSize(context)) {
      case ScreenSize.mobile:
        return 2;
      case ScreenSize.tablet:
        return 3;
      case ScreenSize.desktop:
        return 4;
    }
  }

  /// Get adaptive number of columns for graph grid
  ///
  /// Returns:
  /// - < 600px: 1 column (mobile)
  /// - 600-1100px: 2 columns (tablet and small desktop)
  /// - >= 1100px: 3 columns (large desktop)
  static int getGraphColumns(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < mobileMax) return 1;        // < 600px: mobile
    if (width < 1100.0) return 2;            // 600-1100px: tablet/small desktop
    return 3;                                 // >= 1100px: large desktop
  }

  /// Whether to use master-detail navigation pattern
  ///
  /// Returns true for tablet and desktop, false for mobile
  static bool useMasterDetail(BuildContext context) {
    return getScreenSize(context) != ScreenSize.mobile;
  }

  /// Get adaptive padding size
  ///
  /// Returns:
  /// - Mobile: 16.0
  /// - Tablet: 24.0
  /// - Desktop: 32.0
  static double getPadding(BuildContext context) {
    switch (getScreenSize(context)) {
      case ScreenSize.mobile:
        return 16.0;
      case ScreenSize.tablet:
        return 24.0;
      case ScreenSize.desktop:
        return 32.0;
    }
  }

  /// Get adaptive card spacing
  ///
  /// Returns:
  /// - Mobile: 8.0
  /// - Tablet: 12.0
  /// - Desktop: 16.0
  static double getCardSpacing(BuildContext context) {
    switch (getScreenSize(context)) {
      case ScreenSize.mobile:
        return 8.0;
      case ScreenSize.tablet:
        return 12.0;
      case ScreenSize.desktop:
        return 16.0;
    }
  }

  /// Get adaptive aspect ratio for data cards
  ///
  /// Returns:
  /// - Mobile: 1.5
  /// - Tablet: 1.4
  /// - Desktop: 1.3
  static double getCardAspectRatio(BuildContext context) {
    switch (getScreenSize(context)) {
      case ScreenSize.mobile:
        return 1.5;
      case ScreenSize.tablet:
        return 1.4;
      case ScreenSize.desktop:
        return 1.3;
    }
  }

  /// Get adaptive aspect ratio for graphs
  ///
  /// Returns:
  /// - Mobile: 1.5 (taller for portrait)
  /// - Tablet: 1.8 (balanced)
  /// - Desktop: 2.0 (wider for landscape)
  static double getGraphAspectRatio(BuildContext context) {
    switch (getScreenSize(context)) {
      case ScreenSize.mobile:
        return 1.5;
      case ScreenSize.tablet:
        return 1.8;
      case ScreenSize.desktop:
        return 2.0;
    }
  }

  /// Check if screen is mobile
  static bool isMobile(BuildContext context) {
    return getScreenSize(context) == ScreenSize.mobile;
  }

  /// Check if screen is tablet
  static bool isTablet(BuildContext context) {
    return getScreenSize(context) == ScreenSize.tablet;
  }

  /// Check if screen is desktop
  static bool isDesktop(BuildContext context) {
    return getScreenSize(context) == ScreenSize.desktop;
  }

  /// Check if screen is tablet or desktop (i.e., not mobile)
  static bool isTabletOrDesktop(BuildContext context) {
    return !isMobile(context);
  }
}
