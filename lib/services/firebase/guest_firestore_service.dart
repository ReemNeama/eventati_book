import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eventati_book/models/models.dart';
import 'package:eventati_book/services/firebase/firestore_service.dart';
import 'package:eventati_book/utils/logger.dart';

/// Service for handling guest list-related Firestore operations
class GuestFirestoreService {
  /// Firestore service
  final FirestoreService _firestoreService;

  /// Collection name
  final String _collection = 'events';

  /// Constructor
  GuestFirestoreService({FirestoreService? firestoreService})
      : _firestoreService = firestoreService ?? FirestoreService();

  /// Get guest groups for an event
  Future<List<GuestGroup>> getGuestGroups(String eventId) async {
    try {
      final groups = await _firestoreService.getSubcollectionAs(
        _collection,
        eventId,
        'guest_groups',
        (data, id) => GuestGroup(
          id: id,
          name: data['name'] ?? '',
          description: data['description'],
          color: data['color'],
          guests: [], // Guests will be loaded separately
        ),
      );
      return groups;
    } catch (e) {
      Logger.e('Error getting guest groups: $e', tag: 'GuestFirestoreService');
      rethrow;
    }
  }

  /// Get guests for an event
  Future<List<Guest>> getGuests(String eventId) async {
    try {
      final guests = await _firestoreService.getSubcollectionAs(
        _collection,
        eventId,
        'guests',
        (data, id) => Guest(
          id: id,
          firstName: data['firstName'] ?? '',
          lastName: data['lastName'] ?? '',
          email: data['email'],
          phone: data['phone'],
          groupId: data['groupId'],
          rsvpStatus: _mapRsvpStatus(data['rsvpStatus']),
          rsvpResponseDate: data['rsvpResponseDate'] != null
              ? (data['rsvpResponseDate'] as Timestamp).toDate()
              : null,
          plusOne: data['plusOne'] ?? false,
          plusOneCount: data['plusOneCount'],
          notes: data['notes'],
        ),
      );
      return guests;
    } catch (e) {
      Logger.e('Error getting guests: $e', tag: 'GuestFirestoreService');
      rethrow;
    }
  }

  /// Add a guest group to an event
  Future<String> addGuestGroup(String eventId, GuestGroup group) async {
    try {
      final groupId = await _firestoreService.addSubcollectionDocument(
        _collection,
        eventId,
        'guest_groups',
        {
          'name': group.name,
          'description': group.description,
          'color': group.color,
          'createdAt': FieldValue.serverTimestamp(),
        },
      );
      return groupId;
    } catch (e) {
      Logger.e('Error adding guest group: $e', tag: 'GuestFirestoreService');
      rethrow;
    }
  }

  /// Update a guest group
  Future<void> updateGuestGroup(String eventId, GuestGroup group) async {
    try {
      await _firestoreService.updateSubcollectionDocument(
        _collection,
        eventId,
        'guest_groups',
        group.id,
        {
          'name': group.name,
          'description': group.description,
          'color': group.color,
          'updatedAt': FieldValue.serverTimestamp(),
        },
      );
    } catch (e) {
      Logger.e('Error updating guest group: $e', tag: 'GuestFirestoreService');
      rethrow;
    }
  }

  /// Delete a guest group
  Future<void> deleteGuestGroup(String eventId, String groupId) async {
    try {
      await _firestoreService.deleteSubcollectionDocument(
        _collection,
        eventId,
        'guest_groups',
        groupId,
      );
    } catch (e) {
      Logger.e('Error deleting guest group: $e', tag: 'GuestFirestoreService');
      rethrow;
    }
  }

  /// Add a guest to an event
  Future<String> addGuest(String eventId, Guest guest) async {
    try {
      final guestId = await _firestoreService.addSubcollectionDocument(
        _collection,
        eventId,
        'guests',
        {
          'firstName': guest.firstName,
          'lastName': guest.lastName,
          'email': guest.email,
          'phone': guest.phone,
          'groupId': guest.groupId,
          'rsvpStatus': guest.rsvpStatus.toString().split('.').last,
          'rsvpResponseDate': guest.rsvpResponseDate != null
              ? Timestamp.fromDate(guest.rsvpResponseDate!)
              : null,
          'plusOne': guest.plusOne,
          'plusOneCount': guest.plusOneCount,
          'notes': guest.notes,
          'createdAt': FieldValue.serverTimestamp(),
        },
      );
      return guestId;
    } catch (e) {
      Logger.e('Error adding guest: $e', tag: 'GuestFirestoreService');
      rethrow;
    }
  }

  /// Update a guest
  Future<void> updateGuest(String eventId, Guest guest) async {
    try {
      await _firestoreService.updateSubcollectionDocument(
        _collection,
        eventId,
        'guests',
        guest.id,
        {
          'firstName': guest.firstName,
          'lastName': guest.lastName,
          'email': guest.email,
          'phone': guest.phone,
          'groupId': guest.groupId,
          'rsvpStatus': guest.rsvpStatus.toString().split('.').last,
          'rsvpResponseDate': guest.rsvpResponseDate != null
              ? Timestamp.fromDate(guest.rsvpResponseDate!)
              : null,
          'plusOne': guest.plusOne,
          'plusOneCount': guest.plusOneCount,
          'notes': guest.notes,
          'updatedAt': FieldValue.serverTimestamp(),
        },
      );
    } catch (e) {
      Logger.e('Error updating guest: $e', tag: 'GuestFirestoreService');
      rethrow;
    }
  }

  /// Delete a guest
  Future<void> deleteGuest(String eventId, String guestId) async {
    try {
      await _firestoreService.deleteSubcollectionDocument(
        _collection,
        eventId,
        'guests',
        guestId,
      );
    } catch (e) {
      Logger.e('Error deleting guest: $e', tag: 'GuestFirestoreService');
      rethrow;
    }
  }

  /// Set RSVP deadline for an event
  Future<void> setRsvpDeadline(String eventId, DateTime deadline) async {
    try {
      await _firestoreService.updateDocument(
        _collection,
        eventId,
        {
          'rsvpDeadline': Timestamp.fromDate(deadline),
          'updatedAt': FieldValue.serverTimestamp(),
        },
      );
    } catch (e) {
      Logger.e('Error setting RSVP deadline: $e', tag: 'GuestFirestoreService');
      rethrow;
    }
  }

  /// Set expected guest count for an event
  Future<void> setExpectedGuestCount(String eventId, int count) async {
    try {
      await _firestoreService.updateDocument(
        _collection,
        eventId,
        {
          'expectedGuestCount': count,
          'updatedAt': FieldValue.serverTimestamp(),
        },
      );
    } catch (e) {
      Logger.e('Error setting expected guest count: $e', tag: 'GuestFirestoreService');
      rethrow;
    }
  }

  /// Helper method to map string to RsvpStatus enum
  RsvpStatus _mapRsvpStatus(String? status) {
    switch (status) {
      case 'confirmed':
        return RsvpStatus.confirmed;
      case 'declined':
        return RsvpStatus.declined;
      case 'tentative':
        return RsvpStatus.tentative;
      case 'pending':
      default:
        return RsvpStatus.pending;
    }
  }
}
