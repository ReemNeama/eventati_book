import 'package:eventati_book/providers/planning_providers/task_provider.dart';
import 'package:eventati_book/services/supabase/test/task_test_data_generator.dart';
import 'package:eventati_book/styles/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Screen for testing Supabase integration with tasks
class TaskDatabaseTestScreen extends StatefulWidget {
  /// The ID of the event
  final String eventId;

  /// Creates a new task database test screen
  const TaskDatabaseTestScreen({super.key, required this.eventId});

  @override
  State<TaskDatabaseTestScreen> createState() => _TaskDatabaseTestScreenState();
}

class _TaskDatabaseTestScreenState extends State<TaskDatabaseTestScreen> {
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

  Future<void> _syncExistingData() async {
    setState(() {
      _isLoading = true;
      _message = 'Syncing existing data...';
    });

    try {
      // Get existing data from the provider
      final taskProvider = Provider.of<TaskProvider>(context, listen: false);

      // Force a sync of all tasks to Supabase
      for (final task in taskProvider.tasks) {
        await taskProvider.updateTask(task);
      }

      setState(() {
        _isLoading = false;
        _message = 'Data synced successfully!';
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _message = 'Error syncing data: ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Database Test'),
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
              onPressed: _isLoading ? null : _syncExistingData,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text('Sync Existing Data'),
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
