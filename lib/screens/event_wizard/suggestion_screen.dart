import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:eventati_book/models/suggestion.dart';
import 'package:eventati_book/providers/suggestion_provider.dart';
import 'package:eventati_book/providers/wizard_provider.dart';
import 'package:eventati_book/styles/app_colors.dart';
import 'package:eventati_book/styles/app_colors_dark.dart';

import 'package:eventati_book/widgets/event_wizard/suggestion_card.dart';
import 'package:eventati_book/widgets/common/loading_indicator.dart';
import 'package:eventati_book/widgets/common/error_message.dart';
import 'package:eventati_book/screens/event_wizard/create_suggestion_screen.dart';

/// Screen to display suggestions based on the wizard state
class SuggestionScreen extends StatefulWidget {
  const SuggestionScreen({super.key});

  @override
  State<SuggestionScreen> createState() => _SuggestionScreenState();
}

class _SuggestionScreenState extends State<SuggestionScreen> {
  SuggestionCategory? _selectedCategory;

  @override
  void initState() {
    super.initState();
    // Initialize suggestions when the screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeSuggestions();
    });
  }

  /// Initialize suggestions based on the wizard state
  Future<void> _initializeSuggestions() async {
    final suggestionProvider = Provider.of<SuggestionProvider>(
      context,
      listen: false,
    );
    final wizardProvider = Provider.of<WizardProvider>(context, listen: false);

    // Initialize the suggestion provider if needed
    if (suggestionProvider.allSuggestions.isEmpty) {
      await suggestionProvider.initialize();
    } else {
      // Force a refresh of the suggestions
      await suggestionProvider.initialize();
    }

    // Filter suggestions based on the wizard state
    if (wizardProvider.state != null) {
      suggestionProvider.filterSuggestions(wizardProvider.state!);
    }

    // Reset category filter if any
    if (_selectedCategory != null) {
      _filterByCategory(_selectedCategory);
    }
  }

  /// Filter suggestions by category
  void _filterByCategory(SuggestionCategory? category) {
    setState(() {
      _selectedCategory = category;
    });

    final suggestionProvider = Provider.of<SuggestionProvider>(
      context,
      listen: false,
    );

    // Apply the category filter
    suggestionProvider.setCategoryFilter(category);

    // No need to call filterSuggestions again as setCategoryFilter now handles this
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDarkMode ? AppColorsDark.primary : AppColors.primary;
    final backgroundColor =
        isDarkMode ? AppColorsDark.background : AppColors.background;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Suggestions for You'),
        backgroundColor: primaryColor,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Navigate to create suggestion screen
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CreateSuggestionScreen(),
            ),
          );

          // Refresh suggestions if a new suggestion was added
          if (result == true) {
            _initializeSuggestions();
          }
        },
        backgroundColor: primaryColor,
        child: const Icon(Icons.add),
      ),
      body: Container(
        color: backgroundColor,
        child: Column(
          children: [
            // Category filter chips
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: _buildCategoryFilters(),
            ),

            // Suggestions list
            Expanded(
              child: Consumer2<SuggestionProvider, WizardProvider>(
                builder: (context, suggestionProvider, wizardProvider, _) {
                  // Show loading indicator if loading
                  if (suggestionProvider.isLoading) {
                    return const LoadingIndicator();
                  }

                  // Show error message if there's an error
                  if (suggestionProvider.error != null) {
                    return ErrorMessage(message: suggestionProvider.error!);
                  }

                  // Show empty state if no suggestions
                  if (suggestionProvider.filteredSuggestions.isEmpty) {
                    return _buildEmptyState();
                  }

                  // Show suggestions list
                  return _buildSuggestionsList(
                    suggestionProvider,
                    wizardProvider,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build the category filter chips
  Widget _buildCategoryFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          // All categories chip
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: FilterChip(
              label: const Text('All'),
              selected: _selectedCategory == null,
              onSelected: (selected) {
                if (selected) {
                  _filterByCategory(null);
                }
              },
            ),
          ),

          // Category chips
          ...SuggestionCategory.values.map((category) {
            return Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: FilterChip(
                label: Text(category.label),
                avatar: Icon(category.icon, size: 16),
                selected: _selectedCategory == category,
                onSelected: (selected) {
                  if (selected) {
                    _filterByCategory(category);
                  } else {
                    _filterByCategory(null);
                  }
                },
              ),
            );
          }),
        ],
      ),
    );
  }

  /// Build the suggestions list
  Widget _buildSuggestionsList(
    SuggestionProvider suggestionProvider,
    WizardProvider wizardProvider,
  ) {
    final suggestions = suggestionProvider.filteredSuggestions;

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final suggestion = suggestions[index];
        final relevanceScore =
            wizardProvider.state != null
                ? suggestion.calculateRelevanceScore(wizardProvider.state!)
                : suggestion.baseRelevanceScore;

        return SuggestionCard(
          suggestion: suggestion,
          relevanceScore: relevanceScore,
          onTap: () => _showSuggestionDetails(suggestion, relevanceScore),
        );
      },
    );
  }

  /// Build the empty state widget
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.lightbulb_outline, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text(
            'No suggestions available',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Complete more of your event details\nto get personalized suggestions',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  /// Show suggestion details in a bottom sheet
  void _showSuggestionDetails(Suggestion suggestion, int relevanceScore) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDarkMode ? AppColorsDark.primary : AppColors.primary;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          maxChildSize: 0.9,
          minChildSize: 0.5,
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title and category
                    Row(
                      children: [
                        Icon(
                          suggestion.category.icon,
                          color: primaryColor,
                          size: 28,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            suggestion.title,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Relevance score
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: primaryColor.withAlpha(25),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star, size: 16, color: Colors.amber),
                          const SizedBox(width: 4),
                          Text(
                            'Relevance: $relevanceScore%',
                            style: TextStyle(
                              color: primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Priority
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: suggestion.priority.color.withAlpha(25),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.flag,
                            size: 16,
                            color: suggestion.priority.color,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Priority: ${suggestion.priority.label}',
                            style: TextStyle(
                              color: suggestion.priority.color,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Description
                    const Text(
                      'Description',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      suggestion.description,
                      style: const TextStyle(fontSize: 16, height: 1.5),
                    ),

                    const SizedBox(height: 32),

                    // Action button
                    if (suggestion.actionUrl != null)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.pushNamed(context, suggestion.actionUrl!);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Take Action',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
