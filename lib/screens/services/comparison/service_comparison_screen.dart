import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:eventati_book/models/models.dart';
import 'package:eventati_book/providers/providers.dart';
import 'package:eventati_book/screens/services/comparison/saved_comparisons_screen.dart';
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
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SavedComparisonsScreen(),
                ),
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

    // Controllers for the form fields
    final titleController = TextEditingController();
    final notesController = TextEditingController();

    // Default title based on service type and count
    titleController.text =
        '${widget.serviceType} Comparison (${services.length})';

    // Create a form key for validation
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogContext) {
        // This will be called when the dialog is dismissed
        void disposeControllers() {
          titleController.dispose();
          notesController.dispose();
        }

        return AlertDialog(
          title: const Text('Save Comparison'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Title field with validation
                  TextFormField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: 'Title',
                      hintText: 'Enter a title for this comparison',
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a title';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppConstants.mediumPadding),
                  // Notes field
                  TextField(
                    controller: notesController,
                    decoration: const InputDecoration(
                      labelText: 'Notes',
                      hintText: 'Enter any notes about this comparison',
                    ),
                    maxLines: 3,
                  ),
                  // Event selection will be added when event management is implemented
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                disposeControllers();
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Validate the form
                if (formKey.currentState?.validate() ?? false) {
                  _saveComparison(
                    context,
                    services,
                    titleController.text.trim(),
                    notesController.text.trim(),
                  );
                  disposeControllers();
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    ).then((_) {
      // Ensure controllers are disposed if dialog is dismissed in other ways
      titleController.dispose();
      notesController.dispose();
    });
  }

  /// Save the comparison
  void _saveComparison(
    BuildContext context,
    List<dynamic> services,
    String title,
    String notes,
  ) async {
    // Store the context for later use
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    // Get service IDs and names
    final List<String> serviceIds = [];
    final List<String> serviceNames = [];

    for (var service in services) {
      String id = '';
      String name = '';

      if (service is Venue) {
        // Venues don't have an id field in the model, use name as ID
        id = service.name;
        name = service.name;
      } else if (service is CateringService) {
        // CateringService doesn't have an id field in the model, use name as ID
        id = service.name;
        name = service.name;
      } else if (service is Photographer) {
        // Photographer doesn't have an id field in the model, use name as ID
        id = service.name;
        name = service.name;
      } else if (service is Planner) {
        // Planner doesn't have an id field in the model, use name as ID
        id = service.name;
        name = service.name;
      }

      if (id.isNotEmpty && name.isNotEmpty) {
        serviceIds.add(id);
        serviceNames.add(name);
      }
    }

    // Save the comparison
    final provider = Provider.of<ComparisonSavingProvider>(
      context,
      listen: false,
    );

    // Close the dialog before the async operation
    navigator.pop();

    final success = await provider.saveComparison(
      serviceType: widget.serviceType,
      serviceIds: serviceIds,
      serviceNames: serviceNames,
      title: title,
      notes: notes,
      // Event ID and name will be added when event management is implemented
    );

    // Check if the widget is still mounted before using context
    if (!mounted) return;

    // Show success or error message
    scaffoldMessenger.showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Comparison saved successfully'
              : 'Failed to save comparison: ${provider.error}',
        ),
        action:
            success
                ? SnackBarAction(
                  label: 'View',
                  onPressed: () {
                    if (mounted) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SavedComparisonsScreen(),
                        ),
                      );
                    }
                  },
                )
                : null,
      ),
    );
  }
}
