import 'package:eventati_book/models/models.dart';

/// Builder class for creating budget items from wizard data
class BudgetItemsBuilder {
  /// Create budget items based on selected services
  static List<BudgetItem> createBudgetItemsFromServices({
    required Map<String, bool> selectedServices,
    required int guestCount,
    required String eventType,
    required int eventDuration,
    required bool needsSetup,
    required int setupHours,
    required bool needsTeardown,
    required int teardownHours,
  }) {
    final List<BudgetItem> budgetItems = [];

    // Add venue budget items if selected
    if (selectedServices['Venue'] == true) {
      budgetItems.addAll(
        _createVenueBudgetItems(
          guestCount: guestCount,
          eventType: eventType,
          eventDuration: eventDuration,
          needsSetup: needsSetup,
          setupHours: setupHours,
          needsTeardown: needsTeardown,
          teardownHours: teardownHours,
        ),
      );
    }

    // Add catering budget items if selected
    if (selectedServices['Catering'] == true) {
      budgetItems.addAll(
        _createCateringBudgetItems(
          guestCount: guestCount,
          eventType: eventType,
          eventDuration: eventDuration,
        ),
      );
    }

    // Add photography budget items if selected
    if (selectedServices['Photography'] == true ||
        selectedServices['Photography/Videography'] == true) {
      budgetItems.addAll(
        _createPhotographyBudgetItems(eventDuration: eventDuration),
      );
    }

    // Add videography budget items if selected
    if (selectedServices['Videography'] == true ||
        selectedServices['Photography/Videography'] == true) {
      budgetItems.addAll(
        _createVideographyBudgetItems(eventDuration: eventDuration),
      );
    }

    // Add entertainment budget items if selected
    if (selectedServices['Entertainment'] == true) {
      budgetItems.addAll(_createEntertainmentBudgetItems());
    }

    // Add decor budget items if selected
    if (selectedServices['Decor'] == true) {
      budgetItems.addAll(_createDecorBudgetItems(guestCount: guestCount));
    }

    // Add transportation budget items if selected
    if (selectedServices['Transportation'] == true) {
      budgetItems.addAll(
        _createTransportationBudgetItems(guestCount: guestCount),
      );
    }

    // Add flowers budget items if selected
    if (selectedServices['Flowers'] == true) {
      budgetItems.addAll(_createFlowersBudgetItems());
    }

    // Add planner budget items if selected
    if (selectedServices['Wedding Planner'] == true ||
        selectedServices['Event Staff'] == true) {
      budgetItems.addAll(_createPlannerBudgetItems());
    }

    return budgetItems;
  }

  /// Create venue budget items
  static List<BudgetItem> _createVenueBudgetItems({
    required int guestCount,
    required String eventType,
    required int eventDuration,
    required bool needsSetup,
    required int setupHours,
    required bool needsTeardown,
    required int teardownHours,
  }) {
    final List<BudgetItem> items = [];
    final cost = _calculateEstimatedCost(
      'Venue',
      guestCount,
      eventType,
      eventDuration,
    );

    items.add(
      BudgetItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        categoryId: '1', // Venue category
        description: 'Venue rental',
        estimatedCost: cost,
        isPaid: false,
        notes: 'Based on $guestCount guests and $eventDuration day(s)',
      ),
    );

    // Add setup and teardown costs for business events
    if (eventType.toLowerCase().contains('business')) {
      if (needsSetup) {
        items.add(
          BudgetItem(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            categoryId: '1', // Venue category
            description: 'Venue setup',
            estimatedCost: setupHours * 100, // $100 per hour
            isPaid: false,
            notes: 'Setup costs for $setupHours hour(s)',
          ),
        );
      }

      if (needsTeardown) {
        items.add(
          BudgetItem(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            categoryId: '1', // Venue category
            description: 'Venue teardown',
            estimatedCost: teardownHours * 100, // $100 per hour
            isPaid: false,
            notes: 'Teardown costs for $teardownHours hour(s)',
          ),
        );
      }
    }

    return items;
  }

  /// Create catering budget items
  static List<BudgetItem> _createCateringBudgetItems({
    required int guestCount,
    required String eventType,
    required int eventDuration,
  }) {
    final List<BudgetItem> items = [];
    final cost = _calculateEstimatedCost(
      'Catering',
      guestCount,
      eventType,
      eventDuration,
    );

    items.add(
      BudgetItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        categoryId: '2', // Catering category
        description: 'Catering service',
        estimatedCost: cost,
        isPaid: false,
        notes: 'Based on $guestCount guests',
      ),
    );

    // Add beverage costs
    items.add(
      BudgetItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        categoryId: '2', // Catering category
        description: 'Beverages',
        estimatedCost: guestCount * 15, // $15 per guest
        isPaid: false,
        notes: 'Estimated beverage costs',
      ),
    );

    return items;
  }

  /// Create photography budget items
  static List<BudgetItem> _createPhotographyBudgetItems({
    required int eventDuration,
  }) {
    final List<BudgetItem> items = [];

    items.add(
      BudgetItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        categoryId: '3', // Photography category
        description: 'Photographer',
        estimatedCost: 2000.0 * eventDuration, // $2000 per day
        isPaid: false,
        notes: 'Photography services for $eventDuration day(s)',
      ),
    );

    return items;
  }

  /// Create videography budget items
  static List<BudgetItem> _createVideographyBudgetItems({
    required int eventDuration,
  }) {
    final List<BudgetItem> items = [];

    items.add(
      BudgetItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        categoryId: '3', // Photography category
        description: 'Videographer',
        estimatedCost: 2500.0 * eventDuration, // $2500 per day
        isPaid: false,
        notes: 'Videography services for $eventDuration day(s)',
      ),
    );

    return items;
  }

  /// Create entertainment budget items
  static List<BudgetItem> _createEntertainmentBudgetItems() {
    final List<BudgetItem> items = [];

    items.add(
      BudgetItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        categoryId: '4', // Entertainment category
        description: 'Entertainment',
        estimatedCost: 1500, // Base cost
        isPaid: false,
        notes: 'Entertainment services',
      ),
    );

    return items;
  }

  /// Create decor budget items
  static List<BudgetItem> _createDecorBudgetItems({required int guestCount}) {
    final List<BudgetItem> items = [];

    items.add(
      BudgetItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        categoryId: '5', // Decor category
        description: 'Decorations',
        estimatedCost: 500 + (guestCount * 5), // Base cost + per guest
        isPaid: false,
        notes: 'Decorations for venue and tables',
      ),
    );

    return items;
  }

  /// Create transportation budget items
  static List<BudgetItem> _createTransportationBudgetItems({
    required int guestCount,
  }) {
    final List<BudgetItem> items = [];

    items.add(
      BudgetItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        categoryId: '7', // Transportation category
        description: 'Guest transportation',
        estimatedCost: guestCount * 20, // $20 per guest
        isPaid: false,
        notes: 'Transportation for guests',
      ),
    );

    return items;
  }

  /// Create flowers budget items
  static List<BudgetItem> _createFlowersBudgetItems() {
    final List<BudgetItem> items = [];

    items.add(
      BudgetItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        categoryId: '5', // Decor category
        description: 'Flowers',
        estimatedCost: 800, // Base cost
        isPaid: false,
        notes: 'Floral arrangements',
      ),
    );

    return items;
  }

  /// Create planner budget items
  static List<BudgetItem> _createPlannerBudgetItems() {
    final List<BudgetItem> items = [];

    items.add(
      BudgetItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        categoryId: '10', // Miscellaneous category
        description: 'Event planner',
        estimatedCost: 2000, // Base cost
        isPaid: false,
        notes: 'Event planning services',
      ),
    );

    return items;
  }

  /// Calculate estimated cost based on service type, guest count, event type, and duration
  static double _calculateEstimatedCost(
    String serviceType,
    int guestCount,
    String eventType,
    int eventDuration,
  ) {
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

      default:
        return 0.0;
    }
  }
}
