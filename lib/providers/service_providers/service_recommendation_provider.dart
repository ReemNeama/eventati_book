import 'package:flutter/foundation.dart';
import 'package:eventati_book/di/service_locator.dart';
import 'package:eventati_book/models/models.dart';
import 'package:eventati_book/services/firebase/firestore/vendor_recommendation_firestore_service.dart';
import 'package:eventati_book/utils/logger.dart';

/// Provider for service recommendations based on wizard data
class ServiceRecommendationProvider with ChangeNotifier {
  /// Vendor recommendation service
  final VendorRecommendationFirestoreService _recommendationService;

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
    VendorRecommendationFirestoreService? recommendationService,
    WizardState? initialWizardState,
  }) : _recommendationService =
            recommendationService ?? serviceLocator.vendorRecommendationFirestoreService {
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
      final recommendations =
          await _recommendationService.getPersonalizedRecommendations(
        _wizardState!,
      );

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
        .where((recommendation) => recommendation.priority == SuggestionPriority.high)
        .toList();
  }

  /// Get medium priority recommendations
  List<Suggestion> get mediumPriorityRecommendations {
    return _recommendations
        .where((recommendation) => recommendation.priority == SuggestionPriority.medium)
        .toList();
  }

  /// Get low priority recommendations
  List<Suggestion> get lowPriorityRecommendations {
    return _recommendations
        .where((recommendation) => recommendation.priority == SuggestionPriority.low)
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
