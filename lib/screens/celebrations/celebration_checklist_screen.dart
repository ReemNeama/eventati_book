import 'package:flutter/material.dart';

class TaskItem {
  String title;
  bool isCompleted;

  TaskItem(this.title, {this.isCompleted = false});
}

class CelebrationChecklistScreen extends StatefulWidget {
  final String eventName;
  final String eventType;
  final DateTime eventDate;
  final int guestCount;
  final Map<String, bool> selectedServices;

  const CelebrationChecklistScreen({
    super.key,
    required this.eventName,
    required this.eventType,
    required this.eventDate,
    required this.guestCount,
    required this.selectedServices,
  });

  @override
  State<CelebrationChecklistScreen> createState() =>
      _CelebrationChecklistScreenState();
}

class _CelebrationChecklistScreenState extends State<CelebrationChecklistScreen> {
  late Map<String, List<TaskItem>> _serviceTasks;

  @override
  void initState() {
    super.initState();
    _initializeTasks();
  }

  void _initializeTasks() {
    _serviceTasks = {
      'Venue': [
        TaskItem('Research venues'),
        TaskItem('Schedule venue visits'),
        TaskItem('Review venue contract'),
        TaskItem('Make deposit payment'),
        TaskItem('Confirm venue requirements'),
      ],
      'Catering': [
        TaskItem('Research caterers'),
        TaskItem('Plan menu'),
        TaskItem('Get quotes'),
        TaskItem('Confirm dietary restrictions'),
        TaskItem('Book catering service'),
      ],
      'Photography': [
        TaskItem('Research photographers'),
        TaskItem('Review portfolios'),
        TaskItem('Create shot list'),
        TaskItem('Book photographer'),
      ],
      'Music & Entertainment': [
        TaskItem('Choose entertainment type'),
        TaskItem('Research providers'),
        TaskItem('Create playlist'),
        TaskItem('Book entertainment'),
      ],
      'Decoration': [
        TaskItem('Choose theme'),
        TaskItem('Create decoration list'),
        TaskItem('Source decorations'),
        TaskItem('Plan setup'),
      ],
      'Invitations': [
        TaskItem('Design invitations'),
        TaskItem('Create guest list'),
        TaskItem('Order invitations'),
        TaskItem('Send invitations'),
        TaskItem('Track RSVPs'),
      ],
      'Cake & Desserts': [
        TaskItem('Research bakeries'),
        TaskItem('Choose design'),
        TaskItem('Order cake/desserts'),
        TaskItem('Arrange delivery'),
      ],
      'Party Favors': [
        TaskItem('Choose favor type'),
        TaskItem('Source items'),
        TaskItem('Prepare favors'),
        TaskItem('Plan distribution'),
      ],
      'Transportation': [
        TaskItem('Assess transportation needs'),
        TaskItem('Research options'),
        TaskItem('Book transportation'),
        TaskItem('Create schedule'),
      ],
      'Activities & Games': [
        TaskItem('Plan activities'),
        TaskItem('Source materials'),
        TaskItem('Create schedule'),
        TaskItem('Assign coordinators'),
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
    final selectedServices =
        widget.selectedServices.entries.where((e) => e.value).map((e) => e.key);

    return Scaffold(
      backgroundColor: primaryColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        title: const Text(
          "Celebration Checklist",
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
                    child: Column(
                      children: [
                        ListTile(
                          title: Text(
                            service,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: LinearProgressIndicator(
                            value: progress,
                            backgroundColor: Colors.grey[200],
                            valueColor: AlwaysStoppedAnimation<Color>(
                              primaryColor,
                            ),
                          ),
                        ),
                        const Divider(height: 1),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: tasks.length,
                          itemBuilder: (context, taskIndex) {
                            final task = tasks[taskIndex];
                            return CheckboxListTile(
                              title: Text(task.title),
                              value: task.isCompleted,
                              activeColor: primaryColor,
                              onChanged: (bool? value) {
                                setState(() {
                                  task.isCompleted = value ?? false;
                                });
                              },
                            );
                          },
                        ),
                      ],
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