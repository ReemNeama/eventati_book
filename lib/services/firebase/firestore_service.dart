import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eventati_book/services/interfaces/database_service_interface.dart';

/// Implementation of DatabaseServiceInterface using Firestore
class FirestoreService implements DatabaseServiceInterface {
  /// Firestore instance
  final FirebaseFirestore _firestore;

  /// Constructor
  FirestoreService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<Map<String, dynamic>?> getDocument(
      String collection, String documentId) async {
    try {
      final docSnapshot =
          await _firestore.collection(collection).doc(documentId).get();
      if (!docSnapshot.exists) return null;
      return docSnapshot.data();
    } catch (e) {
      print('Error getting document: $e');
      rethrow;
    }
  }

  @override
  Future<T?> getDocumentAs<T>(
    String collection,
    String documentId,
    T Function(Map<String, dynamic> data, String id) fromMap,
  ) async {
    try {
      final docSnapshot =
          await _firestore.collection(collection).doc(documentId).get();
      if (!docSnapshot.exists) return null;
      final data = docSnapshot.data();
      if (data == null) return null;
      return fromMap(data, documentId);
    } catch (e) {
      print('Error getting document as type: $e');
      rethrow;
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getCollection(String collection) async {
    try {
      final querySnapshot = await _firestore.collection(collection).get();
      return querySnapshot.docs
          .map((doc) => {'id': doc.id, ...doc.data()})
          .toList();
    } catch (e) {
      print('Error getting collection: $e');
      rethrow;
    }
  }

  @override
  Future<List<T>> getCollectionAs<T>(
    String collection,
    T Function(Map<String, dynamic> data, String id) fromMap,
  ) async {
    try {
      final querySnapshot = await _firestore.collection(collection).get();
      return querySnapshot.docs
          .map((doc) => fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Error getting collection as type: $e');
      rethrow;
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getCollectionWithQuery(
    String collection,
    List<QueryFilter> filters,
  ) async {
    try {
      Query query = _firestore.collection(collection);
      for (final filter in filters) {
        query = _applyFilter(query, filter);
      }
      final querySnapshot = await query.get();
      return querySnapshot.docs
          .map((doc) => {'id': doc.id, ...doc.data()})
          .toList();
    } catch (e) {
      print('Error getting collection with query: $e');
      rethrow;
    }
  }

  @override
  Future<List<T>> getCollectionWithQueryAs<T>(
    String collection,
    List<QueryFilter> filters,
    T Function(Map<String, dynamic> data, String id) fromMap,
  ) async {
    try {
      Query query = _firestore.collection(collection);
      for (final filter in filters) {
        query = _applyFilter(query, filter);
      }
      final querySnapshot = await query.get();
      return querySnapshot.docs
          .map((doc) => fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      print('Error getting collection with query as type: $e');
      rethrow;
    }
  }

  @override
  Future<String> addDocument(
      String collection, Map<String, dynamic> data) async {
    try {
      final docRef = await _firestore.collection(collection).add(data);
      return docRef.id;
    } catch (e) {
      print('Error adding document: $e');
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
      await _firestore.collection(collection).doc(documentId).set(data);
    } catch (e) {
      print('Error setting document: $e');
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
      await _firestore.collection(collection).doc(documentId).update(data);
    } catch (e) {
      print('Error updating document: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteDocument(String collection, String documentId) async {
    try {
      await _firestore.collection(collection).doc(documentId).delete();
    } catch (e) {
      print('Error deleting document: $e');
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
      final querySnapshot = await _firestore
          .collection(collection)
          .doc(documentId)
          .collection(subcollection)
          .get();
      return querySnapshot.docs
          .map((doc) => {'id': doc.id, ...doc.data()})
          .toList();
    } catch (e) {
      print('Error getting subcollection: $e');
      rethrow;
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
      final querySnapshot = await _firestore
          .collection(collection)
          .doc(documentId)
          .collection(subcollection)
          .get();
      return querySnapshot.docs
          .map((doc) => fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Error getting subcollection as type: $e');
      rethrow;
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
      final docRef = await _firestore
          .collection(collection)
          .doc(documentId)
          .collection(subcollection)
          .add(data);
      return docRef.id;
    } catch (e) {
      print('Error adding subcollection document: $e');
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
      await _firestore
          .collection(collection)
          .doc(documentId)
          .collection(subcollection)
          .doc(subdocumentId)
          .set(data);
    } catch (e) {
      print('Error setting subcollection document: $e');
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
      await _firestore
          .collection(collection)
          .doc(documentId)
          .collection(subcollection)
          .doc(subdocumentId)
          .update(data);
    } catch (e) {
      print('Error updating subcollection document: $e');
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
      await _firestore
          .collection(collection)
          .doc(documentId)
          .collection(subcollection)
          .doc(subdocumentId)
          .delete();
    } catch (e) {
      print('Error deleting subcollection document: $e');
      rethrow;
    }
  }

  @override
  Stream<Map<String, dynamic>?> documentStream(
    String collection,
    String documentId,
  ) {
    return _firestore
        .collection(collection)
        .doc(documentId)
        .snapshots()
        .map((snapshot) => snapshot.data());
  }

  @override
  Stream<T?> documentStreamAs<T>(
    String collection,
    String documentId,
    T Function(Map<String, dynamic> data, String id) fromMap,
  ) {
    return _firestore
        .collection(collection)
        .doc(documentId)
        .snapshots()
        .map((snapshot) {
      final data = snapshot.data();
      if (data == null) return null;
      return fromMap(data, documentId);
    });
  }

  @override
  Stream<List<Map<String, dynamic>>> collectionStream(String collection) {
    return _firestore.collection(collection).snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList());
  }

  @override
  Stream<List<T>> collectionStreamAs<T>(
    String collection,
    T Function(Map<String, dynamic> data, String id) fromMap,
  ) {
    return _firestore.collection(collection).snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => fromMap(doc.data(), doc.id)).toList());
  }

  @override
  Stream<List<Map<String, dynamic>>> collectionStreamWithQuery(
    String collection,
    List<QueryFilter> filters,
  ) {
    Query query = _firestore.collection(collection);
    for (final filter in filters) {
      query = _applyFilter(query, filter);
    }
    return query.snapshots().map((snapshot) => snapshot.docs
        .map((doc) => {'id': doc.id, ...doc.data()})
        .toList());
  }

  @override
  Stream<List<T>> collectionStreamWithQueryAs<T>(
    String collection,
    List<QueryFilter> filters,
    T Function(Map<String, dynamic> data, String id) fromMap,
  ) {
    Query query = _firestore.collection(collection);
    for (final filter in filters) {
      query = _applyFilter(query, filter);
    }
    return query.snapshots().map((snapshot) => snapshot.docs
        .map((doc) => fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList());
  }

  @override
  Stream<List<Map<String, dynamic>>> subcollectionStream(
    String collection,
    String documentId,
    String subcollection,
  ) {
    return _firestore
        .collection(collection)
        .doc(documentId)
        .collection(subcollection)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => {'id': doc.id, ...doc.data()})
            .toList());
  }

  @override
  Stream<List<T>> subcollectionStreamAs<T>(
    String collection,
    String documentId,
    String subcollection,
    T Function(Map<String, dynamic> data, String id) fromMap,
  ) {
    return _firestore
        .collection(collection)
        .doc(documentId)
        .collection(subcollection)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => fromMap(doc.data(), doc.id)).toList());
  }

  @override
  Future<void> runBatch(List<BatchOperation> operations) async {
    try {
      final batch = _firestore.batch();
      for (final operation in operations) {
        if (operation.subcollection == null) {
          // Collection operation
          final docRef =
              _firestore.collection(operation.collection).doc(operation.documentId);
          switch (operation.type) {
            case BatchOperationType.set:
              batch.set(docRef, operation.data!);
              break;
            case BatchOperationType.update:
              batch.update(docRef, operation.data!);
              break;
            case BatchOperationType.delete:
              batch.delete(docRef);
              break;
          }
        } else {
          // Subcollection operation
          final docRef = _firestore
              .collection(operation.collection)
              .doc(operation.documentId)
              .collection(operation.subcollection!)
              .doc(operation.subdocumentId!);
          switch (operation.type) {
            case BatchOperationType.set:
              batch.set(docRef, operation.data!);
              break;
            case BatchOperationType.update:
              batch.update(docRef, operation.data!);
              break;
            case BatchOperationType.delete:
              batch.delete(docRef);
              break;
          }
        }
      }
      await batch.commit();
    } catch (e) {
      print('Error running batch: $e');
      rethrow;
    }
  }

  @override
  Future<T> runTransaction<T>(
    Future<T> Function(Transaction transaction) transactionFunction,
  ) async {
    try {
      return await _firestore.runTransaction(transactionFunction);
    } catch (e) {
      print('Error running transaction: $e');
      rethrow;
    }
  }

  /// Apply a filter to a query
  Query _applyFilter(Query query, QueryFilter filter) {
    switch (filter.operation) {
      case FilterOperation.equalTo:
        return query.where(filter.field, isEqualTo: filter.value);
      case FilterOperation.notEqualTo:
        return query.where(filter.field, isNotEqualTo: filter.value);
      case FilterOperation.lessThan:
        return query.where(filter.field, isLessThan: filter.value);
      case FilterOperation.lessThanOrEqualTo:
        return query.where(filter.field, isLessThanOrEqualTo: filter.value);
      case FilterOperation.greaterThan:
        return query.where(filter.field, isGreaterThan: filter.value);
      case FilterOperation.greaterThanOrEqualTo:
        return query.where(filter.field, isGreaterThanOrEqualTo: filter.value);
      case FilterOperation.arrayContains:
        return query.where(filter.field, arrayContains: filter.value);
      case FilterOperation.arrayContainsAny:
        return query.where(filter.field, arrayContainsAny: filter.value);
      case FilterOperation.whereIn:
        return query.where(filter.field, whereIn: filter.value);
      case FilterOperation.whereNotIn:
        return query.where(filter.field, whereNotIn: filter.value);
    }
  }
}
