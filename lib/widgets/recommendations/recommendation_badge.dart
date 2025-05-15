import 'package:flutter/material.dart';
import 'package:eventati_book/utils/utils.dart';

/// A badge widget to highlight recommended services with relevance score
class RecommendationBadge extends StatelessWidget {
  /// The reason why this service is recommended
  final String? reason;

  /// The relevance score (0-100)
  final int relevanceScore;

  /// Whether to show the reason in a tooltip
  final bool showTooltip;

  /// Constructor
  const RecommendationBadge({
    super.key,
    this.reason,
    required this.relevanceScore,
    this.showTooltip = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = UIUtils.isDarkMode(context);
    final badgeColor = _getBadgeColor(relevanceScore, isDarkMode);

    final badge = Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(26),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.recommend, color: Colors.white, size: 14),
          const SizedBox(width: 4),
          Text(
            '$relevanceScore% Match',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );

    if (showTooltip && reason != null && reason!.isNotEmpty) {
      return Tooltip(message: reason!, child: badge);
    }

    return badge;
  }

  /// Get the badge color based on the relevance score
  Color _getBadgeColor(int score, bool isDarkMode) {
    if (score >= 90) {
      // Excellent match
      return Colors.green;
    } else if (score >= 70) {
      // Good match
      return Colors.lightGreen;
    } else if (score >= 50) {
      // Moderate match
      return Colors.amber;
    } else {
      // Low match
      return Colors.orange;
    }
  }
}
