import 'package:flutter/material.dart';
import 'package:eventati_book/models/models.dart';

/// Provider for managing budget planning and tracking for an event.
///
/// The BudgetProvider is responsible for:
/// * Managing budget categories and items
/// * Calculating budget totals and summaries
/// * Tracking estimated vs. actual costs
/// * Monitoring payment status of budget items
/// * Providing category-based budget analysis
///
/// Each event has its own budget, identified by the eventId.
/// This provider currently uses mock data, but would connect to a
/// database or API in a production environment.
///
/// Usage example:
/// ```dart
/// // Create a provider for a specific event
/// final budgetProvider = BudgetProvider(eventId: 'event123');
///
/// // Access the provider from the widget tree
/// final budgetProvider = Provider.of<BudgetProvider>(context);
///
/// // Get budget summary information
/// final totalEstimated = budgetProvider.totalEstimated;
/// final totalActual = budgetProvider.totalActual;
/// final totalPaid = budgetProvider.totalPaid;
/// final totalRemaining = budgetProvider.totalRemaining;
///
/// // Get items for a specific category
/// final venueItems = budgetProvider.getItemsByCategory('venue');
///
/// // Add a new budget item
/// final newItem = BudgetItem(
///   id: 'item1',
///   categoryId: 'venue',
///   description: 'Venue deposit',
///   estimatedCost: 1000,
///   actualCost: 1000,
///   isPaid: true,
///   paymentDate: DateTime.now(),
/// );
/// await budgetProvider.addBudgetItem(newItem);
/// ```
class BudgetProvider extends ChangeNotifier {
  /// The unique identifier of the event this budget belongs to
  final String eventId;

  /// List of budget categories (e.g., Venue, Catering, Photography)
  List<BudgetCategory> _categories = [];

  /// List of budget items (individual expenses)
  List<BudgetItem> _items = [];

  /// Flag indicating if the provider is currently loading data
  bool _isLoading = false;

  /// Error message if an operation fails
  String? _error;

  /// Creates a new BudgetProvider for the specified event
  ///
  /// Automatically loads budget data when instantiated
  BudgetProvider({required this.eventId}) {
    _loadBudget();
  }

  /// Returns the list of budget categories
  List<BudgetCategory> get categories => _categories;

  /// Returns the list of all budget items
  List<BudgetItem> get items => _items;

  /// Indicates if the provider is currently loading data
  bool get isLoading => _isLoading;

  /// Returns the error message if an operation has failed, null otherwise
  String? get error => _error;

  /// The total estimated cost of all budget items
  double get totalEstimated =>
      _items.fold(0, (sum, item) => sum + item.estimatedCost);

  /// The total actual cost of all budget items (uses 0 for items without an actual cost)
  double get totalActual =>
      _items.fold(0, (sum, item) => sum + (item.actualCost ?? 0));

  /// The total amount paid (sum of actual costs for items marked as paid)
  double get totalPaid => _items
      .where((item) => item.isPaid)
      .fold(0, (sum, item) => sum + (item.actualCost ?? 0));

  /// The remaining amount to be paid (estimated total minus amount paid)
  double get totalRemaining => totalEstimated - totalPaid;

  /// Returns all budget items belonging to the specified category
  ///
  /// [categoryId] The ID of the category to filter by
  List<BudgetItem> getItemsByCategory(String categoryId) {
    return _items.where((item) => item.categoryId == categoryId).toList();
  }

  /// Calculates the total estimated cost for each budget category
  ///
  /// Returns a map where the keys are category IDs and the values are the total estimated costs
  Map<String, double> getCategoryTotals() {
    final Map<String, double> totals = {};
    for (final category in _categories) {
      final categoryItems = getItemsByCategory(category.id);
      totals[category.id] = categoryItems.fold(
        0,
        (sum, item) => sum + item.estimatedCost,
      );
    }
    return totals;
  }

  /// Loads the budget data for the event
  ///
  /// This is called automatically when the provider is created.
  /// In a real application, this would fetch data from a database or API.
  /// Currently uses mock data for demonstration purposes.
  Future<void> _loadBudget() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // In a real app, this would load from a database or API
      // For now, we'll use mock data
      await Future.delayed(const Duration(milliseconds: 500));
      _loadMockData();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  /// Adds a new budget item to the budget
  ///
  /// [item] The budget item to add
  ///
  /// In a real application, this would persist the item to a database or API.
  /// Notifies listeners when the operation completes.
  Future<void> addBudgetItem(BudgetItem item) async {
    _isLoading = true;
    notifyListeners();

    try {
      // In a real app, this would save to a database or API
      await Future.delayed(const Duration(milliseconds: 300));
      _items.add(item);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  /// Updates an existing budget item
  ///
  /// [item] The updated budget item (must have the same ID as an existing item)
  ///
  /// In a real application, this would update the item in a database or API.
  /// Notifies listeners when the operation completes.
  Future<void> updateBudgetItem(BudgetItem item) async {
    _isLoading = true;
    notifyListeners();

    try {
      // In a real app, this would update in a database or API
      await Future.delayed(const Duration(milliseconds: 300));
      final index = _items.indexWhere((i) => i.id == item.id);
      if (index >= 0) {
        _items[index] = item;
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  /// Deletes a budget item from the budget
  ///
  /// [itemId] The ID of the budget item to delete
  ///
  /// In a real application, this would delete the item from a database or API.
  /// Notifies listeners when the operation completes.
  Future<void> deleteBudgetItem(String itemId) async {
    _isLoading = true;
    notifyListeners();

    try {
      // In a real app, this would delete from a database or API
      await Future.delayed(const Duration(milliseconds: 300));
      _items.removeWhere((item) => item.id == itemId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  /// Loads mock data for testing and demonstration purposes
  ///
  /// This method creates sample budget categories and items.
  /// In a real application, this would be replaced with data from a database or API.
  void _loadMockData() {
    _categories = [
      BudgetCategory(id: '1', name: 'Venue', icon: Icons.location_on),
      BudgetCategory(id: '2', name: 'Catering', icon: Icons.restaurant),
      BudgetCategory(id: '3', name: 'Photography', icon: Icons.camera_alt),
      BudgetCategory(id: '4', name: 'Decoration', icon: Icons.celebration),
      BudgetCategory(id: '5', name: 'Entertainment', icon: Icons.music_note),
      BudgetCategory(id: '6', name: 'Attire', icon: Icons.checkroom),
      BudgetCategory(
        id: '7',
        name: 'Transportation',
        icon: Icons.directions_car,
      ),
      BudgetCategory(id: '8', name: 'Miscellaneous', icon: Icons.more_horiz),
    ];

    _items = [
      BudgetItem(
        id: '1',
        categoryId: '1',
        description: 'Venue rental',
        estimatedCost: 5000,
        actualCost: 5200,
        isPaid: true,
        paymentDate: DateTime.now().subtract(const Duration(days: 30)),
      ),
      BudgetItem(
        id: '2',
        categoryId: '2',
        description: 'Catering service',
        estimatedCost: 3500,
        actualCost: 3600,
        isPaid: false,
      ),
      BudgetItem(
        id: '3',
        categoryId: '3',
        description: 'Photographer',
        estimatedCost: 2000,
        actualCost: 2000,
        isPaid: true,
        paymentDate: DateTime.now().subtract(const Duration(days: 15)),
      ),
    ];
  }
}
