import 'package:flutter/material.dart';
import 'package:eventati_book/widgets/common/error_message.dart';
import 'package:eventati_book/widgets/common/error_screen.dart';
import 'package:eventati_book/utils/utils.dart';
import 'package:eventati_book/styles/app_colors.dart';
import 'package:eventati_book/styles/text_styles.dart';
import 'package:eventati_book/utils/ui/error_messages.dart';
import 'package:eventati_book/utils/ui/recovery_suggestions.dart';

/// Utility functions for error handling
class ErrorHandlingUtils {
  /// Get a user-friendly recovery suggestion based on error type
  static String getRecoverySuggestion(dynamic error) {
    if (error == null) {
      return RecoverySuggestions.getGeneralSuggestion();
    }

    return RecoverySuggestions.getSuggestionFromErrorMessage(error.toString());
  }

  /// Show a snackbar with an error message
  static void showErrorSnackBar(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 4),
    VoidCallback? onRetry,
    ErrorSeverity severity = ErrorSeverity.medium,
    String? actionText,
    VoidCallback? onAction,
  }) {
    // Dismiss any existing snackbars
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    // Add haptic feedback for error
    AccessibilityUtils.errorHapticFeedback();

    // Create the snackbar
    final snackBar = SnackBar(
      content: ErrorMessage.toast(
        message: message,
        severity: severity,
        onDismiss: () {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
        },
        autoDismiss: false,
      ),
      backgroundColor: AppColors.transparent,
      elevation: 0,
      duration: duration,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(8),
      padding: EdgeInsets.zero,
      dismissDirection: DismissDirection.horizontal,
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  /// Show a dialog with an error message
  static Future<void> showErrorDialog(
    BuildContext context,
    String title,
    String message, {
    String? details,
    VoidCallback? onRetry,
    String? actionText,
    VoidCallback? onAction,
    ErrorSeverity severity = ErrorSeverity.medium,
  }) async {
    // Add haptic feedback for error
    AccessibilityUtils.errorHapticFeedback();

    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        final isDarkMode = UIUtils.isDarkMode(context);

        return AlertDialog(
          title: Row(
            children: [
              Icon(
                _getIconForSeverity(severity),
                color: _getColorForSeverity(context, severity),
              ),
              const SizedBox(width: 8),
              Text(title),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(message),
                if (details != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(8),
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
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      details,
                      style: TextStyles.bodySmall.copyWith(
                        fontFamily: 'monospace',
                        color:
                            isDarkMode
                                ? Color.fromRGBO(
                                  AppColors.white.r.toInt(),
                                  AppColors.white.g.toInt(),
                                  AppColors.white.b.toInt(),
                                  0.7,
                                )
                                : AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            if (onAction != null)
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  onAction();
                },
                child: Text(actionText ?? 'Action'),
              ),
            if (onRetry != null)
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  onRetry();
                },
                child: const Text('Retry'),
              ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  /// Show a banner error message at the top of the screen
  static void showErrorBanner(
    BuildContext context,
    String message, {
    String? details,
    VoidCallback? onDismiss,
    String? actionText,
    VoidCallback? onAction,
    ErrorSeverity severity = ErrorSeverity.medium,
    Duration autoDismissDuration = const Duration(seconds: 8),
    bool autoDismiss = true,
  }) {
    // Add haptic feedback for error
    AccessibilityUtils.errorHapticFeedback();

    final bannerWidget = ErrorMessage.banner(
      message: message,
      details: details,
      severity: severity,
      onDismiss:
          onDismiss ??
          () {
            // Remove the banner when dismissed
            ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
          },
      actionText: actionText,
      onAction: onAction,
    );

    // Show the banner
    ScaffoldMessenger.of(context).showMaterialBanner(
      MaterialBanner(
        content: bannerWidget,
        backgroundColor: AppColors.transparent,
        elevation: 0,
        padding: EdgeInsets.zero,
        leadingPadding: EdgeInsets.zero,
        forceActionsBelow: true,
        actions: const [SizedBox.shrink()],
      ),
    );

    // Auto-dismiss if enabled
    if (autoDismiss) {
      Future.delayed(autoDismissDuration, () {
        // Check if the context is still valid
        if (context.mounted) {
          ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
        }
      });
    }
  }

  /// Format an exception into a user-friendly message
  static String formatExceptionMessage(dynamic exception) {
    if (exception == null) {
      return ErrorMessages.getGeneralErrorMessage();
    }

    if (exception is String) {
      return exception;
    }

    // Handle common exceptions with user-friendly messages
    if (exception is FormatException) {
      return ErrorMessages.getValidationErrorMessage();
    }

    if (exception is TimeoutException) {
      return ErrorMessages.getTimeoutErrorMessage();
    }

    if (exception is NetworkException) {
      return ErrorMessages.getNetworkErrorMessage();
    }

    return ErrorMessages.getFriendlyMessageFromError(exception);
  }

  /// Get error widget based on error type and context
  static Widget getErrorWidget(
    String message, {
    String? details,
    String? recoverySuggestion,
    VoidCallback? onRetry,
    ErrorDisplayType displayType = ErrorDisplayType.standard,
    ErrorSeverity severity = ErrorSeverity.medium,
    String? actionText,
    VoidCallback? onAction,
    dynamic originalError,
  }) {
    // If no recovery suggestion is provided but we have the original error,
    // generate a recovery suggestion
    final suggestion =
        recoverySuggestion ??
        (originalError != null ? getRecoverySuggestion(originalError) : null);

    return ErrorMessage(
      message: message,
      details: details,
      recoverySuggestion: suggestion,
      onRetry: onRetry,
      displayType: displayType,
      severity: severity,
      actionText: actionText,
      onAction: onAction,
    );
  }

  /// Get a full-screen error widget
  static Widget getErrorScreen(
    String message, {
    String? details,
    String? recoverySuggestion,
    VoidCallback? onRetry,
    VoidCallback? onGoHome,
    String? title,
    IconData? icon,
    Widget? illustration,
    ErrorScreenType errorType = ErrorScreenType.standard,
    String? errorCode,
    String? supportContact,
    dynamic originalError,
  }) {
    // If no recovery suggestion is provided but we have the original error,
    // generate a recovery suggestion
    final suggestion =
        recoverySuggestion ??
        (originalError != null ? getRecoverySuggestion(originalError) : null);

    return ErrorScreen(
      message: message,
      details: details,
      recoverySuggestion: suggestion,
      onRetry: onRetry,
      onGoHome: onGoHome,
      title: title,
      icon: icon,
      illustration: illustration,
      errorType: errorType,
      errorCode: errorCode,
      supportContact: supportContact,
    );
  }

  /// Get a network error screen
  static Widget getNetworkErrorScreen({
    String message = 'We\'re having trouble connecting to the server.',
    String? recoverySuggestion =
        'Check your internet connection and try again. If you\'re connected to WiFi, try switching to mobile data or vice versa.',
    VoidCallback? onRetry,
    VoidCallback? onGoHome,
    String? details,
    Widget? illustration,
  }) {
    return ErrorScreen.network(
      message: message,
      recoverySuggestion: recoverySuggestion,
      onRetry: onRetry,
      onGoHome: onGoHome,
      details: details,
      illustration: illustration,
    );
  }

  /// Get a permission error screen
  static Widget getPermissionErrorScreen({
    String message = 'You don\'t have permission to access this feature.',
    String? recoverySuggestion =
        'If you believe you should have access, please contact your administrator or support team for assistance.',
    VoidCallback? onGoHome,
    String? details,
    Widget? illustration,
  }) {
    return ErrorScreen.permission(
      message: message,
      recoverySuggestion: recoverySuggestion,
      onGoHome: onGoHome,
      details: details,
      illustration: illustration,
    );
  }

  /// Get a server error screen
  static Widget getServerErrorScreen({
    String message = 'Our servers are experiencing issues.',
    String? recoverySuggestion =
        'This is a temporary problem on our end. Please try again later. Our team has been notified and is working to fix it as quickly as possible.',
    VoidCallback? onRetry,
    VoidCallback? onGoHome,
    String? details,
    String? errorCode,
    Widget? illustration,
  }) {
    return ErrorScreen.server(
      message: message,
      recoverySuggestion: recoverySuggestion,
      onRetry: onRetry,
      onGoHome: onGoHome,
      details: details,
      errorCode: errorCode,
      illustration: illustration,
    );
  }

  /// Get the appropriate icon based on severity
  static IconData _getIconForSeverity(ErrorSeverity severity) {
    switch (severity) {
      case ErrorSeverity.low:
        return Icons.info_outline;
      case ErrorSeverity.medium:
        return Icons.warning_amber_outlined;
      case ErrorSeverity.high:
        return Icons.error_outline;
    }
  }

  /// Get the appropriate color based on severity
  static Color _getColorForSeverity(
    BuildContext context,
    ErrorSeverity severity,
  ) {
    final isDarkMode = UIUtils.isDarkMode(context);

    switch (severity) {
      case ErrorSeverity.low:
        return isDarkMode
            ? Color.fromRGBO(
              AppColors.primary.r.toInt(),
              AppColors.primary.g.toInt(),
              AppColors.primary.b.toInt(),
              0.3,
            )
            : AppColors.primary;
      case ErrorSeverity.medium:
        return isDarkMode
            ? Color.fromRGBO(
              AppColors.warning.r.toInt(),
              AppColors.warning.g.toInt(),
              AppColors.warning.b.toInt(),
              0.3,
            )
            : AppColors.warning;
      case ErrorSeverity.high:
        return isDarkMode
            ? Color.fromRGBO(
              AppColors.error.r.toInt(),
              AppColors.error.g.toInt(),
              AppColors.error.b.toInt(),
              0.3,
            )
            : AppColors.error;
    }
  }
}

/// Exception for network-related errors
class NetworkException implements Exception {
  final String message;

  NetworkException(this.message);

  @override
  String toString() => 'NetworkException: $message';
}

/// Exception for timeout errors
class TimeoutException implements Exception {
  final String message;

  TimeoutException(this.message);

  @override
  String toString() => 'TimeoutException: $message';
}
