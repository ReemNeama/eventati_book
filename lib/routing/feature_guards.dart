import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:eventati_book/providers/providers.dart';
import 'package:eventati_book/routing/route_names.dart';
import 'package:eventati_book/utils/ui/navigation_utils.dart';

/// A guard that checks if a user has a specific role
class RoleGuard {
  /// Check if the user has the required role
  static bool canActivate(BuildContext context, List<String> allowedRoles) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    return authProvider.isAuthenticated &&
        allowedRoles.contains(authProvider.currentUser?.role);
  }

  /// Redirect to the unauthorized screen if the user doesn't have the required role
  static void redirectToUnauthorized(BuildContext context) {
    NavigationUtils.navigateToNamedReplacement(
      context,
      RouteNames.unauthorized,
    );
  }

  /// Handle navigation to a route that requires a specific role
  static bool handleNavigation(
    BuildContext context,
    List<String> allowedRoles,
  ) {
    if (!canActivate(context, allowedRoles)) {
      redirectToUnauthorized(context);
      return false;
    }
    return true;
  }
}

/// A guard that checks if a user has a premium subscription
class SubscriptionGuard {
  /// Check if the user has a premium subscription
  static bool canActivate(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    return authProvider.isAuthenticated &&
        authProvider.currentUser?.hasPremiumSubscription == true;
  }

  /// Redirect to the subscription screen if the user doesn't have a premium subscription
  static void redirectToSubscription(BuildContext context) {
    NavigationUtils.navigateToNamedReplacement(
      context,
      RouteNames.subscription,
    );
  }

  /// Handle navigation to a route that requires a premium subscription
  static bool handleNavigation(BuildContext context) {
    if (!canActivate(context)) {
      redirectToSubscription(context);
      return false;
    }
    return true;
  }
}

/// A guard that checks if a feature is enabled
class FeatureGuard {
  /// Check if the feature is enabled
  static bool canActivate(BuildContext context, String featureKey) {
    final featureProvider = Provider.of<FeatureProvider>(
      context,
      listen: false,
    );
    return featureProvider.isFeatureEnabled(featureKey);
  }

  /// Redirect to the feature unavailable screen if the feature is not enabled
  static void redirectToFeatureUnavailable(BuildContext context) {
    NavigationUtils.navigateToNamedReplacement(
      context,
      RouteNames.featureUnavailable,
    );
  }

  /// Handle navigation to a route that requires a specific feature
  static bool handleNavigation(BuildContext context, String featureKey) {
    if (!canActivate(context, featureKey)) {
      redirectToFeatureUnavailable(context);
      return false;
    }
    return true;
  }
}

/// A guard that checks if a booking is in progress
class BookingGuard {
  /// Check if a booking is in progress
  static bool canActivate(BuildContext context) {
    // Mock implementation - in a real app, this would check if there's an active booking
    return true;
  }

  /// Redirect to the booking selection screen if no booking is in progress
  static void redirectToBookingSelection(BuildContext context) {
    NavigationUtils.navigateToNamedReplacement(
      context,
      RouteNames.bookingSelection,
    );
  }

  /// Handle navigation to a route that requires an active booking
  static bool handleNavigation(BuildContext context) {
    if (!canActivate(context)) {
      redirectToBookingSelection(context);
      return false;
    }
    return true;
  }
}

/// A guard that checks if a comparison is in progress
class ComparisonGuard {
  /// Check if a comparison is in progress
  static bool canActivate(BuildContext context) {
    // Mock implementation - in a real app, this would check if there's an active comparison
    return true;
  }

  /// Redirect to the comparison selection screen if no comparison is in progress
  static void redirectToComparisonSelection(BuildContext context) {
    NavigationUtils.navigateToNamedReplacement(
      context,
      RouteNames.comparisonSelection,
    );
  }

  /// Handle navigation to a route that requires an active comparison
  static bool handleNavigation(BuildContext context) {
    if (!canActivate(context)) {
      redirectToComparisonSelection(context);
      return false;
    }
    return true;
  }
}

/// A guard that checks if a user has completed a specific step in a wizard
class WizardStepGuard {
  /// Check if the user has completed the required step
  static bool canActivate(BuildContext context, int requiredStep) {
    // Mock implementation - in a real app, this would check the current step
    return true;
  }

  /// Redirect to the appropriate wizard step if the user hasn't completed the required step
  static void redirectToWizardStep(BuildContext context, int requiredStep) {
    NavigationUtils.navigateToNamedReplacement(
      context,
      RouteNames.wizard,
      arguments: {'step': 1}, // Mock implementation
    );
  }

  /// Handle navigation to a route that requires a specific wizard step
  static bool handleNavigation(BuildContext context, int requiredStep) {
    if (!canActivate(context, requiredStep)) {
      redirectToWizardStep(context, requiredStep);
      return false;
    }
    return true;
  }
}
