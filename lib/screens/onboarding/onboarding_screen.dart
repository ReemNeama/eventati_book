import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:eventati_book/providers/core_providers/onboarding_provider.dart';
import 'package:eventati_book/screens/onboarding/onboarding_page.dart';
import 'package:eventati_book/routing/route_names.dart';
import 'package:eventati_book/routing/route_arguments.dart';
import 'package:eventati_book/utils/ui/accessibility_utils.dart';
import 'package:eventati_book/utils/logger.dart';
import 'package:posthog_flutter/posthog_flutter.dart';

/// Onboarding screen for first-time users
///
/// This screen shows a series of pages introducing the app's features
/// and helps users get started with the app.
class OnboardingScreen extends StatefulWidget {
  /// Creates an OnboardingScreen
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final int _totalPages = 4;

  @override
  void initState() {
    super.initState();
    // Track screen view
    Posthog().screen(
      screenName: 'Onboarding Screen',
      properties: {'first_time': true},
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _completeOnboarding() async {
    try {
      final onboardingProvider = Provider.of<OnboardingProvider>(
        context,
        listen: false,
      );

      final success = await onboardingProvider.completeOnboarding();

      if (success && mounted) {
        // Track completion
        Posthog().capture(
          eventName: 'onboarding_completed',
          properties: {'pages_viewed': _totalPages},
        );

        // Navigate to main navigation
        Navigator.of(context).pushReplacementNamed(
          RouteNames.mainNavigation,
          arguments: MainNavigationArguments(
            toggleTheme: () {
              // This is a placeholder - the actual toggle theme function
              // will be passed from MyApp
            },
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to complete onboarding. Please try again.'),
          ),
        );
      }
    } catch (e) {
      Logger.e('Error completing onboarding: $e', tag: 'OnboardingScreen');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextButton(
                  onPressed: _completeOnboarding,
                  child: const Text('Skip'),
                ),
              ),
            ),

            // Page content
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (int page) {
                  setState(() {
                    _currentPage = page;
                  });

                  // Track page view
                  Posthog().capture(
                    eventName: 'onboarding_page_viewed',
                    properties: {'page_number': page + 1},
                  );
                },
                children: [
                  OnboardingPage(
                    title: 'Welcome to Eventati Book',
                    description:
                        'Your one-stop solution for planning and booking event venues and services.',
                    image: 'assets/images/onboarding/welcome.png',
                    backgroundColor: theme.colorScheme.primary.withAlpha(25),
                  ),
                  OnboardingPage(
                    title: 'Discover Venues',
                    description:
                        'Browse through a wide selection of venues for your special events.',
                    image: 'assets/images/onboarding/venues.png',
                    backgroundColor: theme.colorScheme.secondary.withAlpha(25),
                  ),
                  OnboardingPage(
                    title: 'Plan Your Event',
                    description:
                        'Use our planning tools to manage your guest list, budget, and timeline.',
                    image: 'assets/images/onboarding/planning.png',
                    backgroundColor: theme.colorScheme.tertiary.withAlpha(25),
                  ),
                  OnboardingPage(
                    title: 'Book with Confidence',
                    description:
                        'Secure your bookings with our trusted vendors and payment system.',
                    image: 'assets/images/onboarding/booking.png',
                    backgroundColor: theme.colorScheme.error.withAlpha(25),
                  ),
                ],
              ),
            ),

            // Page indicator
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _totalPages,
                  (index) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4.0),
                    width: 10.0,
                    height: 10.0,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color:
                          _currentPage == index
                              ? theme.colorScheme.primary
                              : theme.colorScheme.primary.withAlpha(76),
                    ),
                  ),
                ),
              ),
            ),

            // Navigation buttons
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back button
                  _currentPage > 0
                      ? TextButton(
                        onPressed: () {
                          AccessibilityUtils.buttonPressHapticFeedback();
                          _previousPage();
                        },
                        child: const Text('Back'),
                      )
                      : const SizedBox(width: 80),

                  // Next/Finish button
                  ElevatedButton(
                    onPressed: () {
                      AccessibilityUtils.buttonPressHapticFeedback();
                      _nextPage();
                    },
                    child: Text(
                      _currentPage < _totalPages - 1 ? 'Next' : 'Get Started',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
