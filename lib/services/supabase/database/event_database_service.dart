import 'package:eventati_book/models/event_models/event.dart';
import 'package:eventati_book/utils/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Service for handling event-related database operations with Supabase
class EventDatabaseService {
  /// Supabase client
  final SupabaseClient _supabase;

  /// Table name for events
  static const String _eventsTable = 'events';

  /// Constructor
  EventDatabaseService({SupabaseClient? supabase})
    : _supabase = supabase ?? Supabase.instance.client;

  /// Get all events for a user
  Future<List<Event>> getEvents(String userId) async {
    try {
      final response = await _supabase
          .from(_eventsTable)
          .select()
          .eq('user_id', userId);

      return response.map<Event>((data) => Event.fromJson(data)).toList();
    } catch (e) {
      Logger.e('Error getting events: $e', tag: 'EventDatabaseService');
      return [];
    }
  }

  /// Get a stream of events for a user
  Stream<List<Event>> getEventsStream(String userId) {
    return _supabase
        .from(_eventsTable)
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .map(
          (data) => data.map<Event>((item) => Event.fromJson(item)).toList(),
        );
  }

  /// Get an event by ID
  Future<Event?> getEvent(String eventId) async {
    try {
      final response =
          await _supabase
              .from(_eventsTable)
              .select()
              .eq('id', eventId)
              .maybeSingle();

      if (response == null) {
        return null;
      }

      return Event.fromJson(response);
    } catch (e) {
      Logger.e('Error getting event: $e', tag: 'EventDatabaseService');
      return null;
    }
  }

  /// Get a stream of a single event
  Stream<Event?> getEventStream(String eventId) {
    return _supabase
        .from(_eventsTable)
        .stream(primaryKey: ['id'])
        .eq('id', eventId)
        .map((data) {
          if (data.isEmpty) return null;
          return Event.fromJson(data.first);
        });
  }

  /// Add a new event
  Future<String> addEvent(Event event) async {
    try {
      final eventData = event.toJson();

      // Convert to snake_case for Supabase
      final supabaseData = {
        'name': eventData['name'],
        'type': eventData['type'],
        'date': eventData['date'],
        'location': eventData['location'],
        'budget': eventData['budget'],
        'guest_count': eventData['guestCount'],
        'description': eventData['description'],
        'user_id': eventData['userId'],
        'status': eventData['status'],
        'image_urls': eventData['imageUrls'],
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      final response =
          await _supabase
              .from(_eventsTable)
              .insert(supabaseData)
              .select()
              .single();

      return response['id'];
    } catch (e) {
      Logger.e('Error adding event: $e', tag: 'EventDatabaseService');
      rethrow;
    }
  }

  /// Update an existing event
  Future<void> updateEvent(Event event) async {
    try {
      final eventData = event.toJson();

      // Convert to snake_case for Supabase
      final supabaseData = {
        'name': eventData['name'],
        'type': eventData['type'],
        'date': eventData['date'],
        'location': eventData['location'],
        'budget': eventData['budget'],
        'guest_count': eventData['guestCount'],
        'description': eventData['description'],
        'user_id': eventData['userId'],
        'status': eventData['status'],
        'image_urls': eventData['imageUrls'],
        'updated_at': DateTime.now().toIso8601String(),
      };

      await _supabase
          .from(_eventsTable)
          .update(supabaseData)
          .eq('id', event.id);
    } catch (e) {
      Logger.e('Error updating event: $e', tag: 'EventDatabaseService');
      rethrow;
    }
  }

  /// Delete an event
  Future<void> deleteEvent(String eventId) async {
    try {
      await _supabase.from(_eventsTable).delete().eq('id', eventId);
    } catch (e) {
      Logger.e('Error deleting event: $e', tag: 'EventDatabaseService');
      rethrow;
    }
  }

  /// Search events by name or location
  Future<List<Event>> searchEvents(String userId, String query) async {
    try {
      final response = await _supabase
          .from(_eventsTable)
          .select()
          .eq('user_id', userId)
          .or('name.ilike.%$query%,location.ilike.%$query%');

      return response.map<Event>((data) => Event.fromJson(data)).toList();
    } catch (e) {
      Logger.e('Error searching events: $e', tag: 'EventDatabaseService');
      return [];
    }
  }

  /// Get events by type
  Future<List<Event>> getEventsByType(String userId, EventType type) async {
    try {
      final response = await _supabase
          .from(_eventsTable)
          .select()
          .eq('user_id', userId)
          .eq('type', type.index);

      return response.map<Event>((data) => Event.fromJson(data)).toList();
    } catch (e) {
      Logger.e('Error getting events by type: $e', tag: 'EventDatabaseService');
      return [];
    }
  }
}
