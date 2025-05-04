import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:eventati_book/models/models.dart';
import 'package:eventati_book/utils/date_utils.dart' as date_utils;

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
  ///
  /// Returns true if the booking was successfully created, false otherwise.
  /// The booking is added to the list and persisted to SharedPreferences.
  /// Notifies listeners when the operation completes.
  Future<bool> createBooking(Booking booking) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Add booking to list
      _bookings.add(booking);

      // Save bookings to shared preferences
      await _saveBookings();

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
  ///
  /// Returns true if the booking was successfully updated, false otherwise.
  /// Throws an exception if the booking with the specified ID is not found.
  /// The updated booking is persisted to SharedPreferences.
  /// Notifies listeners when the operation completes.
  Future<bool> updateBooking(Booking booking) async {
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
  ///
  /// Returns true if the booking was successfully cancelled, false otherwise.
  /// Throws an exception if the booking with the specified ID is not found.
  /// This method does not remove the booking from the list, but updates its status
  /// to BookingStatus.cancelled and sets the updatedAt timestamp to the current time.
  /// The updated booking is persisted to SharedPreferences.
  /// Notifies listeners when the operation completes.
  Future<bool> cancelBooking(String bookingId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Find booking index
      final index = _bookings.indexWhere((b) => b.id == bookingId);
      if (index == -1) {
        throw Exception('Booking not found');
      }

      // Update booking status
      final booking = _bookings[index].copyWith(
        status: BookingStatus.cancelled,
        updatedAt: DateTime.now(),
      );
      _bookings[index] = booking;

      // Save bookings to shared preferences
      await _saveBookings();

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
        .where(
          (b) => date_utils.DateTimeUtils.isSameDay(b.bookingDateTime, date),
        )
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
                  date_utils.DateTimeUtils.isSameDay(
                    b.bookingDateTime,
                    dateTime,
                  ) &&
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
}
