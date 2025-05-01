import 'package:flutter/material.dart';
import 'package:eventati_book/models/budget_item.dart';

class BudgetProvider extends ChangeNotifier {
  final String eventId;
  List<BudgetCategory> _categories = [];
  List<BudgetItem> _items = [];
  bool _isLoading = false;
  String? _error;

  BudgetProvider({required this.eventId}) {
    _loadBudget();
  }

  // Getters
  List<BudgetCategory> get categories => _categories;
  List<BudgetItem> get items => _items;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Calculated properties
  double get totalEstimated => _items.fold(0, (sum, item) => sum + item.estimatedCost);
  double get totalActual => _items.fold(0, (sum, item) => sum + (item.actualCost ?? 0));
  double get totalPaid => _items.where((item) => item.isPaid).fold(0, (sum, item) => sum + (item.actualCost ?? 0));
  double get totalRemaining => totalEstimated - totalPaid;

  // Get items by category
  List<BudgetItem> getItemsByCategory(String categoryId) {
    return _items.where((item) => item.categoryId == categoryId).toList();
  }

  // Calculate totals by category
  Map<String, double> getCategoryTotals() {
    final Map<String, double> totals = {};
    for (final category in _categories) {
      final categoryItems = getItemsByCategory(category.id);
      totals[category.id] = categoryItems.fold(0, (sum, item) => sum + item.estimatedCost);
    }
    return totals;
  }

  // CRUD operations
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

  // Mock data for testing
  void _loadMockData() {
    _categories = [
      BudgetCategory(id: '1', name: 'Venue', icon: Icons.location_on),
      BudgetCategory(id: '2', name: 'Catering', icon: Icons.restaurant),
      BudgetCategory(id: '3', name: 'Photography', icon: Icons.camera_alt),
      BudgetCategory(id: '4', name: 'Decoration', icon: Icons.celebration),
      BudgetCategory(id: '5', name: 'Entertainment', icon: Icons.music_note),
      BudgetCategory(id: '6', name: 'Attire', icon: Icons.checkroom),
      BudgetCategory(id: '7', name: 'Transportation', icon: Icons.directions_car),
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
