import 'package:flutter/material.dart';
import 'package:eventati_book/styles/app_colors.dart';

/// A widget that shows a visual indicator for field completion status
class FieldCompletionIndicator extends StatelessWidget {
  /// Whether the field is completed
  final bool isCompleted;

  /// Size of the indicator
  final double size;

  /// Color of the indicator when completed
  final Color? completedColor;

  /// Color of the indicator when not completed
  final Color? incompleteColor;

  /// Icon to show when completed
  final IconData completedIcon;

  /// Icon to show when not completed
  final IconData incompleteIcon;

  /// Whether to show the incomplete state
  final bool showIncomplete;

  /// Tooltip text for the indicator
  final String? tooltip;

  /// Creates a field completion indicator
  const FieldCompletionIndicator({
    super.key,
    required this.isCompleted,
    this.size = 16.0,
    this.completedColor,
    this.incompleteColor,
    this.completedIcon = Icons.check_circle,
    this.incompleteIcon = Icons.circle_outlined,
    this.showIncomplete = true,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    const defaultCompletedColor = AppColors.success;
    final defaultIncompleteColor = Color.fromRGBO(
      AppColors.disabled.r.toInt(),
      AppColors.disabled.g.toInt(),
      AppColors.disabled.b.toInt(),
      0.6,
    );

    // If not completed and we don't want to show incomplete state, return empty container
    if (!isCompleted && !showIncomplete) {
      return const SizedBox.shrink();
    }

    final icon = isCompleted ? completedIcon : incompleteIcon;
    final color =
        isCompleted
            ? (completedColor ?? defaultCompletedColor)
            : (incompleteColor ?? defaultIncompleteColor);

    final indicatorWidget = Icon(icon, size: size, color: color);

    // If tooltip is provided, wrap in tooltip widget
    if (tooltip != null) {
      return Tooltip(message: tooltip!, child: indicatorWidget);
    }

    return indicatorWidget;
  }
}
