/// Enum representing planner consultation preferences
enum ConsultationPreference { inPerson, virtual, phone, email, mixed, custom }

/// Extension to add helper methods to ConsultationPreference
extension ConsultationPreferenceExtension on ConsultationPreference {
  /// Get the display name of the consultation preference
  String get displayName {
    switch (this) {
      case ConsultationPreference.inPerson:
        return 'In-Person';
      case ConsultationPreference.virtual:
        return 'Virtual (Video Call)';
      case ConsultationPreference.phone:
        return 'Phone Call';
      case ConsultationPreference.email:
        return 'Email';
      case ConsultationPreference.mixed:
        return 'Mixed (Combination)';
      case ConsultationPreference.custom:
        return 'Custom';
    }
  }
}

/// Enum representing planning package types
enum PlanningPackageType {
  fullPlanning,
  partialPlanning,
  monthOf,
  dayOf,
  consultationOnly,
  custom,
}

/// Extension to add helper methods to PlanningPackageType
extension PlanningPackageTypeExtension on PlanningPackageType {
  /// Get the display name of the planning package type
  String get displayName {
    switch (this) {
      case PlanningPackageType.fullPlanning:
        return 'Full Planning';
      case PlanningPackageType.partialPlanning:
        return 'Partial Planning';
      case PlanningPackageType.monthOf:
        return 'Month-Of Coordination';
      case PlanningPackageType.dayOf:
        return 'Day-Of Coordination';
      case PlanningPackageType.consultationOnly:
        return 'Consultation Only';
      case PlanningPackageType.custom:
        return 'Custom';
    }
  }
}

/// Model representing planner-specific booking options
class PlannerOptions {
  /// Preferred consultation method
  final ConsultationPreference consultationPreference;

  /// Custom consultation preference description (if preference is custom)
  final String? customConsultationDescription;

  /// Planning package type
  final PlanningPackageType packageType;

  /// Custom package type description (if packageType is custom)
  final String? customPackageDescription;

  /// List of specific planning needs
  final List<String> specificPlanningNeeds;

  /// Whether to include vendor coordination
  final bool includeVendorCoordination;

  /// Whether to include budget management
  final bool includeBudgetManagement;

  /// Constructor
  PlannerOptions({
    required this.consultationPreference,
    this.customConsultationDescription,
    required this.packageType,
    this.customPackageDescription,
    required this.specificPlanningNeeds,
    required this.includeVendorCoordination,
    required this.includeBudgetManagement,
  });

  /// Create a copy of this planner options with modified fields
  PlannerOptions copyWith({
    ConsultationPreference? consultationPreference,
    String? customConsultationDescription,
    PlanningPackageType? packageType,
    String? customPackageDescription,
    List<String>? specificPlanningNeeds,
    bool? includeVendorCoordination,
    bool? includeBudgetManagement,
  }) {
    return PlannerOptions(
      consultationPreference:
          consultationPreference ?? this.consultationPreference,
      customConsultationDescription:
          customConsultationDescription ?? this.customConsultationDescription,
      packageType: packageType ?? this.packageType,
      customPackageDescription:
          customPackageDescription ?? this.customPackageDescription,
      specificPlanningNeeds:
          specificPlanningNeeds ?? this.specificPlanningNeeds,
      includeVendorCoordination:
          includeVendorCoordination ?? this.includeVendorCoordination,
      includeBudgetManagement:
          includeBudgetManagement ?? this.includeBudgetManagement,
    );
  }

  /// Convert planner options to JSON
  Map<String, dynamic> toJson() {
    return {
      'consultationPreference': consultationPreference.index,
      'customConsultationDescription': customConsultationDescription,
      'packageType': packageType.index,
      'customPackageDescription': customPackageDescription,
      'specificPlanningNeeds': specificPlanningNeeds,
      'includeVendorCoordination': includeVendorCoordination,
      'includeBudgetManagement': includeBudgetManagement,
    };
  }

  /// Create planner options from JSON
  factory PlannerOptions.fromJson(Map<String, dynamic> json) {
    return PlannerOptions(
      consultationPreference:
          ConsultationPreference.values[json['consultationPreference']],
      customConsultationDescription: json['customConsultationDescription'],
      packageType: PlanningPackageType.values[json['packageType']],
      customPackageDescription: json['customPackageDescription'],
      specificPlanningNeeds: List<String>.from(json['specificPlanningNeeds']),
      includeVendorCoordination: json['includeVendorCoordination'],
      includeBudgetManagement: json['includeBudgetManagement'],
    );
  }

  /// Default planner options
  factory PlannerOptions.defaultOptions() {
    return PlannerOptions(
      consultationPreference: ConsultationPreference.mixed,
      packageType: PlanningPackageType.fullPlanning,
      specificPlanningNeeds: [],
      includeVendorCoordination: true,
      includeBudgetManagement: true,
    );
  }
}
