import 'package:flutter/material.dart';
import 'package:eventati_book/models/models.dart';
import 'package:eventati_book/styles/app_colors.dart';
import 'package:eventati_book/styles/app_colors_dark.dart';
import 'package:eventati_book/styles/text_styles.dart';
import 'package:eventati_book/utils/utils.dart';

/// A widget that displays a feature comparison table for services
class FeatureComparisonTable extends StatelessWidget {
  /// The services to compare
  final List<dynamic> services;

  /// The type of service being compared
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
    final cardColor = isDarkMode ? AppColorsDark.card : AppColors.card;
    final primaryColor = isDarkMode ? AppColorsDark.primary : AppColors.primary;
    final borderColor = isDarkMode ? Colors.grey[700] : Colors.grey[300];

    // Get features based on service type
    final features = _getFeatures();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Feature Comparison', style: TextStyles.sectionTitle),
          const SizedBox(height: 16),

          // Feature comparison table
          Container(
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: borderColor!),
            ),
            child: Column(
              children: [
                // Header row
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Color.fromRGBO(
                      primaryColor.r.toInt(),
                      primaryColor.g.toInt(),
                      primaryColor.b.toInt(),
                      0.1,
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(8),
                      topRight: Radius.circular(8),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          'Feature',
                          style: TextStyles.bodyLarge.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      ...services.map(
                        (service) => Expanded(
                          flex: 1,
                          child: Text(
                            service.name,
                            style: TextStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Feature rows
                ...features.map(
                  (feature) => Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border(top: BorderSide(color: borderColor)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text(
                            feature.name,
                            style: TextStyles.bodyMedium,
                          ),
                        ),
                        ...services.map(
                          (service) => Expanded(
                            flex: 1,
                            child: _buildFeatureValue(
                              feature,
                              service,
                              primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build the feature value widget
  Widget _buildFeatureValue(
    _Feature feature,
    dynamic service,
    Color primaryColor,
  ) {
    final value = feature.getValue(service);

    if (value is bool) {
      return Center(
        child: Icon(
          value ? Icons.check_circle : Icons.cancel,
          color: value ? Colors.green : Colors.red,
          size: 20,
        ),
      );
    } else if (value is String) {
      return Center(
        child: Text(
          value,
          style: TextStyles.bodyMedium,
          textAlign: TextAlign.center,
        ),
      );
    } else if (value is int || value is double) {
      return Center(
        child: Text(
          value.toString(),
          style: TextStyles.bodyMedium,
          textAlign: TextAlign.center,
        ),
      );
    } else if (value is List) {
      return Center(
        child: Text(
          value.isNotEmpty ? '${value.length} items' : 'None',
          style: TextStyles.bodyMedium,
          textAlign: TextAlign.center,
        ),
      );
    } else {
      return Center(
        child: Text(
          'N/A',
          style: TextStyles.bodyMedium,
          textAlign: TextAlign.center,
        ),
      );
    }
  }

  /// Get features based on service type
  List<_Feature> _getFeatures() {
    switch (serviceType) {
      case 'Venue':
        return [
          _Feature(
            name: 'Capacity',
            getValue:
                (service) =>
                    service is Venue
                        ? '${service.minCapacity} - ${service.maxCapacity} guests'
                        : 'N/A',
          ),
          _Feature(
            name: 'Venue Type',
            getValue:
                (service) =>
                    service is Venue
                        ? service.venueTypes.isNotEmpty
                            ? service.venueTypes.join(', ')
                            : 'Not specified'
                        : 'N/A',
          ),
          _Feature(
            name: 'Features',
            getValue: (service) => service is Venue ? service.features : [],
          ),
          _Feature(
            name: 'Price',
            getValue:
                (service) =>
                    service is Venue
                        ? '\$${service.pricePerEvent.toStringAsFixed(2)}'
                        : 'N/A',
          ),
          _Feature(name: 'Rating', getValue: (service) => service.rating),
        ];
      case 'Catering':
        return [
          _Feature(
            name: 'Cuisine Types',
            getValue:
                (service) =>
                    service is CateringService
                        ? service.cuisineTypes.isNotEmpty
                            ? service.cuisineTypes.join(', ')
                            : 'Not specified'
                        : 'N/A',
          ),
          _Feature(
            name: 'Capacity',
            getValue:
                (service) =>
                    service is CateringService
                        ? '${service.minCapacity} - ${service.maxCapacity} guests'
                        : 'N/A',
          ),
          _Feature(
            name: 'Price Per Person',
            getValue:
                (service) =>
                    service is CateringService
                        ? '\$${service.pricePerPerson.toStringAsFixed(2)}'
                        : 'N/A',
          ),
          _Feature(name: 'Rating', getValue: (service) => service.rating),
        ];
      case 'Photographer':
        return [
          _Feature(
            name: 'Styles',
            getValue:
                (service) =>
                    service is Photographer
                        ? service.styles.isNotEmpty
                            ? service.styles.join(', ')
                            : 'Not specified'
                        : 'N/A',
          ),
          _Feature(
            name: 'Equipment',
            getValue:
                (service) => service is Photographer ? service.equipment : [],
          ),
          _Feature(
            name: 'Packages',
            getValue:
                (service) => service is Photographer ? service.packages : [],
          ),
          _Feature(
            name: 'Price',
            getValue:
                (service) =>
                    service is Photographer
                        ? '\$${service.pricePerEvent.toStringAsFixed(2)}'
                        : 'N/A',
          ),
          _Feature(name: 'Rating', getValue: (service) => service.rating),
        ];
      case 'Planner':
        return [
          _Feature(
            name: 'Specialties',
            getValue:
                (service) =>
                    service is Planner
                        ? service.specialties.isNotEmpty
                            ? service.specialties.join(', ')
                            : 'Not specified'
                        : 'N/A',
          ),
          _Feature(
            name: 'Years Experience',
            getValue:
                (service) =>
                    service is Planner ? service.yearsExperience : 'N/A',
          ),
          _Feature(
            name: 'Services',
            getValue: (service) => service is Planner ? service.services : [],
          ),
          _Feature(
            name: 'Price',
            getValue:
                (service) =>
                    service is Planner
                        ? '\$${service.pricePerEvent.toStringAsFixed(2)}'
                        : 'N/A',
          ),
          _Feature(name: 'Rating', getValue: (service) => service.rating),
        ];
      default:
        return [
          _Feature(name: 'Rating', getValue: (service) => service.rating),
          _Feature(
            name: 'Price',
            getValue: (service) => '\$${service.price.toStringAsFixed(2)}',
          ),
        ];
    }
  }
}

/// A feature to compare
class _Feature {
  /// The name of the feature
  final String name;

  /// Function to get the value of the feature from a service
  final dynamic Function(dynamic) getValue;

  /// Constructor
  _Feature({required this.name, required this.getValue});
}
