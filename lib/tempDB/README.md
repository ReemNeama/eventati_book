# Temporary Database

This folder contains temporary mock data for the application. In a production environment, this data would be replaced with API calls to a backend server.

## Structure

- `venues.dart`: Mock data for venues
- `services.dart`: Mock data for services (catering, photography, etc.)
- `events.dart`: Mock data for events
- `users.dart`: Mock data for users
- `budget.dart`: Mock data for budget items
- `guests.dart`: Mock data for guest list
- `tasks.dart`: Mock data for tasks and checklists
- `messages.dart`: Mock data for vendor messages

## Usage

Import the appropriate file to access mock data:

```dart
import 'package:eventati_book/tempDB/venues.dart';

// Use the mock data
final venues = VenueDB.getVenues();
```

## Future API Replacement

When replacing with actual API calls:

1. Create a service class for each data type (e.g., `VenueService`)
2. Implement methods with the same signatures as the mock data methods
3. Replace imports in the codebase from tempDB to services

Example:

```dart
// Before
import 'package:eventati_book/tempDB/venues.dart';
final venues = VenueDB.getVenues();

// After
import 'package:eventati_book/services/venue_service.dart';
final venues = await VenueService.getVenues();
```
