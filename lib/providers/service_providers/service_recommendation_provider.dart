import 'package:flutter/foundation.dart';
import 'package:eventati_book/di/service_locator.dart';
import 'package:eventati_book/models/models.dart';
import 'package:eventati_book/services/supabase/database/vendor_recommendation_database_service.dart';
import 'package:eventati_book/utils/logger.dart';

/// Provider for service recommendations based on wizard data
class ServiceRecommendationProvider with ChangeNotifier {
  /// Vendor recommendation service
  final VendorRecommendationDatabaseService _recommendationService;

  /// Current wizard state
  WizardState? _wizardState;

  /// List of recommendations
  List<Suggestion> _recommendations = [];

  /// Whether the provider is loading data
  bool _isLoading = false;

  /// Error message if loading fails
  String? _errorMessage;

  /// Whether recommendations have been initialized
  bool _initialized = false;

  /// Constructor
  ServiceRecommendationProvider({
    VendorRecommendationDatabaseService? recommendationService,
    WizardState? initialWizardState,
  }) : _recommendationService =
           recommendationService ??
           serviceLocator.vendorRecommendationDatabaseService {
    if (initialWizardState != null) {
      _wizardState = initialWizardState;
      _loadRecommendations();
    }
  }

  /// Get the current wizard state
  WizardState? get wizardState => _wizardState;

  /// Get the list of recommendations
  List<Suggestion> get recommendations => _recommendations;

  /// Get whether the provider is loading data
  bool get isLoading => _isLoading;

  /// Get the error message
  String? get errorMessage => _errorMessage;

  /// Get whether recommendations have been initialized
  bool get initialized => _initialized;

  /// Set the wizard state and load recommendations
  Future<void> setWizardState(WizardState wizardState) async {
    _wizardState = wizardState;
    await _loadRecommendations();
  }

  /// Load recommendations based on the current wizard state
  Future<void> _loadRecommendations() async {
    if (_wizardState == null) {
      _errorMessage = 'No wizard state available';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Get personalized recommendations
      final recommendations = await _recommendationService
          .getPersonalizedRecommendations(_wizardState!);

      _recommendations = recommendations;
      _initialized = true;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to load recommendations: ${e.toString()}';
      Logger.e(_errorMessage!, tag: 'ServiceRecommendationProvider');
      notifyListeners();
    }
  }

  /// Refresh recommendations
  Future<void> refreshRecommendations() async {
    await _loadRecommendations();
  }

  /// Get recommendations for a specific category
  List<Suggestion> getRecommendationsForCategory(SuggestionCategory category) {
    return _recommendations
        .where((recommendation) => recommendation.category == category)
        .toList();
  }

  /// Get high priority recommendations
  List<Suggestion> get highPriorityRecommendations {
    return _recommendations
        .where(
          (recommendation) =>
              recommendation.priority == SuggestionPriority.high,
        )
        .toList();
  }

  /// Get medium priority recommendations
  List<Suggestion> get mediumPriorityRecommendations {
    return _recommendations
        .where(
          (recommendation) =>
              recommendation.priority == SuggestionPriority.medium,
        )
        .toList();
  }

  /// Get low priority recommendations
  List<Suggestion> get lowPriorityRecommendations {
    return _recommendations
        .where(
          (recommendation) => recommendation.priority == SuggestionPriority.low,
        )
        .toList();
  }

  /// Get venue recommendations
  List<Suggestion> get venueRecommendations {
    return getRecommendationsForCategory(SuggestionCategory.venue);
  }

  /// Get catering recommendations
  List<Suggestion> get cateringRecommendations {
    return getRecommendationsForCategory(SuggestionCategory.catering);
  }

  /// Get photography recommendations
  List<Suggestion> get photographyRecommendations {
    return getRecommendationsForCategory(SuggestionCategory.photography);
  }

  /// Get entertainment recommendations
  List<Suggestion> get entertainmentRecommendations {
    return getRecommendationsForCategory(SuggestionCategory.entertainment);
  }

  /// Get decoration recommendations
  List<Suggestion> get decorationRecommendations {
    return getRecommendationsForCategory(SuggestionCategory.decoration);
  }

  /// Get similar recommendations to the given recommendation
  List<Suggestion> getSimilarRecommendations(
    Suggestion recommendation, {
    int maxCount = 5,
  }) {
    // First, try to find recommendations in the same category
    final similarRecommendations = <Suggestion>[];

    // Add recommendations in the same category
    similarRecommendations.addAll(
      _recommendations
          .where(
            (r) =>
                r.id != recommendation.id &&
                r.category == recommendation.category,
          )
          .toList(),
    );

    // If we don't have enough, add recommendations with similar tags
    if (similarRecommendations.length < maxCount &&
        recommendation.tags.isNotEmpty) {
      final recommendationsWithSimilarTags =
          _recommendations.where((r) {
            return r.id != recommendation.id &&
                r.category != recommendation.category &&
                r.tags.any((tag) => recommendation.tags.contains(tag));
          }).toList();

      // Add recommendations with similar tags that aren't already in the list
      for (final r in recommendationsWithSimilarTags) {
        if (similarRecommendations.length >= maxCount) break;
        if (!similarRecommendations.any((similar) => similar.id == r.id)) {
          similarRecommendations.add(r);
        }
      }
    }

    // If we still don't have enough, add recommendations for the same event type
    if (similarRecommendations.length < maxCount &&
        recommendation.applicableEventTypes.isNotEmpty) {
      final recommendationsForSameEventType =
          _recommendations.where((r) {
            return r.id != recommendation.id &&
                !similarRecommendations.any((similar) => similar.id == r.id) &&
                r.applicableEventTypes.any(
                  (type) => recommendation.applicableEventTypes.contains(type),
                );
          }).toList();

      // Add recommendations for the same event type that aren't already in the list
      for (final r in recommendationsForSameEventType) {
        if (similarRecommendations.length >= maxCount) break;
        similarRecommendations.add(r);
      }
    }

    // Sort by relevance score
    similarRecommendations.sort((a, b) {
      if (_wizardState != null) {
        final scoreA = a.calculateRelevanceScore(_wizardState!);
        final scoreB = b.calculateRelevanceScore(_wizardState!);
        return scoreB.compareTo(scoreA); // Higher score first
      } else {
        return b.baseRelevanceScore.compareTo(a.baseRelevanceScore);
      }
    });

    // Limit to maxCount
    return similarRecommendations.take(maxCount).toList();
  }

  /// Filter recommendations by category
  List<Suggestion> filterRecommendationsByCategory(
    List<Suggestion> recommendations,
    SuggestionCategory? category,
  ) {
    if (category == null) {
      return recommendations;
    }
    return recommendations
        .where((recommendation) => recommendation.category == category)
        .toList();
  }

  /// Filter recommendations by price range
  List<Suggestion> filterRecommendationsByPriceRange(
    List<Suggestion> recommendations,
    double minPrice,
    double maxPrice,
  ) {
    // This is a placeholder implementation since we don't have actual price data
    // In a real app, you would filter based on actual price data
    return recommendations;
  }

  /// Filter recommendations by availability
  List<Suggestion> filterRecommendationsByAvailability(
    List<Suggestion> recommendations,
    bool showOnlyAvailable,
  ) {
    // This is a placeholder implementation since we don't have actual availability data
    // In a real app, you would filter based on actual availability data
    return recommendations;
  }

  /// Sort recommendations by relevance
  List<Suggestion> sortRecommendationsByRelevance(
    List<Suggestion> recommendations,
  ) {
    if (_wizardState == null) {
      return recommendations
        ..sort((a, b) => b.baseRelevanceScore.compareTo(a.baseRelevanceScore));
    }

    final sortedRecommendations = List<Suggestion>.from(recommendations);
    sortedRecommendations.sort((a, b) {
      final scoreA = a.calculateRelevanceScore(_wizardState!);
      final scoreB = b.calculateRelevanceScore(_wizardState!);
      return scoreB.compareTo(scoreA); // Higher score first
    });
    return sortedRecommendations;
  }

  /// Sort recommendations by price (low to high)
  List<Suggestion> sortRecommendationsByPriceLowToHigh(
    List<Suggestion> recommendations,
  ) {
    // This is a placeholder implementation since we don't have actual price data
    // In a real app, you would sort based on actual price data
    return recommendations;
  }

  /// Sort recommendations by price (high to low)
  List<Suggestion> sortRecommendationsByPriceHighToLow(
    List<Suggestion> recommendations,
  ) {
    // This is a placeholder implementation since we don't have actual price data
    // In a real app, you would sort based on actual price data
    return recommendations;
  }

  /// Sort recommendations by rating
  List<Suggestion> sortRecommendationsByRating(
    List<Suggestion> recommendations,
  ) {
    // This is a placeholder implementation since we don't have actual rating data
    // In a real app, you would sort based on actual rating data
    return recommendations;
  }

  /// Sort recommendations by popularity
  List<Suggestion> sortRecommendationsByPopularity(
    List<Suggestion> recommendations,
  ) {
    // This is a placeholder implementation since we don't have actual popularity data
    // In a real app, you would sort based on actual popularity data
    return recommendations;
  }

  /// Seed the database with predefined recommendations
  Future<void> seedPredefinedRecommendations() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _recommendationService.seedPredefinedRecommendations();
      await _loadRecommendations();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to seed recommendations: ${e.toString()}';
      Logger.e(_errorMessage!, tag: 'ServiceRecommendationProvider');
      notifyListeners();
    }
  }
}
