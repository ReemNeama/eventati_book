import 'package:flutter/material.dart';
import 'package:eventati_book/routing/route_guards.dart';

/// A widget that wraps a screen and applies route guards
///
/// This widget checks if the user meets the requirements to access the screen.
/// If not, it redirects them to the appropriate screen.
///
/// Usage example:
/// ```dart
/// RouteGuardWrapper(
///   authGuard: true,
///   onboardingGuard: true,
///   eventGuard: true,
///   child: MyProtectedScreen(),
/// )
/// ```
class RouteGuardWrapper extends StatefulWidget {
  /// The child widget to display if all guards pass
  final Widget child;

  /// Whether to apply the authentication guard
  final bool authGuard;

  /// Whether to apply the onboarding guard
  final bool onboardingGuard;

  /// Whether to apply the event guard
  final bool eventGuard;

  /// Creates a new RouteGuardWrapper
  const RouteGuardWrapper({
    super.key,
    required this.child,
    this.authGuard = false,
    this.onboardingGuard = false,
    this.eventGuard = false,
  });

  @override
  State<RouteGuardWrapper> createState() => _RouteGuardWrapperState();
}

class _RouteGuardWrapperState extends State<RouteGuardWrapper> {
  bool _checkingGuards = true;
  bool _guardsPass = true;

  @override
  void initState() {
    super.initState();
    // Check guards after the first frame is rendered
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkGuards();
    });
  }

  /// Check if all guards pass
  void _checkGuards() {
    if (widget.authGuard && !AuthGuard.canActivate(context)) {
      AuthGuard.redirectToLogin(context);
      setState(() {
        _guardsPass = false;
        _checkingGuards = false;
      });
      return;
    }

    if (widget.onboardingGuard && !OnboardingGuard.canActivate(context)) {
      OnboardingGuard.redirectToOnboarding(context);
      setState(() {
        _guardsPass = false;
        _checkingGuards = false;
      });
      return;
    }

    if (widget.eventGuard && !EventGuard.canActivate(context)) {
      EventGuard.redirectToEventSelection(context);
      setState(() {
        _guardsPass = false;
        _checkingGuards = false;
      });
      return;
    }

    setState(() {
      _guardsPass = true;
      _checkingGuards = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Show loading indicator while checking guards
    if (_checkingGuards) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Show child if guards pass
    if (_guardsPass) {
      return widget.child;
    }

    // Show empty container if guards don't pass (we've already redirected)
    return Container();
  }
}
