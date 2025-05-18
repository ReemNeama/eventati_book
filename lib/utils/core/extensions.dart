import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:eventati_book/styles/app_colors.dart';


/// Extension methods for built-in types and Flutter widgets

// String extensions
extension StringExtensions on String {
  /// Capitalize the first letter of the string
  String capitalize() {
    if (isEmpty) return this;

    return '${this[0].toUpperCase()}${substring(1)}';
  }

  /// Capitalize each word in the string
  String capitalizeEachWord() {
    if (isEmpty) return this;

    return split(' ').map((word) => word.capitalize()).join(' ');
  }

  /// Check if the string is a valid email
  bool get isValidEmail {
    return RegExp(r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+').hasMatch(this);
  }

  /// Check if the string is a valid phone number
  bool get isValidPhoneNumber {
    return RegExp(r'^\+?[0-9]{10,15}$').hasMatch(this);
  }

  /// Check if the string is a valid URL
  bool get isValidUrl {
    return RegExp(
      r'^(http|https)://[a-zA-Z0-9]+([\-\.]{1}[a-zA-Z0-9]+)*\.[a-zA-Z]{2,5}(:[0-9]{1,5})?(\/.*)?$',
    ).hasMatch(this);
  }

  /// Remove all HTML tags from the string
  String get stripHtml {
    return replaceAll(RegExp(r'<[^>]*>'), '');
  }

  /// Truncate the string to a maximum length and add ellipsis if needed
  String truncate(int maxLength, {String ellipsis = '...'}) {
    if (length <= maxLength) return this;

    return '${substring(0, maxLength)}$ellipsis';
  }
}

// DateTime extensions
extension DateTimeExtensions on DateTime {
  /// Format the date using a specific format
  String format({String format = 'MMM dd, yyyy'}) {
    return DateFormat(format).format(this);
  }

  /// Check if the date is today
  bool get isToday {
    final now = DateTime.now();

    return year == now.year && month == now.month && day == now.day;
  }

  /// Check if the date is yesterday
  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));

    return year == yesterday.year &&
        month == yesterday.month &&
        day == yesterday.day;
  }

  /// Check if the date is tomorrow
  bool get isTomorrow {
    final tomorrow = DateTime.now().add(const Duration(days: 1));

    return year == tomorrow.year &&
        month == tomorrow.month &&
        day == tomorrow.day;
  }

  /// Check if the date is in the future
  bool get isFuture {
    return isAfter(DateTime.now());
  }

  /// Check if the date is in the past
  bool get isPast {
    return isBefore(DateTime.now());
  }

  /// Get the date without the time component
  DateTime get dateOnly {
    return DateTime(year, month, day);
  }

  /// Add days to the date
  DateTime addDays(int days) {
    return add(Duration(days: days));
  }

  /// Subtract days from the date
  DateTime subtractDays(int days) {
    return subtract(Duration(days: days));
  }
}

// BuildContext extensions
extension BuildContextExtensions on BuildContext {
  /// Get the screen size
  Size get screenSize => MediaQuery.of(this).size;

  /// Get the screen width
  double get screenWidth => screenSize.width;

  /// Get the screen height
  double get screenHeight => screenSize.height;

  /// Check if the device is in dark mode
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  /// Check if the device is a tablet
  bool get isTablet => screenSize.shortestSide >= 600;

  /// Get the theme
  ThemeData get theme => Theme.of(this);

  /// Get the text theme
  TextTheme get textTheme => theme.textTheme;

  /// Get the color scheme
  ColorScheme get colorScheme => theme.colorScheme;

  /// Show a snackbar
  void showSnackBar(
    String message, {
    Duration duration = const Duration(seconds: 2),
    Color? backgroundColor,
    Color? textColor,
  }) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(color: textColor)),
        duration: duration,
        backgroundColor: backgroundColor,
      ),
    );
  }

  /// Show a success snackbar
  void showSuccessSnackBar(
    String message, {
    Duration duration = const Duration(seconds: 2),
  }) {
    showSnackBar(
      message,
      backgroundColor: AppColors.success,
      textColor: Colors.white,
      duration: duration,
    );
  }

  /// Show an error snackbar
  void showErrorSnackBar(
    String message, {
    Duration duration = const Duration(seconds: 2),
  }) {
    showSnackBar(
      message,
      backgroundColor: AppColors.error,
      textColor: Colors.white,
      duration: duration,
    );
  }
}

// List extensions
extension ListExtensions<T> on List<T> {
  /// Get a random item from the list
  T get randomItem {
    if (isEmpty) {
      throw Exception('Cannot get a random item from an empty list');
    }

    return this[DateTime.now().millisecondsSinceEpoch % length];
  }

  /// Check if the list is empty or null
  bool get isNullOrEmpty => isEmpty;

  /// Check if the list is not empty
  bool get isNotEmpty => !isEmpty;

  /// Get the first item or null if the list is empty
  T? get firstOrNull => isEmpty ? null : first;

  /// Get the last item or null if the list is empty
  T? get lastOrNull => isEmpty ? null : last;
}

// Num extensions
extension NumExtensions on num {
  /// Format the number as currency
  String toCurrency({String symbol = '\$', int decimalPlaces = 2}) {
    final formatter = NumberFormat.currency(
      symbol: symbol,
      decimalDigits: decimalPlaces,
    );

    return formatter.format(this);
  }

  /// Format the number with commas for thousands
  String toFormattedString() {
    final formatter = NumberFormat('#,###');

    return formatter.format(this);
  }

  /// Format the number as a percentage
  String toPercentage({int decimalPlaces = 0}) {
    final formatter = NumberFormat.percentPattern();
    formatter.maximumFractionDigits = decimalPlaces;

    return formatter.format(this / 100);
  }

  /// Convert the number to its ordinal form (1st, 2nd, 3rd, etc.)
  String toOrdinal() {
    if (this % 100 >= 11 && this % 100 <= 13) {
      return '${this}th';
    }

    switch (this % 10) {
      case 1:
        return '${this}st';
      case 2:
        return '${this}nd';
      case 3:
        return '${this}rd';
      default:
        return '${this}th';
    }
  }
}
