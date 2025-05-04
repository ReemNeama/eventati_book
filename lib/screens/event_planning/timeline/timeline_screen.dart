import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:eventati_book/providers/task_provider.dart';
import 'package:eventati_book/models/models.dart';
import 'package:eventati_book/utils/utils.dart';
import 'package:eventati_book/styles/app_colors.dart';
import 'package:eventati_book/styles/app_colors_dark.dart';
import 'package:eventati_book/screens/event_planning/timeline/task_form_screen.dart';
import 'package:eventati_book/screens/event_planning/timeline/checklist_screen.dart';
import 'package:intl/intl.dart';

class TimelineScreen extends StatefulWidget {
  final String eventId;
  final String eventName;

  const TimelineScreen({
    super.key,
    required this.eventId,
    required this.eventName,
  });

  @override
  State<TimelineScreen> createState() => _TimelineScreenState();
}

class _TimelineScreenState extends State<TimelineScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = UIUtils.isDarkMode(context);
    final primaryColor = isDarkMode ? AppColorsDark.primary : AppColors.primary;

    return ChangeNotifierProvider(
      create: (_) => TaskProvider(eventId: widget.eventId),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Timeline for ${widget.eventName}'),
          backgroundColor: primaryColor,
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: Colors.white,
            tabs: const [Tab(text: 'Timeline'), Tab(text: 'Checklist')],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildTimelineTab(),
            ChecklistScreen(eventId: widget.eventId),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: primaryColor,
          child: const Icon(Icons.add),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) => TaskFormScreen(
                      eventId: widget.eventId,
                      taskProvider: Provider.of<TaskProvider>(
                        context,
                        listen: false,
                      ),
                    ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTimelineTab() {
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

        // Group tasks by month
        final groupedTasks = _groupTasksByMonth(taskProvider.tasks);
        final sortedMonths =
            groupedTasks.keys.toList()..sort((a, b) => a.compareTo(b));

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: sortedMonths.length,
          itemBuilder: (context, index) {
            final month = sortedMonths[index];
            final monthTasks = groupedTasks[month]!;

            return _buildMonthSection(context, month, monthTasks, taskProvider);
          },
        );
      },
    );
  }

  Widget _buildMonthSection(
    BuildContext context,
    DateTime month,
    List<Task> tasks,
    TaskProvider taskProvider,
  ) {
    final isDarkMode = UIUtils.isDarkMode(context);
    final primaryColor = isDarkMode ? AppColorsDark.primary : AppColors.primary;

    // Sort tasks by date
    tasks.sort((a, b) => a.dueDate.compareTo(b.dueDate));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Text(
            DateFormat('MMMM yyyy').format(month),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
          ),
        ),
        ...tasks.map((task) => _buildTimelineItem(context, task, taskProvider)),
        const Divider(height: 32),
      ],
    );
  }

  Widget _buildTimelineItem(
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

    return InkWell(
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
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Timeline line and dot
            Column(
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: statusColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(statusIcon, color: Colors.white, size: 14),
                ),
                Container(
                  width: 2,
                  height: 60,
                  color: isDarkMode ? Colors.grey[700] : Colors.grey[300],
                ),
              ],
            ),
            const SizedBox(width: 16),
            // Task content
            Expanded(
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
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
                          const Spacer(),
                          Text(
                            DateFormat('MMM d').format(task.dueDate),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color:
                                  isOverdue &&
                                          task.status != TaskStatus.completed
                                      ? Colors.red
                                      : isDarkMode
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
                                isDarkMode
                                    ? Colors.grey[400]
                                    : Colors.grey[600],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (task.status != TaskStatus.completed)
                            TextButton.icon(
                              onPressed: () {
                                taskProvider.updateTaskStatus(
                                  task.id,
                                  TaskStatus.completed,
                                );
                              },
                              icon: const Icon(Icons.check, size: 16),
                              label: const Text('Mark Complete'),
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.green,
                                padding: EdgeInsets.zero,
                                minimumSize: const Size(0, 0),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Map<DateTime, List<Task>> _groupTasksByMonth(List<Task> tasks) {
    final Map<DateTime, List<Task>> grouped = {};

    for (final task in tasks) {
      final month = DateTime(task.dueDate.year, task.dueDate.month);

      if (!grouped.containsKey(month)) {
        grouped[month] = [];
      }

      grouped[month]!.add(task);
    }

    return grouped;
  }
}
