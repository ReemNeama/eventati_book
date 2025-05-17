import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:eventati_book/models/models.dart';
import 'package:eventati_book/providers/providers.dart';
import 'package:eventati_book/utils/utils.dart';
import 'package:eventati_book/styles/app_colors.dart';
import 'package:eventati_book/styles/app_colors_dark.dart';
import 'package:eventati_book/widgets/common/loading_indicator.dart';
import 'package:eventati_book/widgets/recommendations/category_filter_bar.dart';
import 'package:eventati_book/widgets/recommendations/sorting_options_dropdown.dart';
import 'package:eventati_book/widgets/recommendations/vendor_recommendation_card.dart';
import 'package:eventati_book/screens/recommendations/recommendation_details_screen.dart';

/// Screen for displaying vendor recommendations based on wizard data
class VendorRecommendationsScreen extends StatefulWidget {
  /// The ID of the event
  final String eventId;

  /// The name of the event
  final String eventName;

  /// Creates a new vendor recommendations screen
  const VendorRecommendationsScreen({
    super.key,
    required this.eventId,
    required this.eventName,
  });

  @override
  State<VendorRecommendationsScreen> createState() =>
      _VendorRecommendationsScreenState();
}

class _VendorRecommendationsScreenState
    extends State<VendorRecommendationsScreen> {
  /// The currently selected category filter
  SuggestionCategory? _selectedCategory;

  /// The currently selected sort option
  String _sortOption = 'Relevance';

  /// Available sort options
  final List<String> _sortOptions = [
    'Relevance',
    'Price (Low to High)',
    'Price (High to Low)',
    'Rating',
    'Popularity',
  ];

  /// Whether to show only available vendors
  bool _showOnlyAvailable = false;

  /// The selected price range
  RangeValues _priceRange = const RangeValues(0, 5000);

  /// The minimum price value
  static const double _minPrice = 0;

  /// The maximum price value
  static const double _maxPrice = 5000;

  /// Set of saved recommendation IDs
  final Set<String> _savedRecommendations = {};

  @override
  Widget build(BuildContext context) {
    final isDarkMode = UIUtils.isDarkMode(context);
    final backgroundColor =
        isDarkMode ? AppColorsDark.background : AppColors.background;

    return Scaffold(
      appBar: AppBar(
        title: Text('Recommendations for ${widget.eventName}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
            tooltip: 'Filter Options',
          ),
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
      body: Container(
        color: backgroundColor,
        child: Consumer<ServiceRecommendationProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return const LoadingIndicator();
            }

            if (provider.errorMessage != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
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

            final recommendations = provider.recommendations;

            if (recommendations.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.lightbulb_outline,
                      color: Colors.amber,
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

            // Filter and sort recommendations
            final filteredRecommendations = _filterRecommendations(
              recommendations,
            );
            final sortedRecommendations = _sortRecommendations(
              filteredRecommendations,
            );

            return Column(
              children: [
                // Category filter
                Padding(
                  padding: const EdgeInsets.all(AppConstants.mediumPadding),
                  child: CategoryFilterBar(
                    selectedCategory: _selectedCategory,
                    onCategorySelected: (category) {
                      setState(() {
                        _selectedCategory = category;
                      });
                    },
                  ),
                ),

                // Sorting options
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.mediumPadding,
                  ),
                  child: Row(
                    children: [
                      const Text('Sort by:'),
                      const SizedBox(width: 8),
                      SortingOptionsDropdown(
                        options: _sortOptions,
                        selectedOption: _sortOption,
                        onOptionSelected: (option) {
                          setState(() {
                            _sortOption = option;
                          });
                        },
                      ),
                    ],
                  ),
                ),

                // Recommendations list
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(AppConstants.mediumPadding),
                    itemCount: sortedRecommendations.length,
                    itemBuilder: (context, index) {
                      final recommendation = sortedRecommendations[index];
                      return VendorRecommendationCard(
                        recommendation: recommendation,
                        eventId: widget.eventId,
                        onTap: () => _showRecommendationDetails(recommendation),
                        onCompare: () => _addToComparison(recommendation),
                        onSave: () => _toggleSaveRecommendation(recommendation),
                        isSaved: _isSaved(recommendation),
                        showAnimation:
                            index < 3, // Animate only the first few items
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  /// Filter recommendations based on selected filters
  List<Suggestion> _filterRecommendations(List<Suggestion> recommendations) {
    final provider = Provider.of<ServiceRecommendationProvider>(
      context,
      listen: false,
    );

    // Apply category filter
    var filteredRecommendations = provider.filterRecommendationsByCategory(
      recommendations,
      _selectedCategory,
    );

    // Apply price range filter
    filteredRecommendations = provider.filterRecommendationsByPriceRange(
      filteredRecommendations,
      _priceRange.start,
      _priceRange.end,
    );

    // Apply availability filter
    filteredRecommendations = provider.filterRecommendationsByAvailability(
      filteredRecommendations,
      _showOnlyAvailable,
    );

    return filteredRecommendations;
  }

  /// Sort recommendations based on selected sort option
  List<Suggestion> _sortRecommendations(List<Suggestion> recommendations) {
    final provider = Provider.of<ServiceRecommendationProvider>(
      context,
      listen: false,
    );

    switch (_sortOption) {
      case 'Relevance':
        return provider.sortRecommendationsByRelevance(recommendations);
      case 'Price (Low to High)':
        return provider.sortRecommendationsByPriceLowToHigh(recommendations);
      case 'Price (High to Low)':
        return provider.sortRecommendationsByPriceHighToLow(recommendations);
      case 'Rating':
        return provider.sortRecommendationsByRating(recommendations);
      case 'Popularity':
        return provider.sortRecommendationsByPopularity(recommendations);
      default:
        return provider.sortRecommendationsByRelevance(recommendations);
    }
  }

  /// Show recommendation details
  void _showRecommendationDetails(Suggestion recommendation) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => RecommendationDetailsScreen(
              recommendation: recommendation,
              eventId: widget.eventId,
            ),
      ),
    );
  }

  /// Check if a recommendation is saved
  bool _isSaved(Suggestion recommendation) {
    return _savedRecommendations.contains(recommendation.id);
  }

  /// Toggle saving a recommendation
  void _toggleSaveRecommendation(Suggestion recommendation) {
    setState(() {
      if (_isSaved(recommendation)) {
        _savedRecommendations.remove(recommendation.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${recommendation.title} removed from saved'),
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        _savedRecommendations.add(recommendation.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${recommendation.title} added to saved'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    });
    // Save to SharedPreferences
    _saveToSharedPreferences(recommendation);
  }

  /// Add a recommendation to comparison
  void _addToComparison(Suggestion recommendation) {
    // Get the comparison provider
    final comparisonProvider = Provider.of<ComparisonProvider>(
      context,
      listen: false,
    );

    // Add the recommendation to comparison
    comparisonProvider.toggleServiceSelection(recommendation);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${recommendation.title} added to comparison'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// Save a recommendation to SharedPreferences
  Future<void> _saveToSharedPreferences(Suggestion recommendation) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Get existing saved recommendations
      final savedRecommendations =
          prefs.getStringList('saved_recommendations') ?? [];

      // Add the recommendation ID if it's not already saved
      if (!savedRecommendations.contains(recommendation.id)) {
        savedRecommendations.add(recommendation.id);
        await prefs.setStringList(
          'saved_recommendations',
          savedRecommendations,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving recommendation: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  /// Show filter dialog
  void _showFilterDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Filter Options'),
            content: StatefulBuilder(
              builder: (context, setDialogState) {
                return SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Price range filter
                      const Text('Price Range'),
                      RangeSlider(
                        values: _priceRange,
                        min: _minPrice,
                        max: _maxPrice,
                        divisions: 50,
                        labels: RangeLabels(
                          '\$${_priceRange.start.round()}',
                          '\$${_priceRange.end.round()}',
                        ),
                        onChanged: (values) {
                          setDialogState(() {
                            _priceRange = values;
                          });
                        },
                      ),

                      // Availability filter
                      CheckboxListTile(
                        title: const Text('Show Only Available'),
                        value: _showOnlyAvailable,
                        onChanged: (value) {
                          setDialogState(() {
                            _showOnlyAvailable = value ?? false;
                          });
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    // Apply filters
                    // The filters will be applied in the _filterRecommendations method
                  });
                  Navigator.pop(context);
                },
                child: const Text('Apply'),
              ),
            ],
          ),
    );
  }
}
