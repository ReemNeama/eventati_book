import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eventati_book/services/firebase/utils/firestore_service.dart';
import 'package:eventati_book/services/interfaces/database_service_interface.dart';
import 'package:eventati_book/utils/logger.dart';

/// Service for handling wizard connections in Firestore
class WizardConnectionFirestoreService {
  /// Firestore service
  final DatabaseServiceInterface _firestoreService;

  /// Collection name for wizard connections
  static const String _collection = 'wizard_connections';

  /// Constructor
  WizardConnectionFirestoreService({DatabaseServiceInterface? firestoreService})
    : _firestoreService = firestoreService ?? FirestoreService();

  /// Save wizard connection data
  ///
  /// This method saves the connection between the wizard and planning tools
  /// [userId] The ID of the user
  /// [eventId] The ID of the event
  /// [connectionData] The connection data to save
  Future<void> saveWizardConnection(
    String userId,
    String eventId,
    Map<String, dynamic> connectionData,
  ) async {
    try {
      final documentId = '${userId}_$eventId';
      final data = {
        'userId': userId,
        'eventId': eventId,
        ...connectionData,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await _firestoreService.setDocument(_collection, documentId, data);

      Logger.i(
        'Saved wizard connection for user $userId, event $eventId',
        tag: 'WizardConnectionFirestoreService',
      );
    } catch (e) {
      Logger.e(
        'Error saving wizard connection: $e',
        tag: 'WizardConnectionFirestoreService',
      );
      rethrow;
    }
  }

  /// Get wizard connection data
  ///
  /// This method retrieves the connection between the wizard and planning tools
  /// [userId] The ID of the user
  /// [eventId] The ID of the event
  Future<Map<String, dynamic>?> getWizardConnection(
    String userId,
    String eventId,
  ) async {
    try {
      final documentId = '${userId}_$eventId';
      final data = await _firestoreService.getDocument(_collection, documentId);
      return data;
    } catch (e) {
      Logger.e(
        'Error getting wizard connection: $e',
        tag: 'WizardConnectionFirestoreService',
      );
      return null;
    }
  }

  /// Update wizard connection data
  ///
  /// This method updates the connection between the wizard and planning tools
  /// [userId] The ID of the user
  /// [eventId] The ID of the event
  /// [connectionData] The connection data to update
  Future<void> updateWizardConnection(
    String userId,
    String eventId,
    Map<String, dynamic> connectionData,
  ) async {
    try {
      final documentId = '${userId}_$eventId';
      final data = {
        ...connectionData,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await _firestoreService.updateDocument(_collection, documentId, data);

      Logger.i(
        'Updated wizard connection for user $userId, event $eventId',
        tag: 'WizardConnectionFirestoreService',
      );
    } catch (e) {
      Logger.e(
        'Error updating wizard connection: $e',
        tag: 'WizardConnectionFirestoreService',
      );
      rethrow;
    }
  }

  /// Delete wizard connection data
  ///
  /// This method deletes the connection between the wizard and planning tools
  /// [userId] The ID of the user
  /// [eventId] The ID of the event
  Future<void> deleteWizardConnection(String userId, String eventId) async {
    try {
      final documentId = '${userId}_$eventId';
      await _firestoreService.deleteDocument(_collection, documentId);

      Logger.i(
        'Deleted wizard connection for user $userId, event $eventId',
        tag: 'WizardConnectionFirestoreService',
      );
    } catch (e) {
      Logger.e(
        'Error deleting wizard connection: $e',
        tag: 'WizardConnectionFirestoreService',
      );
      rethrow;
    }
  }
}
