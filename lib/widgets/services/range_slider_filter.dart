import 'package:flutter/material.dart';
import 'package:eventati_book/styles/app_colors.dart';

class RangeSliderFilter extends StatelessWidget {
  final String title;
  final RangeValues currentRange;
  final double min;
  final double max;
  final int divisions;
  final Function(RangeValues) onChanged;
  final String Function(double) labelBuilder;

  const RangeSliderFilter({
    super.key,
    required this.title,
    required this.currentRange,
    required this.min,
    required this.max,
    required this.divisions,
    required this.onChanged,
    required this.labelBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
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
          min: min,
          max: max,
          divisions: divisions,
          activeColor: AppColors.primary,
          inactiveColor: AppColors.primaryWithOpacity(0.2),
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
