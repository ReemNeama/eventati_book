import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:eventati_book/models/models.dart';
import 'package:eventati_book/providers/providers.dart';
import 'package:eventati_book/styles/app_colors.dart';
import 'package:eventati_book/styles/app_colors_dark.dart';
import 'package:eventati_book/styles/text_styles.dart';
import 'package:eventati_book/utils/utils.dart';
import 'package:eventati_book/widgets/common/empty_state.dart';
import 'package:eventati_book/widgets/common/loading_indicator.dart';
import 'package:eventati_book/widgets/responsive/responsive.dart';

/// A screen that displays all recently viewed services
class RecentlyViewedScreen extends StatelessWidget {
  /// Constructor
  const RecentlyViewedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = UIUtils.isDarkMode(context);
    final Color primaryColor =
        isDarkMode ? AppColorsDark.primary : AppColors.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recently Viewed'),
        backgroundColor: primaryColor,
        actions: [
          // Clear history button
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Clear history',
            onPressed: () => _showClearHistoryDialog(context),
          ),
        ],
      ),
      body: Consumer<RecentActivityProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const LoadingIndicator(
              message: 'Loading recently viewed services...',
            );
          }

          if (provider.errorMessage != null) {
            return EmptyState(
              icon: Icons.error_outline,
              title: 'Error',
              message: provider.errorMessage!,
            );
          }

          // Filter activities to only show viewed services
          final recentlyViewedServices =
              provider.recentActivities
                  .where(
                    (activity) => activity.type == ActivityType.viewedService,
                  )
                  .toList();

          if (recentlyViewedServices.isEmpty) {
            return const EmptyState(
              icon: Icons.visibility_off,
              title: 'No Recently Viewed Services',
              message: 'Services you view will appear here',
            );
          }

          return ResponsiveBuilder(
            // Mobile layout (portrait phones)
            mobileBuilder: (context, constraints) {
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: recentlyViewedServices.length,
                itemBuilder: (context, index) {
                  final activity = recentlyViewedServices[index];
                  return _buildServiceCard(context, activity);
                },
              );
            },
            // Tablet layout (landscape phones and tablets)
            tabletBuilder: (context, constraints) {
              return GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.5,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: recentlyViewedServices.length,
                itemBuilder: (context, index) {
                  final activity = recentlyViewedServices[index];
                  return _buildServiceCard(context, activity);
                },
              );
            },
            // Desktop layout (large tablets and desktops)
            desktopBuilder: (context, constraints) {
              return GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 1.5,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: recentlyViewedServices.length,
                itemBuilder: (context, index) {
                  final activity = recentlyViewedServices[index];
                  return _buildServiceCard(context, activity);
                },
              );
            },
          );
        },
      ),
    );
  }

  /// Builds a service card for a recently viewed service
  Widget _buildServiceCard(BuildContext context, RecentActivity activity) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          // Navigate to the service details if route is available
          if (activity.route != null) {
            NavigationUtils.navigateToNamed(
              context,
              activity.route!,
              arguments: activity.routeParams,
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(
                activity.title,
                style: TextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 8),

              // Description
              if (activity.description != null) ...[
                Text(
                  activity.description!,
                  style: TextStyles.bodyMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
              ],

              // Timestamp
              Text(
                'Viewed on ${DateTimeUtils.formatDateTime(activity.timestamp)}',
                style: TextStyles.caption,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Shows a dialog to confirm clearing the recently viewed history
  void _showClearHistoryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Clear History'),
            content: const Text(
              'Are you sure you want to clear your recently viewed history?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  // Clear the history
                  final provider = Provider.of<RecentActivityProvider>(
                    context,
                    listen: false,
                  );
                  final authProvider = Provider.of<AuthProvider>(
                    context,
                    listen: false,
                  );

                  if (authProvider.user != null) {
                    provider.clearRecentlyViewedHistory(authProvider.user!.id);
                  }

                  Navigator.pop(context);
                },
                child: const Text('Clear'),
              ),
            ],
          ),
    );
  }
}
