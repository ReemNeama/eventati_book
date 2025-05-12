import 'package:flutter/material.dart';
import 'package:eventati_book/services/analytics/analytics_service.dart';

/// A class for tracking navigation events
class RouteAnalytics {
  /// Private constructor to prevent instantiation
  RouteAnalytics._();

  /// Singleton instance
  static final RouteAnalytics _instance = RouteAnalytics._();

  /// Get the singleton instance
  static RouteAnalytics get instance => _instance;

  /// Analytics service
  late final AnalyticsService _analyticsService;

  /// Initialize the analytics service
  void initialize(AnalyticsService analyticsService) {
    _analyticsService = analyticsService;
  }

  /// Get the analytics service
  AnalyticsService get analyticsService => _analyticsService;

  /// List of observers
  final List<RouteObserver<PageRoute>> _observers = [];

  /// Add an observer
  void addObserver(RouteObserver<PageRoute> observer) {
    _observers.add(observer);
  }

  /// Get all observers
  List<RouteObserver<PageRoute>> get observers => _observers;

  /// Track a navigation event
  Future<void> trackNavigation(
    String routeName, {
    Map<String, dynamic>? parameters,
  }) async {
    // Send the event to the analytics service
    await _analyticsService.trackUserAction(
      'navigation',
      parameters: {'route_name': routeName, ...?parameters},
    );
  }

  /// Track a screen view
  Future<void> trackScreenView(
    String screenName, {
    Map<String, dynamic>? parameters,
  }) async {
    // Send the event to the analytics service
    await _analyticsService.trackScreenView(screenName, parameters: parameters);
  }

  /// Track a user action
  Future<void> trackUserAction(
    String action, {
    Map<String, dynamic>? parameters,
  }) async {
    // Send the event to the analytics service
    await _analyticsService.trackUserAction(action, parameters: parameters);
  }
}

/// A route observer that tracks navigation events
class AnalyticsRouteObserver extends RouteObserver<PageRoute<dynamic>> {
  /// The analytics service
  final AnalyticsService _analyticsService;

  /// Creates a new AnalyticsRouteObserver
  ///
  /// If [analyticsService] is not provided, it will be obtained from RouteAnalytics.
  AnalyticsRouteObserver({AnalyticsService? analyticsService})
    : _analyticsService =
          analyticsService ?? RouteAnalytics.instance.analyticsService;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    if (route is PageRoute) {
      _trackScreenView(route);
    }
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    if (newRoute is PageRoute) {
      _trackScreenView(newRoute);
    }
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    if (previousRoute is PageRoute && route is PageRoute) {
      _trackScreenView(previousRoute);
    }
  }

  void _trackScreenView(PageRoute<dynamic> route) {
    final screenName = route.settings.name ?? 'Unknown';
    final arguments = route.settings.arguments;

    // Extract parameters from arguments
    final parameters =
        arguments is Map<String, dynamic>
            ? arguments
            : arguments != null
            ? {'arguments': arguments.toString()}
            : null;

    // Track screen view using analytics service
    _analyticsService.trackScreenView(screenName, parameters: parameters);

    // Also track in RouteAnalytics for consistency
    RouteAnalytics.instance.trackScreenView(screenName, parameters: parameters);
  }
}
