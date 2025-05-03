import 'package:flutter/material.dart';
import 'package:eventati_book/models/venue.dart';
import 'package:eventati_book/models/catering_service.dart';
import 'package:eventati_book/models/photographer.dart';
import 'package:eventati_book/models/planner.dart';

/// Provider to manage services selected for comparison
class ComparisonProvider extends ChangeNotifier {
  // Maps to store selected services by type
  final Map<String, List<dynamic>> _selectedServices = {
    'Venue': <Venue>[],
    'Catering': <CateringService>[],
    'Photographer': <Photographer>[],
    'Planner': <Planner>[],
  };

  // Maximum number of items that can be compared
  static const int maxComparisonItems = 3;

  // Getters for selected services
  List<Venue> get selectedVenues => List<Venue>.from(_selectedServices['Venue']!);
  List<CateringService> get selectedCateringServices => 
      List<CateringService>.from(_selectedServices['Catering']!);
  List<Photographer> get selectedPhotographers => 
      List<Photographer>.from(_selectedServices['Photographer']!);
  List<Planner> get selectedPlanners => 
      List<Planner>.from(_selectedServices['Planner']!);

  /// Check if a service is selected for comparison
  bool isServiceSelected(dynamic service) {
    if (service is Venue) {
      return selectedVenues.any((venue) => venue.name == service.name);
    } else if (service is CateringService) {
      return selectedCateringServices.any(
          (cateringService) => cateringService.name == service.name);
    } else if (service is Photographer) {
      return selectedPhotographers.any(
          (photographer) => photographer.name == service.name);
    } else if (service is Planner) {
      return selectedPlanners.any((planner) => planner.name == service.name);
    }
    return false;
  }

  /// Toggle service selection for comparison
  void toggleServiceSelection(dynamic service) {
    if (service is Venue) {
      _toggleSelection('Venue', service);
    } else if (service is CateringService) {
      _toggleSelection('Catering', service);
    } else if (service is Photographer) {
      _toggleSelection('Photographer', service);
    } else if (service is Planner) {
      _toggleSelection('Planner', service);
    }
  }

  /// Helper method to toggle selection
  void _toggleSelection(String serviceType, dynamic service) {
    final List<dynamic> selectedList = _selectedServices[serviceType]!;
    
    if (isServiceSelected(service)) {
      // Remove service if already selected
      if (serviceType == 'Venue') {
        selectedList.removeWhere(
            (venue) => (venue as Venue).name == (service as Venue).name);
      } else if (serviceType == 'Catering') {
        selectedList.removeWhere((cateringService) => 
            (cateringService as CateringService).name == 
            (service as CateringService).name);
      } else if (serviceType == 'Photographer') {
        selectedList.removeWhere((photographer) => 
            (photographer as Photographer).name == 
            (service as Photographer).name);
      } else if (serviceType == 'Planner') {
        selectedList.removeWhere((planner) => 
            (planner as Planner).name == (service as Planner).name);
      }
    } else {
      // Add service if not already selected and under max limit
      if (selectedList.length < maxComparisonItems) {
        selectedList.add(service);
      }
    }
    
    notifyListeners();
  }

  /// Clear all selections for a specific service type
  void clearSelections(String serviceType) {
    if (_selectedServices.containsKey(serviceType)) {
      _selectedServices[serviceType]!.clear();
      notifyListeners();
    }
  }

  /// Clear all selections across all service types
  void clearAllSelections() {
    _selectedServices.forEach((key, value) {
      value.clear();
    });
    notifyListeners();
  }

  /// Check if comparison is available for a service type (at least 2 items selected)
  bool canCompare(String serviceType) {
    return _selectedServices.containsKey(serviceType) && 
           _selectedServices[serviceType]!.length >= 2;
  }

  /// Get the count of selected services by type
  int getSelectedCount(String serviceType) {
    return _selectedServices.containsKey(serviceType) ? 
           _selectedServices[serviceType]!.length : 0;
  }
}
