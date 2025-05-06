import 'package:flutter/material.dart';

/// A class for tracking navigation events
class RouteAnalytics {
  /// Private constructor to prevent instantiation
  RouteAnalytics._();

  /// Singleton instance
  static final RouteAnalytics _instance = RouteAnalytics._();

  /// Get the singleton instance
  static RouteAnalytics get instance => _instance;

  /// List of observers
  final List<RouteObserver<PageRoute>> _observers = [];

  /// Add an observer
  void addObserver(RouteObserver<PageRoute> observer) {
    _observers.add(observer);
  }

  /// Get all observers
  List<RouteObserver<PageRoute>> get observers => _observers;

  /// Track a navigation event
  void trackNavigation(String routeName, {Map<String, dynamic>? parameters}) {
    // In a real app, this would send the event to an analytics service
    // For now, we'll just log to the console in debug mode
    debugPrint('Navigation event: $routeName, parameters: $parameters');
  }

  /// Track a screen view
  void trackScreenView(String screenName, {Map<String, dynamic>? parameters}) {
    // In a real app, this would send the event to an analytics service
    // For now, we'll just log to the console in debug mode
    debugPrint('Screen view: $screenName, parameters: $parameters');
  }

  /// Track a user action
  void trackUserAction(String action, {Map<String, dynamic>? parameters}) {
    // In a real app, this would send the event to an analytics service
    // For now, we'll just log to the console in debug mode
    debugPrint('User action: $action, parameters: $parameters');
  }
}

/// A route observer that tracks navigation events
class AnalyticsRouteObserver extends RouteObserver<PageRoute<dynamic>> {
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

    RouteAnalytics.instance.trackScreenView(
      screenName,
      parameters:
          arguments is Map<String, dynamic>
              ? arguments
              : arguments != null
              ? {'arguments': arguments.toString()}
              : null,
    );
  }
}
