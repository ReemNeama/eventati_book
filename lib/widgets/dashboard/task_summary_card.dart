import 'package:flutter/material.dart';
import 'package:eventati_book/models/models.dart';
import 'package:eventati_book/utils/utils.dart';
import 'package:eventati_book/styles/app_colors.dart';
import 'package:eventati_book/styles/app_colors_dark.dart';
import 'package:eventati_book/styles/text_styles.dart';

/// A card displaying a summary of tasks
class TaskSummaryCard extends StatelessWidget {
  final List<Task> tasks;

  const TaskSummaryCard({super.key, required this.tasks});

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = UIUtils.isDarkMode(context);
    final Color cardColor =
        isDarkMode
            ? Color.fromRGBO(
              AppColors.disabled.r.toInt(),
              AppColors.disabled.g.toInt(),
              AppColors.disabled.b.toInt(),
              0.85,
            )
            : Colors.white;
    final Color textSecondary =
        isDarkMode ? AppColorsDark.textSecondary : AppColors.textSecondary;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: cardColor,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Upcoming Tasks',
              style: TextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...tasks.map((task) => _buildTaskItem(context, task)),
            if (tasks.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'No upcoming tasks',
                    style: TextStyle(
                      color: textSecondary,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskItem(BuildContext context, Task task) {
    final daysUntil = task.dueDate.difference(DateTime.now()).inDays;
    final isOverdue = daysUntil < 0;
    final isToday = daysUntil == 0;

    Color statusColor;
    if (isOverdue) {
      statusColor = AppColors.error;
    } else if (isToday) {
      statusColor = AppColors.warning;
    } else if (daysUntil <= 3) {
      statusColor = AppColors.ratingStarColor;
    } else {
      statusColor = AppColors.success;
    }

    String dueText;
    if (isOverdue) {
      dueText = 'Overdue by ${daysUntil.abs()} days';
    } else if (isToday) {
      dueText = 'Due today';
    } else {
      dueText = 'Due in $daysUntil days';
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 12,
            height: 12,
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              color: statusColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(task.title, style: TextStyles.bodyMedium),
                const SizedBox(height: 2),
                Text(dueText, style: TextStyles.bodySmall),
                if (task.description != null &&
                    task.description!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    task.description!,
                    style: TextStyles.bodySmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
