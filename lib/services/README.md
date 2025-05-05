# Services Directory

This directory contains service classes that handle business logic and data operations for the Eventati Book application.

## Purpose

Services in this application are responsible for:
- Providing data to the UI layer
- Processing business logic
- Connecting to external data sources (will be replaced with Firebase in the future)
- Implementing reusable functionality across the application

## Current Services

- **task_template_service.dart**: Manages task templates for different event types
  - Creates default task lists for various event types
  - Provides methods to customize task templates

- **wizard_connection_service.dart**: Connects the event wizard to other planning tools
  - Transfers data from completed wizard to planning tools
  - Initializes planning tools with event-specific data

## Future Services

When Firebase is implemented, the following services will be added:
- **AuthService**: Handle user authentication
- **EventService**: Manage event data
- **BookingService**: Handle service bookings
- **NotificationService**: Manage user notifications
- **StorageService**: Handle file uploads and storage

## Usage Guidelines

1. **Service Naming**: Use the suffix "Service" for all service classes (e.g., `TaskTemplateService`)
2. **Responsibility**: Each service should have a single responsibility
3. **Dependency Injection**: Services should be easily injectable into providers
4. **Error Handling**: Implement proper error handling in all service methods
5. **Documentation**: Document all public methods with clear descriptions

## Example Usage

```dart
// Using the TaskTemplateService
final tasks = TaskTemplateService.getTasksForEventType('wedding');

// Using the WizardConnectionService
WizardConnectionService.connectWizardToPlanning(wizardState);
```

## Integration with Providers

Services should be used by providers to separate business logic from state management:

```dart
class TaskProvider extends ChangeNotifier {
  List<Task> _tasks = [];
  
  void loadTasksForEvent(String eventType) {
    _tasks = TaskTemplateService.getTasksForEventType(eventType);
    notifyListeners();
  }
}
```
