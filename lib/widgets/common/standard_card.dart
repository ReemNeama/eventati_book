import 'package:flutter/material.dart';
import 'package:eventati_book/styles/app_colors.dart';
import 'package:eventati_book/styles/app_colors_dark.dart';
import 'package:eventati_book/utils/ui/ui_utils.dart';
import 'package:eventati_book/utils/core/constants.dart';

/// Card variants
enum CardVariant {
  /// Standard card (default)
  standard,

  /// Outlined card
  outlined,

  /// Elevated card
  elevated,

  /// Flat card (no elevation or border)
  flat,
}

/// Card sizes
enum CardSize {
  /// Small card (less padding)
  small,

  /// Medium card (default)
  medium,

  /// Large card (more padding)
  large,
}

/// A standardized card component with consistent styling
class StandardCard extends StatefulWidget {
  /// The child widget
  final Widget child;

  /// The variant of the card
  final CardVariant variant;

  /// The size of the card
  final CardSize size;

  /// Whether the card is interactive (clickable)
  final bool isInteractive;

  /// The callback to call when the card is tapped
  final VoidCallback? onTap;

  /// The background color of the card
  final Color? backgroundColor;

  /// The border color of the card
  final Color? borderColor;

  /// The border width of the card
  final double? borderWidth;

  /// The border radius of the card
  final double? borderRadius;

  /// The elevation of the card
  final double? elevation;

  /// The margin around the card
  final EdgeInsets? margin;

  /// The padding inside the card
  final EdgeInsets? padding;

  /// The width of the card
  final double? width;

  /// The height of the card
  final double? height;

  /// Constructor
  const StandardCard({
    super.key,
    required this.child,
    this.variant = CardVariant.standard,
    this.size = CardSize.medium,
    this.isInteractive = false,
    this.onTap,
    this.backgroundColor,
    this.borderColor,
    this.borderWidth,
    this.borderRadius,
    this.elevation,
    this.margin,
    this.padding,
    this.width,
    this.height,
  });

  @override
  State<StandardCard> createState() => _StandardCardState();
}

class _StandardCardState extends State<StandardCard> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = UIUtils.isDarkMode(context);
    final cardColor = _getCardColor(isDarkMode);
    final borderColor = _getBorderColor(isDarkMode);
    final elevation = _getElevation();
    final borderRadius = widget.borderRadius ?? AppConstants.mediumBorderRadius;
    final borderWidth = widget.borderWidth ?? 1.0;
    final padding = _getPadding();
    final margin =
        widget.margin ??
        const EdgeInsets.symmetric(
          vertical: AppConstants.smallPadding,
          horizontal: AppConstants.smallPadding,
        );

    // Create the card widget
    final Widget cardWidget = Container(
      width: widget.width,
      height: widget.height,
      margin: margin,
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border:
            widget.variant == CardVariant.outlined ||
                    widget.variant == CardVariant.standard
                ? Border.all(color: borderColor, width: borderWidth)
                : null,
        boxShadow:
            elevation > 0
                ? [
                  BoxShadow(
                    color: const Color.fromRGBO(0, 0, 0, 0.1),
                    blurRadius: elevation,
                    offset: Offset(0, elevation / 2),
                  ),
                ]
                : null,
      ),
      child: Padding(padding: padding, child: widget.child),
    );

    // Wrap with interactive elements if needed
    if (widget.isInteractive || widget.onTap != null) {
      return MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: GestureDetector(
          onTapDown: (_) => setState(() => _isPressed = true),
          onTapUp: (_) => setState(() => _isPressed = false),
          onTapCancel: () => setState(() => _isPressed = false),
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            transform:
                _isPressed
                    ? (Matrix4.identity()..scale(0.98))
                    : _isHovered
                    ? (Matrix4.identity()..scale(1.01))
                    : Matrix4.identity(),
            child: cardWidget,
          ),
        ),
      );
    }

    return cardWidget;
  }

  /// Get the card color based on variant and theme
  Color _getCardColor(bool isDarkMode) {
    final defaultCardColor =
        isDarkMode ? AppColorsDark.cardBackground : AppColors.cardBackground;

    if (widget.backgroundColor != null) {
      return widget.backgroundColor!;
    }

    return defaultCardColor;
  }

  /// Get the border color based on variant and theme
  Color _getBorderColor(bool isDarkMode) {
    final defaultBorderColor =
        isDarkMode ? AppColorsDark.divider : AppColors.divider;

    if (widget.borderColor != null) {
      return widget.borderColor!;
    }

    if (widget.variant == CardVariant.outlined) {
      return defaultBorderColor;
    }

    return Colors.transparent;
  }

  /// Get the elevation based on variant
  double _getElevation() {
    if (widget.elevation != null) {
      return widget.elevation!;
    }

    if (widget.variant == CardVariant.standard) {
      return AppConstants.smallElevation;
    } else if (widget.variant == CardVariant.elevated) {
      return AppConstants.mediumElevation;
    }

    return 0;
  }

  /// Get the padding based on size
  EdgeInsets _getPadding() {
    if (widget.padding != null) {
      return widget.padding!;
    }

    if (widget.size == CardSize.small) {
      return const EdgeInsets.all(AppConstants.smallPadding);
    } else if (widget.size == CardSize.large) {
      return const EdgeInsets.all(AppConstants.largePadding);
    }

    return const EdgeInsets.all(AppConstants.mediumPadding);
  }
}
