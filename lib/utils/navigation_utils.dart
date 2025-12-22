import 'package:flutter/material.dart';
import 'constrained_modal_route.dart';

/// Navigation utilities for consistent routing patterns
///
/// Provides helper methods for pushing screens with appropriate route types.
class NavigationUtils {
  /// Push a configuration screen with automatic responsive constraints
  ///
  /// On tablet/desktop (≥600px width):
  /// - Constrained to 600px max width
  /// - Centered with blurred background
  /// - Elevated with shadow and rounded corners
  ///
  /// On mobile (<600px width):
  /// - Full width (standard behavior)
  ///
  /// Example:
  /// ```dart
  /// final result = await NavigationUtils.pushConfigurationScreen(
  ///   context,
  ///   PowerLimitScreen(device: device, ...),
  /// );
  /// ```
  ///
  /// Returns the result from the pushed screen (via Navigator.pop).
  static Future<T?> pushConfigurationScreen<T>(
    BuildContext context,
    Widget screen,
  ) {
    return Navigator.push<T>(
      context,
      ConstrainedModalRoute<T>(
        builder: (context) => screen,
      ),
    );
  }

  /// Push a standard full-screen page (non-configuration)
  ///
  /// Uses standard MaterialPageRoute without constraints.
  ///
  /// Example:
  /// ```dart
  /// await NavigationUtils.push(
  ///   context,
  ///   DeviceDetailScreen(device: device),
  /// );
  /// ```
  static Future<T?> push<T>(
    BuildContext context,
    Widget screen,
  ) {
    return Navigator.push<T>(
      context,
      MaterialPageRoute<T>(
        builder: (context) => screen,
      ),
    );
  }
}
