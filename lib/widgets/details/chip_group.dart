import 'package:flutter/material.dart';
import 'package:eventati_book/styles/app_colors.dart';

class ChipGroup extends StatelessWidget {
  final List<String> items;
  final double spacing;
  final double runSpacing;

  const ChipGroup({
    super.key,
    required this.items,
    this.spacing = 8,
    this.runSpacing = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: spacing,
      runSpacing: runSpacing,
      children: items
          .map((item) => Chip(
                label: Text(item),
                backgroundColor: AppColors.primaryWithOpacity(0.7),
              ))
          .toList(),
    );
  }
}
