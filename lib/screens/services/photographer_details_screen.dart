import 'package:flutter/material.dart';
import 'package:eventati_book/models/photographer.dart';
import 'package:eventati_book/models/photographer_package.dart';
import 'package:eventati_book/utils/utils.dart';
import 'package:eventati_book/styles/app_colors.dart';
import 'package:eventati_book/styles/app_colors_dark.dart';
import 'package:eventati_book/widgets/details/package_card.dart';
import 'package:eventati_book/widgets/details/feature_item.dart';
import 'package:eventati_book/widgets/details/info_card.dart';
import 'package:eventati_book/widgets/details/detail_tab_bar.dart';
import 'package:eventati_book/widgets/details/image_placeholder.dart';
import 'package:eventati_book/widgets/details/chip_group.dart';
import 'package:eventati_book/widgets/responsive/responsive.dart';

class PhotographerDetailsScreen extends StatefulWidget {
  final Photographer photographer;

  const PhotographerDetailsScreen({super.key, required this.photographer});

  @override
  State<PhotographerDetailsScreen> createState() =>
      _PhotographerDetailsScreenState();
}

class _PhotographerDetailsScreenState extends State<PhotographerDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedPackageIndex = -1;

  // Sample data for packages
  final List<PhotographerPackage> _packages = [
    PhotographerPackage(
      name: 'Photography Only',
      description: 'Professional photography services for your event',
      price: 2000.0,
      includedServices: [
        'Professional photographer',
        '8 hours of coverage',
        'High-resolution digital images',
        'Online gallery',
        'Basic photo editing',
      ],
      additionalFeatures: [
        'Additional hours available',
        'Engagement/pre-event session available',
        'Printed album options available',
      ],
      includesPhotography: true,
      includesVideography: false,
      includesTeam: false,
    ),
    PhotographerPackage(
      name: 'Photography and Videography',
      description: 'Complete visual coverage with both photo and video',
      price: 3500.0,
      includedServices: [
        'Professional photographer',
        'Professional videographer',
        '8 hours of coverage',
        'High-resolution digital images',
        '5-7 minute highlight video',
        'Full ceremony video',
        'Online gallery',
      ],
      additionalFeatures: [
        'Drone footage available',
        'Same-day edit available',
        'Extended video options available',
      ],
      includesPhotography: true,
      includesVideography: true,
      includesTeam: false,
    ),
    PhotographerPackage(
      name: 'Videography Only',
      description: 'Professional video services for your event',
      price: 1800.0,
      includedServices: [
        'Professional videographer',
        '8 hours of coverage',
        '5-7 minute highlight video',
        'Full ceremony video',
        'Digital delivery',
      ],
      additionalFeatures: [
        'Drone footage available',
        'Same-day edit available',
        'Raw footage available',
      ],
      includesPhotography: false,
      includesVideography: true,
      includesTeam: false,
    ),
    PhotographerPackage(
      name: 'Photography with Team',
      description:
          'Photography coverage with a professional team (not the lead photographer)',
      price: 1600.0,
      includedServices: [
        'Professional photography team',
        '8 hours of coverage',
        'High-resolution digital images',
        'Online gallery',
        'Basic photo editing',
      ],
      additionalFeatures: [
        'Multiple photographers for better coverage',
        'Faster delivery time',
        'Printed album options available',
      ],
      includesPhotography: true,
      includesVideography: false,
      includesTeam: true,
    ),
    PhotographerPackage(
      name: 'Photography and Videography with Team',
      description:
          'Complete visual coverage with a professional team (not the lead photographer)',
      price: 2800.0,
      includedServices: [
        'Professional photography team',
        'Professional videography team',
        '8 hours of coverage',
        'High-resolution digital images',
        '5-7 minute highlight video',
        'Full ceremony video',
        'Online gallery',
      ],
      additionalFeatures: [
        'Multiple photographers and videographers',
        'Drone footage available',
        'Same-day edit available',
      ],
      includesPhotography: true,
      includesVideography: true,
      includesTeam: true,
    ),
    PhotographerPackage(
      name: 'Videography with Team',
      description:
          'Video coverage with a professional team (not the lead videographer)',
      price: 1500.0,
      includedServices: [
        'Professional videography team',
        '8 hours of coverage',
        '5-7 minute highlight video',
        'Full ceremony video',
        'Digital delivery',
      ],
      additionalFeatures: [
        'Multiple camera angles',
        'Drone footage available',
        'Same-day edit available',
      ],
      includesPhotography: false,
      includesVideography: true,
      includesTeam: true,
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
        title: Text(widget.photographer.name),
        backgroundColor: primaryColor,
        bottom: DetailTabBar(
          tabController: _tabController,
          tabTitles: const ['Packages', 'Portfolio'],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildPackagesTab(), _buildPortfolioTab()],
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
              additionalInfo: Wrap(
                spacing: 8,
                children: [
                  if (package.includesPhotography)
                    Chip(
                      label: const Text('Photography'),
                      backgroundColor:
                          UIUtils.isDarkMode(context)
                              ? AppColorsDark.primary
                              : AppColors.primary,
                      labelStyle: const TextStyle(color: Colors.white),
                    ),
                  if (package.includesVideography)
                    Chip(
                      label: const Text('Videography'),
                      backgroundColor:
                          UIUtils.isDarkMode(context)
                              ? AppColorsDark.primary
                              : AppColors.primary,
                      labelStyle: const TextStyle(color: Colors.white),
                    ),
                  if (package.includesTeam)
                    Chip(
                      label: const Text('Team Coverage'),
                      backgroundColor:
                          UIUtils.isDarkMode(context)
                              ? AppColorsDark.primary
                              : AppColors.primary,
                      labelStyle: const TextStyle(color: Colors.white),
                    ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildPortfolioTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Portfolio', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),

          // Photographer details
          InfoCard(
            title: 'About the Photographer',
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.photographer.description),
                const SizedBox(height: 16),

                // Photography styles
                const Text(
                  'Photography Styles:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ChipGroup(items: widget.photographer.styles),

                const SizedBox(height: 16),

                // Equipment
                const Text(
                  'Equipment:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...widget.photographer.equipment.map(
                  (item) => FeatureItem(text: item, icon: Icons.camera_alt),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Sample portfolio images
          InfoCard(
            title: 'Sample Work',
            content: OrientationResponsiveBuilder(
              portraitBuilder: (context, constraints) {
                // Portrait mode: 2 columns
                return _buildPortfolioGrid(2);
              },
              landscapeBuilder: (context, constraints) {
                // Landscape mode: 3 columns
                return _buildPortfolioGrid(3);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPortfolioGrid(int crossAxisCount) {
    return ResponsiveGridView(
      minItemWidth: 120,
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
      childAspectRatio: 1,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: List.generate(
        6, // Sample count
        (index) => const ImagePlaceholder(
          borderRadius: 8,
          icon: Icons.image,
          iconSize: 40,
        ),
      ),
    );
  }
}
