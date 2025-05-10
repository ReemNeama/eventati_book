import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents the result of a migration operation
class MigrationResult {
  /// Whether the migration was successful
  final bool success;

  /// Error message if the migration failed
  final String? errorMessage;

  /// Exception that caused the migration to fail
  final dynamic exception;

  /// Number of entities migrated
  final int entitiesMigrated;

  /// Number of entities that failed to migrate
  final int entitiesFailed;

  /// IDs of entities that were successfully migrated
  final List<String> migratedIds;

  /// IDs of entities that failed to migrate
  final List<String> failedIds;

  /// Map of old IDs to new IDs for reference mapping
  final Map<String, String> idMap;

  /// Timestamp when the migration started
  final DateTime startTime;

  /// Timestamp when the migration ended
  final DateTime endTime;

  /// Duration of the migration
  Duration get duration => endTime.difference(startTime);

  /// Constructor
  MigrationResult({
    required this.success,
    this.errorMessage,
    this.exception,
    required this.entitiesMigrated,
    required this.entitiesFailed,
    required this.migratedIds,
    required this.failedIds,
    required this.idMap,
    required this.startTime,
    required this.endTime,
  });

  /// Create a successful migration result
  factory MigrationResult.success({
    required int entitiesMigrated,
    required List<String> migratedIds,
    required Map<String, String> idMap,
    required DateTime startTime,
    required DateTime endTime,
  }) {
    return MigrationResult(
      success: true,
      entitiesMigrated: entitiesMigrated,
      entitiesFailed: 0,
      migratedIds: migratedIds,
      failedIds: const [],
      idMap: idMap,
      startTime: startTime,
      endTime: endTime,
    );
  }

  /// Create a failed migration result
  factory MigrationResult.failure({
    required String errorMessage,
    dynamic exception,
    required int entitiesMigrated,
    required int entitiesFailed,
    required List<String> migratedIds,
    required List<String> failedIds,
    required Map<String, String> idMap,
    required DateTime startTime,
    required DateTime endTime,
  }) {
    return MigrationResult(
      success: false,
      errorMessage: errorMessage,
      exception: exception,
      entitiesMigrated: entitiesMigrated,
      entitiesFailed: entitiesFailed,
      migratedIds: migratedIds,
      failedIds: failedIds,
      idMap: idMap,
      startTime: startTime,
      endTime: endTime,
    );
  }

  /// Convert to a map for storage
  Map<String, dynamic> toMap() {
    return {
      'success': success,
      'errorMessage': errorMessage,
      'entitiesMigrated': entitiesMigrated,
      'entitiesFailed': entitiesFailed,
      'migratedIds': migratedIds,
      'failedIds': failedIds,
      'idMap': idMap,
      'startTime': Timestamp.fromDate(startTime),
      'endTime': Timestamp.fromDate(endTime),
      'durationMilliseconds': duration.inMilliseconds,
    };
  }

  /// Create from a map
  factory MigrationResult.fromMap(Map<String, dynamic> map) {
    return MigrationResult(
      success: map['success'] as bool,
      errorMessage: map['errorMessage'] as String?,
      exception: null,
      entitiesMigrated: map['entitiesMigrated'] as int,
      entitiesFailed: map['entitiesFailed'] as int,
      migratedIds: List<String>.from(map['migratedIds'] as List),
      failedIds: List<String>.from(map['failedIds'] as List),
      idMap: Map<String, String>.from(map['idMap'] as Map),
      startTime: (map['startTime'] as Timestamp).toDate(),
      endTime: (map['endTime'] as Timestamp).toDate(),
    );
  }

  /// Combine multiple migration results
  static MigrationResult combine(List<MigrationResult> results) {
    if (results.isEmpty) {
      return MigrationResult(
        success: true,
        entitiesMigrated: 0,
        entitiesFailed: 0,
        migratedIds: const [],
        failedIds: const [],
        idMap: const {},
        startTime: DateTime.now(),
        endTime: DateTime.now(),
      );
    }

    final success = results.every((result) => result.success);
    final errorMessages = results
        .where((result) => result.errorMessage != null)
        .map((result) => result.errorMessage!)
        .join('; ');
    final entitiesMigrated = results.fold(
      0,
      (total, result) => total + result.entitiesMigrated,
    );
    final entitiesFailed = results.fold(
      0,
      (total, result) => total + result.entitiesFailed,
    );
    final migratedIds = results.expand((result) => result.migratedIds).toList();
    final failedIds = results.expand((result) => result.failedIds).toList();
    final idMap = <String, String>{};
    for (final result in results) {
      idMap.addAll(result.idMap);
    }
    final startTime = results
        .map((result) => result.startTime)
        .reduce((a, b) => a.isBefore(b) ? a : b);
    final endTime = results
        .map((result) => result.endTime)
        .reduce((a, b) => a.isAfter(b) ? a : b);

    return MigrationResult(
      success: success,
      errorMessage: errorMessages.isEmpty ? null : errorMessages,
      exception: null,
      entitiesMigrated: entitiesMigrated,
      entitiesFailed: entitiesFailed,
      migratedIds: migratedIds,
      failedIds: failedIds,
      idMap: idMap,
      startTime: startTime,
      endTime: endTime,
    );
  }
}
