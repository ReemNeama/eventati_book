import 'package:flutter/material.dart';

/// A widget that provides different layouts based on screen size.
///
/// This widget helps create responsive UIs by showing different layouts
/// for mobile, tablet, and desktop screen sizes.
class ResponsiveLayout extends StatelessWidget {
  /// The layout to show on mobile devices (small screens).
  final Widget mobile;

  /// The layout to show on tablet devices (medium screens).
  /// If null, the mobile layout will be used.
  final Widget? tablet;

  /// The layout to show on desktop devices (large screens).
  /// If null, the tablet layout will be used if available, otherwise the mobile layout.
  final Widget? desktop;

  /// The breakpoint for mobile to tablet transition (default: 600).
  final double tabletBreakpoint;

  /// The breakpoint for tablet to desktop transition (default: 900).
  final double desktopBreakpoint;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
    this.tabletBreakpoint = 600,
    this.desktopBreakpoint = 900,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    // Desktop layout
    if (size.shortestSide >= desktopBreakpoint && desktop != null) {
      return desktop!;
    }

    // Tablet layout
    if (size.shortestSide >= tabletBreakpoint && tablet != null) {
      return tablet!;
    }

    // Mobile layout (default)
    return mobile;
  }

  /// Check if the current device is a mobile device.
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.shortestSide < 600;
  }

  /// Check if the current device is a tablet.
  static bool isTablet(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return size.shortestSide >= 600 && size.shortestSide < 900;
  }

  /// Check if the current device is a desktop.
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.shortestSide >= 900;
  }
}
