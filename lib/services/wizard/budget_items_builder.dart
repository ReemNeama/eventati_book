import 'package:eventati_book/models/models.dart';
import 'package:eventati_book/services/wizard/enhanced_budget_calculator.dart';

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
    String location = 'Unknown',
    DateTime? eventDate,
    bool isPremiumVenue = false,
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
          location: location,
          eventDate: eventDate,
          isPremiumVenue: isPremiumVenue,
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
          location: location,
          eventDate: eventDate,
        ),
      );
    }

    // Add photography budget items if selected
    if (selectedServices['Photography'] == true ||
        selectedServices['Photography/Videography'] == true) {
      budgetItems.addAll(
        _createPhotographyBudgetItems(
          eventDuration: eventDuration,
          eventType: eventType,
          guestCount: guestCount,
          location: location,
          eventDate: eventDate,
        ),
      );
    }

    // Add videography budget items if selected
    if (selectedServices['Videography'] == true ||
        selectedServices['Photography/Videography'] == true) {
      budgetItems.addAll(
        _createVideographyBudgetItems(
          eventDuration: eventDuration,
          eventType: eventType,
          guestCount: guestCount,
          location: location,
          eventDate: eventDate,
        ),
      );
    }

    // Add entertainment budget items if selected
    if (selectedServices['Entertainment'] == true) {
      budgetItems.addAll(
        _createEntertainmentBudgetItems(
          eventType: eventType,
          guestCount: guestCount,
          eventDuration: eventDuration,
          location: location,
          eventDate: eventDate,
        ),
      );
    }

    // Add decor budget items if selected
    if (selectedServices['Decor'] == true) {
      budgetItems.addAll(
        _createDecorBudgetItems(
          guestCount: guestCount,
          eventType: eventType,
          location: location,
          eventDate: eventDate,
        ),
      );
    }

    // Add transportation budget items if selected
    if (selectedServices['Transportation'] == true) {
      budgetItems.addAll(
        _createTransportationBudgetItems(
          guestCount: guestCount,
          eventType: eventType,
          location: location,
        ),
      );
    }

    // Add flowers budget items if selected
    if (selectedServices['Flowers'] == true) {
      budgetItems.addAll(
        _createFlowersBudgetItems(
          eventType: eventType,
          guestCount: guestCount,
          location: location,
          eventDate: eventDate,
        ),
      );
    }

    // Add planner budget items if selected
    if (selectedServices['Wedding Planner'] == true ||
        selectedServices['Event Staff'] == true) {
      budgetItems.addAll(
        _createPlannerBudgetItems(
          eventType: eventType,
          guestCount: guestCount,
          eventDuration: eventDuration,
          location: location,
        ),
      );
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
    String location = 'Unknown',
    DateTime? eventDate,
    bool isPremiumVenue = false,
  }) {
    final List<BudgetItem> items = [];

    // Check if the event is on a weekend
    final isWeekend =
        eventDate != null
            ? (eventDate.weekday == 6 || eventDate.weekday == 7)
            : false;

    // Calculate venue cost with enhanced calculator
    final cost = EnhancedBudgetCalculator.calculateEstimatedCost(
      serviceType: 'Venue',
      guestCount: guestCount,
      eventType: eventType,
      eventDuration: eventDuration,
      location: location,
      eventDate: eventDate,
      isPremiumVenue: isPremiumVenue,
      isWeekend: isWeekend,
    );

    // Add detailed notes about cost factors
    String costFactors =
        'Based on $guestCount guests and $eventDuration day(s)';
    if (location != 'Unknown') {
      costFactors += ', in $location';
    }
    if (eventDate != null) {
      costFactors += ', on ${eventDate.toString().substring(0, 10)}';
    }
    if (isWeekend) {
      costFactors += ' (weekend)';
    }
    if (isPremiumVenue) {
      costFactors += ' (premium venue)';
    }

    items.add(
      BudgetItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        categoryId: '1', // Venue category
        description: 'Venue rental',
        estimatedCost: cost,
        isPaid: false,
        notes: costFactors,
      ),
    );

    // Add setup and teardown costs for business events and weddings
    if (eventType.toLowerCase().contains('business') ||
        eventType.toLowerCase().contains('wedding')) {
      if (needsSetup) {
        // Setup cost is now calculated as a percentage of venue cost
        final setupCost =
            setupHours * (cost * 0.05); // 5% of venue cost per hour

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

      if (needsTeardown) {
        // Teardown cost is now calculated as a percentage of venue cost
        final teardownCost =
            teardownHours * (cost * 0.04); // 4% of venue cost per hour

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
    }

    return items;
  }

  /// Create catering budget items
  static List<BudgetItem> _createCateringBudgetItems({
    required int guestCount,
    required String eventType,
    required int eventDuration,
    String location = 'Unknown',
    DateTime? eventDate,
  }) {
    final List<BudgetItem> items = [];

    // Check if the event is on a weekend
    final isWeekend =
        eventDate != null
            ? (eventDate.weekday == 6 || eventDate.weekday == 7)
            : false;

    // Calculate catering cost with enhanced calculator
    final cost = EnhancedBudgetCalculator.calculateEstimatedCost(
      serviceType: 'Catering',
      guestCount: guestCount,
      eventType: eventType,
      eventDuration: eventDuration,
      location: location,
      eventDate: eventDate,
      isWeekend: isWeekend,
    );

    // Add detailed notes about cost factors
    String costFactors = 'Based on $guestCount guests';
    if (location != 'Unknown') {
      costFactors += ', in $location';
    }
    if (eventDate != null) {
      costFactors += ', on ${eventDate.toString().substring(0, 10)}';
    }
    if (isWeekend) {
      costFactors += ' (weekend)';
    }

    items.add(
      BudgetItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        categoryId: '2', // Catering category
        description: 'Catering service',
        estimatedCost: cost,
        isPaid: false,
        notes: costFactors,
      ),
    );

    // Calculate beverage costs based on event type
    double beverageCostPerGuest = 15.0; // Base cost

    // Adjust beverage cost based on event type
    if (eventType.toLowerCase().contains('wedding')) {
      beverageCostPerGuest = 25.0; // Higher for weddings (more alcohol)
    } else if (eventType.toLowerCase().contains('business')) {
      beverageCostPerGuest = 12.0; // Lower for business events
    }

    // Add location factor
    if (location.toLowerCase().contains('new york') ||
        location.toLowerCase().contains('san francisco')) {
      beverageCostPerGuest *= 1.3; // 30% higher in expensive cities
    }

    items.add(
      BudgetItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        categoryId: '2', // Catering category
        description: 'Beverages',
        estimatedCost: guestCount * beverageCostPerGuest,
        isPaid: false,
        notes: 'Estimated beverage costs for $guestCount guests',
      ),
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

  /// Create photography budget items
  static List<BudgetItem> _createPhotographyBudgetItems({
    required int eventDuration,
    required String eventType,
    required int guestCount,
    String location = 'Unknown',
    DateTime? eventDate,
  }) {
    final List<BudgetItem> items = [];

    // Check if the event is on a weekend
    final isWeekend =
        eventDate != null
            ? (eventDate.weekday == 6 || eventDate.weekday == 7)
            : false;

    // Calculate photography cost with enhanced calculator
    final cost = EnhancedBudgetCalculator.calculateEstimatedCost(
      serviceType: 'Photography',
      guestCount: guestCount,
      eventType: eventType,
      eventDuration: eventDuration,
      location: location,
      eventDate: eventDate,
      isWeekend: isWeekend,
    );

    // Add detailed notes about cost factors
    String costFactors = 'Photography services for $eventDuration day(s)';
    if (location != 'Unknown') {
      costFactors += ', in $location';
    }
    if (eventDate != null) {
      costFactors += ', on ${eventDate.toString().substring(0, 10)}';
    }
    if (isWeekend) {
      costFactors += ' (weekend)';
    }

    items.add(
      BudgetItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        categoryId: '3', // Photography category
        description: 'Photographer',
        estimatedCost: cost,
        isPaid: false,
        notes: costFactors,
      ),
    );

    // Add second photographer for weddings or large events
    if (eventType.toLowerCase().contains('wedding') || guestCount > 150) {
      items.add(
        BudgetItem(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          categoryId: '3', // Photography category
          description: 'Second photographer',
          estimatedCost: cost * 0.5, // 50% of main photographer cost
          isPaid: false,
          notes: 'Additional photographer for better coverage',
        ),
      );
    }

    // Add photo editing costs
    items.add(
      BudgetItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        categoryId: '3', // Photography category
        description: 'Photo editing',
        estimatedCost: cost * 0.2, // 20% of photography cost
        isPaid: false,
        notes: 'Post-production editing and retouching',
      ),
    );

    return items;
  }

  /// Create videography budget items
  static List<BudgetItem> _createVideographyBudgetItems({
    required int eventDuration,
    required String eventType,
    required int guestCount,
    String location = 'Unknown',
    DateTime? eventDate,
  }) {
    final List<BudgetItem> items = [];

    // Check if the event is on a weekend
    final isWeekend =
        eventDate != null
            ? (eventDate.weekday == 6 || eventDate.weekday == 7)
            : false;

    // Calculate videography cost with enhanced calculator
    final cost = EnhancedBudgetCalculator.calculateEstimatedCost(
      serviceType: 'Videography',
      guestCount: guestCount,
      eventType: eventType,
      eventDuration: eventDuration,
      location: location,
      eventDate: eventDate,
      isWeekend: isWeekend,
    );

    // Add detailed notes about cost factors
    String costFactors = 'Videography services for $eventDuration day(s)';
    if (location != 'Unknown') {
      costFactors += ', in $location';
    }
    if (eventDate != null) {
      costFactors += ', on ${eventDate.toString().substring(0, 10)}';
    }
    if (isWeekend) {
      costFactors += ' (weekend)';
    }

    items.add(
      BudgetItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        categoryId: '3', // Photography category
        description: 'Videographer',
        estimatedCost: cost,
        isPaid: false,
        notes: costFactors,
      ),
    );

    // Add video editing costs
    items.add(
      BudgetItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        categoryId: '3', // Photography category
        description: 'Video editing',
        estimatedCost: cost * 0.3, // 30% of videography cost
        isPaid: false,
        notes: 'Post-production editing and effects',
      ),
    );

    // Add drone footage for outdoor events
    if (eventType.toLowerCase().contains('wedding') ||
        eventType.toLowerCase().contains('celebration')) {
      items.add(
        BudgetItem(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          categoryId: '3', // Photography category
          description: 'Drone footage',
          estimatedCost: 500.0, // Fixed cost for drone
          isPaid: false,
          notes: 'Aerial videography of venue and event',
        ),
      );
    }

    return items;
  }

  /// Create entertainment budget items
  static List<BudgetItem> _createEntertainmentBudgetItems({
    required String eventType,
    required int guestCount,
    required int eventDuration,
    String location = 'Unknown',
    DateTime? eventDate,
  }) {
    final List<BudgetItem> items = [];

    // Check if the event is on a weekend
    final isWeekend =
        eventDate != null
            ? (eventDate.weekday == 6 || eventDate.weekday == 7)
            : false;

    // Calculate entertainment cost with enhanced calculator
    final cost = EnhancedBudgetCalculator.calculateEstimatedCost(
      serviceType: 'Entertainment',
      guestCount: guestCount,
      eventType: eventType,
      eventDuration: eventDuration,
      location: location,
      eventDate: eventDate,
      isWeekend: isWeekend,
    );

    // Determine entertainment type based on event type
    if (eventType.toLowerCase().contains('wedding')) {
      // For weddings, add DJ and live band options
      items.add(
        BudgetItem(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          categoryId: '4', // Entertainment category
          description: 'DJ services',
          estimatedCost: cost * 0.4, // 40% of entertainment budget
          isPaid: false,
          notes: 'DJ services for the wedding reception',
        ),
      );

      items.add(
        BudgetItem(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          categoryId: '4', // Entertainment category
          description: 'Live band or musician',
          estimatedCost: cost * 0.6, // 60% of entertainment budget
          isPaid: false,
          notes: 'Live music for ceremony and/or reception',
        ),
      );
    } else if (eventType.toLowerCase().contains('business')) {
      // For business events, add speaker and AV equipment
      items.add(
        BudgetItem(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          categoryId: '4', // Entertainment category
          description: 'Speaker/Presenter',
          estimatedCost: cost * 0.7, // 70% of entertainment budget
          isPaid: false,
          notes: 'Professional speaker or presenter',
        ),
      );

      items.add(
        BudgetItem(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          categoryId: '4', // Entertainment category
          description: 'AV Equipment',
          estimatedCost: cost * 0.3, // 30% of entertainment budget
          isPaid: false,
          notes: 'Audio/visual equipment for presentations',
        ),
      );
    } else {
      // For celebrations and other events
      items.add(
        BudgetItem(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          categoryId: '4', // Entertainment category
          description: 'DJ services',
          estimatedCost: cost * 0.5, // 50% of entertainment budget
          isPaid: false,
          notes: 'DJ services for the event',
        ),
      );

      items.add(
        BudgetItem(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          categoryId: '4', // Entertainment category
          description: 'Entertainment activities',
          estimatedCost: cost * 0.5, // 50% of entertainment budget
          isPaid: false,
          notes: 'Games, photo booth, or other entertainment activities',
        ),
      );
    }

    return items;
  }

  /// Create decor budget items
  static List<BudgetItem> _createDecorBudgetItems({
    required int guestCount,
    required String eventType,
    String location = 'Unknown',
    DateTime? eventDate,
  }) {
    final List<BudgetItem> items = [];

    // Calculate base cost based on event type
    double baseCost = 500.0; // Default base cost
    double perGuestCost = 5.0; // Default per guest cost

    if (eventType.toLowerCase().contains('wedding')) {
      baseCost = 800.0; // Higher base cost for weddings
      perGuestCost = 8.0; // Higher per guest cost for weddings
    } else if (eventType.toLowerCase().contains('business')) {
      baseCost = 400.0; // Lower base cost for business events
      perGuestCost = 3.0; // Lower per guest cost for business events
    }

    // Apply seasonal adjustments
    double seasonalFactor = 1.0;
    if (eventDate != null) {
      final month = eventDate.month;

      // Holiday season (November-December)
      if (month == 11 || month == 12) {
        seasonalFactor = 1.2; // 20% higher during holiday season
      }

      // Spring (March-May)
      if (month >= 3 && month <= 5) {
        seasonalFactor = 1.1; // 10% higher during spring
      }
    }

    // Apply location adjustments
    double locationFactor = 1.0;
    if (location.toLowerCase().contains('new york') ||
        location.toLowerCase().contains('los angeles')) {
      locationFactor = 1.3; // 30% higher in expensive cities
    }

    // Calculate final cost
    final decorCost =
        (baseCost + (perGuestCost * guestCount)) *
        seasonalFactor *
        locationFactor;

    // Add detailed notes about cost factors
    String costFactors = 'Decorations for venue and tables';
    if (seasonalFactor > 1.0) {
      costFactors += ', seasonal adjustment applied';
    }
    if (locationFactor > 1.0) {
      costFactors += ', location premium applied';
    }

    items.add(
      BudgetItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        categoryId: '5', // Decor category
        description: 'Decorations',
        estimatedCost: decorCost,
        isPaid: false,
        notes: costFactors,
      ),
    );

    // Add floral arrangements for weddings and some celebrations
    if (eventType.toLowerCase().contains('wedding') ||
        eventType.toLowerCase().contains('celebration')) {
      items.add(
        BudgetItem(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          categoryId: '5', // Decor category
          description: 'Floral arrangements',
          estimatedCost: decorCost * 0.6, // 60% of decor cost
          isPaid: false,
          notes: 'Flowers and floral arrangements',
        ),
      );
    }

    // Add lighting for evening events
    items.add(
      BudgetItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        categoryId: '5', // Decor category
        description: 'Lighting',
        estimatedCost: decorCost * 0.3, // 30% of decor cost
        isPaid: false,
        notes: 'Special lighting and effects',
      ),
    );

    return items;
  }

  /// Create transportation budget items
  static List<BudgetItem> _createTransportationBudgetItems({
    required int guestCount,
    required String eventType,
    String location = 'Unknown',
  }) {
    final List<BudgetItem> items = [];

    // Calculate transportation costs based on event type and location
    double perGuestCost = 20.0; // Default per guest cost
    double percentageOfGuestsNeeding =
        0.6; // Default percentage of guests needing transportation

    // Adjust based on event type
    if (eventType.toLowerCase().contains('wedding')) {
      perGuestCost = 25.0; // Higher for weddings
      percentageOfGuestsNeeding =
          0.7; // More guests need transportation for weddings
    } else if (eventType.toLowerCase().contains('business')) {
      perGuestCost =
          30.0; // Higher for business events (more premium transportation)
      percentageOfGuestsNeeding =
          0.8; // More guests need transportation for business events
    }

    // Adjust based on location
    if (location.toLowerCase().contains('new york') ||
        location.toLowerCase().contains('chicago') ||
        location.toLowerCase().contains('los angeles')) {
      perGuestCost *= 1.5; // 50% higher in major cities
    } else if (location.toLowerCase().contains('rural') ||
        location.toLowerCase().contains('remote')) {
      perGuestCost *= 1.3; // 30% higher in remote locations
      percentageOfGuestsNeeding =
          0.9; // More guests need transportation in remote locations
    }

    // Calculate number of guests needing transportation
    final guestsNeedingTransport =
        (guestCount * percentageOfGuestsNeeding).round();

    // Calculate total cost
    final transportCost = guestsNeedingTransport * perGuestCost;

    items.add(
      BudgetItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        categoryId: '7', // Transportation category
        description: 'Guest transportation',
        estimatedCost: transportCost,
        isPaid: false,
        notes:
            'Transportation for approximately $guestsNeedingTransport guests',
      ),
    );

    // Add VIP transportation for weddings and business events
    if (eventType.toLowerCase().contains('wedding') ||
        eventType.toLowerCase().contains('business')) {
      items.add(
        BudgetItem(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          categoryId: '7', // Transportation category
          description: 'VIP transportation',
          estimatedCost: 500.0, // Fixed cost for VIP transportation
          isPaid: false,
          notes: 'Premium transportation for key individuals',
        ),
      );
    }

    return items;
  }

  /// Create flowers budget items
  static List<BudgetItem> _createFlowersBudgetItems({
    required String eventType,
    required int guestCount,
    String location = 'Unknown',
    DateTime? eventDate,
  }) {
    final List<BudgetItem> items = [];

    // Base cost calculation
    double baseCost = 800.0; // Default base cost
    double perTableCost = 50.0; // Cost per table arrangement

    // Estimate number of tables (1 table per 8-10 guests)
    final tableCount = (guestCount / 8).ceil();

    // Adjust based on event type
    if (eventType.toLowerCase().contains('wedding')) {
      baseCost = 1200.0; // Higher base cost for weddings
      perTableCost = 75.0; // Higher per table cost for weddings

      // Add bridal bouquet and other wedding-specific flowers
      items.add(
        BudgetItem(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          categoryId: '5', // Decor category
          description: 'Bridal bouquet and accessories',
          estimatedCost: 350.0,
          isPaid: false,
          notes: 'Bridal bouquet, boutonnieres, and corsages',
        ),
      );
    } else if (eventType.toLowerCase().contains('business')) {
      baseCost = 600.0; // Lower base cost for business events
      perTableCost = 40.0; // Lower per table cost for business events
    }

    // Apply seasonal adjustments
    double seasonalFactor = 1.0;
    if (eventDate != null) {
      final month = eventDate.month;

      // Valentine's Day and Mother's Day season
      if (month == 2 || month == 5) {
        seasonalFactor = 1.3; // 30% higher during flower-heavy holidays
      }

      // Winter (December-February)
      if (month == 12 || month == 1 || month == 2) {
        seasonalFactor =
            1.15; // 15% higher during winter (except for Valentine's)
      }
    }

    // Calculate table arrangements cost
    final tableArrangementsCost = tableCount * perTableCost * seasonalFactor;

    // Calculate entrance and focal point arrangements
    final focalPointCost = baseCost * seasonalFactor;

    // Add table arrangements
    items.add(
      BudgetItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        categoryId: '5', // Decor category
        description: 'Table arrangements',
        estimatedCost: tableArrangementsCost,
        isPaid: false,
        notes: 'Floral arrangements for $tableCount tables',
      ),
    );

    // Add entrance and focal point arrangements
    items.add(
      BudgetItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        categoryId: '5', // Decor category
        description: 'Entrance and focal point flowers',
        estimatedCost: focalPointCost,
        isPaid: false,
        notes: 'Statement floral pieces for key areas',
      ),
    );

    return items;
  }

  /// Create planner budget items
  static List<BudgetItem> _createPlannerBudgetItems({
    required String eventType,
    required int guestCount,
    required int eventDuration,
    String location = 'Unknown',
  }) {
    final List<BudgetItem> items = [];

    // Base cost calculation
    double baseCost = 2000.0; // Default base cost

    // Adjust based on event type
    if (eventType.toLowerCase().contains('wedding')) {
      // Wedding planners are more expensive
      baseCost = 3000.0;

      // Add day-of coordinator for weddings
      items.add(
        BudgetItem(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          categoryId: '10', // Miscellaneous category
          description: 'Day-of coordinator',
          estimatedCost: 1200.0,
          isPaid: false,
          notes: 'Coordination services for the wedding day',
        ),
      );
    } else if (eventType.toLowerCase().contains('business')) {
      // Business event planners have different pricing
      baseCost = 2500.0;

      // Add AV coordinator for business events
      items.add(
        BudgetItem(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          categoryId: '10', // Miscellaneous category
          description: 'Technical coordinator',
          estimatedCost: 800.0,
          isPaid: false,
          notes: 'Coordination of technical aspects and presentations',
        ),
      );
    }

    // Adjust based on guest count
    if (guestCount > 150) {
      baseCost *= 1.3; // 30% more for large events
    } else if (guestCount < 50) {
      baseCost *= 0.8; // 20% less for small events
    }

    // Adjust based on event duration
    baseCost *=
        (1.0 + (eventDuration - 1) * 0.2); // 20% more for each additional day

    // Adjust based on location
    if (location.toLowerCase().contains('new york') ||
        location.toLowerCase().contains('los angeles')) {
      baseCost *= 1.4; // 40% more in expensive cities
    }

    // Add main planner item
    items.add(
      BudgetItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        categoryId: '10', // Miscellaneous category
        description: 'Event planner',
        estimatedCost: baseCost,
        isPaid: false,
        notes: 'Professional planning services for your $eventType',
      ),
    );

    // Add staff costs for larger events
    if (guestCount > 100) {
      // Calculate number of staff needed (1 per 50 guests)
      final staffCount = (guestCount / 50).ceil();
      final staffCost =
          staffCount * 200.0 * eventDuration; // $200 per staff per day

      items.add(
        BudgetItem(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          categoryId: '10', // Miscellaneous category
          description: 'Event staff',
          estimatedCost: staffCost,
          isPaid: false,
          notes: 'Staff costs for $staffCount event assistants',
        ),
      );
    }

    return items;
  }
}
