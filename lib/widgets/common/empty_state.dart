import 'package:flutter/material.dart';
import 'package:eventati_book/styles/app_colors.dart';
import 'package:eventati_book/styles/app_colors_dark.dart';
import 'package:eventati_book/utils/utils.dart';
import 'package:eventati_book/styles/text_styles.dart';

/// Display type for empty states
enum EmptyStateDisplayType {
  /// Standard empty state with icon, title, and message
  standard,

  /// Compact empty state with smaller icon and message
  compact,

  /// Minimal empty state with just text
  minimal,

  /// Card-style empty state with a border
  card,

  /// Animated empty state with subtle animations
  animated,

  /// Placeholder style for content that's loading or not yet available
  placeholder,
}

/// Animation type for animated empty states
enum EmptyStateAnimationType {
  /// Fade in animation
  fadeIn,

  /// Slide in from bottom animation
  slideUp,

  /// Pulse animation that draws attention
  pulse,

  /// Bounce animation
  bounce,

  /// No animation
  none,
}

/// A reusable empty state widget
class EmptyState extends StatelessWidget {
  /// The title to display
  final String title;

  /// The message to display
  final String message;

  /// The icon to display
  final IconData icon;

  /// Optional action button text
  final String? actionText;

  /// Optional action callback
  final VoidCallback? onAction;

  /// Optional secondary action button text
  final String? secondaryActionText;

  /// Optional secondary action callback
  final VoidCallback? onSecondaryAction;

  /// Display type for the empty state
  final EmptyStateDisplayType displayType;

  /// Optional custom illustration widget
  final Widget? illustration;

  /// Optional animation type for animated display type
  final EmptyStateAnimationType animationType;

  /// Optional animation duration
  final Duration animationDuration;

  /// Optional custom background color
  final Color? backgroundColor;

  /// Optional custom icon color
  final Color? iconColor;

  /// Optional custom text color
  final Color? textColor;

  /// Optional custom button color
  final Color? buttonColor;

  /// Optional spacing between elements
  final double spacing;

  /// Optional padding around the widget
  final EdgeInsetsGeometry padding;

  /// Optional border radius for card display type
  final double borderRadius;

  /// Optional elevation for card display type
  final double elevation;

  /// Optional custom styles for title
  final TextStyle? titleStyle;

  /// Optional custom styles for message
  final TextStyle? messageStyle;

  const EmptyState({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.inbox,
    this.actionText,
    this.onAction,
    this.secondaryActionText,
    this.onSecondaryAction,
    this.displayType = EmptyStateDisplayType.standard,
    this.illustration,
    this.animationType = EmptyStateAnimationType.none,
    this.animationDuration = const Duration(milliseconds: 500),
    this.backgroundColor,
    this.iconColor,
    this.textColor,
    this.buttonColor,
    this.spacing = 8.0,
    this.padding = const EdgeInsets.all(24.0),
    this.borderRadius = 8.0,
    this.elevation = 2.0,
    this.titleStyle,
    this.messageStyle,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = UIUtils.isDarkMode(context);
    final primaryColor =
        buttonColor ?? (isDarkMode ? AppColorsDark.primary : AppColors.primary);
    final defaultTextColor =
        textColor ?? (isDarkMode ? Color.fromRGBO(Colors.white.r.toInt(), Colors.white.g.toInt(), Colors.white.b.toInt(), 0.7) : AppColors.textPrimary);
    final secondaryTextColor = isDarkMode ? Color.fromRGBO(Colors.white.r.toInt(), Colors.white.g.toInt(), Colors.white.b.toInt(), 0.54) : AppColors.textSecondary;
    final defaultIconColor =
        iconColor ?? (isDarkMode ? Color.fromRGBO(AppColors.disabled.r.toInt(), AppColors.disabled.g.toInt(), AppColors.disabled.b.toInt(), 0.6) : Color.fromRGBO(AppColors.disabled.r.toInt(), AppColors.disabled.g.toInt(), AppColors.disabled.b.toInt(), 0.4));

    // Create the base widget based on display type
    Widget emptyStateWidget;

    switch (displayType) {
      case EmptyStateDisplayType.standard:
        emptyStateWidget = _buildStandardEmptyState(
          context,
          primaryColor,
          defaultTextColor,
          secondaryTextColor,
        );
      case EmptyStateDisplayType.compact:
        emptyStateWidget = _buildCompactEmptyState(
          context,
          primaryColor,
          defaultTextColor,
          secondaryTextColor,
        );
      case EmptyStateDisplayType.minimal:
        emptyStateWidget = _buildMinimalEmptyState(
          context,
          defaultTextColor,
          secondaryTextColor,
        );
      case EmptyStateDisplayType.card:
        emptyStateWidget = _buildCardEmptyState(
          context,
          primaryColor,
          defaultTextColor,
          secondaryTextColor,
          defaultIconColor,
        );
      case EmptyStateDisplayType.animated:
        // For animated type, use standard layout but apply animation later
        emptyStateWidget = _buildStandardEmptyState(
          context,
          primaryColor,
          defaultTextColor,
          secondaryTextColor,
        );
      case EmptyStateDisplayType.placeholder:
        emptyStateWidget = _buildPlaceholderEmptyState(
          context,
          primaryColor,
          defaultTextColor,
          secondaryTextColor,
          defaultIconColor,
        );
    }

    // Apply animation if needed
    if (displayType == EmptyStateDisplayType.animated ||
        animationType != EmptyStateAnimationType.none) {
      return _applyAnimation(emptyStateWidget);
    }

    return emptyStateWidget;
  }

  /// Apply animation to the widget based on animation type
  Widget _applyAnimation(Widget child) {
    switch (animationType) {
      case EmptyStateAnimationType.fadeIn:
        return _buildFadeInAnimation(child);
      case EmptyStateAnimationType.slideUp:
        return _buildSlideUpAnimation(child);
      case EmptyStateAnimationType.pulse:
        return _buildPulseAnimation(child);
      case EmptyStateAnimationType.bounce:
        return _buildBounceAnimation(child);
      case EmptyStateAnimationType.none:
        return child;
    }
  }

  /// Build fade-in animation
  Widget _buildFadeInAnimation(Widget child) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: animationDuration,
      builder: (context, value, child) {
        return Opacity(opacity: value, child: child);
      },
      child: child,
    );
  }

  /// Build slide-up animation
  Widget _buildSlideUpAnimation(Widget child) {
    return TweenAnimationBuilder<Offset>(
      tween: Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero),
      duration: animationDuration,
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return FractionalTranslation(translation: value, child: child);
      },
      child: child,
    );
  }

  /// Build pulse animation
  Widget _buildPulseAnimation(Widget child) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.95, end: 1.0),
      duration: const Duration(milliseconds: 1500),
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        return Transform.scale(scale: value, child: child);
      },
      child: child,
    );
  }

  /// Build bounce animation
  Widget _buildBounceAnimation(Widget child) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: animationDuration,
      curve: Curves.bounceOut,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: child,
        );
      },
      child: child,
    );
  }

  Widget _buildStandardEmptyState(
    BuildContext context,
    Color primaryColor,
    Color textColor,
    Color secondaryTextColor,
  ) {
    final isDarkMode = UIUtils.isDarkMode(context);
    final defaultIconColor =
        iconColor ?? (isDarkMode ? Color.fromRGBO(AppColors.disabled.r.toInt(), AppColors.disabled.g.toInt(), AppColors.disabled.b.toInt(), 0.6) : Color.fromRGBO(AppColors.disabled.r.toInt(), AppColors.disabled.g.toInt(), AppColors.disabled.b.toInt(), 0.4));

    return Center(
      child: Padding(
        padding: padding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Use the illustration if provided, otherwise use the icon
            if (illustration != null)
              illustration!
            else
              Icon(
                icon,
                size: 80,
                color: defaultIconColor,
                semanticLabel: '$title icon',
              ),
            SizedBox(height: spacing * 3),
            Text(
              title,
              style: titleStyle ?? TextStyles.title.copyWith(color: textColor),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: spacing),
            Text(
              message,
              style:
                  messageStyle ??
                  TextStyles.bodyLarge.copyWith(color: secondaryTextColor),
              textAlign: TextAlign.center,
            ),
            if (actionText != null && onAction != null) ...[
              SizedBox(height: spacing * 3),
              ElevatedButton(
                onPressed: () {
                  AccessibilityUtils.buttonPressHapticFeedback();
                  onAction?.call();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
                child: Text(actionText!),
              ),
            ],
            if (secondaryActionText != null && onSecondaryAction != null) ...[
              SizedBox(height: spacing),
              TextButton(
                onPressed: () {
                  AccessibilityUtils.buttonPressHapticFeedback();
                  onSecondaryAction?.call();
                },
                style: TextButton.styleFrom(foregroundColor: primaryColor),
                child: Text(secondaryActionText!),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCompactEmptyState(
    BuildContext context,
    Color primaryColor,
    Color textColor,
    Color secondaryTextColor,
  ) {
    final isDarkMode = UIUtils.isDarkMode(context);
    final defaultIconColor =
        iconColor ?? (isDarkMode ? Color.fromRGBO(AppColors.disabled.r.toInt(), AppColors.disabled.g.toInt(), AppColors.disabled.b.toInt(), 0.6) : Color.fromRGBO(AppColors.disabled.r.toInt(), AppColors.disabled.g.toInt(), AppColors.disabled.b.toInt(), 0.4));

    return Center(
      child: Padding(
        padding: padding,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (illustration != null)
              SizedBox(width: 40, height: 40, child: illustration!)
            else
              Icon(
                icon,
                size: 40,
                color: defaultIconColor,
                semanticLabel: '$title icon',
              ),
            SizedBox(width: spacing * 2),
            Flexible(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style:
                        titleStyle ??
                        TextStyles.subtitle.copyWith(color: textColor),
                  ),
                  SizedBox(height: spacing / 2),
                  Text(
                    message,
                    style:
                        messageStyle ??
                        TextStyles.bodyMedium.copyWith(
                          color: secondaryTextColor,
                        ),
                  ),
                  if (actionText != null && onAction != null) ...[
                    SizedBox(height: spacing),
                    TextButton(
                      onPressed: () {
                        AccessibilityUtils.buttonPressHapticFeedback();
                        onAction?.call();
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: primaryColor,
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(0, 36),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(actionText!),
                    ),
                  ],
                  if (secondaryActionText != null &&
                      onSecondaryAction != null) ...[
                    SizedBox(height: spacing / 2),
                    TextButton(
                      onPressed: () {
                        AccessibilityUtils.buttonPressHapticFeedback();
                        onSecondaryAction?.call();
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: secondaryTextColor,
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(0, 36),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(secondaryActionText!),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMinimalEmptyState(
    BuildContext context,
    Color textColor,
    Color secondaryTextColor,
  ) {
    return Center(
      child: Padding(
        padding: padding,
        child: Text(
          message,
          style:
              messageStyle ??
              TextStyles.bodyMedium.copyWith(color: secondaryTextColor),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  /// Build a card-style empty state
  Widget _buildCardEmptyState(
    BuildContext context,
    Color primaryColor,
    Color textColor,
    Color secondaryTextColor,
    Color? iconColor,
  ) {
    final isDarkMode = UIUtils.isDarkMode(context);
    final cardColor =
        backgroundColor ?? (isDarkMode ? Color.fromRGBO(AppColors.disabled.r.toInt(), AppColors.disabled.g.toInt(), AppColors.disabled.b.toInt(), 0.85) : Colors.white);

    return Center(
      child: Padding(
        padding: padding,
        child: Card(
          elevation: elevation,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          color: cardColor,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (illustration != null)
                  illustration!
                else
                  Icon(
                    icon,
                    size: 64,
                    color: iconColor,
                    semanticLabel: '$title icon',
                  ),
                SizedBox(height: spacing * 2),
                Text(
                  title,
                  style:
                      titleStyle ??
                      TextStyles.subtitle.copyWith(color: textColor),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: spacing),
                Text(
                  message,
                  style:
                      messageStyle ??
                      TextStyles.bodyMedium.copyWith(color: secondaryTextColor),
                  textAlign: TextAlign.center,
                ),
                if (actionText != null && onAction != null) ...[
                  SizedBox(height: spacing * 2),
                  ElevatedButton(
                    onPressed: onAction,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                    child: Text(actionText!),
                  ),
                ],
                if (secondaryActionText != null &&
                    onSecondaryAction != null) ...[
                  SizedBox(height: spacing),
                  TextButton(
                    onPressed: onSecondaryAction,
                    style: TextButton.styleFrom(foregroundColor: primaryColor),
                    child: Text(secondaryActionText!),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Build a placeholder empty state
  Widget _buildPlaceholderEmptyState(
    BuildContext context,
    Color primaryColor,
    Color textColor,
    Color secondaryTextColor,
    Color? iconColor,
  ) {
    final isDarkMode = UIUtils.isDarkMode(context);
    final placeholderColor = isDarkMode ? Color.fromRGBO(AppColors.disabled.r.toInt(), AppColors.disabled.g.toInt(), AppColors.disabled.b.toInt(), 0.7) : Color.fromRGBO(AppColors.disabled.r.toInt(), AppColors.disabled.g.toInt(), AppColors.disabled.b.toInt(), 0.3);

    return Center(
      child: Padding(
        padding: padding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Placeholder for icon or illustration
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: placeholderColor,
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(height: spacing * 2),
            // Placeholder for title
            Container(
              width: 150,
              height: 24,
              decoration: BoxDecoration(
                color: placeholderColor,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            SizedBox(height: spacing),
            // Placeholder for message
            Container(
              width: 200,
              height: 16,
              decoration: BoxDecoration(
                color: placeholderColor,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            SizedBox(height: spacing),
            Container(
              width: 180,
              height: 16,
              decoration: BoxDecoration(
                color: placeholderColor,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            SizedBox(height: spacing * 2),
            // Placeholder for button
            Container(
              width: 120,
              height: 36,
              decoration: BoxDecoration(
                color: placeholderColor,
                borderRadius: BorderRadius.circular(18),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Factory method for creating an empty list state
  factory EmptyState.list({
    String title = 'No items',
    required String message,
    IconData icon = Icons.list_alt,
    String? actionText,
    VoidCallback? onAction,
    EmptyStateDisplayType displayType = EmptyStateDisplayType.standard,
    Widget? illustration,
  }) {
    return EmptyState(
      title: title,
      message: message,
      icon: icon,
      actionText: actionText,
      onAction: onAction,
      displayType: displayType,
      illustration: illustration,
    );
  }

  /// Factory method for creating an empty search results state
  factory EmptyState.search({
    String title = 'No results found',
    String message = 'Try adjusting your search or filters',
    IconData icon = Icons.search_off,
    String? actionText,
    VoidCallback? onAction,
    EmptyStateDisplayType displayType = EmptyStateDisplayType.standard,
    Widget? illustration,
  }) {
    return EmptyState(
      title: title,
      message: message,
      icon: icon,
      actionText: actionText,
      onAction: onAction,
      displayType: displayType,
      illustration: illustration,
    );
  }

  /// Factory method for creating an empty favorites state
  factory EmptyState.favorites({
    String title = 'No favorites yet',
    String message = 'Items you mark as favorites will appear here',
    IconData icon = Icons.favorite_border,
    String? actionText,
    VoidCallback? onAction,
    EmptyStateDisplayType displayType = EmptyStateDisplayType.standard,
    Widget? illustration,
  }) {
    return EmptyState(
      title: title,
      message: message,
      icon: icon,
      actionText: actionText,
      onAction: onAction,
      displayType: displayType,
      illustration: illustration,
    );
  }

  /// Factory method for creating an empty notifications state
  factory EmptyState.notifications({
    String title = 'No notifications',
    String message = 'You\'re all caught up!',
    IconData icon = Icons.notifications_none,
    String? actionText,
    VoidCallback? onAction,
    EmptyStateDisplayType displayType = EmptyStateDisplayType.standard,
    Widget? illustration,
  }) {
    return EmptyState(
      title: title,
      message: message,
      icon: icon,
      actionText: actionText,
      onAction: onAction,
      displayType: displayType,
      illustration: illustration,
    );
  }

  /// Factory method for creating an error state
  factory EmptyState.error({
    String title = 'Something went wrong',
    required String message,
    IconData icon = Icons.error_outline,
    String? actionText,
    VoidCallback? onAction,
    EmptyStateDisplayType displayType = EmptyStateDisplayType.standard,
    Widget? illustration,
  }) {
    return EmptyState(
      title: title,
      message: message,
      icon: icon,
      actionText: actionText,
      onAction: onAction,
      displayType: displayType,
      illustration: illustration,
    );
  }

  /// Factory method for creating a not found state
  factory EmptyState.notFound({
    String title = 'Not Found',
    required String message,
    IconData icon = Icons.search_off,
    String? actionText,
    VoidCallback? onAction,
    EmptyStateDisplayType displayType = EmptyStateDisplayType.standard,
    Widget? illustration,
  }) {
    return EmptyState(
      title: title,
      message: message,
      icon: icon,
      actionText: actionText,
      onAction: onAction,
      displayType: displayType,
      illustration: illustration,
    );
  }

  /// Factory method for creating an empty state
  factory EmptyState.empty({
    String title = 'No Data',
    required String message,
    IconData icon = Icons.inbox,
    String? actionText,
    VoidCallback? onAction,
    EmptyStateDisplayType displayType = EmptyStateDisplayType.standard,
    Widget? illustration,
  }) {
    return EmptyState(
      title: title,
      message: message,
      icon: icon,
      actionText: actionText,
      onAction: onAction,
      displayType: displayType,
      illustration: illustration,
    );
  }
}
