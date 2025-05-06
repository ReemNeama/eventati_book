import 'package:flutter/material.dart';
import 'package:eventati_book/routing/route_names.dart';
import 'package:eventati_book/providers/providers.dart';
import 'package:provider/provider.dart';

/// A route guard that checks if a user is authenticated
class AuthGuard {
  /// Check if the user is authenticated
  static bool canActivate(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    return authProvider.isAuthenticated;
  }

  /// Redirect to the login screen if the user is not authenticated
  static void redirectToLogin(BuildContext context) {
    Navigator.of(context).pushReplacementNamed(RouteNames.login);
  }

  /// Handle navigation to a protected route
  static bool handleNavigation(BuildContext context) {
    if (!canActivate(context)) {
      redirectToLogin(context);
      return false;
    }
    return true;
  }
}

// Note: The following guards are commented out as they require providers
// that are not yet implemented in the application. They serve as examples
// for future implementation.

/*
/// A route guard that checks if a user has completed the onboarding process
class OnboardingGuard {
  /// Check if the user has completed onboarding
  static bool canActivate(BuildContext context) {
    final onboardingProvider = Provider.of<OnboardingProvider>(
      context,
      listen: false,
    );
    return onboardingProvider.hasCompletedOnboarding;
  }

  /// Redirect to the onboarding screen if the user has not completed onboarding
  static void redirectToOnboarding(BuildContext context) {
    Navigator.of(context).pushReplacementNamed(RouteNames.onboarding);
  }

  /// Handle navigation to a route that requires onboarding
  static bool handleNavigation(BuildContext context) {
    if (!canActivate(context)) {
      redirectToOnboarding(context);
      return false;
    }
    return true;
  }
}

/// A route guard that checks if a user has an active event
class EventGuard {
  /// Check if the user has an active event
  static bool canActivate(BuildContext context) {
    final eventProvider = Provider.of<EventProvider>(context, listen: false);
    return eventProvider.hasActiveEvent;
  }

  /// Redirect to the event selection screen if the user has no active event
  static void redirectToEventSelection(BuildContext context) {
    Navigator.of(context).pushReplacementNamed(RouteNames.eventSelection);
  }

  /// Handle navigation to a route that requires an active event
  static bool handleNavigation(BuildContext context) {
    if (!canActivate(context)) {
      redirectToEventSelection(context);
      return false;
    }
    return true;
  }
}
*/
