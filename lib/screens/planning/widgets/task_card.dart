import 'package:flutter/material.dart';
import 'package:eventati_book/models/models.dart';
import 'package:eventati_book/styles/app_colors.dart';
import 'package:eventati_book/utils/core/constants.dart';
import 'package:intl/intl.dart';


/// A card widget that displays task information
class TaskCard extends StatelessWidget {
  /// The task to display
  final Task task;

  /// The task category
  final TaskCategory? category;

  /// Whether the card is selected
  final bool isSelected;

  /// Whether the card is a prerequisite task
  final bool isPrerequisite;

  /// Whether the card is a dependent task
  final bool isDependent;

  /// Number of prerequisite tasks this task depends on
  final int prerequisiteCount;

  /// Number of tasks that depend on this task
  final int dependentCount;

  /// Callback when the card is tapped
  final VoidCallback? onTap;

  /// Creates a new task card
  const TaskCard({
    super.key,
    required this.task,
    this.category,
    this.isSelected = false,
    this.isPrerequisite = false,
    this.isDependent = false,
    this.prerequisiteCount = 0,
    this.dependentCount = 0,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Determine card color based on selection state
    Color cardColor = theme.cardTheme.color ?? Colors.white;
    if (isSelected) {
      cardColor = Color.fromRGBO(
        AppColors.primary.r.toInt(),
        AppColors.primary.g.toInt(),
        AppColors.primary.b.toInt(),
        0.15,
      );
    } else if (isPrerequisite) {
      cardColor = Color.fromRGBO(
        AppColors.primary.r.toInt(),
        AppColors.primary.g.toInt(),
        AppColors.primary.b.toInt(),
        0.10,
      ); // 0.1 * 255 = 26
    } else if (isDependent) {
      cardColor = Color.fromRGBO(
        AppColors.warning.r.toInt(),
        AppColors.warning.g.toInt(),
        AppColors.warning.b.toInt(),
        0.10,
      ); // 0.1 * 255 = 26
    }

    // Determine border color based on selection state
    Color borderColor = Colors.transparent;
    if (isSelected) {
      borderColor = AppColors.primary;
    } else if (isPrerequisite) {
      borderColor = AppColors.primary;
    } else if (isDependent) {
      borderColor = AppColors.warning;
    }

    return Card(
      margin: const EdgeInsets.symmetric(
        vertical: AppConstants.smallPadding / 2,
        horizontal: AppConstants.smallPadding,
      ),
      elevation:
          isSelected
              ? AppConstants.mediumElevation
              : AppConstants.smallElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.mediumBorderRadius),
        side: BorderSide(
          color: borderColor,
          width: isSelected || isPrerequisite || isDependent ? 2 : 0,
        ),
      ),
      color: cardColor,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.mediumBorderRadius),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.mediumPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Task title and status indicator
              Row(
                children: [
                  Expanded(
                    child: Text(
                      task.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        decoration:
                            task.status == TaskStatus.completed
                                ? TextDecoration.lineThrough
                                : null,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: AppConstants.smallPadding),
                  _buildStatusIndicator(task.status),
                ],
              ),

              if (task.description != null && task.description!.isNotEmpty) ...[
                const SizedBox(height: AppConstants.smallPadding),
                Text(
                  task.description!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              const SizedBox(height: AppConstants.mediumPadding),

              // Task metadata
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Category
                  if (category != null)
                    Chip(
                      backgroundColor: category!.getColorObject().withAlpha(
                        51,
                      ), // 0.2 * 255 = 51
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            category!.getIconData(),
                            size: 16,
                            color: category!.getColorObject(),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            category!.name,
                            style: TextStyle(
                              color: category!.getColorObject(),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      padding: EdgeInsets.zero,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),

                  // Due date
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        DateFormat('MMM d, yyyy').format(task.dueDate),
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ],
              ),

              // Dependency indicators
              if (prerequisiteCount > 0 || dependentCount > 0)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (prerequisiteCount > 0)
                        _buildDependencyBadge(
                          count: prerequisiteCount,
                          icon: Icons.arrow_upward,
                          color: AppColors.primary,
                          tooltip:
                              'Depends on $prerequisiteCount ${prerequisiteCount == 1 ? 'task' : 'tasks'}',
                        ),
                      if (prerequisiteCount > 0 && dependentCount > 0)
                        const SizedBox(width: 8),
                      if (dependentCount > 0)
                        _buildDependencyBadge(
                          count: dependentCount,
                          icon: Icons.arrow_downward,
                          color: AppColors.warning,
                          tooltip:
                              '$dependentCount ${dependentCount == 1 ? 'task depends' : 'tasks depend'} on this',
                        ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds a status indicator based on the task status
  Widget _buildStatusIndicator(TaskStatus status) {
    IconData icon;
    Color color;

    switch (status) {
      case TaskStatus.completed:
        icon = Icons.check_circle;
        color = AppColors.success;
        break;
      case TaskStatus.inProgress:
        icon = Icons.pending;
        color = AppColors.info;
        break;
      case TaskStatus.overdue:
        icon = Icons.warning;
        color = AppColors.error;
        break;
      case TaskStatus.notStarted:
        icon = Icons.circle_outlined;
        color = AppColors.textSecondary;
        break;
    }

    return Icon(icon, color: color);
  }

  /// Builds a dependency badge with count
  Widget _buildDependencyBadge({
    required int count,
    required IconData icon,
    required Color color,
    required String tooltip,
  }) {
    return Tooltip(
      message: tooltip,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: color.withAlpha(26), // 0.1 * 255 = 26
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(
              count.toString(),
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
