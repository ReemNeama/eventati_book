import 'package:eventati_book/models/planning_models/guest.dart';
import 'package:flutter/material.dart';

/// Guest group model for tempDB
class GuestGroup {
  final String id;
  final String name;
  final String description;
  final Color color;

  GuestGroup({
    required this.id,
    required this.name,
    required this.description,
    required this.color,
  });
}

/// Temporary database for guest data
class GuestDB {
  /// Get mock guests for an event
  static List<Guest> getGuests(String eventId) {
    // Different guests based on event ID
    if (eventId == 'event_1') {
      return _getWeddingGuests();
    } else if (eventId == 'event_2' || eventId == 'event_5') {
      return _getBusinessGuests();
    } else {
      return _getCelebrationGuests();
    }
  }

  /// Get mock guest groups for an event
  static List<GuestGroup> getGuestGroups(String eventId) {
    // Different groups based on event ID
    if (eventId == 'event_1') {
      return _getWeddingGuestGroups();
    } else if (eventId == 'event_2' || eventId == 'event_5') {
      return _getBusinessGuestGroups();
    } else {
      return _getCelebrationGuestGroups();
    }
  }

  /// Get wedding guests
  static List<Guest> _getWeddingGuests() {
    return [
      Guest(
        id: 'guest_1',
        firstName: 'John',
        lastName: 'Smith',
        email: 'john.smith@example.com',
        phone: '+1234567890',
        rsvpStatus: RsvpStatus.confirmed,
        groupId: 'group_1',
      ),
      Guest(
        id: 'guest_2',
        firstName: 'Jane',
        lastName: 'Smith',
        email: 'jane.smith@example.com',
        phone: '+1234567891',
        rsvpStatus: RsvpStatus.confirmed,
        groupId: 'group_1',
      ),
      Guest(
        id: 'guest_3',
        firstName: 'Michael',
        lastName: 'Johnson',
        email: 'michael.johnson@example.com',
        phone: '+1234567892',
        rsvpStatus: RsvpStatus.pending,
        groupId: 'group_2',
      ),
      Guest(
        id: 'guest_4',
        firstName: 'Emily',
        lastName: 'Johnson',
        email: 'emily.johnson@example.com',
        phone: '+1234567893',
        rsvpStatus: RsvpStatus.pending,
        groupId: 'group_2',
      ),
      Guest(
        id: 'guest_5',
        firstName: 'Robert',
        lastName: 'Williams',
        email: 'robert.williams@example.com',
        phone: '+1234567894',
        rsvpStatus: RsvpStatus.declined,
        groupId: 'group_3',
      ),
    ];
  }

  /// Get business guests
  static List<Guest> _getBusinessGuests() {
    return [
      Guest(
        id: 'guest_6',
        firstName: 'David',
        lastName: 'Brown',
        email: 'david.brown@example.com',
        phone: '+1234567895',
        rsvpStatus: RsvpStatus.confirmed,
        groupId: 'group_4',
      ),
      Guest(
        id: 'guest_7',
        firstName: 'Sarah',
        lastName: 'Miller',
        email: 'sarah.miller@example.com',
        phone: '+1234567896',
        rsvpStatus: RsvpStatus.confirmed,
        groupId: 'group_4',
      ),
      Guest(
        id: 'guest_8',
        firstName: 'James',
        lastName: 'Wilson',
        email: 'james.wilson@example.com',
        phone: '+1234567897',
        rsvpStatus: RsvpStatus.pending,
        groupId: 'group_5',
      ),
      Guest(
        id: 'guest_9',
        firstName: 'Jennifer',
        lastName: 'Taylor',
        email: 'jennifer.taylor@example.com',
        phone: '+1234567898',
        rsvpStatus: RsvpStatus.declined,
        groupId: 'group_5',
      ),
    ];
  }

  /// Get celebration guests
  static List<Guest> _getCelebrationGuests() {
    return [
      Guest(
        id: 'guest_10',
        firstName: 'Thomas',
        lastName: 'Anderson',
        email: 'thomas.anderson@example.com',
        phone: '+1234567899',
        rsvpStatus: RsvpStatus.confirmed,
        groupId: 'group_6',
      ),
      Guest(
        id: 'guest_11',
        firstName: 'Lisa',
        lastName: 'Anderson',
        email: 'lisa.anderson@example.com',
        phone: '+1234567900',
        rsvpStatus: RsvpStatus.confirmed,
        groupId: 'group_6',
      ),
      Guest(
        id: 'guest_12',
        firstName: 'Daniel',
        lastName: 'Martinez',
        email: 'daniel.martinez@example.com',
        phone: '+1234567901',
        rsvpStatus: RsvpStatus.pending,
        groupId: 'group_7',
      ),
    ];
  }

  /// Get wedding guest groups
  static List<GuestGroup> _getWeddingGuestGroups() {
    return [
      GuestGroup(
        id: 'group_1',
        name: 'Family',
        description: 'Close family members',
        color: Colors.blue,
      ),
      GuestGroup(
        id: 'group_2',
        name: 'Friends',
        description: 'Close friends',
        color: Colors.green,
      ),
      GuestGroup(
        id: 'group_3',
        name: 'Colleagues',
        description: 'Work colleagues',
        color: Colors.orange,
      ),
    ];
  }

  /// Get business guest groups
  static List<GuestGroup> _getBusinessGuestGroups() {
    return [
      GuestGroup(
        id: 'group_4',
        name: 'Executives',
        description: 'Company executives',
        color: Colors.purple,
      ),
      GuestGroup(
        id: 'group_5',
        name: 'Partners',
        description: 'Business partners',
        color: Colors.teal,
      ),
    ];
  }

  /// Get celebration guest groups
  static List<GuestGroup> _getCelebrationGuestGroups() {
    return [
      GuestGroup(
        id: 'group_6',
        name: 'Family',
        description: 'Close family members',
        color: Colors.red,
      ),
      GuestGroup(
        id: 'group_7',
        name: 'Friends',
        description: 'Close friends',
        color: Colors.amber,
      ),
    ];
  }
}
