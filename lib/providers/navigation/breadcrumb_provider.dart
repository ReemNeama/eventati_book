import 'package:flutter/material.dart';

/// Represents a single breadcrumb in the navigation path
class BreadcrumbItem {
  /// The label to display for this breadcrumb
  final String label;
  
  /// The route name to navigate to when this breadcrumb is tapped
  final String routeName;
  
  /// Optional arguments to pass to the route
  final Object? arguments;
  
  /// Constructor
  const BreadcrumbItem({
    required this.label,
    required this.routeName,
    this.arguments,
  });
}

/// Provider for managing breadcrumb navigation state
class BreadcrumbProvider extends ChangeNotifier {
  /// The current breadcrumb path
  List<BreadcrumbItem> _breadcrumbs = [];
  
  /// Get the current breadcrumb path
  List<BreadcrumbItem> get breadcrumbs => _breadcrumbs;
  
  /// Set the breadcrumb path
  void setBreadcrumbs(List<BreadcrumbItem> breadcrumbs) {
    _breadcrumbs = breadcrumbs;
    notifyListeners();
  }
  
  /// Add a breadcrumb to the path
  void addBreadcrumb(BreadcrumbItem breadcrumb) {
    _breadcrumbs.add(breadcrumb);
    notifyListeners();
  }
  
  /// Remove the last breadcrumb from the path
  void removeLastBreadcrumb() {
    if (_breadcrumbs.isNotEmpty) {
      _breadcrumbs.removeLast();
      notifyListeners();
    }
  }
  
  /// Clear the breadcrumb path
  void clearBreadcrumbs() {
    _breadcrumbs = [];
    notifyListeners();
  }
  
  /// Navigate to a specific breadcrumb in the path
  /// This will remove all breadcrumbs after the selected one
  void navigateToBreadcrumb(int index) {
    if (index >= 0 && index < _breadcrumbs.length) {
      _breadcrumbs = _breadcrumbs.sublist(0, index + 1);
      notifyListeners();
    }
  }
}
