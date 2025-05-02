import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:eventati_book/utils/validation_utils.dart';

/// Utility functions for form-related operations
class FormUtils {
  /// Get a text input formatter for numbers only
  static List<TextInputFormatter> getNumberFormatters() {
    return [FilteringTextInputFormatter.digitsOnly];
  }

  /// Get a text input formatter for currency input
  static List<TextInputFormatter> getCurrencyFormatters() {
    return [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))];
  }

  /// Get a text input formatter for phone numbers
  static List<TextInputFormatter> getPhoneFormatters() {
    return [
      FilteringTextInputFormatter.allow(RegExp(r'[0-9\+\-\(\) ]')),
      LengthLimitingTextInputFormatter(15),
    ];
  }

  /// Get a text input formatter for names (letters, spaces, hyphens, apostrophes)
  static List<TextInputFormatter> getNameFormatters() {
    return [FilteringTextInputFormatter.allow(RegExp(r"[a-zA-Z\s\-']"))];
  }

  /// Get a text input formatter for email addresses
  static List<TextInputFormatter> getEmailFormatters() {
    return [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9@\.\-_]'))];
  }

  /// Format error message for display
  static String formatErrorMessage(String? errorMessage) {
    if (errorMessage == null || errorMessage.isEmpty) {
      return '';
    }

    // Ensure the error message starts with a capital letter
    final formattedMessage =
        errorMessage[0].toUpperCase() + errorMessage.substring(1);

    // Add a period if the message doesn't end with punctuation
    if (!formattedMessage.endsWith('.') &&
        !formattedMessage.endsWith('!') &&
        !formattedMessage.endsWith('?')) {
      return '$formattedMessage.';
    }

    return formattedMessage;
  }

  /// Create a standard form field decoration
  static InputDecoration createInputDecoration({
    required String label,
    String? hint,
    Widget? prefixIcon,
    Widget? suffixIcon,
    String? errorText,
    bool isDense = false,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      errorText: errorText != null && errorText.isNotEmpty ? errorText : null,
      isDense: isDense,
      border: const OutlineInputBorder(),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
    );
  }

  /// Validate a form and return whether it's valid
  static bool validateForm(GlobalKey<FormState> formKey) {
    return formKey.currentState?.validate() ?? false;
  }

  /// Reset a form
  static void resetForm(GlobalKey<FormState> formKey) {
    formKey.currentState?.reset();
  }

  /// Save a form
  static void saveForm(GlobalKey<FormState> formKey) {
    formKey.currentState?.save();
  }

  /// Create a standard form validator for required fields
  static String? Function(String?) requiredValidator(String fieldName) {
    return (value) => ValidationUtils.validateRequired(
      value,
      message: '$fieldName is required',
    );
  }

  /// Create a standard form validator for email fields
  static String? Function(String?) emailValidator() {
    return (value) => ValidationUtils.validateEmail(value);
  }

  /// Create a standard form validator for phone number fields
  static String? Function(String?) phoneValidator() {
    return (value) => ValidationUtils.validatePhoneNumber(value);
  }

  /// Create a standard form validator for password fields
  static String? Function(String?) passwordValidator({
    int minLength = 8,
    bool requireUppercase = true,
    bool requireLowercase = true,
    bool requireNumbers = true,
    bool requireSpecialChars = true,
  }) {
    return (value) => ValidationUtils.validatePassword(
      value,
      minLength: minLength,
      requireUppercase: requireUppercase,
      requireLowercase: requireLowercase,
      requireNumbers: requireNumbers,
      requireSpecialChars: requireSpecialChars,
    );
  }

  /// Create a standard form validator for number fields
  static String? Function(String?) numberValidator({
    String message = 'Please enter a valid number',
  }) {
    return (value) => ValidationUtils.validateNumber(value, message: message);
  }
}
