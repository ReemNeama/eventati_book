import 'package:eventati_book/tempDB/data/catering_data.dart';
import 'package:eventati_book/tempDB/data/photography_data.dart';

/// Temporary database for service data
class ServiceDB {
  /// Get all catering services
  static List<Map<String, dynamic>> getCateringServices() {
    return CateringData.getCateringServices();
  }

  /// Get all photography services
  static List<Map<String, dynamic>> getPhotographyServices() {
    return PhotographyData.getPhotographyServices();
  }

  /// Get service by ID and type
  static Map<String, dynamic>? getServiceById(String id, String type) {
    List<Map<String, dynamic>> services;

    if (type == 'catering') {
      services = getCateringServices();
    } else if (type == 'photography') {
      services = getPhotographyServices();
    } else {
      return null;
    }

    try {
      return services.firstWhere((service) => service['id'] == id);
    } catch (e) {
      return null;
    }
  }

  /// Search services by name or description
  static List<Map<String, dynamic>> searchServices(String query, String type) {
    List<Map<String, dynamic>> services;

    if (type == 'catering') {
      services = getCateringServices();
    } else if (type == 'photography') {
      services = getPhotographyServices();
    } else {
      return [];
    }

    final lowercaseQuery = query.toLowerCase();

    return services.where((service) {
      final name = service['name'].toString().toLowerCase();
      final description = service['description'].toString().toLowerCase();

      return name.contains(lowercaseQuery) ||
          description.contains(lowercaseQuery);
    }).toList();
  }

  /// Filter services by criteria
  static List<Map<String, dynamic>> filterServices({
    required String type,
    String? priceRange,
    double? minRating,
    List<String>? features,
  }) {
    List<Map<String, dynamic>> services;

    if (type == 'catering') {
      services = getCateringServices();
    } else if (type == 'photography') {
      services = getPhotographyServices();
    } else {
      return [];
    }

    if (priceRange != null) {
      services =
          services
              .where((service) => service['priceRange'] == priceRange)
              .toList();
    }

    if (minRating != null) {
      services =
          services.where((service) => service['rating'] >= minRating).toList();
    }

    if (features != null && features.isNotEmpty) {
      services =
          services.where((service) {
            final serviceFeatures = List<String>.from(service['features']);
            return features.every(
              (feature) => serviceFeatures.contains(feature),
            );
          }).toList();
    }

    return services;
  }
}
