import 'package:flutter/material.dart';
import 'package:eventati_book/models/models.dart';
import 'package:eventati_book/styles/app_colors.dart';
import 'package:eventati_book/styles/app_colors_dark.dart';
import 'package:eventati_book/styles/text_styles.dart';
import 'package:eventati_book/utils/utils.dart';
import 'package:eventati_book/widgets/services/comparison/feature_comparison_table.dart';
import 'package:eventati_book/widgets/services/comparison/pricing_comparison_table.dart';
import 'package:eventati_book/widgets/common/loading_indicator.dart';
import 'package:eventati_book/widgets/common/error_message.dart';
import 'package:eventati_book/routing/routing.dart';
import 'package:eventati_book/di/service_locator.dart';
import 'package:eventati_book/services/supabase/database/service_database_service.dart';

/// A screen that allows users to compare services before proceeding to checkout
class PreCheckoutComparisonScreen extends StatefulWidget {
  /// The type of service being compared
  final String serviceType;

  /// The IDs of the services being compared
  final List<String> serviceIds;

  /// The event ID (optional)
  final String? eventId;

  /// The event name (optional)
  final String? eventName;

  /// Constructor
  const PreCheckoutComparisonScreen({
    super.key,
    required this.serviceType,
    required this.serviceIds,
    this.eventId,
    this.eventName,
  });

  @override
  State<PreCheckoutComparisonScreen> createState() =>
      _PreCheckoutComparisonScreenState();
}

class _PreCheckoutComparisonScreenState
    extends State<PreCheckoutComparisonScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  String? _error;
  List<dynamic> _services = [];
  int _selectedServiceIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadServices();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// Load the services to be compared
  Future<void> _loadServices() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final services = <dynamic>[];
      final serviceDatabase = serviceLocator.get<ServiceDatabaseService>();

      // Load services based on type
      for (final id in widget.serviceIds) {
        try {
          final service = await serviceDatabase.getService(id);
          if (service != null) {
            // Convert the service to the appropriate type based on serviceType
            switch (widget.serviceType) {
              case 'Venue':
                final venue = Venue(
                  name: service.name,
                  description: service.description,
                  rating: service.averageRating,
                  venueTypes: service.tags,
                  minCapacity: 50, // Default value
                  maxCapacity: service.maximumCapacity ?? 200,
                  pricePerEvent: service.price,
                  imageUrl:
                      service.imageUrls.isNotEmpty
                          ? service.imageUrls.first
                          : 'assets/images/venue_placeholder.jpg',
                  features: service.tags,
                );
                services.add(venue);
                break;
              case 'Catering':
                final catering = CateringService(
                  name: service.name,
                  description: service.description,
                  rating: service.averageRating,
                  cuisineTypes: service.tags,
                  minCapacity: 50, // Default value
                  maxCapacity: service.maximumCapacity ?? 200,
                  pricePerPerson: service.price,
                  imageUrl:
                      service.imageUrls.isNotEmpty
                          ? service.imageUrls.first
                          : 'assets/images/catering_placeholder.jpg',
                );
                services.add(catering);
                break;
              case 'Photographer':
                final photographer = Photographer(
                  name: service.name,
                  description: service.description,
                  rating: service.averageRating,
                  styles: service.tags,
                  pricePerEvent: service.price,
                  imageUrl:
                      service.imageUrls.isNotEmpty
                          ? service.imageUrls.first
                          : 'assets/images/photographer_placeholder.jpg',
                  equipment:
                      service.tags
                          .where((tag) => tag.startsWith('equipment_'))
                          .toList(),
                  packages: [], // Empty list as default
                );
                services.add(photographer);
                break;
              case 'Planner':
                final planner = Planner(
                  name: service.name,
                  description: service.description,
                  rating: service.averageRating,
                  specialties: service.tags,
                  yearsExperience: 5, // Default value
                  pricePerEvent: service.price,
                  imageUrl:
                      service.imageUrls.isNotEmpty
                          ? service.imageUrls.first
                          : 'assets/images/planner_placeholder.jpg',
                  services: [], // Empty list as default
                );
                services.add(planner);
                break;
              default:
                throw Exception(
                  'Unsupported service type: ${widget.serviceType}',
                );
            }
          }
        } catch (e) {
          debugPrint('Error loading service $id: $e');
          // Continue with the next service
        }
      }

      if (services.isEmpty) {
        throw Exception('No services found with the provided IDs');
      }

      setState(() {
        _services = services;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load services: $e';
        _isLoading = false;
      });
    }
  }

  /// Proceed to checkout with the selected service
  void _proceedToCheckout() {
    if (_services.isEmpty || _selectedServiceIndex >= _services.length) {
      return;
    }

    final selectedService = _services[_selectedServiceIndex];

    // Navigate to booking form based on service type
    switch (widget.serviceType) {
      case 'Venue':
        NavigationUtils.navigateToNamed(
          context,
          RouteNames.bookingForm,
          arguments: BookingFormArguments(
            serviceId: selectedService.id,
            serviceType: widget.serviceType,
            serviceName: selectedService.name,
            basePrice: selectedService.price,
            eventId: widget.eventId,
            eventName: widget.eventName,
          ),
        );
        break;
      case 'Catering':
        NavigationUtils.navigateToNamed(
          context,
          RouteNames.bookingForm,
          arguments: BookingFormArguments(
            serviceId: selectedService.id,
            serviceType: widget.serviceType,
            serviceName: selectedService.name,
            basePrice: selectedService.price,
            eventId: widget.eventId,
            eventName: widget.eventName,
          ),
        );
        break;
      case 'Photographer':
        NavigationUtils.navigateToNamed(
          context,
          RouteNames.bookingForm,
          arguments: BookingFormArguments(
            serviceId: selectedService.id,
            serviceType: widget.serviceType,
            serviceName: selectedService.name,
            basePrice: selectedService.price,
            eventId: widget.eventId,
            eventName: widget.eventName,
          ),
        );
        break;
      case 'Planner':
        NavigationUtils.navigateToNamed(
          context,
          RouteNames.bookingForm,
          arguments: BookingFormArguments(
            serviceId: selectedService.id,
            serviceType: widget.serviceType,
            serviceName: selectedService.name,
            basePrice: selectedService.price,
            eventId: widget.eventId,
            eventName: widget.eventName,
          ),
        );
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unsupported service type')),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = UIUtils.isDarkMode(context);
    final primaryColor = isDarkMode ? AppColorsDark.primary : AppColors.primary;
    final backgroundColor =
        isDarkMode ? AppColorsDark.background : AppColors.background;
    final cardColor = isDarkMode ? AppColorsDark.card : AppColors.card;
    final textColor =
        isDarkMode ? AppColorsDark.textPrimary : AppColors.textPrimary;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text('Compare Before Booking'),
        backgroundColor: primaryColor,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Features'),
            Tab(text: 'Pricing'),
          ],
        ),
      ),
      body:
          _isLoading
              ? const Center(
                child: LoadingIndicator(message: 'Loading services...'),
              )
              : _error != null
              ? Center(
                child: ErrorMessage(message: _error!, onRetry: _loadServices),
              )
              : TabBarView(
                controller: _tabController,
                children: [
                  // Overview tab
                  _buildOverviewTab(cardColor, textColor, primaryColor),

                  // Features tab
                  FeatureComparisonTable(
                    services: _services,
                    serviceType: widget.serviceType,
                  ),

                  // Pricing tab
                  PricingComparisonTable(
                    services: _services,
                    serviceType: widget.serviceType,
                  ),
                ],
              ),
      bottomNavigationBar:
          _isLoading || _error != null
              ? null
              : BottomAppBar(
                color: cardColor,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Selected: ${_services.isNotEmpty ? _services[_selectedServiceIndex].name : "None"}',
                        style: TextStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      ElevatedButton(
                        onPressed: _proceedToCheckout,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                        child: const Text('Proceed to Booking'),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }

  /// Build the overview tab
  Widget _buildOverviewTab(
    Color cardColor,
    Color textColor,
    Color primaryColor,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Select a service to book', style: TextStyles.sectionTitle),
          const SizedBox(height: 16),

          // Service selection cards
          ..._services.asMap().entries.map((entry) {
            final index = entry.key;
            final service = entry.value;

            return Card(
              color: cardColor,
              elevation: 2,
              margin: const EdgeInsets.only(bottom: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(
                  color:
                      _selectedServiceIndex == index
                          ? primaryColor
                          : Colors.transparent,
                  width: 2,
                ),
              ),
              child: InkWell(
                onTap: () {
                  setState(() {
                    _selectedServiceIndex = index;
                  });
                },
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Service image
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child:
                            service.imageUrls != null &&
                                    service.imageUrls.isNotEmpty
                                ? Image.network(
                                  service.imageUrls.first,
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      width: 80,
                                      height: 80,
                                      color: Colors.grey[300],
                                      child: const Icon(Icons.error),
                                    );
                                  },
                                )
                                : Container(
                                  width: 80,
                                  height: 80,
                                  color: Colors.grey[300],
                                  child: const Icon(Icons.image),
                                ),
                      ),
                      const SizedBox(width: 16),

                      // Service details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(service.name, style: TextStyles.sectionTitle),
                            const SizedBox(height: 4),
                            Text(
                              service.description,
                              style: TextStyles.bodyMedium,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(
                                  Icons.star,
                                  size: 16,
                                  color: AppColors.ratingStarColor,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${service.rating.toStringAsFixed(1)} (${service is Service ? service.reviewCount : 0})',
                                  style: TextStyles.bodySmall,
                                ),
                                const SizedBox(width: 16),
                                Text(
                                  '\$${service is Venue
                                      ? service.pricePerEvent
                                      : service is CateringService
                                      ? service.pricePerPerson
                                      : service is Photographer
                                      ? service.pricePerEvent
                                      : service is Planner
                                      ? service.pricePerEvent
                                      : 0.0}',
                                  style: TextStyles.price,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Selection indicator
                      Radio<int>(
                        value: index,
                        groupValue: _selectedServiceIndex,
                        onChanged: (value) {
                          setState(() {
                            _selectedServiceIndex = value!;
                          });
                        },
                        activeColor: primaryColor,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),

          const SizedBox(height: 16),

          // Booking information
          Card(
            color: cardColor,
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Booking Information', style: TextStyles.sectionTitle),
                  const SizedBox(height: 8),
                  if (widget.eventId != null && widget.eventName != null) ...[
                    Text(
                      'Event: ${widget.eventName}',
                      style: TextStyles.bodyMedium,
                    ),
                    const SizedBox(height: 4),
                  ],
                  Text(
                    'Service Type: ${widget.serviceType}',
                    style: TextStyles.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Next Steps:',
                    style: TextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '1. Select a service from the options above',
                    style: TextStyles.bodyMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '2. Click "Proceed to Booking" to continue',
                    style: TextStyles.bodyMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '3. Fill out the booking form with your details',
                    style: TextStyles.bodyMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '4. Review and confirm your booking',
                    style: TextStyles.bodyMedium,
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
