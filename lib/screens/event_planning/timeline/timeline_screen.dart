import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:eventati_book/providers/providers.dart';
import 'package:eventati_book/models/models.dart';
import 'package:eventati_book/utils/utils.dart';
import 'package:eventati_book/styles/app_colors.dart';
import 'package:eventati_book/styles/app_colors_dark.dart';
import 'package:eventati_book/widgets/common/responsive_layout.dart';
import 'package:eventati_book/screens/event_planning/timeline/task_form_screen.dart';
import 'package:eventati_book/screens/event_planning/timeline/checklist_screen.dart';
import 'package:eventati_book/routing/route_names.dart';
import 'package:eventati_book/routing/route_arguments.dart';
import 'package:intl/intl.dart';
import 'package:eventati_book/styles/text_styles.dart';

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
          actions: [
            IconButton(
              icon: const Icon(Icons.account_tree),
              tooltip: 'Manage Dependencies',
              onPressed: () {
                NavigationUtils.navigateToNamed(
                  context,
                  RouteNames.taskDependency,
                  arguments: TaskDependencyArguments(
                    eventId: widget.eventId,
                    eventName: widget.eventName,
                  ),
                );
              },
            ),
            // Database test button removed
          ],
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: Colors.white,
            tabs: const [Tab(text: 'Timeline'), Tab(text: 'Checklist')],
          ),
        ),
        body: ResponsiveLayout(
          // Mobile layout (portrait phones)
          mobileLayout: TabBarView(
            controller: _tabController,
            children: [
              _buildTimelineTab(),
              ChecklistScreen(eventId: widget.eventId),
            ],
          ),
          // Tablet layout (landscape phones and tablets)
          tabletLayout: _buildTabletLayout(),
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
          return ErrorHandlingUtils.getErrorScreen(
            taskProvider.error!,
            onRetry: () {
              // Create a new provider instance to reload the data
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => TimelineScreen(
                        eventId: widget.eventId,
                        eventName: widget.eventName,
                      ),
                ),
              );
            },
            onGoHome: () => Navigator.of(context).pop(),
          );
        }

        if (taskProvider.tasks.isEmpty) {
          return Center(
            child: EmptyStateUtils.getEmptyTimelineState(
              actionText: 'Add Task',
              onAction: () {
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
    // Sort tasks by date
    tasks.sort((a, b) => a.dueDate.compareTo(b.dueDate));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Text(
            DateFormat('MMMM yyyy').format(month),
            style: TextStyles.sectionTitle,
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
                  color:
                      UIUtils.isDarkMode(context)
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
                          Icon(
                            category.getIconData(),
                            color: category.getColorObject(),
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(category.name, style: TextStyles.bodySmall),
                          const Spacer(),
                          Text(
                            DateFormat('MMM d').format(task.dueDate),
                            style: TextStyles.bodySmall,
                          ),
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
                          style: TextStyles.bodyMedium,
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
                                foregroundColor: AppColors.success,
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

  /// Builds a side-by-side layout for tablets and larger screens
  Widget _buildTabletLayout() {
    return Consumer<TaskProvider>(
      builder: (context, taskProvider, _) {
        if (taskProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (taskProvider.error != null) {
          return ErrorHandlingUtils.getErrorScreen(
            taskProvider.error!,
            onRetry: () {
              // Create a new provider instance to reload the data
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => TimelineScreen(
                        eventId: widget.eventId,
                        eventName: widget.eventName,
                      ),
                ),
              );
            },
            onGoHome: () => Navigator.of(context).pop(),
          );
        }

        return Row(
          children: [
            // Timeline on the left (60% of width)
            Expanded(flex: 60, child: _buildTimelineTab()),
            // Vertical divider
            VerticalDivider(
              width: 1,
              thickness: 1,
              color:
                  UIUtils.isDarkMode(context)
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
                      ),
            ),
            // Checklist on the right (40% of width)
            Expanded(flex: 40, child: ChecklistScreen(eventId: widget.eventId)),
          ],
        );
      },
    );
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
