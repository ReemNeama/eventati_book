import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Import providers using barrel file
import 'package:eventati_book/providers/providers.dart';

// Import utilities using barrel file
import 'package:eventati_book/utils/utils.dart';

// Import authentication widgets using barrel file
import 'package:eventati_book/widgets/auth/auth_widgets.dart';

// Import routing
import 'package:eventati_book/routing/routing.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Method to handle login process
  Future<void> _handleLogin(AuthProvider authProvider) async {
    if (!_formKey.currentState!.validate()) return;

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (dialogContext) => const AlertDialog(
            content: Row(
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 20),
                Text('Logging in...'),
              ],
            ),
          ),
    );

    // Attempt to login
    final success = await authProvider.login(
      _emailController.text,
      _passwordController.text,
    );

    // Only proceed if the widget is still mounted
    if (!mounted) return;

    // Hide loading indicator
    Navigator.pop(context);

    if (success) {
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Login successful!',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate to home screen
      NavigationUtils.navigateToNamedAndRemoveUntil(context, RouteNames.home);
    } else {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            authProvider.errorMessage ?? 'Login failed',
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Method to handle Google login
  Future<void> _handleGoogleLogin(AuthProvider authProvider) async {
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (dialogContext) => const AlertDialog(
            content: Row(
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 20),
                Text('Logging in with Google...'),
              ],
            ),
          ),
    );

    // Attempt to login with Google
    final success = await authProvider.loginWithGoogle();

    // Only proceed if the widget is still mounted
    if (!mounted) return;

    // Hide loading indicator
    Navigator.pop(context);

    if (success) {
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Google login successful!',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate to home screen
      NavigationUtils.navigateToNamedAndRemoveUntil(context, RouteNames.home);
    } else {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            authProvider.errorMessage ?? 'Google login failed',
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const AuthTitleWidget(),
              const SizedBox(height: 50),
              AuthTextField(
                controller: _emailController,
                hintText: 'Email',
                prefixIcon: Icons.email,
                keyboardType: TextInputType.emailAddress,
                validator: (value) => ValidationUtils.validateEmail(value),
              ),
              const SizedBox(height: 20),
              AuthTextField(
                controller: _passwordController,
                hintText: 'Password',
                prefixIcon: Icons.lock,
                obscureText: true,
                validator:
                    (value) => ValidationUtils.validatePassword(
                      value,
                      minLength: 6,
                      requireUppercase: false,
                      requireLowercase: false,
                      requireNumbers: false,
                      requireSpecialChars: false,
                    ),
              ),
              const SizedBox(height: 30),
              Consumer<AuthProvider>(
                builder: (context, authProvider, _) {
                  return AuthButton(
                    onPressed: () {
                      _handleLogin(authProvider);
                    },
                    text:
                        authProvider.status == AuthStatus.authenticating
                            ? 'Please wait...'
                            : 'Login',
                  );
                },
              ),
              const SizedBox(height: 20),
              const Row(
                children: [
                  Expanded(child: Divider()),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text('OR', style: TextStyle(color: Colors.grey)),
                  ),
                  Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: 20),
              Consumer<AuthProvider>(
                builder: (context, authProvider, _) {
                  return SocialAuthButton(
                    onPressed: () {
                      _handleGoogleLogin(authProvider);
                    },
                    text: 'Sign in with Google',
                    imagePath: 'assets/google.png',
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
