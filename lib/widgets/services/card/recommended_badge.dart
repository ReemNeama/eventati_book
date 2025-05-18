import 'package:flutter/material.dart';
import 'package:eventati_book/styles/app_colors.dart';
import 'package:eventati_book/styles/app_colors_dark.dart';
import 'package:eventati_book/utils/utils.dart';

/// A badge widget to highlight recommended services
class RecommendedBadge extends StatelessWidget {
  /// The reason why this service is recommended
  final String? reason;

  /// Whether to show the reason in a tooltip
  final bool showTooltip;

  /// Constructor
  const RecommendedBadge({super.key, this.reason, this.showTooltip = true});

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = UIUtils.isDarkMode(context);
    final Color primaryColor =
        isDarkMode ? AppColorsDark.primary : AppColors.primary;

    final Widget badge = Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: primaryColor,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.thumb_up, size: 14.0, color: Colors.white),
          SizedBox(width: 4.0),
          Text(
            'Recommended',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );

    // If there's a reason and showTooltip is true, wrap the badge in a tooltip
    if (reason != null && showTooltip) {
      // Store the non-null reason in a local variable
      final tooltipMessage = reason;
      // Use the non-null reason directly
      return Tooltip(message: tooltipMessage ?? '', child: badge);
    }

    return badge;
  }
}
