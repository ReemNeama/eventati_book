/// Enum representing venue layout preferences
enum VenueLayout {
  banquet,
  theater,
  classroom,
  reception,
  boardroom,
  uShape,
  custom,
}

/// Extension to add helper methods to VenueLayout
extension VenueLayoutExtension on VenueLayout {
  /// Get the display name of the venue layout
  String get displayName {
    switch (this) {
      case VenueLayout.banquet:
        return 'Banquet';
      case VenueLayout.theater:
        return 'Theater';
      case VenueLayout.classroom:
        return 'Classroom';
      case VenueLayout.reception:
        return 'Reception';
      case VenueLayout.boardroom:
        return 'Boardroom';
      case VenueLayout.uShape:
        return 'U-Shape';
      case VenueLayout.custom:
        return 'Custom';
    }
  }
}

/// Model representing venue-specific booking options
class VenueOptions {
  /// Setup time in minutes before the event
  final int setupTimeMinutes;

  /// Teardown time in minutes after the event
  final int teardownTimeMinutes;

  /// Preferred layout for the venue
  final VenueLayout layout;

  /// Custom layout description (if layout is custom)
  final String? customLayoutDescription;

  /// Equipment needs for the venue
  final List<String> equipmentNeeds;

  /// Constructor
  VenueOptions({
    required this.setupTimeMinutes,
    required this.teardownTimeMinutes,
    required this.layout,
    this.customLayoutDescription,
    required this.equipmentNeeds,
  });

  /// Create a copy of this venue options with modified fields
  VenueOptions copyWith({
    int? setupTimeMinutes,
    int? teardownTimeMinutes,
    VenueLayout? layout,
    String? customLayoutDescription,
    List<String>? equipmentNeeds,
  }) {
    return VenueOptions(
      setupTimeMinutes: setupTimeMinutes ?? this.setupTimeMinutes,
      teardownTimeMinutes: teardownTimeMinutes ?? this.teardownTimeMinutes,
      layout: layout ?? this.layout,
      customLayoutDescription:
          customLayoutDescription ?? this.customLayoutDescription,
      equipmentNeeds: equipmentNeeds ?? this.equipmentNeeds,
    );
  }

  /// Convert venue options to JSON
  Map<String, dynamic> toJson() {
    return {
      'setupTimeMinutes': setupTimeMinutes,
      'teardownTimeMinutes': teardownTimeMinutes,
      'layout': layout.index,
      'customLayoutDescription': customLayoutDescription,
      'equipmentNeeds': equipmentNeeds,
    };
  }

  /// Create venue options from JSON
  factory VenueOptions.fromJson(Map<String, dynamic> json) {
    return VenueOptions(
      setupTimeMinutes: json['setupTimeMinutes'],
      teardownTimeMinutes: json['teardownTimeMinutes'],
      layout: VenueLayout.values[json['layout']],
      customLayoutDescription: json['customLayoutDescription'],
      equipmentNeeds: List<String>.from(json['equipmentNeeds']),
    );
  }

  /// Default venue options
  factory VenueOptions.defaultOptions() {
    return VenueOptions(
      setupTimeMinutes: 60,
      teardownTimeMinutes: 60,
      layout: VenueLayout.banquet,
      equipmentNeeds: [],
    );
  }
}
