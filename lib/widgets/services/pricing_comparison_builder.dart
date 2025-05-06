import 'package:flutter/material.dart';
import 'package:eventati_book/models/models.dart';
import 'package:eventati_book/styles/app_colors.dart';
import 'package:eventati_book/styles/app_colors_dark.dart';
import 'package:eventati_book/utils/utils.dart';

/// Builder class for pricing comparison table components
class PricingComparisonBuilder {
  /// Build calculation parameters section
  static Widget buildCalculationParameters({
    required BuildContext context,
    required String serviceType,
    required int guestCount,
    required int hours,
    required Function(int) onGuestCountChanged,
    required Function(int) onHoursChanged,
  }) {
    final isDarkMode = UIUtils.isDarkMode(context);
    final primaryColor = isDarkMode ? AppColorsDark.primary : AppColors.primary;

    return Card(
      elevation: AppConstants.smallElevation,
      margin: const EdgeInsets.only(bottom: AppConstants.mediumPadding),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.mediumPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Calculation Parameters',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: primaryColor,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: AppConstants.mediumPadding),

            // Guest count slider (for catering services)
            if (serviceType == 'Catering') ...[
              Row(
                children: [
                  const Text('Guest Count:'),
                  const SizedBox(width: AppConstants.mediumPadding),
                  Text(
                    '$guestCount guests',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Slider(
                value: guestCount.toDouble(),
                min: 50,
                max: 500,
                divisions: 45,
                label: guestCount.toString(),
                onChanged: (value) {
                  onGuestCountChanged(value.round());
                },
              ),
            ],

            // Hours slider (for photographer services)
            if (serviceType == 'Photographer') ...[
              Row(
                children: [
                  const Text('Hours:'),
                  const SizedBox(width: AppConstants.mediumPadding),
                  Text(
                    '$hours hours',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Slider(
                value: hours.toDouble(),
                min: 1,
                max: 12,
                divisions: 11,
                label: hours.toString(),
                onChanged: (value) {
                  onHoursChanged(value.round());
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Build pricing table header
  static Widget buildPricingTableHeader({required BuildContext context}) {
    final isDarkMode = UIUtils.isDarkMode(context);
    final primaryColor = isDarkMode ? AppColorsDark.primary : AppColors.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pricing Comparison',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: primaryColor,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: AppConstants.mediumPadding),

        // Table header
        Row(
          children: [
            // Service column
            SizedBox(
              width: 120,
              child: Text(
                'Service',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
            ),

            // Base price column
            Expanded(
              child: Text(
                'Base Price',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            // Total cost column
            Expanded(
              child: Text(
                'Total Cost',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
        const Divider(height: 32, thickness: 1),
      ],
    );
  }

  /// Calculate base price for a service
  static double calculateBasePrice({
    required dynamic service,
    required String serviceType,
  }) {
    if (serviceType == 'Venue' && service is Venue) {
      return service.pricePerEvent;
    } else if (serviceType == 'Catering' && service is CateringService) {
      return service.pricePerPerson;
    } else if (serviceType == 'Photographer' && service is Photographer) {
      return service.pricePerEvent;
    } else if (serviceType == 'Planner' && service is Planner) {
      return service.pricePerEvent;
    }

    return 0;
  }

  /// Calculate total cost for a service
  static double calculateTotalCost({
    required dynamic service,
    required String serviceType,
    required int guestCount,
    required int hours,
  }) {
    if (serviceType == 'Venue' && service is Venue) {
      return service.pricePerEvent;
    } else if (serviceType == 'Catering' && service is CateringService) {
      return service.pricePerPerson * guestCount;
    } else if (serviceType == 'Photographer' && service is Photographer) {
      // Assuming the base price is for a standard package (e.g., 4 hours)
      // and additional hours are charged at 25% of the base price per hour
      return hours <= 4
          ? service.pricePerEvent
          : service.pricePerEvent +
              (service.pricePerEvent * 0.25 * (hours - 4));
    } else if (serviceType == 'Planner' && service is Planner) {
      return service.pricePerEvent;
    }

    return 0;
  }

  /// Check if a service has the lowest cost
  static bool hasLowestCost({
    required dynamic service,
    required List<dynamic> allServices,
    required String serviceType,
    required int guestCount,
    required int hours,
  }) {
    final totalCost = calculateTotalCost(
      service: service,
      serviceType: serviceType,
      guestCount: guestCount,
      hours: hours,
    );

    for (var s in allServices) {
      final otherTotalCost = calculateTotalCost(
        service: s,
        serviceType: serviceType,
        guestCount: guestCount,
        hours: hours,
      );

      if (otherTotalCost < totalCost) {
        return false;
      }
    }

    return true;
  }

  /// Build a service row
  static Widget buildServiceRow({
    required dynamic service,
    required String serviceType,
    required int guestCount,
    required int hours,
    required List<dynamic> allServices,
  }) {
    final name =
        service is Venue
            ? service.name
            : service is CateringService
            ? service.name
            : service is Photographer
            ? service.name
            : service is Planner
            ? service.name
            : '';

    final basePrice = calculateBasePrice(
      service: service,
      serviceType: serviceType,
    );

    final totalCost = calculateTotalCost(
      service: service,
      serviceType: serviceType,
      guestCount: guestCount,
      hours: hours,
    );

    final isLowestCost = hasLowestCost(
      service: service,
      allServices: allServices,
      serviceType: serviceType,
      guestCount: guestCount,
      hours: hours,
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.mediumPadding),
      child: Row(
        children: [
          // Service name
          SizedBox(
            width: 120,
            child: Text(
              name,
              style: const TextStyle(fontWeight: FontWeight.bold),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // Base price
          Expanded(
            child: Text(
              '\$${basePrice.toStringAsFixed(2)}',
              textAlign: TextAlign.center,
            ),
          ),

          // Total cost
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration:
                  isLowestCost
                      ? BoxDecoration(
                        color: Colors.green.withAlpha(51), // 0.2 * 255 = 51
                        borderRadius: BorderRadius.circular(
                          AppConstants.smallBorderRadius,
                        ),
                      )
                      : null,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '\$${totalCost.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontWeight:
                          isLowestCost ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  if (isLowestCost) ...[
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 16,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build notes section
  static List<Widget> buildNotes({required String serviceType}) {
    return [
      const Text('Notes:', style: TextStyle(fontWeight: FontWeight.bold)),
      const SizedBox(height: AppConstants.smallPadding),
      if (serviceType == 'Venue') ...[
        const Text('• Venue prices are for the entire event.'),
        const Text(
          '• Additional fees may apply for extended hours or special services.',
        ),
      ] else if (serviceType == 'Catering') ...[
        const Text('• Catering prices are per person.'),
        const Text('• Total cost is calculated based on the guest count.'),
        const Text(
          '• Additional fees may apply for special dietary requirements or premium menu items.',
        ),
      ] else if (serviceType == 'Photographer') ...[
        const Text('• Photographer prices are for a standard package.'),
        const Text(
          '• Additional hours beyond 4 hours are calculated at 25% of the base price per hour.',
        ),
        const Text(
          '• Additional fees may apply for extra photographers, special equipment, or rush delivery.',
        ),
      ] else if (serviceType == 'Planner') ...[
        const Text(
          '• Planner prices are for the entire event planning process.',
        ),
        const Text(
          '• Additional fees may apply for day-of coordination or special services.',
        ),
      ],
    ];
  }
}
