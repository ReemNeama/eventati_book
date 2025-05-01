import 'package:flutter/material.dart';

class WeddingChecklistScreen extends StatefulWidget {
  final String eventName;
  final String eventType;
  final DateTime eventDate;
  final int guestCount;
  final Map<String, bool> selectedServices;

  const WeddingChecklistScreen({
    super.key,
    required this.eventName,
    required this.eventType,
    required this.eventDate,
    required this.guestCount,
    required this.selectedServices,
  });

  @override
  State<WeddingChecklistScreen> createState() => _WeddingChecklistScreenState();
}

class _WeddingChecklistScreenState extends State<WeddingChecklistScreen> {
  late Map<String, List<TaskItem>> _serviceTasks;

  @override
  void initState() {
    super.initState();
    _initializeTasks();
  }

  void _initializeTasks() {
    _serviceTasks = {
      'Venue': [
        TaskItem('Research wedding venues'),
        TaskItem('Schedule venue visits'),
        TaskItem('Review venue contract'),
        TaskItem('Make deposit payment'),
        TaskItem('Confirm venue requirements'),
        TaskItem('Plan ceremony layout'),
        TaskItem('Plan reception layout'),
      ],
      'Catering': [
        TaskItem('Research caterers'),
        TaskItem('Schedule tastings'),
        TaskItem('Plan menu'),
        TaskItem('Confirm dietary restrictions'),
        TaskItem('Finalize catering contract'),
        TaskItem('Choose wedding cake design'),
        TaskItem('Plan bar service'),
      ],
      'Photography/Videography': [
        TaskItem('Research photographers'),
        TaskItem('Review portfolios'),
        TaskItem('Create shot list'),
        TaskItem('Sign contract'),
        TaskItem('Schedule engagement photos'),
        TaskItem('Plan video coverage'),
      ],
      'Wedding Dress/Attire': [
        TaskItem('Research bridal shops'),
        TaskItem('Schedule fittings'),
        TaskItem('Choose wedding dress'),
        TaskItem('Select accessories'),
        TaskItem('Plan groom\'s attire'),
        TaskItem('Coordinate wedding party attire'),
      ],
      'Flowers & Decoration': [
        TaskItem('Choose florist'),
        TaskItem('Select flower arrangements'),
        TaskItem('Plan ceremony decorations'),
        TaskItem('Plan reception decorations'),
        TaskItem('Order bouquets'),
        TaskItem('Plan centerpieces'),
      ],
      'Music & Entertainment': [
        TaskItem('Research entertainment options'),
        TaskItem('Book ceremony musician'),
        TaskItem('Book reception band/DJ'),
        TaskItem('Create playlist'),
        TaskItem('Plan special dances'),
      ],
      'Wedding Cake': [
        TaskItem('Research bakeries'),
        TaskItem('Schedule tastings'),
        TaskItem('Choose cake design'),
        TaskItem('Order cake'),
        TaskItem('Plan cake display'),
      ],
      'Invitations': [
        TaskItem('Choose invitation design'),
        TaskItem('Order save-the-dates'),
        TaskItem('Order invitations'),
        TaskItem('Address envelopes'),
        TaskItem('Mail invitations'),
        TaskItem('Track RSVPs'),
      ],
      'Transportation': [
        TaskItem('Research transportation options'),
        TaskItem('Book wedding party transport'),
        TaskItem('Plan guest shuttle service'),
        TaskItem('Confirm pickup times'),
        TaskItem('Create transportation schedule'),
      ],
      'Accommodation': [
        TaskItem('Research hotels'),
        TaskItem('Block hotel rooms'),
        TaskItem('Negotiate group rates'),
        TaskItem('Communicate with guests'),
        TaskItem('Plan welcome bags'),
      ],
      'Hair & Makeup': [
        TaskItem('Research beauty services'),
        TaskItem('Schedule trials'),
        TaskItem('Book services'),
        TaskItem('Create timeline'),
        TaskItem('Plan touch-up kit'),
      ],
      'Wedding Rings': [
        TaskItem('Research jewelers'),
        TaskItem('Choose wedding bands'),
        TaskItem('Get rings sized'),
        TaskItem('Purchase rings'),
        TaskItem('Get rings cleaned'),
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
    final selectedServices =
        widget.selectedServices.entries.where((e) => e.value).map((e) => e.key).toList();

    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0,
        title: const Text(
          "Wedding Planning Checklist",
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
            Padding(
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
                    style: const TextStyle(fontSize: 16),
                  ),
                  Text(
                    'Date: ${widget.eventDate.toString().split(' ')[0]}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  Text(
                    'Guests: ${widget.guestCount}',
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: selectedServices.length,
                itemBuilder: (context, index) {
                  final service = selectedServices[index];
                  final tasks = _serviceTasks[service] ?? [];
                  final progress = _calculateProgress(service);

                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ExpansionTile(
                      title: Text(
                        service,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),
                          LinearProgressIndicator(
                            value: progress,
                            backgroundColor: Colors.grey[200],
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Theme.of(context).primaryColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${(progress * 100).toInt()}% completed',
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ],
                      ),
                      children: tasks.map((task) {
                        return CheckboxListTile(
                          title: Text(task.description),
                          value: task.isCompleted,
                          activeColor: Theme.of(context).primaryColor,
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