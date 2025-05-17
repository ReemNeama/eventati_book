import 'package:flutter/material.dart';
import 'package:eventati_book/models/models.dart';
import 'package:eventati_book/services/calendar/calendar_service.dart';
import 'package:eventati_book/utils/logger.dart';

/// Provider for managing calendar integration
class CalendarProvider extends ChangeNotifier {
  /// Calendar service
  final CalendarService _calendarService;

  /// Whether the provider is loading
  bool _isLoading = false;

  /// Error message if any
  String? _errorMessage;

  /// Whether calendar permissions are granted
  bool _hasPermissions = false;

  /// Whether to add reminders for events
  bool _addReminders = true;

  /// Minutes before event to show reminder
  int _reminderMinutesBefore = 60;

  /// Constructor
  CalendarProvider({CalendarService? calendarService})
    : _calendarService = calendarService ?? CalendarService();

  /// Initialize the provider
  Future<void> initialize() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Check permissions
      _hasPermissions = await _calendarService.hasCalendarPermissions();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to initialize calendar provider: $e';
      Logger.e(_errorMessage!, tag: 'CalendarProvider');
      notifyListeners();
    }
  }

  /// Request calendar permissions
  Future<bool> requestPermissions() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _hasPermissions = await _calendarService.requestCalendarPermissions();

      _isLoading = false;
      notifyListeners();
      return _hasPermissions;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to request calendar permissions: $e';
      Logger.e(_errorMessage!, tag: 'CalendarProvider');
      notifyListeners();
      return false;
    }
  }

  /// Create a calendar event for a booking
  Future<String?> createEventForBooking(Booking booking) async {
    if (!_hasPermissions) {
      final granted = await requestPermissions();
      if (!granted) {
        _errorMessage = 'Calendar permissions not granted';
        notifyListeners();
        return null;
      }
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final eventId = await _calendarService.createEventForBooking(
        booking,
        addReminder: _addReminders,
        reminderMinutesBefore: _reminderMinutesBefore,
      );

      _isLoading = false;
      notifyListeners();
      return eventId;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to create calendar event: $e';
      Logger.e(_errorMessage!, tag: 'CalendarProvider');
      notifyListeners();
      return null;
    }
  }

  /// Update a calendar event for a booking
  Future<bool> updateEventForBooking(Booking booking, String eventId) async {
    if (!_hasPermissions) {
      _errorMessage = 'Calendar permissions not granted';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final success = await _calendarService.updateEventForBooking(
        booking,
        eventId,
      );

      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to update calendar event: $e';
      Logger.e(_errorMessage!, tag: 'CalendarProvider');
      notifyListeners();
      return false;
    }
  }

  /// Delete a calendar event for a booking
  Future<bool> deleteEventForBooking(String bookingId, String eventId) async {
    if (!_hasPermissions) {
      _errorMessage = 'Calendar permissions not granted';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final success = await _calendarService.deleteEventForBooking(
        bookingId,
        eventId,
      );

      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to delete calendar event: $e';
      Logger.e(_errorMessage!, tag: 'CalendarProvider');
      notifyListeners();
      return false;
    }
  }

  /// Check availability for a specific time slot
  Future<bool> checkAvailability(DateTime startTime, DateTime endTime) async {
    if (!_hasPermissions) {
      final granted = await requestPermissions();
      if (!granted) {
        _errorMessage = 'Calendar permissions not granted';
        notifyListeners();
        return false;
      }
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final isAvailable = await _calendarService.checkAvailability(
        startTime,
        endTime,
      );

      _isLoading = false;
      notifyListeners();
      return isAvailable;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to check availability: $e';
      Logger.e(_errorMessage!, tag: 'CalendarProvider');
      notifyListeners();
      return false;
    }
  }

  /// Set whether to add reminders for events
  void setAddReminders(bool addReminders) {
    _addReminders = addReminders;
    notifyListeners();
  }

  /// Set minutes before event to show reminder
  void setReminderMinutesBefore(int minutes) {
    _reminderMinutesBefore = minutes;
    notifyListeners();
  }

  /// Get whether the provider is loading
  bool get isLoading => _isLoading;

  /// Get error message if any
  String? get errorMessage => _errorMessage;

  /// Get whether calendar permissions are granted
  bool get hasPermissions => _hasPermissions;

  /// Get whether to add reminders for events
  bool get addReminders => _addReminders;

  /// Get minutes before event to show reminder
  int get reminderMinutesBefore => _reminderMinutesBefore;
}
