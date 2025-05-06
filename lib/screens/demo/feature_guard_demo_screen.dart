import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:eventati_book/providers/providers.dart';
import 'package:eventati_book/widgets/widgets.dart';

/// A screen that demonstrates the use of feature guards
class FeatureGuardDemoScreen extends StatelessWidget {
  /// Creates a new FeatureGuardDemoScreen
  const FeatureGuardDemoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Access providers
    Provider.of<FeatureProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Feature Guards Demo')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Feature Guards', style: theme.textTheme.headlineMedium),
            const SizedBox(height: 8),
            Text(
              'This screen demonstrates the use of feature guards to protect routes based on user roles, subscription status, feature flags, and more.',
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),

            // Role Guard Demo
            _buildSection(
              context,
              title: 'Role Guard',
              description: 'Protects routes based on user roles.',
              children: [
                _buildRoleToggle(context, 'user', 'User'),
                _buildRoleToggle(context, 'admin', 'Admin'),
                _buildRoleToggle(context, 'moderator', 'Moderator'),
                _buildRoleToggle(context, 'vendor', 'Vendor'),
                _buildRoleToggle(context, 'planner', 'Planner'),
                const SizedBox(height: 16),
                _buildGuardedButton(context, 'Admin Area', () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => const FeatureGuardWrapper(
                            roleGuard: true,
                            allowedRoles: ['admin'],
                            child: _DemoProtectedScreen(
                              title: 'Admin Area',
                              description:
                                  'This area is only accessible to admins.',
                            ),
                          ),
                    ),
                  );
                }),
                _buildGuardedButton(context, 'Moderator Area', () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => const FeatureGuardWrapper(
                            roleGuard: true,
                            allowedRoles: ['admin', 'moderator'],
                            child: _DemoProtectedScreen(
                              title: 'Moderator Area',
                              description:
                                  'This area is only accessible to admins and moderators.',
                            ),
                          ),
                    ),
                  );
                }),
                _buildGuardedButton(context, 'Vendor Area', () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => const FeatureGuardWrapper(
                            roleGuard: true,
                            allowedRoles: ['admin', 'vendor'],
                            child: _DemoProtectedScreen(
                              title: 'Vendor Area',
                              description:
                                  'This area is only accessible to admins and vendors.',
                            ),
                          ),
                    ),
                  );
                }),
              ],
            ),

            const SizedBox(height: 24),

            // Subscription Guard Demo
            _buildSection(
              context,
              title: 'Subscription Guard',
              description: 'Protects routes based on subscription status.',
              children: [
                SwitchListTile(
                  title: const Text('Premium Subscription'),
                  subtitle: Text(
                    authProvider.currentUser?.hasPremiumSubscription == true
                        ? 'Active until ${authProvider.currentUser?.subscriptionExpirationDate?.toString().split(' ')[0]}'
                        : 'Inactive',
                  ),
                  value:
                      authProvider.currentUser?.hasPremiumSubscription == true,
                  onChanged: (value) {
                    final user = authProvider.currentUser;
                    if (user != null) {
                      // In a real app, this would update the user's subscription status
                      // For now, we'll just show a snackbar
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            value
                                ? 'Premium subscription activated'
                                : 'Premium subscription deactivated',
                          ),
                        ),
                      );
                    }
                  },
                ),
                const SizedBox(height: 16),
                _buildGuardedButton(context, 'Premium Feature', () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => const FeatureGuardWrapper(
                            subscriptionGuard: true,
                            child: _DemoProtectedScreen(
                              title: 'Premium Feature',
                              description:
                                  'This feature is only accessible to premium subscribers.',
                            ),
                          ),
                    ),
                  );
                }),
              ],
            ),

            const SizedBox(height: 24),

            // Feature Guard Demo
            _buildSection(
              context,
              title: 'Feature Guard',
              description: 'Protects routes based on feature flags.',
              children: [
                ..._buildFeatureToggles(context, [
                  'premium_comparison',
                  'premium_search',
                  'premium_filter',
                  'ai_suggestions',
                  'ai_planning',
                ]),
                const SizedBox(height: 16),
                _buildGuardedButton(context, 'Premium Comparison', () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => const FeatureGuardWrapper(
                            featureGuard: true,
                            requiredFeature: 'premium_comparison',
                            child: _DemoProtectedScreen(
                              title: 'Premium Comparison',
                              description:
                                  'This feature requires the premium_comparison feature flag.',
                            ),
                          ),
                    ),
                  );
                }),
                _buildGuardedButton(context, 'AI Suggestions', () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => const FeatureGuardWrapper(
                            featureGuard: true,
                            requiredFeature: 'ai_suggestions',
                            child: _DemoProtectedScreen(
                              title: 'AI Suggestions',
                              description:
                                  'This feature requires the ai_suggestions feature flag.',
                            ),
                          ),
                    ),
                  );
                }),
              ],
            ),

            const SizedBox(height: 24),

            // Combined Guards Demo
            _buildSection(
              context,
              title: 'Combined Guards',
              description: 'Protects routes based on multiple conditions.',
              children: [
                _buildGuardedButton(context, 'Admin + Premium', () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => const FeatureGuardWrapper(
                            roleGuard: true,
                            allowedRoles: ['admin'],
                            subscriptionGuard: true,
                            child: _DemoProtectedScreen(
                              title: 'Admin + Premium',
                              description:
                                  'This area requires admin role and premium subscription.',
                            ),
                          ),
                    ),
                  );
                }),
                _buildGuardedButton(context, 'Premium + AI Feature', () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => const FeatureGuardWrapper(
                            subscriptionGuard: true,
                            featureGuard: true,
                            requiredFeature: 'ai_suggestions',
                            child: _DemoProtectedScreen(
                              title: 'Premium + AI Feature',
                              description:
                                  'This area requires premium subscription and ai_suggestions feature.',
                            ),
                          ),
                    ),
                  );
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required String description,
    required List<Widget> children,
  }) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(description, style: theme.textTheme.bodyMedium),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildRoleToggle(BuildContext context, String role, String label) {
    final authProvider = Provider.of<AuthProvider>(context);
    final currentRole = authProvider.currentUser?.role;

    return RadioListTile<String>(
      title: Text(label),
      value: role,
      groupValue: currentRole,
      onChanged: (value) {
        final user = authProvider.currentUser;
        if (user != null && value != null) {
          // In a real app, this would update the user's role
          // For now, we'll just show a snackbar
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Changed role to: $value')));
        }
      },
    );
  }

  List<Widget> _buildFeatureToggles(
    BuildContext context,
    List<String> features,
  ) {
    final featureProvider = Provider.of<FeatureProvider>(context);

    return features.map((feature) {
      return SwitchListTile(
        title: Text(feature),
        value: featureProvider.isFeatureEnabled(feature),
        onChanged: (value) {
          if (value) {
            featureProvider.enableFeature(feature);
          } else {
            featureProvider.disableFeature(feature);
          }
        },
      );
    }).toList();
  }

  Widget _buildGuardedButton(
    BuildContext context,
    String label,
    VoidCallback onPressed,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
        child: Text(label),
      ),
    );
  }
}

class _DemoProtectedScreen extends StatelessWidget {
  final String title;
  final String description;

  const _DemoProtectedScreen({required this.title, required this.description});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.check_circle,
                size: 80,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 24),
              Text(
                'Access Granted',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                description,
                style: theme.textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
