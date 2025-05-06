// Import providers using barrel file
import 'package:eventati_book/providers/providers.dart';

import 'package:eventati_book/styles/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Import routing
import 'package:eventati_book/routing/routing.dart';
import 'package:eventati_book/di/service_locator.dart';
import 'package:eventati_book/utils/utils.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        // Core providers
        ChangeNotifierProvider(create: (_) => AuthProvider()),

        // Event wizard providers
        ChangeNotifierProvider(create: (_) => WizardProvider()),
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
        // ChangeNotifierProvider(create: (_) => ComparisonProvider()),

        // Event planning tool providers
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

        // Booking provider
        ChangeNotifierProvider(create: (_) => BookingProvider(), lazy: true),

        // Comparison providers
        ChangeNotifierProvider(create: (_) => ComparisonProvider()),
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
      ],
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
        // Initialize auth provider
        Provider.of<AuthProvider>(context, listen: false).initialize();

        // Initialize suggestion provider
        Provider.of<SuggestionProvider>(context, listen: false).initialize();

        // Initialize booking provider
        Provider.of<BookingProvider>(context, listen: false).initialize();
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
      home: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          // Show different screens based on authentication status
          if (authProvider.status == AuthStatus.authenticating) {
            // Show loading screen while authenticating
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          } else if (authProvider.isAuthenticated) {
            // Show main navigation screen if authenticated
            return NavigationUtils.navigateToNamedAndRemoveUntilBuilder(
              RouteNames.mainNavigation,
              arguments: MainNavigationArguments(toggleTheme: toggleTheme),
            );
          } else {
            // Show authentication screen if not authenticated
            return NavigationUtils.navigateToNamedAndRemoveUntilBuilder(
              RouteNames.splash,
            );
          }
        },
      ),
    );
  }
}
