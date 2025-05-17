import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:eventati_book/utils/logger.dart';

/// Service for caching data
///
/// This service provides methods for caching data in memory and on disk.
/// It supports time-based cache invalidation and automatic cache cleanup.
class CacheService {
  /// Singleton instance
  static final CacheService _instance = CacheService._internal();

  /// Factory constructor
  factory CacheService() => _instance;

  /// Internal constructor
  CacheService._internal();

  /// In-memory cache
  final Map<String, _CacheEntry> _memoryCache = {};

  /// Shared preferences instance
  SharedPreferences? _prefs;

  /// Initialize the cache service
  Future<void> initialize() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      _cleanupExpiredDiskCache();
    } catch (e) {
      Logger.e('Error initializing cache service: $e', tag: 'CacheService');
    }
  }

  /// Get a value from the cache
  ///
  /// [key] The cache key
  /// [fetchFromDisk] Whether to fetch from disk if not found in memory
  /// Returns the cached value, or null if not found
  T? get<T>(String key, {bool fetchFromDisk = true}) {
    // Check memory cache first
    if (_memoryCache.containsKey(key)) {
      final entry = _memoryCache[key]!;

      // Check if the entry has expired
      if (entry.expiresAt != null &&
          entry.expiresAt!.isBefore(DateTime.now())) {
        // Remove expired entry
        _memoryCache.remove(key);
        return null;
      }

      return entry.value as T?;
    }

    // If not in memory and fetchFromDisk is true, check disk cache
    if (fetchFromDisk) {
      return _getFromDisk<T>(key);
    }

    return null;
  }

  /// Set a value in the cache
  ///
  /// [key] The cache key
  /// [value] The value to cache
  /// [expiresIn] How long the cache entry should be valid
  /// [saveToDisk] Whether to save to disk as well
  void set<T>(
    String key,
    T value, {
    Duration? expiresIn,
    bool saveToDisk = false,
  }) {
    final expiresAt = expiresIn != null ? DateTime.now().add(expiresIn) : null;

    // Save to memory cache
    _memoryCache[key] = _CacheEntry(value: value, expiresAt: expiresAt);

    // Save to disk if requested
    if (saveToDisk) {
      _saveToDisk(key, value, expiresAt: expiresAt);
    }
  }

  /// Remove a value from the cache
  ///
  /// [key] The cache key
  /// [removeFromDisk] Whether to remove from disk as well
  void remove(String key, {bool removeFromDisk = false}) {
    // Remove from memory cache
    _memoryCache.remove(key);

    // Remove from disk if requested
    if (removeFromDisk && _prefs != null) {
      _prefs!.remove(key);
      _prefs!.remove('${key}_expires');
    }
  }

  /// Clear the entire cache
  ///
  /// [clearDisk] Whether to clear the disk cache as well
  void clear({bool clearDisk = false}) {
    // Clear memory cache
    _memoryCache.clear();

    // Clear disk cache if requested
    if (clearDisk && _prefs != null) {
      final keys = _prefs!.getKeys();
      for (final key in keys) {
        if (key.endsWith('_expires') || _prefs!.containsKey('${key}_expires')) {
          _prefs!.remove(key);
        }
      }
    }
  }

  /// Check if a key exists in the cache
  ///
  /// [key] The cache key
  /// [checkDisk] Whether to check the disk cache as well
  /// Returns true if the key exists and has not expired
  bool containsKey(String key, {bool checkDisk = false}) {
    // Check memory cache
    if (_memoryCache.containsKey(key)) {
      final entry = _memoryCache[key]!;

      // Check if the entry has expired
      if (entry.expiresAt != null &&
          entry.expiresAt!.isBefore(DateTime.now())) {
        // Remove expired entry
        _memoryCache.remove(key);
        return false;
      }

      return true;
    }

    // Check disk cache if requested
    if (checkDisk && _prefs != null) {
      final expiresKey = '${key}_expires';

      if (_prefs!.containsKey(key) && _prefs!.containsKey(expiresKey)) {
        final expiresAtString = _prefs!.getString(expiresKey);

        if (expiresAtString != null) {
          final expiresAt = DateTime.parse(expiresAtString);

          // Check if the entry has expired
          if (expiresAt.isBefore(DateTime.now())) {
            // Remove expired entry
            _prefs!.remove(key);
            _prefs!.remove(expiresKey);
            return false;
          }

          return true;
        }
      }

      return _prefs!.containsKey(key);
    }

    return false;
  }

  /// Get a value from the disk cache
  ///
  /// [key] The cache key
  /// Returns the cached value, or null if not found or expired
  T? _getFromDisk<T>(String key) {
    if (_prefs == null) {
      return null;
    }

    // Check if the key exists
    if (!_prefs!.containsKey(key)) {
      return null;
    }

    // Check if the entry has expired
    final expiresKey = '${key}_expires';
    if (_prefs!.containsKey(expiresKey)) {
      final expiresAtString = _prefs!.getString(expiresKey);

      if (expiresAtString != null) {
        final expiresAt = DateTime.parse(expiresAtString);

        // Check if the entry has expired
        if (expiresAt.isBefore(DateTime.now())) {
          // Remove expired entry
          _prefs!.remove(key);
          _prefs!.remove(expiresKey);
          return null;
        }
      }
    }

    // Get the value
    final value = _prefs!.getString(key);
    if (value == null) {
      return null;
    }

    try {
      // Decode the JSON value
      final decodedValue = jsonDecode(value);

      // Cache in memory for faster access next time
      _memoryCache[key] = _CacheEntry(
        value: decodedValue,
        expiresAt:
            _prefs!.containsKey(expiresKey)
                ? DateTime.parse(_prefs!.getString(expiresKey)!)
                : null,
      );

      return decodedValue as T?;
    } catch (e) {
      Logger.e('Error decoding cached value: $e', tag: 'CacheService');
      return null;
    }
  }

  /// Save a value to the disk cache
  ///
  /// [key] The cache key
  /// [value] The value to cache
  /// [expiresAt] When the cache entry should expire
  void _saveToDisk<T>(String key, T value, {DateTime? expiresAt}) {
    if (_prefs == null) {
      return;
    }

    try {
      // Encode the value as JSON
      final encodedValue = jsonEncode(value);

      // Save the value
      _prefs!.setString(key, encodedValue);

      // Save the expiration time if provided
      if (expiresAt != null) {
        _prefs!.setString('${key}_expires', expiresAt.toIso8601String());
      }
    } catch (e) {
      Logger.e('Error saving to disk cache: $e', tag: 'CacheService');
    }
  }

  /// Clean up expired entries in the disk cache
  void _cleanupExpiredDiskCache() {
    if (_prefs == null) {
      return;
    }

    final now = DateTime.now();
    final keys = _prefs!.getKeys();

    for (final key in keys) {
      if (key.endsWith('_expires')) {
        final expiresAtString = _prefs!.getString(key);

        if (expiresAtString != null) {
          final expiresAt = DateTime.parse(expiresAtString);

          // Check if the entry has expired
          if (expiresAt.isBefore(now)) {
            // Remove expired entry
            final dataKey = key.substring(
              0,
              key.length - 8,
            ); // Remove '_expires'
            _prefs!.remove(dataKey);
            _prefs!.remove(key);
          }
        }
      }
    }
  }
}

/// Cache entry for in-memory cache
class _CacheEntry {
  /// The cached value
  final dynamic value;

  /// When the cache entry expires
  final DateTime? expiresAt;

  /// Creates a cache entry
  _CacheEntry({required this.value, this.expiresAt});
}
