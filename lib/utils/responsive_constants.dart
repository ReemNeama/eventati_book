import 'package:flutter/material.dart';

/// Constants for responsive design
class ResponsiveConstants {
  /// Breakpoint for mobile devices (0-599)
  static const double mobileBreakpoint = 600;
  
  /// Breakpoint for tablet devices (600-959)
  static const double tabletBreakpoint = 960;
  
  /// Breakpoint for desktop devices (960+)
  static const double desktopBreakpoint = 1280;
  
  /// Minimum width for small mobile devices
  static const double smallMobileWidth = 320;
  
  /// Maximum content width for desktop
  static const double maxContentWidth = 1200;
  
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
  
  /// Get the number of grid columns based on device type
  static int getGridColumns(BuildContext context) {
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
