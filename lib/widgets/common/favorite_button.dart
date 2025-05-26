import 'package:flutter/material.dart';
import 'package:eventati_book/styles/app_colors.dart';
import 'package:eventati_book/utils/ui/accessibility_utils.dart';

/// A button that toggles between favorite and not favorite states
class FavoriteButton extends StatelessWidget {
  /// Whether the item is currently favorited
  final bool isFavorite;

  /// Callback when the favorite status is toggled
  final VoidCallback onToggle;

  /// Size of the icon
  final double size;

  /// Color of the icon when favorited
  final Color? activeColor;

  /// Color of the icon when not favorited
  final Color? inactiveColor;

  /// Background color of the button
  final Color? backgroundColor;

  /// Whether to show a background
  final bool showBackground;

  /// Tooltip text
  final String? tooltip;

  /// Constructor
  const FavoriteButton({
    super.key,
    required this.isFavorite,
    required this.onToggle,
    this.size = 24.0,
    this.activeColor,
    this.inactiveColor,
    this.backgroundColor,
    this.showBackground = true,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const defaultActiveColor = AppColors.warning;
    final defaultInactiveColor =
        theme.brightness == Brightness.dark
            ? Colors.white
            : Colors.grey.shade700;

    final buttonActiveColor = activeColor ?? defaultActiveColor;
    final buttonInactiveColor = inactiveColor ?? defaultInactiveColor;
    final buttonBackgroundColor =
        backgroundColor ?? const Color.fromRGBO(0, 0, 0, 0.39);

    final tooltipText =
        tooltip ?? (isFavorite ? 'Remove from favorites' : 'Add to favorites');

    final iconWidget = Icon(
      isFavorite ? Icons.bookmark : Icons.bookmark_border,
      color: isFavorite ? buttonActiveColor : buttonInactiveColor,
      size: size,
    );

    if (!showBackground) {
      return IconButton(
        icon: iconWidget,
        onPressed: () {
          AccessibilityUtils.buttonPressHapticFeedback();
          onToggle();
        },
        tooltip: tooltipText,
        iconSize: size,
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: buttonBackgroundColor,
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: iconWidget,
        onPressed: () {
          AccessibilityUtils.buttonPressHapticFeedback();
          onToggle();
        },
        tooltip: tooltipText,
        iconSize: size,
      ),
    );
  }
}
