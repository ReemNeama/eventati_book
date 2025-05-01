import 'package:flutter/material.dart';
import 'package:eventati_book/styles/app_colors.dart';
import 'package:eventati_book/styles/app_colors_dark.dart';
import 'package:eventati_book/utils/utils.dart';

class PriceRangeFilter extends StatelessWidget {
  final String title;
  final RangeValues currentRange;
  final RangeValues absoluteRange;
  final Function(RangeValues) onChanged;
  final String Function(double) labelBuilder;

  const PriceRangeFilter({
    super.key,
    required this.title,
    required this.currentRange,
    required this.absoluteRange,
    required this.onChanged,
    required this.labelBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(labelBuilder(currentRange.start)),
              Text(labelBuilder(currentRange.end)),
            ],
          ),
        ),
        RangeSlider(
          values: currentRange,
          min: absoluteRange.start,
          max: absoluteRange.end,
          divisions: (absoluteRange.end - absoluteRange.start).round(),
          activeColor: Theme.of(context).primaryColor,
          inactiveColor:
              UIUtils.isDarkMode(context)
                  ? AppColorsDark.primaryWithOpacity(0.2)
                  : AppColors.primaryWithOpacity(0.2),
          labels: RangeLabels(
            labelBuilder(currentRange.start),
            labelBuilder(currentRange.end),
          ),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
