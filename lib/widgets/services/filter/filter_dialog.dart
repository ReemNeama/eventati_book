import 'package:flutter/material.dart';
import 'package:eventati_book/widgets/services/filter/price_range_filter.dart';
import 'package:eventati_book/styles/app_colors_dark.dart';
import 'package:eventati_book/utils/utils.dart';

/// A preset filter configuration that can be saved and applied
class FilterPreset {
  /// Name of the preset
  final String name;

  /// Price range values
  final RangeValues priceRange;

  /// Capacity range values
  final RangeValues capacityRange;

  /// Selected filter options
  final List<String> selectedOptions;

  /// Whether to show recommended only
  final bool showRecommendedOnly;

  /// Additional filter parameters
  final Map<String, dynamic> additionalParams;

  /// Constructor
  const FilterPreset({
    required this.name,
    required this.priceRange,
    required this.capacityRange,
    required this.selectedOptions,
    this.showRecommendedOnly = false,
    this.additionalParams = const {},
  });
}

/// A dialog for filtering services with various options
class FilterDialog extends StatefulWidget {
  /// Current price range
  final RangeValues priceRange;

  /// Callback when price range changes
  final Function(RangeValues) onPriceRangeChanged;

  /// Current capacity range
  final RangeValues capacityRange;

  /// Callback when capacity range changes
  final Function(RangeValues) onCapacityRangeChanged;

  /// Available filter options
  final List<String> filterOptions;

  /// Currently selected options
  final List<String> selectedOptions;

  /// Callback when an option is selected or deselected
  final Function(String, bool) onOptionSelected;

  /// Title for the filter options section
  final String filterTitle;

  /// Extra filter widget to display
  final Widget? extraFilterWidget;

  /// Whether to show recommended only
  final bool showRecommendedOnly;

  /// Callback when show recommended only changes
  final Function(bool)? onShowRecommendedOnlyChanged;

  /// Available filter presets
  final List<FilterPreset> presets;

  /// Callback when a preset is applied
  final Function(FilterPreset)? onPresetApplied;

  /// Callback when a preset is saved
  final Function(String)? onPresetSaved;

  /// Callback when all filters are reset
  final VoidCallback? onResetFilters;

  /// Absolute range for price (min and max possible values)
  final RangeValues absolutePriceRange;

  /// Absolute range for capacity (min and max possible values)
  final RangeValues absoluteCapacityRange;

  /// Price label format (e.g., "per person" or "per event")
  final String priceLabelFormat;

  /// Constructor
  const FilterDialog({
    super.key,
    required this.priceRange,
    required this.onPriceRangeChanged,
    required this.capacityRange,
    required this.onCapacityRangeChanged,
    required this.filterOptions,
    required this.selectedOptions,
    required this.onOptionSelected,
    required this.filterTitle,
    this.extraFilterWidget,
    this.showRecommendedOnly = false,
    this.onShowRecommendedOnlyChanged,
    this.presets = const [],
    this.onPresetApplied,
    this.onPresetSaved,
    this.onResetFilters,
    this.absolutePriceRange = const RangeValues(30, 150),
    this.absoluteCapacityRange = const RangeValues(10, 1000),
    this.priceLabelFormat = 'per person',
  });

  @override
  State<FilterDialog> createState() => _FilterDialogState();
}

class _FilterDialogState extends State<FilterDialog> {
  // Local state for the dialog
  late RangeValues _currentPriceRange;
  late RangeValues _currentCapacityRange;
  late List<String> _currentSelectedOptions;
  late bool _currentShowRecommendedOnly;
  String _presetName = '';
  bool _showSavePresetField = false;

  @override
  void initState() {
    super.initState();
    // Initialize local state from widget properties
    _currentPriceRange = widget.priceRange;
    _currentCapacityRange = widget.capacityRange;
    _currentSelectedOptions = List.from(widget.selectedOptions);
    _currentShowRecommendedOnly = widget.showRecommendedOnly;
  }

  // Apply a preset
  void _applyPreset(FilterPreset preset) {
    setState(() {
      _currentPriceRange = preset.priceRange;
      _currentCapacityRange = preset.capacityRange;
      _currentSelectedOptions = List.from(preset.selectedOptions);
      _currentShowRecommendedOnly = preset.showRecommendedOnly;
    });

    // Notify parent
    widget.onPriceRangeChanged(_currentPriceRange);
    widget.onCapacityRangeChanged(_currentCapacityRange);

    // Update selected options
    final Set<String> oldSelected = Set.from(widget.selectedOptions);
    final Set<String> newSelected = Set.from(_currentSelectedOptions);

    // Handle deselected options
    for (final option in oldSelected) {
      if (!newSelected.contains(option)) {
        widget.onOptionSelected(option, false);
      }
    }

    // Handle newly selected options
    for (final option in newSelected) {
      if (!oldSelected.contains(option)) {
        widget.onOptionSelected(option, true);
      }
    }

    // Update recommended only
    if (widget.onShowRecommendedOnlyChanged != null &&
        _currentShowRecommendedOnly != widget.showRecommendedOnly) {
      widget.onShowRecommendedOnlyChanged!(_currentShowRecommendedOnly);
    }

    // Notify preset applied
    if (widget.onPresetApplied != null) {
      widget.onPresetApplied!(preset);
    }
  }

  // Reset all filters
  void _resetFilters() {
    setState(() {
      _currentPriceRange = widget.absolutePriceRange;
      _currentCapacityRange = widget.absoluteCapacityRange;
      _currentSelectedOptions = [];
      _currentShowRecommendedOnly = false;
    });

    // Notify parent
    widget.onPriceRangeChanged(_currentPriceRange);
    widget.onCapacityRangeChanged(_currentCapacityRange);

    // Deselect all options
    for (final option in widget.selectedOptions) {
      widget.onOptionSelected(option, false);
    }

    // Update recommended only
    if (widget.onShowRecommendedOnlyChanged != null &&
        widget.showRecommendedOnly) {
      widget.onShowRecommendedOnlyChanged!(false);
    }

    // Notify reset
    if (widget.onResetFilters != null) {
      widget.onResetFilters!();
    }
  }

  // Save current filters as a preset
  void _savePreset() {
    if (_presetName.isEmpty) return;

    if (widget.onPresetSaved != null) {
      widget.onPresetSaved!(_presetName);
    }

    setState(() {
      _showSavePresetField = false;
      _presetName = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = UIUtils.isDarkMode(context);
    final Color primaryColor = Theme.of(context).primaryColor;
    final Color chipBgColor =
        isDarkMode ? AppColorsDark.chipBackground : Colors.white;

    return AlertDialog(
      title: const Text('Filter Options'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Presets section (if available)
            if (widget.presets.isNotEmpty) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Presets',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _showSavePresetField = !_showSavePresetField;
                      });
                    },
                    child: Text(
                      _showSavePresetField ? 'Cancel' : 'Save Current',
                    ),
                  ),
                ],
              ),

              // Save preset field
              if (_showSavePresetField) ...[
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: const InputDecoration(
                          hintText: 'Preset name',
                          isDense: true,
                        ),
                        onChanged: (value) {
                          setState(() {
                            _presetName = value;
                          });
                        },
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.save),
                      onPressed: _presetName.isNotEmpty ? _savePreset : null,
                      tooltip: 'Save preset',
                    ),
                  ],
                ),
              ],

              // Preset chips
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children:
                    widget.presets.map((preset) {
                      return ActionChip(
                        label: Text(preset.name),
                        onPressed: () => _applyPreset(preset),
                        backgroundColor: Color.fromRGBO(
                          primaryColor.r.toInt(),
                          primaryColor.g.toInt(),
                          primaryColor.b.toInt(),
                          0.1,
                        ),
                      );
                    }).toList(),
              ),
              const Divider(),
            ],

            // Price range filter
            PriceRangeFilter(
              title: 'Price Range (${widget.priceLabelFormat})',
              currentRange: _currentPriceRange,
              absoluteRange: widget.absolutePriceRange,
              onChanged: (values) {
                setState(() {
                  _currentPriceRange = values;
                });
                widget.onPriceRangeChanged(values);
              },
              labelBuilder:
                  (value) =>
                      NumberUtils.formatCurrency(value, decimalPlaces: 0),
            ),

            const SizedBox(height: 16),

            // Capacity range filter
            PriceRangeFilter(
              title: 'Capacity Range',
              currentRange: _currentCapacityRange,
              absoluteRange: widget.absoluteCapacityRange,
              onChanged: (values) {
                setState(() {
                  _currentCapacityRange = values;
                });
                widget.onCapacityRangeChanged(values);
              },
              labelBuilder:
                  (value) =>
                      '${NumberUtils.formatWithCommas(value.round())} guests',
            ),

            const SizedBox(height: 16),

            // Recommended only checkbox
            if (widget.onShowRecommendedOnlyChanged != null) ...[
              Row(
                children: [
                  Checkbox(
                    value: _currentShowRecommendedOnly,
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _currentShowRecommendedOnly = value;
                        });
                        widget.onShowRecommendedOnlyChanged!(value);
                      }
                    },
                  ),
                  const Text('Show recommended only'),
                ],
              ),
              const SizedBox(height: 16),
            ],

            // Filter options
            Text(
              widget.filterTitle,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  widget.filterOptions.map((option) {
                    final isSelected = _currentSelectedOptions.contains(option);

                    return FilterChip(
                      label: Text(
                        option,
                        style: TextStyle(
                          color: isSelected ? Colors.white : primaryColor,
                        ),
                      ),
                      selected: isSelected,
                      selectedColor: primaryColor,
                      backgroundColor: chipBgColor,
                      checkmarkColor: Colors.white,
                      side: BorderSide(color: primaryColor),
                      onSelected: (bool selected) {
                        setState(() {
                          if (selected) {
                            _currentSelectedOptions.add(option);
                          } else {
                            _currentSelectedOptions.remove(option);
                          }
                        });
                        widget.onOptionSelected(option, selected);
                      },
                    );
                  }).toList(),
            ),

            // Extra filter widget
            if (widget.extraFilterWidget != null) ...[
              const SizedBox(height: 16),
              widget.extraFilterWidget!,
            ],
          ],
        ),
      ),
      actions: [
        // Reset button
        if (widget.onResetFilters != null)
          TextButton(onPressed: _resetFilters, child: const Text('Reset All')),

        // Apply button
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Apply & Close'),
        ),
      ],
    );
  }
}
