import 'package:flutter/material.dart';
import 'package:eventati_book/widgets/services/price_range_filter.dart';
import 'package:eventati_book/styles/app_colors_dark.dart';
import 'package:eventati_book/utils/utils.dart';

class FilterDialog extends StatelessWidget {
  final RangeValues priceRange;
  final Function(RangeValues) onPriceRangeChanged;
  final RangeValues capacityRange;
  final Function(RangeValues) onCapacityRangeChanged;
  final List<String> filterOptions;
  final List<String> selectedOptions;
  final Function(String, bool) onOptionSelected;
  final String filterTitle;
  final Widget? extraFilterWidget;

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
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Filter Options'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PriceRangeFilter(
              title: 'Price Range (per person)',
              currentRange: priceRange,
              absoluteRange: const RangeValues(30, 150),
              onChanged: (values) {
                // Make sure to call the callback with the new values
                onPriceRangeChanged(values);
              },
              labelBuilder:
                  (value) =>
                      NumberUtils.formatCurrency(value, decimalPlaces: 0),
            ),
            const SizedBox(height: 16),
            PriceRangeFilter(
              title: 'Capacity Range',
              currentRange: capacityRange,
              absoluteRange: const RangeValues(10, 1000),
              onChanged: (values) {
                // Make sure to call the callback with the new values
                onCapacityRangeChanged(values);
              },
              labelBuilder:
                  (value) =>
                      '${NumberUtils.formatWithCommas(value.round())} guests',
            ),
            const SizedBox(height: 16),
            Text(filterTitle),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  filterOptions.map((option) {
                    final isSelected = selectedOptions.contains(option);
                    return FilterChip(
                      label: Text(
                        option,
                        style: TextStyle(
                          color:
                              isSelected
                                  ? Colors.white
                                  : Theme.of(context).primaryColor,
                        ),
                      ),
                      selected: isSelected,
                      selectedColor: Theme.of(context).primaryColor,
                      backgroundColor:
                          UIUtils.isDarkMode(context)
                              ? AppColorsDark.chipBackground
                              : Colors.white,
                      checkmarkColor: Colors.white,
                      side: BorderSide(color: Theme.of(context).primaryColor),
                      onSelected: (bool selected) {
                        onOptionSelected(option, selected);
                      },
                    );
                  }).toList(),
            ),
            if (extraFilterWidget != null) ...[
              const SizedBox(height: 16),
              extraFilterWidget!,
            ],
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
    );
  }
}
