import 'package:flutter/foundation.dart';
import 'package:eventati_book/di/service_locator.dart';
import 'package:eventati_book/models/models.dart';
import 'package:eventati_book/services/supabase/database/vendor_recommendation_database_service.dart';
import 'package:eventati_book/utils/logger.dart';

/// Provider for recommending services based on event wizard data.
///
/// The ServiceRecommendationProvider is responsible for:
/// * Storing event data from the wizard (guest count, event type, selected services)
/// * Determining which services are recommended based on the event requirements
/// * Providing recommendation reasons for each service type
/// * Filtering services to show only recommended ones if desired
///
/// This provider analyzes event requirements from the wizard and matches them
/// with service capabilities to provide personalized recommendations for venues,
/// catering services, photographers, and planners.
class ServiceRecommendationProvider with ChangeNotifier {
  /// Vendor recommendation service
  final VendorRecommendationDatabaseService _recommendationService;

  /// Event data from the wizard, including event type, guest count, and selected services
  ///
  /// This data is used to determine which services are recommended for the event.
  /// It's typically set by the WizardConnectionService when the user completes the wizard.
  /// The map contains keys like 'eventType', 'guestCount', and 'selectedServices'.
  Map<String, dynamic>? _wizardData;

  /// The current wizard state
  WizardState? _wizardState;

  /// List of recommendations
  List<Suggestion> _recommendations = [];

  /// Flag indicating whether to show only recommended services in service listings
  ///
  /// When true, service screens should filter out non-recommended services.
  /// When false, all services should be shown, with recommended ones highlighted.
  bool _showOnlyRecommended = false;

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

  /// Returns the current wizard data, or null if no data has been set
  ///
  /// This data includes event type, guest count, and selected services.
  Map<String, dynamic>? get wizardData => _wizardData;

  /// Get the current wizard state
  WizardState? get wizardState => _wizardState;

  /// Get the list of recommendations
  List<Suggestion> get recommendations => _recommendations;

  /// Get the list of personalized recommendations (alias for recommendations)
  List<Suggestion> get personalizedRecommendations => _recommendations;

  /// Get whether the provider is loading data
  bool get isLoading => _isLoading;

  /// Get the error message
  String? get errorMessage => _errorMessage;

  /// Get whether recommendations have been initialized
  bool get initialized => _initialized;

  /// Indicates whether to show only recommended services
  ///
  /// Service screens can use this to filter their listings.
  bool get showOnlyRecommended => _showOnlyRecommended;

  /// Sets the wizard data used for service recommendations
  ///
  /// [data] A map containing event data from the wizard
  ///
  /// This method is typically called by the WizardConnectionService when
  /// the user completes the event wizard. The data should include:
  /// - 'eventType': String (e.g., 'wedding', 'business', 'celebration')
  /// - 'guestCount': int (number of guests)
  /// - 'selectedServices': Map of String to bool (services selected in the wizard)
  ///
  /// Notifies listeners when the data is updated.
  void setWizardData(Map<String, dynamic> data) {
    _wizardData = data;
    notifyListeners();
  }

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

  /// Get personalized recommendations for a specific category
  List<Suggestion> getPersonalizedRecommendationsForCategory(
    SuggestionCategory category,
  ) {
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

  /// Toggles between showing all services and showing only recommended services
  ///
  /// This method inverts the current value of showOnlyRecommended.
  /// Notifies listeners when the value changes.
  void toggleShowOnlyRecommended() {
    _showOnlyRecommended = !_showOnlyRecommended;
    notifyListeners();
  }

  /// Sets whether to show only recommended services
  ///
  /// [value] True to show only recommended services, false to show all services
  ///
  /// Notifies listeners when the value changes.
  void setShowOnlyRecommended(bool value) {
    _showOnlyRecommended = value;
    notifyListeners();
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

  /// Determines if a venue is recommended for the current event
  ///
  /// [venue] The venue to check for recommendation
  ///
  /// This method analyzes the venue's capacity and types to determine if it's
  /// suitable for the event based on the wizard data. A venue is recommended if:
  /// 1. The 'Venue' service was selected in the wizard
  /// 2. The venue can accommodate the guest count
  /// 3. The venue type matches the event type (wedding, business, celebration)
  ///
  /// Returns true if the venue is recommended, false otherwise.
  /// Always returns false if no wizard data has been set.
  bool isVenueRecommended(Venue venue) {
    if (_wizardData == null) return false;

    final int guestCount = _wizardData!['guestCount'] as int;
    final String eventType = _wizardData!['eventType'] as String;
    final Map<String, bool> selectedServices = Map<String, bool>.from(
      _wizardData!['selectedServices'],
    );

    // Check if venue service was selected in the wizard
    if (!selectedServices.containsKey('Venue') || !selectedServices['Venue']!) {
      return false;
    }

    // Check if venue can accommodate the guest count
    final bool hasCapacity =
        venue.minCapacity <= guestCount && venue.maxCapacity >= guestCount;

    // Check if venue is suitable for the event type
    bool matchesEventType = true;
    if (eventType.toLowerCase().contains('wedding')) {
      matchesEventType = venue.venueTypes.any(
        (type) =>
            type.toLowerCase().contains('wedding') ||
            type.toLowerCase().contains('ballroom') ||
            type.toLowerCase().contains('garden'),
      );
    } else if (eventType.toLowerCase().contains('business')) {
      matchesEventType = venue.venueTypes.any(
        (type) =>
            type.toLowerCase().contains('conference') ||
            type.toLowerCase().contains('meeting') ||
            type.toLowerCase().contains('corporate'),
      );
    } else if (eventType.toLowerCase().contains('celebration')) {
      matchesEventType = venue.venueTypes.any(
        (type) =>
            type.toLowerCase().contains('party') ||
            type.toLowerCase().contains('banquet') ||
            type.toLowerCase().contains('restaurant'),
      );
    }

    return hasCapacity && matchesEventType;
  }

  /// Provides a human-readable reason why a venue is recommended
  ///
  /// [venue] The venue to get the recommendation reason for
  ///
  /// This method generates a string explaining why the venue is recommended
  /// for the event, based on its capacity and suitability for the event type.
  /// The reason might include multiple factors, joined by commas.
  ///
  /// Returns a string with the recommendation reason, or null if the venue
  /// is not recommended or no wizard data has been set.
  String? getVenueRecommendationReason(Venue venue) {
    if (!isVenueRecommended(venue) || _wizardData == null) return null;

    final int guestCount = _wizardData!['guestCount'] as int;
    final String eventType = _wizardData!['eventType'] as String;

    final List<String> reasons = [];

    if (venue.minCapacity <= guestCount && venue.maxCapacity >= guestCount) {
      reasons.add('Can accommodate your $guestCount guests');
    }

    if (eventType.toLowerCase().contains('wedding') &&
        venue.venueTypes.any(
          (type) => type.toLowerCase().contains('wedding'),
        )) {
      reasons.add('Perfect for weddings');
    } else if (eventType.toLowerCase().contains('business') &&
        venue.venueTypes.any(
          (type) => type.toLowerCase().contains('conference'),
        )) {
      reasons.add('Ideal for business events');
    } else if (eventType.toLowerCase().contains('celebration') &&
        venue.venueTypes.any((type) => type.toLowerCase().contains('party'))) {
      reasons.add('Great for celebrations');
    }

    return reasons.isNotEmpty ? reasons.join(', ') : null;
  }

  /// Determines if a catering service is recommended for the current event
  ///
  /// [service] The catering service to check for recommendation
  ///
  /// This method analyzes the catering service's capacity and cuisine types to determine
  /// if it's suitable for the event based on the wizard data. A catering service is
  /// recommended if:
  /// 1. The 'Catering' service was selected in the wizard
  /// 2. The service can accommodate the guest count
  /// 3. The service offers cuisine types appropriate for the event type
  ///
  /// For weddings, fine dining and international cuisines are recommended.
  /// For business events, international and Mediterranean cuisines are recommended.
  ///
  /// Returns true if the catering service is recommended, false otherwise.
  /// Always returns false if no wizard data has been set.
  bool isCateringServiceRecommended(CateringService service) {
    if (_wizardData == null) return false;

    final int guestCount = _wizardData!['guestCount'] as int;
    final String eventType = _wizardData!['eventType'] as String;
    final Map<String, bool> selectedServices = Map<String, bool>.from(
      _wizardData!['selectedServices'],
    );

    // Check if catering service was selected in the wizard
    if (!selectedServices.containsKey('Catering') ||
        !selectedServices['Catering']!) {
      return false;
    }

    // Check if service can accommodate the guest count
    final bool hasCapacity =
        service.minCapacity <= guestCount && service.maxCapacity >= guestCount;

    // Check if service is suitable for the event type
    bool matchesEventType = true;
    if (eventType.toLowerCase().contains('wedding')) {
      matchesEventType = service.cuisineTypes.any(
        (type) =>
            type.toLowerCase().contains('fine dining') ||
            type.toLowerCase().contains('international'),
      );
    } else if (eventType.toLowerCase().contains('business')) {
      matchesEventType = service.cuisineTypes.any(
        (type) =>
            type.toLowerCase().contains('international') ||
            type.toLowerCase().contains('mediterranean'),
      );
    }

    return hasCapacity && matchesEventType;
  }

  /// Provides a human-readable reason why a catering service is recommended
  ///
  /// [service] The catering service to get the recommendation reason for
  ///
  /// This method generates a string explaining why the catering service is recommended
  /// for the event, based on its capacity and cuisine types offered.
  /// The reason might include multiple factors, joined by commas.
  ///
  /// For weddings, it highlights fine dining options.
  /// For business events, it highlights professional international cuisine options.
  ///
  /// Returns a string with the recommendation reason, or null if the service
  /// is not recommended or no wizard data has been set.
  String? getCateringRecommendationReason(CateringService service) {
    if (!isCateringServiceRecommended(service) || _wizardData == null) {
      return null;
    }

    final int guestCount = _wizardData!['guestCount'] as int;
    final String eventType = _wizardData!['eventType'] as String;

    final List<String> reasons = [];

    if (service.minCapacity <= guestCount &&
        service.maxCapacity >= guestCount) {
      reasons.add('Can cater for your $guestCount guests');
    }

    if (eventType.toLowerCase().contains('wedding') &&
        service.cuisineTypes.any(
          (type) => type.toLowerCase().contains('fine dining'),
        )) {
      reasons.add('Offers fine dining options perfect for weddings');
    } else if (eventType.toLowerCase().contains('business') &&
        service.cuisineTypes.any(
          (type) => type.toLowerCase().contains('international'),
        )) {
      reasons.add('Professional international cuisine for business events');
    }

    return reasons.isNotEmpty ? reasons.join(', ') : null;
  }

  /// Determines if a photographer is recommended for the current event
  ///
  /// [photographer] The photographer to check for recommendation
  ///
  /// This method analyzes the photographer's styles to determine if they're
  /// suitable for the event based on the wizard data. A photographer is recommended if:
  /// 1. The 'Photography' service was selected in the wizard
  /// 2. The photographer's style matches the event type (wedding, business, celebration)
  ///
  /// Returns true if the photographer is recommended, false otherwise.
  /// Always returns false if no wizard data has been set.
  bool isPhotographerRecommended(Photographer photographer) {
    if (_wizardData == null) return false;

    final String eventType = _wizardData!['eventType'] as String;
    final Map<String, bool> selectedServices = Map<String, bool>.from(
      _wizardData!['selectedServices'],
    );

    // Check if photography service was selected in the wizard
    if (!selectedServices.containsKey('Photography') ||
        !selectedServices['Photography']!) {
      return false;
    }

    // Check if photographer's style matches the event type
    bool matchesEventType = true;
    if (eventType.toLowerCase().contains('wedding')) {
      matchesEventType = photographer.styles.any(
        (style) => style.toLowerCase().contains('wedding'),
      );
    } else if (eventType.toLowerCase().contains('business')) {
      matchesEventType = photographer.styles.any(
        (style) =>
            style.toLowerCase().contains('corporate') ||
            style.toLowerCase().contains('event'),
      );
    } else if (eventType.toLowerCase().contains('celebration')) {
      matchesEventType = photographer.styles.any(
        (style) =>
            style.toLowerCase().contains('event') ||
            style.toLowerCase().contains('party'),
      );
    }

    return matchesEventType;
  }

  /// Provides a human-readable reason why a photographer is recommended
  ///
  /// [photographer] The photographer to get the recommendation reason for
  ///
  /// This method generates a string explaining why the photographer is recommended
  /// for the event, based on their styles and rating.
  /// The reason might include multiple factors, joined by commas.
  ///
  /// Returns a string with the recommendation reason, or null if the photographer
  /// is not recommended or no wizard data has been set.
  String? getPhotographerRecommendationReason(Photographer photographer) {
    if (!isPhotographerRecommended(photographer) || _wizardData == null) {
      return null;
    }

    final String eventType = _wizardData!['eventType'] as String;
    final List<String> reasons = [];

    if (eventType.toLowerCase().contains('wedding') &&
        photographer.styles.any(
          (style) => style.toLowerCase().contains('wedding'),
        )) {
      reasons.add('Specializes in wedding photography');
    } else if (eventType.toLowerCase().contains('business') &&
        photographer.styles.any(
          (style) => style.toLowerCase().contains('corporate'),
        )) {
      reasons.add('Experienced in corporate photography');
    } else if (eventType.toLowerCase().contains('celebration') &&
        photographer.styles.any(
          (style) => style.toLowerCase().contains('event'),
        )) {
      reasons.add('Expert in event photography');
    }

    if (photographer.rating > 4.5) {
      reasons.add('Highly rated (${photographer.rating}/5)');
    }

    return reasons.isNotEmpty ? reasons.join(', ') : null;
  }

  /// Determines if a planner is recommended for the current event
  ///
  /// [planner] The planner to check for recommendation
  ///
  /// This method analyzes the planner's specialties to determine if they're
  /// suitable for the event based on the wizard data. A planner is recommended if:
  /// 1. The 'Planner' service was selected in the wizard
  /// 2. The planner specializes in the event type (wedding, business, celebration)
  ///
  /// Returns true if the planner is recommended, false otherwise.
  /// Always returns false if no wizard data has been set.
  bool isPlannerRecommended(Planner planner) {
    if (_wizardData == null) return false;

    final String eventType = _wizardData!['eventType'] as String;
    final Map<String, bool> selectedServices = Map<String, bool>.from(
      _wizardData!['selectedServices'],
    );

    // Check if planner service was selected in the wizard
    if (!selectedServices.containsKey('Planner') ||
        !selectedServices['Planner']!) {
      return false;
    }

    // Check if planner specializes in the event type
    bool matchesEventType = true;
    if (eventType.toLowerCase().contains('wedding')) {
      matchesEventType = planner.specialties.any(
        (specialty) => specialty.toLowerCase().contains('wedding'),
      );
    } else if (eventType.toLowerCase().contains('business')) {
      matchesEventType = planner.specialties.any(
        (specialty) =>
            specialty.toLowerCase().contains('corporate') ||
            specialty.toLowerCase().contains('business'),
      );
    } else if (eventType.toLowerCase().contains('celebration')) {
      matchesEventType = planner.specialties.any(
        (specialty) =>
            specialty.toLowerCase().contains('event') ||
            specialty.toLowerCase().contains('party'),
      );
    }

    return matchesEventType;
  }

  /// Provides a human-readable reason why a planner is recommended
  ///
  /// [planner] The planner to get the recommendation reason for
  ///
  /// This method generates a string explaining why the planner is recommended
  /// for the event, based on their specialties and experience.
  /// The reason might include multiple factors, joined by commas.
  ///
  /// Returns a string with the recommendation reason, or null if the planner
  /// is not recommended or no wizard data has been set.
  String? getPlannerRecommendationReason(Planner planner) {
    if (!isPlannerRecommended(planner) || _wizardData == null) {
      return null;
    }

    final String eventType = _wizardData!['eventType'] as String;
    final List<String> reasons = [];

    if (eventType.toLowerCase().contains('wedding') &&
        planner.specialties.any(
          (specialty) => specialty.toLowerCase().contains('wedding'),
        )) {
      reasons.add('Specializes in wedding planning');
    } else if (eventType.toLowerCase().contains('business') &&
        planner.specialties.any(
          (specialty) => specialty.toLowerCase().contains('corporate'),
        )) {
      reasons.add('Experienced in corporate event planning');
    } else if (eventType.toLowerCase().contains('celebration') &&
        planner.specialties.any(
          (specialty) => specialty.toLowerCase().contains('event'),
        )) {
      reasons.add('Expert in event planning');
    }

    if (planner.yearsExperience > 5) {
      reasons.add('${planner.yearsExperience} years of experience');
    }

    if (planner.rating > 4.5) {
      reasons.add('Highly rated (${planner.rating}/5)');
    }

    return reasons.isNotEmpty ? reasons.join(', ') : null;
  }
}
