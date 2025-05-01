import 'package:eventati_book/providers/auth_provider.dart';
import 'package:eventati_book/screens/authentications/authentication_screen.dart';
import 'package:eventati_book/screens/services/catering_list_screen.dart';
import 'package:eventati_book/styles/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => AuthProvider())],
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
      home: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          // Show different screens based on authentication status
          if (authProvider.status == AuthStatus.authenticating) {
            // Show loading screen while authenticating
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          } else if (authProvider.isAuthenticated) {
            // Show home screen if authenticated
            return CateringListScreen(toggleTheme: toggleTheme);
          } else {
            // Show authentication screen if not authenticated
            return const AuthenticationScreen();
          }
        },
      ),
    );
  }
}
