import 'package:eventati_book/models/models.dart';
import 'package:flutter/material.dart';
import 'package:eventati_book/widgets/services/filter/service_filter_bar.dart';
import 'package:eventati_book/widgets/services/card/service_card.dart';
import 'package:eventati_book/widgets/services/filter/filter_dialog.dart';
import 'package:eventati_book/styles/app_colors.dart';
import 'package:eventati_book/styles/app_colors_dark.dart';
import 'package:eventati_book/utils/utils.dart';
import 'package:eventati_book/providers/providers.dart';
import 'package:provider/provider.dart';
import 'package:eventati_book/routing/routing.dart';

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

  @override
  Widget build(BuildContext context) {
    final comparisonProvider = Provider.of<ComparisonProvider>(context);
    final isDarkMode = UIUtils.isDarkMode(context);

    return Scaffold(
      backgroundColor: Theme.of(context).canvasColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: const Text('Catering Services'),
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
              itemCount: filteredServices.length,
              itemBuilder: (context, index) {
                final service = filteredServices[index];

                final serviceRecommendationProvider =
                    Provider.of<ServiceRecommendationProvider>(context);
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
                  onTap: () {
                    NavigationUtils.navigateToNamed(
                      context,
                      RouteNames.cateringDetails,
                      arguments: CateringDetailsArguments(
                        cateringId: service.name,
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
                            service.cuisineTypes
                                .map(
                                  (cuisine) => Chip(
                                    label: Text(cuisine),
                                    backgroundColor: Color.fromRGBO(
                                      AppColors.primary.r.toInt(),
                                      AppColors.primary.g.toInt(),
                                      AppColors.primary.b.toInt(),
                                      0.5,
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
                            'Capacity: ${NumberUtils.formatWithCommas(service.minCapacity)}-${NumberUtils.formatWithCommas(service.maxCapacity)} guests',
                          ),
                          Text(
                            '${NumberUtils.formatCurrency(service.pricePerPerson, decimalPlaces: 0)}/person',
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
          final int count = provider.getSelectedCount('Catering');

          // Only show FAB if at least 2 items are selected
          if (count >= 2) {
            return FloatingActionButton.extended(
              onPressed: () {
                NavigationUtils.navigateToNamed(
                  context,
                  RouteNames.serviceComparison,
                  arguments: const ServiceComparisonArguments(
                    serviceType: 'Catering',
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
