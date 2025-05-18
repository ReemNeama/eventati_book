/// Utility class for providing recovery suggestions for different error types
class RecoverySuggestions {
  /// Get a recovery suggestion for a network error
  static String getNetworkSuggestion() {
    return 'Check your internet connection and try again. If you\'re connected to WiFi, try switching to mobile data or vice versa. If the problem persists, the server might be temporarily unavailable.';
  }

  /// Get a recovery suggestion for an authentication error
  static String getAuthSuggestion() {
    return 'Please check your login details and try again. If you\'ve forgotten your password, use the reset password option. Make sure you\'re using the correct email address associated with your account.';
  }

  /// Get a recovery suggestion for a permission error
  static String getPermissionSuggestion() {
    return 'You don\'t have permission to perform this action. If you believe this is a mistake, please contact support or your administrator for assistance.';
  }

  /// Get a recovery suggestion for a server error
  static String getServerSuggestion() {
    return 'Our servers are experiencing issues. This is a temporary problem on our end. Please try again later. Our team has been notified and is working to fix it as quickly as possible.';
  }

  /// Get a recovery suggestion for a timeout error
  static String getTimeoutSuggestion() {
    return 'The operation took too long to complete. This could be due to a slow internet connection or high server load. Please try again, and if the problem persists, try again later.';
  }

  /// Get a recovery suggestion for a not found error
  static String getNotFoundSuggestion() {
    return 'The information you\'re looking for couldn\'t be found. It may have been moved, deleted, or never existed. Please check the details and try again.';
  }

  /// Get a recovery suggestion for a validation error
  static String getValidationSuggestion() {
    return 'Please check the information you\'ve entered and try again. Make sure all required fields are filled out correctly and meet any format requirements.';
  }

  /// Get a recovery suggestion for a data error
  static String getDataSuggestion() {
    return 'There was a problem with the data. This could be due to a temporary issue or a problem with the information you\'ve provided. Please try again, and if the problem persists, contact support.';
  }

  /// Get a recovery suggestion for a storage error
  static String getStorageSuggestion() {
    return 'There was a problem storing or retrieving your data. This could be due to insufficient storage space or a temporary server issue. Please try again later.';
  }

  /// Get a recovery suggestion for a general error
  static String getGeneralSuggestion() {
    return 'Something went wrong. Please try again. If the problem persists, try restarting the app or contact support for assistance.';
  }

  /// Get a recovery suggestion based on error message content
  static String getSuggestionFromErrorMessage(String errorMessage) {
    final lowerCaseMessage = errorMessage.toLowerCase();

    if (lowerCaseMessage.contains('network') ||
        lowerCaseMessage.contains('internet') ||
        lowerCaseMessage.contains('connection') ||
        lowerCaseMessage.contains('offline')) {
      return getNetworkSuggestion();
    }

    if (lowerCaseMessage.contains('auth') ||
        lowerCaseMessage.contains('login') ||
        lowerCaseMessage.contains('password') ||
        lowerCaseMessage.contains('credential')) {
      return getAuthSuggestion();
    }

    if (lowerCaseMessage.contains('permission') ||
        lowerCaseMessage.contains('access') ||
        lowerCaseMessage.contains('denied')) {
      return getPermissionSuggestion();
    }

    if (lowerCaseMessage.contains('server') ||
        lowerCaseMessage.contains('500') ||
        lowerCaseMessage.contains('503')) {
      return getServerSuggestion();
    }

    if (lowerCaseMessage.contains('timeout') ||
        lowerCaseMessage.contains('timed out')) {
      return getTimeoutSuggestion();
    }

    if (lowerCaseMessage.contains('not found') ||
        lowerCaseMessage.contains('404')) {
      return getNotFoundSuggestion();
    }

    if (lowerCaseMessage.contains('valid') ||
        lowerCaseMessage.contains('format') ||
        lowerCaseMessage.contains('required')) {
      return getValidationSuggestion();
    }

    if (lowerCaseMessage.contains('data') ||
        lowerCaseMessage.contains('information')) {
      return getDataSuggestion();
    }

    if (lowerCaseMessage.contains('storage') ||
        lowerCaseMessage.contains('space') ||
        lowerCaseMessage.contains('disk')) {
      return getStorageSuggestion();
    }

    return getGeneralSuggestion();
  }
}
