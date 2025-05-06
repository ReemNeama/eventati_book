import 'package:flutter/material.dart';
import 'package:eventati_book/models/models.dart';
import 'package:eventati_book/utils/utils.dart';
import 'package:eventati_book/styles/app_colors.dart';
import 'package:eventati_book/styles/app_colors_dark.dart';
import 'package:eventati_book/widgets/details/package_card.dart';
import 'package:eventati_book/widgets/details/feature_item.dart';
import 'package:eventati_book/widgets/details/info_card.dart';
import 'package:eventati_book/widgets/details/detail_tab_bar.dart';
import 'package:eventati_book/widgets/details/image_placeholder.dart';
import 'package:eventati_book/widgets/details/chip_group.dart';
import 'package:eventati_book/providers/providers.dart';
import 'package:provider/provider.dart';
import 'package:eventati_book/routing/routing.dart';

class VenueDetailsScreen extends StatefulWidget {
  final Venue venue;

  const VenueDetailsScreen({super.key, required this.venue});

  @override
  State<VenueDetailsScreen> createState() => _VenueDetailsScreenState();
}

class _VenueDetailsScreenState extends State<VenueDetailsScreen>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;
  int _selectedPackageIndex = -1;

  // Sample data for packages
  final List<VenuePackage> _packages = [
    VenuePackage(
      name: 'Basic Package',
      description: 'Essential venue rental for smaller events',
      price: 2000.0,
      maxCapacity: 100,
      includedServices: [
        'Venue rental for 6 hours',
        'Basic setup and cleanup',
        'Tables and chairs',
        'Parking for guests',
      ],
      additionalFeatures: [
        'Additional hours available',
        'AV equipment rental available',
        'Catering options available',
      ],
    ),
    VenuePackage(
      name: 'Standard Package',
      description: 'Complete venue rental for medium-sized events',
      price: 3500.0,
      maxCapacity: 200,
      includedServices: [
        'Venue rental for 8 hours',
        'Full setup and cleanup',
        'Tables and chairs',
        'Basic lighting',
        'Sound system',
        'Parking for guests',
      ],
      additionalFeatures: [
        'Additional hours available',
        'Decorative lighting options',
        'Catering options available',
      ],
    ),
    VenuePackage(
      name: 'Premium Package',
      description: 'Luxury venue rental for larger events',
      price: 5000.0,
      maxCapacity: 300,
      includedServices: [
        'Venue rental for 10 hours',
        'Full setup and cleanup',
        'Premium tables and chairs',
        'Decorative lighting',
        'Professional sound system',
        'Dedicated event coordinator',
        'Bridal/VIP suite access',
        'Parking for guests',
      ],
      additionalFeatures: [
        'Additional hours available',
        'Custom floor plan design',
        'Premium decoration options',
        'Preferred vendor list',
      ],
    ),
    VenuePackage(
      name: 'All-Inclusive Package',
      description: 'Complete event solution with all services included',
      price: 8000.0,
      maxCapacity: 300,
      includedServices: [
        'Venue rental for 12 hours',
        'Full setup and cleanup',
        'Premium tables and chairs',
        'Decorative lighting',
        'Professional sound system',
        'Dedicated event coordinator',
        'Bridal/VIP suite access',
        'Basic catering (appetizers and drinks)',
        'Basic decoration package',
        'Photography service (4 hours)',
        'Parking for guests with valet option',
      ],
      additionalFeatures: [
        'Additional hours available',
        'Custom menu options',
        'Premium decoration upgrades',
        'Extended photography coverage',
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = UIUtils.isDarkMode(context);
    final Color primaryColor =
        isDarkMode ? AppColorsDark.primary : AppColors.primary;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.venue.name),
        backgroundColor: primaryColor,
        bottom: DetailTabBar(
          tabController: _tabController!,
          tabTitles: const ['Packages', 'Venue Details'],
        ),
      ),
      body: TabBarView(
        controller: _tabController!,
        children: [_buildPackagesTab(), _buildVenueDetailsTab()],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed:
            _selectedPackageIndex >= 0 ? () => _navigateToBookingForm() : null,
        backgroundColor: _getButtonBackgroundColor(primaryColor, isDarkMode),
        label: const Text('Book Now'),
        icon: const Icon(Icons.calendar_today),
        tooltip:
            _selectedPackageIndex >= 0
                ? 'Book this venue'
                : 'Select a package first',
      ),
    );
  }

  /// Get the background color for the booking button based on selection state and theme
  Color _getButtonBackgroundColor(Color primaryColor, bool isDarkMode) {
    if (_selectedPackageIndex >= 0) {
      return primaryColor;
    } else {
      // Package not selected, use a disabled color based on theme
      return isDarkMode ? Colors.grey[700]! : Colors.grey[400]!;
    }
  }

  /// Navigate to the booking form screen with the selected package details
  void _navigateToBookingForm() {
    if (_selectedPackageIndex < 0 ||
        _selectedPackageIndex >= _packages.length) {
      return;
    }

    final selectedPackage = _packages[_selectedPackageIndex];

    NavigationUtils.navigateToNamed(
      context,
      RouteNames.bookingForm,
      arguments: BookingFormArguments(
        serviceId: widget.venue.name, // Using name as ID for now
        serviceType: 'venue',
        serviceName: widget.venue.name,
        basePrice: selectedPackage.price,
        // Optional event parameters can be added here if available
      ),
    );
  }

  /// Builds the packages tab with title, recommendations, and package list
  Widget _buildPackagesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.mediumPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPackageTitle(),
          _buildPackageRecommendation(),
          _buildPackageList(),
        ],
      ),
    );
  }

  /// Builds the package selection title
  Widget _buildPackageTitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Select a Package', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: AppConstants.mediumPadding),
      ],
    );
  }

  /// Builds the package recommendation section based on wizard data
  Widget _buildPackageRecommendation() {
    return Consumer<ServiceRecommendationProvider>(
      builder: (context, provider, _) {
        // Only show recommendations if the venue is recommended
        if (!provider.isVenueRecommended(widget.venue) ||
            provider.wizardData == null) {
          return const SizedBox.shrink();
        }

        // We've already checked that wizardData is not null above
        // Now we can safely access it with the non-null assertion
        final wizardData = provider.wizardData!;
        // Access the map values
        final guestCount = wizardData['guestCount'] as int;
        final eventType = wizardData['eventType'] as String;

        // Find recommended package and build recommendation card
        final recommendationData = _findRecommendedPackage(
          guestCount,
          eventType,
        );
        if (recommendationData == null) {
          return const SizedBox.shrink();
        }

        // Get the recommended index and message
        // final recommendedPackage = recommendationData['package'] as VenuePackage;
        final recommendedIndex = recommendationData['index'] as int;
        final recommendationMessage = recommendationData['message'] as String;

        return _buildRecommendationCard(
          recommendationMessage,
          recommendedIndex,
        );
      },
    );
  }

  /// Finds the recommended package based on guest count and event type
  Map<String, dynamic>? _findRecommendedPackage(
    int guestCount,
    String eventType,
  ) {
    // Find the most suitable package based on guest count
    VenuePackage? recommendedPackage;
    int recommendedIndex = -1;

    for (int i = 0; i < _packages.length; i++) {
      final package = _packages[i];
      if (package.maxCapacity >= guestCount) {
        recommendedPackage = package;
        recommendedIndex = i;
        break;
      }
    }

    if (recommendedPackage == null) {
      return null;
    }

    // Build recommendation message
    String recommendationMessage =
        'Based on your guest count of $guestCount, we recommend the ${recommendedPackage.name}.';

    if (eventType.toLowerCase().contains('wedding') &&
        recommendedPackage.name.contains('Premium')) {
      recommendationMessage +=
          ' This package includes features perfect for weddings.';
    } else if (eventType.toLowerCase().contains('business') &&
        recommendedPackage.name.contains('Standard')) {
      recommendationMessage +=
          ' This package includes features suitable for business events.';
    }

    return {
      'package': recommendedPackage,
      'index': recommendedIndex,
      'message': recommendationMessage,
    };
  }

  /// Builds a recommendation card with the given message
  Widget _buildRecommendationCard(String message, int recommendedIndex) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.mediumPadding),
      child: Card(
        color: Theme.of(context).primaryColor.withAlpha(50),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.mediumPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.recommend,
                    color: Theme.of(context).primaryColor,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Recommended Package',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(message),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () {
                  setState(() {
                    _selectedPackageIndex = recommendedIndex;
                  });
                },
                child: const Text('Select This Package'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the list of package cards
  Widget _buildPackageList() {
    return Column(
      children: List.generate(_packages.length, (index) {
        final package = _packages[index];
        final isSelected = _selectedPackageIndex == index;

        return PackageCard(
          name: package.name,
          description: package.description,
          price: package.price,
          includedItems: package.includedServices,
          additionalFeatures: package.additionalFeatures,
          isSelected: isSelected,
          onTap: () {
            setState(() {
              _selectedPackageIndex = index;
            });
          },
          additionalInfo: Text(
            'Max Capacity: ${NumberUtils.formatWithCommas(package.maxCapacity)} guests',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        );
      }),
    );
  }

  /// Builds the venue details tab with all venue information sections
  Widget _buildVenueDetailsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.mediumPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildVenueImage(),
          _buildVenueRecommendation(),
          _buildVenueInfo(),
          const SizedBox(height: AppConstants.mediumPadding),
          _buildVenueFeatures(),
          const SizedBox(height: AppConstants.mediumPadding),
          _buildLocationInfo(),
        ],
      ),
    );
  }

  /// Builds the venue image placeholder
  Widget _buildVenueImage() {
    return const Column(
      children: [
        ImagePlaceholder(
          height: 200,
          width: double.infinity,
          borderRadius: AppConstants.mediumBorderRadius,
          icon: Icons.image,
          iconSize: 50,
        ),
        SizedBox(height: AppConstants.mediumPadding),
      ],
    );
  }

  /// Builds the venue recommendation section if available
  Widget _buildVenueRecommendation() {
    return Consumer<ServiceRecommendationProvider>(
      builder: (context, provider, _) {
        final isRecommended = provider.isVenueRecommended(widget.venue);
        final recommendationReason = provider.getVenueRecommendationReason(
          widget.venue,
        );

        if (isRecommended && recommendationReason != null) {
          return Padding(
            padding: const EdgeInsets.only(bottom: AppConstants.mediumPadding),
            child: Card(
              color: Theme.of(context).primaryColor.withAlpha(50),
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.mediumPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.thumb_up,
                          color: Theme.of(context).primaryColor,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Recommended for Your Event',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(recommendationReason),
                  ],
                ),
              ),
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  /// Builds the venue information section
  Widget _buildVenueInfo() {
    return InfoCard(
      title: 'About the Venue',
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.venue.description),
          const SizedBox(height: AppConstants.mediumPadding),
          _buildVenueTypes(),
          const SizedBox(height: AppConstants.mediumPadding),
          _buildVenueCapacityAndPrice(),
        ],
      ),
    );
  }

  /// Builds the venue types section
  Widget _buildVenueTypes() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Venue Type:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: AppConstants.smallPadding),
        ChipGroup(items: widget.venue.venueTypes),
      ],
    );
  }

  /// Builds the venue capacity and price information
  Widget _buildVenueCapacityAndPrice() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Capacity
        FeatureItem(
          text:
              'Capacity: ${NumberUtils.formatWithCommas(widget.venue.minCapacity)}-${NumberUtils.formatWithCommas(widget.venue.maxCapacity)} guests',
          icon: Icons.people,
          iconSize: 20,
          padding: const EdgeInsets.only(bottom: AppConstants.smallPadding),
        ),

        // Price
        FeatureItem(
          text:
              'Base Price: ${ServiceUtils.formatPrice(widget.venue.pricePerEvent, showPerEvent: true, decimalPlaces: 0)}',
          icon: Icons.attach_money,
          iconSize: 20,
        ),
      ],
    );
  }

  /// Builds the venue features section
  Widget _buildVenueFeatures() {
    return InfoCard(
      title: 'Venue Features',
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...widget.venue.features.map(
            (feature) => FeatureItem(
              text: feature,
              padding: const EdgeInsets.only(bottom: AppConstants.smallPadding),
              iconSize: 20,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the location information section
  Widget _buildLocationInfo() {
    return const InfoCard(
      title: 'Location',
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ImagePlaceholder(
            height: 150,
            width: double.infinity,
            borderRadius: AppConstants.smallBorderRadius * 2,
            icon: Icons.map,
            iconSize: 40,
          ),
          SizedBox(height: AppConstants.smallPadding),
          FeatureItem(
            text: '123 Event Street, City, State, ZIP',
            icon: Icons.location_on,
            iconSize: 20,
          ),
        ],
      ),
    );
  }
}
