import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:eventati_book/models/models.dart';
import 'package:eventati_book/styles/app_colors.dart';
import 'package:eventati_book/styles/app_colors_dark.dart';
import 'package:eventati_book/utils/utils.dart';

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
                      : Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              milestone.title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color:
                      milestone.status == MilestoneStatus.completed
                          ? Colors.white
                          : isDarkMode
                          ? Colors.white
                          : Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Description
            Text(
              milestone.description,
              style: TextStyle(
                fontSize: 16,
                color: isDarkMode ? Colors.white70 : Colors.black87,
              ),
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
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
              ],
            ),

            // Completion date for completed milestones
            if (milestone.status == MilestoneStatus.completed &&
                milestone.completedDate != null)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(
                  'Completed on ${DateFormat('MMMM d, yyyy').format(milestone.completedDate!)}',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDarkMode ? Colors.white70 : Colors.black54,
                  ),
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
              child: const Text(
                'Close',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
        return Colors.green;
      case MilestoneStatus.unlocked:
        return isDarkMode ? Colors.blue[700]! : Colors.blue[100]!;
      case MilestoneStatus.locked:
        return isDarkMode ? Colors.grey[800]! : Colors.grey[300]!;
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
