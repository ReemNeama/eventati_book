import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eventati_book/utils/logger.dart';

/// Manager for Firestore offline persistence settings
class OfflinePersistenceManager {
  /// Singleton instance
  static final OfflinePersistenceManager _instance =
      OfflinePersistenceManager._internal();

  /// Firestore instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Whether offline persistence is enabled
  bool _isEnabled = true;

  /// Private constructor
  OfflinePersistenceManager._internal() {
    // Initialize with default settings
    _init();
  }

  /// Factory constructor
  factory OfflinePersistenceManager() => _instance;

  /// Initialize the manager
  void _init() async {
    try {
      // Enable offline persistence by default
      await enablePersistence();
    } catch (e) {
      Logger.e(
        'Error initializing offline persistence: $e',
        tag: 'OfflinePersistenceManager',
      );
    }
  }

  /// Enable offline persistence
  Future<void> enablePersistence({int cacheSizeBytes = 100000000}) async {
    try {
      // Use Settings instead of enablePersistence which is deprecated
      _firestore.settings = Settings(
        persistenceEnabled: true,
        cacheSizeBytes: cacheSizeBytes,
      );
      _isEnabled = true;
      Logger.d(
        'Offline persistence enabled with cache size: $cacheSizeBytes bytes',
        tag: 'OfflinePersistenceManager',
      );
    } catch (e) {
      _isEnabled = false;
      Logger.e(
        'Error enabling offline persistence: $e',
        tag: 'OfflinePersistenceManager',
      );
      rethrow;
    }
  }

  /// Disable offline persistence
  Future<void> disablePersistence() async {
    try {
      await _firestore.clearPersistence();
      _isEnabled = false;
      Logger.d(
        'Offline persistence disabled',
        tag: 'OfflinePersistenceManager',
      );
    } catch (e) {
      Logger.e(
        'Error disabling offline persistence: $e',
        tag: 'OfflinePersistenceManager',
      );
      rethrow;
    }
  }

  /// Clear offline persistence cache
  Future<void> clearPersistence() async {
    try {
      await _firestore.clearPersistence();
      Logger.d(
        'Offline persistence cache cleared',
        tag: 'OfflinePersistenceManager',
      );
    } catch (e) {
      Logger.e(
        'Error clearing offline persistence: $e',
        tag: 'OfflinePersistenceManager',
      );
      rethrow;
    }
  }

  /// Set cache size
  Future<void> setCacheSize(int cacheSizeBytes) async {
    try {
      _firestore.settings = Settings(
        persistenceEnabled: _isEnabled,
        cacheSizeBytes: cacheSizeBytes,
      );
      Logger.d(
        'Cache size set to $cacheSizeBytes bytes',
        tag: 'OfflinePersistenceManager',
      );
    } catch (e) {
      Logger.e(
        'Error setting cache size: $e',
        tag: 'OfflinePersistenceManager',
      );
      rethrow;
    }
  }

  /// Check if offline persistence is enabled
  bool get isEnabled => _isEnabled;

  /// Get the current cache size
  int? get cacheSize => _firestore.settings.cacheSizeBytes;

  /// Wait for pending writes to be acknowledged by the server
  Future<void> waitForPendingWrites() async {
    try {
      await _firestore.waitForPendingWrites();
      Logger.d(
        'All pending writes have been acknowledged by the server',
        tag: 'OfflinePersistenceManager',
      );
    } catch (e) {
      Logger.e(
        'Error waiting for pending writes: $e',
        tag: 'OfflinePersistenceManager',
      );
      rethrow;
    }
  }

  /// Terminate the Firestore instance
  Future<void> terminate() async {
    try {
      await _firestore.terminate();
      Logger.d(
        'Firestore instance terminated',
        tag: 'OfflinePersistenceManager',
      );
    } catch (e) {
      Logger.e(
        'Error terminating Firestore instance: $e',
        tag: 'OfflinePersistenceManager',
      );
      rethrow;
    }
  }
}
