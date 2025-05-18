import 'package:flutter/material.dart';
import 'package:eventati_book/styles/app_colors.dart';
import 'package:eventati_book/styles/app_colors_dark.dart';
import 'package:eventati_book/utils/utils.dart';

/// Error screen type for different visual presentations
enum ErrorScreenType {
  /// Standard full-screen error
  standard,

  /// Minimal error with less visual elements
  minimal,

  /// Network error specific layout
  network,

  /// Permission error specific layout
  permission,

  /// Server error specific layout
  server,
}

/// A full-screen error widget for critical errors
class ErrorScreen extends StatelessWidget {
  /// The error message to display
  final String message;

  /// Optional error details
  final String? details;

  /// Optional retry callback
  final VoidCallback? onRetry;

  /// Optional home navigation callback
  final VoidCallback? onGoHome;

  /// Optional custom title (defaults to "Something went wrong")
  final String? title;

  /// Optional custom icon
  final IconData? icon;

  /// Optional custom illustration widget
  final Widget? illustration;

  /// Error screen type for different visual presentations
  final ErrorScreenType errorType;

  /// Optional error code to display
  final String? errorCode;

  /// Optional support contact information
  final String? supportContact;

  /// Creates a full-screen error widget
  const ErrorScreen({
    super.key,
    required this.message,
    this.details,
    this.onRetry,
    this.onGoHome,
    this.title,
    this.icon,
    this.illustration,
    this.errorType = ErrorScreenType.standard,
    this.errorCode,
    this.supportContact,
  });

  /// Factory constructor for network errors
  factory ErrorScreen.network({
    String message =
        'Unable to connect to the server. Please check your internet connection and try again.',
    VoidCallback? onRetry,
    VoidCallback? onGoHome,
    String? details,
  }) {
    return ErrorScreen(
      title: 'Network Error',
      message: message,
      details: details,
      onRetry: onRetry,
      onGoHome: onGoHome,
      icon: Icons.wifi_off,
      errorType: ErrorScreenType.network,
    );
  }

  /// Factory constructor for permission errors
  factory ErrorScreen.permission({
    String message = 'You don\'t have permission to access this feature.',
    VoidCallback? onGoHome,
    String? details,
  }) {
    return ErrorScreen(
      title: 'Access Denied',
      message: message,
      details: details,
      onGoHome: onGoHome,
      icon: Icons.no_accounts,
      errorType: ErrorScreenType.permission,
    );
  }

  /// Factory constructor for server errors
  factory ErrorScreen.server({
    String message =
        'The server encountered an error. Our team has been notified.',
    VoidCallback? onRetry,
    VoidCallback? onGoHome,
    String? details,
    String? errorCode,
  }) {
    return ErrorScreen(
      title: 'Server Error',
      message: message,
      details: details,
      onRetry: onRetry,
      onGoHome: onGoHome,
      icon: Icons.cloud_off,
      errorType: ErrorScreenType.server,
      errorCode: errorCode,
      supportContact: 'support@eventati.com',
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = UIUtils.isDarkMode(context);
    final errorColor = isDarkMode ? AppColorsDark.error : AppColors.error;
    final primaryColor = isDarkMode ? AppColorsDark.primary : AppColors.primary;
    final backgroundColor =
        isDarkMode
            ? Color.fromRGBO(
              AppColors.disabled.r.toInt(),
              AppColors.disabled.g.toInt(),
              AppColors.disabled.b.toInt(),
              0.9,
            )
            : Color.fromRGBO(
              AppColors.disabled.r.toInt(),
              AppColors.disabled.g.toInt(),
              AppColors.disabled.b.toInt(),
              0.1,
            );
    final textColor =
        isDarkMode
            ? Color.fromRGBO(
              Colors.white.r.toInt(),
              Colors.white.g.toInt(),
              Colors.white.b.toInt(),
              0.7,
            )
            : AppColors.textPrimary;

    // Get responsive values
    final isTablet =
        ResponsiveUtils.getDeviceType(context) != DeviceType.mobile;
    final iconSize = ResponsiveUtils.getResponsiveValue(
      context: context,
      mobile: 64.0,
      tablet: 80.0,
      desktop: 96.0,
    );
    final titleSize = ResponsiveUtils.getResponsiveValue(
      context: context,
      mobile: 24.0,
      tablet: 28.0,
      desktop: 32.0,
    );
    final messageSize = ResponsiveUtils.getResponsiveValue(
      context: context,
      mobile: 16.0,
      tablet: 18.0,
      desktop: 20.0,
    );

    // Determine icon based on error type if not explicitly provided
    final IconData displayIcon = icon ?? _getIconForErrorType(errorType);

    // Determine title based on error type if not explicitly provided
    final String displayTitle = title ?? _getTitleForErrorType(errorType);

    // Add haptic feedback for error
    AccessibilityUtils.errorHapticFeedback();

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isTablet ? 600 : double.infinity,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Use illustration if provided, otherwise use icon
                  if (illustration != null)
                    illustration!
                  else
                    Icon(
                      displayIcon,
                      color: errorColor,
                      size: iconSize,
                      semanticLabel: '$displayTitle icon',
                    ),
                  const SizedBox(height: 24),
                  Text(
                    displayTitle,
                    style: TextStyle(
                      color: errorColor,
                      fontSize: titleSize,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    message,
                    style: TextStyle(color: textColor, fontSize: messageSize),
                    textAlign: TextAlign.center,
                  ),
                  if (errorCode != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Error code: $errorCode',
                      style: TextStyle(
                        color:
                            isDarkMode
                                ? Color.fromRGBO(
                                  Colors.white.r.toInt(),
                                  Colors.white.g.toInt(),
                                  Colors.white.b.toInt(),
                                  0.6,
                                )
                                : AppColors.textSecondary,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  if (details != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color:
                            isDarkMode
                                ? Color.fromRGBO(
                                  AppColors.disabled.r.toInt(),
                                  AppColors.disabled.g.toInt(),
                                  AppColors.disabled.b.toInt(),
                                  0.8,
                                )
                                : Color.fromRGBO(
                                  AppColors.disabled.r.toInt(),
                                  AppColors.disabled.g.toInt(),
                                  AppColors.disabled.b.toInt(),
                                  0.2,
                                ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        details ?? '',
                        style: TextStyle(
                          color:
                              isDarkMode
                                  ? Color.fromRGBO(
                                    Colors.white.r.toInt(),
                                    Colors.white.g.toInt(),
                                    Colors.white.b.toInt(),
                                    0.6,
                                  )
                                  : AppColors.textSecondary,
                          fontSize: 14,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 32),
                  if (onRetry != null)
                    ElevatedButton.icon(
                      onPressed: () {
                        AccessibilityUtils.buttonPressHapticFeedback();
                        onRetry?.call();
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                    ),
                  if (onRetry != null && onGoHome != null)
                    const SizedBox(height: 16),
                  if (onGoHome != null)
                    TextButton.icon(
                      onPressed: () {
                        AccessibilityUtils.buttonPressHapticFeedback();
                        onGoHome?.call();
                      },
                      icon: const Icon(Icons.home),
                      label: const Text('Go to Home'),
                      style: TextButton.styleFrom(
                        foregroundColor: primaryColor,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                    ),
                  if (supportContact != null) ...[
                    const SizedBox(height: 24),
                    Text(
                      'Need help? Contact $supportContact',
                      style: TextStyle(
                        color:
                            isDarkMode
                                ? Color.fromRGBO(
                                  Colors.white.r.toInt(),
                                  Colors.white.g.toInt(),
                                  Colors.white.b.toInt(),
                                  0.6,
                                )
                                : AppColors.textSecondary,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Get the appropriate icon based on error type
  IconData _getIconForErrorType(ErrorScreenType type) {
    switch (type) {
      case ErrorScreenType.network:
        return Icons.wifi_off;
      case ErrorScreenType.permission:
        return Icons.no_accounts;
      case ErrorScreenType.server:
        return Icons.cloud_off;
      case ErrorScreenType.minimal:
        return Icons.info_outline;
      case ErrorScreenType.standard:
        return Icons.error_outline;
    }
  }

  /// Get the appropriate title based on error type
  String _getTitleForErrorType(ErrorScreenType type) {
    switch (type) {
      case ErrorScreenType.network:
        return 'Network Error';
      case ErrorScreenType.permission:
        return 'Access Denied';
      case ErrorScreenType.server:
        return 'Server Error';
      case ErrorScreenType.minimal:
      case ErrorScreenType.standard:
        return 'Something went wrong';
    }
  }
}
