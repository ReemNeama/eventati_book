import 'package:flutter/material.dart';

// Import models using barrel file
import 'package:eventati_book/models/models.dart';

// Import styles
import 'package:eventati_book/styles/app_colors.dart';
import 'package:eventati_book/styles/app_colors_dark.dart';

// Import utilities using barrel file
import 'package:eventati_book/utils/utils.dart';

// Import widgets using barrel files
import 'package:eventati_book/widgets/details/detail_widgets.dart';
import 'package:eventati_book/widgets/responsive/responsive.dart';

// Import routing
import 'package:eventati_book/routing/routing.dart';

// Import providers
import 'package:eventati_book/providers/providers.dart';
import 'package:provider/provider.dart';

class PlannerDetailsScreen extends StatefulWidget {
  final Planner planner;

  const PlannerDetailsScreen({super.key, required this.planner});

  @override
  State<PlannerDetailsScreen> createState() => _PlannerDetailsScreenState();
}

class _PlannerDetailsScreenState extends State<PlannerDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedPackageIndex = -1;

  // Sample data for packages
  final List<PlannerPackage> _packages = [
    PlannerPackage(
      name: 'Day-of Coordination',
      description: 'Essential coordination services for your event day',
      price: 1200.0,
      includedServices: [
        'Initial consultation',
        'Vendor coordination on event day',
        'Timeline creation and management',
        'Setup supervision',
        'On-site coordination (up to 8 hours)',
        'Emergency kit',
      ],
      additionalFeatures: [
        'Additional hours available',
        'Assistant coordinator available',
        'Rehearsal coordination available',
      ],
    ),
    PlannerPackage(
      name: 'Partial Planning',
      description: 'Support throughout your planning process with key services',
      price: 2500.0,
      includedServices: [
        'Initial consultation',
        'Vendor recommendations and coordination',
        'Budget management assistance',
        'Timeline creation and management',
        'Setup supervision',
        'On-site coordination (up to 10 hours)',
        'Emergency kit',
      ],
      additionalFeatures: [
        'Additional planning meetings available',
        'Design consultation available',
        'Guest management assistance available',
      ],
    ),
    PlannerPackage(
      name: 'Full Planning',
      description: 'Comprehensive planning services from start to finish',
      price: 4000.0,
      includedServices: [
        'Initial consultation',
        'Unlimited planning meetings',
        'Vendor research, recommendations, and coordination',
        'Budget creation and management',
        'Design concept and implementation',
        'Timeline creation and management',
        'Guest management assistance',
        'Setup supervision',
        'On-site coordination (up to 12 hours)',
        'Emergency kit',
      ],
      additionalFeatures: [
        'Multiple coordinator assistants available',
        'Destination planning assistance available',
        'Post-event services available',
      ],
    ),
    PlannerPackage(
      name: 'Luxury Planning',
      description: 'Premium planning experience with exclusive services',
      price: 6000.0,
      includedServices: [
        'Initial consultation',
        'Unlimited planning meetings',
        'Exclusive vendor access and coordination',
        'Budget creation and management',
        'Custom design concept and implementation',
        'Detailed timeline creation and management',
        'Complete guest management',
        'RSVP tracking',
        'Setup and teardown supervision',
        'On-site coordination (unlimited hours)',
        'Lead coordinator and assistant',
        'Emergency kit',
        'Transportation coordination',
        'Accommodation coordination',
      ],
      additionalFeatures: [
        'International destination planning available',
        'Multiple event coordination available',
        'Personal concierge services available',
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
        title: Text(widget.planner.name),
        backgroundColor: primaryColor,
        bottom: DetailTabBar(
          tabController: _tabController,
          tabTitles: const ['Packages', 'About Planner'],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildPackagesTab(), _buildPlannerDetailsTab()],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed:
            _selectedPackageIndex >= 0 ? () => _navigateToBookingForm() : null,
        backgroundColor:
            _selectedPackageIndex >= 0
                ? primaryColor
                : isDarkMode
                ? Colors.grey[700]
                : Colors.grey[400],
        label: const Text('Book Now'),
        icon: const Icon(Icons.calendar_today),
        tooltip:
            _selectedPackageIndex >= 0
                ? 'Book this planner'
                : 'Select a package first',
      ),
    );
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
        serviceId: widget.planner.name, // Using name as ID for now
        serviceType: 'planner',
        serviceName: widget.planner.name,
        basePrice: selectedPackage.price,
        // Optional event parameters can be added here if available
      ),
    );
  }

  Widget _buildPackagesTab() {
    return OrientationResponsiveBuilder(
      portraitBuilder: (context, constraints) {
        // Portrait mode: single column list
        return _buildPackagesList(1);
      },
      landscapeBuilder: (context, constraints) {
        // Landscape mode: two columns on larger screens
        return _buildPackagesList(UIUtils.isTablet(context) ? 2 : 1);
      },
    );
  }

  /// Builds the recommendation section if the planner is recommended
  Widget _buildRecommendationSection() {
    return Consumer<ServiceRecommendationProvider>(
      builder: (context, provider, _) {
        // Only show if there's wizard data and the planner is recommended
        if (provider.wizardData == null) {
          return const SizedBox.shrink();
        }

        final isRecommended = provider.isPlannerRecommended(widget.planner);
        if (!isRecommended) {
          return const SizedBox.shrink();
        }

        final recommendationReason = provider.getPlannerRecommendationReason(
          widget.planner,
        );

        return InfoCard(
          title: 'Recommended for Your Event',
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.thumb_up, color: Colors.green),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      recommendationReason ??
                          'This planner is recommended for your event',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPackagesList(int columns) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildRecommendationSection(),
          const SizedBox(height: 16),
          Text(
            'Select a Package',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          if (columns == 1)
            // Single column layout
            ...List.generate(_packages.length, (index) {
              return _buildPackageCard(index);
            })
          else
            // Multi-column layout using grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio:
                    0.8, // Adjust based on your card's aspect ratio
              ),
              itemCount: _packages.length,
              itemBuilder: (context, index) {
                return _buildPackageCard(index);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildPackageCard(int index) {
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
    );
  }

  Widget _buildPlannerDetailsTab() {
    return OrientationResponsiveBuilder(
      portraitBuilder: (context, constraints) {
        // Portrait mode: standard layout
        return _buildPlannerDetailsContent(false);
      },
      landscapeBuilder: (context, constraints) {
        // Landscape mode: optimized layout
        return _buildPlannerDetailsContent(true);
      },
    );
  }

  Widget _buildPlannerDetailsContent(bool isLandscape) {
    final bool isTablet = UIUtils.isTablet(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Planner profile - responsive layout
          if (isLandscape && isTablet)
            // Tablet landscape: larger profile with more space
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left column: profile and about
                Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildPlannerProfile(),
                      const SizedBox(height: 16),
                      InfoCard(
                        title: 'About',
                        content: Text(widget.planner.description),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // Right column: specialties and services
                Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InfoCard(
                        title: 'Specialties',
                        content: ChipGroup(items: widget.planner.specialties),
                      ),
                      const SizedBox(height: 16),
                      _buildServicesCard(),
                    ],
                  ),
                ),
              ],
            )
          else
            // Phone or portrait: standard stacked layout
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPlannerProfile(),
                const SizedBox(height: 24),
                InfoCard(
                  title: 'About',
                  content: Text(widget.planner.description),
                ),
                const SizedBox(height: 16),
                InfoCard(
                  title: 'Specialties',
                  content: ChipGroup(items: widget.planner.specialties),
                ),
                const SizedBox(height: 16),
                _buildServicesCard(),
              ],
            ),

          const SizedBox(height: 16),

          // Past events - responsive grid for tablet
          InfoCard(
            title: 'Past Events',
            content: isTablet ? _buildPastEventsGrid() : _buildPastEventsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPlannerProfile() {
    final bool isTablet = UIUtils.isTablet(context);
    final double profileSize = isTablet ? 120.0 : 100.0;
    final double iconSize = isTablet ? 60.0 : 50.0;
    final double nameSize = isTablet ? 24.0 : 20.0;

    return Row(
      children: [
        ImagePlaceholder(
          height: profileSize,
          width: profileSize,
          borderRadius: profileSize / 2,
          icon: Icons.person,
          iconSize: iconSize,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.planner.name,
                style: TextStyle(
                  fontSize: nameSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(
                    Icons.star,
                    color: AppColors.ratingStarColor,
                    size: 18,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    ServiceUtils.formatRating(widget.planner.rating),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text('${widget.planner.yearsExperience} years of experience'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildServicesCard() {
    return InfoCard(
      title: 'Services Offered',
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...widget.planner.services.map(
            (service) => FeatureItem(
              text: service,
              padding: const EdgeInsets.only(bottom: 8),
              iconSize: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPastEventsList() {
    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 5,
        itemBuilder: (context, index) {
          return Container(
            width: 160,
            margin: const EdgeInsets.only(right: 8),
            child: const ImagePlaceholder(
              height: 120,
              width: 160,
              borderRadius: 8,
            ),
          );
        },
      ),
    );
  }

  Widget _buildPastEventsGrid() {
    return ResponsiveGridView(
      minItemWidth: 150,
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
      childAspectRatio: 1.3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: List.generate(
        5,
        (index) => const ImagePlaceholder(
          borderRadius: 8,
          icon: Icons.image,
          iconSize: 40,
        ),
      ),
    );
  }
}
