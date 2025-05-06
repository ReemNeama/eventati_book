import 'package:flutter/material.dart';
import 'package:eventati_book/routing/feature_guards.dart';

/// A widget that wraps a child widget and applies feature guards
///
/// This widget can be used to protect routes based on user roles,
/// subscription status, feature flags, booking status, comparison status,
/// or wizard step completion.
///
/// Example usage:
/// ```dart
/// FeatureGuardWrapper(
///   // Require admin or moderator role
///   roleGuard: true,
///   allowedRoles: ['admin', 'moderator'],
///   // Require premium subscription
///   subscriptionGuard: true,
///   // Require a specific feature to be enabled
///   featureGuard: true,
///   requiredFeature: 'premium_comparison',
///   // Require an active booking
///   bookingGuard: true,
///   // Require an active comparison
///   comparisonGuard: true,
///   // Require a specific wizard step
///   wizardStepGuard: true,
///   requiredWizardStep: 3,
///   child: MyProtectedScreen(),
/// )
/// ```
class FeatureGuardWrapper extends StatelessWidget {
  /// The child widget to display if all guards pass
  final Widget child;

  /// Whether to apply the role guard
  final bool roleGuard;

  /// The roles that are allowed to access the route
  final List<String> allowedRoles;

  /// Whether to apply the subscription guard
  final bool subscriptionGuard;

  /// Whether to apply the feature guard
  final bool featureGuard;

  /// The feature that is required to access the route
  final String requiredFeature;

  /// Whether to apply the booking guard
  final bool bookingGuard;

  /// Whether to apply the comparison guard
  final bool comparisonGuard;

  /// Whether to apply the wizard step guard
  final bool wizardStepGuard;

  /// The wizard step that is required to access the route
  final int requiredWizardStep;

  /// Creates a new FeatureGuardWrapper
  const FeatureGuardWrapper({
    super.key,
    required this.child,
    this.roleGuard = false,
    this.allowedRoles = const ['admin'],
    this.subscriptionGuard = false,
    this.featureGuard = false,
    this.requiredFeature = '',
    this.bookingGuard = false,
    this.comparisonGuard = false,
    this.wizardStepGuard = false,
    this.requiredWizardStep = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        // Check role guard
        if (roleGuard && !RoleGuard.canActivate(context, allowedRoles)) {
          // Redirect to unauthorized screen
          WidgetsBinding.instance.addPostFrameCallback((_) {
            RoleGuard.redirectToUnauthorized(context);
          });
          return const SizedBox.shrink();
        }

        // Check subscription guard
        if (subscriptionGuard && !SubscriptionGuard.canActivate(context)) {
          // Redirect to subscription screen
          WidgetsBinding.instance.addPostFrameCallback((_) {
            SubscriptionGuard.redirectToSubscription(context);
          });
          return const SizedBox.shrink();
        }

        // Check feature guard
        if (featureGuard &&
            !FeatureGuard.canActivate(context, requiredFeature)) {
          // Redirect to feature unavailable screen
          WidgetsBinding.instance.addPostFrameCallback((_) {
            FeatureGuard.redirectToFeatureUnavailable(context);
          });
          return const SizedBox.shrink();
        }

        // Check booking guard
        if (bookingGuard && !BookingGuard.canActivate(context)) {
          // Redirect to booking selection screen
          WidgetsBinding.instance.addPostFrameCallback((_) {
            BookingGuard.redirectToBookingSelection(context);
          });
          return const SizedBox.shrink();
        }

        // Check comparison guard
        if (comparisonGuard && !ComparisonGuard.canActivate(context)) {
          // Redirect to comparison selection screen
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ComparisonGuard.redirectToComparisonSelection(context);
          });
          return const SizedBox.shrink();
        }

        // Check wizard step guard
        if (wizardStepGuard &&
            !WizardStepGuard.canActivate(context, requiredWizardStep)) {
          // Redirect to wizard step
          WidgetsBinding.instance.addPostFrameCallback((_) {
            WizardStepGuard.redirectToWizardStep(context, requiredWizardStep);
          });
          return const SizedBox.shrink();
        }

        // All guards passed, show the child
        return child;
      },
    );
  }
}
