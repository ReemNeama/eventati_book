import 'package:flutter/material.dart';
import 'package:eventati_book/styles/app_colors.dart';
import 'package:eventati_book/styles/app_colors_dark.dart';
import 'package:eventati_book/styles/text_styles.dart';
import 'package:eventati_book/utils/ui/ui_utils.dart';
import 'package:eventati_book/utils/ui/feedback_utils.dart';
import 'package:eventati_book/utils/ui/touch_target_utils.dart';
import 'package:eventati_book/utils/core/constants.dart';

/// Button sizes
enum ButtonSize {
  /// Small button (height: 32)
  small,

  /// Medium button (height: 40)
  medium,

  /// Large button (height: 48)
  large,
}

/// Button variants
enum ButtonVariant {
  /// Primary button (filled with primary color)
  primary,

  /// Secondary button (outlined with primary color)
  secondary,

  /// Tertiary button (text only)
  tertiary,

  /// Danger button (filled with error color)
  danger,

  /// Success button (filled with success color)
  success,
}

/// A standardized button component with consistent styling
class StandardButton extends StatefulWidget {
  /// The text to display on the button
  final String text;

  /// The callback to call when the button is pressed
  final VoidCallback onPressed;

  /// The size of the button
  final ButtonSize size;

  /// The variant of the button
  final ButtonVariant variant;

  /// The icon to display on the button
  final IconData? icon;

  /// Whether to show the icon on the left or right
  final bool iconOnRight;

  /// Whether the button is disabled
  final bool isDisabled;

  /// Whether the button is loading
  final bool isLoading;

  /// Whether to add haptic feedback when the button is pressed
  final bool addHapticFeedback;

  /// The type of haptic feedback to add
  final HapticFeedbackType hapticFeedbackType;

  /// The semantic label for the button
  final String? semanticLabel;

  /// Constructor
  const StandardButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.size = ButtonSize.medium,
    this.variant = ButtonVariant.primary,
    this.icon,
    this.iconOnRight = false,
    this.isDisabled = false,
    this.isLoading = false,
    this.addHapticFeedback = true,
    this.hapticFeedbackType = HapticFeedbackType.light,
    this.semanticLabel,
  });

  @override
  State<StandardButton> createState() => _StandardButtonState();
}

class _StandardButtonState extends State<StandardButton> {
  bool _isHovered = false;
  bool _isPressed = false;
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = UIUtils.isDarkMode(context);
    final effectiveSemanticLabel = widget.semanticLabel ?? widget.text;

    return Semantics(
      button: true,
      enabled: !widget.isDisabled && !widget.isLoading,
      label: effectiveSemanticLabel,
      child: FocusableActionDetector(
        onShowFocusHighlight: (focused) {
          setState(() {
            _isFocused = focused;
          });
        },
        child: MouseRegion(
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          child: GestureDetector(
            onTapDown: (_) => setState(() => _isPressed = true),
            onTapUp: (_) => setState(() => _isPressed = false),
            onTapCancel: () => setState(() => _isPressed = false),
            onTap: _handleTap,
            child: Container(
              height: _getButtonHeight(),
              constraints: const BoxConstraints(
                minWidth: TouchTargetUtils.minTouchTargetSize,
                minHeight: TouchTargetUtils.minTouchTargetSize,
              ),
              decoration: _getButtonDecoration(isDarkMode),
              child: Padding(
                padding: _getButtonPadding(),
                child: _buildButtonContent(isDarkMode),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Handle button tap
  void _handleTap() {
    if (widget.isDisabled || widget.isLoading) {
      return;
    }

    if (widget.addHapticFeedback) {
      FeedbackUtils.addHapticFeedback(widget.hapticFeedbackType);
    }

    widget.onPressed();
  }

  /// Get the button height based on size
  double _getButtonHeight() {
    switch (widget.size) {
      case ButtonSize.small:
        return 32.0;
      case ButtonSize.medium:
        return 40.0;
      case ButtonSize.large:
        return 48.0;
    }
  }

  /// Get the button padding based on size
  EdgeInsets _getButtonPadding() {
    switch (widget.size) {
      case ButtonSize.small:
        return const EdgeInsets.symmetric(
          horizontal: AppConstants.smallPadding,
        );
      case ButtonSize.medium:
        return const EdgeInsets.symmetric(
          horizontal: AppConstants.mediumPadding,
        );
      case ButtonSize.large:
        return const EdgeInsets.symmetric(
          horizontal: AppConstants.largePadding,
        );
    }
  }

  /// Get the button decoration based on variant and state
  BoxDecoration _getButtonDecoration(bool isDarkMode) {
    final primaryColor = isDarkMode ? AppColorsDark.primary : AppColors.primary;
    final errorColor = isDarkMode ? AppColorsDark.error : AppColors.error;
    final successColor = isDarkMode ? AppColorsDark.success : AppColors.success;
    final disabledColor =
        isDarkMode
            ? Color.fromRGBO(
              AppColors.disabled.r.toInt(),
              AppColors.disabled.g.toInt(),
              AppColors.disabled.b.toInt(),
              0.3,
            )
            : Color.fromRGBO(
              AppColors.disabled.r.toInt(),
              AppColors.disabled.g.toInt(),
              AppColors.disabled.b.toInt(),
              0.2,
            );

    // Get the base color based on variant
    Color baseColor;
    switch (widget.variant) {
      case ButtonVariant.primary:
        baseColor = primaryColor;
        break;
      case ButtonVariant.danger:
        baseColor = errorColor;
        break;
      case ButtonVariant.success:
        baseColor = successColor;
        break;
      default:
        baseColor = primaryColor;
    }

    // Apply state modifications
    if (widget.isDisabled) {
      baseColor = disabledColor;
    } else if (_isPressed) {
      baseColor = Color.fromRGBO(
        baseColor.r.toInt(),
        baseColor.g.toInt(),
        baseColor.b.toInt(),
        0.8,
      );
    } else if (_isHovered) {
      baseColor = Color.fromRGBO(
        baseColor.r.toInt(),
        baseColor.g.toInt(),
        baseColor.b.toInt(),
        0.9,
      );
    }

    // Create the decoration based on variant
    switch (widget.variant) {
      case ButtonVariant.primary:
      case ButtonVariant.danger:
      case ButtonVariant.success:
        return BoxDecoration(
          color: baseColor,
          borderRadius: BorderRadius.circular(
            AppConstants.smallBorderRadius * 2,
          ),
          boxShadow:
              _isPressed || widget.isDisabled
                  ? null
                  : [
                    BoxShadow(
                      color: Color.fromRGBO(
                        baseColor.r.toInt(),
                        baseColor.g.toInt(),
                        baseColor.b.toInt(),
                        0.3,
                      ),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
          border: _isFocused ? Border.all(color: Colors.white, width: 2) : null,
        );
      case ButtonVariant.secondary:
        return BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(
            AppConstants.smallBorderRadius * 2,
          ),
          border: Border.all(
            color: widget.isDisabled ? disabledColor : baseColor,
            width: 1.5,
          ),
        );
      case ButtonVariant.tertiary:
        return BoxDecoration(
          color:
              _isPressed || _isHovered
                  ? Color.fromRGBO(
                    baseColor.r.toInt(),
                    baseColor.g.toInt(),
                    baseColor.b.toInt(),
                    0.1,
                  )
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(
            AppConstants.smallBorderRadius * 2,
          ),
        );
    }
  }

  /// Build the button content
  Widget _buildButtonContent(bool isDarkMode) {
    final primaryColor = isDarkMode ? AppColorsDark.primary : AppColors.primary;
    final errorColor = isDarkMode ? AppColorsDark.error : AppColors.error;
    final successColor = isDarkMode ? AppColorsDark.success : AppColors.success;
    final disabledColor =
        isDarkMode
            ? Color.fromRGBO(
              AppColors.disabled.r.toInt(),
              AppColors.disabled.g.toInt(),
              AppColors.disabled.b.toInt(),
              0.5,
            )
            : Color.fromRGBO(
              AppColors.disabled.r.toInt(),
              AppColors.disabled.g.toInt(),
              AppColors.disabled.b.toInt(),
              0.4,
            );

    // Get text color based on variant
    Color textColor;
    switch (widget.variant) {
      case ButtonVariant.primary:
      case ButtonVariant.danger:
      case ButtonVariant.success:
        textColor = Colors.white;
        break;
      case ButtonVariant.secondary:
        textColor = widget.isDisabled ? disabledColor : primaryColor;
        if (widget.variant == ButtonVariant.danger) {
          textColor = widget.isDisabled ? disabledColor : errorColor;
        } else if (widget.variant == ButtonVariant.success) {
          textColor = widget.isDisabled ? disabledColor : successColor;
        }
        break;
      case ButtonVariant.tertiary:
        textColor = widget.isDisabled ? disabledColor : primaryColor;
        if (widget.variant == ButtonVariant.danger) {
          textColor = widget.isDisabled ? disabledColor : errorColor;
        } else if (widget.variant == ButtonVariant.success) {
          textColor = widget.isDisabled ? disabledColor : successColor;
        }
        break;
    }

    // Get text style based on size
    TextStyle textStyle;
    switch (widget.size) {
      case ButtonSize.small:
        textStyle = TextStyles.bodySmall.copyWith(
          color: textColor,
          fontWeight: FontWeight.w600,
        );
        break;
      case ButtonSize.medium:
        textStyle = TextStyles.bodyMedium.copyWith(
          color: textColor,
          fontWeight: FontWeight.w600,
        );
        break;
      case ButtonSize.large:
        textStyle = TextStyles.bodyLarge.copyWith(
          color: textColor,
          fontWeight: FontWeight.w600,
        );
        break;
    }

    // Show loading indicator if loading
    if (widget.isLoading) {
      return Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(textColor),
          ),
        ),
      );
    }

    // Show icon and text
    if (widget.icon != null) {
      final iconSize = widget.size == ButtonSize.small ? 16.0 : 20.0;
      final spacing = widget.size == ButtonSize.small ? 4.0 : 8.0;

      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children:
            widget.iconOnRight
                ? [
                  Text(widget.text, style: textStyle),
                  SizedBox(width: spacing),
                  Icon(widget.icon, size: iconSize, color: textColor),
                ]
                : [
                  Icon(widget.icon, size: iconSize, color: textColor),
                  SizedBox(width: spacing),
                  Text(widget.text, style: textStyle),
                ],
      );
    }

    // Show text only
    return Center(child: Text(widget.text, style: textStyle));
  }
}
