import 'package:flutter/material.dart';
import 'package:eventati_book/styles/text_styles.dart';
import 'package:eventati_book/utils/ui/ui_utils.dart';

/// A button for quick actions on the homepage
class QuickActionButton extends StatelessWidget {
  /// The label to display
  final String label;

  /// The icon to display
  final IconData icon;

  /// The color of the icon
  final Color? iconColor;

  /// The background color of the button
  final Color? backgroundColor;

  /// The function to call when the button is tapped
  final VoidCallback onTap;

  /// The size of the button
  final double size;

  /// The size of the icon
  final double iconSize;

  /// The style of the label
  final TextStyle? labelStyle;

  /// The tooltip text for accessibility
  final String? tooltip;

  /// Whether to show a badge
  final bool showBadge;

  /// The badge count
  final int badgeCount;

  /// The color of the badge
  final Color? badgeColor;

  /// Constructor
  const QuickActionButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onTap,
    this.iconColor,
    this.backgroundColor,
    this.size = 80.0,
    this.iconSize = 32.0,
    this.labelStyle,
    this.tooltip,
    this.showBadge = false,
    this.badgeCount = 0,
    this.badgeColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = UIUtils.isDarkMode(context);

    // Default colors
    final defaultIconColor = iconColor ?? theme.primaryColor;
    final defaultBackgroundColor =
        backgroundColor ??
        (isDarkMode ? theme.colorScheme.surface : Colors.white);
    final defaultLabelStyle =
        labelStyle ??
        TextStyles.bodySmall.copyWith(fontWeight: FontWeight.bold);
    final defaultBadgeColor = badgeColor ?? theme.colorScheme.error;

    // Build the button
    Widget button = InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: defaultBackgroundColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.1),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon
            Icon(icon, size: iconSize, color: defaultIconColor),
            const SizedBox(height: 8),
            // Label
            Text(
              label,
              style: defaultLabelStyle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );

    // Add badge if needed
    if (showBadge) {
      button = Stack(
        children: [
          button,
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: defaultBadgeColor,
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
              child: Center(
                child: Text(
                  badgeCount > 99 ? '99+' : badgeCount.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    }

    // Add tooltip if provided
    if (tooltip != null) {
      button = Tooltip(message: tooltip!, child: button);
    }

    return button;
  }
}
