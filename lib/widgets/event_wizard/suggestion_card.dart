import 'package:flutter/material.dart';
import 'package:eventati_book/models/models.dart';
import 'package:eventati_book/styles/app_colors.dart';
import 'package:eventati_book/styles/app_colors_dark.dart';


/// Card widget to display a suggestion
class SuggestionCard extends StatelessWidget {
  /// The suggestion to display
  final Suggestion suggestion;

  /// The calculated relevance score
  final int relevanceScore;

  /// Callback when the card is tapped
  final VoidCallback onTap;

  const SuggestionCard({
    super.key,
    required this.suggestion,
    required this.relevanceScore,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDarkMode ? AppColorsDark.card : AppColors.card;
    final textColor =
        isDarkMode ? AppColorsDark.textPrimary : AppColors.textPrimary;
    final secondaryTextColor =
        isDarkMode ? AppColorsDark.textSecondary : AppColors.textSecondary;

    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: cardColor,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with category icon and priority
              Row(
                children: [
                  // Category icon
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color:
                          isDarkMode
                              ? AppColorsDark.primary.withAlpha(25)
                              : Color.fromRGBO(
                                AppColors.primary.r.toInt(),
                                AppColors.primary.g.toInt(),
                                AppColors.primary.b.toInt(),
                                0.10,
                              ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      suggestion.category.icon,
                      color:
                          isDarkMode
                              ? AppColorsDark.primary
                              : AppColors.primary,
                      size: 20,
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Category name
                  Text(
                    suggestion.category.label,
                    style: TextStyle(
                      color: secondaryTextColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const Spacer(),

                  // Priority indicator
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: suggestion.priority.color.withAlpha(25),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.flag,
                          color: suggestion.priority.color,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          suggestion.priority.label,
                          style: TextStyle(
                            color: suggestion.priority.color,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Title with custom badge if applicable
              Row(
                children: [
                  Expanded(
                    child: Text(
                      suggestion.title,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  // Custom badge
                  if (suggestion.isCustom)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Color.fromRGBO(
                          Colors.purple.r.toInt(),
                          Colors.purple.g.toInt(),
                          Colors.purple.b.toInt(),
                          0.10,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.edit, color: Colors.purple, size: 12),
                          SizedBox(width: 4),
                          Text(
                            'Custom',
                            style: TextStyle(
                              color: Colors.purple,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 8),

              // Description (truncated)
              Text(
                suggestion.description.length > 120
                    ? '${suggestion.description.substring(0, 120)}...'
                    : suggestion.description,
                style: TextStyle(
                  color: secondaryTextColor,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 16),

              // Footer with relevance score and action hint
              Row(
                children: [
                  // Relevance score
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getRelevanceColor(relevanceScore).withAlpha(25),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.star,
                          color: _getRelevanceColor(relevanceScore),
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$relevanceScore% Match',
                          style: TextStyle(
                            color: _getRelevanceColor(relevanceScore),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // Action hint
                  Text(
                    'View Details',
                    style: TextStyle(
                      color:
                          isDarkMode
                              ? AppColorsDark.primary
                              : AppColors.primary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(width: 4),

                  Icon(
                    Icons.arrow_forward_ios,
                    color:
                        isDarkMode ? AppColorsDark.primary : AppColors.primary,
                    size: 14,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Get color based on relevance score
  Color _getRelevanceColor(int score) {
    if (score >= 80) {
      return AppColors.success;
    } else if (score >= 60) {
      return AppColors.ratingStarColor;
    } else {
      return AppColors.primary;
    }
  }
}
