import 'package:flutter/material.dart';
import 'package:eventati_book/models/models.dart';
import 'package:eventati_book/styles/app_colors.dart';
import 'package:eventati_book/styles/app_colors_dark.dart';
import 'package:eventati_book/utils/utils.dart';
import 'package:eventati_book/widgets/recommendations/recommendation_badge.dart';
import 'package:eventati_book/utils/core/constants.dart';

/// Card widget to display a vendor recommendation
class VendorRecommendationCard extends StatelessWidget {
  /// The recommendation to display
  final Suggestion recommendation;

  /// The event ID
  final String eventId;

  /// Callback when the card is tapped
  final VoidCallback onTap;

  /// Callback when the compare button is tapped
  final VoidCallback? onCompare;

  /// Callback when the save button is tapped
  final VoidCallback? onSave;

  /// Whether the recommendation is saved
  final bool isSaved;

  /// Whether to show the animation effect
  final bool showAnimation;

  /// Creates a new vendor recommendation card
  const VendorRecommendationCard({
    super.key,
    required this.recommendation,
    required this.eventId,
    required this.onTap,
    this.onCompare,
    this.onSave,
    this.isSaved = false,
    this.showAnimation = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = UIUtils.isDarkMode(context);
    final primaryColor = isDarkMode ? AppColorsDark.primary : AppColors.primary;
    final cardColor =
        isDarkMode ? AppColorsDark.cardBackground : AppColors.cardBackground;
    final textColor = isDarkMode ? Colors.white : Colors.black;

    // Create the card widget
    final Widget card = Card(
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
                            height: 180,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return _buildPlaceholderImage(context);
                            },
                          )
                          : _buildPlaceholderImage(context),
                ),
                // Save button
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withAlpha(100),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: Icon(
                        isSaved ? Icons.bookmark : Icons.bookmark_border,
                        color: isSaved ? Colors.yellow : Colors.white,
                      ),
                      onPressed: onSave,
                      tooltip: isSaved ? 'Remove from saved' : 'Save',
                      iconSize: 20,
                    ),
                  ),
                ),
                // Recommendation badge
                Positioned(
                  top: 12,
                  right: 12,
                  child: RecommendationBadge(
                    reason: recommendation.description,
                    relevanceScore: recommendation.baseRelevanceScore,
                  ),
                ),
                // Title overlay
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withAlpha(200),
                          Colors.black.withAlpha(100),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.7, 1.0],
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          recommendation.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(
                                blurRadius: 2.0,
                                color: Colors.black,
                                offset: Offset(1.0, 1.0),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              recommendation.category.icon,
                              color: Colors.white,
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              recommendation.category.label,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                shadows: [
                                  Shadow(
                                    blurRadius: 2.0,
                                    color: Colors.black,
                                    offset: Offset(1.0, 1.0),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
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
                  // Rating and price range
                  Row(
                    children: [
                      // Rating stars
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 16),
                          const Icon(Icons.star, color: Colors.amber, size: 16),
                          const Icon(Icons.star, color: Colors.amber, size: 16),
                          const Icon(Icons.star, color: Colors.amber, size: 16),
                          const Icon(
                            Icons.star_half,
                            color: Colors.amber,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '4.5',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      // Price range
                      Text(
                        '\$\$\$',
                        style: TextStyle(
                          color: textColor.withAlpha(179),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Description
                  Text(
                    recommendation.description,
                    style: TextStyle(
                      color: textColor.withAlpha(204),
                      fontSize: 14,
                      height: 1.4,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),

                  // Tags
                  if (recommendation.tags.isNotEmpty) ...[
                    SizedBox(
                      height: 28,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: recommendation.tags.length,
                        itemBuilder: (context, index) {
                          return Container(
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: primaryColor.withAlpha(26),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: primaryColor.withAlpha(51),
                              ),
                            ),
                            child: Text(
                              recommendation.tags[index],
                              style: TextStyle(
                                color: primaryColor,
                                fontSize: 12,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Action buttons
                  Row(
                    children: [
                      // Priority chip
                      _buildPriorityChip(recommendation.priority),
                      const Spacer(),
                      // Compare button
                      OutlinedButton.icon(
                        onPressed: onCompare,
                        icon: const Icon(Icons.compare, size: 16),
                        label: const Text('Compare'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: primaryColor,
                          side: BorderSide(color: primaryColor),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // View details button
                      ElevatedButton.icon(
                        onPressed: onTap,
                        icon: const Icon(Icons.visibility, size: 16),
                        label: const Text('Details'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
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

    // Add animation if needed
    if (showAnimation) {
      return TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0.8, end: 1.0),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        builder: (context, value, child) {
          return Transform.scale(
            scale: value,
            child: Opacity(opacity: value, child: child),
          );
        },
        child: card,
      );
    }

    return card;
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
      height: 180,
      width: double.infinity,
      decoration: BoxDecoration(
        color: backgroundColor,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [backgroundColor, backgroundColor.withAlpha(150)],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(recommendation.category.icon, size: 64, color: iconColor),
          const SizedBox(height: 8),
          Text(
            recommendation.category.label,
            style: TextStyle(
              color: iconColor,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
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
