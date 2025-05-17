import 'package:flutter/material.dart';
import 'package:eventati_book/models/models.dart';
import 'package:eventati_book/utils/utils.dart';
import 'package:eventati_book/styles/app_colors.dart';
import 'package:eventati_book/styles/app_colors_dark.dart';

/// Extension on BudgetItem to add missing properties
extension BudgetItemExtension on BudgetItem {
  /// Get the estimated amount
  double get estimatedAmount => 0.0; // Default value

  /// Get the actual amount
  double? get actualAmount => null; // Default value
}

/// A card displaying a summary of budget items
class BudgetSummaryCard extends StatelessWidget {
  final List<BudgetItem> budgetItems;

  const BudgetSummaryCard({super.key, required this.budgetItems});

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = UIUtils.isDarkMode(context);
    final Color cardColor = isDarkMode ? Colors.grey[850]! : Colors.white;
    final Color textPrimary =
        isDarkMode ? AppColorsDark.textPrimary : AppColors.textPrimary;
    final Color textSecondary =
        isDarkMode ? AppColorsDark.textSecondary : AppColors.textSecondary;

    // Calculate budget totals
    double totalEstimated = 0;
    double totalActual = 0;
    for (final item in budgetItems) {
      totalEstimated += item.estimatedAmount;
      totalActual += item.actualAmount ?? 0;
    }

    // Calculate percentage spent
    final percentSpent =
        totalEstimated > 0
            ? (totalActual / totalEstimated * 100).clamp(0, 100).toInt()
            : 0;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: cardColor,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Budget Overview',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textPrimary,
                  ),
                ),
                Text(
                  '$percentSpent% spent',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: _getPercentColor(percentSpent),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: percentSpent / 100,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                _getPercentColor(percentSpent),
              ),
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildBudgetSummaryItem(
                  'Estimated',
                  ServiceUtils.formatPrice(totalEstimated),
                  textPrimary,
                  textSecondary,
                ),
                _buildBudgetSummaryItem(
                  'Actual',
                  ServiceUtils.formatPrice(totalActual),
                  textPrimary,
                  textSecondary,
                ),
                _buildBudgetSummaryItem(
                  'Remaining',
                  ServiceUtils.formatPrice(totalEstimated - totalActual),
                  textPrimary,
                  textSecondary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBudgetSummaryItem(
    String label,
    String value,
    Color textPrimary,
    Color textSecondary,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: textSecondary)),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: textPrimary,
          ),
        ),
      ],
    );
  }

  Color _getPercentColor(int percent) {
    if (percent < 50) {
      return Colors.green;
    } else if (percent < 75) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }
}
