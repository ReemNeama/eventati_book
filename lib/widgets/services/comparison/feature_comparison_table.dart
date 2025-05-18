import 'package:flutter/material.dart';
import 'package:eventati_book/models/models.dart';
import 'package:eventati_book/styles/app_colors.dart';
import 'package:eventati_book/styles/app_colors_dark.dart';
import 'package:eventati_book/utils/utils.dart';
import 'package:eventati_book/widgets/services/comparison/feature_value_builder.dart';
import 'package:eventati_book/widgets/services/comparison/feature_list_builder.dart';


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
    return FeatureListBuilder.getFeaturesToCompare(serviceType);
  }

  /// Build a widget to display a feature value with comparison indicators
  Widget _buildFeatureValue(
    dynamic service,
    Map<String, dynamic> feature,
    List<dynamic> allServices,
    bool isDarkMode,
  ) {
    return FeatureValueBuilder.buildFeatureValue(
      service: service,
      feature: feature,
      allServices: allServices,
      serviceType: serviceType,
      isDarkMode: isDarkMode,
    );
  }
}
