import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:eventati_book/models/models.dart';
import 'package:eventati_book/providers/providers.dart';
import 'package:eventati_book/styles/text_styles.dart';
import 'package:eventati_book/utils/utils.dart';
import 'package:eventati_book/widgets/common/empty_state.dart';
import 'package:eventati_book/widgets/common/loading_indicator.dart';
import 'package:intl/intl.dart';

/// A screen that displays the user's activity history
class ActivityHistoryScreen extends StatefulWidget {
  /// Constructor
  const ActivityHistoryScreen({super.key});

  @override
  State<ActivityHistoryScreen> createState() => _ActivityHistoryScreenState();
}

class _ActivityHistoryScreenState extends State<ActivityHistoryScreen> {
  @override
  void initState() {
    super.initState();
    // Initialize the activity provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.currentUser != null) {
        Provider.of<RecentActivityProvider>(
          context,
          listen: false,
        ).initialize(authProvider.currentUser!.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Activity History'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              _showFilterOptions(context);
            },
            tooltip: 'Filter activities',
          ),
        ],
      ),
      body: Consumer<RecentActivityProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const LoadingIndicator(
              message: 'Loading activity history...',
            );
          }

          if (provider.errorMessage != null) {
            return EmptyState(
              icon: Icons.error_outline,
              title: 'Error',
              message: provider.errorMessage!,
            );
          }

          final activities = provider.recentActivities;

          if (activities.isEmpty) {
            return const EmptyState(
              icon: Icons.history,
              title: 'No Activity History',
              message: 'You don\'t have any recent activities yet.',
            );
          }

          return _buildActivityList(activities);
        },
      ),
    );
  }

  Widget _buildActivityList(List<RecentActivity> activities) {
    // Group activities by date
    final Map<String, List<RecentActivity>> groupedActivities = {};

    for (final activity in activities) {
      final date = DateFormat('yyyy-MM-dd').format(activity.timestamp);
      if (!groupedActivities.containsKey(date)) {
        groupedActivities[date] = [];
      }
      groupedActivities[date]!.add(activity);
    }

    // Sort dates in descending order
    final sortedDates =
        groupedActivities.keys.toList()..sort((a, b) => b.compareTo(a));

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sortedDates.length,
      itemBuilder: (context, index) {
        final date = sortedDates[index];
        final dateActivities = groupedActivities[date]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDateHeader(date),
            const SizedBox(height: 8),
            ...dateActivities.map((activity) => _buildActivityCard(activity)),
            if (index < sortedDates.length - 1) const SizedBox(height: 16),
          ],
        );
      },
    );
  }

  Widget _buildDateHeader(String date) {
    final DateTime dateTime = DateTime.parse(date);
    final now = DateTime.now();
    final yesterday = DateTime.now().subtract(const Duration(days: 1));

    String formattedDate;
    if (DateFormat('yyyy-MM-dd').format(now) == date) {
      formattedDate = 'Today';
    } else if (DateFormat('yyyy-MM-dd').format(yesterday) == date) {
      formattedDate = 'Yesterday';
    } else {
      formattedDate = DateFormat('EEEE, MMMM d, yyyy').format(dateTime);
    }

    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 4),
      child: Text(
        formattedDate,
        style: TextStyles.subtitle.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildActivityCard(RecentActivity activity) {
    // Get icon based on activity type
    final IconData icon = _getActivityIcon(activity.type);

    // Format the timestamp
    final formattedTime = DateFormat('h:mm a').format(activity.timestamp);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          // Navigate to the activity's route if available
          if (activity.route != null) {
            if (activity.routeParams != null) {
              NavigationUtils.navigateToNamed(
                context,
                activity.route!,
                arguments: activity.routeParams,
              );
            } else {
              NavigationUtils.navigateToNamed(context, activity.route!);
            }
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Activity icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Color.fromRGBO(
                    Theme.of(context).primaryColor.r.toInt(),
                    Theme.of(context).primaryColor.g.toInt(),
                    Theme.of(context).primaryColor.b.toInt(),
                    0.1,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: Theme.of(context).primaryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),

              // Activity details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activity.title,
                      style: TextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (activity.description != null) ...[
                      const SizedBox(height: 4),
                      Text(activity.description!, style: TextStyles.bodySmall),
                    ],
                    const SizedBox(height: 4),
                    Text(
                      formattedTime,
                      style: TextStyles.bodySmall.copyWith(
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                    ),
                  ],
                ),
              ),

              // Navigation arrow
              if (activity.route != null)
                const Icon(Icons.arrow_forward_ios, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  /// Get an icon based on activity type
  IconData _getActivityIcon(ActivityType type) {
    switch (type) {
      case ActivityType.viewedEvent:
        return Icons.event;
      case ActivityType.viewedService:
        return Icons.business;
      case ActivityType.createdEvent:
        return Icons.add_circle;
      case ActivityType.updatedEvent:
        return Icons.edit;
      case ActivityType.addedTask:
        return Icons.check_circle;
      case ActivityType.completedTask:
        return Icons.task_alt;
      case ActivityType.addedGuest:
        return Icons.person_add;
      case ActivityType.addedBudgetItem:
        return Icons.attach_money;
      case ActivityType.madeBooking:
        return Icons.book_online;
      case ActivityType.comparedServices:
        return Icons.compare;
      case ActivityType.viewedRecommendation:
        return Icons.recommend;
      case ActivityType.other:
        return Icons.history;
    }
  }

  void _showFilterOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('All Activities'),
                leading: const Icon(Icons.all_inclusive),
                onTap: () {
                  Navigator.pop(context);
                  // Apply filter for all activities
                },
              ),
              ListTile(
                title: const Text('Events'),
                leading: const Icon(Icons.event),
                onTap: () {
                  Navigator.pop(context);
                  // Apply filter for event activities
                },
              ),
              ListTile(
                title: const Text('Services'),
                leading: const Icon(Icons.business),
                onTap: () {
                  Navigator.pop(context);
                  // Apply filter for service activities
                },
              ),
              ListTile(
                title: const Text('Tasks'),
                leading: const Icon(Icons.check_circle),
                onTap: () {
                  Navigator.pop(context);
                  // Apply filter for task activities
                },
              ),
              ListTile(
                title: const Text('Bookings'),
                leading: const Icon(Icons.book_online),
                onTap: () {
                  Navigator.pop(context);
                  // Apply filter for booking activities
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
