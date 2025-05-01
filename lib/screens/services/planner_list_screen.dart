import 'package:eventati_book/models/planner.dart';
import 'package:flutter/material.dart';
import 'package:eventati_book/widgets/services/service_filter_bar.dart';
import 'package:eventati_book/widgets/services/service_card.dart';
import 'package:eventati_book/widgets/services/filter_dialog.dart';
import 'package:eventati_book/styles/app_colors.dart';
import 'package:eventati_book/utils/utils.dart';

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

        return matchesSearch &&
            matchesSpecialty &&
            matchesPrice &&
            matchesExperience;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).canvasColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: const Text('Event Planners'),
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
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filteredPlanners.length,
              itemBuilder: (context, index) {
                final planner = filteredPlanners[index];
                return ServiceCard(
                  name: planner.name,
                  description: planner.description,
                  rating: planner.rating,
                  imageUrl: planner.imageUrl,
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
                            planner.specialties
                                .map(
                                  (specialty) => Chip(
                                    label: Text(specialty),
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
                          Text('Experience: ${planner.yearsExperience} years'),
                          Text(
                            '${NumberUtils.formatCurrency(planner.pricePerEvent, decimalPlaces: 0)} base fee',
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
    RangeValues localExperienceRange = _experienceRange;
    List<String> localSelectedSpecialties = List.from(_selectedSpecialties);

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
