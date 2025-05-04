import 'package:flutter/material.dart';
import 'package:eventati_book/models/models.dart';

/// Provider to store wizard data and provide service recommendations
class ServiceRecommendationProvider extends ChangeNotifier {
  // Wizard data
  Map<String, dynamic>? _wizardData;

  // Whether to show only recommended services
  bool _showOnlyRecommended = false;

  // Getters
  Map<String, dynamic>? get wizardData => _wizardData;
  bool get showOnlyRecommended => _showOnlyRecommended;

  // Set wizard data
  void setWizardData(Map<String, dynamic> data) {
    _wizardData = data;
    notifyListeners();
  }

  // Toggle show only recommended
  void toggleShowOnlyRecommended() {
    _showOnlyRecommended = !_showOnlyRecommended;
    notifyListeners();
  }

  // Set show only recommended
  void setShowOnlyRecommended(bool value) {
    _showOnlyRecommended = value;
    notifyListeners();
  }

  // Check if a venue is recommended
  bool isVenueRecommended(Venue venue) {
    if (_wizardData == null) return false;

    final int guestCount = _wizardData!['guestCount'] as int;
    final String eventType = _wizardData!['eventType'] as String;
    final Map<String, bool> selectedServices = Map<String, bool>.from(
      _wizardData!['selectedServices'],
    );

    // Check if venue service was selected in the wizard
    if (!selectedServices.containsKey('Venue') || !selectedServices['Venue']!) {
      return false;
    }

    // Check if venue can accommodate the guest count
    final bool hasCapacity =
        venue.minCapacity <= guestCount && venue.maxCapacity >= guestCount;

    // Check if venue is suitable for the event type
    bool matchesEventType = true;
    if (eventType.toLowerCase().contains('wedding')) {
      matchesEventType = venue.venueTypes.any(
        (type) =>
            type.toLowerCase().contains('wedding') ||
            type.toLowerCase().contains('ballroom') ||
            type.toLowerCase().contains('garden'),
      );
    } else if (eventType.toLowerCase().contains('business')) {
      matchesEventType = venue.venueTypes.any(
        (type) =>
            type.toLowerCase().contains('conference') ||
            type.toLowerCase().contains('meeting') ||
            type.toLowerCase().contains('corporate'),
      );
    } else if (eventType.toLowerCase().contains('celebration')) {
      matchesEventType = venue.venueTypes.any(
        (type) =>
            type.toLowerCase().contains('party') ||
            type.toLowerCase().contains('banquet') ||
            type.toLowerCase().contains('restaurant'),
      );
    }

    return hasCapacity && matchesEventType;
  }

  // Get recommendation reason for a venue
  String? getVenueRecommendationReason(Venue venue) {
    if (!isVenueRecommended(venue) || _wizardData == null) return null;

    final int guestCount = _wizardData!['guestCount'] as int;
    final String eventType = _wizardData!['eventType'] as String;

    final List<String> reasons = [];

    if (venue.minCapacity <= guestCount && venue.maxCapacity >= guestCount) {
      reasons.add('Can accommodate your $guestCount guests');
    }

    if (eventType.toLowerCase().contains('wedding') &&
        venue.venueTypes.any(
          (type) => type.toLowerCase().contains('wedding'),
        )) {
      reasons.add('Perfect for weddings');
    } else if (eventType.toLowerCase().contains('business') &&
        venue.venueTypes.any(
          (type) => type.toLowerCase().contains('conference'),
        )) {
      reasons.add('Ideal for business events');
    } else if (eventType.toLowerCase().contains('celebration') &&
        venue.venueTypes.any((type) => type.toLowerCase().contains('party'))) {
      reasons.add('Great for celebrations');
    }

    return reasons.isNotEmpty ? reasons.join(', ') : null;
  }

  // Check if a catering service is recommended
  bool isCateringServiceRecommended(CateringService service) {
    if (_wizardData == null) return false;

    final int guestCount = _wizardData!['guestCount'] as int;
    final String eventType = _wizardData!['eventType'] as String;
    final Map<String, bool> selectedServices = Map<String, bool>.from(
      _wizardData!['selectedServices'],
    );

    // Check if catering service was selected in the wizard
    if (!selectedServices.containsKey('Catering') ||
        !selectedServices['Catering']!) {
      return false;
    }

    // Check if service can accommodate the guest count
    final bool hasCapacity =
        service.minCapacity <= guestCount && service.maxCapacity >= guestCount;

    // Check if service is suitable for the event type
    bool matchesEventType = true;
    if (eventType.toLowerCase().contains('wedding')) {
      matchesEventType = service.cuisineTypes.any(
        (type) =>
            type.toLowerCase().contains('fine dining') ||
            type.toLowerCase().contains('international'),
      );
    } else if (eventType.toLowerCase().contains('business')) {
      matchesEventType = service.cuisineTypes.any(
        (type) =>
            type.toLowerCase().contains('international') ||
            type.toLowerCase().contains('mediterranean'),
      );
    }

    return hasCapacity && matchesEventType;
  }

  // Get recommendation reason for a catering service
  String? getCateringRecommendationReason(CateringService service) {
    if (!isCateringServiceRecommended(service) || _wizardData == null) {
      return null;
    }

    final int guestCount = _wizardData!['guestCount'] as int;
    final String eventType = _wizardData!['eventType'] as String;

    final List<String> reasons = [];

    if (service.minCapacity <= guestCount &&
        service.maxCapacity >= guestCount) {
      reasons.add('Can cater for your $guestCount guests');
    }

    if (eventType.toLowerCase().contains('wedding') &&
        service.cuisineTypes.any(
          (type) => type.toLowerCase().contains('fine dining'),
        )) {
      reasons.add('Elegant dining options for weddings');
    } else if (eventType.toLowerCase().contains('business') &&
        service.cuisineTypes.any(
          (type) => type.toLowerCase().contains('international'),
        )) {
      reasons.add('Professional catering for business events');
    }

    return reasons.isNotEmpty ? reasons.join(', ') : null;
  }

  // Check if a photographer is recommended
  bool isPhotographerRecommended(Photographer photographer) {
    if (_wizardData == null) return false;

    final String eventType = _wizardData!['eventType'] as String;
    final Map<String, bool> selectedServices = Map<String, bool>.from(
      _wizardData!['selectedServices'],
    );

    // Check if photography service was selected in the wizard
    bool photographySelected = false;
    if (selectedServices.containsKey('Photography/Videography') &&
        selectedServices['Photography/Videography']!) {
      photographySelected = true;
    } else if (selectedServices.containsKey('Photography') &&
        selectedServices['Photography']!) {
      photographySelected = true;
    }

    if (!photographySelected) {
      return false;
    }

    // Check if photographer is suitable for the event type
    bool matchesEventType = true;
    if (eventType.toLowerCase().contains('wedding')) {
      matchesEventType = photographer.styles.any(
        (style) =>
            style.toLowerCase().contains('wedding') ||
            style.toLowerCase().contains('contemporary') ||
            style.toLowerCase().contains('photojournalistic'),
      );
    } else if (eventType.toLowerCase().contains('business')) {
      matchesEventType = photographer.styles.any(
        (style) =>
            style.toLowerCase().contains('corporate') ||
            style.toLowerCase().contains('commercial'),
      );
    } else if (eventType.toLowerCase().contains('celebration')) {
      matchesEventType = photographer.styles.any(
        (style) =>
            style.toLowerCase().contains('event') ||
            style.toLowerCase().contains('portrait'),
      );
    }

    return matchesEventType;
  }

  // Get recommendation reason for a photographer
  String? getPhotographerRecommendationReason(Photographer photographer) {
    if (!isPhotographerRecommended(photographer) || _wizardData == null) {
      return null;
    }

    final String eventType = _wizardData!['eventType'] as String;

    final List<String> reasons = [];

    if (eventType.toLowerCase().contains('wedding') &&
        photographer.styles.any(
          (style) => style.toLowerCase().contains('wedding'),
        )) {
      reasons.add('Specializes in wedding photography');
    } else if (eventType.toLowerCase().contains('business') &&
        photographer.styles.any(
          (style) => style.toLowerCase().contains('corporate'),
        )) {
      reasons.add('Experienced in corporate event photography');
    } else if (eventType.toLowerCase().contains('celebration') &&
        photographer.styles.any(
          (style) => style.toLowerCase().contains('event'),
        )) {
      reasons.add('Perfect for capturing celebration moments');
    }

    return reasons.isNotEmpty ? reasons.join(', ') : null;
  }

  // Check if a planner is recommended
  bool isPlannerRecommended(Planner planner) {
    if (_wizardData == null) return false;

    final String eventType = _wizardData!['eventType'] as String;
    final Map<String, bool> selectedServices = Map<String, bool>.from(
      _wizardData!['selectedServices'],
    );

    // Check if planner service was selected in the wizard
    bool plannerSelected = false;
    if (selectedServices.containsKey('Event Staff') &&
        selectedServices['Event Staff']!) {
      plannerSelected = true;
    } else if (selectedServices.containsKey('Wedding Planner') &&
        selectedServices['Wedding Planner']!) {
      plannerSelected = true;
    }

    if (!plannerSelected) {
      return false;
    }

    // Check if planner is suitable for the event type
    bool matchesEventType = true;
    if (eventType.toLowerCase().contains('wedding')) {
      matchesEventType = planner.specialties.any(
        (specialty) => specialty.toLowerCase().contains('wedding'),
      );
    } else if (eventType.toLowerCase().contains('business')) {
      matchesEventType = planner.specialties.any(
        (specialty) =>
            specialty.toLowerCase().contains('corporate') ||
            specialty.toLowerCase().contains('business'),
      );
    } else if (eventType.toLowerCase().contains('celebration')) {
      matchesEventType = planner.specialties.any(
        (specialty) =>
            specialty.toLowerCase().contains('social') ||
            specialty.toLowerCase().contains('party'),
      );
    }

    return matchesEventType;
  }

  // Get recommendation reason for a planner
  String? getPlannerRecommendationReason(Planner planner) {
    if (!isPlannerRecommended(planner) || _wizardData == null) {
      return null;
    }

    final String eventType = _wizardData!['eventType'] as String;

    final List<String> reasons = [];

    if (eventType.toLowerCase().contains('wedding') &&
        planner.specialties.any(
          (specialty) => specialty.toLowerCase().contains('wedding'),
        )) {
      reasons.add('Specializes in wedding planning');
    } else if (eventType.toLowerCase().contains('business') &&
        planner.specialties.any(
          (specialty) => specialty.toLowerCase().contains('corporate'),
        )) {
      reasons.add('Experienced in corporate event planning');
    } else if (eventType.toLowerCase().contains('celebration') &&
        planner.specialties.any(
          (specialty) => specialty.toLowerCase().contains('social'),
        )) {
      reasons.add('Perfect for planning celebrations');
    }

    if (planner.yearsExperience > 10) {
      reasons.add('${planner.yearsExperience} years of experience');
    }

    return reasons.isNotEmpty ? reasons.join(', ') : null;
  }
}
