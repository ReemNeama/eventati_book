import 'package:flutter/material.dart';
import 'package:eventati_book/models/models.dart';
import 'package:eventati_book/utils/utils.dart';
import 'package:eventati_book/widgets/widgets.dart';
import 'package:eventati_book/providers/providers.dart';
import 'package:provider/provider.dart';
import 'package:eventati_book/routing/routing.dart';
import 'package:eventati_book/services/services.dart';

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

  /// Reset all filters to their default values
  void _resetFilters() {
    setState(() {
      _searchQuery = '';
      _searchController.clear();
      _selectedVenueTypes.clear();
      _priceRange = const RangeValues(1000, 5000);
      _capacityRange = const RangeValues(50, 300);
      _showRecommendedOnly = false;
    });
  }

  /// Remove a specific filter based on its display text
  void _removeFilter(String filter) {
    if (filter.startsWith('Search:')) {
      setState(() {
        _searchQuery = '';
        _searchController.clear();
      });
    } else if (filter.startsWith('Types:')) {
      setState(() {
        _selectedVenueTypes.clear();
      });
    } else if (filter.startsWith('Price:')) {
      setState(() {
        _priceRange = const RangeValues(1000, 5000);
      });
    } else if (filter.startsWith('Capacity:')) {
      setState(() {
        _capacityRange = const RangeValues(50, 300);
      });
    } else if (filter == 'Recommended Only') {
      setState(() {
        _showRecommendedOnly = false;
      });
    }
  }

  /// Show the comparison drawer
  void _showComparisonDrawer(BuildContext context, List<Venue> venues) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => DraggableScrollableSheet(
            initialChildSize: 0.9,
            minChildSize: 0.5,
            maxChildSize: 0.95,
            builder: (context, scrollController) {
              return ComparisonDrawer(
                services: venues,
                serviceType: 'Venue',
                onFullComparisonPressed: () {
                  Navigator.pop(context);
                  NavigationUtils.navigateToNamed(
                    context,
                    RouteNames.serviceComparison,
                    arguments: const ServiceComparisonArguments(
                      serviceType: 'Venue',
                    ),
                  );
                },
                onSaveComparisonPressed: () {
                  UIUtils.showSnackBar(
                    context,
                    'Save comparison functionality coming soon!',
                  );
                },
                onShareComparisonPressed: () {
                  UIUtils.showSnackBar(
                    context,
                    'Share comparison functionality coming soon!',
                  );
                },
                onRemoveService: (service) {
                  if (service is Venue) {
                    Provider.of<ComparisonProvider>(
                      context,
                      listen: false,
                    ).toggleServiceSelection(service);
                    Navigator.pop(context);
                  }
                },
              );
            },
          ),
    );
  }

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

  // Scroll controller for the venue list
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    final serviceRecommendationProvider =
        Provider.of<ServiceRecommendationProvider>(context);
    final comparisonProvider = Provider.of<ComparisonProvider>(context);

    // Get active filters for display
    final List<String> activeFilters = [];
    if (_searchQuery.isNotEmpty) {
      activeFilters.add('Search: $_searchQuery');
    }
    if (_selectedVenueTypes.isNotEmpty) {
      activeFilters.add('Types: ${_selectedVenueTypes.length} selected');
    }
    if (_priceRange.start > 1000 || _priceRange.end < 5000) {
      activeFilters.add(
        'Price: ${NumberUtils.formatCurrency(_priceRange.start)} - ${NumberUtils.formatCurrency(_priceRange.end)}',
      );
    }
    if (_capacityRange.start > 50 || _capacityRange.end < 300) {
      activeFilters.add(
        'Capacity: ${_capacityRange.start.round()} - ${_capacityRange.end.round()} guests',
      );
    }
    if (_showRecommendedOnly) {
      activeFilters.add('Recommended Only');
    }

    // Get comparison count
    final int comparisonCount = comparisonProvider.getSelectedCount('Venue');
    final bool canCompare = comparisonCount >= 2;

    // Get selected venues for comparison
    final List<Venue> selectedVenues = comparisonProvider.selectedVenues;

    return Scaffold(
      backgroundColor: Theme.of(context).canvasColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: const Text('Venues'),
        actions: [
          // Comparison button in app bar
          if (comparisonCount > 0)
            IconButton(
              icon: Badge(
                label: Text('$comparisonCount'),
                isLabelVisible: comparisonCount > 0,
                child: const Icon(Icons.compare_arrows),
              ),
              onPressed:
                  canCompare
                      ? () {
                        _showComparisonDrawer(context, selectedVenues);
                      }
                      : null,
              tooltip:
                  canCompare
                      ? 'Compare selected venues'
                      : 'Select at least 2 venues to compare',
            ),
        ],
      ),
      body: ResponsiveBuilder(
        // Mobile layout (portrait phones)
        mobileBuilder: (context, constraints) {
          return Column(
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
                sortOptions: SortService.getAllSortOptions(),
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
                // Enhanced filter bar features
                activeFilters: activeFilters,
                onFilterRemoved: (filter) {
                  _removeFilter(filter);
                },
                onClearAllFilters: () {
                  _resetFilters();
                },
                showActiveFilters: activeFilters.isNotEmpty,
                // Comparison features
                showComparisonButton: true,
                isComparisonActive: comparisonCount > 0,
                onComparisonTap:
                    canCompare
                        ? () {
                          _showComparisonDrawer(context, selectedVenues);
                        }
                        : null,
                comparisonCount: comparisonCount,
              ),
              Expanded(
                child: ScrollToTopWrapper(
                  scrollController: _scrollController,
                  child: _buildVenueList(
                    filteredVenues,
                    serviceRecommendationProvider,
                    comparisonProvider,
                  ),
                ),
              ),
            ],
          );
        },
        // Tablet layout (landscape phones and tablets)
        tabletBuilder: (context, constraints) {
          return _buildTabletLayout(
            filteredVenues,
            serviceRecommendationProvider,
            comparisonProvider,
          );
        },
      ),
      floatingActionButton: ComparisonFloatingButton(
        selectedCount: comparisonCount,
        minItemsForComparison: 2,
        onPressed: () {
          NavigationUtils.navigateToNamed(
            context,
            RouteNames.serviceComparison,
            arguments: const ServiceComparisonArguments(serviceType: 'Venue'),
          );
        },
        visible: comparisonCount > 0,
      ),
    );
  }

  /// Builds the venue list or empty state
  Widget _buildVenueList(
    List<Venue> venues,
    ServiceRecommendationProvider serviceRecommendationProvider,
    ComparisonProvider comparisonProvider,
  ) {
    return venues.isEmpty
        ? Center(
          child: EmptyState(
            title:
                _searchQuery.isNotEmpty ||
                        _selectedVenueTypes.isNotEmpty ||
                        _showRecommendedOnly
                    ? 'No Matching Venues'
                    : 'No Venues Available',
            message:
                _searchQuery.isNotEmpty ||
                        _selectedVenueTypes.isNotEmpty ||
                        _showRecommendedOnly
                    ? 'Try adjusting your filters or search criteria'
                    : 'Check back later for available venues',
            icon: Icons.location_city,
            actionText:
                _searchQuery.isNotEmpty ||
                        _selectedVenueTypes.isNotEmpty ||
                        _showRecommendedOnly
                    ? 'Clear Filters'
                    : null,
            onAction:
                _searchQuery.isNotEmpty ||
                        _selectedVenueTypes.isNotEmpty ||
                        _showRecommendedOnly
                    ? () {
                      setState(() {
                        _searchQuery = '';
                        _searchController.clear();
                        _selectedVenueTypes.clear();
                        _priceRange = const RangeValues(1000, 5000);
                        _capacityRange = const RangeValues(50, 300);
                        _showRecommendedOnly = false;
                      });
                    }
                    : null,
            displayType: EmptyStateDisplayType.standard,
            animationType: EmptyStateAnimationType.fadeIn,
          ),
        )
        : ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.all(16),
          itemCount: venues.length,
          itemBuilder: (context, index) {
            final venue = venues[index];
            final isRecommended = serviceRecommendationProvider
                .isVenueRecommended(venue);
            final recommendationReason =
                isRecommended
                    ? serviceRecommendationProvider
                        .getVenueRecommendationReason(venue)
                    : null;

            return TooltipUtils.infoTooltip(
              message: 'View details for ${venue.name}',
              child: ServiceCard(
                // Basic info
                name: venue.name,
                description: venue.description,
                rating: venue.rating,
                imageUrl: venue.imageUrl,

                // Recommendation and comparison
                isRecommended: isRecommended,
                recommendationReason: recommendationReason,
                isCompareSelected: comparisonProvider.isServiceSelected(venue),
                onCompareToggle: (_) {
                  comparisonProvider.toggleServiceSelection(venue);
                },

                // Enhanced features
                price: venue.pricePerEvent,
                priceType: PriceType.perEvent,
                tags: venue.venueTypes,
                minCapacity: venue.minCapacity,
                maxCapacity: venue.maxCapacity,
                isAvailable: true,
                isFeatured: venue.name == 'Historic Manor House', // Example
                // Quick actions
                onShare: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Share functionality coming soon!'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                onSave: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Save functionality coming soon!'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },

                // Navigation
                onTap: () {
                  NavigationUtils.navigateToNamed(
                    context,
                    RouteNames.venueDetails,
                    arguments: VenueDetailsArguments(
                      venueId: venue.name,
                    ), // Using name as ID for now
                  );
                },
              ),
            );
          },
        );
  }

  /// Builds a side-by-side layout for tablets and larger screens
  Widget _buildTabletLayout(
    List<Venue> venues,
    ServiceRecommendationProvider serviceRecommendationProvider,
    ComparisonProvider comparisonProvider,
  ) {
    return Column(
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
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Filter panel on the left (30% width)
              Expanded(
                flex: 30,
                child: Card(
                  margin: const EdgeInsets.all(16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Venue Types',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: ListView(
                            children:
                                [
                                      'Ballroom',
                                      'Garden',
                                      'Beach',
                                      'Historic',
                                      'Modern',
                                      'Rustic',
                                      'Rooftop',
                                    ]
                                    .map(
                                      (type) => CheckboxListTile(
                                        title: Text(type),
                                        value: _selectedVenueTypes.contains(
                                          type,
                                        ),
                                        onChanged: (selected) {
                                          setState(() {
                                            if (selected ?? false) {
                                              _selectedVenueTypes.add(type);
                                            } else {
                                              _selectedVenueTypes.remove(type);
                                            }
                                          });
                                        },
                                        dense: true,
                                      ),
                                    )
                                    .toList(),
                          ),
                        ),
                        const Divider(),
                        Text(
                          'Price Range',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        RangeSlider(
                          values: _priceRange,
                          min: 1000,
                          max: 10000,
                          divisions: 18,
                          labels: RangeLabels(
                            NumberUtils.formatCurrency(
                              _priceRange.start,
                              decimalPlaces: 0,
                            ),
                            NumberUtils.formatCurrency(
                              _priceRange.end,
                              decimalPlaces: 0,
                            ),
                          ),
                          onChanged: (values) {
                            setState(() {
                              _priceRange = values;
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Capacity Range',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        RangeSlider(
                          values: _capacityRange,
                          min: 50,
                          max: 1000,
                          divisions: 19,
                          labels: RangeLabels(
                            '${_capacityRange.start.round()}',
                            '${_capacityRange.end.round()}',
                          ),
                          onChanged: (values) {
                            setState(() {
                              _capacityRange = values;
                            });
                          },
                        ),
                        Consumer<ServiceRecommendationProvider>(
                          builder: (context, provider, _) {
                            // Only show the recommended filter if there's wizard data
                            if (provider.wizardData == null) {
                              return const SizedBox.shrink();
                            }

                            return CheckboxListTile(
                              title: const Text('Show Recommended Only'),
                              value: _showRecommendedOnly,
                              onChanged: (value) {
                                setState(() {
                                  _showRecommendedOnly = value ?? false;
                                });
                              },
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _searchQuery = '';
                              _searchController.clear();
                              _selectedVenueTypes.clear();
                              _priceRange = const RangeValues(1000, 5000);
                              _capacityRange = const RangeValues(50, 300);
                              _showRecommendedOnly = false;
                            });
                          },
                          child: const Text('Reset Filters'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Venue list on the right (70% width)
              Expanded(
                flex: 70,
                child: ScrollToTopWrapper(
                  scrollController: _scrollController,
                  child: _buildVenueList(
                    venues,
                    serviceRecommendationProvider,
                    comparisonProvider,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
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
    _scrollController.dispose();
    super.dispose();
  }
}
