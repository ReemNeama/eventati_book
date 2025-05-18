import 'package:flutter/material.dart';
import 'package:eventati_book/models/models.dart';
import 'package:eventati_book/styles/app_colors.dart';
import 'package:eventati_book/styles/app_colors_dark.dart';
import 'package:eventati_book/styles/text_styles.dart';
import 'package:eventati_book/utils/utils.dart';

/// A widget that displays a pricing comparison table for services
class PricingComparisonTable extends StatelessWidget {
  /// The services to compare
  final List<dynamic> services;

  /// The type of service being compared
  final String serviceType;

  /// Constructor
  const PricingComparisonTable({
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

    // Get pricing details based on service type
    final pricingDetails = _getPricingDetails();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Pricing Comparison', style: TextStyles.sectionTitle),
          const SizedBox(height: 16),

          // Pricing comparison table
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
                          'Detail',
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

                // Pricing detail rows
                ...pricingDetails.map(
                  (detail) => Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border(top: BorderSide(color: borderColor)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text(
                            detail.name,
                            style: TextStyles.bodyMedium,
                          ),
                        ),
                        ...services.map(
                          (service) => Expanded(
                            flex: 1,
                            child: _buildPricingValue(
                              detail,
                              service,
                              primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Total row
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Color.fromRGBO(
                      primaryColor.r.toInt(),
                      primaryColor.g.toInt(),
                      primaryColor.b.toInt(),
                      0.1,
                    ),
                    border: Border(top: BorderSide(color: borderColor)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          'Total',
                          style: TextStyles.bodyLarge.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      ...services.map(
                        (service) => Expanded(
                          flex: 1,
                          child: Text(
                            _getServiceTotalPrice(service),
                            style: TextStyles.bodyLarge.copyWith(
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Pricing notes
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: borderColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pricing Notes',
                  style: TextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(_getPricingNotes(), style: TextStyles.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build the pricing value widget
  Widget _buildPricingValue(
    _PricingDetail detail,
    dynamic service,
    Color primaryColor,
  ) {
    final value = detail.getValue(service);

    if (value is String) {
      return Center(
        child: Text(
          value,
          style: TextStyles.bodyMedium,
          textAlign: TextAlign.center,
        ),
      );
    } else if (value is bool) {
      return Center(
        child: Icon(
          value ? Icons.check_circle : Icons.cancel,
          color: value ? Colors.green : Colors.red,
          size: 20,
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

  /// Get pricing details based on service type
  List<_PricingDetail> _getPricingDetails() {
    switch (serviceType) {
      case 'Venue':
        return [
          _PricingDetail(
            name: 'Base Price',
            getValue:
                (service) =>
                    service is Venue
                        ? '\$${service.pricePerEvent.toStringAsFixed(2)}'
                        : 'N/A',
          ),
          _PricingDetail(
            name: 'Price Type',
            getValue: (service) => service is Venue ? 'Per Event' : 'N/A',
          ),
          _PricingDetail(
            name: 'Capacity',
            getValue:
                (service) =>
                    service is Venue ? '${service.maxCapacity} guests' : 'N/A',
          ),
          _PricingDetail(
            name: 'Price Per Guest',
            getValue:
                (service) =>
                    service is Venue && service.maxCapacity > 0
                        ? '\$${(service.pricePerEvent / service.maxCapacity).toStringAsFixed(2)}'
                        : 'N/A',
          ),
        ];
      case 'Catering':
        return [
          _PricingDetail(
            name: 'Price Per Person',
            getValue:
                (service) =>
                    service is CateringService
                        ? '\$${service.pricePerPerson.toStringAsFixed(2)}'
                        : 'N/A',
          ),
          _PricingDetail(
            name: 'Minimum Capacity',
            getValue:
                (service) =>
                    service is CateringService
                        ? '${service.minCapacity} guests'
                        : 'N/A',
          ),
          _PricingDetail(
            name: 'Maximum Capacity',
            getValue:
                (service) =>
                    service is CateringService
                        ? '${service.maxCapacity} guests'
                        : 'N/A',
          ),
          _PricingDetail(
            name: 'Estimated Total (50 guests)',
            getValue:
                (service) =>
                    service is CateringService
                        ? '\$${(service.pricePerPerson * 50).toStringAsFixed(2)}'
                        : 'N/A',
          ),
        ];
      case 'Photographer':
        return [
          _PricingDetail(
            name: 'Base Price',
            getValue:
                (service) =>
                    service is Photographer
                        ? '\$${service.pricePerEvent.toStringAsFixed(2)}'
                        : 'N/A',
          ),
          _PricingDetail(
            name: 'Price Type',
            getValue:
                (service) => service is Photographer ? 'Per Event' : 'N/A',
          ),
          _PricingDetail(
            name: 'Number of Packages',
            getValue:
                (service) =>
                    service is Photographer
                        ? '${service.packages.length} packages'
                        : 'N/A',
          ),
        ];
      case 'Planner':
        return [
          _PricingDetail(
            name: 'Base Price',
            getValue:
                (service) =>
                    service is Planner
                        ? '\$${service.pricePerEvent.toStringAsFixed(2)}'
                        : 'N/A',
          ),
          _PricingDetail(
            name: 'Price Type',
            getValue: (service) => service is Planner ? 'Per Event' : 'N/A',
          ),
          _PricingDetail(
            name: 'Years Experience',
            getValue:
                (service) =>
                    service is Planner
                        ? '${service.yearsExperience} years'
                        : 'N/A',
          ),
          _PricingDetail(
            name: 'Number of Services',
            getValue:
                (service) =>
                    service is Planner
                        ? '${service.services.length} services'
                        : 'N/A',
          ),
        ];
      default:
        return [
          _PricingDetail(
            name: 'Base Price',
            getValue: (service) => '\$${service.price.toStringAsFixed(2)}',
          ),
        ];
    }
  }

  /// Get the total price for a service
  String _getServiceTotalPrice(dynamic service) {
    if (service is Venue) {
      return '\$${service.pricePerEvent.toStringAsFixed(2)}';
    } else if (service is CateringService) {
      // Assuming 50 guests for comparison
      return '\$${(service.pricePerPerson * 50).toStringAsFixed(2)}';
    } else if (service is Photographer) {
      return '\$${service.pricePerEvent.toStringAsFixed(2)}';
    } else if (service is Planner) {
      return '\$${service.pricePerEvent.toStringAsFixed(2)}';
    } else {
      return '\$${service.price.toStringAsFixed(2)}';
    }
  }

  /// Get pricing notes based on service type
  String _getPricingNotes() {
    switch (serviceType) {
      case 'Venue':
        return 'Venue prices are typically for the entire event. Additional costs may apply for extended hours, special setups, or premium dates. Contact the venue for a detailed quote.';
      case 'Catering':
        return 'Catering prices are per person. The total cost will depend on the number of guests. For this comparison, we\'ve calculated an estimate for 50 guests. Additional costs may apply for special dietary requirements, premium menu options, or service staff.';
      case 'Photographer':
        return 'Photography prices are typically for the entire event. Additional costs may apply for extra hours, additional photographers, or premium editing services. Contact the photographer for package details.';
      case 'Planner':
        return 'Planner prices are typically for the entire event planning process. The price may vary based on the complexity of the event, the number of guests, and the level of service required. Contact the planner for a detailed quote.';
      default:
        return 'Prices shown are base prices. Additional costs may apply depending on specific requirements. Contact the service provider for a detailed quote.';
    }
  }
}

/// A pricing detail to compare
class _PricingDetail {
  /// The name of the pricing detail
  final String name;

  /// Function to get the value of the pricing detail from a service
  final dynamic Function(dynamic) getValue;

  /// Constructor
  _PricingDetail({required this.name, required this.getValue});
}
