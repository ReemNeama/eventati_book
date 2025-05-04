import 'package:flutter/material.dart';
import 'package:eventati_book/models/models.dart';

/// Provider for managing guest lists and RSVPs for an event.
///
/// The GuestListProvider is responsible for:
/// * Managing the list of guests and guest groups
/// * Tracking RSVP statuses and responses
/// * Calculating guest statistics and summaries
/// * Setting and tracking RSVP deadlines
/// * Sending RSVP reminders
/// * Organizing guests into groups
///
/// Each event has its own guest list, identified by the eventId.
/// This provider currently uses mock data, but would connect to a
/// database or API in a production environment.
///
/// Usage example:
/// ```dart
/// // Create a provider for a specific event
/// final guestListProvider = GuestListProvider(eventId: 'event123');
///
/// // Access the provider from the widget tree
/// final guestListProvider = Provider.of<GuestListProvider>(context);
///
/// // Get guest statistics
/// final totalGuests = guestListProvider.totalGuests;
/// final confirmedGuests = guestListProvider.confirmedGuests;
/// final responseRate = guestListProvider.rsvpResponseRate;
///
/// // Get guests by group
/// final familyGuests = guestListProvider.getGuestsByGroup('family');
///
/// // Add a new guest
/// final newGuest = Guest(
///   id: 'guest1',
///   firstName: 'John',
///   lastName: 'Doe',
///   email: 'john.doe@example.com',
///   groupId: 'family',
///   rsvpStatus: RsvpStatus.pending,
/// );
/// await guestListProvider.addGuest(newGuest);
///
/// // Send RSVP reminders
/// final guestsNeedingReminders = guestListProvider.getGuestsNeedingReminders();
/// await guestListProvider.sendRsvpReminders(
///   guestsNeedingReminders.map((g) => g.id).toList(),
/// );
/// ```
class GuestListProvider extends ChangeNotifier {
  /// The unique identifier of the event this guest list belongs to
  final String eventId;

  /// List of all guests for the event
  List<Guest> _guests = [];

  /// List of guest groups (e.g., Family, Friends, Colleagues)
  List<GuestGroup> _groups = [];

  /// The deadline by which guests should respond to their invitation
  DateTime? _rsvpDeadline;

  /// The expected total number of guests for planning purposes
  int _expectedGuestCount = 0;

  /// Flag indicating if the provider is currently loading data
  bool _isLoading = false;

  /// Error message if an operation fails
  String? _error;

  /// Creates a new GuestListProvider for the specified event
  ///
  /// Automatically loads guest list data when instantiated
  GuestListProvider({required this.eventId}) {
    _loadGuestList();
  }

  /// Returns the list of all guests
  List<Guest> get guests => _guests;

  /// Returns the list of all guest groups
  List<GuestGroup> get groups => _groups;

  /// Returns the RSVP deadline date, if set
  DateTime? get rsvpDeadline => _rsvpDeadline;

  /// Returns the expected total number of guests
  int get expectedGuestCount => _expectedGuestCount;

  /// Indicates if the provider is currently loading data
  bool get isLoading => _isLoading;

  /// Returns the error message if an operation has failed, null otherwise
  String? get error => _error;

  /// The total number of guests in the guest list
  int get totalGuests => _guests.length;

  /// The number of guests who have confirmed their attendance
  int get confirmedGuests =>
      _guests.where((g) => g.rsvpStatus == RsvpStatus.confirmed).length;

  /// The number of guests who have not yet responded
  int get pendingGuests =>
      _guests.where((g) => g.rsvpStatus == RsvpStatus.pending).length;

  /// The number of guests who have declined their invitation
  int get declinedGuests =>
      _guests.where((g) => g.rsvpStatus == RsvpStatus.declined).length;

  /// The number of guests who have responded as maybe/tentative
  int get tentativeGuests =>
      _guests.where((g) => g.rsvpStatus == RsvpStatus.tentative).length;

  /// The percentage of guests who have responded to their invitation
  ///
  /// Returns a value between 0.0 and 1.0 representing the response rate.
  /// Returns 0.0 if there are no guests.
  double get rsvpResponseRate {
    if (_guests.isEmpty) return 0.0;
    final respondedGuests =
        _guests.where((g) => g.rsvpStatus != RsvpStatus.pending).length;
    return respondedGuests / _guests.length;
  }

  /// The number of days remaining until the RSVP deadline
  ///
  /// Returns null if no RSVP deadline has been set.
  /// Can return a negative number if the deadline has passed.
  int? get daysUntilRsvpDeadline {
    if (_rsvpDeadline == null) return null;
    final now = DateTime.now();
    return _rsvpDeadline!.difference(now).inDays;
  }

  /// Returns all guests belonging to the specified group
  ///
  /// [groupId] The ID of the group to filter by
  List<Guest> getGuestsByGroup(String groupId) {
    return _guests.where((guest) => guest.groupId == groupId).toList();
  }

  /// Returns all guests with the specified RSVP status
  ///
  /// [status] The RSVP status to filter by (confirmed, declined, pending, tentative)
  List<Guest> getGuestsByRsvpStatus(RsvpStatus status) {
    return _guests.where((guest) => guest.rsvpStatus == status).toList();
  }

  /// Returns all guests who need RSVP reminders
  ///
  /// These are guests who have a pending RSVP status and have not yet
  /// responded (no response date recorded).
  List<Guest> getGuestsNeedingReminders() {
    return _guests
        .where(
          (guest) =>
              guest.rsvpStatus == RsvpStatus.pending &&
              guest.rsvpResponseDate == null,
        )
        .toList();
  }

  /// Loads the guest list data for the event
  ///
  /// This is called automatically when the provider is created.
  /// In a real application, this would fetch data from a database or API.
  /// Currently uses mock data for demonstration purposes.
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

  /// Adds a new guest to the guest list
  ///
  /// [guest] The guest to add
  ///
  /// In a real application, this would persist the guest to a database or API.
  /// Notifies listeners when the operation completes.
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

  /// Updates an existing guest's information
  ///
  /// [guest] The updated guest (must have the same ID as an existing guest)
  ///
  /// In a real application, this would update the guest in a database or API.
  /// Notifies listeners when the operation completes.
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

  /// Removes a guest from the guest list
  ///
  /// [guestId] The ID of the guest to remove
  ///
  /// In a real application, this would delete the guest from a database or API.
  /// Notifies listeners when the operation completes.
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

  /// Adds a new guest group to the guest list
  ///
  /// [group] The guest group to add
  ///
  /// In a real application, this would persist the group to a database or API.
  /// Notifies listeners when the operation completes.
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

  /// Updates an existing guest group
  ///
  /// [group] The updated guest group (must have the same ID as an existing group)
  ///
  /// In a real application, this would update the group in a database or API.
  /// Notifies listeners when the operation completes.
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

  /// Removes a guest group from the guest list
  ///
  /// [groupId] The ID of the guest group to remove
  ///
  /// In a real application, this would delete the group from a database or API.
  /// Note: This does not automatically update the groupId of guests in this group.
  /// Notifies listeners when the operation completes.
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

  /// Sets the RSVP deadline for the event
  ///
  /// [deadline] The date by which guests should respond to their invitation
  ///
  /// This deadline is used for planning purposes and for calculating days remaining.
  /// Notifies listeners when the deadline is updated.
  Future<void> setRsvpDeadline(DateTime deadline) async {
    _rsvpDeadline = deadline;
    notifyListeners();
  }

  /// Sets the expected total number of guests for the event
  ///
  /// [count] The expected number of guests
  ///
  /// This count is used for planning purposes and may differ from the actual
  /// number of guests in the guest list.
  /// Notifies listeners when the count is updated.
  Future<void> setExpectedGuestCount(int count) async {
    _expectedGuestCount = count;
    notifyListeners();
  }

  /// Sends RSVP reminders to the specified guests
  ///
  /// [guestIds] List of guest IDs to send reminders to
  ///
  /// In a real application, this would send actual email or SMS reminders.
  /// Currently, it just updates the guest notes to indicate a reminder was sent.
  /// Notifies listeners when the operation completes.
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

  /// Loads mock data for testing and demonstration purposes
  ///
  /// This method creates sample guest groups and guests.
  /// In a real application, this would be replaced with data from a database or API.
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
