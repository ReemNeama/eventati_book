import 'package:flutter/material.dart';
import 'package:eventati_book/screens/authentications/reset_password_screen.dart';
import 'package:eventati_book/widgets/auth/auth_title_widget.dart';
import 'package:eventati_book/widgets/auth/auth_button.dart';
import 'package:eventati_book/widgets/auth/verification_code_input.dart';
import 'package:eventati_book/utils/utils.dart';

class VerificationScreen extends StatefulWidget {
  final String email;

  const VerificationScreen({super.key, required this.email});

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  final List<TextEditingController> controllers = List.generate(
    6,
    (index) => TextEditingController(),
  );

  final List<FocusNode> focusNodes = List.generate(6, (index) => FocusNode());

  @override
  void dispose() {
    for (var controller in controllers) {
      controller.dispose();
    }
    for (var node in focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void onCodeChanged(String value, int index) {
    if (value.length == 1 && index < 5) {
      focusNodes[index + 1].requestFocus();
    }
    if (value.isEmpty && index > 0) {
      focusNodes[index - 1].requestFocus();
    }
  }

  // Method to handle resending verification code
  Future<void> _resendVerificationCode() async {
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
                Text('Resending code...'),
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
      SnackBar(
        content: Text(
          'Verification code resent to ${widget.email}',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
      ),
    );
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const AuthTitleWidget(title: "Verification", fontSize: 32),
            const SizedBox(height: 20),
            const Text(
              "Enter the verification code sent to your email",
              style: TextStyle(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 50),
            VerificationCodeInput(
              controllers: controllers,
              focusNodes: focusNodes,
              onCodeChanged: onCodeChanged,
            ),
            const SizedBox(height: 30),
            AuthButton(
              onPressed: () {
                String code =
                    controllers.map((controller) => controller.text).join();
                if (code.length == 6) {
                  // Show success message
                  UIUtils.showSuccessSnackBar(
                    context,
                    'Verification successful!',
                  );

                  // Navigate to reset password screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ResetPasswordScreen(),
                    ),
                  );
                } else {
                  // Show error message
                  UIUtils.showErrorSnackBar(
                    context,
                    'Please enter a valid 6-digit verification code',
                  );
                }
              },
              text: 'Verify',
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () {
                _resendVerificationCode();
              },
              child: const Text(
                'Resend Code',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
