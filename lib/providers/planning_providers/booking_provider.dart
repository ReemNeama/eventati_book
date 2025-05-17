import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:eventati_book/models/models.dart';
import 'package:eventati_book/utils/utils.dart';
import 'package:eventati_book/utils/logger.dart';
import 'package:eventati_book/services/calendar/calendar_service.dart';
import 'package:eventati_book/services/notification/email_service.dart';
import 'package:eventati_book/services/notification/email_preferences_service.dart';

/// Provider for managing service bookings and appointments.
///
/// The BookingProvider is responsible for:
/// * Creating, updating, and canceling service bookings
/// * Tracking booking status and history
/// * Checking service availability for specific dates and times
/// * Filtering bookings by service, event, or date
/// * Persisting booking data using SharedPreferences
///
/// Unlike other providers, BookingProvider is not tied to a specific event
/// and manages bookings across all events. It uses SharedPreferences for
/// persistent storage rather than mock data.
///
/// Usage example:
/// ```dart
/// // Access the provider from the widget tree
/// final bookingProvider = Provider.of<BookingProvider>(context);
///
/// // Initialize the provider (typically done in main.dart)
/// await bookingProvider.initialize();
///
/// // Get upcoming bookings
/// final upcomingBookings = bookingProvider.upcomingBookings;
///
/// // Check if a service is available at a specific time
/// final isAvailable = await bookingProvider.isServiceAvailable(
///   'service123',
///   DateTime(2023, 6, 15, 14, 0), // June 15, 2023, 2:00 PM
///   2.5, // 2.5 hours duration
/// );
///
/// // Create a new booking
/// final newBooking = Booking(
///   id: 'booking123',
///   serviceId: 'service123',
///   eventId: 'event123',
///   bookingDateTime: DateTime(2023, 6, 15, 14, 0),
///   duration: 2.5, // 2.5 hours
///   status: BookingStatus.confirmed,
///   createdAt: DateTime.now(),
/// );
/// await bookingProvider.createBooking(newBooking);
///
/// // Cancel a booking
/// await bookingProvider.cancelBooking('booking123');
/// ```
class BookingProvider extends ChangeNotifier {
  /// List of all bookings across all events and services
  List<Booking> _bookings = [];

  /// Flag indicating if the provider is currently loading data
  bool _isLoading = false;

  /// Error message if an operation fails
  String? _error;

  /// Calendar service for managing calendar events
  final CalendarService _calendarService;

  /// Email service for sending booking notifications
  final EmailService _emailService;

  /// Email preferences service for checking user preferences
  final EmailPreferencesService _emailPreferencesService;

  /// Map of booking IDs to calendar event IDs
  final Map<String, String> _calendarEventIds = {};

  /// Constructor
  BookingProvider({
    CalendarService? calendarService,
    EmailService? emailService,
    EmailPreferencesService? emailPreferencesService,
  }) : _calendarService = calendarService ?? CalendarService(),
       _emailService = emailService ?? EmailService(),
       _emailPreferencesService =
           emailPreferencesService ?? EmailPreferencesService();

  /// Returns the complete list of all bookings
  ///
  /// This includes bookings for all events, services, and statuses.
  List<Booking> get bookings => _bookings;

  /// Indicates if the provider is currently loading data
  bool get isLoading => _isLoading;

  /// Returns the error message if an operation has failed, null otherwise
  String? get error => _error;

  /// Returns all bookings with future dates
  ///
  /// A booking is considered upcoming if its date and time are in the future
  /// and it has not been cancelled. This is determined by the [isUpcoming]
  /// property on the Booking model.
  List<Booking> get upcomingBookings =>
      _bookings.where((booking) => booking.isUpcoming).toList();

  /// Returns all bookings with past dates
  ///
  /// A booking is considered past if its date and time (plus duration) have already
  /// passed. This is determined by the [isPast] property on the Booking model.
  List<Booking> get pastBookings =>
      _bookings.where((booking) => booking.isPast).toList();

  /// Initializes the provider by loading all bookings from SharedPreferences
  ///
  /// This method should be called when the app starts, typically in main.dart
  /// or when the provider is first created. It loads all saved bookings from
  /// persistent storage and updates the provider's state.
  /// Notifies listeners when the operation completes.
  Future<void> initialize() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Load bookings from shared preferences
      final bookings = await _loadBookings();
      _bookings = bookings;

      // Load calendar event IDs from shared preferences
      await _loadCalendarEventIds();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to initialize bookings: $e';
      notifyListeners();
    }
  }

  /// Creates a new booking and adds it to the booking list
  ///
  /// [booking] The booking to create
  /// [addToCalendar] Whether to add the booking to the user's calendar
  /// [sendConfirmationEmail] Whether to send a confirmation email
  ///
  /// Returns true if the booking was successfully created, false otherwise.
  /// The booking is added to the list and persisted to SharedPreferences.
  /// If [addToCalendar] is true, the booking is also added to the user's calendar.
  /// If [sendConfirmationEmail] is true, a confirmation email is sent to the user.
  /// Notifies listeners when the operation completes.
  Future<bool> createBooking(
    Booking booking, {
    bool addToCalendar = true,
    bool sendConfirmationEmail = true,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Add booking to list
      _bookings.add(booking);

      // Save bookings to shared preferences
      await _saveBookings();

      // Add to calendar if requested
      String? calendarEventId;
      if (addToCalendar) {
        try {
          calendarEventId = await _calendarService.createEventForBooking(
            booking,
            addReminder: true,
            reminderMinutesBefore: 60,
          );

          if (calendarEventId != null) {
            _calendarEventIds[booking.id] = calendarEventId;
            // Save calendar event IDs to shared preferences
            await _saveCalendarEventIds();
          }
        } catch (e) {
          Logger.w(
            'Failed to add booking to calendar: $e',
            tag: 'BookingProvider',
          );
          // Continue with booking creation even if calendar fails
        }
      }

      // Send confirmation email if requested
      if (sendConfirmationEmail) {
        try {
          // Check if user has opted in to booking confirmation emails
          final hasOptedIn = await _emailPreferencesService.hasOptedIn(
            booking.userId,
            EmailType.bookingConfirmation,
          );

          if (hasOptedIn) {
            // Create add to calendar URL if available
            String? addToCalendarUrl;
            if (calendarEventId != null) {
              // This is a simplified example - in a real app, you would create a proper URL
              addToCalendarUrl = 'io.eventati.book://calendar/$calendarEventId';
            }

            await _emailService.sendBookingConfirmationEmail(
              booking,
              addToCalendarUrl: addToCalendarUrl,
            );
          }
        } catch (e) {
          Logger.w(
            'Failed to send booking confirmation email: $e',
            tag: 'BookingProvider',
          );
          // Continue with booking creation even if email fails
        }
      }

      _isLoading = false;
      notifyListeners();

      return true;
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to create booking: $e';
      notifyListeners();

      return false;
    }
  }

  /// Updates an existing booking with new information
  ///
  /// [booking] The updated booking (must have the same ID as an existing booking)
  /// [updateCalendar] Whether to update the calendar event
  /// [sendUpdateEmail] Whether to send an update email
  /// [updateMessage] Message to include in the update email
  ///
  /// Returns true if the booking was successfully updated, false otherwise.
  /// Throws an exception if the booking with the specified ID is not found.
  /// The updated booking is persisted to SharedPreferences.
  /// If [updateCalendar] is true, the calendar event is also updated.
  /// If [sendUpdateEmail] is true, an update email is sent to the user.
  /// Notifies listeners when the operation completes.
  Future<bool> updateBooking(
    Booking booking, {
    bool updateCalendar = true,
    bool sendUpdateEmail = true,
    String updateMessage = 'Your booking details have been updated.',
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Find booking index
      final index = _bookings.indexWhere((b) => b.id == booking.id);
      if (index == -1) {
        throw Exception('Booking not found');
      }

      // Update booking
      _bookings[index] = booking;

      // Save bookings to shared preferences
      await _saveBookings();

      // Update calendar event if requested
      if (updateCalendar && _calendarEventIds.containsKey(booking.id)) {
        try {
          final calendarEventId = _calendarEventIds[booking.id];
          if (calendarEventId != null) {
            final success = await _calendarService.updateEventForBooking(
              booking,
              calendarEventId,
            );

            if (success) {
              // The updateEventForBooking method in our new implementation
              // deletes the old event and creates a new one with a new ID
              // So we need to update the calendar event ID in our map
              // The new ID is stored in Supabase, but we don't have access to it here
              // For simplicity, we'll just remove the old ID from our map
              _calendarEventIds.remove(booking.id);
              await _saveCalendarEventIds();
            }
          }
        } catch (e) {
          Logger.w(
            'Failed to update calendar event: $e',
            tag: 'BookingProvider',
          );
          // Continue with booking update even if calendar fails
        }
      }

      // Send update email if requested
      if (sendUpdateEmail) {
        try {
          // Check if user has opted in to booking update emails
          final hasOptedIn = await _emailPreferencesService.hasOptedIn(
            booking.userId,
            EmailType.bookingUpdate,
          );

          if (hasOptedIn) {
            await _emailService.sendBookingUpdateEmail(booking, updateMessage);
          }
        } catch (e) {
          Logger.w(
            'Failed to send booking update email: $e',
            tag: 'BookingProvider',
          );
          // Continue with booking update even if email fails
        }
      }

      _isLoading = false;
      notifyListeners();

      return true;
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to update booking: $e';
      notifyListeners();

      return false;
    }
  }

  /// Cancels an existing booking by changing its status to cancelled
  ///
  /// [bookingId] The ID of the booking to cancel
  /// [removeFromCalendar] Whether to remove the booking from the calendar
  /// [sendCancellationEmail] Whether to send a cancellation email
  ///
  /// Returns true if the booking was successfully cancelled, false otherwise.
  /// Throws an exception if the booking with the specified ID is not found.
  /// This method does not remove the booking from the list, but updates its status
  /// to BookingStatus.cancelled and sets the updatedAt timestamp to the current time.
  /// If [removeFromCalendar] is true, the calendar event is also removed.
  /// If [sendCancellationEmail] is true, a cancellation email is sent to the user.
  /// The updated booking is persisted to SharedPreferences.
  /// Notifies listeners when the operation completes.
  Future<bool> cancelBooking(
    String bookingId, {
    bool removeFromCalendar = true,
    bool sendCancellationEmail = true,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Find booking index
      final index = _bookings.indexWhere((b) => b.id == bookingId);
      if (index == -1) {
        throw Exception('Booking not found');
      }

      // Get the booking
      final booking = _bookings[index];

      // Update booking status
      final updatedBooking = booking.copyWith(
        status: BookingStatus.cancelled,
        updatedAt: DateTime.now(),
      );
      _bookings[index] = updatedBooking;

      // Save bookings to shared preferences
      await _saveBookings();

      // Remove from calendar if requested
      if (removeFromCalendar && _calendarEventIds.containsKey(bookingId)) {
        try {
          final calendarEventId = _calendarEventIds[bookingId];
          if (calendarEventId != null) {
            await _calendarService.deleteEventForBooking(
              bookingId,
              calendarEventId,
            );
            _calendarEventIds.remove(bookingId);
            await _saveCalendarEventIds();
          }
        } catch (e) {
          Logger.w(
            'Failed to remove booking from calendar: $e',
            tag: 'BookingProvider',
          );
          // Continue with booking cancellation even if calendar fails
        }
      }

      // Send cancellation email if requested
      if (sendCancellationEmail) {
        try {
          // Check if user has opted in to booking update emails
          final hasOptedIn = await _emailPreferencesService.hasOptedIn(
            booking.userId,
            EmailType.bookingUpdate,
          );

          if (hasOptedIn) {
            await _emailService.sendBookingCancellationEmail(updatedBooking);
          }
        } catch (e) {
          Logger.w(
            'Failed to send booking cancellation email: $e',
            tag: 'BookingProvider',
          );
          // Continue with booking cancellation even if email fails
        }
      }

      _isLoading = false;
      notifyListeners();

      return true;
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to cancel booking: $e';
      notifyListeners();

      return false;
    }
  }

  /// Permanently removes a booking from the list
  ///
  /// [bookingId] The ID of the booking to delete
  ///
  /// Returns true if the booking was successfully deleted, false otherwise.
  /// Unlike cancelBooking, this method completely removes the booking from the list.
  /// The updated booking list is persisted to SharedPreferences.
  /// Notifies listeners when the operation completes.
  Future<bool> deleteBooking(String bookingId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Remove booking
      _bookings.removeWhere((b) => b.id == bookingId);

      // Save bookings to shared preferences
      await _saveBookings();

      _isLoading = false;
      notifyListeners();

      return true;
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to delete booking: $e';
      notifyListeners();

      return false;
    }
  }

  /// Finds and returns a booking with the specified ID
  ///
  /// [bookingId] The ID of the booking to find
  ///
  /// Returns the booking if found, null otherwise.
  /// This method does not modify the booking list or notify listeners.
  Booking? getBookingById(String bookingId) {
    try {
      return _bookings.firstWhere((b) => b.id == bookingId);
    } catch (e) {
      return null;
    }
  }

  /// Returns all bookings for a specific service
  ///
  /// [serviceId] The ID of the service to filter by
  ///
  /// Returns a list of bookings that match the specified service ID.
  /// This method does not modify the booking list or notify listeners.
  List<Booking> getBookingsForService(String serviceId) {
    return _bookings.where((b) => b.serviceId == serviceId).toList();
  }

  /// Returns all bookings for a specific event
  ///
  /// [eventId] The ID of the event to filter by
  ///
  /// Returns a list of bookings that match the specified event ID.
  /// This method does not modify the booking list or notify listeners.
  List<Booking> getBookingsForEvent(String eventId) {
    return _bookings.where((b) => b.eventId == eventId).toList();
  }

  /// Returns all bookings for a specific date
  ///
  /// [date] The date to filter by
  ///
  /// Returns a list of bookings that occur on the specified date,
  /// regardless of the time of day. Uses DateTimeUtils.isSameDay to
  /// compare dates, which ignores the time component.
  /// This method does not modify the booking list or notify listeners.
  List<Booking> getBookingsForDate(DateTime date) {
    return _bookings
        .where((b) => DateTimeUtils.isSameDay(b.bookingDateTime, date))
        .toList();
  }

  /// Checks if a service is available at a specific date and time
  ///
  /// [serviceId] The ID of the service to check availability for
  /// [dateTime] The date and time to check
  /// [duration] The duration of the booking in hours
  ///
  /// Returns true if the service is available at the specified time, false otherwise.
  /// A service is considered available if there are no other non-cancelled bookings
  /// for the same service that overlap with the requested time period.
  /// This method does not modify the booking list or notify listeners.
  Future<bool> isServiceAvailable(
    String serviceId,
    DateTime dateTime,
    double duration,
  ) async {
    // Get bookings for the service
    final serviceBookings = getBookingsForService(serviceId);

    // Filter bookings for the same day
    final sameDayBookings =
        serviceBookings
            .where(
              (b) =>
                  DateTimeUtils.isSameDay(b.bookingDateTime, dateTime) &&
                  b.status != BookingStatus.cancelled,
            )
            .toList();

    // Check if there's any overlap with existing bookings
    for (final booking in sameDayBookings) {
      final bookingStart = booking.bookingDateTime;
      final bookingEnd = booking.bookingDateTime.add(
        Duration(minutes: (booking.duration * 60).round()),
      );

      final newBookingStart = dateTime;
      final newBookingEnd = dateTime.add(
        Duration(minutes: (duration * 60).round()),
      );

      // Check for overlap
      if (newBookingStart.isBefore(bookingEnd) &&
          newBookingEnd.isAfter(bookingStart)) {
        return false; // Overlap found
      }
    }

    return true; // No overlap, service is available
  }

  /// Loads bookings from SharedPreferences
  ///
  /// Returns a list of Booking objects deserialized from JSON stored in SharedPreferences.
  /// If no bookings are found or an error occurs, returns an empty list.
  /// Updates the error message if an error occurs.
  Future<List<Booking>> _loadBookings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonData = prefs.getString('bookings');

      if (jsonData == null) return [];

      final jsonList = jsonDecode(jsonData) as List;

      return jsonList.map((json) => Booking.fromJson(json)).toList();
    } catch (e) {
      _error = 'Failed to load bookings: $e';
      notifyListeners();

      return [];
    }
  }

  /// Saves bookings to SharedPreferences
  ///
  /// Serializes all bookings to JSON and stores them in SharedPreferences.
  /// Updates the error message if an error occurs.
  Future<void> _saveBookings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = _bookings.map((b) => b.toJson()).toList();
      final jsonData = jsonEncode(jsonList);
      await prefs.setString('bookings', jsonData);
    } catch (e) {
      _error = 'Failed to save bookings: $e';
      notifyListeners();
    }
  }

  /// Loads calendar event IDs from SharedPreferences
  ///
  /// Loads the mapping of booking IDs to calendar event IDs from persistent storage.
  /// If no mapping is found, initializes an empty map.
  Future<void> _loadCalendarEventIds() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final calendarEventIdsJson = prefs.getString('calendar_event_ids');
      if (calendarEventIdsJson == null) {
        _calendarEventIds.clear();
        return;
      }

      final calendarEventIdsMap =
          jsonDecode(calendarEventIdsJson) as Map<String, dynamic>;
      _calendarEventIds.clear();
      calendarEventIdsMap.forEach((key, value) {
        _calendarEventIds[key] = value.toString();
      });
    } catch (e) {
      Logger.e('Error loading calendar event IDs: $e', tag: 'BookingProvider');
      _calendarEventIds.clear();
    }
  }

  /// Saves calendar event IDs to SharedPreferences
  ///
  /// Persists the current mapping of booking IDs to calendar event IDs to storage.
  Future<void> _saveCalendarEventIds() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final calendarEventIdsJson = jsonEncode(_calendarEventIds);
      await prefs.setString('calendar_event_ids', calendarEventIdsJson);
    } catch (e) {
      Logger.e('Error saving calendar event IDs: $e', tag: 'BookingProvider');
      _error = 'Failed to save calendar event IDs: $e';
      notifyListeners();
    }
  }
}
