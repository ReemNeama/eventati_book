import 'dart:async';

import 'package:eventati_book/services/interfaces/database_service_interface.dart';
import 'package:eventati_book/utils/logger.dart';
import 'package:eventati_book/utils/cache_utils.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Implementation of DatabaseServiceInterface using Supabase
class DatabaseService implements DatabaseServiceInterface {
  /// Supabase client instance
  final SupabaseClient _supabase;

  /// Constructor
  DatabaseService({SupabaseClient? supabase})
    : _supabase = supabase ?? Supabase.instance.client;

  @override
  Future<Map<String, dynamic>?> getDocument(
    String collection,
    String documentId,
  ) async {
    try {
      final response =
          await _supabase
              .from(collection)
              .select()
              .eq('id', documentId)
              .single();

      return response as Map<String, dynamic>?;
    } catch (e) {
      Logger.e('Error getting document: $e', tag: 'DatabaseService');
      return null;
    }
  }

  @override
  Future<T?> getDocumentAs<T>(
    String collection,
    String documentId,
    T Function(Map<String, dynamic> data, String id) fromMap,
  ) async {
    try {
      final data = await getDocument(collection, documentId);
      if (data == null) return null;
      return fromMap(data, documentId);
    } catch (e) {
      Logger.e('Error getting document as type: $e', tag: 'DatabaseService');
      return null;
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getCollection(
    String collection, {
    int? page,
    int? pageSize,
    bool useCache = true,
  }) async {
    try {
      // Check cache first if useCache is true
      if (useCache) {
        final cachedData = CacheUtils.getCollection(
          collection,
          page: page,
          pageSize: pageSize,
        );

        if (cachedData != null) {
          Logger.d(
            'Using cached data for $collection (page: $page, size: $pageSize)',
            tag: 'DatabaseService',
          );
          return cachedData;
        }
      }

      List<Map<String, dynamic>> result;

      // Apply pagination if specified
      if (page != null && pageSize != null) {
        final from = page * pageSize;
        final to = from + pageSize - 1;

        final response = await _supabase
            .from(collection)
            .select()
            .range(from, to);

        result = List<Map<String, dynamic>>.from(response);
      } else {
        // Get all items if no pagination is specified
        final response = await _supabase.from(collection).select();
        result = List<Map<String, dynamic>>.from(response);
      }

      // Cache the result if useCache is true
      if (useCache) {
        CacheUtils.cacheCollection(
          collection,
          result,
          page: page,
          pageSize: pageSize,
        );
      }

      return result;
    } catch (e) {
      Logger.e('Error getting collection: $e', tag: 'DatabaseService');
      return [];
    }
  }

  /// Get a collection with count information for pagination
  ///
  /// [collection] The collection to get
  /// [page] The page number (0-based)
  /// [pageSize] The number of items per page
  /// [useCache] Whether to use the cache
  /// Returns a map with data, count, page, pageSize, and hasMorePages
  Future<Map<String, dynamic>> getCollectionWithCount(
    String collection, {
    int? page,
    int? pageSize,
    bool useCache = true,
  }) async {
    try {
      // Check cache first if useCache is true
      if (useCache) {
        final cacheKey = '${collection}_count_${page ?? 0}_${pageSize ?? 0}';
        final cachedResult = CacheUtils.getQuery(collection, cacheKey);

        if (cachedResult != null) {
          // We store the result as a single-item list containing the result map
          final resultMap = cachedResult.first;
          Logger.d(
            'Using cached data with count for $collection (page: $page, size: $pageSize)',
            tag: 'DatabaseService',
          );
          return Map<String, dynamic>.from(resultMap);
        }
      }

      // Get the total count by counting all records
      final totalCount = await _supabase.from(collection).count();

      // Get the data with pagination
      List<Map<String, dynamic>> items;

      if (page != null && pageSize != null) {
        final from = page * pageSize;
        final to = from + pageSize - 1;

        // Use from and to for pagination
        final response = await _supabase
            .from(collection)
            .select()
            .range(from, to);

        items = List<Map<String, dynamic>>.from(response);
      } else {
        // Get all items if no pagination is specified
        final response = await _supabase.from(collection).select();
        items = List<Map<String, dynamic>>.from(response);
      }

      // Items are already populated above

      // Create the result map
      final resultMap = {
        'data': items,
        'count': totalCount,
        'page': page ?? 0,
        'pageSize': pageSize ?? items.length,
        'hasMorePages':
            page != null && pageSize != null
                ? (page + 1) * pageSize < totalCount
                : false,
      };

      // Cache the result if useCache is true
      if (useCache) {
        final cacheKey = '${collection}_count_${page ?? 0}_${pageSize ?? 0}';
        // Store as a single-item list containing the result map
        CacheUtils.cacheQuery(collection, cacheKey, [resultMap]);
      }

      return resultMap;
    } catch (e) {
      Logger.e(
        'Error getting collection with count: $e',
        tag: 'DatabaseService',
      );
      return {
        'data': <Map<String, dynamic>>[],
        'count': 0,
        'page': page ?? 0,
        'pageSize': pageSize ?? 0,
        'hasMorePages': false,
      };
    }
  }

  @override
  Future<List<T>> getCollectionAs<T>(
    String collection,
    T Function(Map<String, dynamic> data, String id) fromMap,
  ) async {
    try {
      final dataList = await getCollection(collection);
      return dataList
          .map((data) => fromMap(data, data['id'] as String))
          .toList();
    } catch (e) {
      Logger.e('Error getting collection as type: $e', tag: 'DatabaseService');
      return [];
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getCollectionWithQuery(
    String collection,
    List<QueryFilter> filters,
  ) async {
    try {
      // Use dynamic to avoid type issues
      dynamic query = _supabase.from(collection).select();

      for (final filter in filters) {
        query = _applyFilter(query, filter);
      }

      final response = await query;
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      Logger.e(
        'Error getting collection with query: $e',
        tag: 'DatabaseService',
      );
      return [];
    }
  }

  @override
  Future<List<T>> getCollectionWithQueryAs<T>(
    String collection,
    List<QueryFilter> filters,
    T Function(Map<String, dynamic> data, String id) fromMap,
  ) async {
    try {
      final dataList = await getCollectionWithQuery(collection, filters);
      return dataList
          .map((data) => fromMap(data, data['id'] as String))
          .toList();
    } catch (e) {
      Logger.e(
        'Error getting collection with query as type: $e',
        tag: 'DatabaseService',
      );
      return [];
    }
  }

  @override
  Future<String> addDocument(
    String collection,
    Map<String, dynamic> data,
  ) async {
    try {
      // Add created_at and updated_at timestamps
      final timestampedData = {
        ...data,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      final response =
          await _supabase
              .from(collection)
              .insert(timestampedData)
              .select()
              .single();

      return response['id'] as String;
    } catch (e) {
      Logger.e('Error adding document: $e', tag: 'DatabaseService');
      rethrow;
    }
  }

  @override
  Future<void> setDocument(
    String collection,
    String documentId,
    Map<String, dynamic> data,
  ) async {
    try {
      // Add updated_at timestamp
      final timestampedData = {
        ...data,
        'id': documentId,
        'updated_at': DateTime.now().toIso8601String(),
      };

      await _supabase.from(collection).upsert(timestampedData);
    } catch (e) {
      Logger.e('Error setting document: $e', tag: 'DatabaseService');
      rethrow;
    }
  }

  @override
  Future<void> updateDocument(
    String collection,
    String documentId,
    Map<String, dynamic> data,
  ) async {
    try {
      // Add updated_at timestamp
      final timestampedData = {
        ...data,
        'updated_at': DateTime.now().toIso8601String(),
      };

      await _supabase
          .from(collection)
          .update(timestampedData)
          .eq('id', documentId);
    } catch (e) {
      Logger.e('Error updating document: $e', tag: 'DatabaseService');
      rethrow;
    }
  }

  @override
  Future<void> deleteDocument(String collection, String documentId) async {
    try {
      await _supabase.from(collection).delete().eq('id', documentId);
    } catch (e) {
      Logger.e('Error deleting document: $e', tag: 'DatabaseService');
      rethrow;
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getSubcollection(
    String collection,
    String documentId,
    String subcollection,
  ) async {
    try {
      // In Supabase, we can use a naming convention like 'collection_subcollection'
      // and filter by the parent document ID
      final response = await _supabase
          .from('${collection}_$subcollection')
          .select()
          .eq(
            '${collection.substring(0, collection.length - 1)}_id',
            documentId,
          );

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      Logger.e('Error getting subcollection: $e', tag: 'DatabaseService');
      return [];
    }
  }

  @override
  Future<List<T>> getSubcollectionAs<T>(
    String collection,
    String documentId,
    String subcollection,
    T Function(Map<String, dynamic> data, String id) fromMap,
  ) async {
    try {
      final dataList = await getSubcollection(
        collection,
        documentId,
        subcollection,
      );
      return dataList
          .map((data) => fromMap(data, data['id'] as String))
          .toList();
    } catch (e) {
      Logger.e(
        'Error getting subcollection as type: $e',
        tag: 'DatabaseService',
      );
      return [];
    }
  }

  @override
  Future<String> addSubcollectionDocument(
    String collection,
    String documentId,
    String subcollection,
    Map<String, dynamic> data,
  ) async {
    try {
      // Add created_at and updated_at timestamps and parent reference
      final timestampedData = {
        ...data,
        '${collection.substring(0, collection.length - 1)}_id': documentId,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      final response =
          await _supabase
              .from('${collection}_$subcollection')
              .insert(timestampedData)
              .select()
              .single();

      return response['id'] as String;
    } catch (e) {
      Logger.e(
        'Error adding subcollection document: $e',
        tag: 'DatabaseService',
      );
      rethrow;
    }
  }

  @override
  Future<void> setSubcollectionDocument(
    String collection,
    String documentId,
    String subcollection,
    String subdocumentId,
    Map<String, dynamic> data,
  ) async {
    try {
      // Add updated_at timestamp and parent reference
      final timestampedData = {
        ...data,
        'id': subdocumentId,
        '${collection.substring(0, collection.length - 1)}_id': documentId,
        'updated_at': DateTime.now().toIso8601String(),
      };

      await _supabase
          .from('${collection}_$subcollection')
          .upsert(timestampedData);
    } catch (e) {
      Logger.e(
        'Error setting subcollection document: $e',
        tag: 'DatabaseService',
      );
      rethrow;
    }
  }

  @override
  Future<void> updateSubcollectionDocument(
    String collection,
    String documentId,
    String subcollection,
    String subdocumentId,
    Map<String, dynamic> data,
  ) async {
    try {
      // Add updated_at timestamp
      final timestampedData = {
        ...data,
        'updated_at': DateTime.now().toIso8601String(),
      };

      await _supabase
          .from('${collection}_$subcollection')
          .update(timestampedData)
          .eq('id', subdocumentId)
          .eq(
            '${collection.substring(0, collection.length - 1)}_id',
            documentId,
          );
    } catch (e) {
      Logger.e(
        'Error updating subcollection document: $e',
        tag: 'DatabaseService',
      );
      rethrow;
    }
  }

  @override
  Future<void> deleteSubcollectionDocument(
    String collection,
    String documentId,
    String subcollection,
    String subdocumentId,
  ) async {
    try {
      await _supabase
          .from('${collection}_$subcollection')
          .delete()
          .eq('id', subdocumentId)
          .eq(
            '${collection.substring(0, collection.length - 1)}_id',
            documentId,
          );
    } catch (e) {
      Logger.e(
        'Error deleting subcollection document: $e',
        tag: 'DatabaseService',
      );
      rethrow;
    }
  }

  @override
  Stream<Map<String, dynamic>?> documentStream(
    String collection,
    String documentId,
  ) {
    // Create a stream controller
    final controller = StreamController<Map<String, dynamic>?>();

    // Poll for changes every 5 seconds
    Timer? timer;
    Map<String, dynamic>? lastData;

    // Initial data
    getDocument(collection, documentId).then((data) {
      if (!controller.isClosed) {
        lastData = data;
        controller.add(data);
      }
    });

    // Set up polling
    timer = Timer.periodic(const Duration(seconds: 5), (_) async {
      if (controller.isClosed) {
        timer?.cancel();
        return;
      }

      try {
        final data = await getDocument(collection, documentId);

        // Only emit if data has changed
        if (_hasDataChanged(lastData, data)) {
          lastData = data;
          if (!controller.isClosed) {
            controller.add(data);
          }
        }
      } catch (e) {
        Logger.e('Error in document stream: $e', tag: 'DatabaseService');
      }
    });

    // Clean up on stream cancellation
    controller.onCancel = () {
      timer?.cancel();
      controller.close();
    };

    return controller.stream;
  }

  @override
  Stream<T?> documentStreamAs<T>(
    String collection,
    String documentId,
    T Function(Map<String, dynamic> data, String id) fromMap,
  ) {
    return documentStream(collection, documentId).map((data) {
      if (data == null) return null;
      return fromMap(data, documentId);
    });
  }

  @override
  Stream<List<Map<String, dynamic>>> collectionStream(String collection) {
    // Create a stream controller
    final controller = StreamController<List<Map<String, dynamic>>>();

    // Poll for changes every 5 seconds
    Timer? timer;
    List<Map<String, dynamic>>? lastDataList;

    // Initial data
    getCollection(collection).then((dataList) {
      if (!controller.isClosed) {
        lastDataList = dataList;
        controller.add(dataList);
      }
    });

    // Set up polling
    timer = Timer.periodic(const Duration(seconds: 5), (_) async {
      if (controller.isClosed) {
        timer?.cancel();
        return;
      }

      try {
        final dataList = await getCollection(collection);

        // Only emit if data has changed
        if (_hasListDataChanged(lastDataList, dataList)) {
          lastDataList = dataList;
          if (!controller.isClosed) {
            controller.add(dataList);
          }
        }
      } catch (e) {
        Logger.e('Error in collection stream: $e', tag: 'DatabaseService');
      }
    });

    // Clean up on stream cancellation
    controller.onCancel = () {
      timer?.cancel();
      controller.close();
    };

    return controller.stream;
  }

  @override
  Stream<List<T>> collectionStreamAs<T>(
    String collection,
    T Function(Map<String, dynamic> data, String id) fromMap,
  ) {
    return collectionStream(collection).map((dataList) {
      return dataList
          .map((data) => fromMap(data, data['id'] as String))
          .toList();
    });
  }

  @override
  Stream<List<Map<String, dynamic>>> collectionStreamWithQuery(
    String collection,
    List<QueryFilter> filters,
  ) {
    // Create a stream controller
    final controller = StreamController<List<Map<String, dynamic>>>();

    // Poll for changes every 5 seconds
    Timer? timer;
    List<Map<String, dynamic>>? lastDataList;

    // Initial data
    getCollectionWithQuery(collection, filters).then((dataList) {
      if (!controller.isClosed) {
        lastDataList = dataList;
        controller.add(dataList);
      }
    });

    // Set up polling
    timer = Timer.periodic(const Duration(seconds: 5), (_) async {
      if (controller.isClosed) {
        timer?.cancel();
        return;
      }

      try {
        final dataList = await getCollectionWithQuery(collection, filters);

        // Only emit if data has changed
        if (_hasListDataChanged(lastDataList, dataList)) {
          lastDataList = dataList;
          if (!controller.isClosed) {
            controller.add(dataList);
          }
        }
      } catch (e) {
        Logger.e(
          'Error in collection query stream: $e',
          tag: 'DatabaseService',
        );
      }
    });

    // Clean up on stream cancellation
    controller.onCancel = () {
      timer?.cancel();
      controller.close();
    };

    return controller.stream;
  }

  @override
  Stream<List<T>> collectionStreamWithQueryAs<T>(
    String collection,
    List<QueryFilter> filters,
    T Function(Map<String, dynamic> data, String id) fromMap,
  ) {
    return collectionStreamWithQuery(collection, filters).map((dataList) {
      return dataList
          .map((data) => fromMap(data, data['id'] as String))
          .toList();
    });
  }

  @override
  Stream<List<Map<String, dynamic>>> subcollectionStream(
    String collection,
    String documentId,
    String subcollection,
  ) {
    // Create a stream controller
    final controller = StreamController<List<Map<String, dynamic>>>();

    // Poll for changes every 5 seconds
    Timer? timer;
    List<Map<String, dynamic>>? lastDataList;

    // Initial data
    getSubcollection(collection, documentId, subcollection).then((dataList) {
      if (!controller.isClosed) {
        lastDataList = dataList;
        controller.add(dataList);
      }
    });

    // Set up polling
    timer = Timer.periodic(const Duration(seconds: 5), (_) async {
      if (controller.isClosed) {
        timer?.cancel();
        return;
      }

      try {
        final dataList = await getSubcollection(
          collection,
          documentId,
          subcollection,
        );

        // Only emit if data has changed
        if (_hasListDataChanged(lastDataList, dataList)) {
          lastDataList = dataList;
          if (!controller.isClosed) {
            controller.add(dataList);
          }
        }
      } catch (e) {
        Logger.e('Error in subcollection stream: $e', tag: 'DatabaseService');
      }
    });

    // Clean up on stream cancellation
    controller.onCancel = () {
      timer?.cancel();
      controller.close();
    };

    return controller.stream;
  }

  @override
  Stream<List<T>> subcollectionStreamAs<T>(
    String collection,
    String documentId,
    String subcollection,
    T Function(Map<String, dynamic> data, String id) fromMap,
  ) {
    return subcollectionStream(collection, documentId, subcollection).map((
      dataList,
    ) {
      return dataList
          .map((data) => fromMap(data, data['id'] as String))
          .toList();
    });
  }

  /// Check if data has changed
  bool _hasDataChanged(
    Map<String, dynamic>? oldData,
    Map<String, dynamic>? newData,
  ) {
    if (oldData == null && newData == null) return false;
    if (oldData == null || newData == null) return true;

    // Compare JSON strings for deep equality
    return oldData.toString() != newData.toString();
  }

  /// Check if list data has changed
  bool _hasListDataChanged(
    List<Map<String, dynamic>>? oldList,
    List<Map<String, dynamic>>? newList,
  ) {
    if (oldList == null && newList == null) return false;
    if (oldList == null || newList == null) return true;
    if (oldList.length != newList.length) return true;

    // Compare JSON strings for deep equality
    return oldList.toString() != newList.toString();
  }

  @override
  Future<void> runBatch(List<BatchOperation> operations) async {
    try {
      // Supabase doesn't have a direct batch API
      // We'll execute operations sequentially
      for (final operation in operations) {
        if (operation.subcollection != null &&
            operation.subdocumentId != null) {
          // Subcollection operation
          final tableName =
              '${operation.collection}_${operation.subcollection}';
          final parentIdField =
              '${operation.collection.substring(0, operation.collection.length - 1)}_id';

          switch (operation.type) {
            case BatchOperationType.set:
              await _supabase.from(tableName).upsert({
                'id': operation.subdocumentId,
                parentIdField: operation.documentId,
                ...?operation.data,
                'updated_at': DateTime.now().toIso8601String(),
              });
              break;
            case BatchOperationType.update:
              await _supabase
                  .from(tableName)
                  .update({
                    ...?operation.data,
                    'updated_at': DateTime.now().toIso8601String(),
                  })
                  .eq('id', operation.subdocumentId!)
                  .eq(parentIdField, operation.documentId);
              break;
            case BatchOperationType.delete:
              await _supabase
                  .from(tableName)
                  .delete()
                  .eq('id', operation.subdocumentId!)
                  .eq(parentIdField, operation.documentId);
              break;
          }
        } else {
          // Collection operation
          switch (operation.type) {
            case BatchOperationType.set:
              await _supabase.from(operation.collection).upsert({
                'id': operation.documentId,
                ...?operation.data,
                'updated_at': DateTime.now().toIso8601String(),
              });
              break;
            case BatchOperationType.update:
              await _supabase
                  .from(operation.collection)
                  .update({
                    ...?operation.data,
                    'updated_at': DateTime.now().toIso8601String(),
                  })
                  .eq('id', operation.documentId);
              break;
            case BatchOperationType.delete:
              await _supabase
                  .from(operation.collection)
                  .delete()
                  .eq('id', operation.documentId);
              break;
          }
        }
      }
    } catch (e) {
      Logger.e('Error running batch operations: $e', tag: 'DatabaseService');
      rethrow;
    }
  }

  @override
  Future<T> runTransaction<T>(
    Future<T> Function(dynamic transaction) transactionFunction,
  ) async {
    try {
      // Supabase doesn't have a direct transaction API through the client
      // We'll just run the function with the client
      final result = await transactionFunction(_supabase);
      return result;
    } catch (e) {
      Logger.e('Error running transaction: $e', tag: 'DatabaseService');
      rethrow;
    }
  }

  /// Apply a filter to a Supabase query
  dynamic _applyFilter(dynamic query, QueryFilter filter) {
    switch (filter.operation) {
      case FilterOperation.equalTo:
        return query.eq(filter.field, filter.value);
      case FilterOperation.notEqualTo:
        return query.neq(filter.field, filter.value);
      case FilterOperation.lessThan:
        return query.lt(filter.field, filter.value);
      case FilterOperation.lessThanOrEqualTo:
        return query.lte(filter.field, filter.value);
      case FilterOperation.greaterThan:
        return query.gt(filter.field, filter.value);
      case FilterOperation.greaterThanOrEqualTo:
        return query.gte(filter.field, filter.value);
      case FilterOperation.arrayContains:
        return query.contains(filter.field, [filter.value]);
      case FilterOperation.arrayContainsAny:
        if (filter.value is List) {
          return query.overlaps(filter.field, filter.value as List);
        }
        return query.contains(filter.field, [filter.value]);
      case FilterOperation.whereIn:
        if (filter.value is List) {
          // Use 'in' operator instead of in_ method
          return query.filter(filter.field, 'in', filter.value as List);
        }
        return query.eq(filter.field, filter.value);
      case FilterOperation.whereNotIn:
        if (filter.value is List) {
          return query.not(filter.field, 'in', filter.value as List);
        }
        return query.neq(filter.field, filter.value);
      case FilterOperation.isNull:
        // Use 'is' operator instead of is_ method
        return query.filter(filter.field, 'is', null);
      case FilterOperation.isNotNull:
        return query.not(filter.field, 'is', null);
    }
  }
}
