import 'package:eventati_book/models/models.dart';

/// Enum for recurring event frequency
enum RecurrenceFrequency {
  /// Daily recurrence
  daily,

  /// Weekly recurrence
  weekly,

  /// Monthly recurrence
  monthly,

  /// Yearly recurrence
  yearly,
}

/// Enum for days of the week
enum DayOfWeek {
  /// Monday
  monday,

  /// Tuesday
  tuesday,

  /// Wednesday
  wednesday,

  /// Thursday
  thursday,

  /// Friday
  friday,

  /// Saturday
  saturday,

  /// Sunday
  sunday,
}

/// Model for recurring events
class RecurringEvent {
  /// Unique identifier for the recurring event
  final String id;

  /// The ID of the user who created the event
  final String userId;

  /// The ID of the event this recurring event is associated with (optional)
  final String? eventId;

  /// The ID of the booking this recurring event is associated with (optional)
  final String? bookingId;

  /// The title of the event
  final String title;

  /// The description of the event
  final String description;

  /// The location of the event
  final String location;

  /// The start date and time of the event
  final DateTime startDateTime;

  /// The end date and time of the event
  final DateTime endDateTime;

  /// The frequency of recurrence
  final RecurrenceFrequency frequency;

  /// The interval between recurrences (e.g., every 2 weeks)
  final int interval;

  /// The days of the week the event occurs on (for weekly recurrence)
  final List<DayOfWeek>? daysOfWeek;

  /// The day of the month the event occurs on (for monthly recurrence)
  final int? dayOfMonth;

  /// The month of the year the event occurs on (for yearly recurrence)
  final int? monthOfYear;

  /// The end date of the recurrence (optional)
  final DateTime? endDate;

  /// The number of occurrences (optional)
  final int? count;

  /// The dates to exclude from the recurrence
  final List<DateTime>? excludeDates;

  /// The dates to include in the recurrence (overrides the pattern)
  final List<DateTime>? includeDates;

  /// Whether reminders are enabled for this event
  final bool enableReminders;

  /// The number of minutes before the event to send a reminder
  final int? reminderMinutesBefore;

  /// The date and time the event was created
  final DateTime createdAt;

  /// The date and time the event was last updated
  final DateTime updatedAt;

  /// Constructor
  RecurringEvent({
    required this.id,
    required this.userId,
    this.eventId,
    this.bookingId,
    required this.title,
    required this.description,
    required this.location,
    required this.startDateTime,
    required this.endDateTime,
    required this.frequency,
    this.interval = 1,
    this.daysOfWeek,
    this.dayOfMonth,
    this.monthOfYear,
    this.endDate,
    this.count,
    this.excludeDates,
    this.includeDates,
    this.enableReminders = true,
    this.reminderMinutesBefore = 60,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  /// Create a RecurringEvent from a map
  factory RecurringEvent.fromMap(Map<String, dynamic> map) {
    return RecurringEvent(
      id: map['id'],
      userId: map['user_id'],
      eventId: map['event_id'],
      bookingId: map['booking_id'],
      title: map['title'],
      description: map['description'] ?? '',
      location: map['location'] ?? '',
      startDateTime: DateTime.parse(map['start_date_time']),
      endDateTime: DateTime.parse(map['end_date_time']),
      frequency: RecurrenceFrequency.values.firstWhere(
        (e) => e.toString().split('.').last == map['frequency'],
        orElse: () => RecurrenceFrequency.weekly,
      ),
      interval: map['interval'] ?? 1,
      daysOfWeek: map['days_of_week'] != null
          ? (map['days_of_week'] as List)
              .map((day) => DayOfWeek.values.firstWhere(
                    (e) => e.toString().split('.').last == day,
                    orElse: () => DayOfWeek.monday,
                  ))
              .toList()
          : null,
      dayOfMonth: map['day_of_month'],
      monthOfYear: map['month_of_year'],
      endDate:
          map['end_date'] != null ? DateTime.parse(map['end_date']) : null,
      count: map['count'],
      excludeDates: map['exclude_dates'] != null
          ? (map['exclude_dates'] as List)
              .map((date) => DateTime.parse(date))
              .toList()
          : null,
      includeDates: map['include_dates'] != null
          ? (map['include_dates'] as List)
              .map((date) => DateTime.parse(date))
              .toList()
          : null,
      enableReminders: map['enable_reminders'] ?? true,
      reminderMinutesBefore: map['reminder_minutes_before'] ?? 60,
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  /// Convert RecurringEvent to a map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'event_id': eventId,
      'booking_id': bookingId,
      'title': title,
      'description': description,
      'location': location,
      'start_date_time': startDateTime.toIso8601String(),
      'end_date_time': endDateTime.toIso8601String(),
      'frequency': frequency.toString().split('.').last,
      'interval': interval,
      'days_of_week': daysOfWeek
          ?.map((day) => day.toString().split('.').last)
          .toList(),
      'day_of_month': dayOfMonth,
      'month_of_year': monthOfYear,
      'end_date': endDate?.toIso8601String(),
      'count': count,
      'exclude_dates':
          excludeDates?.map((date) => date.toIso8601String()).toList(),
      'include_dates':
          includeDates?.map((date) => date.toIso8601String()).toList(),
      'enable_reminders': enableReminders,
      'reminder_minutes_before': reminderMinutesBefore,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Create a copy of this RecurringEvent with the given fields replaced with new values
  RecurringEvent copyWith({
    String? id,
    String? userId,
    String? eventId,
    String? bookingId,
    String? title,
    String? description,
    String? location,
    DateTime? startDateTime,
    DateTime? endDateTime,
    RecurrenceFrequency? frequency,
    int? interval,
    List<DayOfWeek>? daysOfWeek,
    int? dayOfMonth,
    int? monthOfYear,
    DateTime? endDate,
    int? count,
    List<DateTime>? excludeDates,
    List<DateTime>? includeDates,
    bool? enableReminders,
    int? reminderMinutesBefore,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RecurringEvent(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      eventId: eventId ?? this.eventId,
      bookingId: bookingId ?? this.bookingId,
      title: title ?? this.title,
      description: description ?? this.description,
      location: location ?? this.location,
      startDateTime: startDateTime ?? this.startDateTime,
      endDateTime: endDateTime ?? this.endDateTime,
      frequency: frequency ?? this.frequency,
      interval: interval ?? this.interval,
      daysOfWeek: daysOfWeek ?? this.daysOfWeek,
      dayOfMonth: dayOfMonth ?? this.dayOfMonth,
      monthOfYear: monthOfYear ?? this.monthOfYear,
      endDate: endDate ?? this.endDate,
      count: count ?? this.count,
      excludeDates: excludeDates ?? this.excludeDates,
      includeDates: includeDates ?? this.includeDates,
      enableReminders: enableReminders ?? this.enableReminders,
      reminderMinutesBefore: reminderMinutesBefore ?? this.reminderMinutesBefore,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}
