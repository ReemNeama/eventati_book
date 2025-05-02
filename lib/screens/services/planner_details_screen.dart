import 'package:flutter/material.dart';
import 'package:eventati_book/models/planner.dart';
import 'package:eventati_book/models/planner_package.dart';
import 'package:eventati_book/styles/app_colors.dart';
import 'package:eventati_book/styles/app_colors_dark.dart';
import 'package:eventati_book/utils/utils.dart';
import 'package:eventati_book/widgets/details/package_card.dart';
import 'package:eventati_book/widgets/details/feature_item.dart';
import 'package:eventati_book/widgets/details/info_card.dart';
import 'package:eventati_book/widgets/details/detail_tab_bar.dart';
import 'package:eventati_book/widgets/details/image_placeholder.dart';
import 'package:eventati_book/widgets/details/chip_group.dart';

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
    );
  }

  Widget _buildPackagesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select a Package',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
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
            );
          }),
        ],
      ),
    );
  }

  Widget _buildPlannerDetailsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Planner profile
          Row(
            children: [
              const ImagePlaceholder(
                height: 100,
                width: 100,
                borderRadius: 50,
                icon: Icons.person,
                iconSize: 50,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.planner.name,
                      style: const TextStyle(
                        fontSize: 20,
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
                    Text(
                      '${widget.planner.yearsExperience} years of experience',
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // About the planner
          InfoCard(title: 'About', content: Text(widget.planner.description)),

          const SizedBox(height: 16),

          // Specialties
          InfoCard(
            title: 'Specialties',
            content: ChipGroup(items: widget.planner.specialties),
          ),

          const SizedBox(height: 16),

          // Services
          InfoCard(
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
          ),

          const SizedBox(height: 16),

          // Past events (placeholder)
          InfoCard(
            title: 'Past Events',
            content: SizedBox(
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
            ),
          ),
        ],
      ),
    );
  }
}
