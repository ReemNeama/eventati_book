# Eventati Book Service Comparison System

This document provides a comprehensive overview of the service comparison functionality in the Eventati Book application, including its architecture, components, data flow, and integration with other features.

## Service Comparison Overview

The service comparison system allows users to select multiple services of the same type (venues, catering services, photographers, or planners) and compare them side by side. This helps users make informed decisions by directly comparing features, pricing, and other important factors. The system also allows users to save comparisons for future reference.

## Comparison Flow Diagram

```
┌─────────────────────────────────────────────────────────────────────────┐
│                       SERVICE LISTING SCREEN                            │
└───────────────────────────────────┬─────────────────────────────────────┘
                                    │
                                    │ User selects services to compare
                                    ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                       COMPARISON BUTTON                                 │
│                                                                         │
│  ┌─────────────────────────────────────────────────────────────────┐    │
│  │  Compare Selected (3)                                           │    │
│  └─────────────────────────────────────────────────────────────────┘    │
└───────────────────────────────────┬─────────────────────────────────────┘
                                    │
                                    │ User taps comparison button
                                    ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                       SERVICE COMPARISON SCREEN                         │
│                                                                         │
│  ┌─────────────────────────────────────────────────────────────────┐    │
│  │  Tab Navigation                                                  │    │
│  │  - Overview                                                      │    │
│  │  - Features                                                      │    │
│  │  - Pricing                                                       │    │
│  └─────────────────────────────────────────────────────────────────┘    │
│                                                                         │
│  ┌─────────────────────────────────────────────────────────────────┐    │
│  │  Action Buttons                                                  │    │
│  │  - Save Comparison                                               │    │
│  │  - View Saved Comparisons                                        │    │
│  │  - Clear Selection                                               │    │
│  └─────────────────────────────────────────────────────────────────┘    │
└───────────────────────────────────┬─────────────────────────────────────┘
                                    │
                                    │ User navigates between tabs
                                    ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                       COMPARISON TABS                                   │
│                                                                         │
│  ┌─────────────────────────────────────────────────────────────────┐    │
│  │  OVERVIEW TAB                                                    │    │
│  │  - Service cards side by side                                    │    │
│  │  - Basic information for each service                            │    │
│  │  - Highlights best-rated service                                 │    │
│  └─────────────────────────────────────────────────────────────────┘    │
│                                                                         │
│  ┌─────────────────────────────────────────────────────────────────┐    │
│  │  FEATURES TAB                                                    │    │
│  │  - Feature comparison table                                      │    │
│  │  - Service-specific features                                     │    │
│  │  - Visual indicators for feature availability                    │    │
│  └─────────────────────────────────────────────────────────────────┘    │
│                                                                         │
│  ┌─────────────────────────────────────────────────────────────────┐    │
│  │  PRICING TAB                                                     │    │
│  │  - Price comparison table                                        │    │
│  │  - Base prices and package options                               │    │
│  │  - Additional costs                                              │    │
│  └─────────────────────────────────────────────────────────────────┘    │
└───────────────────────────────────┬─────────────────────────────────────┘
                                    │
                                    │ User taps "Save Comparison"
                                    ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                       SAVE COMPARISON DIALOG                            │
│                                                                         │
│  ┌─────────────────────────────────────────────────────────────────┐    │
│  │  Title Field                                                     │    │
│  └─────────────────────────────────────────────────────────────────┘    │
│                                                                         │
│  ┌─────────────────────────────────────────────────────────────────┐    │
│  │  Notes Field                                                     │    │
│  └─────────────────────────────────────────────────────────────────┘    │
│                                                                         │
│  ┌─────────────────────────────────────────────────────────────────┐    │
│  │  Event Association (optional)                                    │    │
│  └─────────────────────────────────────────────────────────────────┘    │
│                                                                         │
│  ┌─────────────────────────────────────────────────────────────────┐    │
│  │  Save Button                                                     │    │
│  └─────────────────────────────────────────────────────────────────┘    │
└───────────────────────────────────┬─────────────────────────────────────┘
                                    │
                                    │ User taps "View Saved Comparisons"
                                    ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                       SAVED COMPARISONS SCREEN                          │
│                                                                         │
│  ┌─────────────────────────────────────────────────────────────────┐    │
│  │  Filter and Sort Options                                         │    │
│  │  - Filter by service type                                        │    │
│  │  - Sort by date (newest/oldest)                                  │    │
│  └─────────────────────────────────────────────────────────────────┘    │
│                                                                         │
│  ┌─────────────────────────────────────────────────────────────────┐    │
│  │  Comparison Cards                                                │    │
│  │  - Title                                                         │    │
│  │  - Service type                                                  │    │
│  │  - Services being compared                                       │    │
│  │  - Date saved                                                    │    │
│  │  - Event association (if any)                                    │    │
│  │  - Action buttons (View, Edit, Delete)                           │    │
│  └─────────────────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────────────────┘
```

## Service Comparison Components

### Screens

1. **ServiceComparisonScreen**
   - Purpose: Compare selected services side by side
   - Key Features:
     - Tab navigation (Overview, Features, Pricing)
     - Service cards with key information
     - Feature comparison table
     - Pricing comparison table
     - Save comparison functionality
     - Navigation to saved comparisons

2. **SavedComparisonsScreen**
   - Purpose: Display and manage saved comparisons
   - Key Features:
     - Filter by service type
     - Sort by date
     - Comparison cards with summary information
     - View, edit, and delete actions
     - Responsive layout for different screen sizes

### Widgets

1. **ComparisonItemCard**
   - Purpose: Display a service card in the comparison overview
   - Key Features:
     - Service name and type
     - Rating display
     - Key features summary
     - Price information
     - Highlight for best-rated service

2. **FeatureComparisonTable**
   - Purpose: Display a table comparing features across services
   - Key Features:
     - Service-specific feature rows
     - Visual indicators for feature availability
     - Responsive layout for different screen sizes
     - Highlighting of differences

3. **PricingComparisonTable**
   - Purpose: Display a table comparing pricing across services
   - Key Features:
     - Base price comparison
     - Package options comparison
     - Additional costs comparison
     - Responsive layout for different screen sizes

### Models

1. **SavedComparison**
   - Core data model for saved comparison information
   - Properties:
     - id: Unique identifier
     - userId: User who created the comparison
     - serviceType: Type of services being compared
     - serviceIds: List of service IDs in the comparison
     - serviceNames: List of service names in the comparison
     - title: User-defined title for the comparison
     - notes: User-defined notes about the comparison
     - createdAt: Creation timestamp
     - eventId: Associated event (optional)
     - eventName: Associated event name (optional)

### Providers

1. **ComparisonProvider**
   - Purpose: Manage service selection for comparison
   - Key Responsibilities:
     - Track selected services by type
     - Add and remove services from selection
     - Clear selections
     - Check if a service is selected
     - Get count of selected services

2. **ComparisonSavingProvider**
   - Purpose: Manage saved comparisons
   - Key Responsibilities:
     - Save new comparisons
     - Retrieve saved comparisons
     - Update existing comparisons
     - Delete comparisons
     - Filter comparisons by service type
     - Sort comparisons by date
     - Handle errors

## Integration with Other Features

### Integration with Service Listings

- Services can be selected for comparison from service listing screens
- Selection state is maintained across navigation
- Comparison button appears when multiple services are selected

### Integration with Event Planning

- Comparisons can be associated with events
- Event details (name, ID) are stored with the comparison
- Comparisons can be accessed from event planning screens

### Integration with User Management

- User information is used to associate comparisons with users
- User ID is used for access control to saved comparisons
- User can view their saved comparisons

## Data Models

### SavedComparison Model

```dart
class SavedComparison {
  final String id;
  final String userId;
  final String serviceType;
  final List<String> serviceIds;
  final List<String> serviceNames;
  final String title;
  final String notes;
  final DateTime createdAt;
  final String? eventId;
  final String? eventName;

  // Constructor and other methods...
}
```

## Key Functionality

### Service Selection

The comparison system allows users to select multiple services of the same type for comparison. The selection state is managed by the ComparisonProvider:

```dart
void toggleServiceSelection(dynamic service, String serviceType) {
  switch (serviceType) {
    case 'Venue':
      if (service is Venue) {
        if (isVenueSelected(service)) {
          _selectedVenues.remove(service);
        } else {
          _selectedVenues.add(service);
        }
      }
      break;
    // Similar cases for other service types...
  }
  notifyListeners();
}
```

### Feature Comparison

The system dynamically generates a feature comparison table based on the service type. Different service types have different feature sets:

- **Venues**: Capacity, amenities, layout options, accessibility
- **Catering**: Menu options, dietary accommodations, service styles
- **Photography**: Package contents, equipment, delivery timeframes
- **Planners**: Services included, planning areas, experience

The FeatureComparisonTable widget handles the rendering of these comparisons with visual indicators for feature availability.

### Price Comparison

The system provides a detailed price comparison table that breaks down costs across services:

- Base prices
- Package options
- Additional services
- Per-person costs
- Minimum requirements

The PricingComparisonTable widget handles the rendering of these comparisons with clear formatting for monetary values.

### Saving Comparisons

Users can save comparisons for future reference. The saving process includes:

1. Capturing the current state of the comparison
2. Adding user-defined title and notes
3. Optionally associating with an event
4. Storing the comparison data

```dart
Future<bool> saveComparison({
  required String serviceType,
  required List<String> serviceIds,
  required List<String> serviceNames,
  required String title,
  required String notes,
  String? eventId,
  String? eventName,
}) async {
  try {
    // Create a unique ID for the comparison
    final id = const Uuid().v4();
    
    // Get the current user ID
    final userId = _authProvider.currentUser?.uid ?? '';
    
    // Create the saved comparison object
    final savedComparison = SavedComparison(
      id: id,
      userId: userId,
      serviceType: serviceType,
      serviceIds: serviceIds,
      serviceNames: serviceNames,
      title: title,
      notes: notes,
      createdAt: DateTime.now(),
      eventId: eventId,
      eventName: eventName,
    );
    
    // Save the comparison
    await _saveComparisonToStorage(savedComparison);
    
    // Refresh the list of saved comparisons
    await refreshData();
    
    return true;
  } catch (e) {
    _error = e.toString();
    return false;
  }
}
```

### Managing Saved Comparisons

The system provides functionality for managing saved comparisons:

- Viewing saved comparisons
- Editing comparison details (title, notes, event association)
- Deleting comparisons
- Filtering comparisons by service type
- Sorting comparisons by date

## Responsive Design

The comparison system is designed to be responsive across different screen sizes:

- On mobile devices, services are compared in a scrollable view
- On tablets and larger screens, services are displayed side by side
- Tables adapt their layout based on available space
- Filter and sort controls adjust for different screen sizes

## Future Enhancements

Planned enhancements for the comparison system include:

- Export comparisons to PDF or other formats
- Share comparisons with other users
- More advanced filtering and sorting options
- Visual charts for price and feature comparisons
- Integration with booking system for direct booking from comparison
- Comparison history tracking
- Automated recommendations based on user preferences
