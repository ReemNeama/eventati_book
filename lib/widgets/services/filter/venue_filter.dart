import 'package:flutter/material.dart';
import 'package:eventati_book/models/models.dart';
import 'package:eventati_book/providers/providers.dart';

/// Helper class for filtering venues
class VenueFilter {
  /// Filter venues based on search query, venue types, price range, capacity range, and recommendation
  static List<Venue> filterVenues({
    required List<Venue> venues,
    required String searchQuery,
    required List<String> selectedVenueTypes,
    required RangeValues priceRange,
    required RangeValues capacityRange,
    required bool showRecommendedOnly,
    required ServiceRecommendationProvider recommendationProvider,
  }) {
    return venues.where((venue) {
      return _matchesSearchQuery(venue, searchQuery) &&
          _matchesVenueTypes(venue, selectedVenueTypes) &&
          _matchesPriceRange(venue, priceRange) &&
          _matchesCapacityRange(venue, capacityRange) &&
          _matchesRecommendation(
            venue,
            showRecommendedOnly,
            recommendationProvider,
          );
    }).toList();
  }

  /// Sort venues based on sort option and recommendation status
  static List<Venue> sortVenues({
    required List<Venue> venues,
    required String sortOption,
    required bool showRecommendedOnly,
    required ServiceRecommendationProvider recommendationProvider,
  }) {
    venues.sort((a, b) {
      // If showing recommended only, sort recommended venues first
      if (showRecommendedOnly) {
        final aIsRecommended = recommendationProvider.isVenueRecommended(a);
        final bIsRecommended = recommendationProvider.isVenueRecommended(b);

        if (aIsRecommended && !bIsRecommended) return -1;
        if (!aIsRecommended && bIsRecommended) return 1;
      }

      // Sort based on selected option
      switch (sortOption) {
        case 'Price (Low to High)':
          return a.pricePerEvent.compareTo(b.pricePerEvent);
        case 'Price (High to Low)':
          return b.pricePerEvent.compareTo(a.pricePerEvent);
        case 'Rating':
          return b.rating.compareTo(a.rating);
        case 'Capacity':
          return b.maxCapacity.compareTo(a.maxCapacity);
        default:
          return b.rating.compareTo(a.rating);
      }
    });

    return venues;
  }

  /// Check if a venue matches the search query
  static bool _matchesSearchQuery(Venue venue, String query) {
    if (query.isEmpty) return true;

    final lowercaseQuery = query.toLowerCase();
    return venue.name.toLowerCase().contains(lowercaseQuery) ||
        venue.description.toLowerCase().contains(lowercaseQuery);
  }

  /// Check if a venue matches the selected venue types
  static bool _matchesVenueTypes(Venue venue, List<String> selectedTypes) {
    if (selectedTypes.isEmpty) return true;

    return venue.venueTypes.any((type) => selectedTypes.contains(type));
  }

  /// Check if a venue matches the price range
  static bool _matchesPriceRange(Venue venue, RangeValues priceRange) {
    return venue.pricePerEvent >= priceRange.start &&
        venue.pricePerEvent <= priceRange.end;
  }

  /// Check if a venue matches the capacity range
  static bool _matchesCapacityRange(Venue venue, RangeValues capacityRange) {
    return venue.maxCapacity >= capacityRange.start &&
        venue.minCapacity <= capacityRange.end;
  }

  /// Check if a venue matches the recommendation filter
  static bool _matchesRecommendation(
    Venue venue,
    bool showRecommendedOnly,
    ServiceRecommendationProvider provider,
  ) {
    if (!showRecommendedOnly) return true;

    return provider.isVenueRecommended(venue);
  }
}
