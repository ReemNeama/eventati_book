import 'package:flutter/material.dart';
import 'package:eventati_book/providers/providers.dart';
import 'package:eventati_book/widgets/auth/auth_title_widget.dart';
import 'package:eventati_book/widgets/auth/auth_text_field.dart';
import 'package:eventati_book/widgets/auth/auth_button.dart';
import 'package:eventati_book/utils/utils.dart';
import 'package:provider/provider.dart';
import 'package:eventati_book/routing/routing.dart';

class ForgetpasswordScreen extends StatefulWidget {
  const ForgetpasswordScreen({super.key});

  @override
  State<ForgetpasswordScreen> createState() => _ForgetpasswordScreenState();
}

class _ForgetpasswordScreenState extends State<ForgetpasswordScreen> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  // Method to handle reset password process
  Future<void> _handleResetPassword(AuthProvider authProvider) async {
    if (!_formKey.currentState!.validate()) return;

    // Store email locally to use after async operations
    final email = _emailController.text;

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
                Text('Sending reset email...'),
              ],
            ),
          ),
    );

    // Call the resetPassword method from AuthProvider
    final success = await authProvider.resetPassword(email);

    // Only proceed if the widget is still mounted
    if (!mounted) return;

    // Hide loading indicator
    Navigator.pop(context);

    if (success) {
      // Show success message with detailed instructions
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text('Password Reset Email Sent'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('A password reset link has been sent to $email.'),
                  const SizedBox(height: 16),
                  const Text(
                    'Please check your inbox and follow the instructions to reset your password.',
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Note: The link will expire after 1 hour for security reasons.',
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pushReplacementNamed(context, RouteNames.login);
                  },
                  child: const Text('OK'),
                ),
              ],
            ),
      );
    } else {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            authProvider.errorMessage ?? 'Failed to send reset email',
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
              const SizedBox(height: 20),
              const AuthTitleWidget(title: 'Reset Password', fontSize: 24),
              const SizedBox(height: 50),
              AuthTextField(
                controller: _emailController,
                hintText: 'Email',
                prefixIcon: Icons.email,
                keyboardType: TextInputType.emailAddress,
                validator: (value) => ValidationUtils.validateEmail(value),
              ),
              const SizedBox(height: 30),
              Consumer<AuthProvider>(
                builder: (context, authProvider, _) {
                  return AuthButton(
                    onPressed: () {
                      _handleResetPassword(authProvider);
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
