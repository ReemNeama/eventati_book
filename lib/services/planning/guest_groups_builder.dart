import 'package:eventati_book/models/planning_models/guest.dart';
import 'package:eventati_book/utils/logger.dart';

/// Service for building guest groups based on event details
class GuestGroupsBuilder {
  /// Create default guest groups based on event type
  static List<GuestGroup> createDefaultGuestGroups(String eventType) {
    Logger.i(
      'Creating default guest groups for $eventType event',
      tag: 'GuestGroupsBuilder',
    );

    if (eventType.toLowerCase().contains('wedding')) {
      return _createWeddingGuestGroups();
    } else if (eventType.toLowerCase().contains('business')) {
      return _createBusinessGuestGroups();
    } else {
      return _createCelebrationGuestGroups();
    }
  }

  /// Create wedding-specific guest groups
  static List<GuestGroup> _createWeddingGuestGroups() {
    return [
      GuestGroup(
        id: 'wedding_group_1_${DateTime.now().millisecondsSinceEpoch}',
        name: 'Family - Partner 1',
        description: 'Immediate and extended family of Partner 1',
        color: '#FF5733', // Coral
      ),
      GuestGroup(
        id: 'wedding_group_2_${DateTime.now().millisecondsSinceEpoch}',
        name: 'Family - Partner 2',
        description: 'Immediate and extended family of Partner 2',
        color: '#33A1FF', // Light Blue
      ),
      GuestGroup(
        id: 'wedding_group_3_${DateTime.now().millisecondsSinceEpoch}',
        name: 'Wedding Party',
        description: 'Bridesmaids, groomsmen, and other wedding party members',
        color: '#9C33FF', // Purple
      ),
      GuestGroup(
        id: 'wedding_group_4_${DateTime.now().millisecondsSinceEpoch}',
        name: 'Friends - Partner 1',
        description: 'Friends of Partner 1',
        color: '#FF33A8', // Pink
      ),
      GuestGroup(
        id: 'wedding_group_5_${DateTime.now().millisecondsSinceEpoch}',
        name: 'Friends - Partner 2',
        description: 'Friends of Partner 2',
        color: '#33FF57', // Green
      ),
      GuestGroup(
        id: 'wedding_group_6_${DateTime.now().millisecondsSinceEpoch}',
        name: 'Colleagues',
        description: 'Work colleagues and professional connections',
        color: '#FFD433', // Yellow
      ),
    ];
  }

  /// Create business event-specific guest groups
  static List<GuestGroup> _createBusinessGuestGroups() {
    return [
      GuestGroup(
        id: 'business_group_1_${DateTime.now().millisecondsSinceEpoch}',
        name: 'Executives',
        description: 'C-level executives and senior management',
        color: '#3358FF', // Blue
      ),
      GuestGroup(
        id: 'business_group_2_${DateTime.now().millisecondsSinceEpoch}',
        name: 'Team Members',
        description: 'Internal team members and employees',
        color: '#33FFC1', // Teal
      ),
      GuestGroup(
        id: 'business_group_3_${DateTime.now().millisecondsSinceEpoch}',
        name: 'Clients',
        description: 'Current clients and customers',
        color: '#FF8C33', // Orange
      ),
      GuestGroup(
        id: 'business_group_4_${DateTime.now().millisecondsSinceEpoch}',
        name: 'Prospects',
        description: 'Potential clients and business leads',
        color: '#FF3333', // Red
      ),
      GuestGroup(
        id: 'business_group_5_${DateTime.now().millisecondsSinceEpoch}',
        name: 'Partners',
        description: 'Business partners and vendors',
        color: '#B1FF33', // Lime
      ),
      GuestGroup(
        id: 'business_group_6_${DateTime.now().millisecondsSinceEpoch}',
        name: 'Speakers/Presenters',
        description: 'Event speakers, presenters, and special guests',
        color: '#9E33FF', // Purple
      ),
      GuestGroup(
        id: 'business_group_7_${DateTime.now().millisecondsSinceEpoch}',
        name: 'Media',
        description: 'Press and media representatives',
        color: '#FF33F5', // Pink
      ),
    ];
  }

  /// Create celebration-specific guest groups
  static List<GuestGroup> _createCelebrationGuestGroups() {
    return [
      GuestGroup(
        id: 'celebration_group_1_${DateTime.now().millisecondsSinceEpoch}',
        name: 'Family',
        description: 'Immediate and extended family members',
        color: '#FF5733', // Coral
      ),
      GuestGroup(
        id: 'celebration_group_2_${DateTime.now().millisecondsSinceEpoch}',
        name: 'Close Friends',
        description: 'Close personal friends',
        color: '#33A1FF', // Light Blue
      ),
      GuestGroup(
        id: 'celebration_group_3_${DateTime.now().millisecondsSinceEpoch}',
        name: 'Friends',
        description: 'Other friends and acquaintances',
        color: '#33FF57', // Green
      ),
      GuestGroup(
        id: 'celebration_group_4_${DateTime.now().millisecondsSinceEpoch}',
        name: 'Colleagues',
        description: 'Work colleagues and professional connections',
        color: '#FFD433', // Yellow
      ),
      GuestGroup(
        id: 'celebration_group_5_${DateTime.now().millisecondsSinceEpoch}',
        name: 'Neighbors',
        description: 'Neighbors and community members',
        color: '#FF33A8', // Pink
      ),
    ];
  }

  /// Create sample guests for testing or demonstration purposes
  static List<Guest> createSampleGuests(List<GuestGroup> groups, int count) {
    Logger.i('Creating $count sample guests', tag: 'GuestGroupsBuilder');

    final guests = <Guest>[];
    final firstNames = [
      'John',
      'Jane',
      'Michael',
      'Emily',
      'David',
      'Sarah',
      'Robert',
      'Lisa',
      'William',
      'Emma',
      'James',
      'Olivia',
      'Daniel',
      'Sophia',
      'Matthew',
      'Ava',
    ];
    final lastNames = [
      'Smith',
      'Johnson',
      'Williams',
      'Jones',
      'Brown',
      'Davis',
      'Miller',
      'Wilson',
      'Moore',
      'Taylor',
      'Anderson',
      'Thomas',
      'Jackson',
      'White',
      'Harris',
      'Martin',
    ];

    for (int i = 0; i < count; i++) {
      final firstNameIndex = i % firstNames.length;
      final lastNameIndex = (i ~/ firstNames.length) % lastNames.length;
      final groupIndex = i % groups.length;

      guests.add(
        Guest(
          id: 'guest_${DateTime.now().millisecondsSinceEpoch}_$i',
          firstName: firstNames[firstNameIndex],
          lastName: lastNames[lastNameIndex],
          email:
              '${firstNames[firstNameIndex].toLowerCase()}.${lastNames[lastNameIndex].toLowerCase()}@example.com',
          phone: '+1${5550000 + i}',
          groupId: groups[groupIndex].id,
          rsvpStatus: RsvpStatus.pending,
          notes:
              i % 5 == 0
                  ? 'Dietary restrictions: Vegetarian'
                  : (i % 10 == 0 ? 'VIP guest' : null),
        ),
      );
    }

    return guests;
  }

  /// Distribute guests evenly across tables
  static Map<String, List<String>> assignGuestsToTables(
    List<Guest> guests,
    int tableCount,
    int seatsPerTable,
  ) {
    Logger.i(
      'Assigning ${guests.length} guests to $tableCount tables with $seatsPerTable seats each',
      tag: 'GuestGroupsBuilder',
    );

    final Map<String, List<String>> tablesToGuests = {};

    // Initialize tables
    for (int i = 1; i <= tableCount; i++) {
      tablesToGuests['Table $i'] = [];
    }

    // Group guests by group ID to keep groups together
    final Map<String, List<Guest>> guestsByGroup = {};
    for (final guest in guests) {
      // Skip guests without a group ID
      if (guest.groupId == null) continue;

      final groupId = guest.groupId!;
      if (!guestsByGroup.containsKey(groupId)) {
        guestsByGroup[groupId] = [];
      }
      guestsByGroup[groupId]!.add(guest);
    }

    // Sort groups by size (largest first) to optimize table assignments
    final sortedGroups =
        guestsByGroup.values.toList()
          ..sort((a, b) => b.length.compareTo(a.length));

    // Assign groups to tables
    for (final group in sortedGroups) {
      // Find table with most available seats
      String? bestTable;
      int maxAvailableSeats = 0;

      for (final table in tablesToGuests.keys) {
        final availableSeats = seatsPerTable - tablesToGuests[table]!.length;
        if (availableSeats > maxAvailableSeats) {
          maxAvailableSeats = availableSeats;
          bestTable = table;
        }
      }

      // If group is too large for any single table, split it across tables
      if (group.length > maxAvailableSeats) {
        // Assign as many as possible to the best table
        for (int i = 0; i < maxAvailableSeats; i++) {
          tablesToGuests[bestTable!]!.add(group[i].id);
        }

        // Assign remaining guests to other tables
        for (int i = maxAvailableSeats; i < group.length; i++) {
          // Find next best table
          String? nextTable;
          int nextMaxSeats = 0;

          for (final table in tablesToGuests.keys) {
            if (table == bestTable) continue;

            final availableSeats =
                seatsPerTable - tablesToGuests[table]!.length;
            if (availableSeats > nextMaxSeats) {
              nextMaxSeats = availableSeats;
              nextTable = table;
            }
          }

          if (nextTable != null) {
            tablesToGuests[nextTable]!.add(group[i].id);
          }
        }
      } else {
        // Assign whole group to best table
        for (final guest in group) {
          tablesToGuests[bestTable!]!.add(guest.id);
        }
      }
    }

    return tablesToGuests;
  }
}
