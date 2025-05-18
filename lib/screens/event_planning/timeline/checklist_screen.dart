import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:eventati_book/providers/providers.dart';
import 'package:eventati_book/models/models.dart';
import 'package:eventati_book/utils/utils.dart';
import 'package:eventati_book/styles/app_colors.dart';
import 'package:eventati_book/styles/app_colors_dark.dart';
import 'package:eventati_book/screens/event_planning/timeline/task_form_screen.dart';
import 'package:eventati_book/routing/route_names.dart';
import 'package:eventati_book/routing/route_arguments.dart';
import 'package:intl/intl.dart';
import 'package:eventati_book/styles/text_styles.dart';

class ChecklistScreen extends StatefulWidget {
  final String eventId;

  const ChecklistScreen({super.key, required this.eventId});

  @override
  State<ChecklistScreen> createState() => _ChecklistScreenState();
}

class _ChecklistScreenState extends State<ChecklistScreen> {
  String? _selectedCategoryId;
  TaskStatus? _selectedStatus;
  bool _showCompleted = true;

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskProvider>(
      builder: (context, taskProvider, _) {
        if (taskProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (taskProvider.error != null) {
          return Center(child: Text('Error: ${taskProvider.error}'));
        }

        if (taskProvider.tasks.isEmpty) {
          return const Center(
            child: Text('No tasks yet. Add your first task!'),
          );
        }

        // Filter tasks
        final filteredTasks = _getFilteredTasks(taskProvider);

        return Column(
          children: [
            _buildFilterBar(context, taskProvider),
            Expanded(
              child:
                  filteredTasks.isEmpty
                      ? Center(
                        child: Text(
                          'No tasks match your filters',
                          style: TextStyle(
                            color:
                                UIUtils.isDarkMode(context)
                                    ? Colors.white70
                                    : Colors.black54,
                          ),
                        ),
                      )
                      : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filteredTasks.length,
                        itemBuilder: (context, index) {
                          return _buildTaskItem(
                            context,
                            filteredTasks[index],
                            taskProvider,
                          );
                        },
                      ),
            ),
            _buildProgressBar(context, taskProvider),
          ],
        );
      },
    );
  }

  List<Task> _getFilteredTasks(TaskProvider taskProvider) {
    var tasks = taskProvider.tasks;

    // Filter by completion status
    if (!_showCompleted) {
      tasks =
          tasks.where((task) => task.status != TaskStatus.completed).toList();
    }

    // Filter by category if selected
    if (_selectedCategoryId != null) {
      tasks =
          tasks
              .where((task) => task.categoryId == _selectedCategoryId)
              .toList();
    }

    // Filter by status if selected
    if (_selectedStatus != null) {
      tasks = tasks.where((task) => task.status == _selectedStatus).toList();
    }

    // Sort by due date
    tasks.sort((a, b) => a.dueDate.compareTo(b.dueDate));

    return tasks;
  }

  Widget _buildFilterBar(BuildContext context, TaskProvider taskProvider) {
    final isDarkMode = UIUtils.isDarkMode(context);
    final primaryColor = isDarkMode ? AppColorsDark.primary : AppColors.primary;
    final backgroundColor =
        isDarkMode
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
              0.2,
            );

    return Container(
      padding: const EdgeInsets.all(16),
      color: backgroundColor,
      child: Column(
        children: [
          // Category filter
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildCategoryChip(
                  context,
                  null,
                  'All',
                  Icons.list,
                  primaryColor,
                ),
                ...taskProvider.categories.map((category) {
                  return _buildCategoryChip(
                    context,
                    category.id,
                    category.name,
                    category.getIconData(),
                    category.getColorObject(),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Status filter
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildStatusChip(
                  context,
                  null,
                  'All Statuses',
                  Icons.filter_list,
                  primaryColor,
                ),
                _buildStatusChip(
                  context,
                  TaskStatus.notStarted,
                  'Not Started',
                  Icons.circle_outlined,
                  AppColors.warning,
                ),
                _buildStatusChip(
                  context,
                  TaskStatus.inProgress,
                  'In Progress',
                  Icons.pending,
                  AppColors.primary,
                ),
                _buildStatusChip(
                  context,
                  TaskStatus.completed,
                  'Completed',
                  Icons.check_circle,
                  AppColors.success,
                ),
                _buildStatusChip(
                  context,
                  TaskStatus.overdue,
                  'Overdue',
                  Icons.warning,
                  AppColors.error,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Show/hide completed tasks
          SwitchListTile(
            title: const Text('Show Completed Tasks'),
            value: _showCompleted,
            activeColor: primaryColor,
            contentPadding: EdgeInsets.zero,
            dense: true,
            onChanged: (value) {
              setState(() {
                _showCompleted = value;
              });
            },
          ),

          // Manage dependencies button
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: ElevatedButton.icon(
              onPressed: () {
                NavigationUtils.navigateToNamed(
                  context,
                  RouteNames.taskDependency,
                  arguments: TaskDependencyArguments(
                    eventId: widget.eventId,
                    eventName:
                        'Event', // We don't have event name in this screen
                  ),
                );
              },
              icon: const Icon(Icons.account_tree),
              label: const Text('Manage Task Dependencies'),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(
    BuildContext context,
    String? categoryId,
    String label,
    IconData icon,
    Color color,
  ) {
    final isSelected = _selectedCategoryId == categoryId;
    final isDarkMode = UIUtils.isDarkMode(context);

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        selected: isSelected,
        label: Text(label),
        avatar: Icon(
          icon,
          size: 18,
          color:
              isSelected
                  ? Colors.white
                  : isDarkMode
                  ? Colors.white
                  : color,
        ),
        backgroundColor:
            isDarkMode
                ? Color.fromRGBO(
                  AppColors.disabled.r.toInt(),
                  AppColors.disabled.g.toInt(),
                  AppColors.disabled.b.toInt(),
                  0.7,
                )
                : Colors.white,
        selectedColor: color,
        checkmarkColor: Colors.white,
        labelStyle: TextStyle(
          color:
              isSelected
                  ? Colors.white
                  : isDarkMode
                  ? Colors.white
                  : Colors.black,
        ),
        onSelected: (selected) {
          setState(() {
            _selectedCategoryId = selected ? categoryId : null;
          });
        },
      ),
    );
  }

  Widget _buildStatusChip(
    BuildContext context,
    TaskStatus? status,
    String label,
    IconData icon,
    Color color,
  ) {
    final isSelected = _selectedStatus == status;
    final isDarkMode = UIUtils.isDarkMode(context);

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        selected: isSelected,
        label: Text(label),
        avatar: Icon(
          icon,
          size: 18,
          color:
              isSelected
                  ? Colors.white
                  : isDarkMode
                  ? Colors.white
                  : color,
        ),
        backgroundColor:
            isDarkMode
                ? Color.fromRGBO(
                  AppColors.disabled.r.toInt(),
                  AppColors.disabled.g.toInt(),
                  AppColors.disabled.b.toInt(),
                  0.7,
                )
                : Colors.white,
        selectedColor: color,
        checkmarkColor: Colors.white,
        labelStyle: TextStyle(
          color:
              isSelected
                  ? Colors.white
                  : isDarkMode
                  ? Colors.white
                  : Colors.black,
        ),
        onSelected: (selected) {
          setState(() {
            _selectedStatus = selected ? status : null;
          });
        },
      ),
    );
  }

  Widget _buildTaskItem(
    BuildContext context,
    Task task,
    TaskProvider taskProvider,
  ) {
    final category = taskProvider.categories.firstWhere(
      (c) => c.id == task.categoryId,
      orElse:
          () => TaskCategory(
            id: '',
            name: 'Unknown',
            description: '',
            icon: 'help_outline',
            color: '#9E9E9E',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
    );

    final isOverdue =
        task.status != TaskStatus.completed &&
        task.dueDate.isBefore(DateTime.now());

    Color statusColor;
    IconData statusIcon;

    switch (task.status) {
      case TaskStatus.completed:
        statusColor = AppColors.success;
        statusIcon = Icons.check_circle;
        break;
      case TaskStatus.inProgress:
        statusColor = AppColors.primary;
        statusIcon = Icons.pending;
        break;
      case TaskStatus.notStarted:
        statusColor = isOverdue ? AppColors.error : AppColors.warning;
        statusIcon = isOverdue ? Icons.warning : Icons.circle_outlined;
        break;
      case TaskStatus.overdue:
        statusColor = AppColors.error;
        statusIcon = Icons.warning;
        break;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => TaskFormScreen(
                    eventId: widget.eventId,
                    taskProvider: taskProvider,
                    task: task,
                  ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status icon
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: statusColor.withAlpha(51), // 0.2 * 255 = 51
                  shape: BoxShape.circle,
                ),
                child: Icon(statusIcon, color: statusColor, size: 16),
              ),
              const SizedBox(width: 16),
              // Task content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          category.getIconData(),
                          color: category.getColorObject(),
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(category.name, style: TextStyles.bodySmall),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            task.title,
                            style: TextStyles.bodyLarge.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        // Dependency indicators
                        _buildDependencyIndicators(taskProvider, task),
                      ],
                    ),
                    if (task.description != null &&
                        task.description!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        task.description!,
                        style: TextStyles.bodyMedium.copyWith(
                          decoration:
                              task.status == TaskStatus.completed
                                  ? TextDecoration.lineThrough
                                  : null,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Due: ${DateFormat('MMM d, yyyy').format(task.dueDate)}',
                          style: TextStyles.bodySmall,
                        ),
                        if (task.status != TaskStatus.completed)
                          Checkbox(
                            value: false,
                            activeColor: AppColors.success,
                            onChanged: (_) {
                              // Store the current context and task ID before the async gap
                              final currentContext = context;
                              final currentTaskId = task.id;
                              final currentEventId = widget.eventId;

                              // Use a separate function to handle the async operation
                              _completeTask(
                                taskProvider,
                                currentTaskId,
                                currentContext,
                                currentEventId,
                              );
                            },
                          )
                        else
                          Checkbox(
                            value: true,
                            activeColor: AppColors.success,
                            onChanged: (_) {
                              // For resetting a task to not started, we don't need to check dependencies
                              taskProvider.updateTaskStatus(
                                task.id,
                                TaskStatus.notStarted,
                              );
                            },
                          ),
                      ],
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

  Widget _buildProgressBar(BuildContext context, TaskProvider taskProvider) {
    final isDarkMode = UIUtils.isDarkMode(context);
    final primaryColor = isDarkMode ? AppColorsDark.primary : AppColors.primary;
    final backgroundColor =
        isDarkMode
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
              0.2,
            );

    final completionPercentage = taskProvider.completionPercentage;

    return Container(
      padding: const EdgeInsets.all(16),
      color: backgroundColor,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progress',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
              Text(
                '${completionPercentage.toStringAsFixed(0)}%',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: completionPercentage / 100,
            backgroundColor:
                isDarkMode
                    ? Color.fromRGBO(
                      AppColors.disabled.r.toInt(),
                      AppColors.disabled.g.toInt(),
                      AppColors.disabled.b.toInt(),
                      0.7,
                    )
                    : Color.fromRGBO(
                      AppColors.disabled.r.toInt(),
                      AppColors.disabled.g.toInt(),
                      AppColors.disabled.b.toInt(),
                      0.3,
                    ),
            valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${taskProvider.completedTasks} of ${taskProvider.totalTasks} tasks completed',
                style: TextStyles.bodySmall,
              ),
              Text(
                '${taskProvider.pendingTasks} remaining',
                style: TextStyles.bodySmall,
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Handles completing a task asynchronously
  Future<void> _completeTask(
    TaskProvider taskProvider,
    String taskId,
    BuildContext currentContext,
    String eventId,
  ) async {
    // We don't need to capture anything from the currentContext
    // since we'll use the State's context after the async gap

    final success = await taskProvider.updateTaskStatus(
      taskId,
      TaskStatus.completed,
    );

    // Check if the widget is still mounted and there was an error
    if (mounted && !success && taskProvider.error != null) {
      // Get a fresh context after the async gap
      final errorMessage = taskProvider.error!;

      // Use the State's context which is guaranteed to be valid if mounted is true
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: AppColors.error,
          duration: const Duration(seconds: 5),
          action: SnackBarAction(
            label: 'View Dependencies',
            textColor: Colors.white,
            onPressed: () {
              // Use the State's context which is guaranteed to be valid if mounted is true
              NavigationUtils.navigateToNamed(
                context,
                RouteNames.taskDependency,
                arguments: TaskDependencyArguments(
                  eventId: eventId,
                  eventName: 'Event',
                  focusedTaskId: taskId,
                ),
              );
            },
          ),
        ),
      );
    }
  }

  /// Builds dependency indicator icons for a task
  Widget _buildDependencyIndicators(TaskProvider taskProvider, Task task) {
    final hasPrerequisites =
        taskProvider.getPrerequisiteTasks(task.id).isNotEmpty;
    final hasDependents = taskProvider.getDependentTasks(task.id).isNotEmpty;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (hasPrerequisites)
          const Tooltip(
            message: 'This task depends on other tasks',
            child: Padding(
              padding: EdgeInsets.only(left: 4),
              child: Icon(
                Icons.arrow_downward,
                size: 16,
                color: AppColors.warning,
              ),
            ),
          ),
        if (hasDependents)
          const Tooltip(
            message: 'Other tasks depend on this task',
            child: Padding(
              padding: EdgeInsets.only(left: 4),
              child: Icon(
                Icons.arrow_upward,
                size: 16,
                color: AppColors.primary,
              ),
            ),
          ),
      ],
    );
  }
}
