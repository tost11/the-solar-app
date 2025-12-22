import 'dart:ui';
import 'package:flutter/material.dart';
import 'responsive_breakpoints.dart';

/// Custom PageRoute that constrains width and blurs background on tablet/desktop
///
/// Usage:
/// ```dart
/// Navigator.push(
///   context,
///   ConstrainedModalRoute(
///     builder: (context) => ConfigurationScreen(),
///   ),
/// );
/// ```
///
/// Behavior:
/// - **Mobile (< 600px)**: Full width, standard MaterialPageRoute behavior
/// - **Tablet/Desktop (≥ 600px)**: Constrained to maxWidth, centered, with blurred background
///
/// Features:
/// - Blur effect using BackdropFilter
/// - Material elevation and shadow
/// - Rounded corners for polished look
/// - Maintains all standard navigation behaviors (back button, gestures, animations)
class ConstrainedModalRoute<T> extends PageRouteBuilder<T> {
  /// Maximum width of the constrained content (default: 600px)
  final double maxWidth;

  /// Blur intensity for background (default: 5.0 for medium blur)
  final double blurSigma;

  /// Builder for the page content
  final WidgetBuilder builder;

  ConstrainedModalRoute({
    required this.builder,
    RouteSettings? settings,
    this.maxWidth = 600.0,
    this.blurSigma = 5.0,
  }) : super(
          settings: settings,
          opaque: false, // Allow previous route to show through
          barrierDismissible: false,
          barrierColor: Colors.transparent,
          transitionDuration: const Duration(milliseconds: 300),
          pageBuilder: (context, animation, secondaryAnimation) {
            final page = builder(context);

            // On mobile, return page as-is (full width, no constraints)
            if (ResponsiveBreakpoints.isMobile(context)) {
              return page;
            }

            // On tablet/desktop: Apply constraints and blur effect
            return Stack(
              children: [
                // Blurred background showing previous screen
                Positioned.fill(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
                    child: Container(
                      color: Colors.black.withOpacity(0.3), // Subtle dark overlay
                    ),
                  ),
                ),

                // Centered constrained content with shadow
                Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: maxWidth,
                      maxHeight: MediaQuery.of(context).size.height,
                    ),
                    child: Material(
                      elevation: 8,
                      borderRadius: BorderRadius.circular(12),
                      clipBehavior: Clip.antiAlias,
                      child: page,
                    ),
                  ),
                ),
              ],
            );
          },
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            // Slide transition from right (like MaterialPageRoute)
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.easeInOut;

            var tween = Tween(begin: begin, end: end).chain(
              CurveTween(curve: curve),
            );

            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
        );
}
