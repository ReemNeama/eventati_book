import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eventati_book/models/models.dart';
import 'package:eventati_book/services/firebase/event_firestore_service.dart';
import 'package:eventati_book/services/firebase/firestore_service.dart';
import 'package:eventati_book/services/firebase/guest_firestore_service.dart';
import 'package:eventati_book/services/firebase/service_firestore_service.dart';
import 'package:eventati_book/services/firebase/task_firestore_service.dart';
import 'package:eventati_book/services/firebase/user_firestore_service.dart';
import 'package:eventati_book/services/interfaces/database_service_interface.dart';
import 'package:eventati_book/utils/logger.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Service for migrating data from tempDB to Firebase
class DataMigrationService {
  /// Firebase Auth instance
  final firebase_auth.FirebaseAuth _auth;

  /// Firestore instance
  final FirebaseFirestore _firestore;

  /// User Firestore service
  final UserFirestoreService _userService;

  /// Event Firestore service
  final EventFirestoreService _eventService;

  /// Service Firestore service
  final ServiceFirestoreService _serviceService;

  /// Guest Firestore service
  final GuestFirestoreService _guestService;

  /// Task Firestore service
  final TaskFirestoreService _taskService;

  /// Booking Firestore service
  final BookingFirestoreService _bookingService;

  /// Database service
  final DatabaseServiceInterface _databaseService;

  /// Constructor
  DataMigrationService({
    firebase_auth.FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    UserFirestoreService? userService,
    EventFirestoreService? eventService,
    ServiceFirestoreService? serviceService,
    GuestFirestoreService? guestService,
    TaskFirestoreService? taskService,
    BookingFirestoreService? bookingService,
    DatabaseServiceInterface? databaseService,
  }) : _auth = auth ?? firebase_auth.FirebaseAuth.instance,
       _firestore = firestore ?? FirebaseFirestore.instance,
       _userService = userService ?? UserFirestoreService(),
       _eventService = eventService ?? EventFirestoreService(),
       _serviceService = serviceService ?? ServiceFirestoreService(),
       _guestService = guestService ?? GuestFirestoreService(),
       _taskService = taskService ?? TaskFirestoreService(),
       _bookingService = bookingService ?? BookingFirestoreService(),
       _databaseService = databaseService ?? FirestoreService();

  /// Migrate all data from tempDB to Firebase
  Future<void> migrateAllData() async {
    try {
      // Check if platform is supported
      if (!kIsWeb && !Platform.isAndroid && !Platform.isIOS) {
        Logger.i(
          'Firebase is not supported on this platform',
          tag: 'DataMigrationService',
        );
        return;
      }

      // Check if user is logged in
      if (_auth.currentUser == null) {
        throw Exception('User must be logged in to migrate data');
      }

      // Start migration
      Logger.i('Starting data migration...', tag: 'DataMigrationService');

      // Migrate users
      await _migrateUsers();

      // Migrate venues
      await _migrateVenues();

      // Migrate services
      await _migrateServices();

      // Migrate events
      await _migrateEvents();

      // Migrate budget items
      await _migrateBudgetItems();

      // Migrate guests
      await _migrateGuests();

      // Migrate tasks
      await _migrateTasks();

      // Migrate messages
      await _migrateMessages();

      // Migration complete
      Logger.i(
        'Data migration completed successfully',
        tag: 'DataMigrationService',
      );
    } catch (e) {
      Logger.e('Error migrating data: $e', tag: 'DataMigrationService');
      rethrow;
    }
  }

  /// Migrate users from tempDB to Firebase
  Future<void> _migrateUsers() async {
    try {
      Logger.i('Migrating users...', tag: 'DataMigrationService');

      // Get users from tempDB
      final users = UserDB.getUsers();

      // Check if users already exist in Firebase
      final existingUsers = await _databaseService.getCollection('users');
      if (existingUsers.isNotEmpty) {
        Logger.i(
          'Users already exist in Firebase, skipping migration',
          tag: 'DataMigrationService',
        );
        return;
      }

      // Migrate each user
      for (final user in users) {
        await _userService.createUser(user);
      }

      Logger.i('Migrated ${users.length} users', tag: 'DataMigrationService');
    } catch (e) {
      Logger.e('Error migrating users: $e', tag: 'DataMigrationService');
      rethrow;
    }
  }

  /// Migrate venues from tempDB to Firebase
  Future<void> _migrateVenues() async {
    try {
      Logger.i('Migrating venues...', tag: 'DataMigrationService');

      // Get venues from tempDB
      final venues = VenueDB.getVenues();

      // Check if venues already exist in Firebase
      final existingVenues = await _databaseService.getCollection(
        'services/venues',
      );
      if (existingVenues.isNotEmpty) {
        Logger.i(
          'Venues already exist in Firebase, skipping migration',
          tag: 'DataMigrationService',
        );
        return;
      }

      // Migrate each venue
      for (final venueData in venues) {
        // Convert to Venue model
        final venue = Venue(
          name: venueData['name'] ?? '',
          description: venueData['description'] ?? '',
          rating: (venueData['rating'] ?? 0).toDouble(),
          venueTypes: List<String>.from(venueData['features'] ?? []),
          minCapacity: 50, // Default value
          maxCapacity: venueData['capacity'] ?? 100,
          pricePerEvent: 1000, // Default value
          imageUrl:
              venueData['imageUrls']?.isNotEmpty == true
                  ? venueData['imageUrls'][0]
                  : 'assets/images/venue_placeholder.jpg',
          features: List<String>.from(venueData['features'] ?? []),
        );

        // Add to Firebase
        await _serviceService.addVenue(venue);
      }

      Logger.i('Migrated ${venues.length} venues', tag: 'DataMigrationService');
    } catch (e) {
      Logger.e('Error migrating venues: $e', tag: 'DataMigrationService');
      rethrow;
    }
  }

  /// Migrate services from tempDB to Firebase
  Future<void> _migrateServices() async {
    try {
      Logger.i('Migrating services...', tag: 'DataMigrationService');

      // Migrate catering services
      await _migrateCateringServices();

      // Migrate photography services
      await _migratePhotographyServices();

      Logger.i('Services migration completed', tag: 'DataMigrationService');
    } catch (e) {
      Logger.e('Error migrating services: $e', tag: 'DataMigrationService');
      rethrow;
    }
  }

  /// Migrate catering services from tempDB to Firebase
  Future<void> _migrateCateringServices() async {
    try {
      // Get catering services from tempDB
      final cateringServices = ServiceDB.getCateringServices();

      // Check if catering services already exist in Firebase
      final existingServices = await _databaseService.getCollection(
        'services/catering',
      );
      if (existingServices.isNotEmpty) {
        Logger.i(
          'Catering services already exist in Firebase, skipping migration',
          tag: 'DataMigrationService',
        );
        return;
      }

      // Migrate each catering service
      for (final serviceData in cateringServices) {
        // Convert to CateringService model
        final service = CateringService(
          name: serviceData['name'] ?? '',
          description: serviceData['description'] ?? '',
          rating: (serviceData['rating'] ?? 0).toDouble(),
          cuisineTypes: List<String>.from(serviceData['cuisineTypes'] ?? []),
          pricePerPerson:
              (serviceData['priceRange'] ?? '\$\$').length *
              25.0, // Estimate based on price range
          imageUrl: 'assets/images/catering_placeholder.jpg',
          dietaryOptions: List<String>.from(
            serviceData['dietaryOptions'] ?? [],
          ),
        );

        // Add to Firebase
        await _serviceService.addCateringService(service);
      }

      Logger.i(
        'Migrated ${cateringServices.length} catering services',
        tag: 'DataMigrationService',
      );
    } catch (e) {
      Logger.e(
        'Error migrating catering services: $e',
        tag: 'DataMigrationService',
      );
      rethrow;
    }
  }

  /// Migrate photography services from tempDB to Firebase
  Future<void> _migratePhotographyServices() async {
    try {
      // Get photography services from tempDB
      final photographyServices = ServiceDB.getPhotographyServices();

      // Check if photography services already exist in Firebase
      final existingServices = await _databaseService.getCollection(
        'services/photography',
      );
      if (existingServices.isNotEmpty) {
        Logger.i(
          'Photography services already exist in Firebase, skipping migration',
          tag: 'DataMigrationService',
        );
        return;
      }

      // Migrate each photography service
      for (final serviceData in photographyServices) {
        // Convert to Photographer model
        final service = Photographer(
          name: serviceData['name'] ?? '',
          description: serviceData['description'] ?? '',
          rating: (serviceData['rating'] ?? 0).toDouble(),
          styles: List<String>.from(serviceData['specialties'] ?? []),
          pricePerEvent:
              (serviceData['priceRange'] ?? '\$\$').length *
              500.0, // Estimate based on price range
          imageUrl: 'assets/images/photography_placeholder.jpg',
          equipment: [
            'DSLR Camera',
            'Lighting Equipment',
            'Tripod',
          ], // Default equipment
          packages: List<String>.from(
            (serviceData['packages'] as List<dynamic>? ?? [])
                .map((package) => package['name'] ?? '')
                .toList(),
          ),
        );

        // Add to Firebase
        await _serviceService.addPhotographer(service);
      }

      Logger.i(
        'Migrated ${photographyServices.length} photography services',
        tag: 'DataMigrationService',
      );
    } catch (e) {
      Logger.e(
        'Error migrating photography services: $e',
        tag: 'DataMigrationService',
      );
      rethrow;
    }
  }

  /// Migrate events from tempDB to Firebase
  Future<void> _migrateEvents() async {
    try {
      Logger.i('Migrating events...', tag: 'DataMigrationService');

      // Get events from tempDB
      final events = EventDB.getEvents();

      // Check if events already exist in Firebase
      final existingEvents = await _databaseService.getCollection('events');
      if (existingEvents.isNotEmpty) {
        Logger.i(
          'Events already exist in Firebase, skipping migration',
          tag: 'DataMigrationService',
        );
        return;
      }

      // Migrate each event
      for (final eventData in events) {
        // Convert to EventTemplate model
        final event = EventTemplate(
          id: eventData['id'] ?? '',
          name: eventData['name'] ?? '',
          description: eventData['description'] ?? '',
          icon: Icons.event,
          subtypes: List<String>.from(eventData['subtypes'] ?? []),
          defaultServices: Map<String, bool>.from(
            eventData['defaultServices'] ?? {},
          ),
          suggestedTasks: List<String>.from(eventData['suggestedTasks'] ?? []),
          userId: eventData['userId'] ?? _auth.currentUser?.uid,
          createdAt:
              eventData['createdAt'] != null
                  ? DateTime.parse(eventData['createdAt'])
                  : DateTime.now(),
          updatedAt:
              eventData['updatedAt'] != null
                  ? DateTime.parse(eventData['updatedAt'])
                  : DateTime.now(),
          status: eventData['status'] ?? 'active',
        );

        // Add to Firebase
        await _eventService.createEvent(event);
      }

      Logger.i('Migrated ${events.length} events', tag: 'DataMigrationService');
    } catch (e) {
      Logger.e('Error migrating events: $e', tag: 'DataMigrationService');
      rethrow;
    }
  }

  /// Migrate budget items from tempDB to Firebase
  Future<void> _migrateBudgetItems() async {
    try {
      Logger.i('Migrating budget items...', tag: 'DataMigrationService');

      // Get budget items from tempDB
      final budgetItems = BudgetDB.getBudgetItems();

      // Get events from Firebase
      final events = await _databaseService.getCollection('events');
      if (events.isEmpty) {
        Logger.i(
          'No events found in Firebase, skipping budget items migration',
          tag: 'DataMigrationService',
        );
        return;
      }

      // Check if budget items already exist for the first event
      final firstEventId = events[0]['id'] ?? '';
      final existingBudgetItems = await _databaseService.getSubcollection(
        'events',
        firstEventId,
        'budget_items',
      );
      if (existingBudgetItems.isNotEmpty) {
        Logger.i(
          'Budget items already exist in Firebase, skipping migration',
          tag: 'DataMigrationService',
        );
        return;
      }

      // Migrate budget items for each event
      for (final event in events) {
        final eventId = event['id'] ?? '';

        // Migrate each budget item
        for (final itemData in budgetItems) {
          // Convert to BudgetItem model
          final item = BudgetItem(
            id: itemData['id'] ?? '',
            name: itemData['name'] ?? '',
            category: itemData['category'] ?? '',
            estimatedCost: (itemData['estimatedCost'] ?? 0).toDouble(),
            actualCost: (itemData['actualCost'] ?? 0).toDouble(),
            isPaid: itemData['isPaid'] ?? false,
            notes: itemData['notes'] ?? '',
            dueDate:
                itemData['dueDate'] != null
                    ? DateTime.parse(itemData['dueDate'])
                    : null,
            vendorName: itemData['vendorName'] ?? '',
            vendorContact: itemData['vendorContact'] ?? '',
          );

          // Add to Firebase
          await _firestore
              .collection('events')
              .doc(eventId)
              .collection('budget_items')
              .add({
                'name': item.name,
                'category': item.category,
                'estimatedCost': item.estimatedCost,
                'actualCost': item.actualCost,
                'isPaid': item.isPaid,
                'notes': item.notes,
                'dueDate':
                    item.dueDate != null
                        ? Timestamp.fromDate(item.dueDate!)
                        : null,
                'vendorName': item.vendorName,
                'vendorContact': item.vendorContact,
                'createdAt': FieldValue.serverTimestamp(),
                'updatedAt': FieldValue.serverTimestamp(),
              });
        }
      }

      Logger.i(
        'Migrated ${budgetItems.length} budget items for ${events.length} events',
        tag: 'DataMigrationService',
      );
    } catch (e) {
      Logger.e('Error migrating budget items: $e', tag: 'DataMigrationService');
      rethrow;
    }
  }

  /// Migrate guests from tempDB to Firebase
  Future<void> _migrateGuests() async {
    try {
      Logger.i('Migrating guests...', tag: 'DataMigrationService');

      // Get guests from tempDB
      final guests = GuestDB.getGuests();

      // Get events from Firebase
      final events = await _databaseService.getCollection('events');
      if (events.isEmpty) {
        Logger.i(
          'No events found in Firebase, skipping guests migration',
          tag: 'DataMigrationService',
        );
        return;
      }

      // Check if guests already exist for the first event
      final firstEventId = events[0]['id'] ?? '';
      final existingGuests = await _databaseService.getSubcollection(
        'events',
        firstEventId,
        'guests',
      );
      if (existingGuests.isNotEmpty) {
        Logger.i(
          'Guests already exist in Firebase, skipping migration',
          tag: 'DataMigrationService',
        );
        return;
      }

      // Migrate guests for each event
      for (final event in events) {
        final eventId = event['id'] ?? '';

        // Migrate each guest
        for (final guestData in guests) {
          // Convert to Guest model
          final guest = Guest(
            id: guestData['id'] ?? '',
            firstName: guestData['firstName'] ?? '',
            lastName: guestData['lastName'] ?? '',
            email: guestData['email'],
            phone: guestData['phone'],
            groupId: guestData['groupId'],
            rsvpStatus: _parseRsvpStatus(guestData['rsvpStatus']),
            rsvpResponseDate:
                guestData['rsvpResponseDate'] != null
                    ? DateTime.parse(guestData['rsvpResponseDate'])
                    : null,
            plusOne: guestData['plusOne'] ?? false,
            plusOneCount: guestData['plusOneCount'],
            notes: guestData['notes'],
          );

          // Add to Firebase
          await _guestService.addGuest(eventId, guest);
        }
      }

      Logger.i(
        'Migrated ${guests.length} guests for ${events.length} events',
        tag: 'DataMigrationService',
      );
    } catch (e) {
      Logger.e('Error migrating guests: $e', tag: 'DataMigrationService');
      rethrow;
    }
  }

  /// Parse RSVP status from string
  RsvpStatus _parseRsvpStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'attending':
        return RsvpStatus.attending;
      case 'declined':
        return RsvpStatus.declined;
      case 'maybe':
        return RsvpStatus.maybe;
      default:
        return RsvpStatus.pending;
    }
  }

  /// Migrate tasks from tempDB to Firebase
  Future<void> _migrateTasks() async {
    try {
      Logger.i('Migrating tasks...', tag: 'DataMigrationService');

      // Get tasks from tempDB
      final tasks = TaskDB.getTasks();

      // Get events from Firebase
      final events = await _databaseService.getCollection('events');
      if (events.isEmpty) {
        Logger.i(
          'No events found in Firebase, skipping tasks migration',
          tag: 'DataMigrationService',
        );
        return;
      }

      // Check if tasks already exist for the first event
      final firstEventId = events[0]['id'] ?? '';
      final existingTasks = await _databaseService.getSubcollection(
        'events',
        firstEventId,
        'tasks',
      );
      if (existingTasks.isNotEmpty) {
        Logger.i(
          'Tasks already exist in Firebase, skipping migration',
          tag: 'DataMigrationService',
        );
        return;
      }

      // Migrate tasks for each event
      for (final event in events) {
        final eventId = event['id'] ?? '';

        // Migrate each task
        for (final taskData in tasks) {
          // Convert to Task model
          final task = Task(
            id: taskData['id'] ?? '',
            title: taskData['title'] ?? '',
            description: taskData['description'] ?? '',
            dueDate:
                taskData['dueDate'] != null
                    ? DateTime.parse(taskData['dueDate'])
                    : DateTime.now().add(const Duration(days: 30)),
            status: _parseTaskStatus(taskData['status']),
            categoryId: taskData['categoryId'] ?? '1',
            priority: _parseTaskPriority(taskData['priority']),
            assignedTo: taskData['assignedTo'],
            completedAt:
                taskData['completedAt'] != null
                    ? DateTime.parse(taskData['completedAt'])
                    : null,
            notes: taskData['notes'],
            dependencies: List<String>.from(taskData['dependencies'] ?? []),
          );

          // Add to Firebase
          await _taskService.addTask(eventId, task);
        }
      }

      Logger.i(
        'Migrated ${tasks.length} tasks for ${events.length} events',
        tag: 'DataMigrationService',
      );
    } catch (e) {
      Logger.e('Error migrating tasks: $e', tag: 'DataMigrationService');
      rethrow;
    }
  }

  /// Parse task status from string
  TaskStatus _parseTaskStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'completed':
        return TaskStatus.completed;
      case 'in_progress':
        return TaskStatus.inProgress;
      case 'overdue':
        return TaskStatus.overdue;
      default:
        return TaskStatus.notStarted;
    }
  }

  /// Parse task priority from string
  TaskPriority _parseTaskPriority(String? priority) {
    switch (priority?.toLowerCase()) {
      case 'high':
        return TaskPriority.high;
      case 'medium':
        return TaskPriority.medium;
      case 'low':
        return TaskPriority.low;
      default:
        return TaskPriority.medium;
    }
  }

  /// Migrate messages from tempDB to Firebase
  Future<void> _migrateMessages() async {
    try {
      Logger.i('Migrating messages...', tag: 'DataMigrationService');

      // Get messages from tempDB
      final messages = MessageDB.getMessages();

      // Check if messages already exist in Firebase
      final existingMessages = await _databaseService.getCollection('messages');
      if (existingMessages.isNotEmpty) {
        Logger.i(
          'Messages already exist in Firebase, skipping migration',
          tag: 'DataMigrationService',
        );
        return;
      }

      // Migrate each message
      for (final messageData in messages) {
        // Add to Firebase
        await _firestore.collection('messages').add({
          'userId': messageData['userId'] ?? _auth.currentUser?.uid,
          'vendorId': messageData['vendorId'] ?? '',
          'eventId': messageData['eventId'] ?? '',
          'content': messageData['content'] ?? '',
          'timestamp':
              messageData['timestamp'] != null
                  ? Timestamp.fromDate(DateTime.parse(messageData['timestamp']))
                  : FieldValue.serverTimestamp(),
          'isRead': messageData['isRead'] ?? false,
          'sender': messageData['sender'] ?? 'user',
          'attachments': messageData['attachments'] ?? [],
        });
      }

      Logger.i(
        'Migrated ${messages.length} messages',
        tag: 'DataMigrationService',
      );
    } catch (e) {
      Logger.e('Error migrating messages: $e', tag: 'DataMigrationService');
      rethrow;
    }
  }
}
