import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:eventati_book/providers/task_provider.dart';
import 'package:eventati_book/models/task.dart';
import 'package:eventati_book/utils/utils.dart';
import 'package:eventati_book/styles/app_colors.dart';
import 'package:eventati_book/styles/app_colors_dark.dart';
import 'package:eventati_book/screens/event_planning/timeline/task_form_screen.dart';
import 'package:intl/intl.dart';

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
    final backgroundColor = isDarkMode ? Colors.grey[800] : Colors.grey[200];

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
                    category.icon,
                    category.color,
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
                  Colors.orange,
                ),
                _buildStatusChip(
                  context,
                  TaskStatus.inProgress,
                  'In Progress',
                  Icons.pending,
                  Colors.blue,
                ),
                _buildStatusChip(
                  context,
                  TaskStatus.completed,
                  'Completed',
                  Icons.check_circle,
                  Colors.green,
                ),
                _buildStatusChip(
                  context,
                  TaskStatus.overdue,
                  'Overdue',
                  Icons.warning,
                  Colors.red,
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
        backgroundColor: isDarkMode ? Colors.grey[700] : Colors.white,
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
        backgroundColor: isDarkMode ? Colors.grey[700] : Colors.white,
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
    final isDarkMode = UIUtils.isDarkMode(context);
    final textColor = isDarkMode ? Colors.white : Colors.black;

    final category = taskProvider.categories.firstWhere(
      (c) => c.id == task.categoryId,
      orElse:
          () => TaskCategory(
            id: '',
            name: 'Unknown',
            icon: Icons.help_outline,
            color: Colors.grey,
          ),
    );

    final isOverdue =
        task.status != TaskStatus.completed &&
        task.dueDate.isBefore(DateTime.now());

    Color statusColor;
    IconData statusIcon;

    switch (task.status) {
      case TaskStatus.completed:
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case TaskStatus.inProgress:
        statusColor = Colors.blue;
        statusIcon = Icons.pending;
        break;
      case TaskStatus.notStarted:
        statusColor = isOverdue ? Colors.red : Colors.orange;
        statusIcon = isOverdue ? Icons.warning : Icons.circle_outlined;
        break;
      case TaskStatus.overdue:
        statusColor = Colors.red;
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
                        Icon(category.icon, color: category.color, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          category.name,
                          style: TextStyle(
                            fontSize: 12,
                            color:
                                isDarkMode
                                    ? Colors.grey[400]
                                    : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      task.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                        decoration:
                            task.status == TaskStatus.completed
                                ? TextDecoration.lineThrough
                                : null,
                      ),
                    ),
                    if (task.description != null &&
                        task.description!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        task.description!,
                        style: TextStyle(
                          fontSize: 14,
                          color:
                              isDarkMode ? Colors.grey[400] : Colors.grey[600],
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
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color:
                                isOverdue && task.status != TaskStatus.completed
                                    ? Colors.red
                                    : isDarkMode
                                    ? Colors.grey[400]
                                    : Colors.grey[600],
                          ),
                        ),
                        if (task.status != TaskStatus.completed)
                          Checkbox(
                            value: false,
                            activeColor: Colors.green,
                            onChanged: (_) {
                              taskProvider.updateTaskStatus(
                                task.id,
                                TaskStatus.completed,
                              );
                            },
                          )
                        else
                          Checkbox(
                            value: true,
                            activeColor: Colors.green,
                            onChanged: (_) {
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
    final backgroundColor = isDarkMode ? Colors.grey[800] : Colors.grey[200];

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
            backgroundColor: isDarkMode ? Colors.grey[700] : Colors.grey[300],
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
                style: TextStyle(
                  fontSize: 12,
                  color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
              Text(
                '${taskProvider.pendingTasks} remaining',
                style: TextStyle(
                  fontSize: 12,
                  color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
