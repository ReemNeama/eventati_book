/// Enum representing the type of pricing for a service
enum PriceType {
  /// Price per event (flat fee)
  perEvent,

  /// Price per person (per guest)
  perPerson,

  /// Price per hour (hourly rate)
  perHour,
}

/// Extension on PriceType to add helper methods
extension PriceTypeExtension on PriceType {
  /// Get the display text for the price type
  String get displayText {
    switch (this) {
      case PriceType.perEvent:
        return 'per event';
      case PriceType.perPerson:
        return 'per person';
      case PriceType.perHour:
        return 'per hour';
    }
  }
}
