import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:eventati_book/services/analytics/analytics_service.dart';

/// A class for optimizing routing performance
///
/// This class provides methods for optimizing the performance of the routing system,
/// such as route caching, lazy loading, and performance monitoring.
class RoutePerformance {
  /// Private constructor to prevent instantiation
  RoutePerformance._();

  /// Singleton instance
  static final RoutePerformance _instance = RoutePerformance._();

  /// Get the singleton instance
  static RoutePerformance get instance => _instance;

  /// Analytics service for tracking performance metrics
  late final AnalyticsService _analyticsService;

  /// Cache of routes
  final Map<String, Widget> _routeCache = {};

  /// Cache of route transitions
  final Map<String, PageRouteBuilder> _transitionCache = {};

  /// Performance metrics
  final Map<String, List<double>> _navigationTimes = {};

  /// Initialize the route performance service
  void initialize(AnalyticsService analyticsService) {
    _analyticsService = analyticsService;
  }

  /// Get a cached route
  ///
  /// If the route is not in the cache, the builder function is called to create it.
  /// Note: This method requires a BuildContext to be passed to the builder function.
  Widget getCachedRoute(String routeName, Widget Function() builder) {
    if (!_routeCache.containsKey(routeName)) {
      _routeCache[routeName] = builder();
    }
    return _routeCache[routeName]!;
  }

  /// Clear the route cache
  void clearRouteCache() {
    _routeCache.clear();
  }

  /// Remove a route from the cache
  void removeFromCache(String routeName) {
    _routeCache.remove(routeName);
  }

  /// Get a cached transition
  ///
  /// If the transition is not in the cache, a new one is created.
  PageRouteBuilder getCachedTransition(
    String routeName,
    Widget page, {
    Duration transitionDuration = const Duration(milliseconds: 300),
    bool opaque = true,
    bool barrierDismissible = false,
    Color? barrierColor,
    String? barrierLabel,
    bool maintainState = true,
    bool fullscreenDialog = false,
  }) {
    if (!_transitionCache.containsKey(routeName)) {
      _transitionCache[routeName] = PageRouteBuilder(
        settings: RouteSettings(name: routeName),
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: transitionDuration,
        opaque: opaque,
        barrierDismissible: barrierDismissible,
        barrierColor: barrierColor,
        barrierLabel: barrierLabel,
        maintainState: maintainState,
        fullscreenDialog: fullscreenDialog,
      );
    }
    return _transitionCache[routeName]!;
  }

  /// Clear the transition cache
  void clearTransitionCache() {
    _transitionCache.clear();
  }

  /// Start tracking navigation time
  void startNavigationTimer(String routeName) {
    if (!_navigationTimes.containsKey(routeName)) {
      _navigationTimes[routeName] = [];
    }
    _navigationTimes[routeName]!.add(
      DateTime.now().millisecondsSinceEpoch.toDouble(),
    );
  }

  /// End tracking navigation time
  void endNavigationTimer(String routeName) {
    if (_navigationTimes.containsKey(routeName) &&
        _navigationTimes[routeName]!.isNotEmpty) {
      final startTime = _navigationTimes[routeName]!.last;
      final endTime = DateTime.now().millisecondsSinceEpoch.toDouble();
      final duration = endTime - startTime;

      // Replace the start time with the duration
      _navigationTimes[routeName]![_navigationTimes[routeName]!.length - 1] =
          duration;

      // Track the navigation time
      _analyticsService.trackUserAction(
        'navigation_performance',
        parameters: {'route_name': routeName, 'duration_ms': duration},
      );

      // Log in debug mode
      if (kDebugMode) {
        print(
          '🚀 Navigation to $routeName took ${duration.toStringAsFixed(2)}ms',
        );
      }
    }
  }

  /// Get the average navigation time for a route
  double getAverageNavigationTime(String routeName) {
    if (!_navigationTimes.containsKey(routeName) ||
        _navigationTimes[routeName]!.isEmpty) {
      return 0;
    }

    final times = _navigationTimes[routeName]!;
    final sum = times.reduce((a, b) => a + b);
    return sum / times.length;
  }

  /// Get the navigation times for a route
  List<double> getNavigationTimes(String routeName) {
    if (!_navigationTimes.containsKey(routeName)) {
      return [];
    }
    return List.from(_navigationTimes[routeName]!);
  }

  /// Clear the navigation times
  void clearNavigationTimes() {
    _navigationTimes.clear();
  }

  /// Get the routes with the slowest navigation times
  List<MapEntry<String, double>> getSlowestRoutes({int limit = 5}) {
    final averages = <String, double>{};

    for (final entry in _navigationTimes.entries) {
      if (entry.value.isNotEmpty) {
        final sum = entry.value.reduce((a, b) => a + b);
        averages[entry.key] = sum / entry.value.length;
      }
    }

    final sortedEntries =
        averages.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

    return sortedEntries.take(limit).toList();
  }

  /// Get performance metrics for all routes
  Map<String, Map<String, dynamic>> getPerformanceMetrics() {
    final metrics = <String, Map<String, dynamic>>{};

    for (final entry in _navigationTimes.entries) {
      if (entry.value.isNotEmpty) {
        final times = entry.value;
        final sum = times.reduce((a, b) => a + b);
        final average = sum / times.length;
        final min = times.reduce((a, b) => a < b ? a : b);
        final max = times.reduce((a, b) => a > b ? a : b);

        metrics[entry.key] = {
          'average_ms': average,
          'min_ms': min,
          'max_ms': max,
          'count': times.length,
        };
      }
    }

    return metrics;
  }

  /// Track a route transition
  void trackTransition(String routeName, Duration duration) {
    _analyticsService.trackUserAction(
      'route_transition',
      parameters: {
        'route_name': routeName,
        'duration_ms': duration.inMilliseconds,
      },
    );
  }
}
