import 'package:intl/intl.dart';

/// Utility functions for date and time operations
class DateTimeUtils {
  /// Format a DateTime object to a readable date string
  static String formatDate(DateTime date, {String format = 'MMM dd, yyyy'}) {
    return DateFormat(format).format(date);
  }

  /// Format a DateTime object to a readable time string
  static String formatTime(DateTime time, {String format = 'h:mm a'}) {
    return DateFormat(format).format(time);
  }

  /// Format a DateTime object to a readable date and time string
  static String formatDateTime(
    DateTime dateTime, {
    String format = 'MMM dd, yyyy - h:mm a',
  }) {
    return DateFormat(format).format(dateTime);
  }

  /// Get a readable string representing the difference between two dates
  static String getDateDifference(DateTime date1, DateTime date2) {
    final difference = date1.difference(date2);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} years';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} months';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} days';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutes';
    } else {
      return 'Just now';
    }
  }

  /// Check if a date is in the future
  static bool isFutureDate(DateTime date) {
    final now = DateTime.now();
    return date.isAfter(now);
  }

  /// Check if a date is today
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  /// Check if two dates are on the same day
  static bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  /// Get a list of dates between two dates
  static List<DateTime> getDatesBetween(DateTime startDate, DateTime endDate) {
    final days = endDate.difference(startDate).inDays + 1;
    return List.generate(
      days,
      (index) =>
          DateTime(startDate.year, startDate.month, startDate.day + index),
    );
  }
}
