import 'package:flutter/material.dart';
import 'package:eventati_book/widgets/auth/auth_title_widget.dart';
import 'package:eventati_book/widgets/auth/auth_button.dart';
import 'package:eventati_book/utils/utils.dart';
import 'package:eventati_book/routing/routing.dart';
import 'package:eventati_book/providers/providers.dart';
import 'package:provider/provider.dart';
import 'package:eventati_book/styles/app_colors.dart';


class VerificationScreen extends StatefulWidget {
  final String email;

  const VerificationScreen({super.key, required this.email});

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  bool _isResending = false;
  bool _isChecking = false;

  Future<void> _resendVerificationEmail(AuthProvider authProvider) async {
    setState(() {
      _isResending = true;
    });

    final success = await authProvider.verifyEmail();

    if (!mounted) return;

    setState(() {
      _isResending = false;
    });

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Verification email sent. Please check your inbox.',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: AppColors.success,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            authProvider.errorMessage ?? 'Failed to send verification email',
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _checkEmailVerification(AuthProvider authProvider) async {
    setState(() {
      _isChecking = true;
    });

    // Reload the user to check if email is verified
    await authProvider.reloadUser();

    if (!mounted) return;

    setState(() {
      _isChecking = false;
    });

    if (authProvider.isEmailVerified) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Email verified successfully!',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: AppColors.success,
        ),
      );

      // Navigate to home screen
      NavigationUtils.navigateToNamedAndRemoveUntil(context, RouteNames.home);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Email not verified yet. Please check your inbox and click the verification link.',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: AppColors.warning,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        return Scaffold(
          backgroundColor: Theme.of(context).primaryColor,
          appBar: AppBar(
            backgroundColor: Theme.of(context).primaryColor,
            elevation: 0,
          ),
          body: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const AuthTitleWidget(title: 'Verify Your Email', fontSize: 32),
                const SizedBox(height: 20),
                const Icon(Icons.email_outlined, size: 80, color: Colors.white),
                const SizedBox(height: 20),
                Text(
                  'A verification email has been sent to:',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  widget.email,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                const Text(
                  'Please check your inbox and click the verification link to complete your registration.',
                  style: TextStyle(color: Colors.white70),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                AuthButton(
                  onPressed:
                      _isChecking
                          ? null
                          : () => _checkEmailVerification(authProvider),
                  text: _isChecking ? 'Checking...' : 'I\'ve Verified My Email',
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed:
                      _isResending
                          ? null
                          : () => _resendVerificationEmail(authProvider),
                  child: Text(
                    _isResending ? 'Sending...' : 'Resend Verification Email',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                    NavigationUtils.navigateToNamedAndRemoveUntil(
                      context,
                      RouteNames.login,
                    );
                  },
                  child: const Text(
                    'Back to Login',
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
