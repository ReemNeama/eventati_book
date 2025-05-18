import 'package:flutter/material.dart';
import 'package:eventati_book/styles/app_colors.dart';
import 'package:eventati_book/utils/ui/ui_utils.dart';

/// Enum for tooltip styles
enum TooltipStyle {
  /// Informational tooltip (blue)
  info,

  /// Warning tooltip (orange)
  warning,

  /// Error tooltip (red)
  error,

  /// Success tooltip (green)
  success,
}

/// Utility functions for tooltips
class TooltipUtils {
  /// Create a tooltip with the given message
  static Widget tooltip({
    required String message,
    required Widget child,
    TooltipStyle style = TooltipStyle.info,
    Duration? waitDuration,
    Duration? showDuration,
    double? height,
    EdgeInsetsGeometry? padding,
    TextStyle? textStyle,
    Decoration? decoration,
    bool preferBelow = true,
    bool excludeFromSemantics = false,
  }) {
    return Builder(
      builder: (context) {
        return Tooltip(
          message: message,
          waitDuration: waitDuration ?? const Duration(milliseconds: 500),
          showDuration: showDuration ?? const Duration(seconds: 2),
          height: height,
          padding:
              padding ??
              const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
          textStyle: textStyle ?? getTooltipTextStyle(context),
          decoration: decoration ?? getTooltipDecoration(context, style),
          preferBelow: preferBelow,
          excludeFromSemantics: excludeFromSemantics,
          child: child,
        );
      },
    );
  }

  /// Create an info tooltip
  static Widget infoTooltip({
    required String message,
    required Widget child,
    Duration? waitDuration,
    Duration? showDuration,
    double? height,
    EdgeInsetsGeometry? padding,
    TextStyle? textStyle,
    Decoration? decoration,
    bool preferBelow = true,
    bool excludeFromSemantics = false,
  }) {
    return tooltip(
      message: message,
      child: child,
      style: TooltipStyle.info,
      waitDuration: waitDuration,
      showDuration: showDuration,
      height: height,
      padding: padding,
      textStyle: textStyle,
      decoration: decoration,
      preferBelow: preferBelow,
      excludeFromSemantics: excludeFromSemantics,
    );
  }

  /// Create a warning tooltip
  static Widget warningTooltip({
    required String message,
    required Widget child,
    Duration? waitDuration,
    Duration? showDuration,
    double? height,
    EdgeInsetsGeometry? padding,
    TextStyle? textStyle,
    Decoration? decoration,
    bool preferBelow = true,
    bool excludeFromSemantics = false,
  }) {
    return tooltip(
      message: message,
      child: child,
      style: TooltipStyle.warning,
      waitDuration: waitDuration,
      showDuration: showDuration,
      height: height,
      padding: padding,
      textStyle: textStyle,
      decoration: decoration,
      preferBelow: preferBelow,
      excludeFromSemantics: excludeFromSemantics,
    );
  }

  /// Create an error tooltip
  static Widget errorTooltip({
    required String message,
    required Widget child,
    Duration? waitDuration,
    Duration? showDuration,
    double? height,
    EdgeInsetsGeometry? padding,
    TextStyle? textStyle,
    Decoration? decoration,
    bool preferBelow = true,
    bool excludeFromSemantics = false,
  }) {
    return tooltip(
      message: message,
      child: child,
      style: TooltipStyle.error,
      waitDuration: waitDuration,
      showDuration: showDuration,
      height: height,
      padding: padding,
      textStyle: textStyle,
      decoration: decoration,
      preferBelow: preferBelow,
      excludeFromSemantics: excludeFromSemantics,
    );
  }

  /// Create a success tooltip
  static Widget successTooltip({
    required String message,
    required Widget child,
    Duration? waitDuration,
    Duration? showDuration,
    double? height,
    EdgeInsetsGeometry? padding,
    TextStyle? textStyle,
    Decoration? decoration,
    bool preferBelow = true,
    bool excludeFromSemantics = false,
  }) {
    return tooltip(
      message: message,
      child: child,
      style: TooltipStyle.success,
      waitDuration: waitDuration,
      showDuration: showDuration,
      height: height,
      padding: padding,
      textStyle: textStyle,
      decoration: decoration,
      preferBelow: preferBelow,
      excludeFromSemantics: excludeFromSemantics,
    );
  }

  /// Get the decoration for a tooltip based on the style
  static Decoration getTooltipDecoration(
    BuildContext context,
    TooltipStyle style,
  ) {
    final theme = Theme.of(context);
    final isDarkMode = UIUtils.isDarkMode(context);

    Color backgroundColor;
    switch (style) {
      case TooltipStyle.info:
        final primaryColor = theme.primaryColor;
        backgroundColor =
            isDarkMode
                ? primaryColor.withAlpha(230)
                : primaryColor.withAlpha(204);
        break;
      case TooltipStyle.warning:
        final warningColor = Color.fromRGBO(
          AppColors.warning.r.toInt(),
          AppColors.warning.g.toInt(),
          AppColors.warning.b.toInt(),
          1.0,
        );
        backgroundColor =
            isDarkMode
                ? warningColor.withAlpha(230)
                : warningColor.withAlpha(204);
        break;
      case TooltipStyle.error:
        final errorColor = Color.fromRGBO(
          AppColors.error.r.toInt(),
          AppColors.error.g.toInt(),
          AppColors.error.b.toInt(),
          1.0,
        );
        backgroundColor =
            isDarkMode ? errorColor.withAlpha(230) : errorColor.withAlpha(204);
        break;
      case TooltipStyle.success:
        final successColor = Color.fromRGBO(
          AppColors.success.r.toInt(),
          AppColors.success.g.toInt(),
          AppColors.success.b.toInt(),
          1.0,
        );
        backgroundColor =
            isDarkMode
                ? successColor.withAlpha(230)
                : successColor.withAlpha(204);
        break;
    }

    return BoxDecoration(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(4),
    );
  }

  /// Get the text style for a tooltip
  static TextStyle getTooltipTextStyle(BuildContext context) {
    return const TextStyle(color: Colors.white, fontSize: 14);
  }
}
