# Task Dependency Example

This document provides a simple example of how to use the task dependency functionality in the Eventati Book application.

## Creating Task Dependencies

### Using the TaskProvider

```dart
// Get the TaskProvider
final taskProvider = Provider.of<TaskProvider>(context, listen: false);

// Add a dependency between two tasks
final success = await taskProvider.addDependency('task1', 'task2');

// Check if the dependency was added successfully
if (success) {
  print('Dependency added successfully');
} else {
  print('Failed to add dependency');
}
```

### Using the TaskDatabaseService Directly

```dart
// Get the TaskDatabaseService
final taskDatabaseService = serviceLocator.get<TaskDatabaseService>();

// Create a dependency object
final dependency = TaskDependency(
  prerequisiteTaskId: 'task1',
  dependentTaskId: 'task2',
);

// Add the dependency to the database
await taskDatabaseService.addTaskDependency('event1', dependency);
```

## Removing Task Dependencies

### Using the TaskProvider

```dart
// Get the TaskProvider
final taskProvider = Provider.of<TaskProvider>(context, listen: false);

// Remove a dependency between two tasks
final success = await taskProvider.removeDependency('task1', 'task2');

// Check if the dependency was removed successfully
if (success) {
  print('Dependency removed successfully');
} else {
  print('Failed to remove dependency');
}
```

### Using the TaskDatabaseService Directly

```dart
// Get the TaskDatabaseService
final taskDatabaseService = serviceLocator.get<TaskDatabaseService>();

// Remove the dependency from the database
await taskDatabaseService.removeTaskDependency('event1', 'task1', 'task2');
```

## Getting Task Dependencies

### Using the TaskProvider

```dart
// Get the TaskProvider
final taskProvider = Provider.of<TaskProvider>(context, listen: false);

// Get tasks that depend on a specific task
final dependentTasks = taskProvider.getDependentTasks('task1');

// Get tasks that a specific task depends on
final prerequisiteTasks = taskProvider.getPrerequisiteTasks('task2');
```

### Using the TaskDatabaseService Directly

```dart
// Get the TaskDatabaseService
final taskDatabaseService = serviceLocator.get<TaskDatabaseService>();

// Get all dependencies for an event
final dependencies = await taskDatabaseService.getTaskDependencies('event1');

// Get a stream of dependencies for an event
final dependenciesStream = taskDatabaseService.getTaskDependenciesStream('event1');
```

## Checking for Circular Dependencies

The `TaskProvider` automatically checks for circular dependencies when adding a new dependency:

```dart
// This method is called internally by the TaskProvider
bool _wouldCreateCircularDependency(
  String prerequisiteTaskId,
  String dependentTaskId,
) {
  // If the dependent task is already a prerequisite for the prerequisite task,
  // this would create a circular dependency
  final visited = <String>{};
  final toVisit = <String>[dependentTaskId];

  while (toVisit.isNotEmpty) {
    final current = toVisit.removeLast();
    visited.add(current);

    final dependents = getDependentTasks(current);

    // If any dependent is the prerequisite, we have a cycle
    if (dependents.contains(prerequisiteTaskId)) {
      return true;
    }

    // Add unvisited dependents to the queue
    for (final dependent in dependents) {
      if (!visited.contains(dependent)) {
        toVisit.add(dependent);
      }
    }
  }

  return false;
}
```

## UI Example

The `TaskDependencyScreen` provides a user interface for managing task dependencies:

```dart
// Navigate to the TaskDependencyScreen
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => TaskDependencyScreen(eventId: 'event1'),
  ),
);
```

The screen allows users to:

1. View existing dependencies in a list or graph view
2. Add new dependencies by selecting prerequisite and dependent tasks
3. Remove existing dependencies

## Complete Example

For a complete example of how to use the task dependency functionality, see the `TaskDependencyExample` class in the `lib/examples/task_dependency_example.dart` file.
