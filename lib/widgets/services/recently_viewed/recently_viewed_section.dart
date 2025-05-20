import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:eventati_book/models/models.dart';
import 'package:eventati_book/providers/providers.dart';
import 'package:eventati_book/styles/text_styles.dart';
import 'package:eventati_book/utils/utils.dart';
import 'package:eventati_book/widgets/services/card/service_mini_card.dart';
import 'package:eventati_book/routing/routing.dart';
import 'package:eventati_book/widgets/common/empty_state.dart';
import 'package:eventati_book/widgets/common/loading_indicator.dart';

/// A widget that displays recently viewed services in a horizontal scrollable list
class RecentlyViewedSection extends StatelessWidget {
  /// The title of the section
  final String title;

  /// The maximum number of services to display
  final int maxServices;

  /// Whether to show the "See All" button
  final bool showSeeAllButton;

  /// Constructor
  const RecentlyViewedSection({
    super.key,
    this.title = 'Recently Viewed',
    this.maxServices = 5,
    this.showSeeAllButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<RecentActivityProvider>(
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
          return const SizedBox.shrink(); // Don't show anything if no recently viewed services
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section title and See All button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(title, style: TextStyles.sectionTitle),
                  if (showSeeAllButton &&
                      recentlyViewedServices.length > maxServices)
                    TextButton(
                      onPressed: () {
                        NavigationUtils.navigateToNamed(
                          context,
                          RouteNames.recentlyViewedServices,
                        );
                      },
                      child: const Text('See All'),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Horizontal list of recently viewed services
            SizedBox(
              height: 180, // Fixed height for the horizontal list
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                itemCount:
                    recentlyViewedServices.length > maxServices
                        ? maxServices
                        : recentlyViewedServices.length,
                itemBuilder: (context, index) {
                  final activity = recentlyViewedServices[index];
                  return _buildServiceCard(context, activity);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  /// Builds a service card for a recently viewed service
  Widget _buildServiceCard(BuildContext context, RecentActivity activity) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: ServiceMiniCard(
        title: activity.title,
        subtitle: activity.description ?? '',
        imageUrl: null, // We don't have the image URL in the activity
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
        timestamp: activity.timestamp,
      ),
    );
  }
}
