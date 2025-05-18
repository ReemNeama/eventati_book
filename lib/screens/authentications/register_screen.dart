import 'package:flutter/material.dart';
import 'package:eventati_book/providers/providers.dart';
import 'package:eventati_book/widgets/auth/auth_title_widget.dart';
import 'package:eventati_book/widgets/auth/auth_text_field.dart';
import 'package:eventati_book/widgets/auth/auth_button.dart';
import 'package:eventati_book/utils/utils.dart';
import 'package:provider/provider.dart';
import 'package:eventati_book/routing/routing.dart';
import 'package:eventati_book/styles/app_colors.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // Method to handle registration process
  Future<void> _handleRegistration(AuthProvider authProvider) async {
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
                Text('Creating account...'),
              ],
            ),
          ),
    );

    // Attempt to register
    final result = await authProvider.register(
      _nameController.text,
      _emailController.text,
      _passwordController.text,
    );

    // Only proceed if the widget is still mounted
    if (!mounted) return;

    // Hide loading indicator
    Navigator.pop(context);

    if (result.isSuccess) {
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Registration successful! Please verify your email.',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: AppColors.success,
        ),
      );

      // Store email for later use
      final email = _emailController.text;

      // Send verification email
      await authProvider.verifyEmail();

      // Check if widget is still mounted before navigating
      if (!mounted) return;

      // Navigate to verification screen
      NavigationUtils.navigateToNamed(
        context,
        RouteNames.verification,
        arguments: VerificationArguments(email: email),
      );
    } else {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            authProvider.errorMessage ?? 'Registration failed',
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const AuthTitleWidget(title: 'Create Account'),
                const SizedBox(height: 50),
                AuthTextField(
                  controller: _nameController,
                  hintText: 'Full Name',
                  prefixIcon: Icons.person,
                  validator:
                      (value) => ValidationUtils.validateRequired(
                        value,
                        message: 'Please enter your name',
                      ),
                ),
                const SizedBox(height: 20),
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
                  showPasswordStrength: true,
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
                const SizedBox(height: 20),
                AuthTextField(
                  controller: _confirmPasswordController,
                  hintText: 'Confirm Password',
                  prefixIcon: Icons.lock,
                  obscureText: true,
                  validator:
                      (value) => ValidationUtils.validatePasswordsMatch(
                        _passwordController.text,
                        value,
                      ),
                ),
                const SizedBox(height: 30),
                Consumer<AuthProvider>(
                  builder: (context, authProvider, _) {
                    return AuthButton(
                      onPressed: () {
                        _handleRegistration(authProvider);
                      },
                      text:
                          authProvider.status == AuthStatus.authenticating
                              ? 'Please wait...'
                              : 'Register',
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
