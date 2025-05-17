import 'package:flutter/material.dart';
import 'package:eventati_book/styles/app_colors.dart';
import 'package:eventati_book/styles/app_colors_dark.dart';
import 'package:eventati_book/utils/utils.dart';

/// A reusable section header widget with optional action button
class SectionHeader extends StatelessWidget {
  /// The title of the section
  final String title;

  /// Optional text for the action button
  final String? actionText;

  /// Optional callback for when the action button is tapped
  final VoidCallback? onActionTap;

  /// Optional icon for the action button
  final IconData? actionIcon;

  /// Whether to show a divider below the header
  final bool showDivider;

  /// Constructor for SectionHeader
  const SectionHeader({
    super.key,
    required this.title,
    this.actionText,
    this.onActionTap,
    this.actionIcon,
    this.showDivider = false,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = UIUtils.isDarkMode(context);
    final Color textColor =
        isDarkMode ? AppColorsDark.textPrimary : AppColors.textPrimary;
    final Color accentColor =
        isDarkMode ? AppColorsDark.primary : AppColors.primary;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            if (actionText != null && onActionTap != null)
              InkWell(
                onTap: onActionTap,
                borderRadius: BorderRadius.circular(4),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 4.0,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        actionText!,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: accentColor,
                        ),
                      ),
                      if (actionIcon != null) ...[
                        const SizedBox(width: 4),
                        Icon(actionIcon, size: 16, color: accentColor),
                      ] else ...[
                        const SizedBox(width: 4),
                        Icon(Icons.arrow_forward, size: 16, color: accentColor),
                      ],
                    ],
                  ),
                ),
              ),
          ],
        ),
        if (showDivider) ...[
          const SizedBox(height: 8),
          Divider(
            color: isDarkMode ? Colors.grey[800] : Colors.grey[300],
            thickness: 1,
          ),
        ],
      ],
    );
  }
}
