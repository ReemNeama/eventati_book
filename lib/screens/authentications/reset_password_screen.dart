import 'package:flutter/material.dart';
import 'package:eventati_book/providers/providers.dart';
import 'package:eventati_book/widgets/auth/auth_title_widget.dart';
import 'package:eventati_book/widgets/auth/auth_text_field.dart';
import 'package:eventati_book/widgets/auth/auth_button.dart';
import 'package:eventati_book/utils/utils.dart';
import 'package:provider/provider.dart';
import 'package:eventati_book/routing/routing.dart';
import 'package:eventati_book/styles/app_colors.dart';
import 'package:eventati_book/styles/text_styles.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String? oobCode; // Out-of-band code from password reset link

  const ResetPasswordScreen({super.key, this.oobCode});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isCodeValid = false;
  bool _isCheckingCode = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _verifyResetCode();
  }

  Future<void> _verifyResetCode() async {
    if (widget.oobCode == null || widget.oobCode!.isEmpty) {
      setState(() {
        _isCheckingCode = false;
        _isCodeValid = false;
        _errorMessage =
            'Invalid or expired password reset link. Please request a new one.';
      });
      return;
    }

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final isValid = await authProvider.verifyPasswordResetCode(
        widget.oobCode!,
      );

      if (mounted) {
        setState(() {
          _isCheckingCode = false;
          _isCodeValid = isValid;
          if (!isValid) {
            _errorMessage =
                'Invalid or expired password reset link. Please request a new one.';
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isCheckingCode = false;
          _isCodeValid = false;
          _errorMessage = 'Error verifying reset code: ${e.toString()}';
        });
      }
    }
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // Method to handle password reset
  Future<void> _handlePasswordReset() async {
    if (!_formKey.currentState!.validate() ||
        !_isCodeValid ||
        widget.oobCode == null) {
      return;
    }

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

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final success = await authProvider.confirmPasswordReset(
        widget.oobCode!,
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
              'Password reset successful! You can now login with your new password.',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: AppColors.success,
          ),
        );

        // Navigate back to login screen
        Navigator.pushNamedAndRemoveUntil(
          context,
          RouteNames.login,
          (route) => false,
        );
      } else {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              authProvider.errorMessage ?? 'Failed to reset password',
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      // Only proceed if the widget is still mounted
      if (!mounted) return;

      // Hide loading indicator
      Navigator.pop(context);

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to reset password: ${e.toString()}',
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
        child:
            _isCheckingCode
                ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: Colors.white),
                      SizedBox(height: 20),
                      Text(
                        'Verifying reset link...',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                )
                : !_isCodeValid
                ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: AppColors.error,
                        size: 60,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        _errorMessage ?? 'Invalid reset link',
                        textAlign: TextAlign.center,
                        style: TextStyles.bodyLarge,
                      ),
                      const SizedBox(height: 30),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pushReplacementNamed(
                            context,
                            RouteNames.forgotPassword,
                          );
                        },
                        child: const Text('Request New Reset Link'),
                      ),
                    ],
                  ),
                )
                : Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const AuthTitleWidget(
                        title: 'Reset Password',
                        fontSize: 32,
                      ),
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
                      const SizedBox(height: 20),
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacementNamed(
                            context,
                            RouteNames.login,
                          );
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white70,
                        ),
                        child: const Text('Back to Login'),
                      ),
                    ],
                  ),
                ),
      ),
    );
  }
}
