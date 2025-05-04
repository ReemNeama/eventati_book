import 'package:flutter/material.dart';
import 'package:eventati_book/models/models.dart';
import 'package:eventati_book/widgets/services/service_filter_bar.dart';
import 'package:eventati_book/widgets/services/service_card.dart';
import 'package:eventati_book/widgets/services/multi_select_chip_group.dart';
import 'package:eventati_book/styles/app_colors.dart';
import 'package:eventati_book/styles/app_colors_dark.dart';
import 'package:eventati_book/widgets/services/price_range_filter.dart';
import 'package:eventati_book/utils/utils.dart';
import 'package:eventati_book/screens/services/photographer_details_screen.dart';
import 'package:eventati_book/screens/services/service_comparison_screen.dart';
import 'package:eventati_book/providers/providers.dart';
import 'package:provider/provider.dart';

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

        return matchesSearch && matchesStyle && matchesPrice;
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

  @override
  Widget build(BuildContext context) {
    final comparisonProvider = Provider.of<ComparisonProvider>(context);
    final isDarkMode = UIUtils.isDarkMode(context);

    return Scaffold(
      backgroundColor: Theme.of(context).canvasColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: const Text('Photographers'),
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
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filteredPhotographers.length,
              itemBuilder: (context, index) {
                final photographer = filteredPhotographers[index];
                return ServiceCard(
                  name: photographer.name,
                  description: photographer.description,
                  rating: photographer.rating,
                  imageUrl: photographer.imageUrl,
                  isCompareSelected: comparisonProvider.isServiceSelected(
                    photographer,
                  ),
                  onCompareToggle: (_) {
                    comparisonProvider.toggleServiceSelection(photographer);
                  },
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => PhotographerDetailsScreen(
                              photographer: photographer,
                            ),
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
                            photographer.styles
                                .map(
                                  (style) => Chip(
                                    label: Text(style),
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
                            'Experience: ${photographer.equipment.length} years',
                          ),
                          Text(
                            '${NumberUtils.formatCurrency(photographer.pricePerEvent, decimalPlaces: 0)}/event',
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
          final int count = provider.getSelectedCount('Photographer');

          // Only show FAB if at least 2 items are selected
          if (count >= 2) {
            return FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => const ServiceComparisonScreen(
                          serviceType: 'Photographer',
                        ),
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
    RangeValues localExperienceRange = _experienceRange;
    final List<String> localSelectedStyles = List.from(_selectedStyles);

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
