import 'package:flutter/material.dart';
import 'package:eventati_book/models/models.dart';
import 'package:eventati_book/widgets/services/filter/service_filter_bar.dart';
import 'package:eventati_book/widgets/services/card/service_card.dart';
import 'package:eventati_book/widgets/services/filter/filter_dialog.dart';
import 'package:eventati_book/styles/app_colors.dart';
import 'package:eventati_book/styles/app_colors_dark.dart';
import 'package:eventati_book/utils/utils.dart';
import 'package:eventati_book/screens/services/venue/venue_details_screen.dart';
import 'package:eventati_book/screens/services/comparison/service_comparison_screen.dart';
import 'package:eventati_book/providers/providers.dart';
import 'package:provider/provider.dart';
import 'package:eventati_book/widgets/services/filter/venue_filter.dart';

class VenueListScreen extends StatefulWidget {
  const VenueListScreen({super.key});

  @override
  State<VenueListScreen> createState() => _VenueListScreenState();
}

class _VenueListScreenState extends State<VenueListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedSortOption = 'Rating';
  final List<String> _selectedVenueTypes = [];
  RangeValues _priceRange = const RangeValues(1000, 5000);
  RangeValues _capacityRange = const RangeValues(50, 300);
  bool _showRecommendedOnly = false;

  final List<Venue> _venues = [
    Venue(
      name: 'Grand Plaza Hotel',
      description: 'Luxurious ballroom and outdoor garden venue',
      rating: 4.8,
      venueTypes: ['Hotel', 'Ballroom', 'Garden'],
      minCapacity: 100,
      maxCapacity: 800,
      pricePerEvent: 5000,
      imageUrl: 'assets/images/venue1.jpg',
      features: ['Parking', 'Catering Kitchen', 'AV Equipment', 'Bridal Suite'],
    ),
    Venue(
      name: 'Sunset Beach Resort',
      description: 'Beautiful beachfront venue with stunning ocean views',
      rating: 4.7,
      venueTypes: ['Beach', 'Resort', 'Outdoor'],
      minCapacity: 50,
      maxCapacity: 300,
      pricePerEvent: 3500,
      imageUrl: 'assets/images/venue2.jpg',
      features: [
        'Beach Access',
        'Indoor Backup',
        'Parking',
        'Getting Ready Rooms',
      ],
    ),
    Venue(
      name: 'Historic Manor House',
      description: 'Elegant historic mansion with classic architecture',
      rating: 4.9,
      venueTypes: ['Historic', 'Manor', 'Garden'],
      minCapacity: 75,
      maxCapacity: 500,
      pricePerEvent: 6000,
      imageUrl: 'assets/images/venue3.jpg',
      features: ['Gardens', 'Historic Tours', 'Bridal Suite', 'Parking'],
    ),
  ];

  List<Venue> get filteredVenues {
    final serviceRecommendationProvider =
        Provider.of<ServiceRecommendationProvider>(context, listen: false);

    // Filter venues based on search query, venue types, price range, capacity range, and recommendation
    final filteredList = VenueFilter.filterVenues(
      venues: _venues,
      searchQuery: _searchQuery,
      selectedVenueTypes: _selectedVenueTypes,
      priceRange: _priceRange,
      capacityRange: _capacityRange,
      showRecommendedOnly: _showRecommendedOnly,
      recommendationProvider: serviceRecommendationProvider,
    );

    // Sort venues based on sort option and recommendation status
    return VenueFilter.sortVenues(
      venues: filteredList,
      sortOption: _selectedSortOption,
      showRecommendedOnly: _showRecommendedOnly,
      recommendationProvider: serviceRecommendationProvider,
    );
  }

  @override
  Widget build(BuildContext context) {
    final serviceRecommendationProvider =
        Provider.of<ServiceRecommendationProvider>(context);
    final comparisonProvider = Provider.of<ComparisonProvider>(context);
    final isDarkMode = UIUtils.isDarkMode(context);

    return Scaffold(
      backgroundColor: Theme.of(context).canvasColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: const Text('Venues'),
      ),
      body: Column(
        children: [
          ServiceFilterBar(
            searchHint: 'Search venues...',
            searchController: _searchController,
            onSearchChanged: (query) {
              setState(() {
                _searchQuery = query;
              });
            },
            selectedSortOption: _selectedSortOption,
            sortOptions: const [
              'Rating',
              'Price (Low to High)',
              'Price (High to Low)',
              'Capacity',
            ],
            onSortChanged: (option) {
              if (option != null) {
                setState(() {
                  _selectedSortOption = option;
                });
              }
            },
            onFilterTap: () {
              _showFilterDialog(context);
            },
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filteredVenues.length,
              itemBuilder: (context, index) {
                final venue = filteredVenues[index];
                final isRecommended = serviceRecommendationProvider
                    .isVenueRecommended(venue);
                final recommendationReason =
                    isRecommended
                        ? serviceRecommendationProvider
                            .getVenueRecommendationReason(venue)
                        : null;

                return ServiceCard(
                  name: venue.name,
                  description: venue.description,
                  rating: venue.rating,
                  imageUrl: venue.imageUrl,
                  isRecommended: isRecommended,
                  recommendationReason: recommendationReason,
                  isCompareSelected: comparisonProvider.isServiceSelected(
                    venue,
                  ),
                  onCompareToggle: (_) {
                    comparisonProvider.toggleServiceSelection(venue);
                  },
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => VenueDetailsScreen(venue: venue),
                      ),
                    );
                  },
                  additionalInfo: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children:
                            venue.venueTypes
                                .map(
                                  (type) => Chip(
                                    label: Text(type),
                                    backgroundColor: AppColors.primaryWithAlpha(
                                      0.7,
                                    ),
                                  ),
                                )
                                .toList(),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Capacity: ${NumberUtils.formatWithCommas(venue.minCapacity)}-${NumberUtils.formatWithCommas(venue.maxCapacity)} guests',
                          ),
                          Text(
                            '${NumberUtils.formatCurrency(venue.pricePerEvent, decimalPlaces: 0)}/event',
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: Consumer<ComparisonProvider>(
        builder: (context, provider, child) {
          final int count = provider.getSelectedCount('Venue');

          // Only show FAB if at least 2 items are selected
          if (count >= 2) {
            return FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) =>
                            const ServiceComparisonScreen(serviceType: 'Venue'),
                  ),
                );
              },
              label: Text('Compare ($count)'),
              icon: const Icon(Icons.compare_arrows),
              backgroundColor:
                  isDarkMode ? AppColorsDark.primary : AppColors.primary,
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    // Create local variables to track changes within the dialog
    RangeValues localPriceRange = _priceRange;
    RangeValues localCapacityRange = _capacityRange;
    final List<String> localSelectedVenueTypes = List.from(_selectedVenueTypes);
    bool localShowRecommendedOnly = _showRecommendedOnly;

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setDialogState) => FilterDialog(
                  priceRange: localPriceRange,
                  onPriceRangeChanged: (values) {
                    // Update local state and dialog UI
                    setDialogState(() {
                      localPriceRange = values;
                    });
                    // Also update parent state for real-time filtering
                    setState(() {
                      _priceRange = values;
                    });
                  },
                  capacityRange: localCapacityRange,
                  onCapacityRangeChanged: (values) {
                    // Update local state and dialog UI
                    setDialogState(() {
                      localCapacityRange = values;
                    });
                    // Also update parent state for real-time filtering
                    setState(() {
                      _capacityRange = values;
                    });
                  },
                  filterOptions: const [
                    'Ballroom',
                    'Garden',
                    'Beach',
                    'Historic',
                    'Modern',
                    'Rustic',
                    'Rooftop',
                  ],
                  selectedOptions: localSelectedVenueTypes,
                  onOptionSelected: (option, selected) {
                    setDialogState(() {
                      if (selected) {
                        localSelectedVenueTypes.add(option);
                      } else {
                        localSelectedVenueTypes.remove(option);
                      }
                    });

                    setState(() {
                      _selectedVenueTypes.clear();
                      _selectedVenueTypes.addAll(localSelectedVenueTypes);
                    });
                  },
                  filterTitle: 'Venue Types',
                  extraFilterWidget: Consumer<ServiceRecommendationProvider>(
                    builder: (context, provider, _) {
                      // Only show the recommended filter if there's wizard data
                      if (provider.wizardData == null) {
                        return const SizedBox.shrink();
                      }

                      return CheckboxListTile(
                        title: const Text('Show Recommended Only'),
                        value: localShowRecommendedOnly,
                        onChanged: (value) {
                          setDialogState(() {
                            localShowRecommendedOnly = value ?? false;
                          });

                          setState(() {
                            _showRecommendedOnly = value ?? false;
                          });
                        },
                      );
                    },
                  ),
                ),
          ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
