/// Enum representing meal service styles
enum MealServiceStyle {
  buffet,
  plated,
  familyStyle,
  stationBased,
  cocktailStyle,
  custom,
}

/// Extension to add helper methods to MealServiceStyle
extension MealServiceStyleExtension on MealServiceStyle {
  /// Get the display name of the meal service style
  String get displayName {
    switch (this) {
      case MealServiceStyle.buffet:
        return 'Buffet';
      case MealServiceStyle.plated:
        return 'Plated';
      case MealServiceStyle.familyStyle:
        return 'Family Style';
      case MealServiceStyle.stationBased:
        return 'Station-Based';
      case MealServiceStyle.cocktailStyle:
        return 'Cocktail Style';
      case MealServiceStyle.custom:
        return 'Custom';
    }
  }
}

/// Enum representing beverage service options
enum BeverageOption {
  nonAlcoholic,
  beer,
  wine,
  fullBar,
  openBar,
  cashBar,
  byob,
  custom,
}

/// Extension to add helper methods to BeverageOption
extension BeverageOptionExtension on BeverageOption {
  /// Get the display name of the beverage option
  String get displayName {
    switch (this) {
      case BeverageOption.nonAlcoholic:
        return 'Non-Alcoholic Only';
      case BeverageOption.beer:
        return 'Beer Only';
      case BeverageOption.wine:
        return 'Wine Only';
      case BeverageOption.fullBar:
        return 'Full Bar';
      case BeverageOption.openBar:
        return 'Open Bar';
      case BeverageOption.cashBar:
        return 'Cash Bar';
      case BeverageOption.byob:
        return 'BYOB';
      case BeverageOption.custom:
        return 'Custom';
    }
  }
}

/// Model representing catering-specific booking options
class CateringOptions {
  /// Preferred meal service style
  final MealServiceStyle mealServiceStyle;

  /// Custom meal service description (if style is custom)
  final String? customMealServiceDescription;

  /// List of dietary restrictions to accommodate
  final List<String> dietaryRestrictions;

  /// Beverage service option
  final BeverageOption beverageOption;

  /// Custom beverage service description (if option is custom)
  final String? customBeverageDescription;

  /// Whether to include staff service
  final bool includeStaffService;

  /// Number of staff members requested (if includeStaffService is true)
  final int? staffCount;

  /// Constructor
  CateringOptions({
    required this.mealServiceStyle,
    this.customMealServiceDescription,
    required this.dietaryRestrictions,
    required this.beverageOption,
    this.customBeverageDescription,
    required this.includeStaffService,
    this.staffCount,
  });

  /// Create a copy of this catering options with modified fields
  CateringOptions copyWith({
    MealServiceStyle? mealServiceStyle,
    String? customMealServiceDescription,
    List<String>? dietaryRestrictions,
    BeverageOption? beverageOption,
    String? customBeverageDescription,
    bool? includeStaffService,
    int? staffCount,
  }) {
    return CateringOptions(
      mealServiceStyle: mealServiceStyle ?? this.mealServiceStyle,
      customMealServiceDescription:
          customMealServiceDescription ?? this.customMealServiceDescription,
      dietaryRestrictions: dietaryRestrictions ?? this.dietaryRestrictions,
      beverageOption: beverageOption ?? this.beverageOption,
      customBeverageDescription:
          customBeverageDescription ?? this.customBeverageDescription,
      includeStaffService: includeStaffService ?? this.includeStaffService,
      staffCount: staffCount ?? this.staffCount,
    );
  }

  /// Convert catering options to JSON
  Map<String, dynamic> toJson() {
    return {
      'mealServiceStyle': mealServiceStyle.index,
      'customMealServiceDescription': customMealServiceDescription,
      'dietaryRestrictions': dietaryRestrictions,
      'beverageOption': beverageOption.index,
      'customBeverageDescription': customBeverageDescription,
      'includeStaffService': includeStaffService,
      'staffCount': staffCount,
    };
  }

  /// Create catering options from JSON
  factory CateringOptions.fromJson(Map<String, dynamic> json) {
    return CateringOptions(
      mealServiceStyle: MealServiceStyle.values[json['mealServiceStyle']],
      customMealServiceDescription: json['customMealServiceDescription'],
      dietaryRestrictions: List<String>.from(json['dietaryRestrictions']),
      beverageOption: BeverageOption.values[json['beverageOption']],
      customBeverageDescription: json['customBeverageDescription'],
      includeStaffService: json['includeStaffService'],
      staffCount: json['staffCount'],
    );
  }

  /// Default catering options
  factory CateringOptions.defaultOptions() {
    return CateringOptions(
      mealServiceStyle: MealServiceStyle.buffet,
      dietaryRestrictions: [],
      beverageOption: BeverageOption.nonAlcoholic,
      includeStaffService: true,
      staffCount: 2,
    );
  }
}
