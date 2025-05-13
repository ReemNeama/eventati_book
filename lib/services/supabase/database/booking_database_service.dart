import 'package:eventati_book/models/service_models/booking.dart';
import 'package:eventati_book/utils/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Service for handling booking-related database operations with Supabase
class BookingDatabaseService {
  /// Supabase client
  final SupabaseClient _supabase;

  /// Table name for bookings
  static const String _bookingsTable = 'bookings';

  /// Constructor
  BookingDatabaseService({SupabaseClient? supabase})
    : _supabase = supabase ?? Supabase.instance.client;

  /// Get all bookings for a user
  Future<List<Booking>> getBookings(String userId) async {
    try {
      final response = await _supabase
          .from(_bookingsTable)
          .select()
          .eq('user_id', userId);

      return response.map<Booking>((data) => Booking.fromJson(data)).toList();
    } catch (e) {
      Logger.e('Error getting bookings: $e', tag: 'BookingDatabaseService');
      return [];
    }
  }

  /// Get a stream of bookings for a user
  Stream<List<Booking>> getBookingsStream(String userId) {
    return _supabase
        .from(_bookingsTable)
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .map(
          (data) =>
              data.map<Booking>((item) => Booking.fromJson(item)).toList(),
        );
  }

  /// Get bookings for an event
  Future<List<Booking>> getBookingsForEvent(String eventId) async {
    try {
      final response = await _supabase
          .from(_bookingsTable)
          .select()
          .eq('event_id', eventId);

      return response.map<Booking>((data) => Booking.fromJson(data)).toList();
    } catch (e) {
      Logger.e(
        'Error getting bookings for event: $e',
        tag: 'BookingDatabaseService',
      );
      return [];
    }
  }

  /// Get a booking by ID
  Future<Booking?> getBooking(String bookingId) async {
    try {
      final response =
          await _supabase
              .from(_bookingsTable)
              .select()
              .eq('id', bookingId)
              .maybeSingle();

      if (response == null) {
        return null;
      }

      return Booking.fromJson(response);
    } catch (e) {
      Logger.e('Error getting booking: $e', tag: 'BookingDatabaseService');
      return null;
    }
  }

  /// Add a new booking
  Future<String> addBooking(Booking booking) async {
    try {
      final bookingData = booking.toJson();

      // Convert to snake_case for Supabase
      final supabaseData = {
        'user_id': bookingData['userId'],
        'service_id': bookingData['serviceId'],
        'service_type': bookingData['serviceType'],
        'service_name': bookingData['serviceName'],
        'booking_date_time': bookingData['bookingDateTime'],
        'duration': bookingData['duration'],
        'guest_count': bookingData['guestCount'],
        'special_requests': bookingData['specialRequests'],
        'status': bookingData['status'],
        'total_price': bookingData['totalPrice'],
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
        'contact_name': bookingData['contactName'],
        'contact_email': bookingData['contactEmail'],
        'contact_phone': bookingData['contactPhone'],
        'event_id': bookingData['eventId'],
        'event_name': bookingData['eventName'],
        'service_options': bookingData['serviceOptions'],
      };

      final response =
          await _supabase
              .from(_bookingsTable)
              .insert(supabaseData)
              .select()
              .single();

      return response['id'];
    } catch (e) {
      Logger.e('Error adding booking: $e', tag: 'BookingDatabaseService');
      rethrow;
    }
  }

  /// Update an existing booking
  Future<void> updateBooking(Booking booking) async {
    try {
      final bookingData = booking.toJson();

      // Convert to snake_case for Supabase
      final supabaseData = {
        'user_id': bookingData['userId'],
        'service_id': bookingData['serviceId'],
        'service_type': bookingData['serviceType'],
        'service_name': bookingData['serviceName'],
        'booking_date_time': bookingData['bookingDateTime'],
        'duration': bookingData['duration'],
        'guest_count': bookingData['guestCount'],
        'special_requests': bookingData['specialRequests'],
        'status': bookingData['status'],
        'total_price': bookingData['totalPrice'],
        'updated_at': DateTime.now().toIso8601String(),
        'contact_name': bookingData['contactName'],
        'contact_email': bookingData['contactEmail'],
        'contact_phone': bookingData['contactPhone'],
        'event_id': bookingData['eventId'],
        'event_name': bookingData['eventName'],
        'service_options': bookingData['serviceOptions'],
      };

      await _supabase
          .from(_bookingsTable)
          .update(supabaseData)
          .eq('id', booking.id);
    } catch (e) {
      Logger.e('Error updating booking: $e', tag: 'BookingDatabaseService');
      rethrow;
    }
  }

  /// Delete a booking
  Future<void> deleteBooking(String bookingId) async {
    try {
      await _supabase.from(_bookingsTable).delete().eq('id', bookingId);
    } catch (e) {
      Logger.e('Error deleting booking: $e', tag: 'BookingDatabaseService');
      rethrow;
    }
  }

  /// Get bookings by service type
  Future<List<Booking>> getBookingsByServiceType(
    String userId,
    String serviceType,
  ) async {
    try {
      final response = await _supabase
          .from(_bookingsTable)
          .select()
          .eq('user_id', userId)
          .eq('service_type', serviceType);

      return response.map<Booking>((data) => Booking.fromJson(data)).toList();
    } catch (e) {
      Logger.e(
        'Error getting bookings by service type: $e',
        tag: 'BookingDatabaseService',
      );
      return [];
    }
  }

  /// Get bookings by status
  Future<List<Booking>> getBookingsByStatus(
    String userId,
    BookingStatus status,
  ) async {
    try {
      final response = await _supabase
          .from(_bookingsTable)
          .select()
          .eq('user_id', userId)
          .eq('status', status.index);

      return response.map<Booking>((data) => Booking.fromJson(data)).toList();
    } catch (e) {
      Logger.e(
        'Error getting bookings by status: $e',
        tag: 'BookingDatabaseService',
      );
      return [];
    }
  }

  /// Get upcoming bookings for a user
  Future<List<Booking>> getUpcomingBookings(String userId) async {
    try {
      final now = DateTime.now().toIso8601String();

      final response = await _supabase
          .from(_bookingsTable)
          .select()
          .eq('user_id', userId)
          .gte('booking_date_time', now)
          .order('booking_date_time', ascending: true);

      return response.map<Booking>((data) => Booking.fromJson(data)).toList();
    } catch (e) {
      Logger.e(
        'Error getting upcoming bookings: $e',
        tag: 'BookingDatabaseService',
      );
      return [];
    }
  }

  /// Get bookings that need reminders
  Future<List<Booking>> getBookingsNeedingReminders() async {
    try {
      final now = DateTime.now();
      final sevenDaysFromNow =
          now.add(const Duration(days: 7)).toIso8601String();
      final oneDayFromNow = now.add(const Duration(days: 1)).toIso8601String();

      final response = await _supabase
          .from(_bookingsTable)
          .select()
          .gte('booking_date_time', oneDayFromNow)
          .lte('booking_date_time', sevenDaysFromNow)
          .order('booking_date_time', ascending: true);

      return response.map<Booking>((data) => Booking.fromJson(data)).toList();
    } catch (e) {
      Logger.e(
        'Error getting bookings needing reminders: $e',
        tag: 'BookingDatabaseService',
      );
      return [];
    }
  }

  /// Update booking status
  Future<void> updateBookingStatus(
    String bookingId,
    BookingStatus status,
  ) async {
    try {
      await _supabase
          .from(_bookingsTable)
          .update({
            'status': status.index,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', bookingId);
    } catch (e) {
      Logger.e(
        'Error updating booking status: $e',
        tag: 'BookingDatabaseService',
      );
      rethrow;
    }
  }
}
