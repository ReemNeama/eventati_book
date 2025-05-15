import 'package:flutter/material.dart';
import 'package:eventati_book/models/models.dart';
import 'package:eventati_book/styles/app_colors.dart';
import 'package:eventati_book/styles/app_colors_dark.dart';
import 'package:eventati_book/utils/utils.dart';
import 'package:eventati_book/widgets/recommendations/recommendation_badge.dart';

/// Card widget to display a vendor recommendation
class VendorRecommendationCard extends StatelessWidget {
  /// The recommendation to display
  final Suggestion recommendation;

  /// The event ID
  final String eventId;

  /// Callback when the card is tapped
  final VoidCallback onTap;

  /// Creates a new vendor recommendation card
  const VendorRecommendationCard({
    super.key,
    required this.recommendation,
    required this.eventId,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = UIUtils.isDarkMode(context);
    final primaryColor = isDarkMode ? AppColorsDark.primary : AppColors.primary;
    final cardColor =
        isDarkMode ? AppColorsDark.cardBackground : AppColors.cardBackground;
    final textColor = isDarkMode ? Colors.white : Colors.black;

    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: cardColor,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image section with recommendation badge
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                  child:
                      recommendation.imageUrl != null
                          ? Image.network(
                            recommendation.imageUrl!,
                            height: 150,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return _buildPlaceholderImage(context);
                            },
                          )
                          : _buildPlaceholderImage(context),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: RecommendationBadge(
                    reason: recommendation.description,
                    relevanceScore: recommendation.baseRelevanceScore,
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withAlpha(179),
                          Colors.transparent,
                        ],
                      ),
                    ),
                    child: Text(
                      recommendation.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Content section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category and priority
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: primaryColor.withAlpha(26),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          recommendation.category.icon,
                          color: primaryColor,
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        recommendation.category.label,
                        style: TextStyle(
                          color: textColor.withAlpha(179),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      _buildPriorityChip(recommendation.priority),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Description
                  Text(
                    recommendation.description,
                    style: TextStyle(
                      color: textColor.withAlpha(204),
                      fontSize: 14,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 16),

                  // Action buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton(
                        onPressed: () {
                          // Add to comparison
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: primaryColor,
                          side: BorderSide(color: primaryColor),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        child: const Text('Compare'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: onTap,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        child: const Text('View Details'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build a placeholder image
  Widget _buildPlaceholderImage(BuildContext context) {
    final isDarkMode = UIUtils.isDarkMode(context);
    final backgroundColor =
        isDarkMode
            ? AppColorsDark.primary.withAlpha(26)
            : AppColors.primary.withAlpha(26);
    final iconColor = isDarkMode ? AppColorsDark.primary : AppColors.primary;

    return Container(
      height: 150,
      width: double.infinity,
      color: backgroundColor,
      child: Center(
        child: Icon(recommendation.category.icon, size: 48, color: iconColor),
      ),
    );
  }

  /// Build a priority chip
  Widget _buildPriorityChip(SuggestionPriority priority) {
    Color chipColor;
    String label;

    switch (priority) {
      case SuggestionPriority.high:
        chipColor = Colors.red;
        label = 'High Priority';
        break;
      case SuggestionPriority.medium:
        chipColor = Colors.orange;
        label = 'Medium';
        break;
      case SuggestionPriority.low:
        chipColor = Colors.green;
        label = 'Optional';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: chipColor.withAlpha(26),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: chipColor.withAlpha(128)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: chipColor,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
