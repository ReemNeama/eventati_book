import 'package:flutter/material.dart';
import 'package:eventati_book/models/models.dart';
import 'package:eventati_book/utils/utils.dart';
import 'package:eventati_book/utils/logger.dart';
import 'package:eventati_book/styles/app_colors.dart';
import 'package:eventati_book/styles/app_colors_dark.dart';
import 'package:eventati_book/widgets/details/package_card.dart';
import 'package:eventati_book/widgets/details/feature_item.dart';
import 'package:eventati_book/widgets/details/info_card.dart';
import 'package:eventati_book/widgets/details/detail_tab_bar.dart';
import 'package:eventati_book/widgets/details/image_placeholder.dart';
import 'package:eventati_book/widgets/details/chip_group.dart';
import 'package:eventati_book/widgets/common/image_gallery.dart';
import 'package:eventati_book/widgets/common/share_button.dart';
import 'package:eventati_book/providers/providers.dart';
import 'package:provider/provider.dart';
import 'package:eventati_book/routing/routing.dart';
import 'package:uuid/uuid.dart';

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

  List<String> _venueImages = [];
  bool _isLoadingImages = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadVenueImages();

    // Track service view
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _trackServiceView();
    });
  }

  /// Track that this service was viewed
  void _trackServiceView() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final activityProvider = Provider.of<RecentActivityProvider>(
      context,
      listen: false,
    );

    // Only track if user is logged in
    if (authProvider.user == null) return;

    // Create activity
    final activity = RecentActivity(
      id: const Uuid().v4(),
      userId: authProvider.user!.id,
      type: ActivityType.viewedService,
      title: widget.venue.name,
      description: widget.venue.description,
      entityId: widget.venue.name, // Using name as ID for now
      entityType: 'venue',
      route: RouteNames.venueDetails,
      routeParams: {'venueId': widget.venue.name},
      timestamp: DateTime.now(),
    );

    // Add activity
    activityProvider.addActivity(activity);
  }

  /// Load venue images from storage
  Future<void> _loadVenueImages() async {
    setState(() {
      _isLoadingImages = true;
    });

    try {
      // Start with the main image if it exists
      if (widget.venue.imageUrl.isNotEmpty &&
          !widget.venue.imageUrl.startsWith('assets/')) {
        _venueImages = [widget.venue.imageUrl];
      }

      // Add any additional images from the imageUrls list
      if (widget.venue.imageUrls.isNotEmpty) {
        _venueImages.addAll(widget.venue.imageUrls);
      }

      // Remove duplicates
      _venueImages = _venueImages.toSet().toList();
    } catch (e) {
      Logger.e('Error loading venue images: $e', tag: 'VenueDetailsScreen');
    } finally {
      setState(() {
        _isLoadingImages = false;
      });
    }
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

    // Get comparison provider
    final comparisonProvider = Provider.of<ComparisonProvider>(context);
    final isInComparison = comparisonProvider.isServiceSelected(widget.venue);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.venue.name),
        backgroundColor: primaryColor,
        actions: [
          // Share button
          ShareButton(
            contentType: ShareContentType.venue,
            content: widget.venue,
            tooltip: 'Share this venue',
          ),
          // Save button
          IconButton(
            icon: const Icon(Icons.bookmark_border),
            onPressed: () {
              UIUtils.showSnackBar(context, 'Save functionality coming soon!');
            },
            tooltip: 'Save this venue',
          ),
          // Compare button
          IconButton(
            icon: Icon(
              isInComparison ? Icons.compare_arrows : Icons.compare,
              color: isInComparison ? Colors.amber : null,
            ),
            onPressed: () {
              comparisonProvider.toggleServiceSelection(widget.venue);
              UIUtils.showSnackBar(
                context,
                isInComparison
                    ? 'Removed from comparison'
                    : 'Added to comparison',
              );
            },
            tooltip:
                isInComparison ? 'Remove from comparison' : 'Add to comparison',
          ),
        ],
        bottom: DetailTabBar(
          tabController: _tabController!,
          tabTitles: const ['Overview', 'Packages', 'Features', 'Reviews'],
        ),
      ),
      body: TabBarView(
        controller: _tabController!,
        children: [
          _buildOverviewTab(),
          _buildPackagesTab(),
          _buildFeaturesTab(),
          _buildReviewsTab(),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Price display
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Starting from', style: TextStyle(fontSize: 12)),
                Text(
                  ServiceUtils.formatPrice(
                    widget.venue.pricePerEvent,
                    showPerEvent: true,
                    decimalPlaces: 0,
                  ),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            // Book now button
            ElevatedButton.icon(
              onPressed:
                  _selectedPackageIndex >= 0
                      ? () => _navigateToBookingForm()
                      : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _getButtonBackgroundColor(
                  primaryColor,
                  isDarkMode,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              icon: const Icon(Icons.calendar_today),
              label: const Text('Book Now'),
            ),
          ],
        ),
      ),
    );
  }

  /// Get the background color for the booking button based on selection state and theme
  Color _getButtonBackgroundColor(Color primaryColor, bool isDarkMode) {
    if (_selectedPackageIndex >= 0) {
      return primaryColor;
    } else {
      // Package not selected, use a disabled color based on theme
      return isDarkMode
          ? Color.fromRGBO(
            AppColors.disabled.r.toInt(),
            AppColors.disabled.g.toInt(),
            AppColors.disabled.b.toInt(),
            0.7,
          )
          : Color.fromRGBO(
            AppColors.disabled.r.toInt(),
            AppColors.disabled.g.toInt(),
            AppColors.disabled.b.toInt(),
            0.4,
          );
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

  /// Builds the overview tab with key venue information
  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.mediumPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildVenueImage(),
          _buildVenueRecommendation(),
          _buildVenueInfo(),
          const SizedBox(height: AppConstants.mediumPadding),
          _buildLocationInfo(),
        ],
      ),
    );
  }

  /// Builds the features tab with detailed venue features
  Widget _buildFeaturesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.mediumPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildVenueFeatures(),
          const SizedBox(height: AppConstants.mediumPadding),
          _buildAmenitiesSection(),
          const SizedBox(height: AppConstants.mediumPadding),
          _buildAccessibilitySection(),
        ],
      ),
    );
  }

  /// Builds the reviews tab with venue reviews and ratings
  Widget _buildReviewsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.mediumPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildRatingSummary(),
          const SizedBox(height: AppConstants.mediumPadding),
          _buildReviewsList(),
        ],
      ),
    );
  }

  /// Builds the amenities section
  Widget _buildAmenitiesSection() {
    // Sample amenities data
    final List<String> amenities = [
      'Free Wi-Fi',
      'Air Conditioning',
      'Catering Kitchen',
      'Restrooms',
      'Coat Check',
      'Outdoor Space',
      'Stage Area',
      'Dance Floor',
      'Bar Area',
    ];

    return InfoCard(
      title: 'Amenities',
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...amenities.map(
            (amenity) => FeatureItem(
              text: amenity,
              padding: const EdgeInsets.only(bottom: AppConstants.smallPadding),
              iconSize: 20,
              icon: Icons.check_circle_outline,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the accessibility section
  Widget _buildAccessibilitySection() {
    // Sample accessibility data
    final List<String> accessibility = [
      'Wheelchair Accessible',
      'Elevator Access',
      'Accessible Restrooms',
      'Accessible Parking',
      'Service Animal Friendly',
    ];

    return InfoCard(
      title: 'Accessibility',
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...accessibility.map(
            (feature) => FeatureItem(
              text: feature,
              padding: const EdgeInsets.only(bottom: AppConstants.smallPadding),
              iconSize: 20,
              icon: Icons.accessibility_new,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the rating summary section
  Widget _buildRatingSummary() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.mediumPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Rating Summary',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppConstants.mediumPadding),
            Row(
              children: [
                Text(
                  widget.venue.rating.toString(),
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: AppConstants.mediumPadding),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: List.generate(5, (index) {
                        return Icon(
                          index < widget.venue.rating.floor()
                              ? Icons.star
                              : (index < widget.venue.rating
                                  ? Icons.star_half
                                  : Icons.star_border),
                          color: Colors.amber,
                          size: 24,
                        );
                      }),
                    ),
                    const Text('Based on 24 reviews'),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppConstants.mediumPadding),
            _buildRatingBar('Location', 4.8),
            _buildRatingBar('Value', 4.5),
            _buildRatingBar('Service', 4.7),
            _buildRatingBar('Cleanliness', 4.6),
          ],
        ),
      ),
    );
  }

  /// Builds a rating bar for a specific category
  Widget _buildRatingBar(String category, double rating) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.smallPadding),
      child: Row(
        children: [
          SizedBox(width: 100, child: Text(category)),
          Expanded(
            child: LinearProgressIndicator(
              value: rating / 5,
              backgroundColor: Colors.grey[300],
              color: Colors.amber,
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: AppConstants.smallPadding),
          Text(rating.toString()),
        ],
      ),
    );
  }

  /// Builds the reviews list section
  Widget _buildReviewsList() {
    // Sample review data
    final List<Map<String, dynamic>> reviews = [
      {
        'name': 'John D.',
        'rating': 5.0,
        'date': 'June 15, 2023',
        'comment':
            'Amazing venue! Perfect for our wedding. The staff was incredibly helpful and the space was beautiful.',
      },
      {
        'name': 'Sarah M.',
        'rating': 4.5,
        'date': 'May 22, 2023',
        'comment':
            'Great location and amenities. The only issue was limited parking, but everything else was perfect.',
      },
      {
        'name': 'Michael T.',
        'rating': 4.0,
        'date': 'April 10, 2023',
        'comment':
            'Good venue for our corporate event. Sound system could be better, but the space worked well for our needs.',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Reviews', style: Theme.of(context).textTheme.titleMedium),
            TextButton(
              onPressed: () {
                UIUtils.showSnackBar(
                  context,
                  'Write a review functionality coming soon!',
                );
              },
              child: const Text('Write a Review'),
            ),
          ],
        ),
        const SizedBox(height: AppConstants.smallPadding),
        ...reviews.map((review) => _buildReviewItem(review)),
        const SizedBox(height: AppConstants.mediumPadding),
        Center(
          child: TextButton(
            onPressed: () {
              UIUtils.showSnackBar(
                context,
                'View all reviews functionality coming soon!',
              );
            },
            child: const Text('View All Reviews'),
          ),
        ),
      ],
    );
  }

  /// Builds a single review item
  Widget _buildReviewItem(Map<String, dynamic> review) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppConstants.mediumPadding),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.mediumPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  review['name'],
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(review['date']),
              ],
            ),
            const SizedBox(height: AppConstants.smallPadding),
            Row(
              children: List.generate(5, (index) {
                return Icon(
                  index < review['rating'].floor()
                      ? Icons.star
                      : (index < review['rating']
                          ? Icons.star_half
                          : Icons.star_border),
                  color: Colors.amber,
                  size: 16,
                );
              }),
            ),
            const SizedBox(height: AppConstants.smallPadding),
            Text(review['comment']),
          ],
        ),
      ),
    );
  }

  /// Builds the venue image gallery
  Widget _buildVenueImage() {
    return Column(
      children: [
        if (_isLoadingImages)
          const Center(child: CircularProgressIndicator())
        else if (_venueImages.isEmpty)
          const ImagePlaceholder(
            height: 200,
            width: double.infinity,
            borderRadius: AppConstants.mediumBorderRadius,
            icon: Icons.image,
            iconSize: 50,
          )
        else
          ImageGallery(
            imageUrls: _venueImages,
            height: 250,
            width: double.infinity,
            borderRadius: AppConstants.mediumBorderRadius,
            enableFullScreen: true,
            emptyText: 'No images available for this venue',
          ),
        const SizedBox(height: AppConstants.mediumPadding),
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
