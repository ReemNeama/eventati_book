import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:eventati_book/models/models.dart';
import 'package:eventati_book/providers/providers.dart';
import 'package:eventati_book/utils/utils.dart';
import 'package:eventati_book/styles/app_colors.dart';
import 'package:eventati_book/styles/app_colors_dark.dart';
import 'package:eventati_book/screens/recommendations/recommendation_screens.dart';

/// A section for the home screen that displays personalized recommendations
class PersonalizedRecommendationsSection extends StatelessWidget {
  /// The event ID to show recommendations for
  final String eventId;

  /// The event name
  final String eventName;

  /// Maximum number of recommendations to show
  final int maxRecommendations;

  /// Creates a new personalized recommendations section
  const PersonalizedRecommendationsSection({
    super.key,
    required this.eventId,
    required this.eventName,
    this.maxRecommendations = 5,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = UIUtils.isDarkMode(context);
    final primaryColor = isDarkMode ? AppColorsDark.primary : AppColors.primary;
    final textColor = isDarkMode ? Colors.white : Colors.black;

    return Consumer<ServiceRecommendationProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const _LoadingRecommendationsSection();
        }

        if (provider.errorMessage != null) {
          return const SizedBox.shrink(); // Hide section if there's an error
        }

        final recommendations = provider.recommendations;

        if (recommendations.isEmpty) {
          return const SizedBox.shrink(); // Hide section if there are no recommendations
        }

        // Get high priority recommendations first
        final highPriorityRecommendations =
            provider.recommendations
                .where((r) => r.priority == SuggestionPriority.high)
                .toList();

        // If we don't have enough high priority recommendations, add medium priority ones
        final displayRecommendations = <Suggestion>[];
        displayRecommendations.addAll(highPriorityRecommendations);

        if (displayRecommendations.length < maxRecommendations) {
          final mediumPriorityRecommendations =
              provider.recommendations
                  .where((r) => r.priority == SuggestionPriority.medium)
                  .toList();
          final remainingSlots =
              maxRecommendations - displayRecommendations.length;
          displayRecommendations.addAll(
            mediumPriorityRecommendations.take(remainingSlots),
          );
        }

        // Limit to maxRecommendations
        final limitedRecommendations =
            displayRecommendations.take(maxRecommendations).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recommended for You',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  TextButton(
                    onPressed: () => _navigateToAllRecommendations(context),
                    child: Text(
                      'See All',
                      style: TextStyle(color: primaryColor),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Recommendations list
            SizedBox(
              height: 220,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                itemCount: limitedRecommendations.length,
                itemBuilder: (context, index) {
                  final recommendation = limitedRecommendations[index];
                  return _RecommendationCard(
                    recommendation: recommendation,
                    eventId: eventId,
                    isFirst: index == 0,
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  /// Navigate to the full recommendations screen
  void _navigateToAllRecommendations(BuildContext context) {
    NavigationUtils.navigateTo(
      context,
      VendorRecommendationsScreen(eventId: eventId, eventName: eventName),
    );
  }
}

/// A card for displaying a recommendation in the horizontal list
class _RecommendationCard extends StatelessWidget {
  /// The recommendation to display
  final Suggestion recommendation;

  /// The event ID
  final String eventId;

  /// Whether this is the first card in the list
  final bool isFirst;

  /// Creates a new recommendation card
  const _RecommendationCard({
    required this.recommendation,
    required this.eventId,
    this.isFirst = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = UIUtils.isDarkMode(context);
    final primaryColor = isDarkMode ? AppColorsDark.primary : AppColors.primary;
    final cardColor =
        isDarkMode ? AppColorsDark.cardBackground : AppColors.cardBackground;
    final textColor = isDarkMode ? Colors.white : Colors.black;

    return Container(
      width: 180,
      margin: EdgeInsets.only(left: isFirst ? 0 : 12, right: 12, bottom: 8),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _showRecommendationDetails(context),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image section
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
                            height: 120,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return _buildPlaceholderImage(context);
                            },
                          )
                          : _buildPlaceholderImage(context),
                ),
                // Category badge
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withAlpha(150),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          recommendation.category.icon,
                          color: Colors.white,
                          size: 12,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          recommendation.category.label,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Content section
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    recommendation.title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: textColor,
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),

                  // Relevance score
                  Row(
                    children: [
                      Icon(Icons.thumb_up, color: primaryColor, size: 12),
                      const SizedBox(width: 4),
                      Text(
                        '${recommendation.baseRelevanceScore}% Match',
                        style: TextStyle(
                          color: primaryColor,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
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
      height: 120,
      width: double.infinity,
      color: backgroundColor,
      child: Center(
        child: Icon(recommendation.category.icon, size: 32, color: iconColor),
      ),
    );
  }

  /// Show recommendation details
  void _showRecommendationDetails(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => RecommendationDetailsScreen(
              recommendation: recommendation,
              eventId: eventId,
            ),
      ),
    );
  }
}

/// A loading placeholder for the recommendations section
class _LoadingRecommendationsSection extends StatelessWidget {
  /// Creates a new loading recommendations section
  const _LoadingRecommendationsSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recommended for You',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 80), // Placeholder for "See All" button
            ],
          ),
        ),
        const SizedBox(height: 8),

        // Loading cards
        SizedBox(
          height: 220,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            itemCount: 3, // Show 3 loading cards
            itemBuilder: (context, index) {
              return _buildLoadingCard(context, index == 0);
            },
          ),
        ),
      ],
    );
  }

  /// Build a loading card
  Widget _buildLoadingCard(BuildContext context, bool isFirst) {
    return Container(
      width: 180,
      margin: EdgeInsets.only(left: isFirst ? 0 : 12, right: 12, bottom: 8),
      decoration: BoxDecoration(
        color: Colors.grey.withAlpha(50),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image placeholder
          Container(
            height: 120,
            decoration: BoxDecoration(
              color: Colors.grey.withAlpha(100),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
          ),

          // Content placeholders
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title placeholder
                Container(
                  height: 14,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey.withAlpha(100),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  height: 14,
                  width: 100,
                  decoration: BoxDecoration(
                    color: Colors.grey.withAlpha(100),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),

                // Score placeholder
                Container(
                  height: 12,
                  width: 80,
                  decoration: BoxDecoration(
                    color: Colors.grey.withAlpha(100),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
