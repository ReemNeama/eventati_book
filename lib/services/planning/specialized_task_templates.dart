import 'package:eventati_book/models/planning_models/task.dart';
import 'package:eventati_book/utils/logger.dart';

/// Service for providing specialized task templates based on event type and requirements
class SpecializedTaskTemplates {
  /// Get specialized tasks for a specific event type
  static List<Task> getSpecializedTasks(
    String eventType,
    DateTime eventDate,
    Map<String, bool> selectedServices,
    int guestCount,
  ) {
    Logger.i(
      'Getting specialized tasks for $eventType event',
      tag: 'SpecializedTaskTemplates',
    );
    
    final specializedTasks = <Task>[];
    
    // Add event type specific tasks
    if (eventType.toLowerCase().contains('wedding')) {
      specializedTasks.addAll(_getWeddingTasks(eventDate));
    } else if (eventType.toLowerCase().contains('business')) {
      specializedTasks.addAll(_getBusinessEventTasks(eventDate));
    } else {
      // For other celebration events, add basic tasks
      specializedTasks.addAll(_getCelebrationTasks(eventDate));
    }
    
    // Add tasks based on guest count
    specializedTasks.addAll(_getGuestCountBasedTasks(guestCount, eventDate));
    
    // Add tasks based on selected services
    specializedTasks.addAll(_getServiceBasedTasks(selectedServices, eventDate, guestCount));
    
    return specializedTasks;
  }
  
  /// Get specialized wedding tasks
  static List<Task> _getWeddingTasks(DateTime eventDate) {
    return [
      Task(
        id: 'wedding_specialized_1_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Create wedding website',
        description: 'Set up a website with wedding details for guests',
        categoryId: '1', // Planning category
        dueDate: eventDate.subtract(const Duration(days: 180)),
        status: TaskStatus.notStarted,
        isImportant: false,
      ),
      Task(
        id: 'wedding_specialized_2_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Plan rehearsal dinner',
        description: 'Organize rehearsal dinner for wedding party',
        categoryId: '2', // Event category
        dueDate: eventDate.subtract(const Duration(days: 60)),
        status: TaskStatus.notStarted,
        isImportant: true,
      ),
      Task(
        id: 'wedding_specialized_3_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Arrange transportation',
        description: 'Book transportation for wedding party and guests',
        categoryId: '3', // Logistics category
        dueDate: eventDate.subtract(const Duration(days: 45)),
        status: TaskStatus.notStarted,
        isImportant: true,
      ),
      Task(
        id: 'wedding_specialized_4_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Finalize vows',
        description: 'Write and finalize wedding vows',
        categoryId: '4', // Ceremony category
        dueDate: eventDate.subtract(const Duration(days: 30)),
        status: TaskStatus.notStarted,
        isImportant: true,
      ),
      Task(
        id: 'wedding_specialized_5_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Create seating chart',
        description: 'Organize guest seating arrangements',
        categoryId: '5', // Reception category
        dueDate: eventDate.subtract(const Duration(days: 21)),
        status: TaskStatus.notStarted,
        isImportant: true,
      ),
    ];
  }
  
  /// Get specialized business event tasks
  static List<Task> _getBusinessEventTasks(DateTime eventDate) {
    return [
      Task(
        id: 'business_specialized_1_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Create event branding',
        description: 'Design logos and branding materials for the event',
        categoryId: '1', // Planning category
        dueDate: eventDate.subtract(const Duration(days: 90)),
        status: TaskStatus.notStarted,
        isImportant: true,
      ),
      Task(
        id: 'business_specialized_2_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Develop marketing plan',
        description: 'Create strategy to promote the event',
        categoryId: '6', // Marketing category
        dueDate: eventDate.subtract(const Duration(days: 120)),
        status: TaskStatus.notStarted,
        isImportant: true,
      ),
      Task(
        id: 'business_specialized_3_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Arrange networking activities',
        description: 'Plan structured networking opportunities',
        categoryId: '7', // Activities category
        dueDate: eventDate.subtract(const Duration(days: 45)),
        status: TaskStatus.notStarted,
        isImportant: true,
      ),
      Task(
        id: 'business_specialized_4_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Prepare event materials',
        description: 'Create handouts, presentations, and other materials',
        categoryId: '8', // Materials category
        dueDate: eventDate.subtract(const Duration(days: 30)),
        status: TaskStatus.notStarted,
        isImportant: true,
      ),
    ];
  }
  
  /// Get specialized celebration tasks
  static List<Task> _getCelebrationTasks(DateTime eventDate) {
    return [
      Task(
        id: 'celebration_specialized_1_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Create event timeline',
        description: 'Develop a detailed schedule for the celebration',
        categoryId: '1', // Planning category
        dueDate: eventDate.subtract(const Duration(days: 60)),
        status: TaskStatus.notStarted,
        isImportant: true,
      ),
      Task(
        id: 'celebration_specialized_2_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Plan entertainment',
        description: 'Arrange music, games, or other entertainment',
        categoryId: '3', // Entertainment category
        dueDate: eventDate.subtract(const Duration(days: 45)),
        status: TaskStatus.notStarted,
        isImportant: true,
      ),
      Task(
        id: 'celebration_specialized_3_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Arrange decorations',
        description: 'Plan and purchase decorations for the event',
        categoryId: '5', // Decor category
        dueDate: eventDate.subtract(const Duration(days: 30)),
        status: TaskStatus.notStarted,
        isImportant: true,
      ),
    ];
  }
  
  /// Get tasks based on guest count
  static List<Task> _getGuestCountBasedTasks(int guestCount, DateTime eventDate) {
    final tasks = <Task>[];
    
    if (guestCount > 150) {
      tasks.add(
        Task(
          id: 'guest_count_task_1_${DateTime.now().millisecondsSinceEpoch}',
          title: 'Arrange additional seating',
          description: 'Ensure adequate seating for large guest count',
          categoryId: '5', // Logistics category
          dueDate: eventDate.subtract(const Duration(days: 30)),
          status: TaskStatus.notStarted,
          isImportant: true,
        ),
      );
      
      // For very large events, add crowd management tasks
      if (guestCount > 250) {
        tasks.add(
          Task(
            id: 'guest_count_task_2_${DateTime.now().millisecondsSinceEpoch}',
            title: 'Hire event staff',
            description: 'Arrange for additional staff for large event',
            categoryId: '6', // Staff category
            dueDate: eventDate.subtract(const Duration(days: 60)),
            status: TaskStatus.notStarted,
            isImportant: true,
          ),
        );
        
        tasks.add(
          Task(
            id: 'guest_count_task_3_${DateTime.now().millisecondsSinceEpoch}',
            title: 'Create crowd flow plan',
            description: 'Plan traffic flow and crowd management',
            categoryId: '5', // Logistics category
            dueDate: eventDate.subtract(const Duration(days: 45)),
            status: TaskStatus.notStarted,
            isImportant: true,
          ),
        );
      }
    }
    
    return tasks;
  }
  
  /// Get tasks based on selected services
  static List<Task> _getServiceBasedTasks(
    Map<String, bool> selectedServices,
    DateTime eventDate,
    int guestCount,
  ) {
    final tasks = <Task>[];
    
    // Add catering-specific tasks
    if (selectedServices['Catering'] == true) {
      tasks.addAll(_getCateringTasks(eventDate, guestCount));
    }
    
    // Add photography/videography-specific tasks
    if (selectedServices['Photography'] == true ||
        selectedServices['Videography'] == true ||
        selectedServices['Photography/Videography'] == true) {
      tasks.addAll(_getPhotographyTasks(eventDate));
    }
    
    return tasks;
  }
  
  /// Get catering-specific tasks
  static List<Task> _getCateringTasks(DateTime eventDate, int guestCount) {
    final tasks = <Task>[];
    
    tasks.add(
      Task(
        id: 'catering_task_1_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Finalize menu selections',
        description: 'Confirm final menu choices with caterer',
        categoryId: '6', // Vendors category
        dueDate: eventDate.subtract(const Duration(days: 45)),
        status: TaskStatus.notStarted,
        isImportant: true,
      ),
    );
    
    if (guestCount > 100) {
      tasks.add(
        Task(
          id: 'catering_task_2_${DateTime.now().millisecondsSinceEpoch}',
          title: 'Confirm catering staff count',
          description: 'Ensure adequate staff for large guest count',
          categoryId: '6', // Vendors category
          dueDate: eventDate.subtract(const Duration(days: 21)),
          status: TaskStatus.notStarted,
          isImportant: false,
        ),
      );
    }
    
    // Add dietary restrictions task
    tasks.add(
      Task(
        id: 'catering_task_3_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Collect dietary restrictions',
        description: 'Gather special dietary needs from guests',
        categoryId: '6', // Vendors category
        dueDate: eventDate.subtract(const Duration(days: 30)),
        status: TaskStatus.notStarted,
        isImportant: true,
      ),
    );
    
    return tasks;
  }
  
  /// Get photography-specific tasks
  static List<Task> _getPhotographyTasks(DateTime eventDate) {
    return [
      Task(
        id: 'photo_task_1_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Create shot list',
        description: 'Prepare list of must-have photos/videos',
        categoryId: '7', // Photography category
        dueDate: eventDate.subtract(const Duration(days: 30)),
        status: TaskStatus.notStarted,
        isImportant: true,
      ),
      Task(
        id: 'photo_task_2_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Scout photo locations',
        description: 'Identify key spots for photos/videos',
        categoryId: '7', // Photography category
        dueDate: eventDate.subtract(const Duration(days: 14)),
        status: TaskStatus.notStarted,
        isImportant: false,
      ),
    ];
  }
}
