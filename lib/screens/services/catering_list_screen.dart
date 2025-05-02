import 'package:eventati_book/models/catering_service.dart';
import 'package:flutter/material.dart';
import 'package:eventati_book/widgets/services/service_filter_bar.dart';
import 'package:eventati_book/widgets/services/service_card.dart';
import 'package:eventati_book/widgets/services/filter_dialog.dart';
import 'package:eventati_book/styles/app_colors.dart';
import 'package:eventati_book/utils/utils.dart';
import 'package:eventati_book/screens/services/catering_details_screen.dart';

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

        return matchesSearch &&
            matchesCuisine &&
            matchesPrice &&
            matchesCapacity;
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
                return ServiceCard(
                  name: service.name,
                  description: service.description,
                  rating: service.rating,
                  imageUrl: service.imageUrl,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) =>
                                CateringDetailsScreen(cateringService: service),
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
                                    backgroundColor:
                                        AppColors.primaryWithOpacity(0.7),
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
    );
  }

  void _showFilterDialog(BuildContext context) {
    // Create local variables to track changes within the dialog
    RangeValues localPriceRange = _priceRange;
    RangeValues localCapacityRange = _capacityRange;
    final List<String> localSelectedCuisineTypes = List.from(
      _selectedCuisineTypes,
    );

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
