# Task Dependency System

This document provides an overview of the task dependency system in the Eventati Book application.

## Overview

The task dependency system allows users to create dependencies between tasks, where one task must be completed before another can be started. This is useful for creating a logical sequence of tasks for event planning.

## Components

The task dependency system consists of the following components:

1. **Models**:
   - `TaskDependency`: Represents a dependency between two tasks.
   - `Task`: Contains a list of dependencies.

2. **Services**:
   - `TaskDatabaseService`: Handles database operations for tasks and dependencies.

3. **Providers**:
   - `TaskProvider`: Manages the state of tasks and dependencies.

4. **UI**:
   - `TaskDependencyScreen`: Allows users to view, add, and remove dependencies.
   - `DependencyGraph`: Visualizes task dependencies as a graph.

## Data Model

### TaskDependency

The `TaskDependency` class represents a dependency between two tasks:

```dart
class TaskDependency {
  final String prerequisiteTaskId;
  final String dependentTaskId;
  final DependencyType type;
  final int offsetDays;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // Constructor and methods...
}
```

- `prerequisiteTaskId`: The ID of the task that must be completed first.
- `dependentTaskId`: The ID of the task that depends on the prerequisite.
- `type`: The type of dependency (finish-to-start, start-to-start, etc.).
- `offsetDays`: The number of days offset for the dependency.

### DependencyType

The `DependencyType` enum defines the types of dependencies:

```dart
enum DependencyType {
  finishToStart,  // The dependent task can start only after the prerequisite task finishes
  startToStart,   // The dependent task can start only after the prerequisite task starts
  finishToFinish, // The dependent task can finish only after the prerequisite task finishes
  startToFinish,  // The dependent task can finish only after the prerequisite task starts
}
```

## Database Schema

Task dependencies are stored in the `task_dependencies` table in Supabase with the following structure:

| Column                | Type      | Description                               |
|-----------------------|-----------|-------------------------------------------|
| prerequisite_task_id  | string    | ID of the prerequisite task               |
| dependent_task_id     | string    | ID of the dependent task                  |
| event_id              | string    | ID of the event the tasks belong to       |
| type                  | integer   | Type of dependency (enum index)           |
| offset_days           | integer   | Number of days offset                     |
| created_at            | timestamp | When the dependency was created           |
| updated_at            | timestamp | When the dependency was last updated      |

## Service Methods

The `TaskDatabaseService` provides the following methods for working with task dependencies:

### getTaskDependencies

```dart
Future<List<TaskDependency>> getTaskDependencies(String eventId)
```

Retrieves all task dependencies for a specific event.

### getTaskDependenciesStream

```dart
Stream<List<TaskDependency>> getTaskDependenciesStream(String eventId)
```

Returns a stream of task dependencies for a specific event, which updates in real-time when dependencies change.

### addTaskDependency

```dart
Future<void> addTaskDependency(String eventId, TaskDependency dependency)
```

Adds a new dependency between two tasks.

### removeTaskDependency

```dart
Future<void> removeTaskDependency(String eventId, String prerequisiteTaskId, String dependentTaskId)
```

Removes a dependency between two tasks.

## Provider Methods

The `TaskProvider` provides the following methods for working with task dependencies:

### addDependency

```dart
Future<bool> addDependency(String prerequisiteTaskId, String dependentTaskId)
```

Adds a dependency between two tasks, with validation to prevent circular dependencies.

### removeDependency

```dart
Future<bool> removeDependency(String prerequisiteTaskId, String dependentTaskId)
```

Removes a dependency between two tasks.

### getPrerequisiteTasks

```dart
List<String> getPrerequisiteTasks(String taskId)
```

Returns a list of task IDs that the specified task depends on.

### getDependentTasks

```dart
List<String> getDependentTasks(String taskId)
```

Returns a list of task IDs that depend on the specified task.

## UI Components

### TaskDependencyScreen

The `TaskDependencyScreen` allows users to:

1. View existing task dependencies in a list or graph view.
2. Add new dependencies by selecting prerequisite and dependent tasks.
3. Remove existing dependencies.

### DependencyGraph

The `DependencyGraph` widget visualizes task dependencies as a graph, with:

1. Tasks represented as nodes.
2. Dependencies represented as directed edges.
3. Interactive features like zooming and panning.
4. Task selection for adding new dependencies.

## Usage Example

```dart
// Get the TaskProvider
final taskProvider = Provider.of<TaskProvider>(context, listen: false);

// Add a dependency
final success = await taskProvider.addDependency('task1', 'task2');

// Check if the dependency was added successfully
if (success) {
  print('Dependency added successfully');
} else {
  print('Failed to add dependency');
}

// Get tasks that depend on a specific task
final dependentTasks = taskProvider.getDependentTasks('task1');

// Get tasks that a specific task depends on
final prerequisiteTasks = taskProvider.getPrerequisiteTasks('task2');

// Remove a dependency
await taskProvider.removeDependency('task1', 'task2');
```

## Circular Dependency Prevention

The system prevents circular dependencies by checking if adding a new dependency would create a cycle in the dependency graph. This is done using a depth-first search algorithm in the `_wouldCreateCircularDependency` method of the `TaskProvider` class.

## Conclusion

The task dependency system provides a robust way to manage dependencies between tasks in the event planning process. It ensures that tasks are completed in the correct order and provides visual feedback to users about the relationships between tasks.
