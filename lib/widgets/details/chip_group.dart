import 'package:flutter/material.dart';
import 'package:eventati_book/styles/app_colors.dart';
import 'package:eventati_book/styles/app_colors_dark.dart';
import 'package:eventati_book/utils/utils.dart';
import 'package:eventati_book/styles/text_styles.dart';

/// A widget that displays a group of chips
class ChipGroup extends StatelessWidget {
  /// The items to display as chips
  final List<String> items;

  /// The spacing between chips
  final double spacing;

  /// The spacing between rows of chips
  final double runSpacing;

  /// The maximum number of chips to display
  /// If more items exist, a "+X more" chip will be shown
  final int? maxChips;

  /// Whether to use small chips
  final bool useSmallChips;

  /// Custom chip background color
  final Color? chipColor;

  /// Custom chip text color
  final Color? textColor;

  /// Constructor
  const ChipGroup({
    super.key,
    required this.items,
    this.spacing = 8,
    this.runSpacing = 8,
    this.maxChips,
    this.useSmallChips = false,
    this.chipColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = UIUtils.isDarkMode(context);
    final defaultChipColor = Color.fromRGBO(
      (chipColor ?? (isDarkMode ? AppColorsDark.primary : AppColors.primary)).r
          .toInt(),
      (chipColor ?? (isDarkMode ? AppColorsDark.primary : AppColors.primary)).g
          .toInt(),
      (chipColor ?? (isDarkMode ? AppColorsDark.primary : AppColors.primary)).b
          .toInt(),
      0.1,
    );
    final defaultTextColor =
        textColor ?? (isDarkMode ? AppColorsDark.primary : AppColors.primary);

    // Determine which items to show based on maxChips
    final List<String> displayItems =
        maxChips != null && items.length > maxChips!
            ? items.sublist(0, maxChips)
            : items;

    // Create the list of chips
    final List<Widget> chips =
        displayItems.map((item) {
          return useSmallChips
              ? _buildSmallChip(item, defaultChipColor, defaultTextColor)
              : _buildStandardChip(item, defaultChipColor, defaultTextColor);
        }).toList();

    // Add the "+X more" chip if needed
    if (maxChips != null && items.length > maxChips!) {
      final int moreCount = items.length - maxChips!;
      final Widget moreChip =
          useSmallChips
              ? _buildSmallChip(
                '+$moreCount more',
                defaultChipColor,
                defaultTextColor,
              )
              : _buildStandardChip(
                '+$moreCount more',
                defaultChipColor,
                defaultTextColor,
              );
      chips.add(moreChip);
    }

    return Wrap(spacing: spacing, runSpacing: runSpacing, children: chips);
  }

  /// Build a standard-sized chip
  Widget _buildStandardChip(String label, Color bgColor, Color textColor) {
    return Chip(
      label: Text(label, style: TextStyle(color: textColor)),
      backgroundColor: bgColor,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  /// Build a smaller chip for compact displays
  Widget _buildSmallChip(String label, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyles.bodySmall.copyWith(color: textColor, fontSize: 10),
      ),
    );
  }
}
