import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:local_auth/local_auth.dart';
import 'package:eventati_book/providers/providers.dart';
import 'package:eventati_book/styles/app_colors.dart';
import 'package:eventati_book/styles/app_colors_dark.dart';
import 'package:eventati_book/styles/text_styles.dart';
import 'package:eventati_book/utils/utils.dart';
import 'package:eventati_book/utils/logger.dart';

/// Screen for managing biometric authentication settings
class BiometricSettingsScreen extends StatefulWidget {
  /// Constructor
  const BiometricSettingsScreen({super.key});

  @override
  State<BiometricSettingsScreen> createState() =>
      _BiometricSettingsScreenState();
}

class _BiometricSettingsScreenState extends State<BiometricSettingsScreen> {
  bool _isBiometricAvailable = false;
  List<BiometricType> _availableBiometrics = [];
  bool _isBiometricEnabled = false;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _checkBiometricAvailability();
  }

  // Check if biometric authentication is available
  Future<void> _checkBiometricAvailability() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

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
          _isLoading = false;
        });
      } else {
        setState(() {
          _isBiometricAvailable = false;
          _isLoading = false;
          _errorMessage =
              'Biometric authentication is not available on this device';
        });
      }
    } catch (e) {
      Logger.e(
        'Error checking biometric availability: $e',
        tag: 'BiometricSettingsScreen',
      );
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error checking biometric availability: $e';
      });
    }
  }

  // Toggle biometric authentication
  Future<void> _toggleBiometricAuthentication(bool value) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      if (value) {
        // Show dialog to get credentials
        final credentials = await _showCredentialsDialog();
        if (credentials == null) {
          setState(() {
            _isLoading = false;
          });
          return;
        }

        // Enable biometric authentication
        final result = await authProvider.enableBiometricAuthentication(
          credentials['email']!,
          credentials['password']!,
        );

        setState(() {
          _isBiometricEnabled = result;
          _isLoading = false;
          if (!result) {
            _errorMessage =
                authProvider.errorMessage ??
                'Failed to enable biometric authentication';
          }
        });
      } else {
        // Disable biometric authentication
        final result = await authProvider.disableBiometricAuthentication();

        setState(() {
          _isBiometricEnabled = !result;
          _isLoading = false;
          if (!result) {
            _errorMessage =
                authProvider.errorMessage ??
                'Failed to disable biometric authentication';
          }
        });
      }
    } catch (e) {
      Logger.e(
        'Error toggling biometric authentication: $e',
        tag: 'BiometricSettingsScreen',
      );
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error toggling biometric authentication: $e';
      });
    }
  }

  // Show dialog to get credentials
  Future<Map<String, String>?> _showCredentialsDialog() async {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    return showDialog<Map<String, String>?>(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            title: const Text('Enter Credentials'),
            content: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) => ValidationUtils.validateEmail(value),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: passwordController,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      prefixIcon: Icon(Icons.lock),
                    ),
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
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    Navigator.pop(context, {
                      'email': emailController.text,
                      'password': passwordController.text,
                    });
                  }
                },
                child: const Text('Save'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = UIUtils.isDarkMode(context);
    final backgroundColor =
        isDarkMode ? AppColorsDark.background : AppColors.background;
    final cardColor = isDarkMode ? AppColorsDark.card : AppColors.card;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text('Biometric Authentication'),
        backgroundColor: isDarkMode ? AppColorsDark.primary : AppColors.primary,
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Error message
                    if (_errorMessage != null) ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Color.fromRGBO(
                            AppColors.error.r.toInt(),
                            AppColors.error.g.toInt(),
                            AppColors.error.b.toInt(),
                            0.1,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error, color: AppColors.error),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                _errorMessage!,
                                style: TextStyles.bodyMedium.copyWith(
                                  color: AppColors.error,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Biometric authentication card
                    Card(
                      color: cardColor,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Biometric Authentication',
                              style: TextStyles.sectionTitle,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Use your fingerprint, face, or other biometric method to sign in to the app.',
                              style: TextStyles.bodyMedium,
                            ),
                            const SizedBox(height: 16),
                            if (!_isBiometricAvailable)
                              Text(
                                'Biometric authentication is not available on this device.',
                                style: TextStyles.bodyMedium.copyWith(
                                  color: AppColors.error,
                                ),
                              )
                            else
                              SwitchListTile(
                                title: Text(
                                  'Enable Biometric Authentication',
                                  style: TextStyles.bodyLarge,
                                ),
                                subtitle: Text(
                                  _isBiometricEnabled
                                      ? 'Biometric authentication is enabled'
                                      : 'Biometric authentication is disabled',
                                  style: TextStyles.bodySmall,
                                ),
                                value: _isBiometricEnabled,
                                onChanged: _toggleBiometricAuthentication,
                                activeColor: AppColors.primary,
                              ),
                          ],
                        ),
                      ),
                    ),

                    // Available biometrics card
                    if (_isBiometricAvailable &&
                        _availableBiometrics.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Card(
                        color: cardColor,
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Available Biometric Methods',
                                style: TextStyles.sectionTitle,
                              ),
                              const SizedBox(height: 16),
                              ...List.generate(
                                _availableBiometrics.length,
                                (index) => ListTile(
                                  leading: Icon(
                                    _getBiometricIcon(
                                      _availableBiometrics[index],
                                    ),
                                    color: AppColors.primary,
                                  ),
                                  title: Text(
                                    _getBiometricName(
                                      _availableBiometrics[index],
                                    ),
                                    style: TextStyles.bodyLarge,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
    );
  }

  // Get icon for biometric type
  IconData _getBiometricIcon(BiometricType type) {
    switch (type) {
      case BiometricType.face:
        return Icons.face;
      case BiometricType.fingerprint:
        return Icons.fingerprint;
      case BiometricType.iris:
        return Icons.remove_red_eye;
      case BiometricType.strong:
      case BiometricType.weak:
        return Icons.security;
    }
  }

  // Get name for biometric type
  String _getBiometricName(BiometricType type) {
    switch (type) {
      case BiometricType.face:
        return 'Face Recognition';
      case BiometricType.fingerprint:
        return 'Fingerprint';
      case BiometricType.iris:
        return 'Iris Scan';
      case BiometricType.strong:
        return 'Strong Biometric';
      case BiometricType.weak:
        return 'Weak Biometric';
    }
  }
}
