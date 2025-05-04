import 'package:flutter/material.dart';
import 'package:eventati_book/models/models.dart';

class GuestListProvider extends ChangeNotifier {
  final String eventId;
  List<Guest> _guests = [];
  List<GuestGroup> _groups = [];
  DateTime? _rsvpDeadline;
  int _expectedGuestCount = 0;
  bool _isLoading = false;
  String? _error;

  GuestListProvider({required this.eventId}) {
    _loadGuestList();
  }

  // Getters
  List<Guest> get guests => _guests;
  List<GuestGroup> get groups => _groups;
  DateTime? get rsvpDeadline => _rsvpDeadline;
  int get expectedGuestCount => _expectedGuestCount;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Calculated properties
  int get totalGuests => _guests.length;
  int get confirmedGuests =>
      _guests.where((g) => g.rsvpStatus == RsvpStatus.confirmed).length;
  int get pendingGuests =>
      _guests.where((g) => g.rsvpStatus == RsvpStatus.pending).length;
  int get declinedGuests =>
      _guests.where((g) => g.rsvpStatus == RsvpStatus.declined).length;
  int get tentativeGuests =>
      _guests.where((g) => g.rsvpStatus == RsvpStatus.tentative).length;

  // RSVP response rate
  double get rsvpResponseRate {
    if (_guests.isEmpty) return 0.0;
    final respondedGuests =
        _guests.where((g) => g.rsvpStatus != RsvpStatus.pending).length;
    return respondedGuests / _guests.length;
  }

  // Days until RSVP deadline
  int? get daysUntilRsvpDeadline {
    if (_rsvpDeadline == null) return null;
    final now = DateTime.now();
    return _rsvpDeadline!.difference(now).inDays;
  }

  // Get guests by group
  List<Guest> getGuestsByGroup(String groupId) {
    return _guests.where((guest) => guest.groupId == groupId).toList();
  }

  // Get guests by RSVP status
  List<Guest> getGuestsByRsvpStatus(RsvpStatus status) {
    return _guests.where((guest) => guest.rsvpStatus == status).toList();
  }

  // No meal preference related methods

  // Get guests who need reminders (pending and no response date)
  List<Guest> getGuestsNeedingReminders() {
    return _guests
        .where(
          (guest) =>
              guest.rsvpStatus == RsvpStatus.pending &&
              guest.rsvpResponseDate == null,
        )
        .toList();
  }

  // CRUD operations for guests
  Future<void> _loadGuestList() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // In a real app, this would load from a database or API
      await Future.delayed(const Duration(milliseconds: 500));
      _loadMockData();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> addGuest(Guest guest) async {
    _isLoading = true;
    notifyListeners();

    try {
      // In a real app, this would save to a database or API
      await Future.delayed(const Duration(milliseconds: 300));
      _guests.add(guest);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateGuest(Guest guest) async {
    _isLoading = true;
    notifyListeners();

    try {
      // In a real app, this would update in a database or API
      await Future.delayed(const Duration(milliseconds: 300));
      final index = _guests.indexWhere((g) => g.id == guest.id);
      if (index >= 0) {
        _guests[index] = guest;
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteGuest(String guestId) async {
    _isLoading = true;
    notifyListeners();

    try {
      // In a real app, this would delete from a database or API
      await Future.delayed(const Duration(milliseconds: 300));
      _guests.removeWhere((guest) => guest.id == guestId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  // CRUD operations for groups
  Future<void> addGroup(GuestGroup group) async {
    _isLoading = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 300));
      _groups.add(group);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateGroup(GuestGroup group) async {
    _isLoading = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 300));
      final index = _groups.indexWhere((g) => g.id == group.id);
      if (index >= 0) {
        _groups[index] = group;
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteGroup(String groupId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 300));
      _groups.removeWhere((group) => group.id == groupId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  // No meal preference related CRUD operations

  // RSVP deadline management
  Future<void> setRsvpDeadline(DateTime deadline) async {
    _rsvpDeadline = deadline;
    notifyListeners();
  }

  // Expected guest count management
  Future<void> setExpectedGuestCount(int count) async {
    _expectedGuestCount = count;
    notifyListeners();
  }

  // Send RSVP reminders (in a real app, this would send emails or SMS)
  Future<void> sendRsvpReminders(List<String> guestIds) async {
    _isLoading = true;
    notifyListeners();

    try {
      // In a real app, this would send actual reminders
      await Future.delayed(const Duration(milliseconds: 800));

      // For demo purposes, just mark that reminders were sent by updating the guests
      final now = DateTime.now();
      for (final guestId in guestIds) {
        final index = _guests.indexWhere((g) => g.id == guestId);
        if (index >= 0) {
          // In a real app, you might track when reminders were sent in a separate field
          // For now, we'll just update the guest to show the reminder was sent
          _guests[index] = _guests[index].copyWith(
            notes:
                '${_guests[index].notes ?? ''}${_guests[index].notes != null ? '\n' : ''}Reminder sent on ${now.toString().substring(0, 16)}',
          );
        }
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  // Mock data for testing
  void _loadMockData() {
    // Set RSVP deadline to 30 days from now
    _rsvpDeadline = DateTime.now().add(const Duration(days: 30));

    _groups = [
      GuestGroup(id: '1', name: 'Family', description: 'Close family members'),
      GuestGroup(id: '2', name: 'Friends', description: 'Close friends'),
      GuestGroup(id: '3', name: 'Colleagues', description: 'Work colleagues'),
    ];

    _guests = [
      Guest(
        id: '1',
        firstName: 'John',
        lastName: 'Doe',
        email: 'john.doe@example.com',
        phone: '555-123-4567',
        groupId: '1',
        rsvpStatus: RsvpStatus.confirmed,
        rsvpResponseDate: DateTime.now().subtract(const Duration(days: 5)),
      ),
      Guest(
        id: '2',
        firstName: 'Jane',
        lastName: 'Smith',
        email: 'jane.smith@example.com',
        phone: '555-987-6543',
        groupId: '2',
        rsvpStatus: RsvpStatus.pending,
      ),
      Guest(
        id: '3',
        firstName: 'Bob',
        lastName: 'Johnson',
        email: 'bob.johnson@example.com',
        phone: '555-456-7890',
        groupId: '3',
        rsvpStatus: RsvpStatus.declined,
        rsvpResponseDate: DateTime.now().subtract(const Duration(days: 2)),
      ),
      Guest(
        id: '4',
        firstName: 'Sarah',
        lastName: 'Williams',
        email: 'sarah.williams@example.com',
        phone: '555-222-3333',
        groupId: '2',
        rsvpStatus: RsvpStatus.confirmed,
        rsvpResponseDate: DateTime.now().subtract(const Duration(days: 7)),
        plusOne: true,
        plusOneCount: 1,
      ),
      Guest(
        id: '5',
        firstName: 'Michael',
        lastName: 'Brown',
        email: 'michael.brown@example.com',
        phone: '555-444-5555',
        groupId: '3',
        rsvpStatus: RsvpStatus.tentative,
        rsvpResponseDate: DateTime.now().subtract(const Duration(days: 3)),
      ),
    ];
  }
}
