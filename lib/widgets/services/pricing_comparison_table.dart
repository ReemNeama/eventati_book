import 'package:flutter/material.dart';
import 'package:eventati_book/models/models.dart';
import 'package:eventati_book/styles/app_colors.dart';
import 'package:eventati_book/styles/app_colors_dark.dart';
import 'package:eventati_book/utils/utils.dart';

/// Table widget for comparing pricing of services
class PricingComparisonTable extends StatefulWidget {
  /// The services to compare
  final List<dynamic> services;

  /// The type of service (Venue, Catering, Photographer, Planner)
  final String serviceType;

  /// Constructor
  const PricingComparisonTable({
    super.key,
    required this.services,
    required this.serviceType,
  });

  @override
  State<PricingComparisonTable> createState() => _PricingComparisonTableState();
}

class _PricingComparisonTableState extends State<PricingComparisonTable> {
  // Default values for calculations
  int _guestCount = 100;
  int _hours = 4;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = UIUtils.isDarkMode(context);
    final primaryColor = isDarkMode ? AppColorsDark.primary : AppColors.primary;

    if (widget.services.isEmpty) {
      return const Center(child: Text('No services selected for comparison'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.mediumPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Calculation parameters
          Card(
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
                  if (widget.serviceType == 'Catering') ...[
                    Row(
                      children: [
                        const Text('Guest Count:'),
                        const SizedBox(width: AppConstants.mediumPadding),
                        Text(
                          '$_guestCount guests',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Slider(
                      value: _guestCount.toDouble(),
                      min: 50,
                      max: 500,
                      divisions: 45,
                      label: _guestCount.toString(),
                      onChanged: (value) {
                        setState(() {
                          _guestCount = value.round();
                        });
                      },
                    ),
                  ],

                  // Hours slider (for photographer services)
                  if (widget.serviceType == 'Photographer') ...[
                    Row(
                      children: [
                        const Text('Hours:'),
                        const SizedBox(width: AppConstants.mediumPadding),
                        Text(
                          '$_hours hours',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Slider(
                      value: _hours.toDouble(),
                      min: 1,
                      max: 12,
                      divisions: 11,
                      label: _hours.toString(),
                      onChanged: (value) {
                        setState(() {
                          _hours = value.round();
                        });
                      },
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Pricing table
          Card(
            elevation: AppConstants.smallElevation,
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.mediumPadding),
              child: Column(
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

                  // Service rows
                  ...widget.services.map((service) {
                    String name = '';
                    double basePrice = 0;
                    double totalCost = 0;

                    if (widget.serviceType == 'Venue' && service is Venue) {
                      name = service.name;
                      basePrice = service.pricePerEvent;
                      totalCost = service.pricePerEvent;
                    } else if (widget.serviceType == 'Catering' &&
                        service is CateringService) {
                      name = service.name;
                      basePrice = service.pricePerPerson;
                      totalCost = service.pricePerPerson * _guestCount;
                    } else if (widget.serviceType == 'Photographer' &&
                        service is Photographer) {
                      name = service.name;
                      basePrice = service.pricePerEvent;
                      // Assuming the base price is for a standard package (e.g., 4 hours)
                      // and additional hours are charged at 25% of the base price per hour
                      if (_hours <= 4) {
                        totalCost = service.pricePerEvent;
                      } else {
                        totalCost =
                            service.pricePerEvent +
                            (service.pricePerEvent * 0.25 * (_hours - 4));
                      }
                    } else if (widget.serviceType == 'Planner' &&
                        service is Planner) {
                      name = service.name;
                      basePrice = service.pricePerEvent;
                      totalCost = service.pricePerEvent;
                    }

                    // Find the service with the lowest total cost
                    bool isLowestCost = true;
                    for (var s in widget.services) {
                      double otherTotalCost = 0;

                      if (widget.serviceType == 'Venue' && s is Venue) {
                        otherTotalCost = s.pricePerEvent;
                      } else if (widget.serviceType == 'Catering' &&
                          s is CateringService) {
                        otherTotalCost = s.pricePerPerson * _guestCount;
                      } else if (widget.serviceType == 'Photographer' &&
                          s is Photographer) {
                        if (_hours <= 4) {
                          otherTotalCost = s.pricePerEvent;
                        } else {
                          otherTotalCost =
                              s.pricePerEvent +
                              (s.pricePerEvent * 0.25 * (_hours - 4));
                        }
                      } else if (widget.serviceType == 'Planner' &&
                          s is Planner) {
                        otherTotalCost = s.pricePerEvent;
                      }

                      if (otherTotalCost < totalCost) {
                        isLowestCost = false;
                        break;
                      }
                    }

                    return Padding(
                      padding: const EdgeInsets.only(
                        bottom: AppConstants.mediumPadding,
                      ),
                      child: Row(
                        children: [
                          // Service name
                          SizedBox(
                            width: 120,
                            child: Text(
                              name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
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
                                        color: Colors.green.withAlpha(
                                          51,
                                        ), // 0.2 * 255 = 51
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
                                          isLowestCost
                                              ? FontWeight.bold
                                              : FontWeight.normal,
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
                  }),

                  const Divider(height: 32, thickness: 1),

                  // Notes
                  const Text(
                    'Notes:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: AppConstants.smallPadding),
                  if (widget.serviceType == 'Venue') ...[
                    const Text('• Venue prices are for the entire event.'),
                    const Text(
                      '• Additional fees may apply for extended hours or special services.',
                    ),
                  ] else if (widget.serviceType == 'Catering') ...[
                    const Text('• Catering prices are per person.'),
                    const Text(
                      '• Total cost is calculated based on the guest count.',
                    ),
                    const Text(
                      '• Additional fees may apply for special dietary requirements or premium menu items.',
                    ),
                  ] else if (widget.serviceType == 'Photographer') ...[
                    const Text(
                      '• Photographer prices are for a standard package.',
                    ),
                    const Text(
                      '• Additional hours beyond 4 hours are calculated at 25% of the base price per hour.',
                    ),
                    const Text(
                      '• Additional fees may apply for extra photographers, special equipment, or rush delivery.',
                    ),
                  ] else if (widget.serviceType == 'Planner') ...[
                    const Text(
                      '• Planner prices are for the entire event planning process.',
                    ),
                    const Text(
                      '• Additional fees may apply for day-of coordination or special services.',
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
}
