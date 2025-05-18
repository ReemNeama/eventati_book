/// Utility class for providing user-friendly error messages
class ErrorMessages {
  /// Get a user-friendly message for a network error
  static String getNetworkErrorMessage() {
    return 'We\'re having trouble connecting to the internet. Please check your connection.';
  }

  /// Get a user-friendly message for an authentication error
  static String getAuthErrorMessage() {
    return 'There was a problem with your login information. Please try again.';
  }

  /// Get a user-friendly message for a permission error
  static String getPermissionErrorMessage() {
    return 'You don\'t have permission to access this feature.';
  }

  /// Get a user-friendly message for a server error
  static String getServerErrorMessage() {
    return 'Our servers are experiencing issues. Please try again later.';
  }

  /// Get a user-friendly message for a timeout error
  static String getTimeoutErrorMessage() {
    return 'The request is taking longer than expected. Please try again.';
  }

  /// Get a user-friendly message for a not found error
  static String getNotFoundErrorMessage() {
    return 'The information you\'re looking for couldn\'t be found.';
  }

  /// Get a user-friendly message for a validation error
  static String getValidationErrorMessage() {
    return 'Please check the information you\'ve entered and try again.';
  }

  /// Get a user-friendly message for a data error
  static String getDataErrorMessage() {
    return 'There was a problem with the data. Please try again.';
  }

  /// Get a user-friendly message for a storage error
  static String getStorageErrorMessage() {
    return 'There was a problem storing or retrieving your data. Please try again later.';
  }

  /// Get a user-friendly message for a general error
  static String getGeneralErrorMessage() {
    return 'Something went wrong. Please try again.';
  }

  /// Get a user-friendly message based on error message content
  static String getFriendlyMessageFromError(dynamic error) {
    if (error == null) {
      return getGeneralErrorMessage();
    }

    final errorMessage = error.toString().toLowerCase();

    if (errorMessage.contains('network') ||
        errorMessage.contains('internet') ||
        errorMessage.contains('connection') ||
        errorMessage.contains('offline') ||
        errorMessage.contains('socket')) {
      return getNetworkErrorMessage();
    }

    if (errorMessage.contains('auth') ||
        errorMessage.contains('login') ||
        errorMessage.contains('password') ||
        errorMessage.contains('credential') ||
        errorMessage.contains('sign in')) {
      return getAuthErrorMessage();
    }

    if (errorMessage.contains('permission') ||
        errorMessage.contains('access') ||
        errorMessage.contains('denied') ||
        errorMessage.contains('unauthorized')) {
      return getPermissionErrorMessage();
    }

    if (errorMessage.contains('server') ||
        errorMessage.contains('500') ||
        errorMessage.contains('503')) {
      return getServerErrorMessage();
    }

    if (errorMessage.contains('timeout') ||
        errorMessage.contains('timed out')) {
      return getTimeoutErrorMessage();
    }

    if (errorMessage.contains('not found') || errorMessage.contains('404')) {
      return getNotFoundErrorMessage();
    }

    if (errorMessage.contains('valid') ||
        errorMessage.contains('format') ||
        errorMessage.contains('required') ||
        errorMessage.contains('input')) {
      return getValidationErrorMessage();
    }

    if (errorMessage.contains('data') ||
        errorMessage.contains('information') ||
        errorMessage.contains('parse')) {
      return getDataErrorMessage();
    }

    if (errorMessage.contains('storage') ||
        errorMessage.contains('space') ||
        errorMessage.contains('disk') ||
        errorMessage.contains('file')) {
      return getStorageErrorMessage();
    }

    return getGeneralErrorMessage();
  }
}
