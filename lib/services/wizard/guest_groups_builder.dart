import 'package:eventati_book/models/models.dart';

/// Builder class for creating guest groups based on event type
class GuestGroupsBuilder {
  /// Create guest groups based on event type
  static List<GuestGroup> createGuestGroupsFromEventType(String eventType) {
    if (eventType.toLowerCase().contains('wedding')) {
      return _createWeddingGuestGroups();
    } else if (eventType.toLowerCase().contains('business')) {
      return _createBusinessGuestGroups();
    } else if (eventType.toLowerCase().contains('celebration')) {
      return _createCelebrationGuestGroups();
    } else {
      return _createDefaultGuestGroups();
    }
  }

  /// Create wedding guest groups
  static List<GuestGroup> _createWeddingGuestGroups() {
    return [
      GuestGroup(
        id: '1',
        name: 'Couple\'s Family',
        description: 'Immediate family members of the couple',
        color: '#FF5733', // Coral
        guests: [],
      ),
      GuestGroup(
        id: '2',
        name: 'Wedding Party',
        description: 'Bridesmaids, groomsmen, and other wedding party members',
        color: '#33A1FF', // Light blue
        guests: [],
      ),
      GuestGroup(
        id: '3',
        name: 'Extended Family',
        description: 'Extended family members from both sides',
        color: '#33FF57', // Light green
        guests: [],
      ),
      GuestGroup(
        id: '4',
        name: 'Friends',
        description: 'Friends of the couple',
        color: '#D433FF', // Purple
        guests: [],
      ),
      GuestGroup(
        id: '5',
        name: 'Colleagues',
        description: 'Work colleagues of the couple',
        color: '#FFDD33', // Yellow
        guests: [],
      ),
    ];
  }

  /// Create business event guest groups
  static List<GuestGroup> _createBusinessGuestGroups() {
    return [
      GuestGroup(
        id: '1',
        name: 'Executives',
        description: 'C-level executives and senior management',
        color: '#3366FF', // Blue
        guests: [],
      ),
      GuestGroup(
        id: '2',
        name: 'Management',
        description: 'Middle management and team leads',
        color: '#33A1FF', // Light blue
        guests: [],
      ),
      GuestGroup(
        id: '3',
        name: 'Team Members',
        description: 'Regular team members and staff',
        color: '#33FF57', // Light green
        guests: [],
      ),
      GuestGroup(
        id: '4',
        name: 'Clients',
        description: 'Current and potential clients',
        color: '#FF5733', // Coral
        guests: [],
      ),
      GuestGroup(
        id: '5',
        name: 'Partners',
        description: 'Business partners and vendors',
        color: '#FFDD33', // Yellow
        guests: [],
      ),
      GuestGroup(
        id: '6',
        name: 'Speakers',
        description: 'Event speakers and presenters',
        color: '#D433FF', // Purple
        guests: [],
      ),
    ];
  }

  /// Create celebration guest groups
  static List<GuestGroup> _createCelebrationGuestGroups() {
    return [
      GuestGroup(
        id: '1',
        name: 'Family',
        description: 'Family members',
        color: '#FF5733', // Coral
        guests: [],
      ),
      GuestGroup(
        id: '2',
        name: 'Close Friends',
        description: 'Close friends of the host or guest of honor',
        color: '#33A1FF', // Light blue
        guests: [],
      ),
      GuestGroup(
        id: '3',
        name: 'Friends',
        description: 'Other friends',
        color: '#33FF57', // Light green
        guests: [],
      ),
      GuestGroup(
        id: '4',
        name: 'Colleagues',
        description: 'Work colleagues',
        color: '#FFDD33', // Yellow
        guests: [],
      ),
    ];
  }

  /// Create default guest groups
  static List<GuestGroup> _createDefaultGuestGroups() {
    return [
      GuestGroup(
        id: '1',
        name: 'Group 1',
        description: 'First group of guests',
        color: '#FF5733', // Coral
        guests: [],
      ),
      GuestGroup(
        id: '2',
        name: 'Group 2',
        description: 'Second group of guests',
        color: '#33A1FF', // Light blue
        guests: [],
      ),
      GuestGroup(
        id: '3',
        name: 'Group 3',
        description: 'Third group of guests',
        color: '#33FF57', // Light green
        guests: [],
      ),
    ];
  }
}
