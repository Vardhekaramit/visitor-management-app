import 'package:flutter/material.dart';

/// Helper utility for Material 3 responsive & adaptive layouts.
class Responsive {
  Responsive._();

  static const double tabletBreakpoint = 640;
  static const double desktopBreakpoint = 1024;

  static bool isPhone(BuildContext context) =>
      MediaQuery.sizeOf(context).width < tabletBreakpoint;

  static bool isTablet(BuildContext context) {
    final double width = MediaQuery.sizeOf(context).width;
    return width >= tabletBreakpoint && width < desktopBreakpoint;
  }

  static bool isTabletOrLarger(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= tabletBreakpoint;

  static double horizontalPadding(BuildContext context) {
    final double width = MediaQuery.sizeOf(context).width;
    if (width >= desktopBreakpoint) return 32;
    if (width >= tabletBreakpoint) return 24;
    return 16;
  }

  /// Wraps content in a centered container with optimal reading max-width
  /// on tablets and large screens to avoid awkwardly stretched UI elements.
  static Widget constrainedContainer({
    required BuildContext context,
    required Widget child,
    double maxWidth = 800,
  }) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}
