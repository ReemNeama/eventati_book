import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:eventati_book/models/models.dart';
import 'package:eventati_book/styles/app_colors.dart';
import 'package:eventati_book/styles/app_colors_dark.dart';
import 'package:eventati_book/utils/utils.dart';
import 'package:eventati_book/styles/text_styles.dart';

/// A card to display a milestone
class MilestoneCard extends StatelessWidget {
  /// The milestone to display
  final Milestone milestone;

  /// Callback when the milestone is tapped
  final VoidCallback? onTap;

  const MilestoneCard({super.key, required this.milestone, this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = UIUtils.isDarkMode(context);
    final primaryColor = isDarkMode ? AppColorsDark.primary : AppColors.primary;

    // Determine the card color based on milestone status
    Color cardColor;
    // Text color is determined by the card color
    Color iconColor;

    switch (milestone.status) {
      case MilestoneStatus.completed:
        cardColor = primaryColor;
        iconColor = Colors.white;
        break;
      case MilestoneStatus.unlocked:
        // Use null-safe approach with explicit cast
        cardColor =
            isDarkMode
                ? Color.fromRGBO(
                  AppColors.disabled.r.toInt(),
                  AppColors.disabled.g.toInt(),
                  AppColors.disabled.b.toInt(),
                  0.8,
                )
                : Colors.white;
        iconColor = primaryColor;
        break;
      case MilestoneStatus.locked:
        // Use null-safe approach with explicit cast
        cardColor =
            isDarkMode
                ? Color.fromRGBO(
                  AppColors.disabled.r.toInt(),
                  AppColors.disabled.g.toInt(),
                  AppColors.disabled.b.toInt(),
                  0.9,
                )
                : Color.fromRGBO(
                  AppColors.disabled.r.toInt(),
                  AppColors.disabled.g.toInt(),
                  AppColors.disabled.b.toInt(),
                  0.2,
                );

        iconColor =
            isDarkMode
                ? Color.fromRGBO(
                  AppColors.disabled.r.toInt(),
                  AppColors.disabled.g.toInt(),
                  AppColors.disabled.b.toInt(),
                  0.6,
                )
                : Color.fromRGBO(
                  AppColors.disabled.r.toInt(),
                  AppColors.disabled.g.toInt(),
                  AppColors.disabled.b.toInt(),
                  0.4,
                );
        break;
    }

    return Card(
      elevation: milestone.status == MilestoneStatus.completed ? 4 : 1,
      color: cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side:
            milestone.status == MilestoneStatus.unlocked
                ? BorderSide(color: primaryColor, width: 2)
                : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon
              Icon(milestone.icon, size: 40, color: iconColor),
              const SizedBox(height: 12),

              // Title
              Text(
                milestone.title,
                style: TextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),

              // Points
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color:
                      milestone.status == MilestoneStatus.completed
                          ? Color.fromRGBO(
                            Colors.white.r.toInt(),
                            Colors.white.g.toInt(),
                            Colors.white.b.toInt(),
                            0.20,
                          )
                          : primaryColor.withAlpha(50),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${milestone.points} pts',
                  style: TextStyles.bodySmall,
                ),
              ),

              // Completion date for completed milestones
              if (milestone.status == MilestoneStatus.completed &&
                  milestone.completedDate != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    // Use null-safe approach with null coalescing operator
                    'Completed ${DateFormat('MMM d, yyyy').format(milestone.completedDate ?? DateTime.now())}',
                    style: TextStyles.bodySmall,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
