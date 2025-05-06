import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:eventati_book/utils/constants/app_constants.dart';
import 'package:eventati_book/models/event_models/event.dart';

/// Provider for managing events
///
/// The EventProvider is responsible for:
/// * Creating, reading, updating, and deleting events
/// * Tracking the active event
/// * Storing and retrieving events from SharedPreferences
/// * Filtering events by type
/// * Sorting events by date
///
/// Usage example:
/// ```dart
/// // Access the provider from the widget tree
/// final eventProvider = Provider.of<EventProvider>(context);
///
/// // Check if there's an active event
/// if (eventProvider.hasActiveEvent) {
///   final activeEvent = eventProvider.activeEvent;
///   print('Active event: ${activeEvent.name}');
/// }
///
/// // Create a new event
/// final newEvent = Event(
///   id: 'event123',
///   name: 'Wedding',
///   type: EventType.wedding,
///   date: DateTime(2023, 6, 15),
///   location: 'Grand Plaza Hotel',
///   budget: 10000,
///   guestCount: 100,
/// );
/// await eventProvider.createEvent(newEvent);
///
/// // Set the active event
/// await eventProvider.setActiveEvent('event123');
///
/// // Get all events of a specific type
/// final weddingEvents = eventProvider.getEventsByType(EventType.wedding);
/// ```
class EventProvider extends ChangeNotifier {
  /// List of all events
  List<Event> _events = [];

  /// ID of the active event
  String? _activeEventId;

  /// Flag indicating if the provider is currently loading data
  bool _isLoading = false;

  /// Error message if an operation fails
  String? _error;

  /// Creates a new EventProvider
  ///
  /// Automatically loads events from SharedPreferences
  EventProvider() {
    _loadEvents();
  }

  /// Returns the list of all events
  List<Event> get events => _events;

  /// Returns the active event, or null if no event is active
  Event? get activeEvent {
    if (_activeEventId == null) return null;
    try {
      return _events.firstWhere((event) => event.id == _activeEventId);
    } catch (e) {
      return null;
    }
  }

  /// Returns whether there is an active event
  bool get hasActiveEvent => _activeEventId != null && activeEvent != null;

  /// Indicates if the provider is currently loading data
  bool get isLoading => _isLoading;

  /// Returns the current error message, if any
  String? get error => _error;

  /// Loads events from SharedPreferences
  ///
  /// This is called automatically when the provider is created.
  Future<void> _loadEvents() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();

      // Load events
      final eventsJson = prefs.getString(AppConstants.eventsKey);
      if (eventsJson != null) {
        final List<dynamic> eventsData = jsonDecode(eventsJson);
        _events = eventsData.map((data) => Event.fromJson(data)).toList();
      }

      // Load active event ID
      _activeEventId = prefs.getString(AppConstants.activeEventKey);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to load events: $e';
      notifyListeners();
    }
  }

  /// Saves events to SharedPreferences
  ///
  /// This is called automatically after any operation that modifies the events list.
  Future<void> _saveEvents() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final eventsJson = jsonEncode(_events.map((e) => e.toJson()).toList());
      await prefs.setString(AppConstants.eventsKey, eventsJson);
    } catch (e) {
      _error = 'Failed to save events: $e';
      notifyListeners();
    }
  }

  /// Creates a new event
  ///
  /// Adds the event to the list and saves it to SharedPreferences.
  /// Returns true if successful, false otherwise.
  Future<bool> createEvent(Event event) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Check if event with same ID already exists
      if (_events.any((e) => e.id == event.id)) {
        _isLoading = false;
        _error = 'Event with ID ${event.id} already exists';
        notifyListeners();
        return false;
      }

      // Add event to list
      _events.add(event);

      // Save events to shared preferences
      await _saveEvents();

      // If this is the first event, set it as active
      if (_events.length == 1 && _activeEventId == null) {
        await setActiveEvent(event.id);
      }

      _isLoading = false;
      notifyListeners();

      return true;
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to create event: $e';
      notifyListeners();

      return false;
    }
  }

  /// Updates an existing event
  ///
  /// Replaces the event with the same ID and saves it to SharedPreferences.
  /// Returns true if successful, false otherwise.
  Future<bool> updateEvent(Event event) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Find index of event with same ID
      final index = _events.indexWhere((e) => e.id == event.id);

      // If event doesn't exist, return false
      if (index == -1) {
        _isLoading = false;
        _error = 'Event with ID ${event.id} not found';
        notifyListeners();
        return false;
      }

      // Update event
      _events[index] = event;

      // Save events to shared preferences
      await _saveEvents();

      _isLoading = false;
      notifyListeners();

      return true;
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to update event: $e';
      notifyListeners();

      return false;
    }
  }

  /// Deletes an event
  ///
  /// Removes the event with the specified ID and saves the updated list to SharedPreferences.
  /// If the deleted event was the active event, clears the active event.
  /// Returns true if successful, false otherwise.
  Future<bool> deleteEvent(String eventId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Find index of event with same ID
      final index = _events.indexWhere((e) => e.id == eventId);

      // If event doesn't exist, return false
      if (index == -1) {
        _isLoading = false;
        _error = 'Event with ID $eventId not found';
        notifyListeners();
        return false;
      }

      // Remove event
      _events.removeAt(index);

      // If this was the active event, clear active event
      if (_activeEventId == eventId) {
        await clearActiveEvent();
      }

      // Save events to shared preferences
      await _saveEvents();

      _isLoading = false;
      notifyListeners();

      return true;
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to delete event: $e';
      notifyListeners();

      return false;
    }
  }

  /// Sets the active event
  ///
  /// Updates the active event ID and saves it to SharedPreferences.
  /// Returns true if successful, false otherwise.
  Future<bool> setActiveEvent(String eventId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Check if event exists
      if (!_events.any((e) => e.id == eventId)) {
        _isLoading = false;
        _error = 'Event with ID $eventId not found';
        notifyListeners();
        return false;
      }

      // Update active event ID
      _activeEventId = eventId;

      // Save active event ID to shared preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.activeEventKey, eventId);

      _isLoading = false;
      notifyListeners();

      return true;
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to set active event: $e';
      notifyListeners();

      return false;
    }
  }

  /// Clears the active event
  ///
  /// Sets the active event ID to null and removes it from SharedPreferences.
  /// Returns true if successful, false otherwise.
  Future<bool> clearActiveEvent() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Clear active event ID
      _activeEventId = null;

      // Remove active event ID from shared preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(AppConstants.activeEventKey);

      _isLoading = false;
      notifyListeners();

      return true;
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to clear active event: $e';
      notifyListeners();

      return false;
    }
  }

  /// Returns events of a specific type
  ///
  /// Filters the events list by the specified event type.
  List<Event> getEventsByType(EventType type) {
    return _events.where((event) => event.type == type).toList();
  }

  /// Returns events sorted by date
  ///
  /// Sorts the events list by date, either ascending or descending.
  List<Event> getEventsSortedByDate({bool ascending = true}) {
    final sortedEvents = List<Event>.from(_events);
    sortedEvents.sort((a, b) {
      return ascending ? a.date.compareTo(b.date) : b.date.compareTo(a.date);
    });
    return sortedEvents;
  }

  /// Returns upcoming events
  ///
  /// Filters the events list to only include events with dates in the future.
  List<Event> get upcomingEvents {
    final now = DateTime.now();
    return _events.where((event) => event.date.isAfter(now)).toList();
  }

  /// Returns past events
  ///
  /// Filters the events list to only include events with dates in the past.
  List<Event> get pastEvents {
    final now = DateTime.now();
    return _events.where((event) => event.date.isBefore(now)).toList();
  }
}
