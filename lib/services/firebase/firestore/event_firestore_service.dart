import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eventati_book/models/event_models/event.dart';
import 'package:eventati_book/models/models.dart';
import 'package:eventati_book/services/firebase/utils/firestore_service.dart';
import 'package:eventati_book/services/interfaces/database_service_interface.dart';
import 'package:eventati_book/utils/logger.dart';

/// Service for handling event-related Firestore operations
class EventFirestoreService {
  /// Firestore service
  final DatabaseServiceInterface _firestoreService;

  /// Collection name for events
  static const String _collection = 'events';

  /// Constructor
  EventFirestoreService({DatabaseServiceInterface? firestoreService})
    : _firestoreService = firestoreService ?? FirestoreService();

  /// Get an event by ID
  Future<EventTemplate?> getEventById(String eventId) async {
    try {
      final eventData = await _firestoreService.getDocument(
        _collection,
        eventId,
      );
      if (eventData == null) return null;
      return EventTemplate.fromJson({'id': eventId, ...eventData});
    } catch (e) {
      Logger.e('Error getting event by ID: $e', tag: 'EventFirestoreService');
      rethrow;
    }
  }

  /// Get events for a user
  Future<List<EventTemplate>> getEventsForUser(String userId) async {
    try {
      final events = await _firestoreService
          .getCollectionWithQueryAs(_collection, [
            QueryFilter(
              field: 'userId',
              operation: FilterOperation.equalTo,
              value: userId,
            ),
          ], (data, id) => EventTemplate.fromJson({'id': id, ...data}));
      return events;
    } catch (e) {
      Logger.e(
        'Error getting events for user: $e',
        tag: 'EventFirestoreService',
      );
      rethrow;
    }
  }

  /// Get a stream of events for a user
  Stream<List<EventTemplate>> getEventsForUserStream(String userId) {
    return _firestoreService.collectionStreamWithQueryAs(_collection, [
      QueryFilter(
        field: 'userId',
        operation: FilterOperation.equalTo,
        value: userId,
      ),
    ], (data, id) => EventTemplate.fromJson({'id': id, ...data}));
  }

  /// Create a new event
  Future<String> createEvent(EventTemplate event) async {
    try {
      final eventId = await _firestoreService.addDocument(
        _collection,
        event.toJson()..remove('id'),
      );
      return eventId;
    } catch (e) {
      Logger.e('Error creating event: $e', tag: 'EventFirestoreService');
      rethrow;
    }
  }

  /// Update an event
  Future<void> updateEvent(EventTemplate event) async {
    try {
      await _firestoreService.updateDocument(
        _collection,
        event.id,
        event.toJson()..remove('id'),
      );
    } catch (e) {
      Logger.e('Error updating event: $e', tag: 'EventFirestoreService');
      rethrow;
    }
  }

  /// Delete an event
  Future<void> deleteEvent(String eventId) async {
    try {
      await _firestoreService.deleteDocument(_collection, eventId);
    } catch (e) {
      Logger.e('Error deleting event: $e', tag: 'EventFirestoreService');
      rethrow;
    }
  }

  /// Get wizard state for an event
  Future<WizardState?> getWizardState(String eventId) async {
    try {
      final wizardData = await _firestoreService.getDocument(
        '$_collection/$eventId/wizard_state',
        'current',
      );
      if (wizardData == null) return null;
      return WizardState.fromFirestore(wizardData, eventId);
    } catch (e) {
      Logger.e('Error getting wizard state: $e', tag: 'EventFirestoreService');
      rethrow;
    }
  }

  /// Save wizard state for an event
  Future<void> saveWizardState(String eventId, WizardState wizardState) async {
    try {
      await _firestoreService.setDocument(
        '$_collection/$eventId/wizard_state',
        'current',
        wizardState.toJson(),
      );
    } catch (e) {
      Logger.e('Error saving wizard state: $e', tag: 'EventFirestoreService');
      rethrow;
    }
  }

  /// Get milestones for an event
  Future<List<Milestone>> getMilestones(String eventId) async {
    try {
      final milestones = await _firestoreService.getSubcollectionAs(
        _collection,
        eventId,
        'milestones',
        (data, id) {
          // Create a default criteria for the milestone
          const criteria = MilestoneCriteria(
            completionConditions: [
              MilestoneCondition(
                field: 'isCompleted',
                operator: MilestoneConditionOperator.isTrue,
              ),
            ],
          );
          return Milestone.fromJson({'id': id, ...data}, criteria);
        },
      );
      return milestones;
    } catch (e) {
      Logger.e('Error getting milestones: $e', tag: 'EventFirestoreService');
      rethrow;
    }
  }

  /// Add a milestone to an event
  Future<String> addMilestone(String eventId, Milestone milestone) async {
    try {
      final milestoneId = await _firestoreService.addSubcollectionDocument(
        _collection,
        eventId,
        'milestones',
        milestone.toJson()..remove('id'),
      );
      return milestoneId;
    } catch (e) {
      Logger.e('Error adding milestone: $e', tag: 'EventFirestoreService');
      rethrow;
    }
  }

  /// Update a milestone
  Future<void> updateMilestone(String eventId, Milestone milestone) async {
    try {
      await _firestoreService.updateSubcollectionDocument(
        _collection,
        eventId,
        'milestones',
        milestone.id,
        milestone.toJson()..remove('id'),
      );
    } catch (e) {
      Logger.e('Error updating milestone: $e', tag: 'EventFirestoreService');
      rethrow;
    }
  }

  /// Delete a milestone
  Future<void> deleteMilestone(String eventId, String milestoneId) async {
    try {
      await _firestoreService.deleteSubcollectionDocument(
        _collection,
        eventId,
        'milestones',
        milestoneId,
      );
    } catch (e) {
      Logger.e('Error deleting milestone: $e', tag: 'EventFirestoreService');
      rethrow;
    }
  }

  /// Get suggestions for an event
  Future<List<Suggestion>> getSuggestions(String eventId) async {
    try {
      final suggestions = await _firestoreService.getSubcollectionAs(
        _collection,
        eventId,
        'suggestions',
        (data, id) => Suggestion.fromJson({'id': id, ...data}),
      );
      return suggestions;
    } catch (e) {
      Logger.e('Error getting suggestions: $e', tag: 'EventFirestoreService');
      rethrow;
    }
  }

  /// Add a suggestion to an event
  Future<String> addSuggestion(String eventId, Suggestion suggestion) async {
    try {
      final suggestionId = await _firestoreService.addSubcollectionDocument(
        _collection,
        eventId,
        'suggestions',
        suggestion.toJson()..remove('id'),
      );
      return suggestionId;
    } catch (e) {
      Logger.e('Error adding suggestion: $e', tag: 'EventFirestoreService');
      rethrow;
    }
  }

  /// Update a suggestion
  Future<void> updateSuggestion(String eventId, Suggestion suggestion) async {
    try {
      await _firestoreService.updateSubcollectionDocument(
        _collection,
        eventId,
        'suggestions',
        suggestion.id,
        suggestion.toJson()..remove('id'),
      );
    } catch (e) {
      Logger.e('Error updating suggestion: $e', tag: 'EventFirestoreService');
      rethrow;
    }
  }

  /// Delete a suggestion
  Future<void> deleteSuggestion(String eventId, String suggestionId) async {
    try {
      await _firestoreService.deleteSubcollectionDocument(
        _collection,
        eventId,
        'suggestions',
        suggestionId,
      );
    } catch (e) {
      Logger.e('Error deleting suggestion: $e', tag: 'EventFirestoreService');
      rethrow;
    }
  }

  /// Get saved comparisons for an event
  Future<List<SavedComparison>> getSavedComparisons(String eventId) async {
    try {
      final comparisons = await _firestoreService.getSubcollectionAs(
        _collection,
        eventId,
        'saved_comparisons',
        (data, id) => SavedComparison.fromJson({'id': id, ...data}),
      );
      return comparisons;
    } catch (e) {
      Logger.e(
        'Error getting saved comparisons: $e',
        tag: 'EventFirestoreService',
      );
      rethrow;
    }
  }

  /// Add a saved comparison to an event
  Future<String> addSavedComparison(
    String eventId,
    SavedComparison comparison,
  ) async {
    try {
      final comparisonId = await _firestoreService.addSubcollectionDocument(
        _collection,
        eventId,
        'saved_comparisons',
        comparison.toJson()..remove('id'),
      );
      return comparisonId;
    } catch (e) {
      Logger.e(
        'Error adding saved comparison: $e',
        tag: 'EventFirestoreService',
      );
      rethrow;
    }
  }

  /// Update a saved comparison
  Future<void> updateSavedComparison(
    String eventId,
    SavedComparison comparison,
  ) async {
    try {
      await _firestoreService.updateSubcollectionDocument(
        _collection,
        eventId,
        'saved_comparisons',
        comparison.id,
        comparison.toJson()..remove('id'),
      );
    } catch (e) {
      Logger.e(
        'Error updating saved comparison: $e',
        tag: 'EventFirestoreService',
      );
      rethrow;
    }
  }

  /// Delete a saved comparison
  Future<void> deleteSavedComparison(
    String eventId,
    String comparisonId,
  ) async {
    try {
      await _firestoreService.deleteSubcollectionDocument(
        _collection,
        eventId,
        'saved_comparisons',
        comparisonId,
      );
    } catch (e) {
      Logger.e(
        'Error deleting saved comparison: $e',
        tag: 'EventFirestoreService',
      );
      rethrow;
    }
  }

  //
  // Event model methods (using the updated Event model with Firestore support)
  //

  /// Get an event by ID using the Event model
  Future<Event?> getEvent(String eventId) async {
    try {
      // Get the Firestore instance from the service
      final firestore = (_firestoreService as FirestoreService).getFirestore();

      // Get the document snapshot directly
      final doc = await firestore.collection(_collection).doc(eventId).get();

      if (!doc.exists) return null;
      return Event.fromFirestore(doc);
    } catch (e) {
      Logger.e('Error getting event: $e', tag: 'EventFirestoreService');
      rethrow;
    }
  }

  /// Get events for a user using the Event model
  Future<List<Event>> getEvents(String userId) async {
    try {
      // Get the Firestore instance from the service
      final firestore = (_firestoreService as FirestoreService).getFirestore();

      // Query the collection directly
      final querySnapshot =
          await firestore
              .collection(_collection)
              .where('userId', isEqualTo: userId)
              .get();

      return querySnapshot.docs.map((doc) => Event.fromFirestore(doc)).toList();
    } catch (e) {
      Logger.e('Error getting events: $e', tag: 'EventFirestoreService');
      rethrow;
    }
  }

  /// Get a stream of events for a user using the Event model
  Stream<List<Event>> getEventsStream(String userId) {
    // Get the Firestore instance from the service
    final firestore = (_firestoreService as FirestoreService).getFirestore();

    // Create a stream directly from Firestore
    return firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Event.fromFirestore(doc)).toList(),
        );
  }

  /// Create a new event using the Event model
  Future<String> createEventWithModel(Event event) async {
    try {
      final eventId = await _firestoreService.addDocument(
        _collection,
        event.toFirestore(),
      );
      return eventId;
    } catch (e) {
      Logger.e('Error creating event: $e', tag: 'EventFirestoreService');
      rethrow;
    }
  }

  /// Update an event using the Event model
  Future<void> updateEventWithModel(Event event) async {
    try {
      await _firestoreService.updateDocument(
        _collection,
        event.id,
        event.toFirestore(),
      );
    } catch (e) {
      Logger.e('Error updating event: $e', tag: 'EventFirestoreService');
      rethrow;
    }
  }

  /// Delete an event using the Event model
  Future<void> deleteEventWithModel(String eventId) async {
    try {
      await _firestoreService.deleteDocument(_collection, eventId);
    } catch (e) {
      Logger.e('Error deleting event: $e', tag: 'EventFirestoreService');
      rethrow;
    }
  }

  /// Get all events using the Event model
  Future<List<Event>> getAllEvents() async {
    try {
      // Get the Firestore instance from the service
      final firestore = (_firestoreService as FirestoreService).getFirestore();

      // Get all documents in the collection
      final querySnapshot = await firestore.collection(_collection).get();

      return querySnapshot.docs.map((doc) => Event.fromFirestore(doc)).toList();
    } catch (e) {
      Logger.e('Error getting all events: $e', tag: 'EventFirestoreService');
      rethrow;
    }
  }

  /// Get a stream of all events using the Event model
  Stream<List<Event>> getAllEventsStream() {
    // Get the Firestore instance from the service
    final firestore = (_firestoreService as FirestoreService).getFirestore();

    // Create a stream of all documents in the collection
    return firestore
        .collection(_collection)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Event.fromFirestore(doc)).toList(),
        );
  }

  /// Get events by type using the Event model
  Future<List<Event>> getEventsByType(EventType type) async {
    try {
      // Get the Firestore instance from the service
      final firestore = (_firestoreService as FirestoreService).getFirestore();

      // Query events by type
      final querySnapshot =
          await firestore
              .collection(_collection)
              .where('type', isEqualTo: type.index)
              .get();

      return querySnapshot.docs.map((doc) => Event.fromFirestore(doc)).toList();
    } catch (e) {
      Logger.e(
        'Error getting events by type: $e',
        tag: 'EventFirestoreService',
      );
      rethrow;
    }
  }

  /// Get upcoming events using the Event model
  Future<List<Event>> getUpcomingEvents(String userId) async {
    try {
      // Get the Firestore instance from the service
      final firestore = (_firestoreService as FirestoreService).getFirestore();

      final now = DateTime.now();

      // Query upcoming events
      final querySnapshot =
          await firestore
              .collection(_collection)
              .where('userId', isEqualTo: userId)
              .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(now))
              .get();

      return querySnapshot.docs.map((doc) => Event.fromFirestore(doc)).toList();
    } catch (e) {
      Logger.e(
        'Error getting upcoming events: $e',
        tag: 'EventFirestoreService',
      );
      rethrow;
    }
  }

  /// Get past events using the Event model
  Future<List<Event>> getPastEvents(String userId) async {
    try {
      // Get the Firestore instance from the service
      final firestore = (_firestoreService as FirestoreService).getFirestore();

      final now = DateTime.now();

      // Query past events
      final querySnapshot =
          await firestore
              .collection(_collection)
              .where('userId', isEqualTo: userId)
              .where('date', isLessThan: Timestamp.fromDate(now))
              .get();

      return querySnapshot.docs.map((doc) => Event.fromFirestore(doc)).toList();
    } catch (e) {
      Logger.e('Error getting past events: $e', tag: 'EventFirestoreService');
      rethrow;
    }
  }
}
