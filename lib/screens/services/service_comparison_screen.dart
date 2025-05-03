import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:eventati_book/models/venue.dart';
import 'package:eventati_book/models/catering_service.dart';
import 'package:eventati_book/models/photographer.dart';
import 'package:eventati_book/models/planner.dart';
import 'package:eventati_book/providers/comparison_provider.dart';
import 'package:eventati_book/styles/app_colors.dart';
import 'package:eventati_book/styles/app_colors_dark.dart';
import 'package:eventati_book/utils/utils.dart';
import 'package:eventati_book/widgets/services/comparison_item_card.dart';
import 'package:eventati_book/widgets/services/feature_comparison_table.dart';
import 'package:eventati_book/widgets/services/pricing_comparison_table.dart';

/// Screen for comparing services side by side
class ServiceComparisonScreen extends StatefulWidget {
  /// The type of service being compared (Venue, Catering, Photographer, Planner)
  final String serviceType;

  /// Constructor
  const ServiceComparisonScreen({
    super.key,
    required this.serviceType,
  });

  @override
  State<ServiceComparisonScreen> createState() => _ServiceComparisonScreenState();
}

class _ServiceComparisonScreenState extends State<ServiceComparisonScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final comparisonProvider = Provider.of<ComparisonProvider>(context);
    final isDarkMode = UIUtils.isDarkMode(context);
    final primaryColor = isDarkMode ? AppColorsDark.primary : AppColors.primary;

    // Get the selected services based on the service type
    List<dynamic> selectedServices = [];
    String serviceTypeName = '';

    switch (widget.serviceType) {
      case 'Venue':
        selectedServices = comparisonProvider.selectedVenues;
        serviceTypeName = 'Venues';
        break;
      case 'Catering':
        selectedServices = comparisonProvider.selectedCateringServices;
        serviceTypeName = 'Catering Services';
        break;
      case 'Photographer':
        selectedServices = comparisonProvider.selectedPhotographers;
        serviceTypeName = 'Photographers';
        break;
      case 'Planner':
        selectedServices = comparisonProvider.selectedPlanners;
        serviceTypeName = 'Planners';
        break;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Compare $serviceTypeName'),
        actions: [
          IconButton(
            icon: const Icon(Icons.clear_all),
            onPressed: () {
              comparisonProvider.clearSelections(widget.serviceType);
              Navigator.pop(context);
            },
            tooltip: 'Clear all selections',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: primaryColor,
          labelColor: isDarkMode ? Colors.white : primaryColor,
          unselectedLabelColor: isDarkMode ? Colors.white70 : Colors.black54,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Features'),
            Tab(text: 'Pricing'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Overview tab
          _buildOverviewTab(selectedServices),

          // Features tab
          FeatureComparisonTable(
            services: selectedServices,
            serviceType: widget.serviceType,
          ),

          // Pricing tab
          PricingComparisonTable(
            services: selectedServices,
            serviceType: widget.serviceType,
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewTab(List<dynamic> services) {
    if (services.isEmpty) {
      return const Center(
        child: Text('No services selected for comparison'),
      );
    }

    // Find the service with the highest rating to highlight
    dynamic bestService;
    double highestRating = 0;

    for (var service in services) {
      double rating = 0;
      if (service is Venue) {
        rating = service.rating;
      } else if (service is CateringService) {
        rating = service.rating;
      } else if (service is Photographer) {
        rating = service.rating;
      } else if (service is Planner) {
        rating = service.rating;
      }

      if (rating > highestRating) {
        highestRating = rating;
        bestService = service;
      }
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.mediumPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Display service cards side by side
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: services.map((service) {
              return Expanded(
                child: ComparisonItemCard(
                  service: service,
                  serviceType: widget.serviceType,
                  isHighlighted: service == bestService,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
