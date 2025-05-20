import 'package:flutter/material.dart';
import 'package:eventati_book/models/models.dart';
import 'package:eventati_book/utils/utils.dart';
import 'package:eventati_book/providers/providers.dart';
import 'package:provider/provider.dart';
import 'package:eventati_book/routing/routing.dart';
import 'package:eventati_book/widgets/widgets.dart';

class PlannerListScreen extends StatefulWidget {
  const PlannerListScreen({super.key});

  @override
  State<PlannerListScreen> createState() => _PlannerListScreenState();
}

class _PlannerListScreenState extends State<PlannerListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedSortOption = 'Rating';
  final List<String> _selectedSpecialties = [];
  RangeValues _priceRange = const RangeValues(1000, 5000);
  RangeValues _experienceRange = const RangeValues(2, 10);
  bool _showRecommendedOnly = false;

  final List<Planner> _planners = [
    Planner(
      name: 'Sarah Johnson',
      description: 'Luxury wedding and event planning specialist',
      rating: 4.9,
      specialties: ['Weddings', 'Corporate Events', 'Luxury Events'],
      yearsExperience: 15,
      pricePerEvent: 3000,
      imageUrl: 'assets/images/planner1.jpg',
      services: [
        'Full Planning',
        'Day-of Coordination',
        'Vendor Management',
        'Design Services',
      ],
    ),
    Planner(
      name: 'Michael Chen',
      description: 'Creative event planner with modern design approach',
      rating: 4.7,
      specialties: ['Modern Events', 'Cultural Celebrations', 'Social Events'],
      yearsExperience: 8,
      pricePerEvent: 2000,
      imageUrl: 'assets/images/planner2.jpg',
      services: [
        'Partial Planning',
        'Design Consultation',
        'Timeline Creation',
      ],
    ),
    Planner(
      name: 'Emma Thompson',
      description: 'Destination wedding and luxury event specialist',
      rating: 4.8,
      specialties: ['Destination Weddings', 'Beach Events', 'Luxury Weddings'],
      yearsExperience: 12,
      pricePerEvent: 4000,
      imageUrl: 'assets/images/planner3.jpg',
      services: [
        'Full Planning',
        'Destination Management',
        'Travel Arrangements',
      ],
    ),
  ];

  List<Planner> get filteredPlanners {
    final serviceRecommendationProvider =
        Provider.of<ServiceRecommendationProvider>(context, listen: false);

    return _planners.where((planner) {
        final matchesSearch =
            planner.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            planner.description.toLowerCase().contains(
              _searchQuery.toLowerCase(),
            );

        final matchesSpecialty =
            _selectedSpecialties.isEmpty ||
            planner.specialties.any(
              (type) => _selectedSpecialties.contains(type),
            );

        final matchesPrice =
            planner.pricePerEvent >= _priceRange.start &&
            planner.pricePerEvent <= _priceRange.end;

        final matchesExperience =
            planner.yearsExperience >= _experienceRange.start &&
            planner.yearsExperience <= _experienceRange.end;

        final matchesRecommendation =
            !_showRecommendedOnly ||
            serviceRecommendationProvider.isPlannerRecommended(planner);

        return matchesSearch &&
            matchesSpecialty &&
            matchesPrice &&
            matchesExperience &&
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
          case 'Experience':
            return b.yearsExperience.compareTo(a.yearsExperience);
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
      _selectedSpecialties.clear();
      _priceRange = const RangeValues(1000, 5000);
      _experienceRange = const RangeValues(2, 10);
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
    } else if (filter.startsWith('Specialties:')) {
      setState(() {
        _selectedSpecialties.clear();
      });
    } else if (filter.startsWith('Price:')) {
      setState(() {
        _priceRange = const RangeValues(1000, 5000);
      });
    } else if (filter.startsWith('Experience:')) {
      setState(() {
        _experienceRange = const RangeValues(2, 10);
      });
    } else if (filter == 'Recommended Only') {
      setState(() {
        _showRecommendedOnly = false;
      });
    }
  }

  /// Show the comparison drawer
  void _showComparisonDrawer(BuildContext context, List<Planner> planners) {
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
                services: planners,
                serviceType: 'Planner',
                onFullComparisonPressed: () {
                  Navigator.pop(context);
                  NavigationUtils.navigateToNamed(
                    context,
                    RouteNames.serviceComparison,
                    arguments: const ServiceComparisonArguments(
                      serviceType: 'Planner',
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
                  if (service is Planner) {
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
    if (_selectedSpecialties.isNotEmpty) {
      activeFilters.add('Specialties: ${_selectedSpecialties.length} selected');
    }
    if (_priceRange.start > 1000 || _priceRange.end < 5000) {
      activeFilters.add(
        'Price: ${NumberUtils.formatCurrency(_priceRange.start)} - ${NumberUtils.formatCurrency(_priceRange.end)}',
      );
    }
    if (_experienceRange.start > 2 || _experienceRange.end < 10) {
      activeFilters.add(
        'Experience: ${_experienceRange.start.round()} - ${_experienceRange.end.round()} years',
      );
    }
    if (_showRecommendedOnly) {
      activeFilters.add('Recommended Only');
    }

    // Get comparison count
    final int comparisonCount = comparisonProvider.getSelectedCount('Planner');
    final bool canCompare = comparisonCount >= 2;

    // Get selected planners for comparison
    final List<Planner> selectedPlanners = comparisonProvider.selectedPlanners;

    return Scaffold(
      backgroundColor: Theme.of(context).canvasColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: const Text('Event Planners'),
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
                        _showComparisonDrawer(context, selectedPlanners);
                      }
                      : null,
              tooltip:
                  canCompare
                      ? 'Compare selected planners'
                      : 'Select at least 2 planners to compare',
            ),
        ],
      ),
      body: Column(
        children: [
          ServiceFilterBar(
            searchHint: 'Search event planners...',
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
                      _showComparisonDrawer(context, selectedPlanners);
                    }
                    : null,
            comparisonCount: comparisonCount,
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filteredPlanners.length,
              itemBuilder: (context, index) {
                final planner = filteredPlanners[index];

                final isRecommended = serviceRecommendationProvider
                    .isPlannerRecommended(planner);
                final recommendationReason =
                    isRecommended
                        ? serviceRecommendationProvider
                            .getPlannerRecommendationReason(planner)
                        : null;

                return ServiceCard(
                  name: planner.name,
                  description: planner.description,
                  rating: planner.rating,
                  imageUrl: planner.imageUrl,
                  isRecommended: isRecommended,
                  recommendationReason: recommendationReason,
                  isCompareSelected: comparisonProvider.isServiceSelected(
                    planner,
                  ),
                  onCompareToggle: (_) {
                    comparisonProvider.toggleServiceSelection(planner);
                  },
                  showCompareCheckbox: true,
                  // Enhanced features
                  price: planner.pricePerEvent,
                  priceType: PriceType.perEvent,
                  tags: planner.specialties,
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
                      RouteNames.plannerDetails,
                      arguments: PlannerDetailsArguments(
                        plannerId: planner.name,
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
            arguments: const ServiceComparisonArguments(serviceType: 'Planner'),
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
    final List<String> localSelectedSpecialties = List.from(
      _selectedSpecialties,
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
                  capacityRange: localExperienceRange,
                  onCapacityRangeChanged: (values) {
                    // Update local state and dialog UI
                    setDialogState(() {
                      localExperienceRange = values;
                    });
                    // Also update parent state for real-time filtering
                    setState(() {
                      _experienceRange = values;
                    });
                  },
                  filterOptions: const [
                    'Weddings',
                    'Corporate',
                    'Social Events',
                    'Birthdays',
                    'Anniversaries',
                    'Galas',
                    'Conferences',
                  ],
                  selectedOptions: localSelectedSpecialties,
                  onOptionSelected: (option, selected) {
                    setDialogState(() {
                      if (selected) {
                        localSelectedSpecialties.add(option);
                      } else {
                        localSelectedSpecialties.remove(option);
                      }
                    });

                    setState(() {
                      _selectedSpecialties.clear();
                      _selectedSpecialties.addAll(localSelectedSpecialties);
                    });
                  },
                  filterTitle: 'Specialties',
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
