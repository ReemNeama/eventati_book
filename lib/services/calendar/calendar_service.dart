import 'package:eventati_book/models/models.dart' hide Event;
import 'package:eventati_book/utils/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:timezone/timezone.dart' as tz;

/// Service for handling calendar operations
class CalendarService {
  /// Supabase client
  final SupabaseClient _supabase;

  /// Map of recurrence frequency to RRule frequency
  static const Map<RecurrenceFrequency, String> _recurrenceFrequencyMap = {
    RecurrenceFrequency.daily: 'DAILY',
    RecurrenceFrequency.weekly: 'WEEKLY',
    RecurrenceFrequency.monthly: 'MONTHLY',
    RecurrenceFrequency.yearly: 'YEARLY',
  };

  /// Map of day of week to RRule day
  static const Map<DayOfWeek, String> _dayOfWeekMap = {
    DayOfWeek.monday: 'MO',
    DayOfWeek.tuesday: 'TU',
    DayOfWeek.wednesday: 'WE',
    DayOfWeek.thursday: 'TH',
    DayOfWeek.friday: 'FR',
    DayOfWeek.saturday: 'SA',
    DayOfWeek.sunday: 'SU',
  };

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
        // Add reminder settings
        timeZone: 'UTC',
        recurrence: null,
        allDay: false,
      );

      // Add reminder if requested
      if (addReminder) {
        // While add_2_calendar doesn't directly support setting reminders,
        // most calendar apps will use their default reminder settings
        // We'll store the reminder preference in our database for reference
        await _supabase.from('booking_calendar_preferences').upsert({
          'booking_id': booking.id,
          'add_reminder': addReminder,
          'reminder_minutes_before': reminderMinutesBefore,
          'updated_at': DateTime.now().toIso8601String(),
        });
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
  /// This implementation checks against our own database and considers
  /// both booking status and service capacity
  Future<bool> checkAvailability(
    DateTime startTime,
    DateTime endTime, {
    String? serviceId,
    String? calendarId,
  }) async {
    try {
      // Get all bookings from Supabase within the time range
      final query = _supabase
          .from('bookings')
          .select('*, services:service_id(*)')
          .gte(
            'booking_date_time',
            startTime.subtract(const Duration(hours: 1)).toIso8601String(),
          )
          .lte(
            'booking_date_time',
            endTime.add(const Duration(hours: 1)).toIso8601String(),
          );

      // If a specific service is provided, filter by it
      final response =
          serviceId != null
              ? await query.eq('service_id', serviceId)
              : await query;

      if (response.isEmpty) {
        return true; // No bookings found, time slot is available
      }

      // If checking for a specific service, verify service capacity
      if (serviceId != null) {
        // Count active bookings for this service in this time slot
        int activeBookingsCount = 0;
        int serviceCapacity = 1; // Default to 1 if not specified

        for (final bookingData in response) {
          // Skip cancelled bookings
          if (bookingData['status'] == 'cancelled') {
            continue;
          }

          final bookingStartTime = DateTime.parse(
            bookingData['booking_date_time'],
          );
          final bookingDuration = bookingData['duration'] ?? 1.0;
          final bookingEndTime = bookingStartTime.add(
            Duration(minutes: (bookingDuration * 60).toInt()),
          );

          // Check if there's an overlap with the requested time
          if (startTime.isBefore(bookingEndTime) &&
              endTime.isAfter(bookingStartTime)) {
            activeBookingsCount++;

            // Get service capacity if available
            if (bookingData['services'] != null &&
                bookingData['services']['max_concurrent_bookings'] != null) {
              serviceCapacity =
                  bookingData['services']['max_concurrent_bookings'];
            }
          }
        }

        // Check if we've reached capacity
        if (activeBookingsCount >= serviceCapacity) {
          return false; // Service is at capacity for this time slot
        }
      } else {
        // If not checking for a specific service, just check for any overlap
        for (final bookingData in response) {
          // Skip cancelled bookings
          if (bookingData['status'] == 'cancelled') {
            continue;
          }

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
      }

      // Check for recurring events that might overlap
      final recurringEventsOverlap = await _checkRecurringEventOverlap(
        startTime,
        endTime,
      );
      if (recurringEventsOverlap) {
        return false; // Overlap with recurring event found
      }

      // If we get here, the time slot is available
      return true;
    } catch (e) {
      Logger.e('Error checking availability: $e', tag: 'CalendarService');
      return false;
    }
  }

  /// Create a recurring event
  ///
  /// [recurringEvent] The recurring event to create
  Future<String?> createRecurringEvent(RecurringEvent recurringEvent) async {
    try {
      final permissionsGranted = await hasCalendarPermissions();
      if (!permissionsGranted) {
        final requested = await requestCalendarPermissions();
        if (!requested) {
          throw Exception('Calendar permissions not granted');
        }
      }

      // Build the recurrence rule (RRULE) string
      final recurrenceRule = _buildRecurrenceRule(recurringEvent);

      // Create a description that includes the recurrence information
      String enhancedDescription = recurringEvent.description;
      if (recurrenceRule != null) {
        enhancedDescription += '\n\nThis is a recurring event: ';

        switch (recurringEvent.frequency) {
          case RecurrenceFrequency.daily:
            enhancedDescription += 'Occurs daily';
            break;
          case RecurrenceFrequency.weekly:
            enhancedDescription += 'Occurs weekly';
            if (recurringEvent.daysOfWeek != null &&
                recurringEvent.daysOfWeek!.isNotEmpty) {
              enhancedDescription +=
                  ' on ${_formatDaysOfWeek(recurringEvent.daysOfWeek!)}';
            }
            break;
          case RecurrenceFrequency.monthly:
            enhancedDescription += 'Occurs monthly';
            if (recurringEvent.dayOfMonth != null) {
              enhancedDescription += ' on day ${recurringEvent.dayOfMonth}';
            }
            break;
          case RecurrenceFrequency.yearly:
            enhancedDescription += 'Occurs yearly';
            if (recurringEvent.monthOfYear != null &&
                recurringEvent.dayOfMonth != null) {
              enhancedDescription +=
                  ' on ${_getMonthName(recurringEvent.monthOfYear!)} ${recurringEvent.dayOfMonth}';
            }
            break;
        }

        if (recurringEvent.interval > 1) {
          enhancedDescription += ' every ${recurringEvent.interval} ';
          switch (recurringEvent.frequency) {
            case RecurrenceFrequency.daily:
              enhancedDescription += 'days';
              break;
            case RecurrenceFrequency.weekly:
              enhancedDescription += 'weeks';
              break;
            case RecurrenceFrequency.monthly:
              enhancedDescription += 'months';
              break;
            case RecurrenceFrequency.yearly:
              enhancedDescription += 'years';
              break;
          }
        }

        if (recurringEvent.endDate != null) {
          enhancedDescription +=
              ' until ${_formatDate(recurringEvent.endDate!)}';
        } else if (recurringEvent.count != null) {
          enhancedDescription += ' for ${recurringEvent.count} occurrences';
        }
      }

      // Create event details
      final event = Event(
        title: recurringEvent.title,
        description: enhancedDescription,
        location: recurringEvent.location,
        startDate: recurringEvent.startDateTime,
        endDate: recurringEvent.endDateTime,
        timeZone: 'UTC',
        allDay: false,
      );

      // Add event to calendar
      final success = await Add2Calendar.addEvent2Cal(event);

      if (success) {
        // Generate a unique ID for the event
        final eventId = DateTime.now().millisecondsSinceEpoch.toString();

        // Store the recurring event in Supabase
        await _supabase.from('recurring_events').insert(recurringEvent.toMap());

        // Store the event ID in Supabase for future reference
        if (recurringEvent.bookingId != null) {
          await _supabase.from('booking_calendar_events').insert({
            'booking_id': recurringEvent.bookingId,
            'event_id': eventId,
            'is_recurring': true,
            'created_at': DateTime.now().toIso8601String(),
          });
        }

        Logger.i(
          'Recurring calendar event created: $eventId',
          tag: 'CalendarService',
        );

        return eventId;
      } else {
        throw Exception('Failed to create recurring event');
      }
    } catch (e) {
      Logger.e('Error creating recurring event: $e', tag: 'CalendarService');
      return null;
    }
  }

  /// Build a recurrence rule (RRULE) string from a RecurringEvent
  String? _buildRecurrenceRule(RecurringEvent recurringEvent) {
    // Start building the RRULE
    final frequency = _recurrenceFrequencyMap[recurringEvent.frequency];
    String rule = 'FREQ=$frequency';

    // Add interval if greater than 1
    if (recurringEvent.interval > 1) {
      rule += ';INTERVAL=${recurringEvent.interval}';
    }

    // Add count or end date (UNTIL) if specified
    if (recurringEvent.count != null) {
      rule += ';COUNT=${recurringEvent.count}';
    } else if (recurringEvent.endDate != null) {
      final dateStr = recurringEvent.endDate!.toUtc().toIso8601String();
      final untilDate =
          '${dateStr.replaceAll('-', '').replaceAll(':', '').split('.')[0]}Z';
      rule += ';UNTIL=$untilDate';
    }

    // Add days of week for weekly recurrence
    if (recurringEvent.frequency == RecurrenceFrequency.weekly &&
        recurringEvent.daysOfWeek != null &&
        recurringEvent.daysOfWeek!.isNotEmpty) {
      final days = recurringEvent.daysOfWeek!
          .map((day) => _dayOfWeekMap[day])
          .join(',');
      rule += ';BYDAY=$days';
    }

    // Add day of month for monthly recurrence
    if (recurringEvent.frequency == RecurrenceFrequency.monthly &&
        recurringEvent.dayOfMonth != null) {
      rule += ';BYMONTHDAY=${recurringEvent.dayOfMonth}';
    }

    // Add month and day for yearly recurrence
    if (recurringEvent.frequency == RecurrenceFrequency.yearly &&
        recurringEvent.monthOfYear != null &&
        recurringEvent.dayOfMonth != null) {
      rule += ';BYMONTH=${recurringEvent.monthOfYear}';
      rule += ';BYMONTHDAY=${recurringEvent.dayOfMonth}';
    }

    return rule;
  }

  /// Check if there are any recurring events that overlap with the given time slot
  Future<bool> _checkRecurringEventOverlap(
    DateTime startTime,
    DateTime endTime,
  ) async {
    try {
      // Get all recurring events from Supabase
      final response = await _supabase.from('recurring_events').select();

      for (final eventData in response) {
        final recurringEvent = RecurringEvent.fromMap(eventData);

        // Check if the recurring event is active during the requested time
        if (_isRecurringEventActiveAt(recurringEvent, startTime, endTime)) {
          return true; // Overlap found
        }
      }

      return false; // No overlap found
    } catch (e) {
      Logger.e(
        'Error checking recurring event overlap: $e',
        tag: 'CalendarService',
      );
      return false;
    }
  }

  /// Check if a recurring event is active at the given time
  bool _isRecurringEventActiveAt(
    RecurringEvent recurringEvent,
    DateTime startTime,
    DateTime endTime,
  ) {
    // Check if the event has ended
    if (recurringEvent.endDate != null &&
        recurringEvent.endDate!.isBefore(startTime)) {
      return false;
    }

    // Check if the event starts after the requested end time
    if (recurringEvent.startDateTime.isAfter(endTime)) {
      return false;
    }

    // Check for excluded dates
    if (recurringEvent.excludeDates != null) {
      for (final excludeDate in recurringEvent.excludeDates!) {
        if (_datesOverlap(
          excludeDate,
          excludeDate.add(
            recurringEvent.endDateTime.difference(recurringEvent.startDateTime),
          ),
          startTime,
          endTime,
        )) {
          return false;
        }
      }
    }

    // Check for included dates
    if (recurringEvent.includeDates != null) {
      for (final includeDate in recurringEvent.includeDates!) {
        if (_datesOverlap(
          includeDate,
          includeDate.add(
            recurringEvent.endDateTime.difference(recurringEvent.startDateTime),
          ),
          startTime,
          endTime,
        )) {
          return true;
        }
      }
    }

    // Check based on recurrence pattern
    switch (recurringEvent.frequency) {
      case RecurrenceFrequency.daily:
        return _checkDailyRecurrence(recurringEvent, startTime, endTime);
      case RecurrenceFrequency.weekly:
        return _checkWeeklyRecurrence(recurringEvent, startTime, endTime);
      case RecurrenceFrequency.monthly:
        return _checkMonthlyRecurrence(recurringEvent, startTime, endTime);
      case RecurrenceFrequency.yearly:
        return _checkYearlyRecurrence(recurringEvent, startTime, endTime);
    }
  }

  /// Check if a daily recurring event is active at the given time
  bool _checkDailyRecurrence(
    RecurringEvent recurringEvent,
    DateTime startTime,
    DateTime endTime,
  ) {
    // Calculate the number of days between the event start and the requested start
    final daysBetween =
        startTime.difference(recurringEvent.startDateTime).inDays;

    // Check if the number of days is divisible by the interval
    if (daysBetween % recurringEvent.interval == 0) {
      // Check if the time of day overlaps
      return _timeOfDayOverlaps(
        recurringEvent.startDateTime,
        recurringEvent.endDateTime,
        startTime,
        endTime,
      );
    }

    return false;
  }

  /// Check if a weekly recurring event is active at the given time
  bool _checkWeeklyRecurrence(
    RecurringEvent recurringEvent,
    DateTime startTime,
    DateTime endTime,
  ) {
    // Calculate the number of weeks between the event start and the requested start
    final weeksBetween =
        startTime.difference(recurringEvent.startDateTime).inDays ~/ 7;

    // Check if the number of weeks is divisible by the interval
    if (weeksBetween % recurringEvent.interval == 0) {
      // Check if the day of week is included
      if (recurringEvent.daysOfWeek != null &&
          recurringEvent.daysOfWeek!.isNotEmpty) {
        final dayOfWeek = DayOfWeek.values[startTime.weekday - 1];
        if (!recurringEvent.daysOfWeek!.contains(dayOfWeek)) {
          return false;
        }
      } else {
        // If no days of week are specified, use the same day of week as the start date
        if (startTime.weekday != recurringEvent.startDateTime.weekday) {
          return false;
        }
      }

      // Check if the time of day overlaps
      return _timeOfDayOverlaps(
        recurringEvent.startDateTime,
        recurringEvent.endDateTime,
        startTime,
        endTime,
      );
    }

    return false;
  }

  /// Check if a monthly recurring event is active at the given time
  bool _checkMonthlyRecurrence(
    RecurringEvent recurringEvent,
    DateTime startTime,
    DateTime endTime,
  ) {
    // Calculate the number of months between the event start and the requested start
    final monthsBetween =
        (startTime.year - recurringEvent.startDateTime.year) * 12 +
        (startTime.month - recurringEvent.startDateTime.month);

    // Check if the number of months is divisible by the interval
    if (monthsBetween % recurringEvent.interval == 0) {
      // Check if the day of month matches
      if (recurringEvent.dayOfMonth != null) {
        if (startTime.day != recurringEvent.dayOfMonth) {
          return false;
        }
      } else {
        // If no day of month is specified, use the same day of month as the start date
        if (startTime.day != recurringEvent.startDateTime.day) {
          return false;
        }
      }

      // Check if the time of day overlaps
      return _timeOfDayOverlaps(
        recurringEvent.startDateTime,
        recurringEvent.endDateTime,
        startTime,
        endTime,
      );
    }

    return false;
  }

  /// Check if a yearly recurring event is active at the given time
  bool _checkYearlyRecurrence(
    RecurringEvent recurringEvent,
    DateTime startTime,
    DateTime endTime,
  ) {
    // Calculate the number of years between the event start and the requested start
    final yearsBetween = startTime.year - recurringEvent.startDateTime.year;

    // Check if the number of years is divisible by the interval
    if (yearsBetween % recurringEvent.interval == 0) {
      // Check if the month and day match
      if (recurringEvent.monthOfYear != null &&
          recurringEvent.dayOfMonth != null) {
        if (startTime.month != recurringEvent.monthOfYear ||
            startTime.day != recurringEvent.dayOfMonth) {
          return false;
        }
      } else {
        // If no month or day is specified, use the same month and day as the start date
        if (startTime.month != recurringEvent.startDateTime.month ||
            startTime.day != recurringEvent.startDateTime.day) {
          return false;
        }
      }

      // Check if the time of day overlaps
      return _timeOfDayOverlaps(
        recurringEvent.startDateTime,
        recurringEvent.endDateTime,
        startTime,
        endTime,
      );
    }

    return false;
  }

  /// Check if the time of day of two events overlaps
  bool _timeOfDayOverlaps(
    DateTime event1Start,
    DateTime event1End,
    DateTime event2Start,
    DateTime event2End,
  ) {
    // Create DateTime objects with the same date but the time from the events
    final date = DateTime(2000, 1, 1); // Use a fixed date

    final event1StartTime = DateTime(
      date.year,
      date.month,
      date.day,
      event1Start.hour,
      event1Start.minute,
      event1Start.second,
    );

    final event1EndTime = DateTime(
      date.year,
      date.month,
      date.day,
      event1End.hour,
      event1End.minute,
      event1End.second,
    );

    final event2StartTime = DateTime(
      date.year,
      date.month,
      date.day,
      event2Start.hour,
      event2Start.minute,
      event2Start.second,
    );

    final event2EndTime = DateTime(
      date.year,
      date.month,
      date.day,
      event2End.hour,
      event2End.minute,
      event2End.second,
    );

    // Check for overlap
    return event1StartTime.isBefore(event2EndTime) &&
        event1EndTime.isAfter(event2StartTime);
  }

  /// Check if two date ranges overlap
  bool _datesOverlap(
    DateTime date1Start,
    DateTime date1End,
    DateTime date2Start,
    DateTime date2End,
  ) {
    return date1Start.isBefore(date2End) && date1End.isAfter(date2Start);
  }

  /// Format a list of days of the week into a readable string
  String _formatDaysOfWeek(List<DayOfWeek> daysOfWeek) {
    final dayNames =
        daysOfWeek.map((day) {
          switch (day) {
            case DayOfWeek.monday:
              return 'Monday';
            case DayOfWeek.tuesday:
              return 'Tuesday';
            case DayOfWeek.wednesday:
              return 'Wednesday';
            case DayOfWeek.thursday:
              return 'Thursday';
            case DayOfWeek.friday:
              return 'Friday';
            case DayOfWeek.saturday:
              return 'Saturday';
            case DayOfWeek.sunday:
              return 'Sunday';
          }
        }).toList();

    if (dayNames.length == 1) {
      return dayNames.first;
    } else if (dayNames.length == 2) {
      return '${dayNames.first} and ${dayNames.last}';
    } else {
      final lastDay = dayNames.removeLast();
      return '${dayNames.join(', ')}, and $lastDay';
    }
  }

  /// Get the name of a month from its number (1-12)
  String _getMonthName(int month) {
    switch (month) {
      case 1:
        return 'January';
      case 2:
        return 'February';
      case 3:
        return 'March';
      case 4:
        return 'April';
      case 5:
        return 'May';
      case 6:
        return 'June';
      case 7:
        return 'July';
      case 8:
        return 'August';
      case 9:
        return 'September';
      case 10:
        return 'October';
      case 11:
        return 'November';
      case 12:
        return 'December';
      default:
        return 'Unknown';
    }
  }

  /// Format a date for display
  String _formatDate(DateTime date) {
    final day = date.day;
    final month = _getMonthName(date.month);
    final year = date.year;

    // Add suffix to day
    String daySuffix;
    if (day >= 11 && day <= 13) {
      daySuffix = 'th';
    } else {
      switch (day % 10) {
        case 1:
          daySuffix = 'st';
          break;
        case 2:
          daySuffix = 'nd';
          break;
        case 3:
          daySuffix = 'rd';
          break;
        default:
          daySuffix = 'th';
      }
    }

    return '$month $day$daySuffix, $year';
  }
}
