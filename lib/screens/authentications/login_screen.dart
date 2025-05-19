import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:local_auth/local_auth.dart';

// Import providers using barrel file
import 'package:eventati_book/providers/providers.dart';

// Import utilities using barrel file
import 'package:eventati_book/utils/utils.dart';
import 'package:eventati_book/utils/logger.dart';

// Import authentication widgets using barrel file
import 'package:eventati_book/widgets/auth/auth_widgets.dart';

// Import routing
import 'package:eventati_book/routing/routing.dart';
import 'package:eventati_book/styles/app_colors.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // Remember me option
  bool _rememberMe = false;

  // Biometric authentication
  bool _isBiometricAvailable = false;
  List<BiometricType> _availableBiometrics = [];
  bool _isBiometricEnabled = false;

  @override
  void initState() {
    super.initState();
    _checkBiometricAvailability();
  }

  // Check if biometric authentication is available
  Future<void> _checkBiometricAvailability() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    try {
      // Check if biometric authentication is available
      final isBiometricAvailable = await authProvider.isBiometricAvailable();

      if (isBiometricAvailable) {
        // Get available biometric types
        final availableBiometrics = await authProvider.getAvailableBiometrics();

        // Check if biometric authentication is enabled
        final isBiometricEnabled = await authProvider.isBiometricEnabled();

        setState(() {
          _isBiometricAvailable = isBiometricAvailable;
          _availableBiometrics = availableBiometrics.cast<BiometricType>();
          _isBiometricEnabled = isBiometricEnabled;
        });
      }
    } catch (e) {
      Logger.e('Error checking biometric availability: $e', tag: 'LoginScreen');
    }
  }

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
    final result = await authProvider.login(
      _emailController.text,
      _passwordController.text,
      rememberMe: _rememberMe,
    );

    // Only proceed if the widget is still mounted
    if (!mounted) return;

    // Hide loading indicator
    Navigator.pop(context);

    if (result.isSuccess) {
      // Check if email verification is required
      if (result.requiresEmailVerification) {
        // Show verification required message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Please verify your email before continuing.',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: AppColors.warning,
          ),
        );

        // Navigate to verification screen
        NavigationUtils.navigateToNamed(
          context,
          RouteNames.verification,
          arguments: VerificationArguments(email: _emailController.text),
        );
        return;
      }

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Login successful!',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: AppColors.success,
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
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  // Method to handle biometric authentication
  Future<void> _handleBiometricAuth(AuthProvider authProvider) async {
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
                Text('Authenticating...'),
              ],
            ),
          ),
    );

    // Attempt to authenticate with biometrics
    final result = await authProvider.authenticateWithBiometrics();

    // Only proceed if the widget is still mounted
    if (!mounted) return;

    // Hide loading indicator
    Navigator.pop(context);

    if (result) {
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Biometric authentication successful!',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: AppColors.success,
        ),
      );

      // Navigate to home screen
      NavigationUtils.navigateToNamedAndRemoveUntil(context, RouteNames.home);
    } else {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            authProvider.errorMessage ?? 'Biometric authentication failed',
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: AppColors.error,
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
    final result = await authProvider.loginWithGoogle();

    // Only proceed if the widget is still mounted
    if (!mounted) return;

    // Hide loading indicator
    Navigator.pop(context);

    if (result.isSuccess) {
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Google login successful!',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: AppColors.success,
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
          backgroundColor: AppColors.error,
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
              const SizedBox(height: 10),
              Row(
                children: [
                  Checkbox(
                    value: _rememberMe,
                    onChanged: (value) {
                      setState(() {
                        _rememberMe = value ?? false;
                      });
                    },
                    activeColor: Theme.of(context).primaryColor,
                  ),
                  const Text(
                    'Remember me',
                    style: TextStyle(color: Colors.white70),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      NavigationUtils.navigateToNamed(
                        context,
                        RouteNames.forgotPassword,
                      );
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white70,
                    ),
                    child: const Text('Forgot Password?'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
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
                    child: Text(
                      'OR',
                      style: TextStyle(color: AppColors.disabled),
                    ),
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

              // Show biometric authentication button if available
              if (_isBiometricAvailable &&
                  _isBiometricEnabled &&
                  _availableBiometrics.isNotEmpty) ...[
                const SizedBox(height: 20),
                Consumer<AuthProvider>(
                  builder: (context, authProvider, _) {
                    return BiometricAuthButton(
                      onPressed: () {
                        _handleBiometricAuth(authProvider);
                      },
                      availableBiometrics: _availableBiometrics,
                    );
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
