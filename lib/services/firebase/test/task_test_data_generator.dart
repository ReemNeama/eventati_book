import 'package:eventati_book/models/models.dart';
import 'package:eventati_book/providers/planning_providers/task_provider.dart';
import 'package:eventati_book/services/firebase/firestore/task_firestore_service.dart';
import 'package:eventati_book/utils/logger.dart';
import 'package:flutter/material.dart';

/// Utility for creating test data in Firestore
class TaskTestDataGenerator {
  /// Task Firestore service
  final TaskFirestoreService _taskFirestoreService;

  /// Constructor
  TaskTestDataGenerator({TaskFirestoreService? taskFirestoreService})
    : _taskFirestoreService = taskFirestoreService ?? TaskFirestoreService();

  /// Create test data for an event
  ///
  /// [eventId] The ID of the event
  Future<void> createTestData(String eventId) async {
    try {
      // Create categories
      final venueCategory = TaskCategory(
        id: 'temp_1',
        name: 'Venue',
        icon: Icons.location_on,
        color: Colors.blue,
      );
      final cateringCategory = TaskCategory(
        id: 'temp_2',
        name: 'Catering',
        icon: Icons.restaurant,
        color: Colors.orange,
      );
      final invitationsCategory = TaskCategory(
        id: 'temp_3',
        name: 'Invitations',
        icon: Icons.mail,
        color: Colors.green,
      );
      final decorationsCategory = TaskCategory(
        id: 'temp_4',
        name: 'Decorations',
        icon: Icons.celebration,
        color: Colors.purple,
      );

      final venueCategoryId = await _taskFirestoreService.addTaskCategory(
        eventId,
        venueCategory,
      );
      final cateringCategoryId = await _taskFirestoreService.addTaskCategory(
        eventId,
        cateringCategory,
      );
      final invitationsCategoryId = await _taskFirestoreService.addTaskCategory(
        eventId,
        invitationsCategory,
      );
      final decorationsCategoryId = await _taskFirestoreService.addTaskCategory(
        eventId,
        decorationsCategory,
      );

      // Create tasks
      final now = DateTime.now();

      final bookVenueTask = Task(
        id: 'temp_1',
        title: 'Book venue',
        description: 'Find and book the perfect venue for the event',
        dueDate: now.add(const Duration(days: 90)),
        status: TaskStatus.notStarted,
        categoryId: venueCategoryId,
        isImportant: true,
        priority: TaskPriority.high,
      );

      final selectCateringTask = Task(
        id: 'temp_2',
        title: 'Select catering menu',
        description: 'Choose menu items and confirm with caterer',
        dueDate: now.add(const Duration(days: 60)),
        status: TaskStatus.notStarted,
        categoryId: cateringCategoryId,
        priority: TaskPriority.medium,
      );

      final sendInvitationsTask = Task(
        id: 'temp_3',
        title: 'Send invitations',
        description: 'Finalize guest list and send out invitations',
        dueDate: now.add(const Duration(days: 45)),
        status: TaskStatus.notStarted,
        categoryId: invitationsCategoryId,
        isImportant: true,
        priority: TaskPriority.high,
      );

      final orderFlowersTask = Task(
        id: 'temp_4',
        title: 'Order flowers',
        description: 'Select and order flowers for the event',
        dueDate: now.add(const Duration(days: 30)),
        status: TaskStatus.notStarted,
        categoryId: decorationsCategoryId,
        priority: TaskPriority.low,
      );

      final bookVenueTaskId = await _taskFirestoreService.addTask(
        eventId,
        bookVenueTask,
      );
      final selectCateringTaskId = await _taskFirestoreService.addTask(
        eventId,
        selectCateringTask,
      );
      final sendInvitationsTaskId = await _taskFirestoreService.addTask(
        eventId,
        sendInvitationsTask,
      );
      await _taskFirestoreService.addTask(eventId, orderFlowersTask);

      // Create dependencies
      await _taskFirestoreService.addTaskDependency(
        eventId,
        TaskDependency(
          prerequisiteTaskId: bookVenueTaskId,
          dependentTaskId: selectCateringTaskId,
        ),
      );

      await _taskFirestoreService.addTaskDependency(
        eventId,
        TaskDependency(
          prerequisiteTaskId: bookVenueTaskId,
          dependentTaskId: sendInvitationsTaskId,
        ),
      );
    } catch (e) {
      Logger.e('Error creating test data: $e', tag: 'TaskTestDataGenerator');
      rethrow;
    }
  }
}
