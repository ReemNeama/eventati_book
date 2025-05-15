import 'package:flutter/material.dart';
import 'package:eventati_book/models/models.dart';
import 'package:eventati_book/styles/app_colors.dart';
import 'package:eventati_book/styles/app_colors_dark.dart';
import 'package:eventati_book/utils/utils.dart';

/// A horizontal scrollable bar of category filter chips
class CategoryFilterBar extends StatelessWidget {
  /// The currently selected category
  final SuggestionCategory? selectedCategory;

  /// Callback when a category is selected
  final Function(SuggestionCategory?) onCategorySelected;

  /// Creates a new category filter bar
  const CategoryFilterBar({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = UIUtils.isDarkMode(context);
    final primaryColor = isDarkMode ? AppColorsDark.primary : AppColors.primary;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          // All categories chip
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: FilterChip(
              label: const Text('All'),
              selected: selectedCategory == null,
              selectedColor: primaryColor.withAlpha(51),
              checkmarkColor: primaryColor,
              onSelected: (selected) {
                if (selected) {
                  onCategorySelected(null);
                }
              },
            ),
          ),

          // Category-specific chips
          ...SuggestionCategory.values.map((category) {
            return Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: FilterChip(
                label: Text(category.label),
                selected: selectedCategory == category,
                avatar: Icon(category.icon, size: 16),
                selectedColor: primaryColor.withAlpha(51),
                checkmarkColor: primaryColor,
                onSelected: (selected) {
                  onCategorySelected(selected ? category : null);
                },
              ),
            );
          }),
        ],
      ),
    );
  }
}
