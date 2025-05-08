import 'package:eventati_book/models/event_models/event.dart';

/// Temporary database for event data
class EventDB {
  /// Get mock events
  static List<Event> getEvents() {
    return [
      Event(
        id: 'event_1',
        name: 'Wedding',
        type: EventType.wedding,
        date: DateTime(2023, 6, 15),
        location: 'Grand Plaza Hotel',
        budget: 25000.0,
        guestCount: 150,
        userId: 'user_1',
        createdAt: DateTime(2023, 1, 10),
        updatedAt: DateTime(2023, 1, 10),
        status: 'active',
      ),
      Event(
        id: 'event_2',
        name: 'Corporate Conference',
        type: EventType.business,
        date: DateTime(2023, 8, 20),
        location: 'Business Center',
        budget: 15000.0,
        guestCount: 100,
        userId: 'user_2',
        createdAt: DateTime(2023, 2, 15),
        updatedAt: DateTime(2023, 2, 15),
        status: 'active',
      ),
      Event(
        id: 'event_3',
        name: 'Birthday Party',
        type: EventType.celebration,
        date: DateTime(2023, 5, 10),
        location: 'Sunset Lounge',
        budget: 5000.0,
        guestCount: 50,
        userId: 'user_1',
        createdAt: DateTime(2023, 3, 5),
        updatedAt: DateTime(2023, 3, 5),
        status: 'active',
      ),
      Event(
        id: 'event_4',
        name: 'Anniversary Celebration',
        type: EventType.celebration,
        date: DateTime(2023, 9, 25),
        location: 'Seaside Resort',
        budget: 10000.0,
        guestCount: 75,
        userId: 'user_3',
        createdAt: DateTime(2023, 4, 12),
        updatedAt: DateTime(2023, 4, 12),
        status: 'active',
      ),
      Event(
        id: 'event_5',
        name: 'Product Launch',
        type: EventType.business,
        date: DateTime(2023, 7, 5),
        location: 'Tech Hub',
        budget: 20000.0,
        guestCount: 200,
        userId: 'user_2',
        createdAt: DateTime(2023, 5, 1),
        updatedAt: DateTime(2023, 5, 1),
        status: 'active',
      ),
    ];
  }

  /// Get event by ID
  static Event? getEventById(String id) {
    final events = getEvents();
    try {
      return events.firstWhere((event) => event.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get events for a specific user
  static List<Event> getEventsForUser(String userId) {
    final events = getEvents();
    return events.where((event) => event.userId == userId).toList();
  }
}
