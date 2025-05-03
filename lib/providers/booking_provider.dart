import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:eventati_book/models/booking.dart';
import 'package:eventati_book/utils/date_utils.dart' as date_utils;

/// Provider to manage bookings
class BookingProvider extends ChangeNotifier {
  /// List of all bookings
  List<Booking> _bookings = [];

  /// Loading state
  bool _isLoading = false;

  /// Error message
  String? _error;

  /// Get all bookings
  List<Booking> get bookings => _bookings;

  /// Get loading state
  bool get isLoading => _isLoading;

  /// Get error message
  String? get error => _error;

  /// Get upcoming bookings
  List<Booking> get upcomingBookings =>
      _bookings.where((booking) => booking.isUpcoming).toList();

  /// Get past bookings
  List<Booking> get pastBookings =>
      _bookings.where((booking) => booking.isPast).toList();

  /// Initialize the provider
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

  /// Create a new booking
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

  /// Update an existing booking
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

  /// Cancel a booking
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

  /// Delete a booking
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

  /// Get a booking by ID
  Booking? getBookingById(String bookingId) {
    try {
      return _bookings.firstWhere((b) => b.id == bookingId);
    } catch (e) {
      return null;
    }
  }

  /// Get bookings for a specific service
  List<Booking> getBookingsForService(String serviceId) {
    return _bookings.where((b) => b.serviceId == serviceId).toList();
  }

  /// Get bookings for a specific event
  List<Booking> getBookingsForEvent(String eventId) {
    return _bookings.where((b) => b.eventId == eventId).toList();
  }

  /// Get bookings for a specific date
  List<Booking> getBookingsForDate(DateTime date) {
    return _bookings
        .where(
          (b) => date_utils.DateTimeUtils.isSameDay(b.bookingDateTime, date),
        )
        .toList();
  }

  /// Check if a service is available at a specific date and time
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

  /// Load bookings from shared preferences
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

  /// Save bookings to shared preferences
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
