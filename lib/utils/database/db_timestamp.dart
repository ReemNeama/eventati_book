/// Utility class for handling database timestamps
class DbTimestamp {
  /// Convert a DateTime to an ISO 8601 string
  static String fromDate(DateTime date) {
    return date.toIso8601String();
  }

  /// Convert an ISO 8601 string to a DateTime
  static DateTime toDate(String timestamp) {
    return DateTime.parse(timestamp);
  }
}
