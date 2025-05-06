import 'package:flutter/material.dart';
import 'package:eventati_book/routing/route_names.dart';
import 'package:eventati_book/utils/ui/navigation_utils.dart';

/// Screen displayed when a user tries to access a route they don't have permission for
class UnauthorizedScreen extends StatelessWidget {
  /// Creates a new UnauthorizedScreen
  const UnauthorizedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Unauthorized')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock, size: 80, color: theme.colorScheme.error),
              const SizedBox(height: 24),
              Text(
                'Access Denied',
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: theme.colorScheme.error,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'You don\'t have permission to access this page. Please contact an administrator if you believe this is an error.',
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
