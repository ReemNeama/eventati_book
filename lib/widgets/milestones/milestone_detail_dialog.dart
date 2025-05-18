import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:eventati_book/models/models.dart';
import 'package:eventati_book/styles/app_colors.dart';
import 'package:eventati_book/styles/app_colors_dark.dart';
import 'package:eventati_book/utils/utils.dart';
import 'package:eventati_book/styles/text_styles.dart';

/// A dialog to show milestone details
class MilestoneDetailDialog extends StatelessWidget {
  /// The milestone to display
  final Milestone milestone;

  const MilestoneDetailDialog({super.key, required this.milestone});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = UIUtils.isDarkMode(context);
    final primaryColor = isDarkMode ? AppColorsDark.primary : AppColors.primary;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon and title
            Icon(
              milestone.icon,
              size: 48,
              color:
                  milestone.status == MilestoneStatus.completed
                      ? primaryColor
                      : Color.fromRGBO(
                        AppColors.disabled.r.toInt(),
                        AppColors.disabled.g.toInt(),
                        AppColors.disabled.b.toInt(),
                        0.4,
                      ),
            ),
            const SizedBox(height: 16),
            Text(
              milestone.title,
              style: TextStyles.subtitle,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),

            // Status badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _getStatusColor(milestone.status, isDarkMode),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                _getStatusText(milestone.status),
                style: TextStyles.bodyMedium,
              ),
            ),
            const SizedBox(height: 16),

            // Description
            Text(
              milestone.description,
              style: TextStyles.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),

            // Points
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.star, color: primaryColor, size: 20),
                const SizedBox(width: 4),
                Text(
                  '${milestone.points} points',
                  style: TextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),

            // Completion date for completed milestones
            if (milestone.status == MilestoneStatus.completed &&
                milestone.completedDate != null)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(
                  // Use null-safe approach with null coalescing operator
                  'Completed on ${DateFormat('MMMM d, yyyy').format(milestone.completedDate ?? DateTime.now())}',
                  style: TextStyles.bodyMedium,
                ),
              ),

            const SizedBox(height: 24),

            // Close button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Close',
                style: TextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Get color for milestone status
  Color _getStatusColor(MilestoneStatus status, bool isDarkMode) {
    switch (status) {
      case MilestoneStatus.completed:
        return AppColors.success;
      case MilestoneStatus.unlocked:
        // Use null-safe approach with explicit cast
        return isDarkMode
            ? Color.fromRGBO(
              AppColors.primary.r.toInt(),
              AppColors.primary.g.toInt(),
              AppColors.primary.b.toInt(),
              0.7,
            )
            : Color.fromRGBO(
              AppColors.primary.r.toInt(),
              AppColors.primary.g.toInt(),
              AppColors.primary.b.toInt(),
              0.1,
            );
      case MilestoneStatus.locked:
        // Use null-safe approach with explicit cast
        return isDarkMode
            ? Color.fromRGBO(
              AppColors.disabled.r.toInt(),
              AppColors.disabled.g.toInt(),
              AppColors.disabled.b.toInt(),
              0.8,
            )
            : Color.fromRGBO(
              AppColors.disabled.r.toInt(),
              AppColors.disabled.g.toInt(),
              AppColors.disabled.b.toInt(),
              0.3,
            );
    }
  }

  /// Get text for milestone status
  String _getStatusText(MilestoneStatus status) {
    switch (status) {
      case MilestoneStatus.completed:
        return 'Completed';
      case MilestoneStatus.unlocked:
        return 'In Progress';
      case MilestoneStatus.locked:
        return 'Locked';
    }
  }
}
