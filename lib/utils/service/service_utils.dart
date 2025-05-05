import 'package:flutter/material.dart';
import 'package:eventati_book/utils/formatting/number_utils.dart';

/// Utility functions for service-related operations
class ServiceUtils {
  /// Format price for display
  static String formatPrice(
    double price, {
    bool showPerPerson = false,
    bool showPerEvent = false,
    int decimalPlaces = 0,
  }) {
    final formattedPrice = NumberUtils.formatCurrency(
      price,
      decimalPlaces: decimalPlaces,
    );

    if (showPerPerson) {
      return '$formattedPrice/person';
    } else if (showPerEvent) {
      return '$formattedPrice/event';
    } else {
      return formattedPrice;
    }
  }

  /// Format capacity range for display
  static String formatCapacityRange(int minCapacity, int maxCapacity) {
    return 'Capacity: ${NumberUtils.formatWithCommas(minCapacity)}-${NumberUtils.formatWithCommas(maxCapacity)} guests';
  }

  /// Format experience for display
  static String formatExperience(int years) {
    return 'Experience: $years ${years == 1 ? 'year' : 'years'}';
  }

  /// Format rating for display
  static String formatRating(double rating) {
    return rating.toStringAsFixed(1);
  }

  /// Sort services by rating (high to low)
  static List<T> sortByRating<T>(
    List<T> services,
    double Function(T) getRating,
  ) {
    return List.from(services)
      ..sort((a, b) => getRating(b).compareTo(getRating(a)));
  }

  /// Sort services by price (low to high)
  static List<T> sortByPriceLowToHigh<T>(
    List<T> services,
    double Function(T) getPrice,
  ) {
    return List.from(services)
      ..sort((a, b) => getPrice(a).compareTo(getPrice(b)));
  }

  /// Sort services by price (high to low)
  static List<T> sortByPriceHighToLow<T>(
    List<T> services,
    double Function(T) getPrice,
  ) {
    return List.from(services)
      ..sort((a, b) => getPrice(b).compareTo(getPrice(a)));
  }

  /// Sort services by capacity
  static List<T> sortByCapacity<T>(
    List<T> services,
    int Function(T) getCapacity,
  ) {
    return List.from(services)
      ..sort((a, b) => getCapacity(b).compareTo(getCapacity(a)));
  }

  /// Filter services by price range
  static List<T> filterByPriceRange<T>(
    List<T> services,
    double Function(T) getPrice,
    RangeValues priceRange,
  ) {
    return services.where((service) {
      final price = getPrice(service);

      return price >= priceRange.start && price <= priceRange.end;
    }).toList();
  }

  /// Filter services by capacity range
  static List<T> filterByCapacityRange<T>(
    List<T> services,
    int Function(T) getMinCapacity,
    int Function(T) getMaxCapacity,
    RangeValues capacityRange,
  ) {
    return services.where((service) {
      final maxCapacity = getMaxCapacity(service);
      final minCapacity = getMinCapacity(service);

      return maxCapacity >= capacityRange.start &&
          minCapacity <= capacityRange.end;
    }).toList();
  }

  /// Filter services by search query
  static List<T> filterBySearchQuery<T>(
    List<T> services,
    String Function(T) getName,
    String Function(T) getDescription,
    String searchQuery,
  ) {
    if (searchQuery.isEmpty) return services;

    final query = searchQuery.toLowerCase();

    return services.where((service) {
      final name = getName(service).toLowerCase();
      final description = getDescription(service).toLowerCase();

      return name.contains(query) || description.contains(query);
    }).toList();
  }

  /// Filter services by tags/categories
  static List<T> filterByTags<T>(
    List<T> services,
    List<String> Function(T) getTags,
    List<String> selectedTags,
  ) {
    if (selectedTags.isEmpty) return services;

    return services.where((service) {
      final tags = getTags(service);

      return tags.any((tag) => selectedTags.contains(tag));
    }).toList();
  }
}
