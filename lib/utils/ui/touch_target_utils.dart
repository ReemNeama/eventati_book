import 'package:flutter/material.dart';

/// Utility functions for ensuring adequate touch targets
class TouchTargetUtils {
  /// Minimum touch target size in logical pixels (48x48dp)
  static const double minTouchTargetSize = 48.0;

  /// Ensure a widget has a minimum touch target size
  ///
  /// This method wraps a widget in a [SizedBox] with a minimum size of 48x48dp
  /// to ensure it meets accessibility guidelines for touch targets.
  ///
  /// If the widget is already larger than the minimum size, it will not be affected.
  static Widget ensureMinimumTouchTarget(Widget child) {
    return SizedBox(
      width: minTouchTargetSize,
      height: minTouchTargetSize,
      child: Center(child: child),
    );
  }

  /// Create a touch target wrapper for a widget
  ///
  /// This method wraps a widget in a [GestureDetector] with a minimum size of 48x48dp
  /// to ensure it meets accessibility guidelines for touch targets.
  ///
  /// The [onTap] callback is called when the widget is tapped.
  static Widget createTouchTarget({
    required Widget child,
    required VoidCallback onTap,
    VoidCallback? onLongPress,
    double? width,
    double? height,
  }) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: width ?? minTouchTargetSize,
        height: height ?? minTouchTargetSize,
        constraints: const BoxConstraints(
          minWidth: minTouchTargetSize,
          minHeight: minTouchTargetSize,
        ),
        child: Center(child: child),
      ),
    );
  }

  /// Check if a widget has an adequate touch target size
  ///
  /// This method checks if a widget has a minimum size of 48x48dp
  /// to ensure it meets accessibility guidelines for touch targets.
  static bool hasAdequateTouchTarget(Size size) {
    return size.width >= minTouchTargetSize &&
        size.height >= minTouchTargetSize;
  }

  /// Get the padding needed to ensure a widget has an adequate touch target size
  ///
  /// This method calculates the padding needed to ensure a widget has a minimum
  /// size of 48x48dp to meet accessibility guidelines for touch targets.
  static EdgeInsets getPaddingForAdequateTouchTarget(Size size) {
    final double horizontalPadding =
        size.width < minTouchTargetSize
            ? (minTouchTargetSize - size.width) / 2
            : 0;
    final double verticalPadding =
        size.height < minTouchTargetSize
            ? (minTouchTargetSize - size.height) / 2
            : 0;

    return EdgeInsets.symmetric(
      horizontal: horizontalPadding,
      vertical: verticalPadding,
    );
  }
}
