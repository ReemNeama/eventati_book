import 'package:flutter/material.dart';
import 'package:eventati_book/utils/utils.dart';
import 'package:eventati_book/widgets/services/pricing_comparison_builder.dart';

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
    if (widget.services.isEmpty) {
      return const Center(child: Text('No services selected for comparison'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.mediumPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Calculation parameters
          PricingComparisonBuilder.buildCalculationParameters(
            context: context,
            serviceType: widget.serviceType,
            guestCount: _guestCount,
            hours: _hours,
            onGuestCountChanged: (value) {
              setState(() {
                _guestCount = value;
              });
            },
            onHoursChanged: (value) {
              setState(() {
                _hours = value;
              });
            },
          ),

          // Pricing table
          Card(
            elevation: AppConstants.smallElevation,
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.mediumPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Table header
                  PricingComparisonBuilder.buildPricingTableHeader(
                    context: context,
                  ),

                  // Service rows
                  ...widget.services.map((service) {
                    return PricingComparisonBuilder.buildServiceRow(
                      service: service,
                      serviceType: widget.serviceType,
                      guestCount: _guestCount,
                      hours: _hours,
                      allServices: widget.services,
                    );
                  }),

                  const Divider(height: 32, thickness: 1),

                  // Notes
                  ...PricingComparisonBuilder.buildNotes(
                    serviceType: widget.serviceType,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
