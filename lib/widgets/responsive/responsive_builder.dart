import 'package:flutter/material.dart';

/// A utility widget for building responsive UIs.
///
/// This widget makes it easy to build responsive UIs by providing
/// different builder functions for different screen sizes.
class ResponsiveBuilder extends StatelessWidget {
  /// Builder function for mobile devices (small screens).
  final Widget Function(BuildContext context, BoxConstraints constraints)
  mobileBuilder;

  /// Builder function for tablet devices (medium screens).
  /// If null, the mobile builder will be used.
  final Widget Function(BuildContext context, BoxConstraints constraints)?
  tabletBuilder;

  /// Builder function for desktop devices (large screens).
  /// If null, the tablet builder will be used if available, otherwise the mobile builder.
  final Widget Function(BuildContext context, BoxConstraints constraints)?
  desktopBuilder;

  /// The breakpoint for mobile to tablet transition (default: 600).
  final double tabletBreakpoint;

  /// The breakpoint for tablet to desktop transition (default: 900).
  final double desktopBreakpoint;

  const ResponsiveBuilder({
    super.key,
    required this.mobileBuilder,
    this.tabletBuilder,
    this.desktopBuilder,
    this.tabletBreakpoint = 600,
    this.desktopBreakpoint = 900,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Desktop layout
        if (constraints.maxWidth >= desktopBreakpoint &&
            desktopBuilder != null) {
          // Store the non-null builder in a local variable
          final builder = desktopBuilder;
          // Use null-aware method invocation operator
          return builder?.call(context, constraints) ??
              mobileBuilder(context, constraints);
        }

        // Tablet layout
        if (constraints.maxWidth >= tabletBreakpoint && tabletBuilder != null) {
          // Store the non-null builder in a local variable
          final builder = tabletBuilder;
          // Use null-aware method invocation operator
          return builder?.call(context, constraints) ??
              mobileBuilder(context, constraints);
        }

        // Mobile layout (default)
        return mobileBuilder(context, constraints);
      },
    );
  }
}

/// A utility widget for building responsive UIs based on orientation.
///
/// This widget makes it easy to build responsive UIs by providing
/// different builder functions for portrait and landscape orientations.
class OrientationResponsiveBuilder extends StatelessWidget {
  /// Builder function for portrait orientation.
  final Widget Function(BuildContext context, BoxConstraints constraints)
  portraitBuilder;

  /// Builder function for landscape orientation.
  /// If null, the portrait builder will be used.
  final Widget Function(BuildContext context, BoxConstraints constraints)?
  landscapeBuilder;

  const OrientationResponsiveBuilder({
    super.key,
    required this.portraitBuilder,
    this.landscapeBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (context, orientation) {
        return LayoutBuilder(
          builder: (context, constraints) {
            if (orientation == Orientation.landscape &&
                landscapeBuilder != null) {
              // Store the non-null builder in a local variable
              final builder = landscapeBuilder;
              // Use null-aware method invocation operator
              return builder?.call(context, constraints) ??
                  portraitBuilder(context, constraints);
            }

            return portraitBuilder(context, constraints);
          },
        );
      },
    );
  }
}
