/// Utility functions for form validation
class ValidationUtils {
  /// Validate that a field is not empty
  static String? validateRequired(String? value, {String message = 'This field is required'}) {
    if (value == null || value.isEmpty) {
      return message;
    }
    return null;
  }

  /// Validate email format
  static String? validateEmail(String? value, {String message = 'Please enter a valid email address'}) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    
    final emailRegExp = RegExp(
      r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+',
    );
    
    if (!emailRegExp.hasMatch(value)) {
      return message;
    }
    
    return null;
  }

  /// Validate phone number format
  static String? validatePhoneNumber(String? value, {String message = 'Please enter a valid phone number'}) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    
    final phoneRegExp = RegExp(
      r'^\+?[0-9]{10,15}$',
    );
    
    if (!phoneRegExp.hasMatch(value.replaceAll(RegExp(r'\D'), ''))) {
      return message;
    }
    
    return null;
  }

  /// Validate password strength
  static String? validatePassword(String? value, {
    int minLength = 8,
    bool requireUppercase = true,
    bool requireLowercase = true,
    bool requireNumbers = true,
    bool requireSpecialChars = true,
  }) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    
    if (value.length < minLength) {
      return 'Password must be at least $minLength characters long';
    }
    
    if (requireUppercase && !value.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter';
    }
    
    if (requireLowercase && !value.contains(RegExp(r'[a-z]'))) {
      return 'Password must contain at least one lowercase letter';
    }
    
    if (requireNumbers && !value.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number';
    }
    
    if (requireSpecialChars && !value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return 'Password must contain at least one special character';
    }
    
    return null;
  }

  /// Validate that a value is a number
  static String? validateNumber(String? value, {String message = 'Please enter a valid number'}) {
    if (value == null || value.isEmpty) {
      return 'This field is required';
    }
    
    if (double.tryParse(value) == null) {
      return message;
    }
    
    return null;
  }

  /// Validate that a number is within a range
  static String? validateNumberRange(String? value, {
    double? min,
    double? max,
    String? minMessage,
    String? maxMessage,
  }) {
    final numberValidation = validateNumber(value);
    if (numberValidation != null) {
      return numberValidation;
    }
    
    final number = double.parse(value!);
    
    if (min != null && number < min) {
      return minMessage ?? 'Value must be at least $min';
    }
    
    if (max != null && number > max) {
      return maxMessage ?? 'Value must be at most $max';
    }
    
    return null;
  }

  /// Validate that two passwords match
  static String? validatePasswordsMatch(String? password, String? confirmPassword) {
    if (password != confirmPassword) {
      return 'Passwords do not match';
    }
    return null;
  }
}
