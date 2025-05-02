import 'package:flutter/material.dart';

/// Device type enum for responsive design
enum DeviceType {
  /// Mobile phone (small screen)
  mobile,
  
  /// Tablet (medium screen)
  tablet,
  
  /// Desktop (large screen)
  desktop,
}

/// Utility functions for responsive design
class ResponsiveUtils {
  /// Breakpoint for mobile devices (0-599)
  static const double mobileBreakpoint = 600;
  
  /// Breakpoint for tablet devices (600-959)
  static const double tabletBreakpoint = 960;
  
  /// Breakpoint for desktop devices (960+)
  static const double desktopBreakpoint = 1280;

  /// Get the device type based on screen width
  static DeviceType getDeviceType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return getDeviceTypeFromWidth(width);
  }

  /// Get the device type based on a specific width
  static DeviceType getDeviceTypeFromWidth(double width) {
    if (width < mobileBreakpoint) {
      return DeviceType.mobile;
    } else if (width < desktopBreakpoint) {
      return DeviceType.tablet;
    } else {
      return DeviceType.desktop;
    }
  }

  /// Get the number of columns for a grid based on screen width
  static int getColumnCount(BuildContext context) {
    final deviceType = getDeviceType(context);
    
    switch (deviceType) {
      case DeviceType.mobile:
        return 1;
      case DeviceType.tablet:
        return 2;
      case DeviceType.desktop:
        return 3;
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

  /// Get a responsive padding based on device type
  static EdgeInsets getResponsivePadding(BuildContext context) {
    final deviceType = getDeviceType(context);
    
    switch (deviceType) {
      case DeviceType.mobile:
        return const EdgeInsets.all(16.0);
      case DeviceType.tablet:
        return const EdgeInsets.all(24.0);
      case DeviceType.desktop:
        return const EdgeInsets.all(32.0);
    }
  }

  /// Get a responsive font size based on device type
  static double getResponsiveFontSize(
    BuildContext context, {
    required double mobile,
    required double tablet,
    double? desktop,
  }) {
    return getResponsiveValue(
      context: context,
      mobile: mobile,
      tablet: tablet,
      desktop: desktop,
    );
  }

  /// Get a responsive icon size based on device type
  static double getResponsiveIconSize(BuildContext context) {
    return getResponsiveValue(
      context: context,
      mobile: 24.0,
      tablet: 28.0,
      desktop: 32.0,
    );
  }

  /// Check if the device is in landscape orientation
  static bool isLandscape(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }

  /// Check if the device is in portrait orientation
  static bool isPortrait(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.portrait;
  }

  /// Get the screen width
  static double getScreenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  /// Get the screen height
  static double getScreenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  /// Get the screen size
  static Size getScreenSize(BuildContext context) {
    return MediaQuery.of(context).size;
  }

  /// Get the safe area padding
  static EdgeInsets getSafeAreaPadding(BuildContext context) {
    return MediaQuery.of(context).padding;
  }

  /// Calculate a responsive width based on screen width percentage
  static double getWidthPercentage(BuildContext context, double percentage) {
    return getScreenWidth(context) * (percentage / 100);
  }

  /// Calculate a responsive height based on screen height percentage
  static double getHeightPercentage(BuildContext context, double percentage) {
    return getScreenHeight(context) * (percentage / 100);
  }
}
