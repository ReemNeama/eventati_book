import 'package:eventati_book/models/models.dart';
import 'package:eventati_book/services/wizard/enhanced_budget_calculator.dart';

/// Enhanced builder class for creating budget items from wizard data with historical analysis
class BudgetItemsBuilderEnhanced {
  /// Create budget items based on selected services with historical data analysis
  static Future<List<BudgetItem>> createBudgetItemsFromServices({
    required Map<String, bool> selectedServices,
    required int guestCount,
    required String eventType,
    required int eventDuration,
    required bool needsSetup,
    required int setupHours,
    required bool needsTeardown,
    required int teardownHours,
    String location = 'Unknown',
    DateTime? eventDate,
    bool isPremiumVenue = false,
  }) async {
    final List<BudgetItem> budgetItems = [];

    // Add venue budget items if selected
    if (selectedServices['Venue'] == true) {
      final venueItems = await _createVenueBudgetItems(
        guestCount: guestCount,
        eventType: eventType,
        eventDuration: eventDuration,
        needsSetup: needsSetup,
        setupHours: setupHours,
        needsTeardown: needsTeardown,
        teardownHours: teardownHours,
        location: location,
        eventDate: eventDate,
        isPremiumVenue: isPremiumVenue,
      );
      budgetItems.addAll(venueItems);
    }

    // Add catering budget items if selected
    if (selectedServices['Catering'] == true) {
      final cateringItems = await _createCateringBudgetItems(
        guestCount: guestCount,
        eventType: eventType,
        eventDuration: eventDuration,
        location: location,
        eventDate: eventDate,
      );
      budgetItems.addAll(cateringItems);
    }

    // Add photography budget items if selected
    if (selectedServices['Photography'] == true ||
        selectedServices['Photography/Videography'] == true) {
      final photographyItems = await _createPhotographyBudgetItems(
        eventDuration: eventDuration,
        eventType: eventType,
        guestCount: guestCount,
        location: location,
        eventDate: eventDate,
      );
      budgetItems.addAll(photographyItems);
    }

    // Add videography budget items if selected
    if (selectedServices['Videography'] == true ||
        selectedServices['Photography/Videography'] == true) {
      final videographyItems = await _createVideographyBudgetItems(
        eventDuration: eventDuration,
        eventType: eventType,
        guestCount: guestCount,
        location: location,
        eventDate: eventDate,
      );
      budgetItems.addAll(videographyItems);
    }

    return budgetItems;
  }

  /// Create venue budget items with historical data analysis
  static Future<List<BudgetItem>> _createVenueBudgetItems({
    required int guestCount,
    required String eventType,
    required int eventDuration,
    required bool needsSetup,
    required int setupHours,
    required bool needsTeardown,
    required int teardownHours,
    String location = 'Unknown',
    DateTime? eventDate,
    bool isPremiumVenue = false,
  }) async {
    // Get venue budget items with historical data
    final items =
        await EnhancedBudgetCalculator.createDetailedBudgetWithHistoricalData(
          serviceType: 'Venue',
          guestCount: guestCount,
          eventType: eventType,
          eventDuration: eventDuration,
          location: location,
          eventDate: eventDate,
          isPremiumVenue: isPremiumVenue,
        );

    // Add setup costs if needed
    if (needsSetup) {
      // Get the venue cost from the first item
      final venueCost = items.isNotEmpty ? items[0].estimatedCost : 0.0;

      // Setup cost is calculated as a percentage of venue cost
      final setupCost =
          setupHours * (venueCost * 0.05); // 5% of venue cost per hour

      items.add(
        BudgetItem(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          categoryId: '1', // Venue category
          description: 'Venue setup',
          estimatedCost: setupCost,
          isPaid: false,
          notes: 'Setup costs for $setupHours hour(s)',
        ),
      );
    }

    // Add teardown costs if needed
    if (needsTeardown) {
      // Get the venue cost from the first item
      final venueCost = items.isNotEmpty ? items[0].estimatedCost : 0.0;

      // Teardown cost is calculated as a percentage of venue cost
      final teardownCost =
          teardownHours * (venueCost * 0.04); // 4% of venue cost per hour

      items.add(
        BudgetItem(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          categoryId: '1', // Venue category
          description: 'Venue teardown',
          estimatedCost: teardownCost,
          isPaid: false,
          notes: 'Teardown costs for $teardownHours hour(s)',
        ),
      );
    }

    return items;
  }

  /// Create catering budget items with historical data analysis
  static Future<List<BudgetItem>> _createCateringBudgetItems({
    required int guestCount,
    required String eventType,
    required int eventDuration,
    String location = 'Unknown',
    DateTime? eventDate,
  }) async {
    // Get catering budget items with historical data
    final items =
        await EnhancedBudgetCalculator.createDetailedBudgetWithHistoricalData(
          serviceType: 'Catering',
          guestCount: guestCount,
          eventType: eventType,
          eventDuration: eventDuration,
          location: location,
          eventDate: eventDate,
        );

    // Add staff costs for larger events
    if (guestCount > 50) {
      // Calculate number of staff needed (1 per 25 guests)
      final staffCount = (guestCount / 25).ceil();
      final staffCost =
          staffCount * 150.0 * eventDuration; // $150 per staff per day

      items.add(
        BudgetItem(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          categoryId: '2', // Catering category
          description: 'Catering staff',
          estimatedCost: staffCost,
          isPaid: false,
          notes: 'Staff costs for $staffCount servers',
        ),
      );
    }

    return items;
  }

  /// Create photography budget items with historical data analysis
  static Future<List<BudgetItem>> _createPhotographyBudgetItems({
    required int eventDuration,
    required String eventType,
    required int guestCount,
    String location = 'Unknown',
    DateTime? eventDate,
  }) async {
    // Get photography budget items with historical data
    final items =
        await EnhancedBudgetCalculator.createDetailedBudgetWithHistoricalData(
          serviceType: 'Photography',
          guestCount: guestCount,
          eventType: eventType,
          eventDuration: eventDuration,
          location: location,
          eventDate: eventDate,
        );

    return items;
  }

  /// Create videography budget items with historical data analysis
  static Future<List<BudgetItem>> _createVideographyBudgetItems({
    required int eventDuration,
    required String eventType,
    required int guestCount,
    String location = 'Unknown',
    DateTime? eventDate,
  }) async {
    // Get videography budget items with historical data
    final items =
        await EnhancedBudgetCalculator.createDetailedBudgetWithHistoricalData(
          serviceType: 'Videography',
          guestCount: guestCount,
          eventType: eventType,
          eventDuration: eventDuration,
          location: location,
          eventDate: eventDate,
        );

    return items;
  }
}
