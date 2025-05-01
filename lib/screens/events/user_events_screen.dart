import 'package:flutter/material.dart';

/// Screen that displays all events created or saved by the user
class UserEventsScreen extends StatefulWidget {
  const UserEventsScreen({super.key});

  @override
  State<UserEventsScreen> createState() => _UserEventsScreenState();
}

class _UserEventsScreenState extends State<UserEventsScreen> {
  // This would typically be populated from a provider or service
  final List<Map<String, dynamic>> _mockEvents = [
    {
      'name': 'Company Annual Meeting',
      'type': 'Business Event',
      'date': DateTime.now().add(const Duration(days: 30)),
      'guests': 75,
    },
    {
      'name': 'Sarah & John\'s Wedding',
      'type': 'Wedding',
      'date': DateTime.now().add(const Duration(days: 60)),
      'guests': 120,
    },
    {
      'name': 'Birthday Celebration',
      'type': 'Celebration',
      'date': DateTime.now().add(const Duration(days: 15)),
      'guests': 30,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Events'),
        centerTitle: true,
        elevation: 0,
      ),
      body: _mockEvents.isEmpty ? _buildEmptyState() : _buildEventsList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to event selection screen
          Navigator.pushNamed(context, '/event-selection');
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_busy, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No events yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the + button to create a new event',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildEventsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _mockEvents.length,
      itemBuilder: (context, index) {
        final event = _mockEvents[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            title: Text(
              event['name'],
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.category, size: 16),
                    const SizedBox(width: 8),
                    Text(event['type']),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      '${event['date'].day}/${event['date'].month}/${event['date'].year}',
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.people, size: 16),
                    const SizedBox(width: 8),
                    Text('${event['guests']} guests'),
                  ],
                ),
              ],
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // Navigate to event details
              // This would be implemented based on event type
            },
          ),
        );
      },
    );
  }
}
