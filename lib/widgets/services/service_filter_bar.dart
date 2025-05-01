import 'package:flutter/material.dart';
import 'package:eventati_book/styles/app_colors.dart';
import 'package:eventati_book/styles/app_colors_dark.dart';
import 'package:eventati_book/utils/utils.dart';

class ServiceFilterBar extends StatelessWidget {
  final String searchHint;
  final TextEditingController searchController;
  final Function(String) onSearchChanged;
  final String selectedSortOption;
  final List<String> sortOptions;
  final Function(String?) onSortChanged;
  final VoidCallback onFilterTap;

  const ServiceFilterBar({
    super.key,
    required this.searchHint,
    required this.searchController,
    required this.onSearchChanged,
    required this.selectedSortOption,
    required this.sortOptions,
    required this.onSortChanged,
    required this.onFilterTap,
  });

  @override
  Widget build(BuildContext context) {
    // Use different colors based on the current theme
    final bool isDarkMode = UIUtils.isDarkMode(context);
    final Color filterBarBg =
        isDarkMode
            ? AppColorsDark.filterBarBackground
            : AppColors.filterBarBackground;
    final Color searchBarBg =
        isDarkMode ? AppColorsDark.searchBarBackground : Colors.white;
    final Color sortFilterBg =
        isDarkMode ? AppColorsDark.sortFilterBackground : Colors.white;
    final Color borderColor =
        isDarkMode ? AppColorsDark.divider : AppColors.divider;

    return Container(
      padding: const EdgeInsets.all(12.0),
      color: filterBarBg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search field
          TextField(
            controller: searchController,
            onChanged: onSearchChanged,
            decoration: InputDecoration(
              hintText: searchHint,
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                  AppConstants.mediumBorderRadius,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 8.0),
              filled: true,
              fillColor: searchBarBg,
            ),
          ),

          const SizedBox(height: 12),

          // Sort and Filter options
          Row(
            children: [
              // Sort dropdown
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: sortFilterBg,
                    borderRadius: BorderRadius.circular(
                      AppConstants.mediumBorderRadius,
                    ),
                    border: Border.all(color: borderColor),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.sort,
                        size: 20,
                        color:
                            isDarkMode
                                ? AppColorsDark.textSecondary
                                : Colors.black87,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Sort by: ',
                        style: TextStyle(
                          color:
                              isDarkMode
                                  ? AppColorsDark.textSecondary
                                  : Colors.black87,
                        ),
                      ),
                      Expanded(
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: selectedSortOption,
                            isDense: true,
                            isExpanded: true,
                            items:
                                sortOptions.map((option) {
                                  return DropdownMenuItem<String>(
                                    value: option,
                                    child: Text(option),
                                  );
                                }).toList(),
                            onChanged: onSortChanged,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // Filter button
              InkWell(
                onTap: onFilterTap,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: sortFilterBg,
                    borderRadius: BorderRadius.circular(
                      AppConstants.mediumBorderRadius,
                    ),
                    border: Border.all(color: borderColor),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.filter_list,
                        color:
                            isDarkMode
                                ? AppColorsDark.primary
                                : AppColors.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Filter',
                        style: TextStyle(
                          color:
                              isDarkMode
                                  ? AppColorsDark.primary
                                  : AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
