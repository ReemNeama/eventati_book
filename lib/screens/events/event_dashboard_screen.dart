import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:eventati_book/models/models.dart';
import 'package:eventati_book/providers/providers.dart';
import 'package:eventati_book/services/sharing/platform_sharing_service.dart';
import 'package:eventati_book/routing/routing.dart';
import 'package:eventati_book/styles/app_colors.dart';
import 'package:eventati_book/styles/app_colors_dark.dart';
import 'package:eventati_book/utils/utils.dart';
import 'package:eventati_book/widgets/common/empty_state.dart';
import 'package:eventati_book/widgets/common/loading_indicator.dart';
import 'package:eventati_book/widgets/common/section_header.dart';
import 'package:eventati_book/widgets/dashboard/dashboard_widgets.dart';

/// A comprehensive dashboard for a specific event
class EventDashboardScreen extends StatefulWidget {
  final String eventId;

  const EventDashboardScreen({super.key, required this.eventId});

  @override
  State<EventDashboardScreen> createState() => _EventDashboardScreenState();
}

class _EventDashboardScreenState extends State<EventDashboardScreen> {
  late Future<Event?> _eventFuture;
  late Future<List<Task>> _tasksFuture;
  late Future<List<BudgetItem>> _budgetItemsFuture;
  late Future<List<Guest>> _guestsFuture;
  late Future<List<Booking>> _bookingsFuture;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    // In a real app, these would be actual provider methods
    // For now, we're using mock data for demonstration purposes

    // Create a mock event
    _eventFuture = Future.value(
      Event(
        id: widget.eventId,
        name: 'Sample Event',
        type: EventType.celebration,
        date: DateTime.now().add(const Duration(days: 30)),
        location: 'Sample Location',
        budget: 5000.0,
        guestCount: 100,
        description: 'This is a sample event description',
      ),
    );

    // Create mock tasks
    _tasksFuture = Future.value([]);

    // Create mock budget items
    _budgetItemsFuture = Future.value([]);

    // Create mock guests
    _guestsFuture = Future.value([]);

    // Create mock bookings
    _bookingsFuture = Future.value([]);
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = UIUtils.isDarkMode(context);
    final Color primaryColor =
        isDarkMode ? AppColorsDark.primary : AppColors.primary;
    final Color cardColor =
        isDarkMode
            ? Color.fromRGBO(
              AppColors.disabled.r.toInt(),
              AppColors.disabled.g.toInt(),
              AppColors.disabled.b.toInt(),
              0.85,
            )
            : Colors.white;
    final Color textPrimary =
        isDarkMode ? AppColorsDark.textPrimary : AppColors.textPrimary;
    final Color textSecondary =
        isDarkMode ? AppColorsDark.textSecondary : AppColors.textSecondary;

    return Scaffold(
      appBar: AppBar(
        title: FutureBuilder<Event?>(
          future: _eventFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Text('Event Dashboard');
            }
            if (snapshot.hasData && snapshot.data != null) {
              return Text('${snapshot.data!.name} Dashboard');
            }
            return const Text('Event Dashboard');
          },
        ),
        backgroundColor: primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _shareEventDashboard(),
            tooltip: 'Share Dashboard',
          ),
          PopupMenuButton<String>(
            onSelected: (value) => _handleMenuAction(value),
            itemBuilder:
                (context) => [
                  const PopupMenuItem<String>(
                    value: 'refresh',
                    child: Text('Refresh Data'),
                  ),
                  const PopupMenuItem<String>(
                    value: 'edit',
                    child: Text('Edit Event'),
                  ),
                ],
          ),
        ],
      ),
      body: FutureBuilder<Event?>(
        future: _eventFuture,
        builder: (context, eventSnapshot) {
          if (eventSnapshot.connectionState == ConnectionState.waiting) {
            return const LoadingIndicator();
          }

          if (eventSnapshot.hasError) {
            return Center(
              child: EmptyState.error(
                message: 'Error loading event: ${eventSnapshot.error}',
                actionText: 'Retry',
                onAction: () => setState(() => _loadData()),
              ),
            );
          }

          if (!eventSnapshot.hasData || eventSnapshot.data == null) {
            return Center(
              child: EmptyState.notFound(
                title: 'Event Not Found',
                message: 'The event you are looking for does not exist',
                actionText: 'Go Back',
                onAction: () => Navigator.pop(context),
              ),
            );
          }

          final event = eventSnapshot.data!;

          return RefreshIndicator(
            onRefresh: () async => setState(() => _loadData()),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildEventOverview(event, textPrimary, textSecondary),
                    const SizedBox(height: 24),
                    _buildTasksSection(cardColor, textPrimary),
                    const SizedBox(height: 24),
                    _buildBudgetSection(cardColor, textPrimary),
                    const SizedBox(height: 24),
                    _buildGuestsSection(cardColor, textPrimary),
                    const SizedBox(height: 24),
                    _buildBookingsSection(cardColor, textPrimary),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToEventPlanning(),
        backgroundColor: primaryColor,
        tooltip: 'Edit Event Planning',
        child: const Icon(Icons.edit),
      ),
    );
  }

  Widget _buildEventOverview(
    Event event,
    Color textPrimary,
    Color textSecondary,
  ) {
    return EventOverviewCard(event: event);
  }

  Widget _buildTasksSection(Color cardColor, Color textPrimary) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Tasks & Timeline',
          actionText: 'View All',
          onActionTap: () => _navigateToTimeline(),
          actionIcon: Icons.arrow_forward,
        ),
        const SizedBox(height: 8),
        FutureBuilder<List<Task>>(
          future: _tasksFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const LoadingIndicator(size: 30);
            }

            if (snapshot.hasError) {
              return EmptyState.error(
                message: 'Error loading tasks',
                displayType: EmptyStateDisplayType.compact,
              );
            }

            final tasks = snapshot.data ?? [];
            if (tasks.isEmpty) {
              return EmptyState.empty(
                message: 'No tasks yet',
                actionText: 'Add Tasks',
                onAction: () => _navigateToTimeline(),
                displayType: EmptyStateDisplayType.compact,
              );
            }

            // Show only upcoming tasks, limited to 5
            final upcomingTasks =
                tasks
                    .where(
                      (task) =>
                          task.status != TaskStatus.completed &&
                          task.dueDate.isAfter(DateTime.now()),
                    )
                    .toList()
                  ..sort((a, b) => a.dueDate.compareTo(b.dueDate));

            final tasksToShow = upcomingTasks.take(5).toList();

            return TaskSummaryCard(tasks: tasksToShow);
          },
        ),
      ],
    );
  }

  Widget _buildBudgetSection(Color cardColor, Color textPrimary) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Budget',
          actionText: 'View All',
          onActionTap: () => _navigateToBudget(),
          actionIcon: Icons.arrow_forward,
        ),
        const SizedBox(height: 8),
        FutureBuilder<List<BudgetItem>>(
          future: _budgetItemsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const LoadingIndicator(size: 30);
            }

            if (snapshot.hasError) {
              return EmptyState.error(
                message: 'Error loading budget items',
                displayType: EmptyStateDisplayType.compact,
              );
            }

            final budgetItems = snapshot.data ?? [];
            if (budgetItems.isEmpty) {
              return EmptyState.empty(
                message: 'No budget items yet',
                actionText: 'Set Budget',
                onAction: () => _navigateToBudget(),
                displayType: EmptyStateDisplayType.compact,
              );
            }

            return BudgetSummaryCard(budgetItems: budgetItems);
          },
        ),
      ],
    );
  }

  Widget _buildGuestsSection(Color cardColor, Color textPrimary) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Guest List',
          actionText: 'View All',
          onActionTap: () => _navigateToGuestList(),
          actionIcon: Icons.arrow_forward,
        ),
        const SizedBox(height: 8),
        FutureBuilder<List<Guest>>(
          future: _guestsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const LoadingIndicator(size: 30);
            }

            if (snapshot.hasError) {
              return EmptyState.error(
                message: 'Error loading guests',
                displayType: EmptyStateDisplayType.compact,
              );
            }

            final guests = snapshot.data ?? [];
            if (guests.isEmpty) {
              return EmptyState.empty(
                message: 'No guests yet',
                actionText: 'Add Guests',
                onAction: () => _navigateToGuestList(),
                displayType: EmptyStateDisplayType.compact,
              );
            }

            return GuestSummaryCard(guests: guests);
          },
        ),
      ],
    );
  }

  Widget _buildBookingsSection(Color cardColor, Color textPrimary) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Bookings',
          actionText: 'View All',
          onActionTap: () => _navigateToBookings(),
          actionIcon: Icons.arrow_forward,
        ),
        const SizedBox(height: 8),
        FutureBuilder<List<Booking>>(
          future: _bookingsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const LoadingIndicator(size: 30);
            }

            if (snapshot.hasError) {
              return EmptyState.error(
                message: 'Error loading bookings',
                displayType: EmptyStateDisplayType.compact,
              );
            }

            final bookings = snapshot.data ?? [];
            if (bookings.isEmpty) {
              return EmptyState.empty(
                message: 'No bookings yet',
                actionText: 'Browse Services',
                onAction: () => _navigateToServices(),
                displayType: EmptyStateDisplayType.compact,
              );
            }

            return BookingSummaryCard(bookings: bookings);
          },
        ),
      ],
    );
  }

  void _navigateToTimeline() {
    NavigationUtils.navigateToNamed(
      context,
      RouteNames.timeline,
      arguments: TimelineArguments(
        eventId: widget.eventId,
        eventName: 'Event', // This will be replaced with actual event name
      ),
    );
  }

  void _navigateToBudget() {
    NavigationUtils.navigateToNamed(
      context,
      RouteNames.budgetOverview,
      arguments: BudgetOverviewArguments(eventId: widget.eventId),
    );
  }

  void _navigateToGuestList() {
    NavigationUtils.navigateToNamed(
      context,
      RouteNames.guestList,
      arguments: GuestListArguments(
        eventId: widget.eventId,
        eventName: 'Event', // This will be replaced with actual event name
      ),
    );
  }

  void _navigateToBookings() {
    NavigationUtils.navigateToNamed(context, RouteNames.bookings);
  }

  void _navigateToServices() {
    NavigationUtils.navigateToNamed(context, RouteNames.services);
  }

  void _navigateToEventPlanning() {
    _eventFuture.then((event) {
      if (event != null && mounted) {
        NavigationUtils.navigateToNamed(
          context,
          RouteNames.eventPlanning,
          arguments: EventPlanningArguments(
            eventId: widget.eventId,
            eventName: event.name,
            eventType: event.type.toString().split('.').last,
            eventDate: event.date,
          ),
        );
      }
    });
  }

  void _shareEventDashboard() {
    _eventFuture.then((event) {
      if (event != null && mounted) {
        _showShareOptions(context, event);
      }
    });
  }

  /// Show share options dialog
  void _showShareOptions(BuildContext context, Event event) {
    showDialog(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: const Text('Share Event Dashboard'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.share),
                  title: const Text('Share via System'),
                  subtitle: const Text('Share using your device\'s share menu'),
                  onTap: () {
                    Navigator.of(dialogContext).pop();
                    _shareEvent(event);
                  },
                ),
                const Divider(),
                const SizedBox(height: 8),
                const Text(
                  'Share to social media:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Facebook share button
                    _buildSocialShareButton(
                      dialogContext,
                      event,
                      SharingPlatform.facebook,
                      Icons.facebook,
                      'Facebook',
                    ),
                    // Twitter share button
                    _buildSocialShareButton(
                      dialogContext,
                      event,
                      SharingPlatform.twitter,
                      Icons.flutter_dash,
                      'Twitter',
                    ),
                    // WhatsApp share button
                    _buildSocialShareButton(
                      dialogContext,
                      event,
                      SharingPlatform.whatsapp,
                      Icons.message,
                      'WhatsApp',
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('Cancel'),
              ),
            ],
          ),
    );
  }

  /// Build a social media share button
  Widget _buildSocialShareButton(
    BuildContext dialogContext,
    Event event,
    SharingPlatform platform,
    IconData icon,
    String label,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(icon),
          onPressed: () async {
            Navigator.of(dialogContext).pop();

            // Show loading indicator
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Sharing to $label...'),
                duration: const Duration(seconds: 1),
              ),
            );

            try {
              // Share to the platform
              final success = await Provider.of<SocialSharingProvider>(
                context,
                listen: false,
              ).shareEventToPlatform(event, platform);

              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Shared to $label successfully')),
                );
              } else if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to share to $label')),
                );
              }
            } catch (e) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error sharing to $label: $e')),
                );
              }
            }
          },
          tooltip: 'Share to $label',
        ),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  /// Share event using the system share dialog
  Future<void> _shareEvent(Event event) async {
    try {
      // Show loading indicator
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Preparing to share...'),
          duration: Duration(seconds: 1),
        ),
      );

      // Share the event
      await Provider.of<SocialSharingProvider>(
        context,
        listen: false,
      ).shareEvent(event);
    } catch (e) {
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to share event: $e')));
      }
    }
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'refresh':
        setState(() => _loadData());
        break;
      case 'edit':
        _navigateToEventPlanning();
        break;
    }
  }
}
