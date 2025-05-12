/// Utility classes and functions for database operations
/// Platform-agnostic database types and utilities
library;

/// Represents a timestamp in the database
class DbTimestamp {
  /// The date and time
  final DateTime dateTime;

  /// Creates a timestamp from a DateTime
  DbTimestamp(this.dateTime);

  /// Creates a timestamp from the current date and time
  DbTimestamp.now() : dateTime = DateTime.now();

  /// Creates a timestamp from a date
  DbTimestamp.fromDate(DateTime date) : dateTime = date;

  /// Converts the timestamp to a DateTime
  DateTime toDate() => dateTime;

  /// Converts the timestamp to a map
  Map<String, dynamic> toMap() => {
    'seconds': dateTime.millisecondsSinceEpoch ~/ 1000,
    'nanoseconds': (dateTime.millisecondsSinceEpoch % 1000) * 1000000,
  };

  /// Creates a timestamp from a map
  factory DbTimestamp.fromMap(Map<String, dynamic> map) {
    final seconds = map['seconds'] as int;
    final nanoseconds = map['nanoseconds'] as int;
    final milliseconds = seconds * 1000 + (nanoseconds / 1000000).round();
    return DbTimestamp(DateTime.fromMillisecondsSinceEpoch(milliseconds));
  }

  /// Creates a timestamp from an ISO 8601 string
  factory DbTimestamp.fromIso8601String(String iso8601String) {
    return DbTimestamp(DateTime.parse(iso8601String));
  }

  /// Converts the timestamp to an ISO 8601 string
  String toIso8601String() => dateTime.toIso8601String();

  @override
  String toString() => 'DbTimestamp(${dateTime.toIso8601String()})';
}

/// Utility class for database field values
class DbFieldValue {
  /// Private constructor to prevent instantiation
  DbFieldValue._();

  /// Creates a server timestamp field value
  static Map<String, dynamic> serverTimestamp() => {
    '_serverTimestamp': true,
    'timestamp': DateTime.now().toIso8601String(),
  };

  /// Creates an array union field value
  static Map<String, dynamic> arrayUnion(List<dynamic> elements) => {
    '_arrayUnion': true,
    'elements': elements,
  };

  /// Creates an array remove field value
  static Map<String, dynamic> arrayRemove(List<dynamic> elements) => {
    '_arrayRemove': true,
    'elements': elements,
  };

  /// Creates an increment field value
  static Map<String, dynamic> increment(num value) => {
    '_increment': true,
    'value': value,
  };

  /// Creates a delete field value
  static Map<String, dynamic> delete() => {'_delete': true};
}

/// Represents a document snapshot from the database
class DbDocumentSnapshot {
  /// The document ID
  final String id;

  /// The document data
  final Map<String, dynamic> data;

  /// Creates a document snapshot
  DbDocumentSnapshot({required this.id, required this.data});

  /// Gets a field value from the document
  dynamic get(String field) => data[field];

  /// Checks if the document exists
  bool exists() => data.isNotEmpty;

  /// Gets the document data
  Map<String, dynamic> getData() => data;

  @override
  String toString() => 'DbDocumentSnapshot(id: $id, data: $data)';
}

/// Utility functions for working with database documents
class DbDocumentUtils {
  /// Private constructor to prevent instantiation
  DbDocumentUtils._();

  /// Converts a map to a document snapshot
  static DbDocumentSnapshot mapToDocumentSnapshot(
    Map<String, dynamic> map,
    String id,
  ) {
    return DbDocumentSnapshot(id: id, data: map);
  }

  /// Processes timestamps in a map
  static Map<String, dynamic> processTimestamps(Map<String, dynamic> map) {
    final result = <String, dynamic>{};

    for (final entry in map.entries) {
      final key = entry.key;
      final value = entry.value;

      if (value is DateTime) {
        result[key] = DbTimestamp(value).toIso8601String();
      } else if (value is Map<String, dynamic>) {
        result[key] = processTimestamps(value);
      } else if (value is List) {
        result[key] = _processTimestampsList(value);
      } else {
        result[key] = value;
      }
    }

    return result;
  }

  /// Processes timestamps in a list
  static List<dynamic> _processTimestampsList(List<dynamic> list) {
    return list.map((item) {
      if (item is DateTime) {
        return DbTimestamp(item).toIso8601String();
      } else if (item is Map<String, dynamic>) {
        return processTimestamps(item);
      } else if (item is List) {
        return _processTimestampsList(item);
      } else {
        return item;
      }
    }).toList();
  }
}
