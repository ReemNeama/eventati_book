import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:eventati_book/styles/app_colors.dart';
import 'package:eventati_book/styles/app_colors_dark.dart';
import 'package:eventati_book/styles/text_styles.dart';
import 'package:eventati_book/utils/utils.dart';

/// A button for biometric authentication
class BiometricAuthButton extends StatelessWidget {
  /// Callback when the button is pressed
  final VoidCallback onPressed;

  /// Available biometric types
  final List<BiometricType> availableBiometrics;

  /// Whether the button is enabled
  final bool isEnabled;

  /// Constructor
  const BiometricAuthButton({
    super.key,
    required this.onPressed,
    required this.availableBiometrics,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = UIUtils.isDarkMode(context);
    final buttonColor = isDarkMode ? AppColorsDark.primary : AppColors.primary;
    const textColor = AppColors.white;

    // Determine the icon and text based on available biometrics
    IconData icon;
    String text;

    if (availableBiometrics.contains(BiometricType.face)) {
      icon = Icons.face;
      text = 'Sign in with Face ID';
    } else if (availableBiometrics.contains(BiometricType.fingerprint)) {
      icon = Icons.fingerprint;
      text = 'Sign in with Fingerprint';
    } else if (availableBiometrics.contains(BiometricType.iris)) {
      icon = Icons.remove_red_eye;
      text = 'Sign in with Iris';
    } else {
      icon = Icons.security;
      text = 'Sign in with Biometrics';
    }

    return ElevatedButton.icon(
      onPressed: isEnabled ? onPressed : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: buttonColor,
        foregroundColor: textColor,
        disabledBackgroundColor: AppColors.disabled,
        disabledForegroundColor: AppColors.white,
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      icon: Icon(icon),
      label: Text(text, style: TextStyles.buttonText),
    );
  }
}
