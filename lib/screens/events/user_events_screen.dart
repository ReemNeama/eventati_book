import 'package:flutter/material.dart';
import 'package:eventati_book/utils/utils.dart';
import 'package:eventati_book/styles/app_colors.dart';
import 'package:eventati_book/styles/app_colors_dark.dart';
import 'package:eventati_book/screens/event_planning/event_planning_tools_screen.dart';

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
    final isDarkMode = UIUtils.isDarkMode(context);
    final primaryColor = isDarkMode ? AppColorsDark.primary : AppColors.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Events'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: primaryColor,
      ),
      body: _mockEvents.isEmpty ? _buildEmptyState() : _buildEventsList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to event selection screen
          Navigator.pushNamed(context, '/event-selection');
        },
        backgroundColor: primaryColor,
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
            trailing: PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (value) {
                if (value == 'planning') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => EventPlanningToolsScreen(
                            eventId:
                                index
                                    .toString(), // In a real app, this would be a real ID
                            eventName: event['name'],
                            eventType: event['type'],
                            eventDate: event['date'],
                          ),
                    ),
                  );
                } else if (value == 'details') {
                  // Navigate to event details
                  // This would be implemented based on event type
                }
              },
              itemBuilder:
                  (context) => [
                    const PopupMenuItem(
                      value: 'planning',
                      child: Row(
                        children: [
                          Icon(Icons.build_circle, size: 20),
                          SizedBox(width: 8),
                          Text('Planning Tools'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'details',
                      child: Row(
                        children: [
                          Icon(Icons.info, size: 20),
                          SizedBox(width: 8),
                          Text('Event Details'),
                        ],
                      ),
                    ),
                  ],
            ),
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
