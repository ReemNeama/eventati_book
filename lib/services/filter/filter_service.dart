import 'package:flutter/material.dart';
import 'package:eventati_book/models/models.dart';
import 'package:eventati_book/providers/providers.dart';

/// A service for filtering different types of services
class FilterService {
  /// Filter venues based on criteria
  static List<Venue> filterVenues({
    required List<Venue> venues,
    required String searchQuery,
    required List<String> selectedVenueTypes,
    required RangeValues priceRange,
    required RangeValues capacityRange,
    required bool showRecommendedOnly,
    required ServiceRecommendationProvider recommendationProvider,
    List<String>? selectedFeatures,
    bool? showAvailableOnly,
  }) {
    return venues.where((venue) {
      // Basic filters
      final matchesSearch = _matchesSearchQuery(
        venue.name,
        venue.description,
        searchQuery,
      );
      final matchesVenueTypes =
          selectedVenueTypes.isEmpty ||
          venue.venueTypes.any((type) => selectedVenueTypes.contains(type));
      final matchesPrice =
          venue.pricePerEvent >= priceRange.start &&
          venue.pricePerEvent <= priceRange.end;
      final matchesCapacity =
          venue.maxCapacity >= capacityRange.start &&
          venue.minCapacity <= capacityRange.end;
      final matchesRecommendation =
          !showRecommendedOnly ||
          recommendationProvider.isVenueRecommended(venue);

      // Additional filters
      final matchesFeatures =
          selectedFeatures == null ||
          selectedFeatures.isEmpty ||
          venue.features.any((feature) => selectedFeatures.contains(feature));
      final matchesAvailability =
          showAvailableOnly == null ||
          !showAvailableOnly ||
          true; // Venue availability not implemented yet

      return matchesSearch &&
          matchesVenueTypes &&
          matchesPrice &&
          matchesCapacity &&
          matchesRecommendation &&
          matchesFeatures &&
          matchesAvailability;
    }).toList();
  }

  /// Filter catering services based on criteria
  static List<CateringService> filterCateringServices({
    required List<CateringService> services,
    required String searchQuery,
    required List<String> selectedCuisineTypes,
    required RangeValues priceRange,
    required RangeValues capacityRange,
    required bool showRecommendedOnly,
    required ServiceRecommendationProvider recommendationProvider,
    bool? showAvailableOnly,
  }) {
    return services.where((service) {
      // Basic filters
      final matchesSearch = _matchesSearchQuery(
        service.name,
        service.description,
        searchQuery,
      );
      final matchesCuisine =
          selectedCuisineTypes.isEmpty ||
          service.cuisineTypes.any(
            (cuisine) => selectedCuisineTypes.contains(cuisine),
          );
      final matchesPrice =
          service.pricePerPerson >= priceRange.start &&
          service.pricePerPerson <= priceRange.end;
      final matchesCapacity =
          service.maxCapacity >= capacityRange.start &&
          service.minCapacity <= capacityRange.end;
      final matchesRecommendation =
          !showRecommendedOnly ||
          recommendationProvider.isCateringServiceRecommended(service);

      // Additional filters
      final matchesAvailability =
          showAvailableOnly == null ||
          !showAvailableOnly ||
          true; // Service availability not implemented yet

      return matchesSearch &&
          matchesCuisine &&
          matchesPrice &&
          matchesCapacity &&
          matchesRecommendation &&
          matchesAvailability;
    }).toList();
  }

  /// Filter photographers based on criteria
  static List<Photographer> filterPhotographers({
    required List<Photographer> photographers,
    required String searchQuery,
    required List<String> selectedStyles,
    required RangeValues priceRange,
    required bool showRecommendedOnly,
    required ServiceRecommendationProvider recommendationProvider,
    List<String>? selectedEquipment,
    bool? showAvailableOnly,
  }) {
    return photographers.where((photographer) {
      // Basic filters
      final matchesSearch = _matchesSearchQuery(
        photographer.name,
        photographer.description,
        searchQuery,
      );
      final matchesStyles =
          selectedStyles.isEmpty ||
          photographer.styles.any((style) => selectedStyles.contains(style));
      final matchesPrice =
          photographer.pricePerEvent >= priceRange.start &&
          photographer.pricePerEvent <= priceRange.end;
      final matchesRecommendation =
          !showRecommendedOnly ||
          recommendationProvider.isPhotographerRecommended(photographer);

      // Additional filters
      final matchesEquipment =
          selectedEquipment == null ||
          selectedEquipment.isEmpty ||
          photographer.equipment.any(
            (item) => selectedEquipment.contains(item),
          );
      final matchesAvailability =
          showAvailableOnly == null ||
          !showAvailableOnly ||
          true; // Photographer availability not implemented yet

      return matchesSearch &&
          matchesStyles &&
          matchesPrice &&
          matchesRecommendation &&
          matchesEquipment &&
          matchesAvailability;
    }).toList();
  }

  /// Generic method to check if a service matches a search query
  static bool _matchesSearchQuery(
    String name,
    String description,
    String query,
  ) {
    if (query.isEmpty) return true;

    final lowercaseQuery = query.toLowerCase();
    return name.toLowerCase().contains(lowercaseQuery) ||
        description.toLowerCase().contains(lowercaseQuery);
  }
}
