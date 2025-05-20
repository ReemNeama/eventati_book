import 'package:flutter/material.dart';
import 'package:eventati_book/models/models.dart';
import 'package:eventati_book/utils/utils.dart';
import 'package:eventati_book/styles/app_colors.dart';
import 'package:eventati_book/styles/app_colors_dark.dart';
import 'package:eventati_book/widgets/details/package_card.dart';
import 'package:eventati_book/widgets/details/info_card.dart';
import 'package:eventati_book/widgets/details/detail_tab_bar.dart';
import 'package:eventati_book/widgets/details/image_placeholder.dart';
import 'package:eventati_book/routing/routing.dart';
import 'package:eventati_book/providers/providers.dart';
import 'package:provider/provider.dart';
import 'package:eventati_book/styles/text_styles.dart';
import 'package:uuid/uuid.dart';

class CateringDetailsScreen extends StatefulWidget {
  final CateringService cateringService;

  const CateringDetailsScreen({super.key, required this.cateringService});

  @override
  State<CateringDetailsScreen> createState() => _CateringDetailsScreenState();
}

class _CateringDetailsScreenState extends State<CateringDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedPackageIndex = -1;

  // Sample data for packages
  final List<CateringPackage> _packages = [
    CateringPackage(
      name: 'Bronze Package',
      description: 'Basic catering package for small events',
      price: 45.0,
      includedItems: ['3 Main Dishes', '3 Appetizers', '3 Desserts'],
      additionalServices: ['2 Staff Members', 'Basic Setup and Cleanup'],
    ),
    CateringPackage(
      name: 'Silver Package',
      description: 'Premium catering package for medium events',
      price: 65.0,
      includedItems: ['5 Main Dishes', '5 Appetizers', '4 Desserts'],
      additionalServices: [
        '4 Staff Members',
        'Full Setup and Cleanup',
        'Decorative Food Display',
      ],
    ),
    CateringPackage(
      name: 'Gold Package',
      description: 'Luxury catering package for large events',
      price: 85.0,
      includedItems: [
        '7 Main Dishes',
        '7 Appetizers',
        '5 Desserts',
        'Signature Drinks',
      ],
      additionalServices: [
        '6 Staff Members',
        'Full Setup and Cleanup',
        'Premium Food Display',
        'Dedicated Event Manager',
      ],
    ),
  ];

  // Sample data for menu items
  final List<MenuItem> _menuItems = [
    // Main Dishes
    MenuItem(
      name: 'Grilled Salmon',
      description: 'Fresh salmon fillet with lemon herb butter',
      category: 'Main Dish',
      price: 18.99,
    ),
    MenuItem(
      name: 'Beef Tenderloin',
      description: 'Slow-roasted beef with red wine reduction',
      category: 'Main Dish',
      price: 22.99,
    ),
    MenuItem(
      name: 'Chicken Marsala',
      description: 'Chicken breast with mushroom marsala sauce',
      category: 'Main Dish',
      price: 16.99,
    ),
    MenuItem(
      name: 'Vegetable Lasagna',
      description: 'Layered pasta with seasonal vegetables and cheese',
      category: 'Main Dish',
      price: 14.99,
    ),
    // Appetizers
    MenuItem(
      name: 'Bruschetta',
      description: 'Toasted bread with tomato, basil, and garlic',
      category: 'Appetizer',
      price: 8.99,
    ),
    MenuItem(
      name: 'Shrimp Cocktail',
      description: 'Chilled shrimp with spicy cocktail sauce',
      category: 'Appetizer',
      price: 12.99,
    ),
    MenuItem(
      name: 'Stuffed Mushrooms',
      description: 'Mushroom caps filled with herb cream cheese',
      category: 'Appetizer',
      price: 9.99,
    ),
    // Desserts
    MenuItem(
      name: 'Chocolate Mousse',
      description: 'Rich chocolate mousse with whipped cream',
      category: 'Dessert',
      price: 7.99,
    ),
    MenuItem(
      name: 'Tiramisu',
      description: 'Classic Italian dessert with coffee and mascarpone',
      category: 'Dessert',
      price: 8.99,
    ),
    MenuItem(
      name: 'Fruit Tart',
      description: 'Buttery tart shell with pastry cream and fresh fruits',
      category: 'Dessert',
      price: 6.99,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

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
      title: widget.cateringService.name,
      description: widget.cateringService.description,
      entityId: widget.cateringService.name, // Using name as ID for now
      entityType: 'catering',
      route: RouteNames.cateringDetails,
      routeParams: {'cateringId': widget.cateringService.name},
      timestamp: DateTime.now(),
    );

    // Add activity
    activityProvider.addActivity(activity);
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

    // Get comparison provider
    final comparisonProvider = Provider.of<ComparisonProvider>(context);
    final isInComparison = comparisonProvider.isServiceSelected(
      widget.cateringService,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.cateringService.name),
        backgroundColor: primaryColor,
        actions: [
          // Share button
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              UIUtils.showSnackBar(context, 'Share functionality coming soon!');
            },
            tooltip: 'Share this catering service',
          ),
          // Save button
          IconButton(
            icon: const Icon(Icons.bookmark_border),
            onPressed: () {
              UIUtils.showSnackBar(context, 'Save functionality coming soon!');
            },
            tooltip: 'Save this catering service',
          ),
          // Compare button
          IconButton(
            icon: Icon(
              isInComparison ? Icons.compare_arrows : Icons.compare,
              color: isInComparison ? Colors.amber : null,
            ),
            onPressed: () {
              comparisonProvider.toggleServiceSelection(widget.cateringService);
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
          tabController: _tabController,
          tabTitles: const ['Overview', 'Packages', 'Menu', 'Reviews'],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          _buildPackagesTab(),
          _buildMenuTab(),
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
                    widget.cateringService.pricePerPerson,
                    showPerPerson: true,
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
                backgroundColor:
                    _selectedPackageIndex >= 0
                        ? primaryColor
                        : isDarkMode
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
        serviceId: widget.cateringService.name, // Using name as ID for now
        serviceType: 'catering',
        serviceName: widget.cateringService.name,
        basePrice: selectedPackage.price,
        // Optional event parameters can be added here if available
      ),
    );
  }

  /// Builds the recommendation section if the service is recommended
  Widget _buildRecommendationSection() {
    return Consumer<ServiceRecommendationProvider>(
      builder: (context, provider, _) {
        // Only show if there's wizard data and the service is recommended
        if (provider.wizardData == null) {
          return const SizedBox.shrink();
        }

        final isRecommended = provider.isCateringServiceRecommended(
          widget.cateringService,
        );
        if (!isRecommended) {
          return const SizedBox.shrink();
        }

        final recommendationReason = provider.getCateringRecommendationReason(
          widget.cateringService,
        );

        return InfoCard(
          title: 'Recommended for Your Event',
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.thumb_up, color: AppColors.success),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      recommendationReason ??
                          'This catering service is recommended for your event',
                      style: TextStyles.bodyLarge,
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

  Widget _buildPackagesTab() {
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
          ...List.generate(_packages.length, (index) {
            final package = _packages[index];
            final isSelected = _selectedPackageIndex == index;

            return PackageCard(
              name: package.name,
              description: package.description,
              price: package.price,
              includedItems: package.includedItems,
              additionalFeatures: package.additionalServices,
              isSelected: isSelected,
              onTap: () {
                setState(() {
                  _selectedPackageIndex = index;
                });
              },
              additionalInfo: Text(
                '/person',
                style: TextStyle(
                  color:
                      UIUtils.isDarkMode(context)
                          ? AppColorsDark.primary
                          : AppColors.primary,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  /// Builds the overview tab with key catering service information
  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildServiceImage(),
          const SizedBox(height: 16),
          _buildRecommendationSection(),
          const SizedBox(height: 16),
          _buildServiceInfo(),
          const SizedBox(height: 16),
          _buildCuisineTypes(),
          const SizedBox(height: 16),
          _buildCapacityInfo(),
        ],
      ),
    );
  }

  /// Builds the service image section
  Widget _buildServiceImage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.cateringService.imageUrl.isNotEmpty)
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              widget.cateringService.imageUrl,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return const ImagePlaceholder(
                  height: 200,
                  width: double.infinity,
                  borderRadius: 8,
                  icon: Icons.restaurant,
                  iconSize: 50,
                );
              },
            ),
          )
        else
          const ImagePlaceholder(
            height: 200,
            width: double.infinity,
            borderRadius: 8,
            icon: Icons.restaurant,
            iconSize: 50,
          ),
      ],
    );
  }

  /// Builds the service information section
  Widget _buildServiceInfo() {
    return InfoCard(
      title: 'About',
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.cateringService.description),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.star, color: Colors.amber, size: 20),
              const SizedBox(width: 4),
              Text(
                '${widget.cateringService.rating} Rating',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Builds the cuisine types section
  Widget _buildCuisineTypes() {
    return InfoCard(
      title: 'Cuisine Types',
      content: Wrap(
        spacing: 8,
        runSpacing: 8,
        children:
            widget.cateringService.cuisineTypes.map((cuisine) {
              return Chip(
                label: Text(cuisine),
                backgroundColor: Color.fromRGBO(
                  Theme.of(context).primaryColor.r.toInt(),
                  Theme.of(context).primaryColor.g.toInt(),
                  Theme.of(context).primaryColor.b.toInt(),
                  0.1,
                ),
              );
            }).toList(),
      ),
    );
  }

  /// Builds the capacity information section
  Widget _buildCapacityInfo() {
    return InfoCard(
      title: 'Capacity',
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.people, size: 20),
              const SizedBox(width: 8),
              Text(
                'Minimum: ${NumberUtils.formatWithCommas(widget.cateringService.minCapacity)} guests',
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.people, size: 20),
              const SizedBox(width: 8),
              Text(
                'Maximum: ${NumberUtils.formatWithCommas(widget.cateringService.maxCapacity)} guests',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMenuTab() {
    // Group menu items by category
    final Map<String, List<MenuItem>> categorizedItems = {};
    for (var item in _menuItems) {
      if (!categorizedItems.containsKey(item.category)) {
        categorizedItems[item.category] = [];
      }
      categorizedItems[item.category]!.add(item);
    }

    final bool isDarkMode = UIUtils.isDarkMode(context);
    final Color primaryColor =
        isDarkMode ? AppColorsDark.primary : AppColors.primary;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Food Menu', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          ...categorizedItems.entries.map((entry) {
            final category = entry.key;
            final items = entry.value;

            return Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: InfoCard(
                title: category,
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ...items.map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const ImagePlaceholder(
                              height: 60,
                              width: 60,
                              borderRadius: 8,
                              icon: Icons.restaurant,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          item.name,
                                          style: TextStyles.bodyLarge.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      if (item.price != null)
                                        Text(
                                          ServiceUtils.formatPrice(
                                            item.price!,
                                            decimalPlaces: 2,
                                          ),
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: primaryColor,
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    item.description,
                                    style: TextStyle(
                                      color:
                                          isDarkMode
                                              ? Color.fromRGBO(
                                                AppColors.disabled.r.toInt(),
                                                AppColors.disabled.g.toInt(),
                                                AppColors.disabled.b.toInt(),
                                                0.3,
                                              )
                                              : Color.fromRGBO(
                                                AppColors.disabled.r.toInt(),
                                                AppColors.disabled.g.toInt(),
                                                AppColors.disabled.b.toInt(),
                                                0.7,
                                              ),
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  /// Builds the reviews tab with catering service reviews and ratings
  Widget _buildReviewsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildRatingSummary(),
          const SizedBox(height: 16),
          _buildReviewsList(),
        ],
      ),
    );
  }

  /// Builds the rating summary section
  Widget _buildRatingSummary() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Rating Summary',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Text(
                  widget.cateringService.rating.toString(),
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: List.generate(5, (index) {
                        return Icon(
                          index < widget.cateringService.rating.floor()
                              ? Icons.star
                              : (index < widget.cateringService.rating
                                  ? Icons.star_half
                                  : Icons.star_border),
                          color: Colors.amber,
                          size: 24,
                        );
                      }),
                    ),
                    const Text('Based on 18 reviews'),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildRatingBar('Food Quality', 4.7),
            _buildRatingBar('Service', 4.5),
            _buildRatingBar('Value', 4.3),
            _buildRatingBar('Presentation', 4.8),
          ],
        ),
      ),
    );
  }

  /// Builds a rating bar for a specific category
  Widget _buildRatingBar(String category, double rating) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
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
          const SizedBox(width: 8),
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
        'name': 'Emily R.',
        'rating': 5.0,
        'date': 'July 10, 2023',
        'comment':
            'The food was absolutely amazing! Everyone at our wedding raved about it. The staff was professional and attentive.',
      },
      {
        'name': 'David K.',
        'rating': 4.5,
        'date': 'June 5, 2023',
        'comment':
            'Great food and presentation. The only issue was they arrived a bit late, but they made up for it with excellent service.',
      },
      {
        'name': 'Jessica M.',
        'rating': 4.0,
        'date': 'May 22, 2023',
        'comment':
            'Good variety of options and the food tasted great. Would recommend for corporate events.',
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
        const SizedBox(height: 8),
        ...reviews.map((review) => _buildReviewItem(review)),
        const SizedBox(height: 16),
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
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
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
            const SizedBox(height: 8),
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
            const SizedBox(height: 8),
            Text(review['comment']),
          ],
        ),
      ),
    );
  }
}
