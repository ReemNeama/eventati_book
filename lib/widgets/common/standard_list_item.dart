import 'package:flutter/material.dart';
import 'package:eventati_book/styles/app_colors.dart';
import 'package:eventati_book/styles/app_colors_dark.dart';
import 'package:eventati_book/styles/text_styles.dart';
import 'package:eventati_book/utils/ui/ui_utils.dart';
import 'package:eventati_book/utils/ui/feedback_utils.dart';
import 'package:eventati_book/utils/core/constants.dart';

/// List item variants
enum ListItemVariant {
  /// Standard list item (default)
  standard,

  /// Outlined list item
  outlined,

  /// Elevated list item
  elevated,

  /// Flat list item (no elevation or border)
  flat,
}

/// List item sizes
enum ListItemSize {
  /// Small list item (less padding)
  small,

  /// Medium list item (default)
  medium,

  /// Large list item (more padding)
  large,
}

/// A standardized list item component with consistent styling
class StandardListItem extends StatefulWidget {
  /// The title of the list item
  final String title;

  /// The subtitle of the list item
  final String? subtitle;

  /// The leading widget of the list item
  final Widget? leading;

  /// The trailing widget of the list item
  final Widget? trailing;

  /// The variant of the list item
  final ListItemVariant variant;

  /// The size of the list item
  final ListItemSize size;

  /// Whether the list item is interactive (clickable)
  final bool isInteractive;

  /// The callback to call when the list item is tapped
  final VoidCallback? onTap;

  /// The background color of the list item
  final Color? backgroundColor;

  /// The border color of the list item
  final Color? borderColor;

  /// The border width of the list item
  final double? borderWidth;

  /// The border radius of the list item
  final double? borderRadius;

  /// The elevation of the list item
  final double? elevation;

  /// The margin around the list item
  final EdgeInsets? margin;

  /// The padding inside the list item
  final EdgeInsets? padding;

  /// Whether to add haptic feedback when the list item is tapped
  final bool addHapticFeedback;

  /// The type of haptic feedback to add
  final HapticFeedbackType hapticFeedbackType;

  /// Constructor
  const StandardListItem({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.variant = ListItemVariant.standard,
    this.size = ListItemSize.medium,
    this.isInteractive = true,
    this.onTap,
    this.backgroundColor,
    this.borderColor,
    this.borderWidth,
    this.borderRadius,
    this.elevation,
    this.margin,
    this.padding,
    this.addHapticFeedback = true,
    this.hapticFeedbackType = HapticFeedbackType.light,
  });

  @override
  State<StandardListItem> createState() => _StandardListItemState();
}

class _StandardListItemState extends State<StandardListItem> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = UIUtils.isDarkMode(context);
    final backgroundColor = _getBackgroundColor(isDarkMode);
    final borderColor = _getBorderColor(isDarkMode);
    final elevation = _getElevation();
    final borderRadius = widget.borderRadius ?? AppConstants.smallBorderRadius;
    final borderWidth = widget.borderWidth ?? 1.0;
    final padding = _getPadding();
    final margin =
        widget.margin ??
        const EdgeInsets.symmetric(
          vertical: AppConstants.smallPadding / 2,
          horizontal: AppConstants.smallPadding,
        );

    // Create the list item content
    final Widget content = Row(
      children: [
        if (widget.leading != null) ...[
          widget.leading!,
          SizedBox(width: padding.left),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.title,
                style: _getTitleStyle(isDarkMode),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (widget.subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  widget.subtitle!,
                  style: _getSubtitleStyle(isDarkMode),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
        if (widget.trailing != null) ...[
          SizedBox(width: padding.right),
          widget.trailing!,
        ],
      ],
    );

    // Create the list item container
    final Widget container = Container(
      margin: margin,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border:
            widget.variant == ListItemVariant.outlined ||
                    widget.variant == ListItemVariant.standard
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
      child: Padding(padding: padding, child: content),
    );

    // Wrap with interactive elements if needed
    if (widget.isInteractive && widget.onTap != null) {
      return MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: GestureDetector(
          onTapDown: (_) => setState(() => _isPressed = true),
          onTapUp: (_) => setState(() => _isPressed = false),
          onTapCancel: () => setState(() => _isPressed = false),
          onTap: _handleTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            transform:
                _isPressed
                    ? (Matrix4.identity()..scale(0.98))
                    : _isHovered
                    ? (Matrix4.identity()..scale(1.01))
                    : Matrix4.identity(),
            child: container,
          ),
        ),
      );
    }

    return container;
  }

  /// Handle list item tap
  void _handleTap() {
    if (widget.onTap == null) {
      return;
    }

    if (widget.addHapticFeedback) {
      FeedbackUtils.addHapticFeedback(widget.hapticFeedbackType);
    }

    widget.onTap!();
  }

  /// Get the background color based on variant and theme
  Color _getBackgroundColor(bool isDarkMode) {
    final defaultBackgroundColor =
        isDarkMode ? AppColorsDark.cardBackground : AppColors.cardBackground;
    final hoverColor =
        isDarkMode
            ? Color.fromRGBO(
              AppColorsDark.primary.r.toInt(),
              AppColorsDark.primary.g.toInt(),
              AppColorsDark.primary.b.toInt(),
              0.1,
            )
            : Color.fromRGBO(
              AppColors.primary.r.toInt(),
              AppColors.primary.g.toInt(),
              AppColors.primary.b.toInt(),
              0.05,
            );

    if (widget.backgroundColor != null) {
      return widget.backgroundColor!;
    }

    if (_isPressed && widget.isInteractive && widget.onTap != null) {
      return hoverColor;
    }

    if (_isHovered && widget.isInteractive && widget.onTap != null) {
      return Color.fromRGBO(
        hoverColor.r.toInt(),
        hoverColor.g.toInt(),
        hoverColor.b.toInt(),
        0.5,
      );
    }

    return defaultBackgroundColor;
  }

  /// Get the border color based on variant and theme
  Color _getBorderColor(bool isDarkMode) {
    final defaultBorderColor =
        isDarkMode ? AppColorsDark.divider : AppColors.divider;

    if (widget.borderColor != null) {
      return widget.borderColor!;
    }

    if (widget.variant == ListItemVariant.outlined) {
      return defaultBorderColor;
    }

    return Colors.transparent;
  }

  /// Get the elevation based on variant
  double _getElevation() {
    if (widget.elevation != null) {
      return widget.elevation!;
    }

    if (widget.variant == ListItemVariant.elevated) {
      return AppConstants.smallElevation;
    }

    return 0;
  }

  /// Get the padding based on size
  EdgeInsets _getPadding() {
    if (widget.padding != null) {
      return widget.padding!;
    }

    if (widget.size == ListItemSize.small) {
      return const EdgeInsets.symmetric(
        vertical: AppConstants.smallPadding,
        horizontal: AppConstants.smallPadding,
      );
    } else if (widget.size == ListItemSize.large) {
      return const EdgeInsets.symmetric(
        vertical: AppConstants.mediumPadding,
        horizontal: AppConstants.largePadding,
      );
    }

    return const EdgeInsets.symmetric(
      vertical: AppConstants.mediumPadding / 1.5,
      horizontal: AppConstants.mediumPadding,
    );
  }

  /// Get the title style based on theme
  TextStyle _getTitleStyle(bool isDarkMode) {
    final textColor =
        isDarkMode ? AppColorsDark.textPrimary : AppColors.textPrimary;

    if (widget.size == ListItemSize.small) {
      return TextStyles.bodySmall.copyWith(
        color: textColor,
        fontWeight: FontWeight.w600,
      );
    } else if (widget.size == ListItemSize.large) {
      return TextStyles.bodyLarge.copyWith(
        color: textColor,
        fontWeight: FontWeight.w600,
      );
    }

    return TextStyles.bodyMedium.copyWith(
      color: textColor,
      fontWeight: FontWeight.w600,
    );
  }

  /// Get the subtitle style based on theme
  TextStyle _getSubtitleStyle(bool isDarkMode) {
    final textColor =
        isDarkMode ? AppColorsDark.textSecondary : AppColors.textSecondary;

    if (widget.size == ListItemSize.large) {
      return TextStyles.bodyMedium.copyWith(color: textColor);
    }

    return TextStyles.bodySmall.copyWith(color: textColor);
  }
}
