import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:eventati_book/providers/providers.dart';
import 'package:eventati_book/routing/route_names.dart';
import 'package:eventati_book/utils/ui/navigation_utils.dart';

/// Screen displayed when a user tries to access a premium feature without a subscription
class SubscriptionScreen extends StatelessWidget {
  /// Creates a new SubscriptionScreen
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Premium Subscription')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              Icon(Icons.star, size: 80, color: theme.colorScheme.primary),
              const SizedBox(height: 24),
              Text(
                'Upgrade to Premium',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'This feature requires a premium subscription. Upgrade now to unlock all premium features.',
                style: theme.textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              _buildPlanCard(
                context,
                title: 'Monthly Plan',
                price: '\$9.99',
                period: 'per month',
                features: [
                  'Access to all premium features',
                  'Advanced event planning tools',
                  'Unlimited comparisons',
                  'Priority support',
                ],
                onSubscribe: () => _handleSubscribe(context, 'monthly'),
              ),
              const SizedBox(height: 16),
              _buildPlanCard(
                context,
                title: 'Annual Plan',
                price: '\$99.99',
                period: 'per year',
                features: [
                  'Access to all premium features',
                  'Advanced event planning tools',
                  'Unlimited comparisons',
                  'Priority support',
                  'Save 16% compared to monthly plan',
                ],
                isRecommended: true,
                onSubscribe: () => _handleSubscribe(context, 'annual'),
              ),
              const SizedBox(height: 32),
              OutlinedButton(
                onPressed: () {
                  NavigationUtils.navigateToNamedAndRemoveUntil(
                    context,
                    RouteNames.home,
                  );
                },
                child: const Text('Maybe Later'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlanCard(
    BuildContext context, {
    required String title,
    required String price,
    required String period,
    required List<String> features,
    bool isRecommended = false,
    required VoidCallback onSubscribe,
  }) {
    final theme = Theme.of(context);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side:
            isRecommended
                ? BorderSide(color: theme.colorScheme.primary, width: 2)
                : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (isRecommended)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  'BEST VALUE',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            if (isRecommended) const SizedBox(height: 8),
            Text(
              title,
              style: theme.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  price,
                  style: theme.textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 4),
                Text(period, style: theme.textTheme.bodyMedium),
              ],
            ),
            const SizedBox(height: 16),
            ...features.map(
              (feature) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: theme.colorScheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: Text(feature)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onSubscribe,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    isRecommended
                        ? theme.colorScheme.primary
                        : theme.colorScheme.surface,
                foregroundColor:
                    isRecommended
                        ? theme.colorScheme.onPrimary
                        : theme.colorScheme.primary,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text('Subscribe Now'),
            ),
          ],
        ),
      ),
    );
  }

  void _handleSubscribe(BuildContext context, String plan) {
    // In a real app, this would handle the subscription process
    // For now, we'll just show a dialog
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Subscription'),
            content: Text(
              'You selected the $plan plan. This is a mock implementation.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  // Simulate a successful subscription
                  final authProvider = Provider.of<AuthProvider>(
                    context,
                    listen: false,
                  );
                  final user = authProvider.currentUser;
                  if (user != null) {
                    // In a real app, this would update the user's subscription status
                    // For now, we'll just continue with the flow
                  }

                  Navigator.of(context).pop();
                  NavigationUtils.navigateToNamedAndRemoveUntil(
                    context,
                    RouteNames.home,
                  );

                  // Show success message
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Subscription successful! You now have access to premium features.',
                      ),
                      duration: Duration(seconds: 3),
                    ),
                  );
                },
                child: const Text('Subscribe'),
              ),
            ],
          ),
    );
  }
}
