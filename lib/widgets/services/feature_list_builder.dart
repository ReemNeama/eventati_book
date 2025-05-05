import 'package:flutter/material.dart';

/// Builder class for feature comparison lists
class FeatureListBuilder {
  /// Get the list of features to compare for a specific service type
  static List<Map<String, dynamic>> getFeaturesToCompare(String serviceType) {
    switch (serviceType) {
      case 'Venue':
        return _getVenueFeatures();
      case 'Catering':
        return _getCateringFeatures();
      case 'Photographer':
        return _getPhotographerFeatures();
      case 'Planner':
        return _getPlannerFeatures();
      default:
        return [];
    }
  }

  /// Get the list of venue features to compare
  static List<Map<String, dynamic>> _getVenueFeatures() {
    return [
      {
        'name': 'Venue Types',
        'key': 'venueTypes',
        'type': 'list',
        'compare': true,
        'higher_is_better': true,
      },
      {
        'name': 'Minimum Capacity',
        'key': 'minCapacity',
        'type': 'number',
        'compare': true,
        'higher_is_better': false,
      },
      {
        'name': 'Maximum Capacity',
        'key': 'maxCapacity',
        'type': 'number',
        'compare': true,
        'higher_is_better': true,
      },
      {
        'name': 'Price Per Event',
        'key': 'pricePerEvent',
        'type': 'price',
        'compare': true,
        'higher_is_better': false,
      },
      {
        'name': 'Features',
        'key': 'features',
        'type': 'list',
        'compare': true,
        'higher_is_better': true,
      },
    ];
  }

  /// Get the list of catering features to compare
  static List<Map<String, dynamic>> _getCateringFeatures() {
    return [
      {
        'name': 'Cuisine Types',
        'key': 'cuisineTypes',
        'type': 'list',
        'compare': true,
        'higher_is_better': true,
      },
      {
        'name': 'Minimum Capacity',
        'key': 'minCapacity',
        'type': 'number',
        'compare': true,
        'higher_is_better': false,
      },
      {
        'name': 'Maximum Capacity',
        'key': 'maxCapacity',
        'type': 'number',
        'compare': true,
        'higher_is_better': true,
      },
      {
        'name': 'Price Per Person',
        'key': 'pricePerPerson',
        'type': 'price',
        'compare': true,
        'higher_is_better': false,
      },
      {
        'name': 'Dietary Accommodations',
        'key': 'dietaryAccommodations',
        'type': 'list',
        'compare': true,
        'higher_is_better': true,
      },
      {
        'name': 'Service Types',
        'key': 'serviceTypes',
        'type': 'list',
        'compare': true,
        'higher_is_better': true,
      },
    ];
  }

  /// Get the list of photographer features to compare
  static List<Map<String, dynamic>> _getPhotographerFeatures() {
    return [
      {
        'name': 'Photography Styles',
        'key': 'styles',
        'type': 'list',
        'compare': true,
        'higher_is_better': true,
      },
      {
        'name': 'Price Per Event',
        'key': 'pricePerEvent',
        'type': 'price',
        'compare': true,
        'higher_is_better': false,
      },
      {
        'name': 'Equipment',
        'key': 'equipment',
        'type': 'list',
        'compare': true,
        'higher_is_better': true,
      },
      {
        'name': 'Packages',
        'key': 'packages',
        'type': 'list',
        'compare': true,
        'higher_is_better': true,
      },
    ];
  }

  /// Get the list of planner features to compare
  static List<Map<String, dynamic>> _getPlannerFeatures() {
    return [
      {
        'name': 'Specialties',
        'key': 'specialties',
        'type': 'list',
        'compare': true,
        'higher_is_better': true,
      },
      {
        'name': 'Years of Experience',
        'key': 'yearsExperience',
        'type': 'number',
        'compare': true,
        'higher_is_better': true,
      },
      {
        'name': 'Price Per Event',
        'key': 'pricePerEvent',
        'type': 'price',
        'compare': true,
        'higher_is_better': false,
      },
      {
        'name': 'Services',
        'key': 'services',
        'type': 'list',
        'compare': true,
        'higher_is_better': true,
      },
    ];
  }
}
