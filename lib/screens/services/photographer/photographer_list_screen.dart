import 'package:flutter/material.dart';
import 'package:eventati_book/models/models.dart';
import 'package:eventati_book/utils/utils.dart';
import 'package:eventati_book/providers/providers.dart';
import 'package:provider/provider.dart';
import 'package:eventati_book/routing/routing.dart';
import 'package:eventati_book/widgets/widgets.dart';

class PhotographerListScreen extends StatefulWidget {
  const PhotographerListScreen({super.key});

  @override
  State<PhotographerListScreen> createState() => _PhotographerListScreenState();
}

class _PhotographerListScreenState extends State<PhotographerListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedSortOption = 'Rating';
  final List<String> _selectedStyles = [];
  RangeValues _priceRange = const RangeValues(500, 2000);
  RangeValues _experienceRange = const RangeValues(1, 10);
  bool _showRecommendedOnly = false;

  final List<Photographer> _photographers = [
    Photographer(
      name: 'David Wilson',
      description: 'Contemporary wedding and event photographer',
      rating: 4.8,
      styles: ['Contemporary', 'Photojournalistic', 'Fine Art'],
      pricePerEvent: 2500,
      imageUrl: 'assets/images/photographer1.jpg',
      equipment: ['Canon R5', 'Professional Lighting', '4K Video'],
      packages: ['Full Day Coverage', 'Engagement Session', 'Digital Gallery'],
    ),
    Photographer(
      name: 'Lisa Rodriguez',
      description: 'Creative portrait and event photography specialist',
      rating: 4.9,
      styles: ['Portrait', 'Artistic', 'Documentary'],
      pricePerEvent: 3000,
      imageUrl: 'assets/images/photographer2.jpg',
      equipment: ['Sony A7IV', 'Studio Lighting', 'Drone'],
      packages: ['8 Hour Coverage', 'Print Package', 'Online Gallery'],
    ),
    Photographer(
      name: 'James Chen',
      description: 'Traditional and modern wedding photographer',
      rating: 4.7,
      styles: ['Traditional', 'Modern', 'Cultural'],
      pricePerEvent: 2000,
      imageUrl: 'assets/images/photographer3.jpg',
      equipment: ['Nikon Z6', 'Flash System', 'Backup Gear'],
      packages: ['6 Hour Coverage', 'Digital Delivery', 'Album Design'],
    ),
  ];

  List<Photographer> get filteredPhotographers {
    final serviceRecommendationProvider =
        Provider.of<ServiceRecommendationProvider>(context, listen: false);

    return _photographers.where((photographer) {
        final matchesSearch =
            photographer.name.toLowerCase().contains(
              _searchQuery.toLowerCase(),
            ) ||
            photographer.description.toLowerCase().contains(
              _searchQuery.toLowerCase(),
            );

        final matchesStyle =
            _selectedStyles.isEmpty ||
            photographer.styles.any((style) => _selectedStyles.contains(style));

        final matchesPrice =
            photographer.pricePerEvent >= _priceRange.start &&
            photographer.pricePerEvent <= _priceRange.end;

        final matchesRecommendation =
            !_showRecommendedOnly ||
            serviceRecommendationProvider.isPhotographerRecommended(
              photographer,
            );

        return matchesSearch &&
            matchesStyle &&
            matchesPrice &&
            matchesRecommendation;
      }).toList()
      ..sort((a, b) {
        switch (_selectedSortOption) {
          case 'Price (Low to High)':
            return a.pricePerEvent.compareTo(b.pricePerEvent);
          case 'Price (High to Low)':
            return b.pricePerEvent.compareTo(a.pricePerEvent);
          case 'Rating':
            return b.rating.compareTo(a.rating);
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
      _selectedStyles.clear();
      _priceRange = const RangeValues(500, 2000);
      _experienceRange = const RangeValues(1, 10);
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
    } else if (filter.startsWith('Styles:')) {
      setState(() {
        _selectedStyles.clear();
      });
    } else if (filter.startsWith('Price:')) {
      setState(() {
        _priceRange = const RangeValues(500, 2000);
      });
    } else if (filter.startsWith('Experience:')) {
      setState(() {
        _experienceRange = const RangeValues(1, 10);
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
    List<Photographer> photographers,
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
                services: photographers,
                serviceType: 'Photographer',
                onFullComparisonPressed: () {
                  Navigator.pop(context);
                  NavigationUtils.navigateToNamed(
                    context,
                    RouteNames.serviceComparison,
                    arguments: const ServiceComparisonArguments(
                      serviceType: 'Photographer',
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
                  if (service is Photographer) {
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
    if (_selectedStyles.isNotEmpty) {
      activeFilters.add('Styles: ${_selectedStyles.length} selected');
    }
    if (_priceRange.start > 500 || _priceRange.end < 2000) {
      activeFilters.add(
        'Price: ${NumberUtils.formatCurrency(_priceRange.start)} - ${NumberUtils.formatCurrency(_priceRange.end)}',
      );
    }
    if (_experienceRange.start > 1 || _experienceRange.end < 10) {
      activeFilters.add(
        'Experience: ${_experienceRange.start.round()} - ${_experienceRange.end.round()} years',
      );
    }
    if (_showRecommendedOnly) {
      activeFilters.add('Recommended Only');
    }

    // Get comparison count
    final int comparisonCount = comparisonProvider.getSelectedCount(
      'Photographer',
    );
    final bool canCompare = comparisonCount >= 2;

    // Get selected photographers for comparison
    final List<Photographer> selectedPhotographers =
        comparisonProvider.selectedPhotographers;

    return Scaffold(
      backgroundColor: Theme.of(context).canvasColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: const Text('Photographers'),
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
                        _showComparisonDrawer(context, selectedPhotographers);
                      }
                      : null,
              tooltip:
                  canCompare
                      ? 'Compare selected photographers'
                      : 'Select at least 2 photographers to compare',
            ),
        ],
      ),
      body: Column(
        children: [
          ServiceFilterBar(
            searchHint: 'Search photographers...',
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
              'Experience',
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
                      _showComparisonDrawer(context, selectedPhotographers);
                    }
                    : null,
            comparisonCount: comparisonCount,
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filteredPhotographers.length,
              itemBuilder: (context, index) {
                final photographer = filteredPhotographers[index];

                final isRecommended = serviceRecommendationProvider
                    .isPhotographerRecommended(photographer);
                final recommendationReason =
                    isRecommended
                        ? serviceRecommendationProvider
                            .getPhotographerRecommendationReason(photographer)
                        : null;

                return ServiceCard(
                  name: photographer.name,
                  description: photographer.description,
                  rating: photographer.rating,
                  imageUrl: photographer.imageUrl,
                  isRecommended: isRecommended,
                  recommendationReason: recommendationReason,
                  isCompareSelected: comparisonProvider.isServiceSelected(
                    photographer,
                  ),
                  onCompareToggle: (_) {
                    comparisonProvider.toggleServiceSelection(photographer);
                  },
                  showCompareCheckbox: true,
                  // Enhanced features
                  price: photographer.pricePerEvent,
                  priceType: PriceType.perEvent,
                  tags: photographer.styles,
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
                      RouteNames.photographerDetails,
                      arguments: PhotographerDetailsArguments(
                        photographerId: photographer.name,
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
              serviceType: 'Photographer',
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
    RangeValues localExperienceRange = _experienceRange;
    final List<String> localSelectedStyles = List.from(_selectedStyles);
    bool localShowRecommendedOnly = _showRecommendedOnly;

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setDialogState) => AlertDialog(
                  title: const Text('Filter Options'),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        PriceRangeFilter(
                          title: 'Price Range',
                          currentRange: localPriceRange,
                          absoluteRange: const RangeValues(500, 5000),
                          onChanged: (values) {
                            // Update local state and dialog UI
                            setDialogState(() {
                              localPriceRange = values;
                            });
                            // Also update parent state for real-time filtering
                            setState(() {
                              _priceRange = values;
                            });
                          },
                          labelBuilder:
                              (value) => NumberUtils.formatCurrency(
                                value,
                                decimalPlaces: 0,
                              ),
                        ),
                        const SizedBox(height: 16),
                        PriceRangeFilter(
                          title: 'Experience Range (years)',
                          currentRange: localExperienceRange,
                          absoluteRange: const RangeValues(1, 20),
                          onChanged: (values) {
                            // Update local state and dialog UI
                            setDialogState(() {
                              localExperienceRange = values;
                            });
                            // Also update parent state for real-time filtering
                            setState(() {
                              _experienceRange = values;
                            });
                          },
                          labelBuilder: (value) => '${value.round()} years',
                        ),
                        const SizedBox(height: 16),
                        MultiSelectChipGroup(
                          title: 'Photography Styles',
                          options: const [
                            'Traditional',
                            'Photojournalistic',
                            'Fine Art',
                            'Editorial',
                            'Portrait',
                            'Artistic',
                            'Documentary',
                          ],
                          selectedOptions: localSelectedStyles,
                          onOptionSelected: (option, selected) {
                            setDialogState(() {
                              if (selected) {
                                localSelectedStyles.add(option);
                              } else {
                                localSelectedStyles.remove(option);
                              }
                            });

                            setState(() {
                              _selectedStyles.clear();
                              _selectedStyles.addAll(localSelectedStyles);
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        Consumer<ServiceRecommendationProvider>(
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
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('Apply & Close'),
                    ),
                  ],
                ),
          ),
    );
  }
}
