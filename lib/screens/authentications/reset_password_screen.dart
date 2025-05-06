import 'package:flutter/material.dart';
import 'package:eventati_book/providers/providers.dart';
import 'package:eventati_book/widgets/auth/auth_title_widget.dart';
import 'package:eventati_book/widgets/auth/auth_text_field.dart';
import 'package:eventati_book/widgets/auth/auth_button.dart';
import 'package:eventati_book/utils/utils.dart';
import 'package:provider/provider.dart';
import 'package:eventati_book/routing/routing.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // Method to handle password reset
  Future<void> _handlePasswordReset() async {
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
                Text('Resetting password...'),
              ],
            ),
          ),
    );

    // Simulate API call delay
    await Future.delayed(const Duration(seconds: 1));

    // Only proceed if the widget is still mounted
    if (!mounted) return;

    // Hide loading indicator
    Navigator.pop(context);

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Password reset successful! You can now login with your new password.',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green,
      ),
    );

    // Navigate back to login screen
    NavigationUtils.navigateToNamedAndRemoveUntil(context, RouteNames.login);
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
              const AuthTitleWidget(title: 'Reset Password', fontSize: 32),
              const SizedBox(height: 20),
              const Text(
                'Enter your new password',
                style: TextStyle(color: Colors.white70),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 50),
              AuthTextField(
                controller: _passwordController,
                hintText: 'New Password',
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
              const SizedBox(height: 20),
              AuthTextField(
                controller: _confirmPasswordController,
                hintText: 'Confirm New Password',
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
                      _handlePasswordReset();
                    },
                    text: 'Reset Password',
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
