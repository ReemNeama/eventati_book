import 'package:flutter/material.dart';
import 'package:eventati_book/models/models.dart';
import 'package:eventati_book/styles/app_colors.dart';
import 'package:eventati_book/styles/app_colors_dark.dart';
import 'package:eventati_book/utils/utils.dart';

/// Table widget for comparing features of services
class FeatureComparisonTable extends StatelessWidget {
  /// The services to compare
  final List<dynamic> services;

  /// The type of service (Venue, Catering, Photographer, Planner)
  final String serviceType;

  /// Constructor
  const FeatureComparisonTable({
    super.key,
    required this.services,
    required this.serviceType,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = UIUtils.isDarkMode(context);
    final primaryColor = isDarkMode ? AppColorsDark.primary : AppColors.primary;

    if (services.isEmpty) {
      return const Center(child: Text('No services selected for comparison'));
    }

    // Get the features to compare based on service type
    final List<Map<String, dynamic>> features = _getFeaturesToCompare();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.mediumPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Table header with service names
          Row(
            children: [
              // Feature column header
              SizedBox(
                width: 120,
                child: Text(
                  'Feature',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
              ),

              // Service column headers
              ...services.map((service) {
                String name = '';
                if (serviceType == 'Venue' && service is Venue) {
                  name = service.name;
                } else if (serviceType == 'Catering' &&
                    service is CateringService) {
                  name = service.name;
                } else if (serviceType == 'Photographer' &&
                    service is Photographer) {
                  name = service.name;
                } else if (serviceType == 'Planner' && service is Planner) {
                  name = service.name;
                }

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.smallPadding,
                    ),
                    child: Text(
                      name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                );
              }),
            ],
          ),

          const Divider(height: 32, thickness: 1),

          // Feature rows
          ...features.map((feature) {
            return Padding(
              padding: const EdgeInsets.only(
                bottom: AppConstants.mediumPadding,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Feature name
                  SizedBox(
                    width: 120,
                    child: Text(
                      feature['name'],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),

                  // Feature values for each service
                  ...services.map((service) {
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppConstants.smallPadding,
                        ),
                        child: _buildFeatureValue(
                          service,
                          feature,
                          services,
                          isDarkMode,
                        ),
                      ),
                    );
                  }),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  /// Get the list of features to compare based on service type
  List<Map<String, dynamic>> _getFeaturesToCompare() {
    // Return different features based on service type
    if (serviceType == 'Venue') {
      return [
        {
          'name': 'Venue Type',
          'key': 'venueTypes',
          'type': 'list',
          'compare': false,
        },
        {
          'name': 'Min Capacity',
          'key': 'minCapacity',
          'type': 'number',
          'compare': false,
        },
        {
          'name': 'Max Capacity',
          'key': 'maxCapacity',
          'type': 'number',
          'compare': true,
          'higher_is_better': true,
        },
        {
          'name': 'Price',
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
    } else if (serviceType == 'Catering') {
      return [
        {
          'name': 'Cuisine Types',
          'key': 'cuisineTypes',
          'type': 'list',
          'compare': false,
        },
        {
          'name': 'Min Capacity',
          'key': 'minCapacity',
          'type': 'number',
          'compare': false,
        },
        {
          'name': 'Max Capacity',
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
      ];
    } else if (serviceType == 'Photographer') {
      return [
        {'name': 'Styles', 'key': 'styles', 'type': 'list', 'compare': false},
        {
          'name': 'Price',
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
    } else if (serviceType == 'Planner') {
      return [
        {
          'name': 'Specialties',
          'key': 'specialties',
          'type': 'list',
          'compare': false,
        },
        {
          'name': 'Years Experience',
          'key': 'yearsExperience',
          'type': 'number',
          'compare': true,
          'higher_is_better': true,
        },
        {
          'name': 'Price',
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

    return [];
  }

  /// Build a widget to display a feature value with comparison indicators
  Widget _buildFeatureValue(
    dynamic service,
    Map<String, dynamic> feature,
    List<dynamic> allServices,
    bool isDarkMode,
  ) {
    final goodColor = isDarkMode ? Colors.green[300] : Colors.green;
    final badColor = isDarkMode ? Colors.red[300] : Colors.red;

    // Get the value based on service type and feature key
    dynamic value;

    if (serviceType == 'Venue' && service is Venue) {
      value = _getValueFromObject(service, feature['key']);
    } else if (serviceType == 'Catering' && service is CateringService) {
      value = _getValueFromObject(service, feature['key']);
    } else if (serviceType == 'Photographer' && service is Photographer) {
      value = _getValueFromObject(service, feature['key']);
    } else if (serviceType == 'Planner' && service is Planner) {
      value = _getValueFromObject(service, feature['key']);
    }

    // Format the value based on its type
    Widget valueWidget;

    if (feature['type'] == 'list' && value is List) {
      valueWidget = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children:
            value.map<Widget>((item) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.check, size: 14),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(item, style: const TextStyle(fontSize: 12)),
                    ),
                  ],
                ),
              );
            }).toList(),
      );
    } else if (feature['type'] == 'number') {
      valueWidget = Text(value.toString());
    } else if (feature['type'] == 'price') {
      valueWidget = Text('\$${value.toStringAsFixed(2)}');
    } else {
      valueWidget = Text(value.toString());
    }

    // Add comparison indicator if this feature should be compared
    if (feature['compare'] && allServices.length > 1) {
      if (feature['type'] == 'list' && value is List) {
        // For lists, the best value is the one with the most items
        int maxItems = 0;

        for (final s in allServices) {
          final dynamic v = _getValueFromObject(s, feature['key']);
          if (v is List && v.length > maxItems) {
            maxItems = v.length;
          }
        }

        // Highlight if this service has the most items
        if (value.length == maxItems) {
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
      } else if (feature['type'] == 'number' || feature['type'] == 'price') {
        // For numbers and prices, find the best value
        bool isBest = false;

        if (feature['higher_is_better']) {
          // Higher is better (e.g., capacity, years experience)
          double maxValue = double.negativeInfinity;

          for (final s in allServices) {
            final dynamic v = _getValueFromObject(s, feature['key']);
            if (v is num && v > maxValue) {
              maxValue = v.toDouble();
            }
          }

          isBest = value is num && value.toDouble() == maxValue;
        } else {
          // Lower is better (e.g., price)
          double minValue = double.infinity;

          for (final s in allServices) {
            final dynamic v = _getValueFromObject(s, feature['key']);
            if (v is num && v < minValue) {
              minValue = v.toDouble();
            }
          }

          isBest = value is num && value.toDouble() == minValue;
        }

        if (isBest) {
          return Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color:
                  feature['higher_is_better']
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
                  feature['higher_is_better']
                      ? Icons.thumb_up
                      : Icons.thumb_down,
                  size: 14,
                  color: feature['higher_is_better'] ? goodColor : badColor,
                ),
              ],
            ),
          );
        }
      }
    }

    return valueWidget;
  }

  /// Get a value from an object based on the key
  dynamic _getValueFromObject(dynamic object, String key) {
    if (object is Venue) {
      switch (key) {
        case 'venueTypes':
          return object.venueTypes;
        case 'minCapacity':
          return object.minCapacity;
        case 'maxCapacity':
          return object.maxCapacity;
        case 'pricePerEvent':
          return object.pricePerEvent;
        case 'features':
          return object.features;
        default:
          return null;
      }
    } else if (object is CateringService) {
      switch (key) {
        case 'cuisineTypes':
          return object.cuisineTypes;
        case 'minCapacity':
          return object.minCapacity;
        case 'maxCapacity':
          return object.maxCapacity;
        case 'pricePerPerson':
          return object.pricePerPerson;
        default:
          return null;
      }
    } else if (object is Photographer) {
      switch (key) {
        case 'styles':
          return object.styles;
        case 'pricePerEvent':
          return object.pricePerEvent;
        case 'equipment':
          return object.equipment;
        case 'packages':
          return object.packages;
        default:
          return null;
      }
    } else if (object is Planner) {
      switch (key) {
        case 'specialties':
          return object.specialties;
        case 'yearsExperience':
          return object.yearsExperience;
        case 'pricePerEvent':
          return object.pricePerEvent;
        case 'services':
          return object.services;
        default:
          return null;
      }
    }

    return null;
  }
}
