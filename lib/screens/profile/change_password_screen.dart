import 'package:flutter/material.dart';
import 'package:eventati_book/providers/providers.dart';
import 'package:eventati_book/widgets/widgets.dart';
import 'package:eventati_book/utils/utils.dart';
import 'package:provider/provider.dart';
import 'package:eventati_book/styles/app_colors.dart';

/// Screen for changing user password
class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // Method to handle password change
  Future<void> _handleChangePassword(AuthProvider authProvider) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

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
                Text('Changing password...'),
              ],
            ),
          ),
    );

    try {
      final success = await authProvider.changePassword(
        _currentPasswordController.text,
        _newPasswordController.text,
      );

      // Only proceed if the widget is still mounted
      if (!mounted) return;

      // Hide loading indicator
      Navigator.pop(context);

      setState(() {
        _isLoading = false;
      });

      if (success) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Password changed successfully!',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: AppColors.success,
          ),
        );

        // Navigate back
        Navigator.pop(context);
      } else {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              authProvider.errorMessage ?? 'Failed to change password',
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

      setState(() {
        _isLoading = false;
      });

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to change password: ${e.toString()}',
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
      appBar: AppBar(title: const Text('Change Password')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Update your password',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Enter your current password and choose a new strong password.',
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 30),
                AuthTextField(
                  controller: _currentPasswordController,
                  hintText: 'Current Password',
                  prefixIcon: Icons.lock_outline,
                  obscureText: true,
                  validator:
                      (value) => ValidationUtils.validateRequired(
                        value,
                        message: 'Please enter your current password',
                      ),
                ),
                const SizedBox(height: 20),
                AuthTextField(
                  controller: _newPasswordController,
                  hintText: 'New Password',
                  prefixIcon: Icons.lock,
                  obscureText: true,
                  showPasswordStrength: true,
                  showPasswordRequirements: true,
                  passwordMinLength: 8,
                  requireUppercase: true,
                  requireLowercase: true,
                  requireNumbers: true,
                  requireSpecialChars: true,
                  validator:
                      (value) => ValidationUtils.validatePassword(
                        value,
                        minLength: 8,
                        requireUppercase: true,
                        requireLowercase: true,
                        requireNumbers: true,
                        requireSpecialChars: true,
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
                        _newPasswordController.text,
                        value,
                      ),
                ),
                const SizedBox(height: 30),
                Consumer<AuthProvider>(
                  builder: (context, authProvider, _) {
                    return SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed:
                            _isLoading
                                ? null
                                : () => _handleChangePassword(authProvider),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                        ),
                        child: Text(
                          _isLoading ? 'Please wait...' : 'Change Password',
                        ),
                      ),
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
