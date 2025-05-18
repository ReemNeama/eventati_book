import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:eventati_book/models/models.dart';
import 'package:eventati_book/providers/providers.dart';
import 'package:eventati_book/utils/core/constants.dart';
import 'package:eventati_book/styles/app_colors.dart';


/// Screen for displaying personalized recommendations based on wizard data
class PersonalizedRecommendationsScreen extends StatefulWidget {
  /// Creates a new personalized recommendations screen
  const PersonalizedRecommendationsScreen({super.key});

  @override
  State<PersonalizedRecommendationsScreen> createState() =>
      _PersonalizedRecommendationsScreenState();
}

class _PersonalizedRecommendationsScreenState
    extends State<PersonalizedRecommendationsScreen> {
  /// The currently selected category filter
  SuggestionCategory? _selectedCategory;

  @override
  void initState() {
    super.initState();
    // Load recommendations if needed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<ServiceRecommendationProvider>(
        context,
        listen: false,
      );
      if (provider.wizardState != null &&
          provider.personalizedRecommendations.isEmpty) {
        provider.refreshRecommendations();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Personalized Recommendations'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              final provider = Provider.of<ServiceRecommendationProvider>(
                context,
                listen: false,
              );
              provider.refreshRecommendations();
            },
            tooltip: 'Refresh Recommendations',
          ),
        ],
      ),
      body: Consumer<ServiceRecommendationProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: AppColors.error,
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading recommendations',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    provider.errorMessage!,
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => provider.refreshRecommendations(),
                    child: const Text('Try Again'),
                  ),
                ],
              ),
            );
          }

          if (provider.wizardState == null) {
            return const Center(
              child: Text(
                'No wizard data available. Complete the event wizard first.',
              ),
            );
          }

          final recommendations =
              _selectedCategory != null
                  ? provider.getPersonalizedRecommendationsForCategory(
                    _selectedCategory!,
                  )
                  : provider.personalizedRecommendations;

          if (recommendations.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.lightbulb_outline,
                    color: AppColors.ratingStarColor,
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No recommendations found',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Try changing your event details or selecting different services.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => provider.seedPredefinedRecommendations(),
                    child: const Text('Load Sample Recommendations'),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Category filter
              Padding(
                padding: const EdgeInsets.all(AppConstants.mediumPadding),
                child: _buildCategoryFilter(),
              ),

              // Recommendations list
              Expanded(
                child: ListView.builder(
                  itemCount: recommendations.length,
                  itemBuilder: (context, index) {
                    final recommendation = recommendations[index];
                    return _buildRecommendationCard(recommendation);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// Builds the category filter chips
  Widget _buildCategoryFilter() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          FilterChip(
            label: const Text('All'),
            selected: _selectedCategory == null,
            onSelected: (selected) {
              setState(() {
                _selectedCategory = null;
              });
            },
          ),
          const SizedBox(width: 8),
          ...SuggestionCategory.values.map((category) {
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(category.label),
                selected: _selectedCategory == category,
                avatar: Icon(category.icon, size: 16),
                onSelected: (selected) {
                  setState(() {
                    _selectedCategory = selected ? category : null;
                  });
                },
              ),
            );
          }),
        ],
      ),
    );
  }

  /// Builds a card for a recommendation
  Widget _buildRecommendationCard(Suggestion recommendation) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppConstants.mediumPadding,
        vertical: AppConstants.smallPadding,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.mediumPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title and priority
            Row(
              children: [
                Icon(
                  recommendation.category.icon,
                  color: recommendation.priority.color,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    recommendation.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _buildPriorityChip(recommendation.priority),
              ],
            ),
            const SizedBox(height: 8),

            // Description
            Text(
              recommendation.description,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),

            // Action button
            if (recommendation.actionUrl != null)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    // Navigate to the action URL
                    Navigator.of(context).pushNamed(recommendation.actionUrl!);
                  },
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Take Action'),
                      SizedBox(width: 4),
                      Icon(Icons.arrow_forward, size: 16),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Builds a priority chip
  Widget _buildPriorityChip(SuggestionPriority priority) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: priority.color.withAlpha(51), // 0.2 * 255 = 51
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        priority.label,
        style: TextStyle(
          color: priority.color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
