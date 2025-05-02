import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:eventati_book/models/milestone.dart';
import 'package:eventati_book/styles/app_colors.dart';
import 'package:eventati_book/styles/app_colors_dark.dart';
import 'package:eventati_book/utils/utils.dart';

/// A card to display a milestone
class MilestoneCard extends StatelessWidget {
  /// The milestone to display
  final Milestone milestone;
  
  /// Callback when the milestone is tapped
  final VoidCallback? onTap;
  
  const MilestoneCard({
    super.key,
    required this.milestone,
    this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    final isDarkMode = UIUtils.isDarkMode(context);
    final primaryColor = isDarkMode ? AppColorsDark.primary : AppColors.primary;
    
    // Determine the card color based on milestone status
    Color cardColor;
    Color textColor;
    Color iconColor;
    
    switch (milestone.status) {
      case MilestoneStatus.completed:
        cardColor = primaryColor;
        textColor = Colors.white;
        iconColor = Colors.white;
        break;
      case MilestoneStatus.unlocked:
        cardColor = isDarkMode ? Colors.grey[800]! : Colors.white;
        textColor = isDarkMode ? Colors.white : Colors.black87;
        iconColor = primaryColor;
        break;
      case MilestoneStatus.locked:
        cardColor = isDarkMode ? Colors.grey[900]! : Colors.grey[200]!;
        textColor = isDarkMode ? Colors.grey[400]! : Colors.grey[600]!;
        iconColor = isDarkMode ? Colors.grey[600]! : Colors.grey[400]!;
        break;
    }
    
    return Card(
      elevation: milestone.status == MilestoneStatus.completed ? 4 : 1,
      color: cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: milestone.status == MilestoneStatus.unlocked
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
              Icon(
                milestone.icon,
                size: 40,
                color: iconColor,
              ),
              const SizedBox(height: 12),
              
              // Title
              Text(
                milestone.title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              
              // Points
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: milestone.status == MilestoneStatus.completed
                      ? Colors.white.withAlpha(50)
                      : primaryColor.withAlpha(50),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${milestone.points} pts',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: milestone.status == MilestoneStatus.completed
                        ? Colors.white
                        : primaryColor,
                  ),
                ),
              ),
              
              // Completion date for completed milestones
              if (milestone.status == MilestoneStatus.completed && milestone.completedDate != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'Completed ${DateFormat('MMM d, yyyy').format(milestone.completedDate!)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: textColor.withAlpha(200),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
