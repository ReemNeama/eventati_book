import 'package:eventati_book/models/models.dart';

/// Service to provide task templates for different event types
class TaskTemplateService {
  /// Get task templates for a specific event type
  static List<Map<String, dynamic>> getTaskTemplates(String eventType) {
    switch (eventType.toLowerCase()) {
      case 'wedding':
        return _weddingTaskTemplates;
      case 'business':
      case 'business event':
      case 'conference':
        return _businessTaskTemplates;
      case 'celebration':
      case 'party':
      case 'birthday':
        return _celebrationTaskTemplates;
      default:
        return _generalTaskTemplates;
    }
  }

  /// Create tasks from templates for a specific event
  static List<Task> createTasksFromTemplates(
    String eventId,
    String eventType,
    DateTime eventDate,
    Map<String, bool> selectedServices,
  ) {
    final templates = getTaskTemplates(eventType);
    final tasks = <Task>[];
    final now = DateTime.now();

    // Filter templates based on selected services
    final filteredTemplates =
        templates.where((template) {
          final service = template['service'] as String;

          return selectedServices[service] == true || service == 'General';
        }).toList();

    // Create tasks from templates
    for (var i = 0; i < filteredTemplates.length; i++) {
      final template = filteredTemplates[i];
      final daysBeforeEvent = template['daysBeforeEvent'] as int;
      final dueDate = eventDate.subtract(Duration(days: daysBeforeEvent));

      // Skip tasks that would be due in the past
      if (dueDate.isBefore(now)) continue;

      tasks.add(
        Task(
          id: '${eventId}_${i + 1}',
          title: template['title'] as String,
          description: template['description'] as String?,
          dueDate: dueDate,
          status: TaskStatus.notStarted,
          categoryId: template['categoryId'] as String,
          isImportant: template['isImportant'] as bool? ?? false,
        ),
      );
    }

    return tasks;
  }

  /// Wedding task templates
  static final List<Map<String, dynamic>> _weddingTaskTemplates = [
    // Venue tasks
    {
      'service': 'Venue',
      'categoryId': '1',
      'title': 'Research wedding venues',
      'description': 'Look for venues that match your style and budget',
      'daysBeforeEvent': 365,
      'isImportant': true,
    },
    {
      'service': 'Venue',
      'categoryId': '1',
      'title': 'Schedule venue visits',
      'description': 'Make appointments to tour potential venues',
      'daysBeforeEvent': 335,
    },
    {
      'service': 'Venue',
      'categoryId': '1',
      'title': 'Review venue contract',
      'description': 'Carefully read all terms before signing',
      'daysBeforeEvent': 305,
      'isImportant': true,
    },
    {
      'service': 'Venue',
      'categoryId': '1',
      'title': 'Make deposit payment',
      'description': 'Secure your venue with the initial payment',
      'daysBeforeEvent': 300,
      'isImportant': true,
    },
    {
      'service': 'Venue',
      'categoryId': '1',
      'title': 'Confirm venue requirements',
      'description': 'Check on insurance, permits, and other requirements',
      'daysBeforeEvent': 180,
    },
    {
      'service': 'Venue',
      'categoryId': '1',
      'title': 'Plan ceremony layout',
      'description': 'Decide on seating arrangement and decorations',
      'daysBeforeEvent': 90,
    },
    {
      'service': 'Venue',
      'categoryId': '1',
      'title': 'Plan reception layout',
      'description': 'Arrange tables, dance floor, and other elements',
      'daysBeforeEvent': 90,
    },

    // Catering tasks
    {
      'service': 'Catering',
      'categoryId': '2',
      'title': 'Research caterers',
      'description': 'Find caterers that match your style and budget',
      'daysBeforeEvent': 300,
    },
    {
      'service': 'Catering',
      'categoryId': '2',
      'title': 'Schedule tastings',
      'description': 'Arrange to sample menu options',
      'daysBeforeEvent': 270,
    },
    {
      'service': 'Catering',
      'categoryId': '2',
      'title': 'Plan menu',
      'description': 'Select appetizers, main courses, and desserts',
      'daysBeforeEvent': 240,
    },
    {
      'service': 'Catering',
      'categoryId': '2',
      'title': 'Confirm dietary restrictions',
      'description': 'Ensure options for guests with special dietary needs',
      'daysBeforeEvent': 120,
    },
    {
      'service': 'Catering',
      'categoryId': '2',
      'title': 'Finalize catering contract',
      'description': 'Review and sign the final agreement',
      'daysBeforeEvent': 180,
      'isImportant': true,
    },
    {
      'service': 'Catering',
      'categoryId': '2',
      'title': 'Choose wedding cake design',
      'description': 'Select flavor, size, and decorative elements',
      'daysBeforeEvent': 150,
    },
    {
      'service': 'Catering',
      'categoryId': '2',
      'title': 'Plan bar service',
      'description': 'Decide on open bar, cash bar, or limited service',
      'daysBeforeEvent': 150,
    },

    // Photography tasks
    {
      'service': 'Photography',
      'categoryId': '3',
      'title': 'Research photographers',
      'description': 'Find photographers whose style matches your vision',
      'daysBeforeEvent': 300,
    },
    {
      'service': 'Photography',
      'categoryId': '3',
      'title': 'Review portfolios',
      'description': 'Look through sample work from potential photographers',
      'daysBeforeEvent': 270,
    },
    {
      'service': 'Photography',
      'categoryId': '3',
      'title': 'Create shot list',
      'description': 'Make a list of must-have photos',
      'daysBeforeEvent': 90,
    },
    {
      'service': 'Photography',
      'categoryId': '3',
      'title': 'Sign contract',
      'description': 'Review and sign the photography agreement',
      'daysBeforeEvent': 240,
      'isImportant': true,
    },
    {
      'service': 'Photography',
      'categoryId': '3',
      'title': 'Schedule engagement photos',
      'description': 'Plan a date for your engagement photoshoot',
      'daysBeforeEvent': 210,
    },
    {
      'service': 'Photography',
      'categoryId': '3',
      'title': 'Plan video coverage',
      'description': 'Decide if you want videography and what to include',
      'daysBeforeEvent': 240,
    },

    // Attire tasks
    {
      'service': 'Attire',
      'categoryId': '5',
      'title': 'Research bridal shops',
      'description': 'Find stores with styles you like in your budget',
      'daysBeforeEvent': 300,
    },
    {
      'service': 'Attire',
      'categoryId': '5',
      'title': 'Schedule fittings',
      'description': 'Make appointments for dress fittings',
      'daysBeforeEvent': 270,
    },
    {
      'service': 'Attire',
      'categoryId': '5',
      'title': 'Choose wedding dress',
      'description': 'Select your perfect wedding dress',
      'daysBeforeEvent': 240,
      'isImportant': true,
    },
    {
      'service': 'Attire',
      'categoryId': '5',
      'title': 'Select accessories',
      'description': 'Choose veil, jewelry, and other accessories',
      'daysBeforeEvent': 180,
    },
    {
      'service': 'Attire',
      'categoryId': '5',
      'title': "Plan groom's attire",
      'description': 'Select suit or tuxedo and accessories',
      'daysBeforeEvent': 180,
    },
    {
      'service': 'Attire',
      'categoryId': '5',
      'title': 'Coordinate wedding party attire',
      'description': 'Choose bridesmaid dresses and groomsmen attire',
      'daysBeforeEvent': 210,
    },

    // General wedding tasks
    {
      'service': 'General',
      'categoryId': '7',
      'title': 'Create wedding website',
      'description': 'Build a site with event details for guests',
      'daysBeforeEvent': 240,
    },
    {
      'service': 'General',
      'categoryId': '7',
      'title': 'Book honeymoon',
      'description': 'Plan and reserve your post-wedding getaway',
      'daysBeforeEvent': 180,
      'isImportant': true,
    },
    {
      'service': 'General',
      'categoryId': '7',
      'title': 'Apply for marriage license',
      'description': 'Check local requirements and deadlines',
      'daysBeforeEvent': 60,
      'isImportant': true,
    },
    {
      'service': 'General',
      'categoryId': '7',
      'title': 'Create day-of timeline',
      'description': 'Plan the schedule for your wedding day',
      'daysBeforeEvent': 30,
      'isImportant': true,
    },
  ];

  /// Business event task templates
  static final List<Map<String, dynamic>> _businessTaskTemplates = [
    // Venue tasks
    {
      'service': 'Venue',
      'categoryId': '1',
      'title': 'Research potential venues',
      'description': 'Find venues suitable for your business event',
      'daysBeforeEvent': 180,
      'isImportant': true,
    },
    {
      'service': 'Venue',
      'categoryId': '1',
      'title': 'Schedule venue visits',
      'description': 'Make appointments to tour potential venues',
      'daysBeforeEvent': 150,
    },
    {
      'service': 'Venue',
      'categoryId': '1',
      'title': 'Review venue contract',
      'description': 'Carefully read all terms before signing',
      'daysBeforeEvent': 120,
      'isImportant': true,
    },
    {
      'service': 'Venue',
      'categoryId': '1',
      'title': 'Make deposit payment',
      'description': 'Secure your venue with the initial payment',
      'daysBeforeEvent': 110,
      'isImportant': true,
    },
    {
      'service': 'Venue',
      'categoryId': '1',
      'title': 'Confirm venue requirements',
      'description': 'Check on insurance, permits, and other requirements',
      'daysBeforeEvent': 90,
    },

    // Catering tasks
    {
      'service': 'Catering',
      'categoryId': '2',
      'title': 'Select catering service',
      'description': 'Choose a caterer for your business event',
      'daysBeforeEvent': 120,
    },
    {
      'service': 'Catering',
      'categoryId': '2',
      'title': 'Plan menu',
      'description': 'Select food and beverage options',
      'daysBeforeEvent': 90,
    },
    {
      'service': 'Catering',
      'categoryId': '2',
      'title': 'Arrange food tasting',
      'description': 'Sample menu options before finalizing',
      'daysBeforeEvent': 75,
    },
    {
      'service': 'Catering',
      'categoryId': '2',
      'title': 'Confirm dietary requirements',
      'description': 'Ensure options for attendees with special dietary needs',
      'daysBeforeEvent': 45,
    },
    {
      'service': 'Catering',
      'categoryId': '2',
      'title': 'Finalize catering order',
      'description': 'Confirm final headcount and menu selections',
      'daysBeforeEvent': 30,
      'isImportant': true,
    },

    // Audio/Visual tasks
    {
      'service': 'Audio/Visual',
      'categoryId': '7',
      'title': 'List required equipment',
      'description': 'Determine A/V needs for presentations and activities',
      'daysBeforeEvent': 90,
    },
    {
      'service': 'Audio/Visual',
      'categoryId': '7',
      'title': 'Get quotes from vendors',
      'description': 'Contact A/V providers for pricing and availability',
      'daysBeforeEvent': 75,
    },
    {
      'service': 'Audio/Visual',
      'categoryId': '7',
      'title': 'Check venue compatibility',
      'description': 'Ensure venue can accommodate your A/V requirements',
      'daysBeforeEvent': 60,
    },
    {
      'service': 'Audio/Visual',
      'categoryId': '7',
      'title': 'Schedule equipment setup',
      'description': 'Arrange for delivery and installation',
      'daysBeforeEvent': 30,
    },
    {
      'service': 'Audio/Visual',
      'categoryId': '7',
      'title': 'Arrange for backup equipment',
      'description': 'Plan for technical contingencies',
      'daysBeforeEvent': 30,
    },

    // General business event tasks
    {
      'service': 'General',
      'categoryId': '7',
      'title': 'Create event agenda',
      'description': 'Plan the schedule and activities',
      'daysBeforeEvent': 90,
      'isImportant': true,
    },
    {
      'service': 'General',
      'categoryId': '7',
      'title': 'Invite speakers/presenters',
      'description': 'Secure commitments from key participants',
      'daysBeforeEvent': 120,
      'isImportant': true,
    },
    {
      'service': 'General',
      'categoryId': '7',
      'title': 'Create registration system',
      'description': 'Set up method for attendees to register',
      'daysBeforeEvent': 90,
    },
    {
      'service': 'General',
      'categoryId': '7',
      'title': 'Develop marketing materials',
      'description': 'Create promotional content for the event',
      'daysBeforeEvent': 75,
    },
    {
      'service': 'General',
      'categoryId': '7',
      'title': 'Send invitations/announcements',
      'description': 'Distribute event information to potential attendees',
      'daysBeforeEvent': 60,
      'isImportant': true,
    },
  ];

  /// Celebration task templates
  static final List<Map<String, dynamic>> _celebrationTaskTemplates = [
    // Venue tasks
    {
      'service': 'Venue',
      'categoryId': '1',
      'title': 'Research venues',
      'description': 'Find venues suitable for your celebration',
      'daysBeforeEvent': 120,
      'isImportant': true,
    },
    {
      'service': 'Venue',
      'categoryId': '1',
      'title': 'Schedule venue visits',
      'description': 'Make appointments to tour potential venues',
      'daysBeforeEvent': 100,
    },
    {
      'service': 'Venue',
      'categoryId': '1',
      'title': 'Review venue contract',
      'description': 'Carefully read all terms before signing',
      'daysBeforeEvent': 90,
      'isImportant': true,
    },
    {
      'service': 'Venue',
      'categoryId': '1',
      'title': 'Make deposit payment',
      'description': 'Secure your venue with the initial payment',
      'daysBeforeEvent': 85,
      'isImportant': true,
    },
    {
      'service': 'Venue',
      'categoryId': '1',
      'title': 'Confirm venue requirements',
      'description': 'Check on insurance, permits, and other requirements',
      'daysBeforeEvent': 60,
    },

    // Catering tasks
    {
      'service': 'Catering',
      'categoryId': '2',
      'title': 'Research caterers',
      'description': 'Find caterers that match your style and budget',
      'daysBeforeEvent': 90,
    },
    {
      'service': 'Catering',
      'categoryId': '2',
      'title': 'Plan menu',
      'description': 'Select food and beverage options',
      'daysBeforeEvent': 75,
    },
    {
      'service': 'Catering',
      'categoryId': '2',
      'title': 'Get quotes',
      'description': 'Compare pricing from different caterers',
      'daysBeforeEvent': 75,
    },
    {
      'service': 'Catering',
      'categoryId': '2',
      'title': 'Confirm dietary restrictions',
      'description': 'Ensure options for guests with special dietary needs',
      'daysBeforeEvent': 45,
    },
    {
      'service': 'Catering',
      'categoryId': '2',
      'title': 'Book catering service',
      'description': 'Finalize agreement with chosen caterer',
      'daysBeforeEvent': 60,
      'isImportant': true,
    },

    // Entertainment tasks
    {
      'service': 'Entertainment',
      'categoryId': '7',
      'title': 'Choose entertainment type',
      'description': 'Decide on DJ, band, or other entertainment',
      'daysBeforeEvent': 90,
    },
    {
      'service': 'Entertainment',
      'categoryId': '7',
      'title': 'Research providers',
      'description': 'Find entertainment options within your budget',
      'daysBeforeEvent': 75,
    },
    {
      'service': 'Entertainment',
      'categoryId': '7',
      'title': 'Create playlist',
      'description': 'Select music for different parts of the event',
      'daysBeforeEvent': 30,
    },
    {
      'service': 'Entertainment',
      'categoryId': '7',
      'title': 'Book entertainment',
      'description': 'Finalize agreement with chosen provider',
      'daysBeforeEvent': 60,
      'isImportant': true,
    },

    // Decoration tasks
    {
      'service': 'Decoration',
      'categoryId': '4',
      'title': 'Choose theme',
      'description': 'Decide on colors, style, and overall theme',
      'daysBeforeEvent': 90,
    },
    {
      'service': 'Decoration',
      'categoryId': '4',
      'title': 'Create decoration list',
      'description': 'Make a detailed list of needed items',
      'daysBeforeEvent': 75,
    },
    {
      'service': 'Decoration',
      'categoryId': '4',
      'title': 'Source decorations',
      'description': 'Purchase or rent decorative items',
      'daysBeforeEvent': 45,
    },
    {
      'service': 'Decoration',
      'categoryId': '4',
      'title': 'Plan setup',
      'description': 'Create a layout and schedule for decoration',
      'daysBeforeEvent': 30,
    },

    // General celebration tasks
    {
      'service': 'General',
      'categoryId': '7',
      'title': 'Create guest list',
      'description': 'Decide who to invite to your celebration',
      'daysBeforeEvent': 90,
      'isImportant': true,
    },
    {
      'service': 'General',
      'categoryId': '7',
      'title': 'Send invitations',
      'description': 'Distribute invitations to guests',
      'daysBeforeEvent': 60,
      'isImportant': true,
    },
    {
      'service': 'General',
      'categoryId': '7',
      'title': 'Plan activities',
      'description': 'Organize games or special moments',
      'daysBeforeEvent': 45,
    },
    {
      'service': 'General',
      'categoryId': '7',
      'title': 'Create day-of schedule',
      'description': 'Plan the timing for your celebration',
      'daysBeforeEvent': 14,
      'isImportant': true,
    },
  ];

  /// General task templates for any event type
  static final List<Map<String, dynamic>> _generalTaskTemplates = [
    // Venue tasks
    {
      'service': 'Venue',
      'categoryId': '1',
      'title': 'Research venues',
      'description': 'Find venues suitable for your event',
      'daysBeforeEvent': 120,
      'isImportant': true,
    },
    {
      'service': 'Venue',
      'categoryId': '1',
      'title': 'Book venue',
      'description': 'Secure your chosen venue with a deposit',
      'daysBeforeEvent': 90,
      'isImportant': true,
    },

    // Catering tasks
    {
      'service': 'Catering',
      'categoryId': '2',
      'title': 'Research food options',
      'description': 'Explore catering services or restaurants',
      'daysBeforeEvent': 90,
    },
    {
      'service': 'Catering',
      'categoryId': '2',
      'title': 'Book catering',
      'description': 'Finalize food and beverage arrangements',
      'daysBeforeEvent': 60,
      'isImportant': true,
    },

    // General tasks
    {
      'service': 'General',
      'categoryId': '7',
      'title': 'Create guest list',
      'description': 'Decide who to invite to your event',
      'daysBeforeEvent': 90,
      'isImportant': true,
    },
    {
      'service': 'General',
      'categoryId': '7',
      'title': 'Send invitations',
      'description': 'Distribute invitations to guests',
      'daysBeforeEvent': 60,
      'isImportant': true,
    },
    {
      'service': 'General',
      'categoryId': '7',
      'title': 'Create event schedule',
      'description': 'Plan the timing for your event',
      'daysBeforeEvent': 30,
      'isImportant': true,
    },
  ];
}
