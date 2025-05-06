import 'package:flutter/material.dart';
import 'package:eventati_book/styles/app_colors.dart';
import 'package:eventati_book/styles/app_colors_dark.dart';
import 'package:eventati_book/utils/utils.dart';

/// Display type for empty states
enum EmptyStateDisplayType {
  /// Standard empty state with icon, title, and message
  standard,

  /// Compact empty state with smaller icon and message
  compact,

  /// Minimal empty state with just text
  minimal,
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

  /// Display type for the empty state
  final EmptyStateDisplayType displayType;

  /// Optional custom illustration widget
  final Widget? illustration;

  const EmptyState({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.inbox,
    this.actionText,
    this.onAction,
    this.displayType = EmptyStateDisplayType.standard,
    this.illustration,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = UIUtils.isDarkMode(context);
    final primaryColor = isDarkMode ? AppColorsDark.primary : AppColors.primary;
    final textColor = isDarkMode ? Colors.white70 : Colors.black87;
    final secondaryTextColor = isDarkMode ? Colors.white54 : Colors.black54;

    switch (displayType) {
      case EmptyStateDisplayType.standard:
        return _buildStandardEmptyState(
          context,
          primaryColor,
          textColor,
          secondaryTextColor,
        );
      case EmptyStateDisplayType.compact:
        return _buildCompactEmptyState(
          context,
          primaryColor,
          textColor,
          secondaryTextColor,
        );
      case EmptyStateDisplayType.minimal:
        return _buildMinimalEmptyState(context, textColor, secondaryTextColor);
    }
  }

  Widget _buildStandardEmptyState(
    BuildContext context,
    Color primaryColor,
    Color textColor,
    Color secondaryTextColor,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Use the illustration if provided, otherwise use the icon
            if (illustration != null)
              // Use non-null assertion here since we've already checked it's not null
              illustration!
            else
              Icon(
                icon,
                size: 80,
                color:
                    UIUtils.isDarkMode(context)
                        ? Colors.grey[600]
                        : Colors.grey[400],
                semanticLabel: '$title icon',
              ),
            const SizedBox(height: 24),
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(fontSize: 16, color: secondaryTextColor),
              textAlign: TextAlign.center,
            ),
            if (actionText != null && onAction != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
                // We've already checked that actionText is not null in the if condition
                child: Text(actionText!),
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
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 40,
              color:
                  UIUtils.isDarkMode(context)
                      ? Colors.grey[600]
                      : Colors.grey[400],
              semanticLabel: '$title icon',
            ),
            const SizedBox(width: 16),
            Flexible(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message,
                    style: TextStyle(fontSize: 14, color: secondaryTextColor),
                  ),
                  if (actionText != null && onAction != null) ...[
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: onAction,
                      style: TextButton.styleFrom(
                        foregroundColor: primaryColor,
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(0, 36),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      // We've already checked that actionText is not null in the if condition
                      child: Text(actionText!),
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
        padding: const EdgeInsets.all(16.0),
        child: Text(
          message,
          style: TextStyle(fontSize: 14, color: secondaryTextColor),
          textAlign: TextAlign.center,
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
}
