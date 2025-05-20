import 'package:eventati_book/models/models.dart';
import 'package:eventati_book/providers/providers.dart';

/// Sort options for services
enum SortOption {
  /// Sort by rating (high to low)
  rating,

  /// Sort by price (low to high)
  priceLowToHigh,

  /// Sort by price (high to low)
  priceHighToLow,

  /// Sort by capacity (high to low)
  capacity,

  /// Sort by name (A to Z)
  nameAZ,

  /// Sort by name (Z to A)
  nameZA,

  /// Sort by newest first
  newest,

  /// Sort by popularity
  popularity,
}

/// A service for sorting different types of services
class SortService {
  /// Get the display name for a sort option
  static String getSortOptionName(SortOption option) {
    switch (option) {
      case SortOption.rating:
        return 'Rating';
      case SortOption.priceLowToHigh:
        return 'Price (Low to High)';
      case SortOption.priceHighToLow:
        return 'Price (High to Low)';
      case SortOption.capacity:
        return 'Capacity';
      case SortOption.nameAZ:
        return 'Name (A to Z)';
      case SortOption.nameZA:
        return 'Name (Z to A)';
      case SortOption.newest:
        return 'Newest First';
      case SortOption.popularity:
        return 'Popularity';
    }
  }

  /// Get all available sort options
  static List<String> getAllSortOptions() {
    return SortOption.values
        .map((option) => getSortOptionName(option))
        .toList();
  }

  /// Get sort option from name
  static SortOption getSortOptionFromName(String name) {
    return SortOption.values.firstWhere(
      (option) => getSortOptionName(option) == name,
      orElse: () => SortOption.rating,
    );
  }

  /// Sort venues based on sort option and recommendation status
  static List<Venue> sortVenues({
    required List<Venue> venues,
    required String sortOptionName,
    required bool showRecommendedOnly,
    required ServiceRecommendationProvider recommendationProvider,
  }) {
    final sortOption = getSortOptionFromName(sortOptionName);

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
        case SortOption.rating:
          return b.rating.compareTo(a.rating);
        case SortOption.priceLowToHigh:
          return a.pricePerEvent.compareTo(b.pricePerEvent);
        case SortOption.priceHighToLow:
          return b.pricePerEvent.compareTo(a.pricePerEvent);
        case SortOption.capacity:
          return b.maxCapacity.compareTo(a.maxCapacity);
        case SortOption.nameAZ:
          return a.name.compareTo(b.name);
        case SortOption.nameZA:
          return b.name.compareTo(a.name);
        case SortOption.newest:
          if (a.createdAt == null || b.createdAt == null) return 0;
          return b.createdAt!.compareTo(a.createdAt!);
        case SortOption.popularity:
          // Popularity not implemented yet, fallback to rating
          return b.rating.compareTo(a.rating);
      }
    });

    return venues;
  }

  /// Sort catering services based on sort option and recommendation status
  static List<CateringService> sortCateringServices({
    required List<CateringService> services,
    required String sortOptionName,
    required bool showRecommendedOnly,
    required ServiceRecommendationProvider recommendationProvider,
  }) {
    final sortOption = getSortOptionFromName(sortOptionName);

    services.sort((a, b) {
      // If showing recommended only, sort recommended services first
      if (showRecommendedOnly) {
        final aIsRecommended = recommendationProvider
            .isCateringServiceRecommended(a);
        final bIsRecommended = recommendationProvider
            .isCateringServiceRecommended(b);

        if (aIsRecommended && !bIsRecommended) return -1;
        if (!aIsRecommended && bIsRecommended) return 1;
      }

      // Sort based on selected option
      switch (sortOption) {
        case SortOption.rating:
          return b.rating.compareTo(a.rating);
        case SortOption.priceLowToHigh:
          return a.pricePerPerson.compareTo(b.pricePerPerson);
        case SortOption.priceHighToLow:
          return b.pricePerPerson.compareTo(a.pricePerPerson);
        case SortOption.capacity:
          return b.maxCapacity.compareTo(a.maxCapacity);
        case SortOption.nameAZ:
          return a.name.compareTo(b.name);
        case SortOption.nameZA:
          return b.name.compareTo(a.name);
        case SortOption.newest:
          if (a.createdAt == null || b.createdAt == null) return 0;
          return b.createdAt!.compareTo(a.createdAt!);
        case SortOption.popularity:
          // Popularity not implemented yet, fallback to rating
          return b.rating.compareTo(a.rating);
      }
    });

    return services;
  }

  /// Sort photographers based on sort option and recommendation status
  static List<Photographer> sortPhotographers({
    required List<Photographer> photographers,
    required String sortOptionName,
    required bool showRecommendedOnly,
    required ServiceRecommendationProvider recommendationProvider,
  }) {
    final sortOption = getSortOptionFromName(sortOptionName);

    photographers.sort((a, b) {
      // If showing recommended only, sort recommended photographers first
      if (showRecommendedOnly) {
        final aIsRecommended = recommendationProvider.isPhotographerRecommended(
          a,
        );
        final bIsRecommended = recommendationProvider.isPhotographerRecommended(
          b,
        );

        if (aIsRecommended && !bIsRecommended) return -1;
        if (!aIsRecommended && bIsRecommended) return 1;
      }

      // Sort based on selected option
      switch (sortOption) {
        case SortOption.rating:
          return b.rating.compareTo(a.rating);
        case SortOption.priceLowToHigh:
          return a.pricePerEvent.compareTo(b.pricePerEvent);
        case SortOption.priceHighToLow:
          return b.pricePerEvent.compareTo(a.pricePerEvent);
        case SortOption.capacity:
          // Photographers don't have capacity, fallback to rating
          return b.rating.compareTo(a.rating);
        case SortOption.nameAZ:
          return a.name.compareTo(b.name);
        case SortOption.nameZA:
          return b.name.compareTo(a.name);
        case SortOption.newest:
          if (a.createdAt == null || b.createdAt == null) return 0;
          return b.createdAt!.compareTo(a.createdAt!);
        case SortOption.popularity:
          // Popularity not implemented yet, fallback to rating
          return b.rating.compareTo(a.rating);
      }
    });

    return photographers;
  }
}
