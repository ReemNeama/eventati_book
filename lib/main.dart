// Import Flutter packages
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

// Import app modules
import 'package:eventati_book/styles/app_theme.dart';
import 'package:eventati_book/routing/routing.dart';
import 'package:eventati_book/di/service_locator.dart';
import 'package:eventati_book/di/providers_manager.dart';
import 'package:eventati_book/services/services.dart';
import 'package:eventati_book/utils/error_utils.dart';
import 'firebase_options.dart';

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase (only for supported platforms)
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    // Handle initialization error for unsupported platforms
    debugPrint('Firebase initialization failed: $e');
    // Continue without Firebase on unsupported platforms
  }

  // Initialize the service locator
  ServiceLocator().initialize();

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

  // Initialize analytics service (mock implementation for now)
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
