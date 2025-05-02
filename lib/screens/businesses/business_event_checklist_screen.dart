import 'package:flutter/material.dart';

class BusinessEventChecklistScreen extends StatefulWidget {
  final String eventName;
  final String eventType;
  final DateTime eventDate;
  final int guestCount;
  final Map<String, bool> selectedServices;

  const BusinessEventChecklistScreen({
    super.key,
    required this.eventName,
    required this.eventType,
    required this.eventDate,
    required this.guestCount,
    required this.selectedServices,
  });

  @override
  State<BusinessEventChecklistScreen> createState() =>
      _BusinessEventChecklistScreenState();
}

class _BusinessEventChecklistScreenState
    extends State<BusinessEventChecklistScreen> {
  late Map<String, List<TaskItem>> _serviceTasks;

  @override
  void initState() {
    super.initState();
    _initializeTasks();
  }

  void _initializeTasks() {
    _serviceTasks = {
      'Venue': [
        TaskItem('Research potential venues'),
        TaskItem('Schedule venue visits'),
        TaskItem('Review venue contract'),
        TaskItem('Make deposit payment'),
        TaskItem('Confirm venue requirements'),
      ],
      'Catering': [
        TaskItem('Select catering service'),
        TaskItem('Plan menu'),
        TaskItem('Arrange food tasting'),
        TaskItem('Confirm dietary requirements'),
        TaskItem('Finalize catering order'),
      ],
      'Audio/Visual Equipment': [
        TaskItem('List required equipment'),
        TaskItem('Get quotes from vendors'),
        TaskItem('Check venue compatibility'),
        TaskItem('Schedule equipment setup'),
        TaskItem('Arrange for backup equipment'),
      ],
      'Photography': [
        TaskItem('Choose photographer'),
        TaskItem('Define shot list'),
        TaskItem('Review portfolio'),
        TaskItem('Sign contract'),
        TaskItem('Create event timeline'),
      ],
      'Transportation': [
        TaskItem('Determine transport needs'),
        TaskItem('Get transportation quotes'),
        TaskItem('Create transport schedule'),
        TaskItem('Confirm pickup locations'),
        TaskItem('Book vehicles'),
      ],
      'Accommodation': [
        TaskItem('Block hotel rooms'),
        TaskItem('Negotiate group rates'),
        TaskItem('Create booking system'),
        TaskItem('Send booking information'),
        TaskItem('Monitor reservations'),
      ],
      'Event Staff': [
        TaskItem('Define staffing needs'),
        TaskItem('Create job descriptions'),
        TaskItem('Interview candidates'),
        TaskItem('Schedule staff training'),
        TaskItem('Create staff schedule'),
      ],
      'Decoration': [
        TaskItem('Design event theme'),
        TaskItem('Source decorations'),
        TaskItem('Create layout plan'),
        TaskItem('Order materials'),
        TaskItem('Schedule setup'),
      ],
    };
  }

  double _calculateProgress(String service) {
    final tasks = _serviceTasks[service] ?? [];
    if (tasks.isEmpty) return 0.0;
    final completedTasks = tasks.where((task) => task.isCompleted).length;
    return completedTasks / tasks.length;
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    final selectedServices = widget.selectedServices.entries
        .where((e) => e.value)
        .map((e) => e.key);

    return Scaffold(
      backgroundColor: primaryColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        title: const Text(
          'Event Checklist',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.eventName,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Type: ${widget.eventType}',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                  Text(
                    'Date: ${widget.eventDate.toString().split(' ')[0]}',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                  Text(
                    'Guests: ${widget.guestCount}',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: selectedServices.length,
                itemBuilder: (context, index) {
                  final service = selectedServices.elementAt(index);
                  final tasks = _serviceTasks[service] ?? [];
                  final progress = _calculateProgress(service);

                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ExpansionTile(
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            service,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          LinearProgressIndicator(
                            value: progress,
                            backgroundColor: Colors.grey[200],
                            valueColor: AlwaysStoppedAnimation<Color>(
                              primaryColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${(progress * 100).toInt()}% Complete',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      children:
                          tasks.map((task) {
                            return CheckboxListTile(
                              title: Text(
                                task.description,
                                style: TextStyle(
                                  decoration:
                                      task.isCompleted
                                          ? TextDecoration.lineThrough
                                          : null,
                                  color:
                                      task.isCompleted
                                          ? Colors.grey
                                          : Colors.black,
                                ),
                              ),
                              value: task.isCompleted,
                              activeColor: primaryColor,
                              onChanged: (bool? value) {
                                setState(() {
                                  task.isCompleted = value ?? false;
                                });
                              },
                            );
                          }).toList(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TaskItem {
  final String description;
  bool isCompleted;

  TaskItem(this.description, {this.isCompleted = false});
}
