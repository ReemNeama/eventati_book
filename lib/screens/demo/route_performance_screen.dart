import 'package:flutter/material.dart';
import 'package:eventati_book/routing/route_performance.dart';
import 'package:eventati_book/routing/route_names.dart';
import 'package:eventati_book/utils/ui/navigation_utils.dart';

/// A screen that displays route performance metrics
class RoutePerformanceScreen extends StatefulWidget {
  /// Creates a new RoutePerformanceScreen
  const RoutePerformanceScreen({super.key});

  @override
  State<RoutePerformanceScreen> createState() => _RoutePerformanceScreenState();
}

class _RoutePerformanceScreenState extends State<RoutePerformanceScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final metrics = RoutePerformance.instance.getPerformanceMetrics();
    final slowestRoutes = RoutePerformance.instance.getSlowestRoutes(limit: 5);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Route Performance'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                // Refresh the metrics
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              _showClearConfirmationDialog(context);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Route Performance Metrics',
              style: theme.textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'This screen displays performance metrics for routes in the app.',
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),

            // Slowest Routes Section
            _buildSection(
              context,
              title: 'Slowest Routes',
              description: 'The 5 slowest routes in the app.',
              child:
                  slowestRoutes.isEmpty
                      ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text(
                            'No route performance data available. Navigate to some screens to collect data.',
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                      : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: slowestRoutes.length,
                        itemBuilder: (context, index) {
                          final route = slowestRoutes[index];
                          return _buildRoutePerformanceItem(
                            context,
                            routeName: route.key,
                            averageTime: route.value,
                            index: index + 1,
                          );
                        },
                      ),
            ),

            const SizedBox(height: 24),

            // All Routes Section
            _buildSection(
              context,
              title: 'All Routes',
              description: 'Performance metrics for all routes.',
              child:
                  metrics.isEmpty
                      ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text(
                            'No route performance data available. Navigate to some screens to collect data.',
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                      : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: metrics.length,
                        itemBuilder: (context, index) {
                          final entry = metrics.entries.elementAt(index);
                          return _buildRouteMetricsItem(
                            context,
                            routeName: entry.key,
                            metrics: entry.value,
                          );
                        },
                      ),
            ),

            const SizedBox(height: 24),

            // Test Routes Section
            _buildSection(
              context,
              title: 'Test Routes',
              description: 'Navigate to these routes to test performance.',
              child: Column(
                children: [
                  _buildTestRouteButton(context, 'Home', () {
                    NavigationUtils.navigateToNamed(context, RouteNames.home);
                  }),
                  _buildTestRouteButton(context, 'Profile', () {
                    NavigationUtils.navigateToNamed(
                      context,
                      RouteNames.profile,
                    );
                  }),
                  _buildTestRouteButton(context, 'Feature Guard Demo', () {
                    NavigationUtils.navigateToNamed(
                      context,
                      RouteNames.featureGuardDemo,
                    );
                  }),
                  _buildTestRouteButton(context, 'Unauthorized', () {
                    NavigationUtils.navigateToNamed(
                      context,
                      RouteNames.unauthorized,
                    );
                  }),
                  _buildTestRouteButton(context, 'Subscription', () {
                    NavigationUtils.navigateToNamed(
                      context,
                      RouteNames.subscription,
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required String description,
    required Widget child,
  }) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(description, style: theme.textTheme.bodyMedium),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildRoutePerformanceItem(
    BuildContext context, {
    required String routeName,
    required double averageTime,
    required int index,
  }) {
    final theme = Theme.of(context);

    // Determine color based on performance
    Color performanceColor;
    if (averageTime < 100) {
      performanceColor = Colors.green;
    } else if (averageTime < 300) {
      performanceColor = Colors.orange;
    } else {
      performanceColor = Colors.red;
    }

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: theme.colorScheme.primary,
        child: Text(
          index.toString(),
          style: TextStyle(
            color: theme.colorScheme.onPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      title: Text(routeName),
      subtitle: Text('Average: ${averageTime.toStringAsFixed(2)}ms'),
      trailing: Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          color: performanceColor,
          shape: BoxShape.circle,
        ),
      ),
      onTap: () {
        _showRoutePerformanceDetails(context, routeName);
      },
    );
  }

  Widget _buildRouteMetricsItem(
    BuildContext context, {
    required String routeName,
    required Map<String, dynamic> metrics,
  }) {
    // Determine color based on performance
    final averageTime = metrics['average_ms'] as double;
    Color performanceColor;
    if (averageTime < 100) {
      performanceColor = Colors.green;
    } else if (averageTime < 300) {
      performanceColor = Colors.orange;
    } else {
      performanceColor = Colors.red;
    }

    return ExpansionTile(
      title: Text(routeName),
      subtitle: Text('Average: ${averageTime.toStringAsFixed(2)}ms'),
      leading: Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          color: performanceColor,
          shape: BoxShape.circle,
        ),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Column(
            children: [
              _buildMetricRow(
                context,
                label: 'Min',
                value: '${(metrics['min_ms'] as double).toStringAsFixed(2)}ms',
              ),
              _buildMetricRow(
                context,
                label: 'Max',
                value: '${(metrics['max_ms'] as double).toStringAsFixed(2)}ms',
              ),
              _buildMetricRow(
                context,
                label: 'Count',
                value: '${metrics['count']}',
              ),
            ],
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: () {
                _showRoutePerformanceDetails(context, routeName);
              },
              child: const Text('View Details'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricRow(
    BuildContext context, {
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
        ],
      ),
    );
  }

  Widget _buildTestRouteButton(
    BuildContext context,
    String label,
    VoidCallback onPressed,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
        child: Text(label),
      ),
    );
  }

  void _showRoutePerformanceDetails(BuildContext context, String routeName) {
    final times = RoutePerformance.instance.getNavigationTimes(routeName);

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Route: $routeName'),
            content: SizedBox(
              width: double.maxFinite,
              child:
                  times.isEmpty
                      ? const Center(
                        child: Text('No performance data available.'),
                      )
                      : ListView.builder(
                        shrinkWrap: true,
                        itemCount: times.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text('Navigation ${index + 1}'),
                            subtitle: Text(
                              '${times[index].toStringAsFixed(2)}ms',
                            ),
                          );
                        },
                      ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }

  void _showClearConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Clear Performance Data'),
            content: const Text(
              'Are you sure you want to clear all route performance data?',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  RoutePerformance.instance.clearNavigationTimes();
                  Navigator.of(context).pop();
                  setState(() {});
                },
                child: const Text('Clear'),
              ),
            ],
          ),
    );
  }
}
