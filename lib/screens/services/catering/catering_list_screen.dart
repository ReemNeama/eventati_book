import 'package:eventati_book/models/models.dart';
import 'package:flutter/material.dart';
import 'package:eventati_book/utils/utils.dart';
import 'package:eventati_book/providers/providers.dart';
import 'package:provider/provider.dart';
import 'package:eventati_book/routing/routing.dart';
import 'package:eventati_book/widgets/widgets.dart';
import 'package:eventati_book/services/services.dart';

class CateringListScreen extends StatefulWidget {
  const CateringListScreen({super.key});

  @override
  State<CateringListScreen> createState() => _CateringListScreenState();
}

class _CateringListScreenState extends State<CateringListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedSortOption = 'Rating';
  final List<String> _selectedCuisineTypes = [];
  RangeValues _priceRange = const RangeValues(50, 100);
  RangeValues _capacityRange = const RangeValues(30, 500);
  bool _showRecommendedOnly = false;

  final List<CateringService> _cateringServices = [
    CateringService(
      name: 'Gourmet Delights',
      description: 'Specializing in fine dining and international cuisine',
      rating: 4.8,
      cuisineTypes: ['International', 'Fine Dining', 'Mediterranean'],
      minCapacity: 50,
      maxCapacity: 500,
      pricePerPerson: 85,
      imageUrl: 'assets/images/catering1.jpg',
    ),
    CateringService(
      name: 'Asian Fusion Catering',
      description: 'Modern Asian cuisine with a contemporary twist',
      rating: 4.6,
      cuisineTypes: ['Asian', 'Fusion', 'International'],
      minCapacity: 30,
      maxCapacity: 300,
      pricePerPerson: 65,
      imageUrl: 'assets/images/catering2.jpg',
    ),
    CateringService(
      name: 'Mediterranean Feast',
      description: 'Authentic Mediterranean dishes and mezze platters',
      rating: 4.7,
      cuisineTypes: ['Mediterranean', 'Middle Eastern', 'Vegetarian'],
      minCapacity: 40,
      maxCapacity: 400,
      pricePerPerson: 75,
      imageUrl: 'assets/images/catering3.jpg',
    ),
    // Add more catering services as needed
  ];

  List<CateringService> get filteredServices {
    final serviceRecommendationProvider =
        Provider.of<ServiceRecommendationProvider>(context, listen: false);

    return _cateringServices.where((service) {
        final matchesSearch =
            service.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            service.description.toLowerCase().contains(
              _searchQuery.toLowerCase(),
            );

        final matchesCuisine =
            _selectedCuisineTypes.isEmpty ||
            service.cuisineTypes.any(
              (cuisine) => _selectedCuisineTypes.contains(cuisine),
            );

        final matchesPrice =
            service.pricePerPerson >= _priceRange.start &&
            service.pricePerPerson <= _priceRange.end;

        final matchesCapacity =
            service.maxCapacity >= _capacityRange.start &&
            service.minCapacity <= _capacityRange.end;

        final matchesRecommendation =
            !_showRecommendedOnly ||
            serviceRecommendationProvider.isCateringServiceRecommended(service);

        return matchesSearch &&
            matchesCuisine &&
            matchesPrice &&
            matchesCapacity &&
            matchesRecommendation;
      }).toList()
      ..sort((a, b) {
        switch (_selectedSortOption) {
          case 'Price (Low to High)':
            return a.pricePerPerson.compareTo(b.pricePerPerson);
          case 'Price (High to Low)':
            return b.pricePerPerson.compareTo(a.pricePerPerson);
          case 'Rating':
            return b.rating.compareTo(a.rating);
          case 'Capacity':
            return b.maxCapacity.compareTo(a.maxCapacity);
          default:
            return b.rating.compareTo(a.rating);
        }
      });
  }

  /// Reset all filters to their default values
  void _resetFilters() {
    setState(() {
      _searchQuery = '';
      _searchController.clear();
      _selectedCuisineTypes.clear();
      _priceRange = const RangeValues(50, 100);
      _capacityRange = const RangeValues(30, 500);
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
    } else if (filter.startsWith('Cuisine:')) {
      setState(() {
        _selectedCuisineTypes.clear();
      });
    } else if (filter.startsWith('Price:')) {
      setState(() {
        _priceRange = const RangeValues(50, 100);
      });
    } else if (filter.startsWith('Capacity:')) {
      setState(() {
        _capacityRange = const RangeValues(30, 500);
      });
    } else if (filter == 'Recommended Only') {
      setState(() {
        _showRecommendedOnly = false;
      });
    }
  }

  /// Show the comparison drawer
  void _showComparisonDrawer(
    BuildContext context,
    List<CateringService> services,
  ) {
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
                services: services,
                serviceType: 'Catering',
                onFullComparisonPressed: () {
                  Navigator.pop(context);
                  NavigationUtils.navigateToNamed(
                    context,
                    RouteNames.serviceComparison,
                    arguments: const ServiceComparisonArguments(
                      serviceType: 'Catering',
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
                  if (service is CateringService) {
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
    if (_selectedCuisineTypes.isNotEmpty) {
      activeFilters.add('Cuisine: ${_selectedCuisineTypes.length} selected');
    }
    if (_priceRange.start > 50 || _priceRange.end < 100) {
      activeFilters.add(
        'Price: ${NumberUtils.formatCurrency(_priceRange.start)} - ${NumberUtils.formatCurrency(_priceRange.end)}',
      );
    }
    if (_capacityRange.start > 30 || _capacityRange.end < 500) {
      activeFilters.add(
        'Capacity: ${_capacityRange.start.round()} - ${_capacityRange.end.round()} guests',
      );
    }
    if (_showRecommendedOnly) {
      activeFilters.add('Recommended Only');
    }

    // Get comparison count
    final int comparisonCount = comparisonProvider.getSelectedCount('Catering');
    final bool canCompare = comparisonCount >= 2;

    // Get selected services for comparison
    final List<CateringService> selectedServices =
        comparisonProvider.selectedCateringServices;

    return Scaffold(
      backgroundColor: Theme.of(context).canvasColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: const Text('Catering Services'),
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
                        _showComparisonDrawer(context, selectedServices);
                      }
                      : null,
              tooltip:
                  canCompare
                      ? 'Compare selected services'
                      : 'Select at least 2 services to compare',
            ),
        ],
      ),
      body: Column(
        children: [
          ServiceFilterBar(
            searchHint: 'Search catering services...',
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
                      _showComparisonDrawer(context, selectedServices);
                    }
                    : null,
            comparisonCount: comparisonCount,
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filteredServices.length,
              itemBuilder: (context, index) {
                final service = filteredServices[index];

                final isRecommended = serviceRecommendationProvider
                    .isCateringServiceRecommended(service);
                final recommendationReason =
                    isRecommended
                        ? serviceRecommendationProvider
                            .getCateringRecommendationReason(service)
                        : null;

                return ServiceCard(
                  name: service.name,
                  description: service.description,
                  rating: service.rating,
                  imageUrl: service.imageUrl,
                  isRecommended: isRecommended,
                  recommendationReason: recommendationReason,
                  isCompareSelected: comparisonProvider.isServiceSelected(
                    service,
                  ),
                  onCompareToggle: (_) {
                    comparisonProvider.toggleServiceSelection(service);
                  },
                  showCompareCheckbox: true,
                  // Enhanced features
                  price: service.pricePerPerson,
                  priceType: PriceType.perPerson,
                  tags: service.cuisineTypes,
                  minCapacity: service.minCapacity,
                  maxCapacity: service.maxCapacity,
                  isAvailable: true,
                  // Quick actions
                  onShare: () {
                    UIUtils.showSnackBar(
                      context,
                      'Share functionality coming soon!',
                    );
                  },
                  onSave: () {
                    UIUtils.showSnackBar(
                      context,
                      'Save functionality coming soon!',
                    );
                  },
                  onTap: () {
                    NavigationUtils.navigateToNamed(
                      context,
                      RouteNames.cateringDetails,
                      arguments: CateringDetailsArguments(
                        cateringId: service.name,
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: ComparisonFloatingButton(
        selectedCount: comparisonCount,
        minItemsForComparison: 2,
        onPressed: () {
          NavigationUtils.navigateToNamed(
            context,
            RouteNames.serviceComparison,
            arguments: const ServiceComparisonArguments(
              serviceType: 'Catering',
            ),
          );
        },
        visible: comparisonCount > 0,
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    // Create local variables to track changes within the dialog
    RangeValues localPriceRange = _priceRange;
    RangeValues localCapacityRange = _capacityRange;
    final List<String> localSelectedCuisineTypes = List.from(
      _selectedCuisineTypes,
    );
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
                    'International',
                    'Fine Dining',
                    'Mediterranean',
                    'Asian',
                    'Italian',
                    'BBQ',
                    'Vegetarian',
                  ],
                  selectedOptions: localSelectedCuisineTypes,
                  onOptionSelected: (option, selected) {
                    setDialogState(() {
                      if (selected) {
                        localSelectedCuisineTypes.add(option);
                      } else {
                        localSelectedCuisineTypes.remove(option);
                      }
                    });

                    setState(() {
                      _selectedCuisineTypes.clear();
                      _selectedCuisineTypes.addAll(localSelectedCuisineTypes);
                    });
                  },
                  filterTitle: 'Cuisine Types',
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
