import 'package:flutter/material.dart';
import 'package:eventati_book/models/venue.dart';
import 'package:eventati_book/models/venue_package.dart';
import 'package:eventati_book/utils/utils.dart';
import 'package:eventati_book/styles/app_colors.dart';
import 'package:eventati_book/styles/app_colors_dark.dart';
import 'package:eventati_book/widgets/details/package_card.dart';
import 'package:eventati_book/widgets/details/feature_item.dart';
import 'package:eventati_book/widgets/details/info_card.dart';
import 'package:eventati_book/widgets/details/detail_tab_bar.dart';
import 'package:eventati_book/widgets/details/image_placeholder.dart';
import 'package:eventati_book/widgets/details/chip_group.dart';

class VenueDetailsScreen extends StatefulWidget {
  final Venue venue;

  const VenueDetailsScreen({super.key, required this.venue});

  @override
  State<VenueDetailsScreen> createState() => _VenueDetailsScreenState();
}

class _VenueDetailsScreenState extends State<VenueDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
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
    _tabController.dispose();
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
          tabController: _tabController,
          tabTitles: const ['Packages', 'Venue Details'],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildPackagesTab(), _buildVenueDetailsTab()],
      ),
    );
  }

  Widget _buildPackagesTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(AppConstants.mediumPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select a Package',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          SizedBox(height: AppConstants.mediumPadding),
          ...List.generate(_packages.length, (index) {
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
        ],
      ),
    );
  }

  Widget _buildVenueDetailsTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(AppConstants.mediumPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Venue image placeholder
          ImagePlaceholder(
            height: 200,
            width: double.infinity,
            borderRadius: AppConstants.mediumBorderRadius,
            icon: Icons.image,
            iconSize: 50,
          ),
          SizedBox(height: AppConstants.mediumPadding),

          // Venue details
          InfoCard(
            title: 'About the Venue',
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.venue.description),
                SizedBox(height: AppConstants.mediumPadding),

                // Venue types
                const Text(
                  'Venue Type:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: AppConstants.smallPadding),
                ChipGroup(items: widget.venue.venueTypes),

                SizedBox(height: AppConstants.mediumPadding),

                // Capacity
                FeatureItem(
                  text:
                      'Capacity: ${NumberUtils.formatWithCommas(widget.venue.minCapacity)}-${NumberUtils.formatWithCommas(widget.venue.maxCapacity)} guests',
                  icon: Icons.people,
                  iconSize: 20,
                  padding: EdgeInsets.only(bottom: AppConstants.smallPadding),
                ),

                // Price
                FeatureItem(
                  text:
                      'Base Price: ${ServiceUtils.formatPrice(widget.venue.pricePerEvent, showPerEvent: true, decimalPlaces: 0)}',
                  icon: Icons.attach_money,
                  iconSize: 20,
                ),
              ],
            ),
          ),

          SizedBox(height: AppConstants.mediumPadding),

          // Features
          InfoCard(
            title: 'Venue Features',
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...widget.venue.features.map(
                  (feature) => FeatureItem(
                    text: feature,
                    padding: EdgeInsets.only(bottom: AppConstants.smallPadding),
                    iconSize: 20,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: AppConstants.mediumPadding),

          // Location (placeholder)
          InfoCard(
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
                const FeatureItem(
                  text: '123 Event Street, City, State, ZIP',
                  icon: Icons.location_on,
                  iconSize: 20,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
