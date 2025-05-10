import 'package:eventati_book/models/planning_models/budget_item.dart';
import 'package:flutter/material.dart';

/// Temporary database for budget data
class BudgetDB {
  /// Get mock budget items for an event
  static List<BudgetItem> getBudgetItems(String eventId) {
    // Different items based on event ID
    if (eventId == 'event_1') {
      return _getWeddingBudgetItems();
    } else if (eventId == 'event_2' || eventId == 'event_5') {
      return _getBusinessBudgetItems();
    } else {
      return _getCelebrationBudgetItems();
    }
  }

  /// Get mock budget categories
  static List<BudgetCategory> getBudgetCategories() {
    return [
      BudgetCategory(id: 'category_1', name: 'Venue', icon: Icons.location_on),
      BudgetCategory(
        id: 'category_2',
        name: 'Catering',
        icon: Icons.restaurant,
      ),
      BudgetCategory(
        id: 'category_3',
        name: 'Photography',
        icon: Icons.camera_alt,
      ),
      BudgetCategory(
        id: 'category_4',
        name: 'Decoration',
        icon: Icons.celebration,
      ),
      BudgetCategory(
        id: 'category_5',
        name: 'Entertainment',
        icon: Icons.music_note,
      ),
      BudgetCategory(
        id: 'category_6',
        name: 'Transportation',
        icon: Icons.directions_car,
      ),
      BudgetCategory(id: 'category_7', name: 'Attire', icon: Icons.checkroom),
      BudgetCategory(
        id: 'category_8',
        name: 'Miscellaneous',
        icon: Icons.more_horiz,
      ),
    ];
  }

  /// Get wedding budget items
  static List<BudgetItem> _getWeddingBudgetItems() {
    return [
      BudgetItem(
        id: 'budget_item_1',
        categoryId: 'category_1',
        description: 'Wedding Venue',
        estimatedCost: 10000.0,
        actualCost: 9500.0,
        isPaid: true,
        paymentDate: DateTime(2023, 5, 15),
        notes: 'Includes setup and cleanup',
        vendorName: 'Grand Plaza Hotel',
        vendorContact: 'events@grandplaza.com',
        dueDate: DateTime(2023, 5, 15),
        isBooked: true,
      ),
      BudgetItem(
        id: 'budget_item_2',
        categoryId: 'category_2',
        description: 'Catering',
        estimatedCost: 7500.0,
        actualCost: 8000.0,
        isPaid: true,
        paymentDate: DateTime(2023, 5, 20),
        notes: '150 guests, buffet style',
        vendorName: 'Gourmet Catering',
        vendorContact: 'info@gourmetcatering.com',
        dueDate: DateTime(2023, 5, 20),
        isBooked: true,
      ),
      BudgetItem(
        id: 'budget_item_3',
        categoryId: 'category_3',
        description: 'Photography',
        estimatedCost: 3000.0,
        actualCost: 3000.0,
        isPaid: true,
        paymentDate: DateTime(2023, 5, 25),
        notes: '8 hours of coverage',
        vendorName: 'Capture Moments',
        vendorContact: 'info@capturemoments.com',
        dueDate: DateTime(2023, 5, 25),
        isBooked: true,
      ),
      BudgetItem(
        id: 'budget_item_4',
        categoryId: 'category_4',
        description: 'Flowers and Decoration',
        estimatedCost: 2000.0,
        actualCost: null,
        isPaid: false,
        notes: 'Centerpieces, bouquets, and ceremony decor',
        vendorName: 'Blooming Designs',
        vendorContact: 'info@bloomingdesigns.com',
        dueDate: DateTime(2023, 6, 1),
        isBooked: true,
      ),
      BudgetItem(
        id: 'budget_item_5',
        categoryId: 'category_5',
        description: 'DJ and Entertainment',
        estimatedCost: 1500.0,
        actualCost: null,
        isPaid: false,
        notes: '6 hours of music',
        vendorName: 'Rhythm Masters',
        vendorContact: 'bookings@rhythmmasters.com',
        dueDate: DateTime(2023, 6, 5),
        isBooked: true,
      ),
    ];
  }

  /// Get business event budget items
  static List<BudgetItem> _getBusinessBudgetItems() {
    return [
      BudgetItem(
        id: 'budget_item_6',
        categoryId: 'category_1',
        description: 'Conference Venue',
        estimatedCost: 5000.0,
        actualCost: 5000.0,
        isPaid: true,
        paymentDate: DateTime(2023, 7, 15),
        notes: 'Includes AV equipment',
        vendorName: 'Business Center',
        vendorContact: 'events@businesscenter.com',
        dueDate: DateTime(2023, 7, 15),
        isBooked: true,
      ),
      BudgetItem(
        id: 'budget_item_7',
        categoryId: 'category_2',
        description: 'Lunch and Refreshments',
        estimatedCost: 3000.0,
        actualCost: 3200.0,
        isPaid: true,
        paymentDate: DateTime(2023, 7, 20),
        notes: '100 attendees',
        vendorName: 'Corporate Catering',
        vendorContact: 'info@corporatecatering.com',
        dueDate: DateTime(2023, 7, 20),
        isBooked: true,
      ),
      BudgetItem(
        id: 'budget_item_8',
        categoryId: 'category_3',
        description: 'Event Photography',
        estimatedCost: 1000.0,
        actualCost: null,
        isPaid: false,
        notes: '4 hours of coverage',
        vendorName: 'Business Shots',
        vendorContact: 'info@businessshots.com',
        dueDate: DateTime(2023, 8, 1),
        isBooked: true,
      ),
      BudgetItem(
        id: 'budget_item_9',
        categoryId: 'category_8',
        description: 'Printed Materials',
        estimatedCost: 500.0,
        actualCost: null,
        isPaid: false,
        notes: 'Brochures, name tags, and handouts',
        vendorName: 'Print Pro',
        vendorContact: 'orders@printpro.com',
        dueDate: DateTime(2023, 8, 5),
        isBooked: false,
      ),
    ];
  }

  /// Get celebration budget items
  static List<BudgetItem> _getCelebrationBudgetItems() {
    return [
      BudgetItem(
        id: 'budget_item_10',
        categoryId: 'category_1',
        description: 'Party Venue',
        estimatedCost: 2000.0,
        actualCost: 2000.0,
        isPaid: true,
        paymentDate: DateTime(2023, 4, 15),
        notes: 'Private room',
        vendorName: 'Sunset Lounge',
        vendorContact: 'events@sunsetlounge.com',
        dueDate: DateTime(2023, 4, 15),
        isBooked: true,
      ),
      BudgetItem(
        id: 'budget_item_11',
        categoryId: 'category_2',
        description: 'Food and Drinks',
        estimatedCost: 1500.0,
        actualCost: 1600.0,
        isPaid: true,
        paymentDate: DateTime(2023, 4, 20),
        notes: '50 guests',
        vendorName: 'Party Catering',
        vendorContact: 'info@partycatering.com',
        dueDate: DateTime(2023, 4, 20),
        isBooked: true,
      ),
      BudgetItem(
        id: 'budget_item_12',
        categoryId: 'category_4',
        description: 'Decorations',
        estimatedCost: 500.0,
        actualCost: 450.0,
        isPaid: true,
        paymentDate: DateTime(2023, 4, 25),
        notes: 'Balloons, banners, and table settings',
        vendorName: 'Party Supplies',
        vendorContact: 'info@partysupplies.com',
        dueDate: DateTime(2023, 4, 25),
        isBooked: true,
      ),
      BudgetItem(
        id: 'budget_item_13',
        categoryId: 'category_5',
        description: 'DJ',
        estimatedCost: 500.0,
        actualCost: null,
        isPaid: false,
        notes: '4 hours of music',
        vendorName: 'Party DJs',
        vendorContact: 'bookings@partydjs.com',
        dueDate: DateTime(2023, 5, 1),
        isBooked: true,
      ),
    ];
  }
}
