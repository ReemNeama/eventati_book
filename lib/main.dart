import 'package:eventati_book/providers/auth_provider.dart';
import 'package:eventati_book/providers/milestone_provider.dart';
import 'package:eventati_book/providers/suggestion_provider.dart';
import 'package:eventati_book/providers/wizard_provider.dart';
import 'package:eventati_book/screens/authentications/authentication_screen.dart';
import 'package:eventati_book/screens/authentications/forgetpassword_screen.dart';
import 'package:eventati_book/screens/authentications/login_screen.dart';
import 'package:eventati_book/screens/authentications/register_screen.dart';
import 'package:eventati_book/screens/authentications/verification_screen.dart';
import 'package:eventati_book/screens/event_wizard/suggestion_screen.dart';
import 'package:eventati_book/screens/homepage/event_selection_screen.dart';
import 'package:eventati_book/screens/main_navigation_screen.dart';
import 'package:eventati_book/styles/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
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
        // Other providers will be created as needed in the respective screens
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
    // Initialize the auth provider when the app starts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Provider.of<AuthProvider>(context, listen: false).initialize();
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
      // Define named routes for the app
      initialRoute: '/',
      routes: {
        '/event-selection': (context) => const EventSelectionScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/forgot-password': (context) => const ForgetpasswordScreen(),
        '/event-wizard/suggestions': (context) => const SuggestionScreen(),
      },
      // Use onGenerateRoute for routes that need parameters
      onGenerateRoute: (settings) {
        if (settings.name == '/verification') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) => VerificationScreen(email: args['email']),
          );
        }
        return null;
      },
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
            return MainNavigationScreen(toggleTheme: toggleTheme);
          } else {
            // Show authentication screen if not authenticated
            return const AuthenticationScreen();
          }
        },
      ),
    );
  }
}
