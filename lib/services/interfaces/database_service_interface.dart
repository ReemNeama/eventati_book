/// Interface for database services
abstract class DatabaseServiceInterface {
  /// Get a document by ID
  Future<Map<String, dynamic>?> getDocument(
    String collection,
    String documentId,
  );

  /// Get a document by ID and convert it to a specific type
  Future<T?> getDocumentAs<T>(
    String collection,
    String documentId,
    T Function(Map<String, dynamic> data, String id) fromMap,
  );

  /// Get a collection
  Future<List<Map<String, dynamic>>> getCollection(String collection);

  /// Get a collection and convert it to a specific type
  Future<List<T>> getCollectionAs<T>(
    String collection,
    T Function(Map<String, dynamic> data, String id) fromMap,
  );

  /// Get a collection with a query
  Future<List<Map<String, dynamic>>> getCollectionWithQuery(
    String collection,
    List<QueryFilter> filters,
  );

  /// Get a collection with a query and convert it to a specific type
  Future<List<T>> getCollectionWithQueryAs<T>(
    String collection,
    List<QueryFilter> filters,
    T Function(Map<String, dynamic> data, String id) fromMap,
  );

  /// Add a document to a collection
  Future<String> addDocument(String collection, Map<String, dynamic> data);

  /// Set a document in a collection (create or update)
  Future<void> setDocument(
    String collection,
    String documentId,
    Map<String, dynamic> data,
  );

  /// Update a document in a collection
  Future<void> updateDocument(
    String collection,
    String documentId,
    Map<String, dynamic> data,
  );

  /// Delete a document from a collection
  Future<void> deleteDocument(String collection, String documentId);

  /// Get a subcollection of a document
  Future<List<Map<String, dynamic>>> getSubcollection(
    String collection,
    String documentId,
    String subcollection,
  );

  /// Get a subcollection of a document and convert it to a specific type
  Future<List<T>> getSubcollectionAs<T>(
    String collection,
    String documentId,
    String subcollection,
    T Function(Map<String, dynamic> data, String id) fromMap,
  );

  /// Add a document to a subcollection
  Future<String> addSubcollectionDocument(
    String collection,
    String documentId,
    String subcollection,
    Map<String, dynamic> data,
  );

  /// Set a document in a subcollection (create or update)
  Future<void> setSubcollectionDocument(
    String collection,
    String documentId,
    String subcollection,
    String subdocumentId,
    Map<String, dynamic> data,
  );

  /// Update a document in a subcollection
  Future<void> updateSubcollectionDocument(
    String collection,
    String documentId,
    String subcollection,
    String subdocumentId,
    Map<String, dynamic> data,
  );

  /// Delete a document from a subcollection
  Future<void> deleteSubcollectionDocument(
    String collection,
    String documentId,
    String subcollection,
    String subdocumentId,
  );

  /// Get a stream of a document
  Stream<Map<String, dynamic>?> documentStream(
    String collection,
    String documentId,
  );

  /// Get a stream of a document and convert it to a specific type
  Stream<T?> documentStreamAs<T>(
    String collection,
    String documentId,
    T Function(Map<String, dynamic> data, String id) fromMap,
  );

  /// Get a stream of a collection
  Stream<List<Map<String, dynamic>>> collectionStream(String collection);

  /// Get a stream of a collection and convert it to a specific type
  Stream<List<T>> collectionStreamAs<T>(
    String collection,
    T Function(Map<String, dynamic> data, String id) fromMap,
  );

  /// Get a stream of a collection with a query
  Stream<List<Map<String, dynamic>>> collectionStreamWithQuery(
    String collection,
    List<QueryFilter> filters,
  );

  /// Get a stream of a collection with a query and convert it to a specific type
  Stream<List<T>> collectionStreamWithQueryAs<T>(
    String collection,
    List<QueryFilter> filters,
    T Function(Map<String, dynamic> data, String id) fromMap,
  );

  /// Get a stream of a subcollection
  Stream<List<Map<String, dynamic>>> subcollectionStream(
    String collection,
    String documentId,
    String subcollection,
  );

  /// Get a stream of a subcollection and convert it to a specific type
  Stream<List<T>> subcollectionStreamAs<T>(
    String collection,
    String documentId,
    String subcollection,
    T Function(Map<String, dynamic> data, String id) fromMap,
  );

  /// Run a batch of operations
  Future<void> runBatch(List<BatchOperation> operations);

  /// Run a transaction
  Future<T> runTransaction<T>(
    Future<T> Function(dynamic transaction) transactionFunction,
  );
}

/// Query filter for database queries
class QueryFilter {
  /// Field to filter on
  final String field;

  /// Filter operation
  final FilterOperation operation;

  /// Value to compare against
  final dynamic value;

  /// Constructor
  QueryFilter({
    required this.field,
    required this.operation,
    required this.value,
  });
}

/// Filter operations for database queries
enum FilterOperation {
  /// Equal to
  equalTo,

  /// Not equal to
  notEqualTo,

  /// Less than
  lessThan,

  /// Less than or equal to
  lessThanOrEqualTo,

  /// Greater than
  greaterThan,

  /// Greater than or equal to
  greaterThanOrEqualTo,

  /// Array contains
  arrayContains,

  /// Array contains any
  arrayContainsAny,

  /// In array
  whereIn,

  /// Not in array
  whereNotIn,

  /// Is null
  isNull,

  /// Is not null
  isNotNull,
}

/// Batch operation for database batch writes
class BatchOperation {
  /// Type of operation
  final BatchOperationType type;

  /// Collection path
  final String collection;

  /// Document ID
  final String documentId;

  /// Data for the operation
  final Map<String, dynamic>? data;

  /// Subcollection path (if applicable)
  final String? subcollection;

  /// Subdocument ID (if applicable)
  final String? subdocumentId;

  /// Constructor for collection operations
  BatchOperation.collection({
    required this.type,
    required this.collection,
    required this.documentId,
    this.data,
  }) : subcollection = null,
       subdocumentId = null;

  /// Constructor for subcollection operations
  BatchOperation.subcollection({
    required this.type,
    required this.collection,
    required this.documentId,
    required this.subcollection,
    required this.subdocumentId,
    this.data,
  });
}

/// Types of batch operations
enum BatchOperationType {
  /// Set a document
  set,

  /// Update a document
  update,

  /// Delete a document
  delete,
}
