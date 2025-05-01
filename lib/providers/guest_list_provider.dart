import 'package:flutter/material.dart';
import 'package:eventati_book/models/guest.dart';

class GuestListProvider extends ChangeNotifier {
  final String eventId;
  List<Guest> _guests = [];
  List<GuestGroup> _groups = [];
  List<MealPreference> _mealPreferences = [];
  bool _isLoading = false;
  String? _error;

  GuestListProvider({required this.eventId}) {
    _loadGuestList();
  }

  // Getters
  List<Guest> get guests => _guests;
  List<GuestGroup> get groups => _groups;
  List<MealPreference> get mealPreferences => _mealPreferences;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Calculated properties
  int get totalGuests => _guests.length;
  int get confirmedGuests => _guests.where((g) => g.rsvpStatus == RsvpStatus.confirmed).length;
  int get pendingGuests => _guests.where((g) => g.rsvpStatus == RsvpStatus.pending).length;
  int get declinedGuests => _guests.where((g) => g.rsvpStatus == RsvpStatus.declined).length;

  // Get guests by group
  List<Guest> getGuestsByGroup(String groupId) {
    return _guests.where((guest) => guest.groupId == groupId).toList();
  }

  // Get guests by RSVP status
  List<Guest> getGuestsByRsvpStatus(RsvpStatus status) {
    return _guests.where((guest) => guest.rsvpStatus == status).toList();
  }

  // CRUD operations
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

  // Mock data for testing
  void _loadMockData() {
    _groups = [
      GuestGroup(id: '1', name: 'Family'),
      GuestGroup(id: '2', name: 'Friends'),
      GuestGroup(id: '3', name: 'Colleagues'),
    ];

    _mealPreferences = [
      MealPreference(id: '1', name: 'Standard'),
      MealPreference(id: '2', name: 'Vegetarian'),
      MealPreference(id: '3', name: 'Vegan'),
      MealPreference(id: '4', name: 'Gluten-Free'),
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
        mealPreferenceId: '1',
      ),
      Guest(
        id: '2',
        firstName: 'Jane',
        lastName: 'Smith',
        email: 'jane.smith@example.com',
        phone: '555-987-6543',
        groupId: '2',
        rsvpStatus: RsvpStatus.pending,
        mealPreferenceId: '2',
      ),
      Guest(
        id: '3',
        firstName: 'Bob',
        lastName: 'Johnson',
        email: 'bob.johnson@example.com',
        phone: '555-456-7890',
        groupId: '3',
        rsvpStatus: RsvpStatus.declined,
        mealPreferenceId: '1',
      ),
    ];
  }
}
