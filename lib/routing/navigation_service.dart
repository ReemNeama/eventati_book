import 'package:flutter/material.dart';

/// Service for navigating without requiring a BuildContext
class NavigationService {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  /// Navigate to a named route
  Future<T?> navigateTo<T>(String routeName, {Object? arguments}) {
    return navigatorKey.currentState!.pushNamed<T>(
      routeName,
      arguments: arguments,
    );
  }

  /// Navigate to a named route and replace the current screen
  Future<T?> navigateToReplacement<T>(String routeName, {Object? arguments}) {
    return navigatorKey.currentState!.pushReplacementNamed<T, dynamic>(
      routeName,
      arguments: arguments,
    );
  }

  /// Navigate to a named route and remove all previous screens
  Future<T?> navigateToAndRemoveUntil<T>(
    String routeName, {
    Object? arguments,
  }) {
    return navigatorKey.currentState!.pushNamedAndRemoveUntil<T>(
      routeName,
      (route) => false,
      arguments: arguments,
    );
  }

  /// Go back to the previous screen
  void goBack<T>([T? result]) {
    return navigatorKey.currentState!.pop<T>(result);
  }

  /// Go back to the previous screen if possible
  void goBackIfCan<T>([T? result]) {
    if (navigatorKey.currentState!.canPop()) {
      navigatorKey.currentState!.pop<T>(result);
    }
  }

  /// Pop until a specific route
  void popUntil(String routeName) {
    navigatorKey.currentState!.popUntil(ModalRoute.withName(routeName));
  }

  /// Pop the current route and push a new named route
  void popAndPushNamed(String routeName, {Object? arguments}) {
    navigatorKey.currentState!.popAndPushNamed(routeName, arguments: arguments);
  }
}
