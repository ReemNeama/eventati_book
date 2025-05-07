import 'package:eventati_book/models/models.dart';

/// Enhanced budget calculator with more accurate cost estimation
class EnhancedBudgetCalculator {
  /// Calculate estimated cost based on multiple factors
  static double calculateEstimatedCost({
    required String serviceType,
    required int guestCount,
    required String eventType,
    required int eventDuration,
    String location = 'Unknown',
    DateTime? eventDate,
    bool isPremiumVenue = false,
    bool isWeekend = false,
  }) {
    // Base calculation from the original algorithm
    final baseEstimate = _calculateBaseEstimate(
      serviceType: serviceType,
      guestCount: guestCount,
      eventType: eventType,
      eventDuration: eventDuration,
    );

    // Apply location adjustment
    final locationFactor = _getLocationFactor(location);

    // Apply seasonal adjustment
    final seasonalFactor = _getSeasonalFactor(eventDate);

    // Apply weekend adjustment
    final weekendFactor = isWeekend ? 1.2 : 1.0;

    // Apply premium venue adjustment
    final premiumFactor = isPremiumVenue ? 1.15 : 1.0;

    // Calculate final estimate
    return baseEstimate *
        locationFactor *
        seasonalFactor *
        weekendFactor *
        premiumFactor;
  }

  /// Calculate the base estimate using the original algorithm
  static double _calculateBaseEstimate({
    required String serviceType,
    required int guestCount,
    required String eventType,
    required int eventDuration,
  }) {
    switch (serviceType) {
      case 'Venue':
        // Base cost + per guest + event type factor + duration factor
        const double baseCost = 1000.0;
        const double perGuestCost = 10.0;
        final double eventTypeFactor =
            eventType.toLowerCase().contains('wedding')
                ? 1.5
                : eventType.toLowerCase().contains('business')
                ? 1.2
                : 1.0;
        final double durationFactor =
            eventDuration > 1 ? 0.8 * eventDuration : 1.0;

        return (baseCost + (perGuestCost * guestCount)) *
            eventTypeFactor *
            durationFactor;

      case 'Catering':
        // Per guest cost * event type factor
        const double perGuestCost = 65.0;
        final double eventTypeFactor =
            eventType.toLowerCase().contains('wedding')
                ? 1.3
                : eventType.toLowerCase().contains('business')
                ? 1.1
                : 1.0;

        return perGuestCost * guestCount * eventTypeFactor;

      case 'Photography':
        // Base cost * event type factor * duration factor
        const double baseCost = 2000.0;
        final double eventTypeFactor =
            eventType.toLowerCase().contains('wedding')
                ? 1.5
                : eventType.toLowerCase().contains('business')
                ? 1.2
                : 1.0;
        final double durationFactor =
            eventDuration > 1 ? 0.9 * eventDuration : 1.0;

        return baseCost * eventTypeFactor * durationFactor;

      case 'Videography':
        // Base cost * event type factor * duration factor
        const double baseCost = 2500.0;
        final double eventTypeFactor =
            eventType.toLowerCase().contains('wedding')
                ? 1.6
                : eventType.toLowerCase().contains('business')
                ? 1.3
                : 1.0;
        final double durationFactor =
            eventDuration > 1 ? 0.9 * eventDuration : 1.0;

        return baseCost * eventTypeFactor * durationFactor;

      case 'Entertainment':
        // Base cost * event type factor * duration factor
        const double baseCost = 1200.0;
        final double eventTypeFactor =
            eventType.toLowerCase().contains('wedding')
                ? 1.4
                : eventType.toLowerCase().contains('business')
                ? 1.0
                : 1.2;
        final double durationFactor =
            eventDuration > 1 ? 0.8 * eventDuration : 1.0;

        return baseCost * eventTypeFactor * durationFactor;

      case 'Decor':
        // Base cost + per guest
        const double baseCost = 500.0;
        const double perGuestCost = 5.0;
        final double eventTypeFactor =
            eventType.toLowerCase().contains('wedding')
                ? 1.5
                : eventType.toLowerCase().contains('business')
                ? 0.8
                : 1.2;

        return (baseCost + (perGuestCost * guestCount)) * eventTypeFactor;

      case 'Transportation':
        // Base cost + per guest
        const double baseCost = 300.0;
        const double perGuestCost = 15.0;

        // For transportation, we calculate based on a percentage of guests
        // assuming not all guests will need transportation
        final int transportedGuests = (guestCount * 0.6).round();

        return baseCost + (perGuestCost * transportedGuests);

      default:
        return 0.0;
    }
  }

  /// Get location adjustment factor based on city/region
  static double _getLocationFactor(String location) {
    // Normalize location to lowercase for comparison
    final normalizedLocation = location.toLowerCase();

    // High-cost locations
    if (normalizedLocation.contains('new york') ||
        normalizedLocation.contains('san francisco') ||
        normalizedLocation.contains('los angeles') ||
        normalizedLocation.contains('chicago') ||
        normalizedLocation.contains('boston')) {
      return 1.5;
    }

    // Medium-high cost locations
    if (normalizedLocation.contains('seattle') ||
        normalizedLocation.contains('miami') ||
        normalizedLocation.contains('washington') ||
        normalizedLocation.contains('philadelphia') ||
        normalizedLocation.contains('san diego')) {
      return 1.3;
    }

    // Medium cost locations
    if (normalizedLocation.contains('denver') ||
        normalizedLocation.contains('austin') ||
        normalizedLocation.contains('portland') ||
        normalizedLocation.contains('nashville') ||
        normalizedLocation.contains('atlanta')) {
      return 1.15;
    }

    // Default for unknown or lower-cost locations
    return 1.0;
  }

  /// Get seasonal adjustment factor based on event date
  static double _getSeasonalFactor(DateTime? eventDate) {
    if (eventDate == null) {
      return 1.0;
    }

    final month = eventDate.month;

    // Peak wedding season (May-October)
    if (month >= 5 && month <= 10) {
      return 1.25;
    }

    // Holiday season (December)
    if (month == 12) {
      return 1.2;
    }

    // January is typically lower demand
    if (month == 1) {
      return 0.9;
    }

    // Default for other months
    return 1.0;
  }

  /// Check if the event date falls on a weekend
  static bool isWeekendEvent(DateTime? eventDate) {
    if (eventDate == null) {
      return false;
    }

    // 6 = Saturday, 7 = Sunday
    final weekday = eventDate.weekday;
    return weekday == 6 || weekday == 7;
  }

  /// Create a detailed budget breakdown with itemized costs
  static List<BudgetItem> createDetailedBudget({
    required String serviceType,
    required int guestCount,
    required String eventType,
    required int eventDuration,
    String location = 'Unknown',
    DateTime? eventDate,
    bool isPremiumVenue = false,
  }) {
    final List<BudgetItem> items = [];
    final isWeekend = isWeekendEvent(eventDate);

    switch (serviceType) {
      case 'Venue':
        // Calculate main venue cost
        final venueCost = calculateEstimatedCost(
          serviceType: serviceType,
          guestCount: guestCount,
          eventType: eventType,
          eventDuration: eventDuration,
          location: location,
          eventDate: eventDate,
          isPremiumVenue: isPremiumVenue,
          isWeekend: isWeekend,
        );

        items.add(
          BudgetItem(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            categoryId: '1', // Venue category
            description: 'Venue rental',
            estimatedCost: venueCost,
            isPaid: false,
            notes:
                'Based on $guestCount guests, $eventDuration day(s), in $location',
          ),
        );

        // Add setup costs if applicable
        if (eventType.toLowerCase().contains('business') ||
            eventType.toLowerCase().contains('wedding')) {
          items.add(
            BudgetItem(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              categoryId: '1', // Venue category
              description: 'Venue setup',
              estimatedCost: venueCost * 0.1, // 10% of venue cost
              isPaid: false,
              notes: 'Setup costs',
            ),
          );
        }

        // Add cleanup costs
        items.add(
          BudgetItem(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            categoryId: '1', // Venue category
            description: 'Venue cleanup',
            estimatedCost: venueCost * 0.08, // 8% of venue cost
            isPaid: false,
            notes: 'Cleanup costs',
          ),
        );

        break;

      // Add other service types as needed

      default:
        break;
    }

    return items;
  }
}
