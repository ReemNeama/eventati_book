import 'package:flutter/material.dart';
import 'package:eventati_book/routing/route_names.dart';
import 'package:eventati_book/utils/ui/navigation_utils.dart';

/// Screen displayed when a user tries to access a feature that is not available
class FeatureUnavailableScreen extends StatelessWidget {
  /// Creates a new FeatureUnavailableScreen
  const FeatureUnavailableScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Feature Unavailable')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.construction,
                size: 80,
                color: theme.colorScheme.secondary,
              ),
              const SizedBox(height: 24),
              Text(
                'Feature Unavailable',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'This feature is currently unavailable. It may be under development or temporarily disabled.',
                style: theme.textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  NavigationUtils.navigateToNamedAndRemoveUntil(
                    context,
                    RouteNames.home,
                  );
                },
                child: const Text('Go to Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
