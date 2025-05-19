import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:eventati_book/models/models.dart';
import 'package:eventati_book/providers/providers.dart';
import 'package:eventati_book/routing/routing.dart';
import 'package:eventati_book/styles/text_styles.dart';
import 'package:eventati_book/utils/utils.dart';
import 'package:eventati_book/widgets/common/empty_state.dart';
import 'package:eventati_book/widgets/common/loading_indicator.dart';
import 'package:intl/intl.dart';

/// A widget that displays a section of recent user activities
class RecentActivitySection extends StatelessWidget {
  /// The title of the section
  final String title;

  /// The maximum number of activities to display
  final int maxActivities;

  /// Whether to show the "See All" button
  final bool showSeeAllButton;

  /// Constructor
  const RecentActivitySection({
    super.key,
    this.title = 'Continue where you left off',
    this.maxActivities = 3,
    this.showSeeAllButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<RecentActivityProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const LoadingIndicator(
            message: 'Loading recent activities...',
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
          return const SizedBox.shrink(); // Don't show anything if no activities
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section title
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: TextStyles.subtitle),
                if (showSeeAllButton && activities.length > maxActivities)
                  TextButton(
                    onPressed: () {
                      NavigationUtils.navigateToNamed(
                        context,
                        RouteNames.activityHistory,
                      );
                    },
                    child: const Text('See All'),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // Activity cards
            ...activities
                .take(maxActivities)
                .map((activity) => _buildActivityCard(context, activity)),
          ],
        );
      },
    );
  }

  /// Build a card for a single activity
  Widget _buildActivityCard(BuildContext context, RecentActivity activity) {
    // Get icon based on activity type
    final IconData icon = _getActivityIcon(activity.type);

    // Format the timestamp
    final formattedTime = _formatTimestamp(activity.timestamp);

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
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (activity.description != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        activity.description!,
                        style: TextStyles.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
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

  /// Format a timestamp into a human-readable string
  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
    } else {
      return DateFormat('MMM d, yyyy').format(timestamp);
    }
  }
}
