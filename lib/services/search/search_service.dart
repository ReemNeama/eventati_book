import 'package:eventati_book/models/models.dart';
import 'package:eventati_book/services/supabase/database/event_database_service.dart';
import 'package:eventati_book/services/supabase/database/service_database_service.dart';
import 'package:eventati_book/services/supabase/database/task_database_service.dart';
import 'package:eventati_book/utils/logger.dart';

/// Class to hold search results across all features
class SearchResults {
  final List<Event> events;
  final List<Service> services;
  final List<Task> tasks;
  final List<BudgetItem> budgetItems;
  final List<Guest> guests;
  final List<Booking> bookings;

  SearchResults({
    this.events = const [],
    this.services = const [],
    this.tasks = const [],
    this.budgetItems = const [],
    this.guests = const [],
    this.bookings = const [],
  });

  /// Get the total number of results
  int get totalResults =>
      events.length +
      services.length +
      tasks.length +
      budgetItems.length +
      guests.length +
      bookings.length;

  /// Check if there are any results
  bool get hasResults => totalResults > 0;

  /// Create an empty search results object
  factory SearchResults.empty() => SearchResults();
}

/// Service for searching across all features
class SearchService {
  final EventDatabaseService _eventDatabaseService = EventDatabaseService();
  final ServiceDatabaseService _serviceDatabaseService =
      ServiceDatabaseService();
  final TaskDatabaseService _taskDatabaseService = TaskDatabaseService();

  // These services are currently not used directly but will be needed for future implementation
  // Keeping them commented out until they're implemented
  // final BudgetDatabaseService _budgetDatabaseService = BudgetDatabaseService();
  // final GuestDatabaseService _guestDatabaseService = GuestDatabaseService();
  // final BookingDatabaseService _bookingDatabaseService = BookingDatabaseService();

  /// Search across all features
  Future<SearchResults> search(String query, String userId) async {
    if (query.isEmpty) {
      return SearchResults.empty();
    }

    try {
      // Search events
      final events = await _searchEvents(query, userId);

      // Search services
      final services = await _searchServices(query);

      // Search tasks
      final tasks = await _searchTasks(query, userId);

      // Search budget items
      final budgetItems = await _searchBudgetItems(query, userId);

      // Search guests
      final guests = await _searchGuests(query, userId);

      // Search bookings
      final bookings = await _searchBookings(query, userId);

      return SearchResults(
        events: events,
        services: services,
        tasks: tasks,
        budgetItems: budgetItems,
        guests: guests,
        bookings: bookings,
      );
    } catch (e) {
      Logger.e('Error performing global search: $e', tag: 'SearchService');
      return SearchResults.empty();
    }
  }

  /// Search events by name, location, or description
  Future<List<Event>> _searchEvents(String query, String userId) async {
    try {
      return await _eventDatabaseService.searchEvents(userId, query);
    } catch (e) {
      Logger.e('Error searching events: $e', tag: 'SearchService');
      return [];
    }
  }

  /// Search services by name or description
  Future<List<Service>> _searchServices(String query) async {
    try {
      return await _serviceDatabaseService.searchServices(query);
    } catch (e) {
      Logger.e('Error searching services: $e', tag: 'SearchService');
      return [];
    }
  }

  /// Search tasks by title or description
  Future<List<Task>> _searchTasks(String query, String userId) async {
    try {
      // Since searchTasks is not implemented in TaskDatabaseService,
      // we'll implement a basic search here using getTasks
      final allTasks = await _taskDatabaseService.getTasks(userId);

      // Filter tasks based on the query
      return allTasks.where((task) {
        final title = task.title.toLowerCase();
        final description = task.description?.toLowerCase() ?? '';
        final searchQuery = query.toLowerCase();

        return title.contains(searchQuery) || description.contains(searchQuery);
      }).toList();
    } catch (e) {
      Logger.e('Error searching tasks: $e', tag: 'SearchService');
      return [];
    }
  }

  /// Search budget items by name or category
  Future<List<BudgetItem>> _searchBudgetItems(
    String query,
    String userId,
  ) async {
    try {
      // Since searchBudgetItems is not implemented in BudgetDatabaseService,
      // we'll implement a basic search here
      // This is a placeholder implementation - in a real app, you would
      // fetch budget items from the database and filter them

      // For now, return an empty list as we don't have access to the actual implementation
      return [];

      // In a real implementation, you would do something like:
      // final allBudgetItems = await _budgetDatabaseService.getBudgetItems(userId);
      // return allBudgetItems.where((item) {
      //   final name = item.name.toLowerCase();
      //   final category = item.category.toLowerCase();
      //   final searchQuery = query.toLowerCase();
      //   return name.contains(searchQuery) || category.contains(searchQuery);
      // }).toList();
    } catch (e) {
      Logger.e('Error searching budget items: $e', tag: 'SearchService');
      return [];
    }
  }

  /// Search guests by name or email
  Future<List<Guest>> _searchGuests(String query, String userId) async {
    try {
      // Since searchGuests is not implemented in GuestDatabaseService,
      // we'll implement a basic search here
      // This is a placeholder implementation - in a real app, you would
      // fetch guests from the database and filter them

      // For now, return an empty list as we don't have access to the actual implementation
      return [];

      // In a real implementation, you would do something like:
      // final allGuests = await _guestDatabaseService.getGuests(userId);
      // return allGuests.where((guest) {
      //   final name = guest.name.toLowerCase();
      //   final email = guest.email.toLowerCase();
      //   final searchQuery = query.toLowerCase();
      //   return name.contains(searchQuery) || email.contains(searchQuery);
      // }).toList();
    } catch (e) {
      Logger.e('Error searching guests: $e', tag: 'SearchService');
      return [];
    }
  }

  /// Search bookings by service name or notes
  Future<List<Booking>> _searchBookings(String query, String userId) async {
    try {
      // Since searchBookings is not implemented in BookingDatabaseService,
      // we'll implement a basic search here
      // This is a placeholder implementation - in a real app, you would
      // fetch bookings from the database and filter them

      // For now, return an empty list as we don't have access to the actual implementation
      return [];

      // In a real implementation, you would do something like:
      // final allBookings = await _bookingDatabaseService.getBookings(userId);
      // return allBookings.where((booking) {
      //   final serviceName = booking.serviceName.toLowerCase();
      //   final notes = booking.notes?.toLowerCase() ?? '';
      //   final searchQuery = query.toLowerCase();
      //   return serviceName.contains(searchQuery) || notes.contains(searchQuery);
      // }).toList();
    } catch (e) {
      Logger.e('Error searching bookings: $e', tag: 'SearchService');
      return [];
    }
  }

  /// Search within a specific category
  Future<List<dynamic>> searchCategory(
    String query,
    String category,
    String userId,
  ) async {
    switch (category.toLowerCase()) {
      case 'events':
        return await _searchEvents(query, userId);
      case 'services':
        return await _searchServices(query);
      case 'tasks':
        return await _searchTasks(query, userId);
      case 'budget':
        return await _searchBudgetItems(query, userId);
      case 'guests':
        return await _searchGuests(query, userId);
      case 'bookings':
        return await _searchBookings(query, userId);
      default:
        return [];
    }
  }
}
