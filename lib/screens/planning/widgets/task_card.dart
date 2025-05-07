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
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Determine card color based on selection state
    Color cardColor = theme.cardTheme.color ?? Colors.white;
    if (isSelected) {
      cardColor = AppColors.primaryWithAlpha(0.15);
    } else if (isPrerequisite) {
      cardColor = Colors.blue.withOpacity(0.1);
    } else if (isDependent) {
      cardColor = Colors.orange.withOpacity(0.1);
    }

    // Determine border color based on selection state
    Color borderColor = Colors.transparent;
    if (isSelected) {
      borderColor = AppColors.primary;
    } else if (isPrerequisite) {
      borderColor = Colors.blue;
    } else if (isDependent) {
      borderColor = Colors.orange;
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
                      backgroundColor: category!.color.withOpacity(0.2),
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            category!.icon,
                            size: 16,
                            color: category!.color,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            category!.name,
                            style: TextStyle(
                              color: category!.color,
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
      default:
        icon = Icons.circle_outlined;
        color = AppColors.textSecondary;
        break;
    }

    return Icon(icon, color: color);
  }
}
