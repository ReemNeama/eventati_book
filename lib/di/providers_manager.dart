import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nested/nested.dart';
import 'package:eventati_book/providers/providers.dart';
import 'package:eventati_book/services/supabase/database/activity_database_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Manager for registering and accessing providers
///
/// This class centralizes provider registration and initialization,
/// making it easier to manage providers across the application.
///
/// Usage:
/// ```dart
/// // In main.dart
/// MultiProvider(
///   providers: ProvidersManager().providers,
///   child: MyApp(),
/// )
///
/// // Initialize providers
/// ProvidersManager().initializeProviders(context);
/// ```
class ProvidersManager {
  static final ProvidersManager _instance = ProvidersManager._internal();

  factory ProvidersManager() => _instance;

  ProvidersManager._internal();

  /// Get the list of all providers for MultiProvider
  List<SingleChildWidget> get providers => [
    // Core providers
    ChangeNotifierProvider(create: (_) => AuthProvider()),
    ChangeNotifierProvider(create: (_) => FeatureProvider()),
    ChangeNotifierProvider(create: (_) => WizardProvider()),
    ChangeNotifierProvider(create: (_) => OnboardingProvider()),
    ChangeNotifierProvider(create: (_) => EventProvider()),
    ChangeNotifierProvider(create: (_) => AccessibilityProvider()),

    // Feature providers with dependencies
    ChangeNotifierProxyProvider<WizardProvider, MilestoneProvider>(
      create:
          (context) => MilestoneProvider(
            Provider.of<WizardProvider>(context, listen: false),
          ),
      update:
          (context, wizardProvider, previous) =>
              previous ?? MilestoneProvider(wizardProvider),
    ),
    ChangeNotifierProvider(create: (_) => SuggestionProvider()),
    ChangeNotifierProvider(create: (_) => ServiceRecommendationProvider()),
    ChangeNotifierProvider(create: (_) => ComparisonProvider()),

    // Planning providers
    ChangeNotifierProvider(
      create: (_) => BudgetProvider(eventId: 'default'),
      lazy: true,
    ),
    ChangeNotifierProvider(
      create: (_) => GuestListProvider(eventId: 'default'),
      lazy: true,
    ),
    ChangeNotifierProvider(
      create: (_) => MessagingProvider(eventId: 'default'),
      lazy: true,
    ),
    ChangeNotifierProvider(
      create: (_) => TaskProvider(eventId: 'default'),
      lazy: true,
    ),
    ChangeNotifierProvider(create: (_) => BookingProvider(), lazy: true),
    ChangeNotifierProvider(create: (_) => TaskTemplateProvider(), lazy: true),

    // Comparison providers
    ChangeNotifierProxyProvider<AuthProvider, ComparisonSavingProvider>(
      create:
          (context) => ComparisonSavingProvider(
            Provider.of<AuthProvider>(context, listen: false),
          ),
      update:
          (context, authProvider, previous) =>
              previous ?? ComparisonSavingProvider(authProvider),
      lazy: true,
    ),

    // Notification providers
    ChangeNotifierProvider(create: (_) => NotificationProvider(), lazy: true),

    // Sharing providers
    ChangeNotifierProvider(create: (_) => SocialSharingProvider(), lazy: true),

    // Activity tracking providers
    ChangeNotifierProvider(
      create:
          (context) => RecentActivityProvider(
            activityDatabaseService: ActivityDatabaseService(
              supabase: Supabase.instance.client,
            ),
          ),
      lazy: true,
    ),
  ];

  /// Initialize all providers that need initialization
  ///
  /// This method should be called after the widget tree is built,
  /// typically in the initState method of the root widget.
  ///
  /// Example:
  /// ```dart
  /// @override
  /// void initState() {
  ///   super.initState();
  ///   WidgetsBinding.instance.addPostFrameCallback((_) {
  ///     if (mounted) {
  ///       ProvidersManager().initializeProviders(context);
  ///     }
  ///   });
  /// }
  /// ```
  void initializeProviders(BuildContext context) {
    // Initialize auth provider
    Provider.of<AuthProvider>(context, listen: false).initialize();

    // Initialize suggestion provider
    Provider.of<SuggestionProvider>(context, listen: false).initialize();

    // Initialize booking provider
    Provider.of<BookingProvider>(context, listen: false).initialize();

    // Note: EventProvider doesn't need explicit initialization as it loads data in its constructor

    // Access EventProvider to ensure it's initialized
    Provider.of<EventProvider>(context, listen: false);

    // Initialize notification provider
    Provider.of<NotificationProvider>(context, listen: false);

    // Initialize social sharing provider
    Provider.of<SocialSharingProvider>(context, listen: false);

    // Initialize accessibility provider
    Provider.of<AccessibilityProvider>(context, listen: false);

    // Initialize recent activity provider if user is authenticated
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.status == AuthStatus.authenticated &&
        authProvider.currentUser != null) {
      Provider.of<RecentActivityProvider>(
        context,
        listen: false,
      ).initialize(authProvider.currentUser!.id);
    }
  }
}
