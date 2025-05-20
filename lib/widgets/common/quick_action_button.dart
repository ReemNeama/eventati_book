import 'package:flutter/material.dart';
import 'package:eventati_book/styles/app_colors.dart';
import 'package:eventati_book/styles/app_colors_dark.dart';
import 'package:eventati_book/utils/utils.dart';

/// A small, compact button for quick actions in cards and lists
class QuickActionButton extends StatelessWidget {
  /// The icon to display
  final IconData icon;

  /// The action to perform when pressed
  final VoidCallback onPressed;

  /// Optional tooltip text
  final String? tooltip;

  /// Whether the button is in an active/selected state
  final bool isActive;

  /// Custom color for the active state
  final Color? activeColor;

  /// Custom color for the inactive state
  final Color? inactiveColor;

  /// Custom size for the icon
  final double iconSize;

  /// Label text to show next to the icon (optional)
  final String? label;

  /// Constructor
  const QuickActionButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.isActive = false,
    this.activeColor,
    this.inactiveColor,
    this.iconSize = 20,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = UIUtils.isDarkMode(context);

    final defaultActiveColor =
        activeColor ?? (isDarkMode ? AppColorsDark.primary : AppColors.primary);

    final defaultInactiveColor =
        inactiveColor ??
        (isDarkMode ? AppColorsDark.textSecondary : AppColors.textSecondary);

    final buttonColor = isActive ? defaultActiveColor : defaultInactiveColor;

    Widget buttonContent = Icon(icon, color: buttonColor, size: iconSize);

    // Add label if provided
    if (label != null) {
      buttonContent = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          buttonContent,
          const SizedBox(width: 4),
          Text(
            label!,
            style: TextStyle(
              color: buttonColor,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              fontSize: 12,
            ),
          ),
        ],
      );
    }

    return Tooltip(
      message: tooltip ?? '',
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: buttonContent,
        ),
      ),
    );
  }
}
