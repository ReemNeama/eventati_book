import 'package:flutter/material.dart';
import 'package:eventati_book/models/models.dart';
import 'package:eventati_book/utils/utils.dart';

/// Builder class for feature comparison values
class FeatureValueBuilder {
  /// Build a widget to display a feature value with comparison indicators
  static Widget buildFeatureValue({
    required dynamic service,
    required Map<String, dynamic> feature,
    required List<dynamic> allServices,
    required String serviceType,
    required bool isDarkMode,
  }) {
    // Get the value based on service type and feature key
    final value = _getValueFromService(service, feature['key'], serviceType);

    // Format the value based on its type
    Widget valueWidget = _buildValueWidget(value, feature['type']);

    // Add comparison indicator if this feature should be compared
    if (feature['compare'] == true && allServices.length > 1) {
      return _addComparisonIndicator(
        valueWidget: valueWidget,
        value: value,
        feature: feature,
        allServices: allServices,
        serviceType: serviceType,
        isDarkMode: isDarkMode,
      );
    }

    return valueWidget;
  }

  /// Get a value from a service based on its type and key
  static dynamic _getValueFromService(
    dynamic service,
    String key,
    String serviceType,
  ) {
    if (serviceType == 'Venue' && service is Venue) {
      return _getVenueValue(service, key);
    } else if (serviceType == 'Catering' && service is CateringService) {
      return _getCateringValue(service, key);
    } else if (serviceType == 'Photographer' && service is Photographer) {
      return _getPhotographerValue(service, key);
    } else if (serviceType == 'Planner' && service is Planner) {
      return _getPlannerValue(service, key);
    }

    return null;
  }

  /// Get a value from a Venue object
  static dynamic _getVenueValue(Venue venue, String key) {
    switch (key) {
      case 'venueTypes':
        return venue.venueTypes;
      case 'minCapacity':
        return venue.minCapacity;
      case 'maxCapacity':
        return venue.maxCapacity;
      case 'pricePerEvent':
        return venue.pricePerEvent;
      case 'features':
        return venue.features;
      default:
        return null;
    }
  }

  /// Get a value from a CateringService object
  static dynamic _getCateringValue(CateringService service, String key) {
    switch (key) {
      case 'cuisineTypes':
        return service.cuisineTypes;
      case 'minCapacity':
        return service.minCapacity;
      case 'maxCapacity':
        return service.maxCapacity;
      case 'pricePerPerson':
        return service.pricePerPerson;
      default:
        return null;
    }
  }

  /// Get a value from a Photographer object
  static dynamic _getPhotographerValue(Photographer photographer, String key) {
    switch (key) {
      case 'styles':
        return photographer.styles;
      case 'pricePerEvent':
        return photographer.pricePerEvent;
      case 'equipment':
        return photographer.equipment;
      case 'packages':
        return photographer.packages;
      default:
        return null;
    }
  }

  /// Get a value from a Planner object
  static dynamic _getPlannerValue(Planner planner, String key) {
    switch (key) {
      case 'specialties':
        return planner.specialties;
      case 'yearsExperience':
        return planner.yearsExperience;
      case 'pricePerEvent':
        return planner.pricePerEvent;
      case 'services':
        return planner.services;
      default:
        return null;
    }
  }

  /// Build a widget to display a value based on its type
  static Widget _buildValueWidget(dynamic value, String type) {
    if (type == 'list' && value is List) {
      return _buildListValue(value);
    } else if (type == 'number' && value is num) {
      return Text(value.toString());
    } else if (type == 'price' && value is num) {
      return Text('\$${value.toStringAsFixed(2)}');
    } else if (value != null) {
      return Text(value.toString());
    } else {
      return const Text('-');
    }
  }

  /// Build a widget to display a list value
  static Widget _buildListValue(List<dynamic> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items.map<Widget>((item) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.check, size: 14),
              const SizedBox(width: 4),
              Expanded(
                child: Text(item.toString(), style: const TextStyle(fontSize: 12)),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  /// Add a comparison indicator to a value widget
  static Widget _addComparisonIndicator({
    required Widget valueWidget,
    required dynamic value,
    required Map<String, dynamic> feature,
    required List<dynamic> allServices,
    required String serviceType,
    required bool isDarkMode,
  }) {
    final goodColor = isDarkMode ? Colors.green[300] : Colors.green;
    final badColor = isDarkMode ? Colors.red[300] : Colors.red;
    final bool isBest;

    if (feature['type'] == 'list' && value is List) {
      isBest = _isListFeatureBest(value, feature, allServices, serviceType);
      
      if (isBest) {
        return Stack(
          children: [
            valueWidget,
            Positioned(
              top: 0,
              right: 0,
              child: Icon(
                Icons.star,
                size: 16,
                color: feature['higher_is_better'] ? goodColor : badColor,
              ),
            ),
          ],
        );
      }
    } else if ((feature['type'] == 'number' || feature['type'] == 'price') && value is num) {
      isBest = _isNumberFeatureBest(value, feature, allServices, serviceType);
      
      if (isBest) {
        return Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: feature['higher_is_better']
                ? goodColor!.withAlpha(51) // 0.2 * 255 = 51
                : badColor!.withAlpha(51),
            borderRadius: BorderRadius.circular(
              AppConstants.smallBorderRadius,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              valueWidget,
              const SizedBox(width: 4),
              Icon(
                feature['higher_is_better'] ? Icons.thumb_up : Icons.thumb_down,
                size: 14,
                color: feature['higher_is_better'] ? goodColor : badColor,
              ),
            ],
          ),
        );
      }
    }

    return valueWidget;
  }

  /// Check if a list feature has the best value
  static bool _isListFeatureBest(
    List<dynamic> value,
    Map<String, dynamic> feature,
    List<dynamic> allServices,
    String serviceType,
  ) {
    // For lists, the best value is the one with the most items
    int maxItems = 0;

    for (final service in allServices) {
      final dynamic serviceValue = _getValueFromService(
        service,
        feature['key'],
        serviceType,
      );
      
      if (serviceValue is List && serviceValue.length > maxItems) {
        maxItems = serviceValue.length;
      }
    }

    // Highlight if this service has the most items
    return value.length == maxItems;
  }

  /// Check if a number feature has the best value
  static bool _isNumberFeatureBest(
    num value,
    Map<String, dynamic> feature,
    List<dynamic> allServices,
    String serviceType,
  ) {
    if (feature['higher_is_better']) {
      // Higher is better (e.g., capacity, years experience)
      double maxValue = double.negativeInfinity;

      for (final service in allServices) {
        final dynamic serviceValue = _getValueFromService(
          service,
          feature['key'],
          serviceType,
        );
        
        if (serviceValue is num && serviceValue > maxValue) {
          maxValue = serviceValue.toDouble();
        }
      }

      return value.toDouble() == maxValue;
    } else {
      // Lower is better (e.g., price)
      double minValue = double.infinity;

      for (final service in allServices) {
        final dynamic serviceValue = _getValueFromService(
          service,
          feature['key'],
          serviceType,
        );
        
        if (serviceValue is num && serviceValue < minValue) {
          minValue = serviceValue.toDouble();
        }
      }

      return value.toDouble() == minValue;
    }
  }
}
