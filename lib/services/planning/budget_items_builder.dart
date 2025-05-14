import 'package:eventati_book/models/planning_models/budget_item.dart';
import 'package:eventati_book/utils/logger.dart';

/// Service for building budget items based on event details
class BudgetItemsBuilder {
  /// Create budget items based on event details
  static List<BudgetItem> createBudgetItems(
    Map<String, bool> selectedServices,
    int guestCount,
    String eventType,
    int eventDuration, {
    String location = 'Unknown',
    DateTime? eventDate,
    bool isPremiumVenue = false,
  }) {
    Logger.i(
      'Creating budget items for $eventType event with $guestCount guests',
      tag: 'BudgetItemsBuilder',
    );

    final budgetItems = <BudgetItem>[];

    // Create a basic budget structure based on event type and guest count
    final baseAmount = guestCount * 100.0; // $100 per guest as a starting point

    // Adjust base amount based on event type
    double adjustedBaseAmount = baseAmount;
    if (eventType.toLowerCase().contains('wedding')) {
      adjustedBaseAmount = baseAmount * 1.5; // Weddings typically cost more
    } else if (eventType.toLowerCase().contains('business')) {
      adjustedBaseAmount =
          baseAmount * 1.2; // Business events have higher standards
    }

    // Add venue budget item
    if (selectedServices['Venue'] == true) {
      final venueAmount = adjustedBaseAmount * 0.4; // 40% of budget for venue
      budgetItems.add(
        BudgetItem(
          id: 'venue_${DateTime.now().millisecondsSinceEpoch}',
          categoryId: '1', // Venue category
          description: 'Venue Rental',
          estimatedCost: venueAmount,
          isPaid: false,
          notes: 'Based on $guestCount guests',
        ),
      );

      // Add setup/teardown costs if premium venue
      if (isPremiumVenue) {
        budgetItems.add(
          BudgetItem(
            id: 'venue_setup_${DateTime.now().millisecondsSinceEpoch}',
            categoryId: '1', // Venue category
            description: 'Venue Setup/Teardown',
            estimatedCost: venueAmount * 0.1, // 10% of venue cost
            isPaid: false,
            notes: 'Setup and teardown fees',
          ),
        );
      }
    }

    // Add catering budget item
    if (selectedServices['Catering'] == true) {
      final cateringAmount =
          adjustedBaseAmount * 0.3; // 30% of budget for catering
      budgetItems.add(
        BudgetItem(
          id: 'catering_${DateTime.now().millisecondsSinceEpoch}',
          categoryId: '2', // Food & Beverage category
          description: 'Catering Services',
          estimatedCost: cateringAmount,
          isPaid: false,
          notes: 'Based on $guestCount guests',
        ),
      );

      // Add beverage service if selected
      if (selectedServices['Bar Service'] == true ||
          selectedServices['Beverage Service'] == true) {
        budgetItems.add(
          BudgetItem(
            id: 'beverages_${DateTime.now().millisecondsSinceEpoch}',
            categoryId: '2', // Food & Beverage category
            description: 'Beverage Service',
            estimatedCost: cateringAmount * 0.4, // 40% of catering cost
            isPaid: false,
            notes: 'Beverages for $guestCount guests',
          ),
        );
      }
    }

    // Add photography/videography budget item
    if (selectedServices['Photography'] == true ||
        selectedServices['Videography'] == true ||
        selectedServices['Photography/Videography'] == true) {
      final photoAmount =
          adjustedBaseAmount * 0.15; // 15% of budget for photo/video
      budgetItems.add(
        BudgetItem(
          id: 'photo_video_${DateTime.now().millisecondsSinceEpoch}',
          categoryId: '3', // Photography category
          description: 'Photography/Videography',
          estimatedCost: photoAmount,
          isPaid: false,
          notes: 'Professional photo/video services',
        ),
      );
    }

    // Add entertainment budget item
    if (selectedServices['Entertainment'] == true ||
        selectedServices['DJ'] == true ||
        selectedServices['Live Music'] == true) {
      final entertainmentAmount =
          adjustedBaseAmount * 0.1; // 10% of budget for entertainment
      budgetItems.add(
        BudgetItem(
          id: 'entertainment_${DateTime.now().millisecondsSinceEpoch}',
          categoryId: '4', // Entertainment category
          description: 'Entertainment Services',
          estimatedCost: entertainmentAmount,
          isPaid: false,
          notes: 'DJ, band, or other entertainment',
        ),
      );
    }

    // Add decor budget item
    if (selectedServices['Decor'] == true ||
        selectedServices['Flowers'] == true ||
        selectedServices['Decorations'] == true) {
      final decorAmount = adjustedBaseAmount * 0.1; // 10% of budget for decor
      budgetItems.add(
        BudgetItem(
          id: 'decor_${DateTime.now().millisecondsSinceEpoch}',
          categoryId: '5', // Decor category
          description: 'Decorations and Flowers',
          estimatedCost: decorAmount,
          isPaid: false,
          notes: 'Event decorations and floral arrangements',
        ),
      );
    }

    // Add transportation budget item if needed
    if (selectedServices['Transportation'] == true) {
      final transportAmount =
          adjustedBaseAmount * 0.05; // 5% of budget for transportation
      budgetItems.add(
        BudgetItem(
          id: 'transport_${DateTime.now().millisecondsSinceEpoch}',
          categoryId: '7', // Transportation category
          description: 'Guest Transportation',
          estimatedCost: transportAmount,
          isPaid: false,
          notes: 'Transportation services for guests',
        ),
      );
    }

    // Add miscellaneous budget item for unexpected expenses
    budgetItems.add(
      BudgetItem(
        id: 'misc_${DateTime.now().millisecondsSinceEpoch}',
        categoryId: '10', // Miscellaneous category
        description: 'Miscellaneous Expenses',
        estimatedCost: adjustedBaseAmount * 0.05, // 5% of budget for misc
        isPaid: false,
        notes: 'Contingency for unexpected costs',
      ),
    );

    // Add event-specific budget items
    if (eventType.toLowerCase().contains('wedding')) {
      _addWeddingSpecificItems(budgetItems, adjustedBaseAmount);
    } else if (eventType.toLowerCase().contains('business')) {
      _addBusinessSpecificItems(budgetItems, adjustedBaseAmount, guestCount);
    }

    return budgetItems;
  }

  /// Add wedding-specific budget items
  static void _addWeddingSpecificItems(
    List<BudgetItem> budgetItems,
    double baseAmount,
  ) {
    // Add wedding attire
    budgetItems.add(
      BudgetItem(
        id: 'attire_${DateTime.now().millisecondsSinceEpoch}',
        categoryId: '6', // Attire category
        description: 'Wedding Attire',
        estimatedCost: baseAmount * 0.1, // 10% of budget for attire
        isPaid: false,
        notes: 'Wedding dress, suits, accessories',
      ),
    );

    // Add rings
    budgetItems.add(
      BudgetItem(
        id: 'rings_${DateTime.now().millisecondsSinceEpoch}',
        categoryId: '9', // Gifts category
        description: 'Wedding Rings',
        estimatedCost: baseAmount * 0.05, // 5% of budget for rings
        isPaid: false,
        notes: 'Wedding bands',
      ),
    );

    // Add stationery
    budgetItems.add(
      BudgetItem(
        id: 'stationery_${DateTime.now().millisecondsSinceEpoch}',
        categoryId: '8', // Stationery category
        description: 'Invitations and Stationery',
        estimatedCost: baseAmount * 0.03, // 3% of budget for stationery
        isPaid: false,
        notes: 'Invitations, programs, thank you cards',
      ),
    );
  }

  /// Add business event-specific budget items
  static void _addBusinessSpecificItems(
    List<BudgetItem> budgetItems,
    double baseAmount,
    int guestCount,
  ) {
    // Add A/V equipment
    budgetItems.add(
      BudgetItem(
        id: 'av_equipment_${DateTime.now().millisecondsSinceEpoch}',
        categoryId: '10', // Equipment category
        description: 'A/V Equipment',
        estimatedCost: baseAmount * 0.08, // 8% of budget for A/V
        isPaid: false,
        notes: 'Projectors, microphones, speakers',
      ),
    );

    // Add printed materials
    budgetItems.add(
      BudgetItem(
        id: 'materials_${DateTime.now().millisecondsSinceEpoch}',
        categoryId: '8', // Materials category
        description: 'Printed Materials',
        estimatedCost: guestCount * 15.0, // $15 per guest for materials
        isPaid: false,
        notes: 'Handouts, brochures, name badges',
      ),
    );

    // Add speaker/presenter fees
    budgetItems.add(
      BudgetItem(
        id: 'speakers_${DateTime.now().millisecondsSinceEpoch}',
        categoryId: '9', // Talent category
        description: 'Speaker/Presenter Fees',
        estimatedCost: baseAmount * 0.15, // 15% of budget for speakers
        isPaid: false,
        notes: 'Honorariums and travel for presenters',
      ),
    );
  }
}
