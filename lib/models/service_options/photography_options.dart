/// Enum representing photography session types
enum PhotoSessionType {
  portrait,
  group,
  candid,
  documentary,
  artistic,
  aerial,
  custom,
}

/// Extension to add helper methods to PhotoSessionType
extension PhotoSessionTypeExtension on PhotoSessionType {
  /// Get the display name of the photo session type
  String get displayName {
    switch (this) {
      case PhotoSessionType.portrait:
        return 'Portrait';
      case PhotoSessionType.group:
        return 'Group';
      case PhotoSessionType.candid:
        return 'Candid';
      case PhotoSessionType.documentary:
        return 'Documentary';
      case PhotoSessionType.artistic:
        return 'Artistic';
      case PhotoSessionType.aerial:
        return 'Aerial/Drone';
      case PhotoSessionType.custom:
        return 'Custom';
    }
  }
}

/// Enum representing photography location preferences
enum PhotoLocationPreference {
  indoor,
  outdoor,
  both,
  studio,
  specificLocation,
  custom,
}

/// Extension to add helper methods to PhotoLocationPreference
extension PhotoLocationPreferenceExtension on PhotoLocationPreference {
  /// Get the display name of the photo location preference
  String get displayName {
    switch (this) {
      case PhotoLocationPreference.indoor:
        return 'Indoor Only';
      case PhotoLocationPreference.outdoor:
        return 'Outdoor Only';
      case PhotoLocationPreference.both:
        return 'Both Indoor and Outdoor';
      case PhotoLocationPreference.studio:
        return 'Studio';
      case PhotoLocationPreference.specificLocation:
        return 'Specific Location';
      case PhotoLocationPreference.custom:
        return 'Custom';
    }
  }
}

/// Model representing photography-specific booking options
class PhotographyOptions {
  /// List of requested photo session types
  final List<PhotoSessionType> sessionTypes;

  /// Custom session type description (if a custom type is included)
  final String? customSessionTypeDescription;

  /// Location preference for the photo session
  final PhotoLocationPreference locationPreference;

  /// Specific location description (if locationPreference is specificLocation or custom)
  final String? specificLocationDescription;

  /// List of requested equipment
  final List<String> equipmentRequests;

  /// Whether to include a second photographer
  final bool includeSecondPhotographer;

  /// Whether to include videography
  final bool includeVideography;

  /// Constructor
  PhotographyOptions({
    required this.sessionTypes,
    this.customSessionTypeDescription,
    required this.locationPreference,
    this.specificLocationDescription,
    required this.equipmentRequests,
    required this.includeSecondPhotographer,
    required this.includeVideography,
  });

  /// Create a copy of this photography options with modified fields
  PhotographyOptions copyWith({
    List<PhotoSessionType>? sessionTypes,
    String? customSessionTypeDescription,
    PhotoLocationPreference? locationPreference,
    String? specificLocationDescription,
    List<String>? equipmentRequests,
    bool? includeSecondPhotographer,
    bool? includeVideography,
  }) {
    return PhotographyOptions(
      sessionTypes: sessionTypes ?? this.sessionTypes,
      customSessionTypeDescription:
          customSessionTypeDescription ?? this.customSessionTypeDescription,
      locationPreference: locationPreference ?? this.locationPreference,
      specificLocationDescription:
          specificLocationDescription ?? this.specificLocationDescription,
      equipmentRequests: equipmentRequests ?? this.equipmentRequests,
      includeSecondPhotographer:
          includeSecondPhotographer ?? this.includeSecondPhotographer,
      includeVideography: includeVideography ?? this.includeVideography,
    );
  }

  /// Convert photography options to JSON
  Map<String, dynamic> toJson() {
    return {
      'sessionTypes': sessionTypes.map((type) => type.index).toList(),
      'customSessionTypeDescription': customSessionTypeDescription,
      'locationPreference': locationPreference.index,
      'specificLocationDescription': specificLocationDescription,
      'equipmentRequests': equipmentRequests,
      'includeSecondPhotographer': includeSecondPhotographer,
      'includeVideography': includeVideography,
    };
  }

  /// Create photography options from JSON
  factory PhotographyOptions.fromJson(Map<String, dynamic> json) {
    return PhotographyOptions(
      sessionTypes:
          (json['sessionTypes'] as List)
              .map((index) => PhotoSessionType.values[index])
              .toList(),
      customSessionTypeDescription: json['customSessionTypeDescription'],
      locationPreference:
          PhotoLocationPreference.values[json['locationPreference']],
      specificLocationDescription: json['specificLocationDescription'],
      equipmentRequests: List<String>.from(json['equipmentRequests']),
      includeSecondPhotographer: json['includeSecondPhotographer'],
      includeVideography: json['includeVideography'],
    );
  }

  /// Default photography options
  factory PhotographyOptions.defaultOptions() {
    return PhotographyOptions(
      sessionTypes: [PhotoSessionType.portrait, PhotoSessionType.candid],
      locationPreference: PhotoLocationPreference.both,
      equipmentRequests: [],
      includeSecondPhotographer: false,
      includeVideography: false,
    );
  }
}
