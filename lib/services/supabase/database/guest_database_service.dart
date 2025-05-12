import 'package:eventati_book/models/planning_models/guest.dart';
import 'package:eventati_book/utils/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Service for handling guest-related database operations with Supabase
class GuestDatabaseService {
  /// Supabase client
  final SupabaseClient _supabase;

  /// Table name for guests
  static const String _guestsTable = 'guests';

  /// Table name for guest groups
  static const String _groupsTable = 'guest_groups';

  /// Constructor
  GuestDatabaseService({SupabaseClient? supabase})
    : _supabase = supabase ?? Supabase.instance.client;

  /// Get all guests for an event
  Future<List<Guest>> getGuests(String eventId) async {
    try {
      final response = await _supabase
          .from(_guestsTable)
          .select()
          .eq('event_id', eventId);

      return response.map<Guest>((data) => Guest.fromJson(data)).toList();
    } catch (e) {
      Logger.e('Error getting guests: $e', tag: 'GuestDatabaseService');
      return [];
    }
  }

  /// Get a stream of guests for an event
  Stream<List<Guest>> getGuestsStream(String eventId) {
    return _supabase
        .from(_guestsTable)
        .stream(primaryKey: ['id'])
        .eq('event_id', eventId)
        .map(
          (data) => data.map<Guest>((item) => Guest.fromJson(item)).toList(),
        );
  }

  /// Get a guest by ID
  Future<Guest?> getGuest(String guestId) async {
    try {
      final response =
          await _supabase
              .from(_guestsTable)
              .select()
              .eq('id', guestId)
              .maybeSingle();

      if (response == null) {
        return null;
      }

      return Guest.fromJson(response);
    } catch (e) {
      Logger.e('Error getting guest: $e', tag: 'GuestDatabaseService');
      return null;
    }
  }

  /// Add a new guest
  Future<String> addGuest(String eventId, Guest guest) async {
    try {
      final guestData = guest.toJson();

      // Convert to snake_case for Supabase
      final supabaseData = {
        'event_id': eventId,
        'first_name': guestData['firstName'],
        'last_name': guestData['lastName'],
        'email': guestData['email'],
        'phone': guestData['phone'],
        'group_id': guestData['groupId'],
        'rsvp_status': guestData['rsvpStatus'],
        'rsvp_response_date': guestData['rsvpResponseDate'],
        'plus_one': guestData['plusOne'],
        'plus_one_count': guestData['plusOneCount'],
        'notes': guestData['notes'],
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      final response =
          await _supabase
              .from(_guestsTable)
              .insert(supabaseData)
              .select()
              .single();

      return response['id'];
    } catch (e) {
      Logger.e('Error adding guest: $e', tag: 'GuestDatabaseService');
      rethrow;
    }
  }

  /// Update an existing guest
  Future<void> updateGuest(String eventId, Guest guest) async {
    try {
      final guestData = guest.toJson();

      // Convert to snake_case for Supabase
      final supabaseData = {
        'event_id': eventId,
        'first_name': guestData['firstName'],
        'last_name': guestData['lastName'],
        'email': guestData['email'],
        'phone': guestData['phone'],
        'group_id': guestData['groupId'],
        'rsvp_status': guestData['rsvpStatus'],
        'rsvp_response_date': guestData['rsvpResponseDate'],
        'plus_one': guestData['plusOne'],
        'plus_one_count': guestData['plusOneCount'],
        'notes': guestData['notes'],
        'updated_at': DateTime.now().toIso8601String(),
      };

      await _supabase
          .from(_guestsTable)
          .update(supabaseData)
          .eq('id', guest.id)
          .eq('event_id', eventId);
    } catch (e) {
      Logger.e('Error updating guest: $e', tag: 'GuestDatabaseService');
      rethrow;
    }
  }

  /// Delete a guest
  Future<void> deleteGuest(String guestId, String eventId) async {
    try {
      await _supabase
          .from(_guestsTable)
          .delete()
          .eq('id', guestId)
          .eq('event_id', eventId);
    } catch (e) {
      Logger.e('Error deleting guest: $e', tag: 'GuestDatabaseService');
      rethrow;
    }
  }

  /// Get all guest groups for an event
  Future<List<GuestGroup>> getGuestGroups(String eventId) async {
    try {
      final response = await _supabase
          .from(_groupsTable)
          .select()
          .eq('event_id', eventId);

      return response
          .map<GuestGroup>(
            (data) => GuestGroup(
              id: data['id'],
              name: data['name'],
              description: data['description'],
              color: data['color'],
              guests: [], // Guests need to be loaded separately
            ),
          )
          .toList();
    } catch (e) {
      Logger.e('Error getting guest groups: $e', tag: 'GuestDatabaseService');
      return [];
    }
  }

  /// Add a new guest group
  Future<String> addGuestGroup(String eventId, GuestGroup group) async {
    try {
      final supabaseData = {
        'event_id': eventId,
        'name': group.name,
        'description': group.description,
        'color': group.color,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      final response =
          await _supabase
              .from(_groupsTable)
              .insert(supabaseData)
              .select()
              .single();

      return response['id'];
    } catch (e) {
      Logger.e('Error adding guest group: $e', tag: 'GuestDatabaseService');
      rethrow;
    }
  }

  /// Update an existing guest group
  Future<void> updateGuestGroup(String eventId, GuestGroup group) async {
    try {
      final supabaseData = {
        'event_id': eventId,
        'name': group.name,
        'description': group.description,
        'color': group.color,
        'updated_at': DateTime.now().toIso8601String(),
      };

      await _supabase
          .from(_groupsTable)
          .update(supabaseData)
          .eq('id', group.id)
          .eq('event_id', eventId);
    } catch (e) {
      Logger.e('Error updating guest group: $e', tag: 'GuestDatabaseService');
      rethrow;
    }
  }

  /// Delete a guest group
  Future<void> deleteGuestGroup(String groupId, String eventId) async {
    try {
      await _supabase
          .from(_groupsTable)
          .delete()
          .eq('id', groupId)
          .eq('event_id', eventId);
    } catch (e) {
      Logger.e('Error deleting guest group: $e', tag: 'GuestDatabaseService');
      rethrow;
    }
  }

  /// Get guests by group
  Future<List<Guest>> getGuestsByGroup(String groupId, String eventId) async {
    try {
      final response = await _supabase
          .from(_guestsTable)
          .select()
          .eq('group_id', groupId)
          .eq('event_id', eventId);

      return response.map<Guest>((data) => Guest.fromJson(data)).toList();
    } catch (e) {
      Logger.e(
        'Error getting guests by group: $e',
        tag: 'GuestDatabaseService',
      );
      return [];
    }
  }
}
