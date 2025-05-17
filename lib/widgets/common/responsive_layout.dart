import 'package:flutter/material.dart';
import 'package:eventati_book/utils/ui/responsive_constants.dart';

/// A widget that displays different layouts based on screen size
///
/// This widget helps create responsive layouts by providing different
/// widgets for mobile, tablet, and desktop screen sizes.
///
/// Example usage:
/// ```dart
/// ResponsiveLayout(
///   mobileLayout: MobileHomeScreen(),
///   tabletLayout: TabletHomeScreen(),
///   desktopLayout: DesktopHomeScreen(),
/// )
/// ```
class ResponsiveLayout extends StatelessWidget {
  /// The layout to display on mobile devices
  final Widget mobileLayout;

  /// The layout to display on tablet devices
  final Widget? tabletLayout;

  /// The layout to display on desktop devices
  final Widget? desktopLayout;

  /// Creates a responsive layout widget
  ///
  /// The [mobileLayout] parameter is required and will be used as a fallback
  /// if a specific layout for the current screen size is not provided.
  const ResponsiveLayout({
    super.key,
    required this.mobileLayout,
    this.tabletLayout,
    this.desktopLayout,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        // Desktop layout
        if (width >= ResponsiveConstants.desktopBreakpoint) {
          return desktopLayout ?? tabletLayout ?? mobileLayout;
        }

        // Tablet layout
        if (width >= ResponsiveConstants.mobileBreakpoint) {
          return tabletLayout ?? mobileLayout;
        }

        // Mobile layout
        return mobileLayout;
      },
    );
  }
}

/// A widget that displays different layouts based on screen size and orientation
///
/// This widget extends the functionality of [ResponsiveLayout] by also
/// considering the device orientation.
///
/// Example usage:
/// ```dart
/// OrientationResponsiveLayout(
///   portraitMobileLayout: PortraitMobileHomeScreen(),
///   landscapeMobileLayout: LandscapeMobileHomeScreen(),
///   portraitTabletLayout: PortraitTabletHomeScreen(),
///   landscapeTabletLayout: LandscapeTabletHomeScreen(),
/// )
/// ```
class OrientationResponsiveLayout extends StatelessWidget {
  /// The layout to display on mobile devices in portrait orientation
  final Widget portraitMobileLayout;

  /// The layout to display on mobile devices in landscape orientation
  final Widget? landscapeMobileLayout;

  /// The layout to display on tablet devices in portrait orientation
  final Widget? portraitTabletLayout;

  /// The layout to display on tablet devices in landscape orientation
  final Widget? landscapeTabletLayout;

  /// The layout to display on desktop devices in portrait orientation
  final Widget? portraitDesktopLayout;

  /// The layout to display on desktop devices in landscape orientation
  final Widget? landscapeDesktopLayout;

  /// Creates an orientation-aware responsive layout widget
  ///
  /// The [portraitMobileLayout] parameter is required and will be used as a fallback
  /// if a specific layout for the current screen size and orientation is not provided.
  const OrientationResponsiveLayout({
    super.key,
    required this.portraitMobileLayout,
    this.landscapeMobileLayout,
    this.portraitTabletLayout,
    this.landscapeTabletLayout,
    this.portraitDesktopLayout,
    this.landscapeDesktopLayout,
  });

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (context, orientation) {
        final isPortrait = orientation == Orientation.portrait;

        return LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;

            // Desktop layout
            if (width >= ResponsiveConstants.desktopBreakpoint) {
              if (isPortrait) {
                return portraitDesktopLayout ??
                    portraitTabletLayout ??
                    portraitMobileLayout;
              } else {
                return landscapeDesktopLayout ??
                    landscapeTabletLayout ??
                    landscapeMobileLayout ??
                    portraitDesktopLayout ??
                    portraitTabletLayout ??
                    portraitMobileLayout;
              }
            }

            // Tablet layout
            if (width >= ResponsiveConstants.mobileBreakpoint) {
              if (isPortrait) {
                return portraitTabletLayout ?? portraitMobileLayout;
              } else {
                return landscapeTabletLayout ??
                    landscapeMobileLayout ??
                    portraitTabletLayout ??
                    portraitMobileLayout;
              }
            }

            // Mobile layout
            if (isPortrait) {
              return portraitMobileLayout;
            } else {
              return landscapeMobileLayout ?? portraitMobileLayout;
            }
          },
        );
      },
    );
  }
}

/// A widget that provides responsive padding based on screen size
class ResponsivePadding extends StatelessWidget {
  /// The child widget to wrap with responsive padding
  final Widget child;

  /// Custom padding for mobile devices (optional)
  final EdgeInsets? mobilePadding;

  /// Custom padding for tablet devices (optional)
  final EdgeInsets? tabletPadding;

  /// Custom padding for desktop devices (optional)
  final EdgeInsets? desktopPadding;

  /// Creates a responsive padding widget
  ///
  /// If specific padding values are not provided, default values from
  /// [ResponsiveConstants] will be used.
  const ResponsivePadding({
    super.key,
    required this.child,
    this.mobilePadding,
    this.tabletPadding,
    this.desktopPadding,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        EdgeInsets padding;

        // Desktop padding
        if (width >= ResponsiveConstants.desktopBreakpoint) {
          padding = desktopPadding ??
              tabletPadding ??
              mobilePadding ??
              const EdgeInsets.all(ResponsiveConstants.desktopPadding);
        }
        // Tablet padding
        else if (width >= ResponsiveConstants.mobileBreakpoint) {
          padding = tabletPadding ??
              mobilePadding ??
              const EdgeInsets.all(ResponsiveConstants.tabletPadding);
        }
        // Mobile padding
        else {
          padding = mobilePadding ??
              const EdgeInsets.all(ResponsiveConstants.mobilePadding);
        }

        return Padding(
          padding: padding,
          child: child,
        );
      },
    );
  }
}

/// A widget that provides a responsive container with max width constraints
class ResponsiveContainer extends StatelessWidget {
  /// The child widget to wrap
  final Widget child;

  /// Maximum width for mobile devices (optional)
  final double? mobileMaxWidth;

  /// Maximum width for tablet devices (optional)
  final double? tabletMaxWidth;

  /// Maximum width for desktop devices (optional)
  final double? desktopMaxWidth;

  /// Whether to center the child horizontally
  final bool centerHorizontally;

  /// Creates a responsive container widget
  ///
  /// If specific max width values are not provided, default values will be used.
  const ResponsiveContainer({
    super.key,
    required this.child,
    this.mobileMaxWidth,
    this.tabletMaxWidth,
    this.desktopMaxWidth,
    this.centerHorizontally = true,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        double maxWidth;

        // Desktop max width
        if (width >= ResponsiveConstants.desktopBreakpoint) {
          maxWidth = desktopMaxWidth ??
              tabletMaxWidth ??
              mobileMaxWidth ??
              ResponsiveConstants.maxContentWidth;
        }
        // Tablet max width
        else if (width >= ResponsiveConstants.mobileBreakpoint) {
          maxWidth = tabletMaxWidth ??
              mobileMaxWidth ??
              ResponsiveConstants.tabletBreakpoint;
        }
        // Mobile max width
        else {
          maxWidth = mobileMaxWidth ?? width;
        }

        Widget container = Container(
          constraints: BoxConstraints(
            maxWidth: maxWidth,
          ),
          child: child,
        );

        if (centerHorizontally) {
          return Center(child: container);
        }

        return container;
      },
    );
  }
}
