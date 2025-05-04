import 'package:flutter/material.dart';
import 'package:eventati_book/providers/task_provider.dart';
import 'package:eventati_book/models/models.dart';
import 'package:eventati_book/utils/utils.dart';
import 'package:eventati_book/styles/app_colors.dart';
import 'package:eventati_book/styles/app_colors_dark.dart';
import 'package:intl/intl.dart';

class TaskFormScreen extends StatefulWidget {
  final String eventId;
  final TaskProvider taskProvider;
  final Task? task;

  const TaskFormScreen({
    super.key,
    required this.eventId,
    required this.taskProvider,
    this.task,
  });

  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late String _categoryId;
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  late DateTime _dueDate;
  late TaskStatus _status;
  bool _isImportant = false;
  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();

    if (widget.task != null) {
      // Edit mode - populate form with existing data
      _categoryId = widget.task!.categoryId;
      _titleController.text = widget.task!.title;
      _descriptionController.text = widget.task!.description ?? '';
      _dueDate = widget.task!.dueDate;
      _status = widget.task!.status;
      _isImportant = widget.task!.isImportant;
      _notesController.text = widget.task!.notes ?? '';
    } else {
      // Create mode - initialize with defaults
      _categoryId = widget.taskProvider.categories.first.id;
      _dueDate = DateTime.now().add(const Duration(days: 7));
      _status = TaskStatus.notStarted;
      _isImportant = false;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = UIUtils.isDarkMode(context);
    final primaryColor = isDarkMode ? AppColorsDark.primary : AppColors.primary;
    final isEditing = widget.task != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Task' : 'Add Task'),
        backgroundColor: primaryColor,
        actions: [
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _showDeleteConfirmation(context),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Category dropdown
            DropdownButtonFormField<String>(
              value: _categoryId,
              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
              ),
              items:
                  widget.taskProvider.categories.map((category) {
                    return DropdownMenuItem<String>(
                      value: category.id,
                      child: Row(
                        children: [
                          Icon(category.icon, size: 20, color: category.color),
                          const SizedBox(width: 8),
                          Text(category.name),
                        ],
                      ),
                    );
                  }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _categoryId = value;
                  });
                }
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select a category';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Title
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a title';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Description
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (optional)',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),

            // Due date
            InkWell(
              onTap: () => _selectDueDate(context),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Due Date',
                  border: OutlineInputBorder(),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(DateFormat('MMM d, yyyy').format(_dueDate)),
                    const Icon(Icons.calendar_today),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Status
            DropdownButtonFormField<TaskStatus>(
              value: _status,
              decoration: const InputDecoration(
                labelText: 'Status',
                border: OutlineInputBorder(),
              ),
              items: [
                const DropdownMenuItem(
                  value: TaskStatus.notStarted,
                  child: Row(
                    children: [
                      Icon(
                        Icons.circle_outlined,
                        size: 20,
                        color: Colors.orange,
                      ),
                      SizedBox(width: 8),
                      Text('Not Started'),
                    ],
                  ),
                ),
                const DropdownMenuItem(
                  value: TaskStatus.inProgress,
                  child: Row(
                    children: [
                      Icon(Icons.pending, size: 20, color: Colors.blue),
                      SizedBox(width: 8),
                      Text('In Progress'),
                    ],
                  ),
                ),
                const DropdownMenuItem(
                  value: TaskStatus.completed,
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, size: 20, color: Colors.green),
                      SizedBox(width: 8),
                      Text('Completed'),
                    ],
                  ),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _status = value;
                  });
                }
              },
            ),
            const SizedBox(height: 16),

            // Important flag
            SwitchListTile(
              title: const Text('Mark as Important'),
              value: _isImportant,
              activeColor: primaryColor,
              contentPadding: EdgeInsets.zero,
              onChanged: (value) {
                setState(() {
                  _isImportant = value;
                });
              },
            ),

            const Divider(),
            const SizedBox(height: 16),

            // Notes
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes (optional)',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              maxLines: 3,
            ),

            const SizedBox(height: 24),

            // Submit button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: _saveTask,
              child: Text(
                isEditing ? 'Update Task' : 'Add Task',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDueDate(BuildContext context) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );

    if (pickedDate != null && pickedDate != _dueDate) {
      setState(() {
        _dueDate = pickedDate;
      });
    }
  }

  void _saveTask() async {
    if (_formKey.currentState!.validate()) {
      // Create or update task
      final title = _titleController.text;
      final description =
          _descriptionController.text.isNotEmpty
              ? _descriptionController.text
              : null;
      final notes =
          _notesController.text.isNotEmpty ? _notesController.text : null;

      if (widget.task != null) {
        // Update existing task
        final updatedTask = widget.task!.copyWith(
          categoryId: _categoryId,
          title: title,
          description: description,
          dueDate: _dueDate,
          status: _status,
          isImportant: _isImportant,
          notes: notes,
        );

        await widget.taskProvider.updateTask(updatedTask);
      } else {
        // Create new task
        final newTask = Task(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          categoryId: _categoryId,
          title: title,
          description: description,
          dueDate: _dueDate,
          status: _status,
          isImportant: _isImportant,
          notes: notes,
        );

        await widget.taskProvider.addTask(newTask);
      }

      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Task'),
            content: Text(
              'Are you sure you want to delete "${widget.task!.title}"?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  widget.taskProvider.deleteTask(widget.task!.id);
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context); // Return to previous screen
                },
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }
}
