import 'package:flutter/material.dart';

/// Utility functions for navigation-related operations
class NavigationUtils {
  /// Navigate to a screen
  static Future<T?> navigateTo<T>(BuildContext context, Widget screen) {
    return Navigator.push<T>(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }

  /// Navigate to a screen and replace the current screen
  static Future<T?> navigateToReplacement<T>(BuildContext context, Widget screen) {
    return Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }

  /// Navigate to a screen and remove all previous screens
  static Future<T?> navigateAndRemoveUntil<T>(BuildContext context, Widget screen) {
    return Navigator.pushAndRemoveUntil<T>(
      context,
      MaterialPageRoute(builder: (context) => screen),
      (route) => false,
    );
  }

  /// Navigate to a named route
  static Future<T?> navigateToNamed<T>(BuildContext context, String routeName, {Object? arguments}) {
    return Navigator.pushNamed<T>(
      context,
      routeName,
      arguments: arguments,
    );
  }

  /// Navigate to a named route and replace the current screen
  static Future<T?> navigateToNamedReplacement<T>(BuildContext context, String routeName, {Object? arguments}) {
    return Navigator.pushReplacementNamed<T, dynamic>(
      context,
      routeName,
      arguments: arguments,
    );
  }

  /// Navigate to a named route and remove all previous screens
  static Future<T?> navigateToNamedAndRemoveUntil<T>(BuildContext context, String routeName, {Object? arguments}) {
    return Navigator.pushNamedAndRemoveUntil<T>(
      context,
      routeName,
      (route) => false,
      arguments: arguments,
    );
  }

  /// Pop the current screen
  static void pop<T>(BuildContext context, [T? result]) {
    Navigator.pop(context, result);
  }

  /// Pop the current screen if it can be popped
  static void popIfCan<T>(BuildContext context, [T? result]) {
    if (Navigator.canPop(context)) {
      Navigator.pop(context, result);
    }
  }

  /// Pop until a specific route
  static void popUntil(BuildContext context, String routeName) {
    Navigator.popUntil(context, ModalRoute.withName(routeName));
  }

  /// Get the current route name
  static String? getCurrentRouteName(BuildContext context) {
    return ModalRoute.of(context)?.settings.name;
  }

  /// Get arguments passed to the current route
  static T? getRouteArguments<T>(BuildContext context) {
    return ModalRoute.of(context)?.settings.arguments as T?;
  }

  /// Check if the current route is the first route
  static bool isFirstRoute(BuildContext context) {
    return !Navigator.canPop(context);
  }

  /// Handle back button press
  static Future<bool> handleBackButton(BuildContext context) async {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
      return false;
    }
    return true;
  }
}
