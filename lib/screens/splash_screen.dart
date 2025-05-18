import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:eventati_book/providers/providers.dart';
import 'package:eventati_book/routing/routing.dart';
import 'package:eventati_book/styles/text_styles.dart';
import 'package:eventati_book/utils/utils.dart';
import 'package:eventati_book/utils/logger.dart';
import 'package:eventati_book/widgets/common/loading_indicator.dart';
import 'package:posthog_flutter/posthog_flutter.dart';

/// Splash screen that handles initial app loading and routing
///
/// This screen:
/// 1. Shows a loading indicator while checking authentication status
/// 2. Checks if the user has completed onboarding
/// 3. Redirects to the appropriate screen based on auth and onboarding status
class SplashScreen extends StatefulWidget {
  /// Creates a SplashScreen
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Track screen view
    Posthog().screen(
      screenName: 'Splash Screen',
      properties: {'timestamp': DateTime.now().toIso8601String()},
    );

    // Initialize routing after the first frame is rendered
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeRouting();
    });
  }

  /// Initialize routing based on authentication and onboarding status
  Future<void> _initializeRouting() async {
    try {
      // Get providers
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final onboardingProvider = Provider.of<OnboardingProvider>(
        context,
        listen: false,
      );

      // Wait for providers to initialize
      await Future.delayed(const Duration(seconds: 2));

      // Check if the user is authenticated
      if (authProvider.isAuthenticated) {
        // User is authenticated, check if they've completed onboarding
        if (onboardingProvider.hasCompletedOnboarding) {
          // User has completed onboarding, navigate to main navigation
          if (mounted) {
            NavigationUtils.navigateToNamedAndRemoveUntil(
              context,
              RouteNames.mainNavigation,
              arguments: MainNavigationArguments(
                toggleTheme: () {
                  // This is a placeholder - the actual toggle theme function
                  // will be passed from MyApp
                },
              ),
            );
          }
        } else {
          // User has not completed onboarding, navigate to onboarding
          if (mounted) {
            NavigationUtils.navigateToNamedAndRemoveUntil(
              context,
              RouteNames.onboarding,
            );
          }
        }
      } else {
        // User is not authenticated, navigate to auth screen
        if (mounted) {
          NavigationUtils.navigateToNamedAndRemoveUntil(
            context,
            RouteNames.login,
          );
        }
      }
    } catch (e) {
      Logger.e('Error in splash screen routing: $e', tag: 'SplashScreen');
      // If there's an error, default to the auth screen
      if (mounted) {
        NavigationUtils.navigateToNamedAndRemoveUntil(
          context,
          RouteNames.login,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.primaryColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App logo or name
            Text(
              'Eventati Book',
              style: TextStyles.title.copyWith(
                color: theme.colorScheme.onPrimary,
                fontSize: 40,
              ),
            ),

            const SizedBox(height: 40),

            // Loading indicator
            const LoadingIndicator(message: 'Loading...', size: 40),
          ],
        ),
      ),
    );
  }
}
