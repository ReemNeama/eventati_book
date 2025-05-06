import 'package:eventati_book/tempDB/data/venue_data.dart';

/// Temporary database for venue data
class VenueDB {
  /// Get all venues
  static List<Map<String, dynamic>> getVenues() {
    return VenueData.getVenues();
  }

  /// Get recommended venues
  static List<Map<String, dynamic>> getRecommendedVenues() {
    return getVenues().where((venue) => venue['rating'] >= 4.7).toList();
  }

  /// Get venue by ID
  static Map<String, dynamic>? getVenueById(String id) {
    final venues = getVenues();
    try {
      return venues.firstWhere((venue) => venue['id'] == id);
    } catch (e) {
      return null;
    }
  }

  /// Search venues by name or location
  static List<Map<String, dynamic>> searchVenues(String query) {
    final venues = getVenues();
    final lowercaseQuery = query.toLowerCase();

    return venues.where((venue) {
      final name = venue['name'].toString().toLowerCase();
      final location = venue['location'].toString().toLowerCase();
      final description = venue['description'].toString().toLowerCase();

      return name.contains(lowercaseQuery) ||
          location.contains(lowercaseQuery) ||
          description.contains(lowercaseQuery);
    }).toList();
  }

  /// Filter venues by criteria
  static List<Map<String, dynamic>> filterVenues({
    int? minCapacity,
    int? maxCapacity,
    List<String>? features,
    String? priceRange,
    double? minRating,
  }) {
    var venues = getVenues();

    if (minCapacity != null) {
      venues = venues.where((venue) => venue['capacity'] >= minCapacity).toList();
    }

    if (maxCapacity != null) {
      venues = venues.where((venue) => venue['capacity'] <= maxCapacity).toList();
    }

    if (features != null && features.isNotEmpty) {
      venues = venues.where((venue) {
        final venueFeatures = List<String>.from(venue['features']);
        return features.every((feature) => venueFeatures.contains(feature));
      }).toList();
    }

    if (priceRange != null) {
      venues = venues.where((venue) => venue['priceRange'] == priceRange).toList();
    }

    if (minRating != null) {
      venues = venues.where((venue) => venue['rating'] >= minRating).toList();
    }

    return venues;
  }
}
