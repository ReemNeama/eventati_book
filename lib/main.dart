// Import Flutter packages
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:posthog_flutter/posthog_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

// Import app modules
import 'package:eventati_book/styles/app_theme.dart';
import 'package:eventati_book/routing/routing.dart';
import 'package:eventati_book/di/service_locator.dart';
import 'package:eventati_book/di/providers_manager.dart';
import 'package:eventati_book/services/services.dart';
import 'package:eventati_book/services/supabase/core/posthog_crashlytics_service.dart';
import 'package:eventati_book/services/interfaces/crashlytics_service_interface.dart';
import 'package:eventati_book/services/interfaces/messaging_service_interface.dart';
import 'package:eventati_book/services/supabase/core/custom_messaging_service.dart';
import 'package:eventati_book/utils/error_utils.dart';
import 'package:eventati_book/config/supabase_options.dart';
import 'package:eventati_book/config/posthog_options.dart';
import 'package:eventati_book/config/stripe_options.dart';

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Stripe
  try {
    Stripe.publishableKey = StripeOptions.publishableKey;
    await Stripe.instance.applySettings();
    debugPrint('Stripe initialized successfully');
  } catch (e) {
    debugPrint('Stripe initialization failed: $e');
  }

  // Initialize Supabase
  try {
    await Supabase.initialize(
      url: SupabaseOptions.supabaseUrl,
      anonKey: SupabaseOptions.supabaseAnonKey,
      debug: kDebugMode,
    );
  } catch (e) {
    debugPrint('Supabase initialization failed: $e');
  }

  // Initialize PostHog
  try {
    // Initialize PostHog with the API key and host from PostHogOptions
    final config = PostHogConfig(PostHogOptions.apiKey);
    config.host = PostHogOptions.apiHost;
    config.debug = PostHogOptions.debug;
    config.captureApplicationLifecycleEvents =
        PostHogOptions.captureAppLifecycleEvents;
    config.sessionReplay = PostHogOptions.sessionReplay;

    await Posthog().setup(config);
    debugPrint('PostHog initialized successfully');
  } catch (e) {
    debugPrint('PostHog initialization failed: $e');
  }

  // Initialize the service locator
  ServiceLocator().initialize();

  // Initialize Custom Messaging Service
  final messagingService = CustomMessagingService();
  await messagingService.initialize();
  ServiceLocator().registerSingleton<MessagingServiceInterface>(
    messagingService,
  );

  // Set up error handling
  FlutterError.onError = (FlutterErrorDetails details) {
    // Log to console
    FlutterError.presentError(details);

    // Report to crashlytics
    ErrorUtils.logError(
      'Flutter error',
      error: details.exception,
      stackTrace: details.stack,
    );
  };

  // Initialize analytics service
  final analyticsService = AnalyticsService();
  ServiceLocator().registerSingleton<AnalyticsService>(analyticsService);

  // Initialize route analytics
  RouteAnalytics.instance.initialize(analyticsService);
  final analyticsObserver = AnalyticsRouteObserver(
    analyticsService: analyticsService,
  );
  RouteAnalytics.instance.addObserver(analyticsObserver);

  // Initialize route performance
  RoutePerformance.instance.initialize(analyticsService);

  // Initialize PostHog crashlytics service
  final crashlyticsService = PostHogCrashlyticsService();
  await crashlyticsService.initialize();
  ServiceLocator().registerSingleton<CrashlyticsServiceInterface>(
    crashlyticsService,
  );

  // Initialize deep link handler
  try {
    await DeepLinkHandler.instance.initialize();
    debugPrint('Deep link handler initialized successfully');
  } catch (e) {
    debugPrint('Deep link handler initialization failed: $e');
  }

  // Example error to verify PostHog is working
  try {
    throw Exception('This is a test error for PostHog');
  } catch (e, stackTrace) {
    await Posthog().capture(
      eventName: 'test_error',
      properties: {'error': e.toString(), 'stackTrace': stackTrace.toString()},
    );
  }

  runApp(
    MultiProvider(
      providers: ProvidersManager().providers,
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // Default to light theme
  ThemeMode _themeMode = ThemeMode.light;

  @override
  void initState() {
    super.initState();
    // Initialize providers when the app starts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        // Initialize all providers using the ProvidersManager
        ProvidersManager().initializeProviders(context);
      }
    });
  }

  // Toggle between light and dark themes
  void toggleTheme() {
    setState(() {
      _themeMode =
          _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Eventati Book',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _themeMode,
      // Use the navigation service's navigator key
      navigatorKey: serviceLocator.navigationService.navigatorKey,
      // Define named routes for the app
      initialRoute: RouteNames.splash,
      // Use AppRouter for routes
      routes: AppRouter.routes,
      onGenerateRoute: AppRouter.onGenerateRoute,
      onUnknownRoute: AppRouter.onUnknownRoute,
      // Add route observer for analytics
      navigatorObservers: [...RouteAnalytics.instance.observers],
    );
  }
}
