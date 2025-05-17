import 'package:flutter/material.dart';

/// Constants for responsive design
class ResponsiveConstants {
  // =========================================================
  // SCREEN SIZE BREAKPOINTS
  // =========================================================

  /// Breakpoint for small mobile devices (0-359)
  static const double smallMobileBreakpoint = 360;

  /// Breakpoint for medium mobile devices (360-399)
  static const double mediumMobileBreakpoint = 400;

  /// Breakpoint for large mobile devices (400-599)
  static const double largeMobileBreakpoint = 600;

  /// Breakpoint for mobile devices (0-599)
  static const double mobileBreakpoint = 600;

  /// Breakpoint for small tablet devices (600-767)
  static const double smallTabletBreakpoint = 768;

  /// Breakpoint for medium tablet devices (768-959)
  static const double mediumTabletBreakpoint = 960;

  /// Breakpoint for large tablet devices (960-1023)
  static const double largeTabletBreakpoint = 1024;

  /// Breakpoint for tablet devices (600-1023)
  static const double tabletBreakpoint = 1024;

  /// Breakpoint for small desktop devices (1024-1279)
  static const double smallDesktopBreakpoint = 1280;

  /// Breakpoint for medium desktop devices (1280-1439)
  static const double mediumDesktopBreakpoint = 1440;

  /// Breakpoint for large desktop devices (1440+)
  static const double largeDesktopBreakpoint = 1920;

  /// Breakpoint for desktop devices (1024+)
  static const double desktopBreakpoint = 1024;

  /// Minimum width for small mobile devices
  static const double smallMobileWidth = 320;

  /// Maximum content width for desktop
  static const double maxContentWidth = 1200;

  // =========================================================
  // ORIENTATION-SPECIFIC CONSTANTS
  // =========================================================

  /// Maximum height for considering a device in landscape mode as "short"
  static const double shortLandscapeHeight = 480;

  /// Padding for landscape orientation on mobile
  static const EdgeInsets mobileLandscapePadding = EdgeInsets.symmetric(
    horizontal: 24.0,
    vertical: 12.0,
  );

  /// Padding for landscape orientation on tablet
  static const EdgeInsets tabletLandscapePadding = EdgeInsets.symmetric(
    horizontal: 32.0,
    vertical: 16.0,
  );

  /// Padding for landscape orientation on desktop
  static const EdgeInsets desktopLandscapePadding = EdgeInsets.symmetric(
    horizontal: 48.0,
    vertical: 24.0,
  );

  /// Grid columns for landscape orientation on mobile
  static const int mobileLandscapeGridColumns = 2;

  /// Grid columns for landscape orientation on tablet
  static const int tabletLandscapeGridColumns = 3;

  /// Grid columns for landscape orientation on desktop
  static const int desktopLandscapeGridColumns = 4;

  /// Standard padding for mobile
  static const double mobilePadding = 16.0;

  /// Standard padding for tablet
  static const double tabletPadding = 24.0;

  /// Standard padding for desktop
  static const double desktopPadding = 32.0;

  /// Font size for small text on mobile
  static const double mobileSmallText = 12.0;

  /// Font size for body text on mobile
  static const double mobileBodyText = 14.0;

  /// Font size for title text on mobile
  static const double mobileTitleText = 18.0;

  /// Font size for heading text on mobile
  static const double mobileHeadingText = 22.0;

  /// Font size for small text on tablet
  static const double tabletSmallText = 14.0;

  /// Font size for body text on tablet
  static const double tabletBodyText = 16.0;

  /// Font size for title text on tablet
  static const double tabletTitleText = 20.0;

  /// Font size for heading text on tablet
  static const double tabletHeadingText = 24.0;

  /// Font size for small text on desktop
  static const double desktopSmallText = 14.0;

  /// Font size for body text on desktop
  static const double desktopBodyText = 16.0;

  /// Font size for title text on desktop
  static const double desktopTitleText = 22.0;

  /// Font size for heading text on desktop
  static const double desktopHeadingText = 28.0;

  /// Get the device type based on screen width
  static DeviceType getDeviceType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    if (width < mobileBreakpoint) {
      return DeviceType.mobile;
    } else if (width < desktopBreakpoint) {
      return DeviceType.tablet;
    } else {
      return DeviceType.desktop;
    }
  }

  /// Get the appropriate padding based on device type
  static EdgeInsets getPadding(BuildContext context) {
    final deviceType = getDeviceType(context);

    switch (deviceType) {
      case DeviceType.mobile:
        return const EdgeInsets.all(mobilePadding);
      case DeviceType.tablet:
        return const EdgeInsets.all(tabletPadding);
      case DeviceType.desktop:
        return const EdgeInsets.all(desktopPadding);
    }
  }

  /// Get the appropriate font size for body text based on device type
  static double getBodyTextSize(BuildContext context) {
    final deviceType = getDeviceType(context);

    switch (deviceType) {
      case DeviceType.mobile:
        return mobileBodyText;
      case DeviceType.tablet:
        return tabletBodyText;
      case DeviceType.desktop:
        return desktopBodyText;
    }
  }

  /// Get the appropriate font size for title text based on device type
  static double getTitleTextSize(BuildContext context) {
    final deviceType = getDeviceType(context);

    switch (deviceType) {
      case DeviceType.mobile:
        return mobileTitleText;
      case DeviceType.tablet:
        return tabletTitleText;
      case DeviceType.desktop:
        return desktopTitleText;
    }
  }

  /// Get the appropriate font size for heading text based on device type
  static double getHeadingTextSize(BuildContext context) {
    final deviceType = getDeviceType(context);

    switch (deviceType) {
      case DeviceType.mobile:
        return mobileHeadingText;
      case DeviceType.tablet:
        return tabletHeadingText;
      case DeviceType.desktop:
        return desktopHeadingText;
    }
  }

  /// Get the number of grid columns based on device type and orientation
  static int getGridColumns(BuildContext context) {
    final deviceType = getDeviceType(context);
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    if (isLandscape) {
      switch (deviceType) {
        case DeviceType.mobile:
          return mobileLandscapeGridColumns;
        case DeviceType.tablet:
          return tabletLandscapeGridColumns;
        case DeviceType.desktop:
          return desktopLandscapeGridColumns;
      }
    } else {
      switch (deviceType) {
        case DeviceType.mobile:
          return 1;
        case DeviceType.tablet:
          return 2;
        case DeviceType.desktop:
          return 3;
      }
    }
  }

  /// Get the appropriate padding based on device type and orientation
  static EdgeInsets getOrientationAwarePadding(BuildContext context) {
    final deviceType = getDeviceType(context);
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    if (isLandscape) {
      switch (deviceType) {
        case DeviceType.mobile:
          return mobileLandscapePadding;
        case DeviceType.tablet:
          return tabletLandscapePadding;
        case DeviceType.desktop:
          return desktopLandscapePadding;
      }
    } else {
      return getPadding(context);
    }
  }

  /// Check if the device is in a "short" landscape mode
  static bool isShortLandscape(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return mediaQuery.orientation == Orientation.landscape &&
        mediaQuery.size.height < shortLandscapeHeight;
  }

  /// Get a responsive value based on device type and orientation
  static T getOrientationAwareValue<T>({
    required BuildContext context,
    required T portraitMobile,
    required T portraitTablet,
    T? portraitDesktop,
    required T landscapeMobile,
    required T landscapeTablet,
    T? landscapeDesktop,
  }) {
    final deviceType = getDeviceType(context);
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    if (isLandscape) {
      switch (deviceType) {
        case DeviceType.mobile:
          return landscapeMobile;
        case DeviceType.tablet:
          return landscapeTablet;
        case DeviceType.desktop:
          return landscapeDesktop ?? landscapeTablet;
      }
    } else {
      switch (deviceType) {
        case DeviceType.mobile:
          return portraitMobile;
        case DeviceType.tablet:
          return portraitTablet;
        case DeviceType.desktop:
          return portraitDesktop ?? portraitTablet;
      }
    }
  }

  /// Get a responsive value based on device type
  static T getResponsiveValue<T>({
    required BuildContext context,
    required T mobile,
    required T tablet,
    T? desktop,
  }) {
    final deviceType = getDeviceType(context);

    switch (deviceType) {
      case DeviceType.mobile:
        return mobile;
      case DeviceType.tablet:
        return tablet;
      case DeviceType.desktop:
        return desktop ?? tablet;
    }
  }
}

/// Device type enum for responsive design
enum DeviceType {
  /// Mobile phone (small screen)
  mobile,

  /// Tablet (medium screen)
  tablet,

  /// Desktop (large screen)
  desktop,
}
