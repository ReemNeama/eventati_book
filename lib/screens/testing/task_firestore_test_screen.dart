import 'package:eventati_book/models/models.dart';
import 'package:eventati_book/providers/planning_providers/task_provider.dart';
import 'package:eventati_book/services/firebase/migration/task_migration_service.dart';
import 'package:eventati_book/services/firebase/test/task_test_data_generator.dart';
import 'package:eventati_book/styles/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Screen for testing Firestore integration with tasks
class TaskFirestoreTestScreen extends StatefulWidget {
  /// The ID of the event
  final String eventId;

  /// Creates a new task Firestore test screen
  const TaskFirestoreTestScreen({super.key, required this.eventId});

  @override
  State<TaskFirestoreTestScreen> createState() =>
      _TaskFirestoreTestScreenState();
}

class _TaskFirestoreTestScreenState extends State<TaskFirestoreTestScreen> {
  bool _isLoading = false;
  String? _message;

  Future<void> _createTestData() async {
    setState(() {
      _isLoading = true;
      _message = 'Creating test data...';
    });

    try {
      final generator = TaskTestDataGenerator();
      await generator.createTestData(widget.eventId);

      setState(() {
        _isLoading = false;
        _message = 'Test data created successfully!';
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _message = 'Error creating test data: ${e.toString()}';
      });
    }
  }

  Future<void> _migrateExistingData() async {
    setState(() {
      _isLoading = true;
      _message = 'Migrating existing data...';
    });

    try {
      // Get existing data from the provider
      final taskProvider = Provider.of<TaskProvider>(context, listen: false);
      final tasks = taskProvider.tasks;
      final categories = taskProvider.categories;
      final dependencies = taskProvider.dependencies;

      // Migrate data to Firestore
      final migrationService = TaskMigrationService();
      final success = await migrationService.migrateTaskData(
        widget.eventId,
        tasks,
        categories,
        dependencies,
      );

      setState(() {
        _isLoading = false;
        _message =
            success ? 'Data migrated successfully!' : 'Error migrating data.';
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _message = 'Error migrating data: ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Firestore Test'),
        backgroundColor: AppColors.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: _isLoading ? null : _createTestData,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text('Create Test Data'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isLoading ? null : _migrateExistingData,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text('Migrate Existing Data'),
            ),
            const SizedBox(height: 32),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_message != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _message!,
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
