import 'package:intl/intl.dart';

/// Utility functions for number operations
class NumberUtils {
  /// Format a number as currency
  static String formatCurrency(
    double amount, {
    String symbol = '\$',
    int decimalPlaces = 2,
  }) {
    final formatter = NumberFormat.currency(
      symbol: symbol,
      decimalDigits: decimalPlaces,
    );

    return formatter.format(amount);
  }

  /// Format a number with commas for thousands
  static String formatWithCommas(num number) {
    final formatter = NumberFormat('#,###');

    return formatter.format(number);
  }

  /// Format a number as a percentage
  static String formatPercentage(double percentage, {int decimalPlaces = 0}) {
    final formatter = NumberFormat.percentPattern();
    formatter.maximumFractionDigits = decimalPlaces;

    return formatter.format(percentage / 100);
  }

  /// Calculate the percentage of a value from a total
  static double calculatePercentage(num value, num total) {
    if (total == 0) return 0;

    return (value / total) * 100;
  }

  /// Round a double to a specific number of decimal places
  static double roundToDecimalPlaces(double value, int places) {
    final mod = 10.0 * places;

    return (value * mod).round() / mod;
  }

  /// Check if a string is a valid number
  static bool isNumeric(String str) {
    return double.tryParse(str) != null;
  }

  /// Convert a number to its ordinal form (1st, 2nd, 3rd, etc.)
  static String toOrdinal(int number) {
    if (number % 100 >= 11 && number % 100 <= 13) {
      return '${number}th';
    }

    switch (number % 10) {
      case 1:
        return '${number}st';
      case 2:
        return '${number}nd';
      case 3:
        return '${number}rd';
      default:
        return '${number}th';
    }
  }
}
