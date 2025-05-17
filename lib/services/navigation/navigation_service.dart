import 'package:flutter/material.dart';
import 'package:eventati_book/services/analytics_service.dart';
import 'package:eventati_book/utils/logger.dart';

/// Service for handling navigation in the application
class NavigationService {
  /// Global key for the navigator
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  /// Analytics service for tracking navigation events
  final AnalyticsService _analyticsService;

  /// Constructor
  NavigationService({AnalyticsService? analyticsService})
    : _analyticsService = analyticsService ?? AnalyticsService();

  /// Get the current navigator state
  NavigatorState? get _navigator => navigatorKey.currentState;

  /// Navigate to a named route
  Future<dynamic> navigateTo(
    String routeName, {
    Map<String, dynamic>? arguments,
    bool replace = false,
    bool clearStack = false,
  }) async {
    try {
      // Track the navigation event
      _analyticsService.trackNavigation(routeName, arguments: arguments);

      Logger.i('Navigating to $routeName', tag: 'NavigationService');

      if (clearStack) {
        // Clear the navigation stack and navigate to the route
        return _navigator?.pushNamedAndRemoveUntil(
          routeName,
          (route) => false,
          arguments: arguments,
        );
      } else if (replace) {
        // Replace the current route with the new route
        return _navigator?.pushReplacementNamed(
          routeName,
          arguments: arguments,
        );
      } else {
        // Navigate to the route
        return _navigator?.pushNamed(routeName, arguments: arguments);
      }
    } catch (e) {
      Logger.e('Error navigating to $routeName: $e', tag: 'NavigationService');
      return null;
    }
  }

  /// Navigate back
  void goBack({dynamic result}) {
    try {
      if (_navigator?.canPop() ?? false) {
        _navigator?.pop(result);
        Logger.i('Navigated back', tag: 'NavigationService');
      } else {
        Logger.w(
          'Cannot navigate back - no routes to pop',
          tag: 'NavigationService',
        );
      }
    } catch (e) {
      Logger.e('Error navigating back: $e', tag: 'NavigationService');
    }
  }

  /// Navigate to a route and remove all routes until a specific route
  Future<dynamic> navigateToAndRemoveUntil(
    String routeName,
    String untilRouteName, {
    Map<String, dynamic>? arguments,
  }) async {
    try {
      // Track the navigation event
      _analyticsService.trackNavigation(routeName, arguments: arguments);

      Logger.i(
        'Navigating to $routeName and removing until $untilRouteName',
        tag: 'NavigationService',
      );

      return _navigator?.pushNamedAndRemoveUntil(
        routeName,
        ModalRoute.withName(untilRouteName),
        arguments: arguments,
      );
    } catch (e) {
      Logger.e('Error navigating to $routeName: $e', tag: 'NavigationService');
      return null;
    }
  }

  /// Navigate to a route and remove all routes until a predicate is satisfied
  Future<dynamic> navigateToAndRemoveUntilPredicate(
    String routeName,
    RoutePredicate predicate, {
    Map<String, dynamic>? arguments,
  }) async {
    try {
      // Track the navigation event
      _analyticsService.trackNavigation(routeName, arguments: arguments);

      Logger.i(
        'Navigating to $routeName with predicate',
        tag: 'NavigationService',
      );

      return _navigator?.pushNamedAndRemoveUntil(
        routeName,
        predicate,
        arguments: arguments,
      );
    } catch (e) {
      Logger.e('Error navigating to $routeName: $e', tag: 'NavigationService');
      return null;
    }
  }

  /// Navigate to a route with a fade transition
  Future<dynamic> navigateWithFadeTransition(
    String routeName, {
    Map<String, dynamic>? arguments,
    Duration duration = const Duration(milliseconds: 300),
  }) async {
    try {
      // Track the navigation event
      _analyticsService.trackNavigation(routeName, arguments: arguments);

      Logger.i(
        'Navigating to $routeName with fade transition',
        tag: 'NavigationService',
      );

      return _navigator?.push(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) {
            final Widget page = _buildPageForRoute(routeName, arguments);
            return FadeTransition(opacity: animation, child: page);
          },
          transitionDuration: duration,
          settings: RouteSettings(name: routeName, arguments: arguments),
        ),
      );
    } catch (e) {
      Logger.e('Error navigating to $routeName: $e', tag: 'NavigationService');
      return null;
    }
  }

  /// Build a page for a route
  Widget _buildPageForRoute(String routeName, Map<String, dynamic>? arguments) {
    // This is a placeholder implementation
    // In a real app, you would use a route generator or a router to build the page
    return Center(child: Text('Route not implemented: $routeName'));
  }
}
