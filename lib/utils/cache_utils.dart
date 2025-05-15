import 'package:eventati_book/services/cache/cache_service.dart';

/// Utility class for working with the cache
class CacheUtils {
  /// Private constructor to prevent instantiation
  CacheUtils._();

  /// Cache service instance
  static final CacheService _cacheService = CacheService();

  /// Initialize the cache utils
  static Future<void> initialize() async {
    await _cacheService.initialize();
  }

  /// Cache key prefix for services
  static const String _servicePrefix = 'service_';

  /// Cache key prefix for users
  static const String _userPrefix = 'user_';

  /// Cache key prefix for events
  static const String _eventPrefix = 'event_';

  /// Cache key prefix for collections
  static const String _collectionPrefix = 'collection_';

  /// Cache key prefix for queries
  static const String _queryPrefix = 'query_';

  /// Cache key prefix for images
  static const String _imagePrefix = 'image_';

  /// Default cache duration
  static const Duration defaultCacheDuration = Duration(minutes: 30);

  /// Long cache duration for rarely changing data
  static const Duration longCacheDuration = Duration(hours: 24);

  /// Short cache duration for frequently changing data
  static const Duration shortCacheDuration = Duration(minutes: 5);

  /// Get a service from the cache
  ///
  /// [serviceId] The ID of the service
  /// Returns the cached service, or null if not found
  static Map<String, dynamic>? getService(String serviceId) {
    return _cacheService.get<Map<String, dynamic>>('$_servicePrefix$serviceId');
  }

  /// Cache a service
  ///
  /// [serviceId] The ID of the service
  /// [service] The service data to cache
  /// [duration] How long to cache the service
  static void cacheService(
    String serviceId,
    Map<String, dynamic> service, {
    Duration duration = defaultCacheDuration,
  }) {
    _cacheService.set(
      '$_servicePrefix$serviceId',
      service,
      expiresIn: duration,
      saveToDisk: true,
    );
  }

  /// Get a user from the cache
  ///
  /// [userId] The ID of the user
  /// Returns the cached user, or null if not found
  static Map<String, dynamic>? getUser(String userId) {
    return _cacheService.get<Map<String, dynamic>>('$_userPrefix$userId');
  }

  /// Cache a user
  ///
  /// [userId] The ID of the user
  /// [user] The user data to cache
  /// [duration] How long to cache the user
  static void cacheUser(
    String userId,
    Map<String, dynamic> user, {
    Duration duration = defaultCacheDuration,
  }) {
    _cacheService.set(
      '$_userPrefix$userId',
      user,
      expiresIn: duration,
      saveToDisk: true,
    );
  }

  /// Get an event from the cache
  ///
  /// [eventId] The ID of the event
  /// Returns the cached event, or null if not found
  static Map<String, dynamic>? getEvent(String eventId) {
    return _cacheService.get<Map<String, dynamic>>('$_eventPrefix$eventId');
  }

  /// Cache an event
  ///
  /// [eventId] The ID of the event
  /// [event] The event data to cache
  /// [duration] How long to cache the event
  static void cacheEvent(
    String eventId,
    Map<String, dynamic> event, {
    Duration duration = defaultCacheDuration,
  }) {
    _cacheService.set(
      '$_eventPrefix$eventId',
      event,
      expiresIn: duration,
      saveToDisk: true,
    );
  }

  /// Get a collection from the cache
  ///
  /// [collection] The name of the collection
  /// [page] The page number (0-based)
  /// [pageSize] The number of items per page
  /// Returns the cached collection, or null if not found
  static List<Map<String, dynamic>>? getCollection(
    String collection, {
    int? page,
    int? pageSize,
  }) {
    final key = _getCollectionKey(collection, page, pageSize);
    return _cacheService.get<List<Map<String, dynamic>>>(key);
  }

  /// Cache a collection
  ///
  /// [collection] The name of the collection
  /// [data] The collection data to cache
  /// [page] The page number (0-based)
  /// [pageSize] The number of items per page
  /// [duration] How long to cache the collection
  static void cacheCollection(
    String collection,
    List<Map<String, dynamic>> data, {
    int? page,
    int? pageSize,
    Duration duration = shortCacheDuration,
  }) {
    final key = _getCollectionKey(collection, page, pageSize);
    _cacheService.set(
      key,
      data,
      expiresIn: duration,
      saveToDisk: false, // Don't save collections to disk to save space
    );
  }

  /// Get a query result from the cache
  ///
  /// [collection] The name of the collection
  /// [query] The query string
  /// Returns the cached query result, or null if not found
  static List<Map<String, dynamic>>? getQuery(String collection, String query) {
    final key = '$_queryPrefix${collection}_$query';
    return _cacheService.get<List<Map<String, dynamic>>>(key);
  }

  /// Cache a query result
  ///
  /// [collection] The name of the collection
  /// [query] The query string
  /// [data] The query result to cache
  /// [duration] How long to cache the query result
  static void cacheQuery(
    String collection,
    String query,
    List<Map<String, dynamic>> data, {
    Duration duration = shortCacheDuration,
  }) {
    final key = '$_queryPrefix${collection}_$query';
    _cacheService.set(
      key,
      data,
      expiresIn: duration,
      saveToDisk: false, // Don't save queries to disk to save space
    );
  }

  /// Get an image from the cache
  ///
  /// [url] The URL of the image
  /// Returns the cached image data, or null if not found
  static String? getImage(String url) {
    return _cacheService.get<String>('$_imagePrefix$url');
  }

  /// Cache an image
  ///
  /// [url] The URL of the image
  /// [data] The image data to cache (base64 encoded)
  /// [duration] How long to cache the image
  static void cacheImage(
    String url,
    String data, {
    Duration duration = longCacheDuration,
  }) {
    _cacheService.set(
      '$_imagePrefix$url',
      data,
      expiresIn: duration,
      saveToDisk: true,
    );
  }

  /// Clear the cache
  ///
  /// [clearDisk] Whether to clear the disk cache as well
  static void clearCache({bool clearDisk = false}) {
    _cacheService.clear(clearDisk: clearDisk);
  }

  /// Get the key for a collection cache entry
  ///
  /// [collection] The name of the collection
  /// [page] The page number (0-based)
  /// [pageSize] The number of items per page
  /// Returns the cache key
  static String _getCollectionKey(String collection, int? page, int? pageSize) {
    if (page != null && pageSize != null) {
      return '$_collectionPrefix${collection}_page${page}_size$pageSize';
    }
    return '$_collectionPrefix$collection';
  }
}
