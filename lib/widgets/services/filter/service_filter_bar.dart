import 'package:flutter/material.dart';
import 'package:eventati_book/styles/app_colors.dart';
import 'package:eventati_book/styles/app_colors_dark.dart';
import 'package:eventati_book/styles/text_styles.dart';
import 'package:eventati_book/utils/utils.dart';

/// A widget that provides search, sort, and filter functionality for service lists
class ServiceFilterBar extends StatelessWidget {
  /// Hint text for the search field
  final String searchHint;

  /// Controller for the search field
  final TextEditingController searchController;

  /// Callback when search text changes
  final Function(String) onSearchChanged;

  /// Currently selected sort option
  final String selectedSortOption;

  /// Available sort options
  final List<String> sortOptions;

  /// Callback when sort option changes
  final Function(String?) onSortChanged;

  /// Callback when filter button is tapped
  final VoidCallback onFilterTap;

  /// Active filter tags to display
  final List<String> activeFilters;

  /// Callback when a filter tag is removed
  final Function(String)? onFilterRemoved;

  /// Callback when all filters are cleared
  final VoidCallback? onClearAllFilters;

  /// Whether to show the active filters section
  final bool showActiveFilters;

  /// Whether to show the comparison button
  final bool showComparisonButton;

  /// Whether comparison mode is active
  final bool isComparisonActive;

  /// Callback when comparison button is tapped
  final VoidCallback? onComparisonTap;

  /// Number of items selected for comparison
  final int comparisonCount;

  /// Constructor
  const ServiceFilterBar({
    super.key,
    required this.searchHint,
    required this.searchController,
    required this.onSearchChanged,
    required this.selectedSortOption,
    required this.sortOptions,
    required this.onSortChanged,
    required this.onFilterTap,
    this.activeFilters = const [],
    this.onFilterRemoved,
    this.onClearAllFilters,
    this.showActiveFilters = true,
    this.showComparisonButton = false,
    this.isComparisonActive = false,
    this.onComparisonTap,
    this.comparisonCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    // Use different colors based on the current theme
    final bool isDarkMode = UIUtils.isDarkMode(context);
    final Color primaryColor =
        isDarkMode ? AppColorsDark.primary : AppColors.primary;
    final Color filterBarBg =
        isDarkMode
            ? AppColorsDark.filterBarBackground
            : AppColors.filterBarBackground;
    final Color searchBarBg =
        isDarkMode ? AppColorsDark.searchBarBackground : AppColors.white;
    final Color sortFilterBg =
        isDarkMode ? AppColorsDark.sortFilterBackground : AppColors.white;
    final Color borderColor =
        isDarkMode ? AppColorsDark.divider : AppColors.divider;
    final Color chipBgColor = Color.fromRGBO(
      primaryColor.r.toInt(),
      primaryColor.g.toInt(),
      primaryColor.b.toInt(),
      0.1,
    );

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

          // Sort, Filter, and Compare options
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
                                : AppColors.textPrimary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Sort by: ',
                        style: TextStyles.bodyMedium.copyWith(
                          color:
                              isDarkMode
                                  ? AppColorsDark.textSecondary
                                  : AppColors.textPrimary,
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
                    border: Border.all(
                      color:
                          activeFilters.isNotEmpty ? primaryColor : borderColor,
                      width: activeFilters.isNotEmpty ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.filter_list, color: primaryColor, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        activeFilters.isNotEmpty
                            ? 'Filters (${activeFilters.length})'
                            : 'Filter',
                        style: TextStyles.buttonText.copyWith(
                          color: primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Compare button (if enabled)
              if (showComparisonButton) ...[
                const SizedBox(width: 12),
                InkWell(
                  onTap: comparisonCount >= 2 ? onComparisonTap : null,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color:
                          isComparisonActive
                              ? Color.fromRGBO(
                                primaryColor.r.toInt(),
                                primaryColor.g.toInt(),
                                primaryColor.b.toInt(),
                                0.2,
                              )
                              : sortFilterBg,
                      borderRadius: BorderRadius.circular(
                        AppConstants.mediumBorderRadius,
                      ),
                      border: Border.all(
                        color: isComparisonActive ? primaryColor : borderColor,
                        width: isComparisonActive ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.compare_arrows,
                          color:
                              comparisonCount >= 2
                                  ? primaryColor
                                  : isDarkMode
                                  ? AppColorsDark.disabled
                                  : AppColors.disabled,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Compare ($comparisonCount)',
                          style: TextStyles.buttonText.copyWith(
                            color:
                                comparisonCount >= 2
                                    ? primaryColor
                                    : isDarkMode
                                    ? AppColorsDark.disabled
                                    : AppColors.disabled,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),

          // Active filters section
          if (showActiveFilters && activeFilters.isNotEmpty) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Text(
                  'Active Filters:',
                  style: TextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                if (onClearAllFilters != null)
                  TextButton(
                    onPressed: onClearAllFilters,
                    child: Text(
                      'Clear All',
                      style: TextStyle(color: primaryColor),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  activeFilters.map((filter) {
                    return Chip(
                      label: Text(
                        filter,
                        style: TextStyle(color: primaryColor, fontSize: 12),
                      ),
                      backgroundColor: chipBgColor,
                      deleteIcon: Icon(
                        Icons.close,
                        size: 16,
                        color: primaryColor,
                      ),
                      onDeleted:
                          onFilterRemoved != null
                              ? () => onFilterRemoved!(filter)
                              : null,
                    );
                  }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}
