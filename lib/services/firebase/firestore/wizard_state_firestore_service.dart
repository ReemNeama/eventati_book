import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eventati_book/models/models.dart';
import 'package:eventati_book/services/firebase/utils/firestore_service.dart';
import 'package:eventati_book/services/interfaces/database_service_interface.dart';
import 'package:eventati_book/utils/logger.dart';

/// Service for handling wizard state-related Firestore operations
class WizardStateFirestoreService {
  /// Firestore service
  final DatabaseServiceInterface _firestoreService;

  /// Collection name for wizard states
  static const String _collection = 'wizard_states';

  /// Constructor
  WizardStateFirestoreService({DatabaseServiceInterface? firestoreService})
      : _firestoreService = firestoreService ?? FirestoreService();

  /// Get wizard state by user ID and event ID
  Future<WizardState?> getWizardState(String userId, String eventId) async {
    try {
      final documentId = '${userId}_${eventId}';
      final data = await _firestoreService.getDocument(_collection, documentId);
      if (data == null) return null;
      
      return WizardState.fromFirestore(data, eventId);
    } catch (e) {
      Logger.e(
        'Error getting wizard state: $e',
        tag: 'WizardStateFirestoreService',
      );
      return null;
    }
  }

  /// Save wizard state
  Future<void> saveWizardState(
    String userId,
    String eventId,
    WizardState wizardState,
  ) async {
    try {
      final documentId = '${userId}_${eventId}';
      final data = {
        'userId': userId,
        'eventId': eventId,
        ...wizardState.toFirestore(),
      };
      
      await _firestoreService.setDocument(_collection, documentId, data);
      
      Logger.i(
        'Saved wizard state for user $userId, event $eventId',
        tag: 'WizardStateFirestoreService',
      );
    } catch (e) {
      Logger.e(
        'Error saving wizard state: $e',
        tag: 'WizardStateFirestoreService',
      );
      rethrow;
    }
  }

  /// Update wizard state
  Future<void> updateWizardState(
    String userId,
    String eventId,
    WizardState wizardState,
  ) async {
    try {
      final documentId = '${userId}_${eventId}';
      final data = {
        'userId': userId,
        'eventId': eventId,
        ...wizardState.toFirestore(),
        'updatedAt': FieldValue.serverTimestamp(),
      };
      
      await _firestoreService.updateDocument(_collection, documentId, data);
      
      Logger.i(
        'Updated wizard state for user $userId, event $eventId',
        tag: 'WizardStateFirestoreService',
      );
    } catch (e) {
      Logger.e(
        'Error updating wizard state: $e',
        tag: 'WizardStateFirestoreService',
      );
      rethrow;
    }
  }

  /// Delete wizard state
  Future<void> deleteWizardState(String userId, String eventId) async {
    try {
      final documentId = '${userId}_${eventId}';
      await _firestoreService.deleteDocument(_collection, documentId);
      
      Logger.i(
        'Deleted wizard state for user $userId, event $eventId',
        tag: 'WizardStateFirestoreService',
      );
    } catch (e) {
      Logger.e(
        'Error deleting wizard state: $e',
        tag: 'WizardStateFirestoreService',
      );
      rethrow;
    }
  }

  /// Get all wizard states for a user
  Future<List<WizardState>> getWizardStatesForUser(String userId) async {
    try {
      final wizardStates = await _firestoreService.getCollectionWithQueryAs(
        _collection,
        [
          QueryFilter(
            field: 'userId',
            operation: FilterOperation.equalTo,
            value: userId,
          ),
        ],
        (data, id) {
          final parts = id.split('_');
          final eventId = parts.length > 1 ? parts[1] : '';
          return WizardState.fromFirestore(data, eventId);
        },
      );
      
      return wizardStates.whereType<WizardState>().toList();
    } catch (e) {
      Logger.e(
        'Error getting wizard states for user: $e',
        tag: 'WizardStateFirestoreService',
      );
      return [];
    }
  }

  /// Get a stream of wizard states for a user
  Stream<List<WizardState>> getWizardStatesForUserStream(String userId) {
    try {
      return _firestoreService.collectionStreamWithQueryAs(
        _collection,
        [
          QueryFilter(
            field: 'userId',
            operation: FilterOperation.equalTo,
            value: userId,
          ),
        ],
        (data, id) {
          final parts = id.split('_');
          final eventId = parts.length > 1 ? parts[1] : '';
          return WizardState.fromFirestore(data, eventId);
        },
      ).map((list) => list.whereType<WizardState>().toList());
    } catch (e) {
      Logger.e(
        'Error getting wizard states stream for user: $e',
        tag: 'WizardStateFirestoreService',
      );
      return Stream.value([]);
    }
  }
}
