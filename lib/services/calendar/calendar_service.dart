import 'package:eventati_book/models/models.dart' hide Event;
import 'package:eventati_book/utils/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:add_2_calendar/add_2_calendar.dart';

/// Service for handling calendar operations
class CalendarService {
  /// Supabase client
  final SupabaseClient _supabase;

  /// Constructor
  CalendarService({SupabaseClient? supabase})
    : _supabase = supabase ?? Supabase.instance.client;

  /// Request calendar permissions
  Future<bool> requestCalendarPermissions() async {
    try {
      final status = await Permission.calendarWriteOnly.request();
      return status.isGranted;
    } catch (e) {
      Logger.e(
        'Error requesting calendar permissions: $e',
        tag: 'CalendarService',
      );
      return false;
    }
  }

  /// Check if calendar permissions are granted
  Future<bool> hasCalendarPermissions() async {
    try {
      final status = await Permission.calendarWriteOnly.status;
      return status.isGranted;
    } catch (e) {
      Logger.e(
        'Error checking calendar permissions: $e',
        tag: 'CalendarService',
      );
      return false;
    }
  }

  /// Create a calendar event for a booking
  Future<String?> createEventForBooking(
    Booking booking, {
    bool addReminder = true,
    int reminderMinutesBefore = 60,
  }) async {
    try {
      final permissionsGranted = await hasCalendarPermissions();
      if (!permissionsGranted) {
        final requested = await requestCalendarPermissions();
        if (!requested) {
          throw Exception('Calendar permissions not granted');
        }
      }

      // Create event details
      final event = Event(
        title: '${booking.serviceName} Booking',
        description:
            'Booking for ${booking.serviceName}\nSpecial requests: ${booking.specialRequests}',
        location: booking.serviceOptions['location'] ?? 'Venue location',
        startDate: booking.bookingDateTime,
        endDate: booking.bookingDateTime.add(
          Duration(minutes: (booking.duration * 60).toInt()),
        ),
      );

      // Add reminder if requested
      if (addReminder) {
        // The add_2_calendar package doesn't support reminders directly
        // We'll set the reminder in the device's calendar app
      }

      // Add event to calendar
      final success = await Add2Calendar.addEvent2Cal(event);

      if (success) {
        // Generate a unique ID for the event
        final eventId = DateTime.now().millisecondsSinceEpoch.toString();

        // Store the event ID in Supabase for future reference
        await _supabase.from('booking_calendar_events').insert({
          'booking_id': booking.id,
          'event_id': eventId,
          'created_at': DateTime.now().toIso8601String(),
        });

        Logger.i(
          'Calendar event created for booking ${booking.id}: $eventId',
          tag: 'CalendarService',
        );

        return eventId;
      } else {
        throw Exception('Failed to create event');
      }
    } catch (e) {
      Logger.e('Error creating calendar event: $e', tag: 'CalendarService');
      return null;
    }
  }

  /// Update a calendar event for a booking
  Future<bool> updateEventForBooking(
    Booking booking,
    String eventId, {
    String? calendarId,
  }) async {
    try {
      final permissionsGranted = await hasCalendarPermissions();
      if (!permissionsGranted) {
        throw Exception('Calendar permissions not granted');
      }

      // For add_2_calendar, we can't update existing events directly
      // So we'll delete the old event and create a new one

      // First, delete the old event reference from Supabase
      await _supabase
          .from('booking_calendar_events')
          .delete()
          .eq('booking_id', booking.id)
          .eq('event_id', eventId);

      // Create a new event
      final event = Event(
        title: '${booking.serviceName} Booking',
        description:
            'Booking for ${booking.serviceName}\nSpecial requests: ${booking.specialRequests}',
        location: booking.serviceOptions['location'] ?? 'Venue location',
        startDate: booking.bookingDateTime,
        endDate: booking.bookingDateTime.add(
          Duration(minutes: (booking.duration * 60).toInt()),
        ),
      );

      // Add event to calendar
      final success = await Add2Calendar.addEvent2Cal(event);

      if (success) {
        // Generate a new unique ID for the event
        final newEventId = DateTime.now().millisecondsSinceEpoch.toString();

        // Store the new event ID in Supabase
        await _supabase.from('booking_calendar_events').insert({
          'booking_id': booking.id,
          'event_id': newEventId,
          'created_at': DateTime.now().toIso8601String(),
        });

        Logger.i(
          'Calendar event updated for booking ${booking.id}: $newEventId',
          tag: 'CalendarService',
        );
        return true;
      } else {
        throw Exception('Failed to update event');
      }
    } catch (e) {
      Logger.e('Error updating calendar event: $e', tag: 'CalendarService');
      return false;
    }
  }

  /// Delete a calendar event for a booking
  Future<bool> deleteEventForBooking(
    String bookingId,
    String eventId, {
    String? calendarId,
  }) async {
    try {
      // For add_2_calendar, we can't delete events programmatically
      // We can only remove the reference from our database

      // Remove the event reference from Supabase
      await _supabase
          .from('booking_calendar_events')
          .delete()
          .eq('booking_id', bookingId)
          .eq('event_id', eventId);

      Logger.i(
        'Calendar event reference deleted for booking $bookingId: $eventId',
        tag: 'CalendarService',
      );
      return true;
    } catch (e) {
      Logger.e(
        'Error deleting calendar event reference: $e',
        tag: 'CalendarService',
      );
      return false;
    }
  }

  /// Check availability for a specific time slot
  ///
  /// Note: With add_2_calendar, we can't check availability directly
  /// This is a simplified implementation that checks against our own database
  Future<bool> checkAvailability(
    DateTime startTime,
    DateTime endTime, {
    String? calendarId,
  }) async {
    try {
      // Get all bookings from Supabase
      final response = await _supabase
          .from('bookings')
          .select()
          .gte(
            'booking_date_time',
            startTime.subtract(const Duration(hours: 1)).toIso8601String(),
          )
          .lte(
            'booking_date_time',
            endTime.add(const Duration(hours: 1)).toIso8601String(),
          );

      if (response.isEmpty) {
        return true; // No bookings found, time slot is available
      }

      // Check for overlapping bookings
      for (final bookingData in response) {
        final bookingStartTime = DateTime.parse(
          bookingData['booking_date_time'],
        );
        final bookingDuration = bookingData['duration'] ?? 1.0;
        final bookingEndTime = bookingStartTime.add(
          Duration(minutes: (bookingDuration * 60).toInt()),
        );

        // Check if there's an overlap
        if (startTime.isBefore(bookingEndTime) &&
            endTime.isAfter(bookingStartTime)) {
          return false; // Overlap found, time slot is not available
        }
      }

      // If we get here, the time slot is available
      return true;
    } catch (e) {
      Logger.e('Error checking availability: $e', tag: 'CalendarService');
      return false;
    }
  }
}
