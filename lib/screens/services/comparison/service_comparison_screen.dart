import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:eventati_book/models/models.dart';
import 'package:eventati_book/providers/providers.dart';
import 'package:eventati_book/styles/app_colors.dart';
import 'package:eventati_book/styles/app_colors_dark.dart';
import 'package:eventati_book/utils/utils.dart';
import 'package:eventati_book/widgets/services/comparison/comparison_item_card.dart';
import 'package:eventati_book/widgets/services/comparison/feature_comparison_table.dart';
import 'package:eventati_book/widgets/services/comparison/pricing_comparison_table.dart';
import 'package:eventati_book/widgets/services/comparison/save_comparison_dialog.dart';
import 'package:eventati_book/routing/routing.dart';
import 'package:eventati_book/widgets/common/share_button.dart';

/// Screen for comparing services side by side
class ServiceComparisonScreen extends StatefulWidget {
  /// The type of service being compared (Venue, Catering, Photographer, Planner)
  final String serviceType;

  /// Constructor
  const ServiceComparisonScreen({super.key, required this.serviceType});

  @override
  State<ServiceComparisonScreen> createState() =>
      _ServiceComparisonScreenState();
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
          // Share button
          Builder(
            builder: (context) {
              // Create a temporary SavedComparison object for sharing
              final List<String> serviceNames = [];

              for (var service in selectedServices) {
                String name = '';

                if (service is Venue) {
                  name = service.name;
                } else if (service is CateringService) {
                  name = service.name;
                } else if (service is Photographer) {
                  name = service.name;
                } else if (service is Planner) {
                  name = service.name;
                }

                if (name.isNotEmpty) {
                  serviceNames.add(name);
                }
              }

              final comparison = SavedComparison(
                id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
                title: '${widget.serviceType} Comparison',
                serviceType: widget.serviceType,
                serviceIds: serviceNames,
                serviceNames: serviceNames,
                createdAt: DateTime.now(),
                userId: 'current_user',
                eventId: null,
              );

              return ShareButton(
                contentType: ShareContentType.comparison,
                content: comparison,
                tooltip: 'Share comparison',
              );
            },
          ),
          // Save button
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () => _showSaveDialog(context, selectedServices),
            tooltip: 'Save comparison',
          ),
          // View saved comparisons button
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              NavigationUtils.navigateToNamed(
                context,
                RouteNames.savedComparisons,
              );
            },
            tooltip: 'View saved comparisons',
          ),
          // Clear button
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
          unselectedLabelColor:
              isDarkMode
                  ? Color.fromRGBO(
                    Colors.white.r.toInt(),
                    Colors.white.g.toInt(),
                    Colors.white.b.toInt(),
                    0.7,
                  )
                  : AppColors.textSecondary,
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
      return const Center(child: Text('No services selected for comparison'));
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
            children:
                services.map((service) {
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

  /// Show dialog to save the comparison
  void _showSaveDialog(BuildContext context, List<dynamic> services) {
    if (services.isEmpty || services.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Select at least 2 services to save a comparison'),
        ),
      );
      return;
    }

    // Get service IDs and names
    final List<String> serviceIds = [];
    final List<String> serviceNames = [];

    for (var service in services) {
      String id = '';
      String name = '';

      if (service is Venue) {
        id = service.name;
        name = service.name;
      } else if (service is CateringService) {
        id = service.name;
        name = service.name;
      } else if (service is Photographer) {
        id = service.name;
        name = service.name;
      } else if (service is Planner) {
        id = service.name;
        name = service.name;
      }

      if (id.isNotEmpty && name.isNotEmpty) {
        serviceIds.add(id);
        serviceNames.add(name);
      }
    }

    showDialog(
      context: context,
      builder:
          (context) => SaveComparisonDialog(
            serviceType: widget.serviceType,
            serviceIds: serviceIds,
            serviceNames: serviceNames,
            onSaved: (savedComparison) {
              // Navigate to saved comparisons if needed
              // NavigationUtils.navigateToNamed(
              //   context,
              //   RouteNames.savedComparisons,
              // );
            },
          ),
    );
  }
}
