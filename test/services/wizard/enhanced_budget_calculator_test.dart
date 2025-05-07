import 'package:flutter_test/flutter_test.dart';
import 'package:eventati_book/services/wizard/enhanced_budget_calculator.dart';

void main() {
  group('EnhancedBudgetCalculator', () {
    test('calculateEstimatedCost returns correct base costs', () {
      // Test venue cost calculation
      final venueCost = EnhancedBudgetCalculator.calculateEstimatedCost(
        serviceType: 'Venue',
        guestCount: 100,
        eventType: 'Celebration',
        eventDuration: 1,
      );

      // Test catering cost calculation
      final cateringCost = EnhancedBudgetCalculator.calculateEstimatedCost(
        serviceType: 'Catering',
        guestCount: 100,
        eventType: 'Celebration',
        eventDuration: 1,
      );

      // Test photography cost calculation
      final photographyCost = EnhancedBudgetCalculator.calculateEstimatedCost(
        serviceType: 'Photography',
        guestCount: 100,
        eventType: 'Celebration',
        eventDuration: 1,
      );

      // Verify costs are reasonable and non-zero
      expect(venueCost, greaterThan(0));
      expect(cateringCost, greaterThan(0));
      expect(photographyCost, greaterThan(0));
    });

    test('calculateEstimatedCost applies location adjustments', () {
      // Test venue cost in expensive location
      final expensiveLocationCost =
          EnhancedBudgetCalculator.calculateEstimatedCost(
            serviceType: 'Venue',
            guestCount: 100,
            eventType: 'Celebration',
            eventDuration: 1,
            location: 'New York',
          );

      // Test venue cost in standard location
      final standardLocationCost =
          EnhancedBudgetCalculator.calculateEstimatedCost(
            serviceType: 'Venue',
            guestCount: 100,
            eventType: 'Celebration',
            eventDuration: 1,
            location: 'Unknown',
          );

      // Verify expensive location costs more
      expect(expensiveLocationCost, greaterThan(standardLocationCost));
    });

    test('calculateEstimatedCost applies seasonal adjustments', () {
      // Test venue cost in peak season (June)
      final peakSeasonCost = EnhancedBudgetCalculator.calculateEstimatedCost(
        serviceType: 'Venue',
        guestCount: 100,
        eventType: 'Celebration',
        eventDuration: 1,
        eventDate: DateTime(2023, 6, 15), // June 15, 2023
      );

      // Test venue cost in off-season (January)
      final offSeasonCost = EnhancedBudgetCalculator.calculateEstimatedCost(
        serviceType: 'Venue',
        guestCount: 100,
        eventType: 'Celebration',
        eventDuration: 1,
        eventDate: DateTime(2023, 1, 15), // January 15, 2023
      );

      // Verify peak season costs more
      expect(peakSeasonCost, greaterThan(offSeasonCost));
    });

    test('calculateEstimatedCost applies weekend adjustments', () {
      // Test venue cost on weekend
      final weekendCost = EnhancedBudgetCalculator.calculateEstimatedCost(
        serviceType: 'Venue',
        guestCount: 100,
        eventType: 'Celebration',
        eventDuration: 1,
        isWeekend: true,
      );

      // Test venue cost on weekday
      final weekdayCost = EnhancedBudgetCalculator.calculateEstimatedCost(
        serviceType: 'Venue',
        guestCount: 100,
        eventType: 'Celebration',
        eventDuration: 1,
        isWeekend: false,
      );

      // Verify weekend costs more
      expect(weekendCost, greaterThan(weekdayCost));
    });

    test('calculateEstimatedCost applies premium venue adjustments', () {
      // Test premium venue cost
      final premiumVenueCost = EnhancedBudgetCalculator.calculateEstimatedCost(
        serviceType: 'Venue',
        guestCount: 100,
        eventType: 'Celebration',
        eventDuration: 1,
        isPremiumVenue: true,
      );

      // Test standard venue cost
      final standardVenueCost = EnhancedBudgetCalculator.calculateEstimatedCost(
        serviceType: 'Venue',
        guestCount: 100,
        eventType: 'Celebration',
        eventDuration: 1,
        isPremiumVenue: false,
      );

      // Verify premium venue costs more
      expect(premiumVenueCost, greaterThan(standardVenueCost));
    });

    test('calculateEstimatedCost applies event type adjustments', () {
      // Test wedding venue cost
      final weddingCost = EnhancedBudgetCalculator.calculateEstimatedCost(
        serviceType: 'Venue',
        guestCount: 100,
        eventType: 'Wedding',
        eventDuration: 1,
      );

      // Test business event venue cost
      final businessCost = EnhancedBudgetCalculator.calculateEstimatedCost(
        serviceType: 'Venue',
        guestCount: 100,
        eventType: 'Business Event',
        eventDuration: 1,
      );

      // Test celebration venue cost
      final celebrationCost = EnhancedBudgetCalculator.calculateEstimatedCost(
        serviceType: 'Venue',
        guestCount: 100,
        eventType: 'Celebration',
        eventDuration: 1,
      );

      // Verify wedding costs more than celebration
      expect(weddingCost, greaterThan(celebrationCost));

      // Verify business costs more than celebration
      expect(businessCost, greaterThan(celebrationCost));
    });

    test('isWeekendEvent correctly identifies weekends', () {
      // Test Saturday
      final saturday = DateTime(2023, 7, 1); // July 1, 2023 is a Saturday
      expect(EnhancedBudgetCalculator.isWeekendEvent(saturday), isTrue);

      // Test Sunday
      final sunday = DateTime(2023, 7, 2); // July 2, 2023 is a Sunday
      expect(EnhancedBudgetCalculator.isWeekendEvent(sunday), isTrue);

      // Test Monday
      final monday = DateTime(2023, 7, 3); // July 3, 2023 is a Monday
      expect(EnhancedBudgetCalculator.isWeekendEvent(monday), isFalse);

      // Test null date
      expect(EnhancedBudgetCalculator.isWeekendEvent(null), isFalse);
    });

    test('createDetailedBudget creates appropriate budget items', () {
      // Create detailed budget for venue
      final budgetItems = EnhancedBudgetCalculator.createDetailedBudget(
        serviceType: 'Venue',
        guestCount: 100,
        eventType: 'Wedding',
        eventDuration: 1,
        location: 'Chicago',
        eventDate: DateTime(2023, 6, 15),
        isPremiumVenue: true,
      );

      // Verify budget items were created
      expect(budgetItems.length, greaterThan(0));

      // Verify venue rental item exists
      final venueRentalItem = budgetItems.firstWhere(
        (item) => item.description == 'Venue rental',
        orElse: () => throw Exception('Venue rental item not found'),
      );

      // Verify venue setup item exists for wedding
      final venueSetupItem = budgetItems.firstWhere(
        (item) => item.description == 'Venue setup',
        orElse: () => throw Exception('Venue setup item not found'),
      );

      // Verify costs are reasonable
      expect(venueRentalItem.estimatedCost, greaterThan(0));
      expect(venueSetupItem.estimatedCost, greaterThan(0));
    });
  });
}
