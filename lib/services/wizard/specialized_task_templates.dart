import 'package:eventati_book/models/models.dart';

/// Specialized task templates for different event types
class SpecializedTaskTemplates {
  /// Create specialized tasks for wedding events
  static List<Task> createWeddingTasks(DateTime eventDate) {
    final tasks = <Task>[];

    // 12+ Months Before
    tasks.add(
      Task(
        id: 'wedding_task_${DateTime.now().millisecondsSinceEpoch}_1',
        title: 'Set wedding date and budget',
        description: 'Decide on a wedding date and establish a budget',
        categoryId: '1', // Planning category
        dueDate: eventDate.subtract(const Duration(days: 365)),
        status: TaskStatus.notStarted,
        isImportant: true,
      ),
    );

    tasks.add(
      Task(
        id: 'wedding_task_${DateTime.now().millisecondsSinceEpoch}_2',
        title: 'Choose wedding party',
        description: 'Select bridesmaids, groomsmen, and other roles',
        categoryId: '1', // Planning category
        dueDate: eventDate.subtract(const Duration(days: 365)),
        status: TaskStatus.notStarted,
        isImportant: true,
      ),
    );

    // 9-12 Months Before
    tasks.add(
      Task(
        id: 'wedding_task_${DateTime.now().millisecondsSinceEpoch}_3',
        title: 'Book ceremony venue',
        description: 'Reserve location for the wedding ceremony',
        categoryId: '2', // Venue category
        dueDate: eventDate.subtract(const Duration(days: 300)),
        status: TaskStatus.notStarted,
        isImportant: true,
      ),
    );

    tasks.add(
      Task(
        id: 'wedding_task_${DateTime.now().millisecondsSinceEpoch}_4',
        title: 'Book reception venue',
        description: 'Reserve location for the wedding reception',
        categoryId: '2', // Venue category
        dueDate: eventDate.subtract(const Duration(days: 300)),
        status: TaskStatus.notStarted,
        isImportant: true,
      ),
    );

    tasks.add(
      Task(
        id: 'wedding_task_${DateTime.now().millisecondsSinceEpoch}_5',
        title: 'Hire wedding planner',
        description: 'Interview and select a wedding planner',
        categoryId: '3', // Vendors category
        dueDate: eventDate.subtract(const Duration(days: 300)),
        status: TaskStatus.notStarted,
        isImportant: false,
      ),
    );

    // 6-9 Months Before
    tasks.add(
      Task(
        id: 'wedding_task_${DateTime.now().millisecondsSinceEpoch}_6',
        title: 'Shop for wedding dress',
        description: 'Begin looking for the perfect wedding dress',
        categoryId: '4', // Attire category
        dueDate: eventDate.subtract(const Duration(days: 270)),
        status: TaskStatus.notStarted,
        isImportant: true,
      ),
    );

    tasks.add(
      Task(
        id: 'wedding_task_${DateTime.now().millisecondsSinceEpoch}_7',
        title: 'Book photographer and videographer',
        description: 'Interview and select photography/videography services',
        categoryId: '3', // Vendors category
        dueDate: eventDate.subtract(const Duration(days: 270)),
        status: TaskStatus.notStarted,
        isImportant: true,
      ),
    );

    tasks.add(
      Task(
        id: 'wedding_task_${DateTime.now().millisecondsSinceEpoch}_8',
        title: 'Book caterer',
        description: 'Select catering service and discuss menu options',
        categoryId: '3', // Vendors category
        dueDate: eventDate.subtract(const Duration(days: 240)),
        status: TaskStatus.notStarted,
        isImportant: true,
      ),
    );

    // 4-6 Months Before
    tasks.add(
      Task(
        id: 'wedding_task_${DateTime.now().millisecondsSinceEpoch}_9',
        title: 'Order wedding cake',
        description: 'Select bakery and cake design',
        categoryId: '3', // Vendors category
        dueDate: eventDate.subtract(const Duration(days: 180)),
        status: TaskStatus.notStarted,
        isImportant: false,
      ),
    );

    tasks.add(
      Task(
        id: 'wedding_task_${DateTime.now().millisecondsSinceEpoch}_10',
        title: 'Book florist',
        description: 'Select florist and discuss flower arrangements',
        categoryId: '3', // Vendors category
        dueDate: eventDate.subtract(const Duration(days: 180)),
        status: TaskStatus.notStarted,
        isImportant: false,
      ),
    );

    tasks.add(
      Task(
        id: 'wedding_task_${DateTime.now().millisecondsSinceEpoch}_11',
        title: 'Book entertainment',
        description: 'Hire DJ, band, or other entertainment',
        categoryId: '3', // Vendors category
        dueDate: eventDate.subtract(const Duration(days: 180)),
        status: TaskStatus.notStarted,
        isImportant: true,
      ),
    );

    // 2-4 Months Before
    tasks.add(
      Task(
        id: 'wedding_task_${DateTime.now().millisecondsSinceEpoch}_12',
        title: 'Send invitations',
        description: 'Mail out wedding invitations to guests',
        categoryId: '5', // Stationery category
        dueDate: eventDate.subtract(const Duration(days: 90)),
        status: TaskStatus.notStarted,
        isImportant: true,
      ),
    );

    tasks.add(
      Task(
        id: 'wedding_task_${DateTime.now().millisecondsSinceEpoch}_13',
        title: 'Plan rehearsal dinner',
        description: 'Organize the rehearsal dinner before the wedding',
        categoryId: '1', // Planning category
        dueDate: eventDate.subtract(const Duration(days: 90)),
        status: TaskStatus.notStarted,
        isImportant: false,
      ),
    );

    // 1-2 Months Before
    tasks.add(
      Task(
        id: 'wedding_task_${DateTime.now().millisecondsSinceEpoch}_14',
        title: 'Final dress fitting',
        description: 'Schedule final dress fitting with alterations',
        categoryId: '4', // Attire category
        dueDate: eventDate.subtract(const Duration(days: 45)),
        status: TaskStatus.notStarted,
        isImportant: true,
      ),
    );

    tasks.add(
      Task(
        id: 'wedding_task_${DateTime.now().millisecondsSinceEpoch}_15',
        title: 'Confirm details with vendors',
        description: 'Contact all vendors to confirm arrangements',
        categoryId: '3', // Vendors category
        dueDate: eventDate.subtract(const Duration(days: 30)),
        status: TaskStatus.notStarted,
        isImportant: true,
      ),
    );

    // 1-2 Weeks Before
    tasks.add(
      Task(
        id: 'wedding_task_${DateTime.now().millisecondsSinceEpoch}_16',
        title: 'Create seating chart',
        description: 'Finalize seating arrangements for reception',
        categoryId: '1', // Planning category
        dueDate: eventDate.subtract(const Duration(days: 14)),
        status: TaskStatus.notStarted,
        isImportant: false,
      ),
    );

    tasks.add(
      Task(
        id: 'wedding_task_${DateTime.now().millisecondsSinceEpoch}_17',
        title: 'Final headcount to caterer',
        description: 'Provide final guest count to catering service',
        categoryId: '3', // Vendors category
        dueDate: eventDate.subtract(const Duration(days: 7)),
        status: TaskStatus.notStarted,
        isImportant: true,
      ),
    );

    return tasks;
  }

  /// Create specialized tasks for business events
  static List<Task> createBusinessEventTasks(DateTime eventDate) {
    final tasks = <Task>[];

    // 6+ Months Before
    tasks.add(
      Task(
        id: 'business_task_${DateTime.now().millisecondsSinceEpoch}_1',
        title: 'Define event objectives',
        description: 'Establish clear goals and objectives for the event',
        categoryId: '1', // Planning category
        dueDate: eventDate.subtract(const Duration(days: 180)),
        status: TaskStatus.notStarted,
        isImportant: true,
      ),
    );

    tasks.add(
      Task(
        id: 'business_task_${DateTime.now().millisecondsSinceEpoch}_2',
        title: 'Create event budget',
        description: 'Develop a comprehensive budget for the event',
        categoryId: '1', // Planning category
        dueDate: eventDate.subtract(const Duration(days: 180)),
        status: TaskStatus.notStarted,
        isImportant: true,
      ),
    );

    // 4-6 Months Before
    tasks.add(
      Task(
        id: 'business_task_${DateTime.now().millisecondsSinceEpoch}_3',
        title: 'Book venue',
        description: 'Select and reserve appropriate venue',
        categoryId: '2', // Venue category
        dueDate: eventDate.subtract(const Duration(days: 150)),
        status: TaskStatus.notStarted,
        isImportant: true,
      ),
    );

    tasks.add(
      Task(
        id: 'business_task_${DateTime.now().millisecondsSinceEpoch}_4',
        title: 'Identify and book speakers',
        description: 'Contact and confirm keynote speakers and presenters',
        categoryId: '3', // Speakers category
        dueDate: eventDate.subtract(const Duration(days: 150)),
        status: TaskStatus.notStarted,
        isImportant: true,
      ),
    );

    // 3-4 Months Before
    tasks.add(
      Task(
        id: 'business_task_${DateTime.now().millisecondsSinceEpoch}_5',
        title: 'Develop marketing plan',
        description: 'Create strategy for promoting the event',
        categoryId: '4', // Marketing category
        dueDate: eventDate.subtract(const Duration(days: 120)),
        status: TaskStatus.notStarted,
        isImportant: true,
      ),
    );

    tasks.add(
      Task(
        id: 'business_task_${DateTime.now().millisecondsSinceEpoch}_6',
        title: 'Book catering services',
        description: 'Select menu and catering provider',
        categoryId: '5', // Catering category
        dueDate: eventDate.subtract(const Duration(days: 120)),
        status: TaskStatus.notStarted,
        isImportant: true,
      ),
    );

    // 2-3 Months Before
    tasks.add(
      Task(
        id: 'business_task_${DateTime.now().millisecondsSinceEpoch}_7',
        title: 'Arrange AV equipment',
        description: 'Book audio/visual equipment and technicians',
        categoryId: '6', // Technical category
        dueDate: eventDate.subtract(const Duration(days: 90)),
        status: TaskStatus.notStarted,
        isImportant: true,
      ),
    );

    tasks.add(
      Task(
        id: 'business_task_${DateTime.now().millisecondsSinceEpoch}_8',
        title: 'Send invitations',
        description: 'Distribute event invitations to attendees',
        categoryId: '7', // Communications category
        dueDate: eventDate.subtract(const Duration(days: 90)),
        status: TaskStatus.notStarted,
        isImportant: true,
      ),
    );

    // 1-2 Months Before
    tasks.add(
      Task(
        id: 'business_task_${DateTime.now().millisecondsSinceEpoch}_9',
        title: 'Create event agenda',
        description: 'Develop detailed schedule for the event',
        categoryId: '1', // Planning category
        dueDate: eventDate.subtract(const Duration(days: 60)),
        status: TaskStatus.notStarted,
        isImportant: true,
      ),
    );

    tasks.add(
      Task(
        id: 'business_task_${DateTime.now().millisecondsSinceEpoch}_10',
        title: 'Arrange transportation',
        description: 'Book transportation for speakers and VIPs',
        categoryId: '8', // Logistics category
        dueDate: eventDate.subtract(const Duration(days: 45)),
        status: TaskStatus.notStarted,
        isImportant: false,
      ),
    );

    // 2-4 Weeks Before
    tasks.add(
      Task(
        id: 'business_task_${DateTime.now().millisecondsSinceEpoch}_11',
        title: 'Confirm all vendors',
        description: 'Verify details with all service providers',
        categoryId: '9', // Vendors category
        dueDate: eventDate.subtract(const Duration(days: 30)),
        status: TaskStatus.notStarted,
        isImportant: true,
      ),
    );

    tasks.add(
      Task(
        id: 'business_task_${DateTime.now().millisecondsSinceEpoch}_12',
        title: 'Prepare event materials',
        description: 'Create handouts, name badges, and signage',
        categoryId: '10', // Materials category
        dueDate: eventDate.subtract(const Duration(days: 14)),
        status: TaskStatus.notStarted,
        isImportant: true,
      ),
    );

    // 1 Week Before
    tasks.add(
      Task(
        id: 'business_task_${DateTime.now().millisecondsSinceEpoch}_13',
        title: 'Final headcount to caterer',
        description: 'Provide final attendee count to catering service',
        categoryId: '5', // Catering category
        dueDate: eventDate.subtract(const Duration(days: 7)),
        status: TaskStatus.notStarted,
        isImportant: true,
      ),
    );

    tasks.add(
      Task(
        id: 'business_task_${DateTime.now().millisecondsSinceEpoch}_14',
        title: 'Conduct team briefing',
        description: 'Brief all staff on their roles and responsibilities',
        categoryId: '1', // Planning category
        dueDate: eventDate.subtract(const Duration(days: 3)),
        status: TaskStatus.notStarted,
        isImportant: true,
      ),
    );

    return tasks;
  }
}
