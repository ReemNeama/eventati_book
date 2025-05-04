import 'package:flutter/material.dart';
import 'package:eventati_book/models/models.dart';

/// Provider for managing service comparison functionality.
///
/// The ComparisonProvider is responsible for:
/// * Tracking which services users have selected for comparison
/// * Managing selections across different service types (Venue, Catering, Photographer, Planner)
/// * Enforcing maximum comparison limits
/// * Providing methods to check if services are selected
/// * Enabling/disabling comparison functionality based on selection count
///
/// This provider allows users to select up to a maximum number of services
/// (defined by maxComparisonItems) for side-by-side comparison. It maintains
/// separate lists for each service type and provides methods to toggle selection,
/// clear selections, and check if comparison is available.
///
/// Usage example:
/// ```dart
/// // Access the provider from the widget tree
/// final comparisonProvider = Provider.of<ComparisonProvider>(context);
///
/// // Check if a venue is selected for comparison
/// final venue = Venue(...);
/// final isSelected = comparisonProvider.isServiceSelected(venue);
///
/// // Toggle selection status
/// comparisonProvider.toggleServiceSelection(venue);
///
/// // Get count of selected venues
/// final count = comparisonProvider.getSelectedCount('Venue');
///
/// // Check if venue comparison is available (at least 2 venues selected)
/// final canCompare = comparisonProvider.canCompare('Venue');
///
/// // Clear all venue selections
/// comparisonProvider.clearSelections('Venue');
///
/// // Use in a ListView to show selection status
/// ListView.builder(
///   itemCount: venues.length,
///   itemBuilder: (context, index) {
///     final venue = venues[index];
///     final isSelected = comparisonProvider.isServiceSelected(venue);
///
///     return VenueCard(
///       venue: venue,
///       isSelected: isSelected,
///       onCompareToggle: () {
///         comparisonProvider.toggleServiceSelection(venue);
///       },
///     );
///   },
/// )
/// ```
class ComparisonProvider extends ChangeNotifier {
  /// Map storing lists of selected services organized by service type
  ///
  /// This map contains separate lists for each service type (Venue, Catering,
  /// Photographer, Planner). Each list contains the services that have been
  /// selected for comparison.
  final Map<String, List<dynamic>> _selectedServices = {
    'Venue': <Venue>[],
    'Catering': <CateringService>[],
    'Photographer': <Photographer>[],
    'Planner': <Planner>[],
  };

  /// Maximum number of items that can be compared side-by-side
  ///
  /// This constant defines the upper limit for how many services of the same type
  /// can be selected for comparison at once. This helps ensure the comparison
  /// view remains usable and doesn't become too crowded.
  static const int maxComparisonItems = 3;

  /// Returns a list of venues currently selected for comparison
  ///
  /// This getter returns a new list to prevent direct modification of the
  /// internal list. Changes should only be made through the toggle methods.
  List<Venue> get selectedVenues =>
      List<Venue>.from(_selectedServices['Venue']!);

  /// Returns a list of catering services currently selected for comparison
  ///
  /// This getter returns a new list to prevent direct modification of the
  /// internal list. Changes should only be made through the toggle methods.
  List<CateringService> get selectedCateringServices =>
      List<CateringService>.from(_selectedServices['Catering']!);

  /// Returns a list of photographers currently selected for comparison
  ///
  /// This getter returns a new list to prevent direct modification of the
  /// internal list. Changes should only be made through the toggle methods.
  List<Photographer> get selectedPhotographers =>
      List<Photographer>.from(_selectedServices['Photographer']!);

  /// Returns a list of planners currently selected for comparison
  ///
  /// This getter returns a new list to prevent direct modification of the
  /// internal list. Changes should only be made through the toggle methods.
  List<Planner> get selectedPlanners =>
      List<Planner>.from(_selectedServices['Planner']!);

  /// Checks if a service is currently selected for comparison
  ///
  /// [service] The service to check (can be Venue, CateringService, Photographer, or Planner)
  ///
  /// This method determines if a specific service is currently in the selected list
  /// for its type. Services are matched by name to avoid duplicate selections.
  ///
  /// Returns true if the service is selected, false otherwise.
  /// Also returns false if the service type is not supported.
  bool isServiceSelected(dynamic service) {
    if (service is Venue) {
      return selectedVenues.any((venue) => venue.name == service.name);
    } else if (service is CateringService) {
      return selectedCateringServices.any(
        (cateringService) => cateringService.name == service.name,
      );
    } else if (service is Photographer) {
      return selectedPhotographers.any(
        (photographer) => photographer.name == service.name,
      );
    } else if (service is Planner) {
      return selectedPlanners.any((planner) => planner.name == service.name);
    }
    return false;
  }

  /// Toggles the selection status of a service for comparison
  ///
  /// [service] The service to toggle (can be Venue, CateringService, Photographer, or Planner)
  ///
  /// This method adds the service to the comparison list if it's not already selected,
  /// or removes it if it's already selected. It automatically determines the service type
  /// and delegates to the appropriate internal method.
  ///
  /// If adding a service would exceed maxComparisonItems, the service is not added.
  /// Notifies listeners when the selection changes.
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

  /// Internal helper method to toggle selection for a specific service type
  ///
  /// [serviceType] The type of service ('Venue', 'Catering', 'Photographer', 'Planner')
  /// [service] The service to toggle
  ///
  /// This private method handles the actual addition or removal of a service from
  /// the appropriate list. It ensures that:
  /// 1. Services are removed by matching names to avoid reference issues
  /// 2. New services are only added if under the maximum limit
  /// 3. The UI is updated via notifyListeners() after changes
  void _toggleSelection(String serviceType, dynamic service) {
    final List<dynamic> selectedList = _selectedServices[serviceType]!;

    if (isServiceSelected(service)) {
      // Remove service if already selected
      if (serviceType == 'Venue') {
        selectedList.removeWhere(
          (venue) => (venue as Venue).name == (service as Venue).name,
        );
      } else if (serviceType == 'Catering') {
        selectedList.removeWhere(
          (cateringService) =>
              (cateringService as CateringService).name ==
              (service as CateringService).name,
        );
      } else if (serviceType == 'Photographer') {
        selectedList.removeWhere(
          (photographer) =>
              (photographer as Photographer).name ==
              (service as Photographer).name,
        );
      } else if (serviceType == 'Planner') {
        selectedList.removeWhere(
          (planner) => (planner as Planner).name == (service as Planner).name,
        );
      }
    } else {
      // Add service if not already selected and under max limit
      if (selectedList.length < maxComparisonItems) {
        selectedList.add(service);
      }
    }

    notifyListeners();
  }

  /// Clears all selections for a specific service type
  ///
  /// [serviceType] The type of service to clear ('Venue', 'Catering', 'Photographer', 'Planner')
  ///
  /// This method removes all selected services of the specified type from the comparison.
  /// It's useful when users want to start over with their selections for a particular
  /// service category.
  ///
  /// If the serviceType is invalid or not found, no action is taken.
  /// Notifies listeners when selections are cleared.
  void clearSelections(String serviceType) {
    if (_selectedServices.containsKey(serviceType)) {
      _selectedServices[serviceType]!.clear();
      notifyListeners();
    }
  }

  /// Clears all selections across all service types
  ///
  /// This method removes all selected services from all categories, effectively
  /// resetting the comparison state completely. It's useful when users want to
  /// start fresh with their comparisons.
  ///
  /// Notifies listeners when all selections are cleared.
  void clearAllSelections() {
    _selectedServices.forEach((key, value) {
      value.clear();
    });
    notifyListeners();
  }

  /// Checks if comparison is available for a service type
  ///
  /// [serviceType] The type of service to check ('Venue', 'Catering', 'Photographer', 'Planner')
  ///
  /// This method determines if there are enough services selected of a particular type
  /// to enable a meaningful comparison. A minimum of 2 services must be selected to
  /// enable comparison functionality.
  ///
  /// Returns true if comparison is available (at least 2 items selected), false otherwise.
  /// Also returns false if the serviceType is invalid or not found.
  bool canCompare(String serviceType) {
    return _selectedServices.containsKey(serviceType) &&
        _selectedServices[serviceType]!.length >= 2;
  }

  /// Gets the count of selected services for a specific type
  ///
  /// [serviceType] The type of service to count ('Venue', 'Catering', 'Photographer', 'Planner')
  ///
  /// This method returns the number of services currently selected for the specified type.
  /// It's useful for UI elements that need to display selection counts or enforce limits.
  ///
  /// Returns the number of selected services, or 0 if the serviceType is invalid or not found.
  int getSelectedCount(String serviceType) {
    return _selectedServices.containsKey(serviceType)
        ? _selectedServices[serviceType]!.length
        : 0;
  }
}
