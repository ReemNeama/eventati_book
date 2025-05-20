import 'package:flutter/material.dart';
import 'package:eventati_book/styles/app_colors.dart';
import 'package:eventati_book/styles/app_colors_dark.dart';
import 'package:eventati_book/utils/utils.dart';

/// A floating action button for comparing services
class ComparisonFloatingButton extends StatelessWidget {
  /// The number of items selected for comparison
  final int selectedCount;

  /// The minimum number of items required for comparison
  final int minItemsForComparison;

  /// Callback when the button is pressed
  final VoidCallback onPressed;

  /// Whether to show the button
  final bool visible;

  /// Constructor
  const ComparisonFloatingButton({
    super.key,
    required this.selectedCount,
    this.minItemsForComparison = 2,
    required this.onPressed,
    this.visible = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!visible) return const SizedBox.shrink();

    final bool isDarkMode = UIUtils.isDarkMode(context);
    final bool canCompare = selectedCount >= minItemsForComparison;

    final Color primaryColor =
        isDarkMode ? AppColorsDark.primary : AppColors.primary;

    final Color backgroundColor =
        canCompare
            ? primaryColor
            : isDarkMode
            ? AppColorsDark.disabled
            : AppColors.disabled;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      transform: Matrix4.translationValues(
        0,
        selectedCount > 0 ? 0 : 100, // Slide in/out animation
        0,
      ),
      child: FloatingActionButton.extended(
        onPressed: canCompare ? onPressed : null,
        backgroundColor: backgroundColor,
        label: Row(
          children: [
            Icon(Icons.compare_arrows),
            const SizedBox(width: 8),
            Text(
              'Compare ($selectedCount)',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        tooltip:
            canCompare
                ? 'Compare selected items'
                : 'Select at least $minItemsForComparison items to compare',
      ),
    );
  }
}
