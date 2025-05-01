import 'package:eventati_book/models/venue.dart';
import 'package:flutter/material.dart';
import 'package:eventati_book/widgets/services/service_filter_bar.dart';
import 'package:eventati_book/widgets/services/service_card.dart';
import 'package:eventati_book/widgets/services/filter_dialog.dart';
import 'package:eventati_book/styles/app_colors.dart';
import 'package:eventati_book/utils/utils.dart';

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
    return _venues.where((venue) {
        final matchesSearch =
            venue.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            venue.description.toLowerCase().contains(
              _searchQuery.toLowerCase(),
            );

        final matchesType =
            _selectedVenueTypes.isEmpty ||
            venue.venueTypes.any((type) => _selectedVenueTypes.contains(type));

        final matchesPrice =
            venue.pricePerEvent >= _priceRange.start &&
            venue.pricePerEvent <= _priceRange.end;

        final matchesCapacity =
            venue.maxCapacity >= _capacityRange.start &&
            venue.minCapacity <= _capacityRange.end;

        return matchesSearch && matchesType && matchesPrice && matchesCapacity;
      }).toList()
      ..sort((a, b) {
        switch (_selectedSortOption) {
          case 'Price (Low to High)':
            return a.pricePerEvent.compareTo(b.pricePerEvent);
          case 'Price (High to Low)':
            return b.pricePerEvent.compareTo(a.pricePerEvent);
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
                return ServiceCard(
                  name: venue.name,
                  description: venue.description,
                  rating: venue.rating,
                  imageUrl: venue.imageUrl,
                  onTap: () {
                    // Handle tap
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
    );
  }

  void _showFilterDialog(BuildContext context) {
    // Create local variables to track changes within the dialog
    RangeValues localPriceRange = _priceRange;
    RangeValues localCapacityRange = _capacityRange;
    List<String> localSelectedVenueTypes = List.from(_selectedVenueTypes);

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
