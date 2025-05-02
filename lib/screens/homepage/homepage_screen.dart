import 'package:flutter/material.dart';
import 'package:eventati_book/utils/utils.dart';
import 'package:eventati_book/styles/app_colors.dart';
import 'package:eventati_book/styles/app_colors_dark.dart';

class HomepageScreen extends StatefulWidget {
  const HomepageScreen({super.key});

  @override
  State<HomepageScreen> createState() => _HomepageScreenState();
}

class _HomepageScreenState extends State<HomepageScreen> {
  // Mock data for upcoming events
  final List<Map<String, dynamic>> _upcomingEvents = [
    {
      'name': 'Company Annual Meeting',
      'date': DateTime.now().add(const Duration(days: 30)),
      'location': 'Grand Hotel Conference Center',
      'image': 'assets/business_event.jpg',
    },
  ];

  // Mock data for recommended venues
  final List<Map<String, dynamic>> _recommendedVenues = [
    {
      'name': 'Sunset Beach Resort',
      'rating': 4.8,
      'price': '\$1,200',
      'image': 'assets/venue1.jpg',
    },
    {
      'name': 'Mountain View Lodge',
      'rating': 4.6,
      'price': '\$950',
      'image': 'assets/venue2.jpg',
    },
    {
      'name': 'City Garden Hall',
      'rating': 4.5,
      'price': '\$800',
      'image': 'assets/venue3.jpg',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = UIUtils.isDarkMode(context);
    final textPrimary =
        isDarkMode ? AppColorsDark.textPrimary : AppColors.textPrimary;
    final textSecondary =
        isDarkMode ? AppColorsDark.textSecondary : AppColors.textSecondary;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppConstants.appName),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(AppConstants.mediumPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome section
              Text(
                'Welcome back!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Plan your perfect event with us',
                style: TextStyle(fontSize: 16, color: textSecondary),
              ),
              SizedBox(height: AppConstants.largePadding),

              // Create new event button
              InkWell(
                onTap: () {
                  Navigator.pushNamed(context, '/event-selection');
                },
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    vertical: AppConstants.mediumPadding,
                  ),
                  decoration: BoxDecoration(
                    color: theme.primaryColor,
                    borderRadius: BorderRadius.circular(
                      AppConstants.mediumBorderRadius,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: theme.primaryColor.withAlpha(75),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_circle_outline,
                        color: Colors.white,
                        size: 24,
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Create New Event',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: AppConstants.largePadding + AppConstants.smallPadding,
              ),

              // Upcoming events section
              _sectionTitle('Upcoming Events'),
              SizedBox(height: AppConstants.mediumPadding),
              _upcomingEvents.isEmpty
                  ? _emptyStateCard(
                    'No upcoming events',
                    'Create a new event to get started',
                  )
                  : _buildUpcomingEventsList(),
              const SizedBox(height: 32),

              // Recommended venues section
              _sectionTitle('Recommended Venues'),
              const SizedBox(height: 16),
              SizedBox(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _recommendedVenues.length,
                  itemBuilder: (context, index) {
                    final venue = _recommendedVenues[index];
                    return _buildVenueCard(venue);
                  },
                ),
              ),
              const SizedBox(height: 32),

              // Quick links section
              _sectionTitle('Quick Links'),
              const SizedBox(height: 16),
              _buildQuickLinksGrid(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    );
  }

  Widget _emptyStateCard(String title, String subtitle) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingEventsList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _upcomingEvents.length,
      itemBuilder: (context, index) {
        final event = _upcomingEvents[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withAlpha(50),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.event,
                color: Theme.of(context).primaryColor,
                size: 30,
              ),
            ),
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
                    const Icon(Icons.location_on, size: 16),
                    const SizedBox(width: 8),
                    Expanded(child: Text(event['location'])),
                  ],
                ),
              ],
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // Navigate to event details
            },
          ),
        );
      },
    );
  }

  Widget _buildVenueCard(Map<String, dynamic> venue) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 16),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Venue image (placeholder)
            Container(
              height: 100,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withAlpha(50),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Center(
                child: Icon(
                  Icons.location_city,
                  size: 40,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    venue['name'],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 14, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(
                        venue['rating'].toString(),
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    venue['price'],
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickLinksGrid() {
    final List<Map<String, dynamic>> quickLinks = [
      {
        'title': 'Venues',
        'icon': Icons.location_on,
        'color': Colors.blue,
        'onTap': () {
          // Navigate to venues tab in services screen
        },
      },
      {
        'title': 'Catering',
        'icon': Icons.restaurant,
        'color': Colors.orange,
        'onTap': () {
          // Navigate to catering tab in services screen
        },
      },
      {
        'title': 'Photography',
        'icon': Icons.camera_alt,
        'color': Colors.purple,
        'onTap': () {
          // Navigate to photography tab in services screen
        },
      },
      {
        'title': 'Planners',
        'icon': Icons.people,
        'color': Colors.green,
        'onTap': () {
          // Navigate to planners tab in services screen
        },
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.5,
      ),
      itemCount: quickLinks.length,
      itemBuilder: (context, index) {
        final link = quickLinks[index];
        return InkWell(
          onTap: link['onTap'],
          child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(link['icon'], size: 32, color: link['color']),
                  const SizedBox(height: 8),
                  Text(
                    link['title'],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
