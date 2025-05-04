import 'package:flutter/material.dart';
import 'package:eventati_book/utils/responsive_constants.dart';

/// Utility functions for responsive design
class ResponsiveUtils {
  /// Get the device type based on screen width
  static DeviceType getDeviceType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return getDeviceTypeFromWidth(width);
  }

  /// Get the device type based on a specific width
  static DeviceType getDeviceTypeFromWidth(double width) {
    if (width < ResponsiveConstants.mobileBreakpoint) {
      return DeviceType.mobile;
    } else if (width < ResponsiveConstants.desktopBreakpoint) {
      return DeviceType.tablet;
    } else {
      return DeviceType.desktop;
    }
  }

  /// Get the number of columns for a grid based on screen width
  static int getColumnCount(BuildContext context) {
    return ResponsiveConstants.getGridColumns(context);
  }

  /// Get a responsive value based on device type
  static T getResponsiveValue<T>({
    required BuildContext context,
    required T mobile,
    required T tablet,
    T? desktop,
  }) {
    return ResponsiveConstants.getResponsiveValue(
      context: context,
      mobile: mobile,
      tablet: tablet,
      desktop: desktop,
    );
  }

  /// Get a responsive padding based on device type
  static EdgeInsets getResponsivePadding(BuildContext context) {
    return ResponsiveConstants.getPadding(context);
  }

  /// Get a responsive font size based on device type
  static double getResponsiveFontSize(
    BuildContext context, {
    required double mobile,
    required double tablet,
    double? desktop,
  }) {
    return ResponsiveConstants.getResponsiveValue(
      context: context,
      mobile: mobile,
      tablet: tablet,
      desktop: desktop,
    );
  }

  /// Get a responsive icon size based on device type
  static double getResponsiveIconSize(BuildContext context) {
    return ResponsiveConstants.getResponsiveValue(
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

  /// Check if the device is a tablet or larger
  static bool isTabletOrLarger(BuildContext context) {
    final deviceType = getDeviceType(context);
    return deviceType == DeviceType.tablet || deviceType == DeviceType.desktop;
  }

  /// Calculate a responsive height based on screen height percentage
  static double getHeightPercentage(BuildContext context, double percentage) {
    return getScreenHeight(context) * (percentage / 100);
  }
}
