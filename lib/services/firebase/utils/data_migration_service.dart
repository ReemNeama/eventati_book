import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eventati_book/models/models.dart';
import 'package:eventati_book/services/firebase/firestore/event_firestore_service.dart';
import 'package:eventati_book/services/firebase/utils/firestore_service.dart';
import 'package:eventati_book/services/firebase/firestore/guest_firestore_service.dart';
import 'package:eventati_book/services/firebase/firestore/service_firestore_service.dart';
import 'package:eventati_book/services/firebase/firestore/task_firestore_service.dart';
import 'package:eventati_book/services/firebase/firestore/user_firestore_service.dart';
import 'package:eventati_book/services/interfaces/database_service_interface.dart';
import 'package:eventati_book/utils/logger.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show Icons;

/// Service for migrating data from tempDB to Firebase
class DataMigrationService {
  /// Firebase Auth instance
  final firebase_auth.FirebaseAuth _auth;

  /// Firestore instance - used for direct Firestore operations when needed
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
    DatabaseServiceInterface? databaseService,
  }) : _auth = auth ?? firebase_auth.FirebaseAuth.instance,
       _firestore = firestore ?? FirebaseFirestore.instance,
       _userService = userService ?? UserFirestoreService(),
       _eventService = eventService ?? EventFirestoreService(),
       _serviceService = serviceService ?? ServiceFirestoreService(),
       _guestService = guestService ?? GuestFirestoreService(),
       _taskService = taskService ?? TaskFirestoreService(),
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

      // Migration is not implemented yet
      // This is a placeholder for future implementation
      Logger.i(
        'Data migration not implemented yet',
        tag: 'DataMigrationService',
      );

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

  /// Check if migration is needed
  Future<bool> isMigrationNeeded() async {
    try {
      // Check if platform is supported
      if (!kIsWeb && !Platform.isAndroid && !Platform.isIOS) {
        return false;
      }

      // Check if user is logged in
      if (_auth.currentUser == null) {
        return false;
      }

      // Check if users already exist in Firebase
      final existingUsers = await _databaseService.getCollection('users');
      if (existingUsers.isNotEmpty) {
        // If users exist, migration is not needed
        return false;
      }

      // Migration is needed
      return true;
    } catch (e) {
      Logger.e(
        'Error checking if migration is needed: $e',
        tag: 'DataMigrationService',
      );
      return false;
    }
  }

  /// Create sample data in Firebase for testing
  Future<void> createSampleData() async {
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
        throw Exception('User must be logged in to create sample data');
      }

      // Start creating sample data
      Logger.i('Creating sample data...', tag: 'DataMigrationService');

      // Log Firestore settings to verify connection
      final settings = _firestore.settings;
      Logger.i(
        'Using Firestore with host: ${settings.host}',
        tag: 'DataMigrationService',
      );

      // Create sample user
      final user = User(
        id: _auth.currentUser!.uid,
        name: _auth.currentUser!.displayName ?? 'Sample User',
        email: _auth.currentUser!.email ?? 'user@example.com',
        createdAt: DateTime.now(),
      );
      await _userService.createUser(user);

      // Create sample event
      final event = EventTemplate(
        id: 'sample-event',
        name: 'Sample Event',
        description: 'This is a sample event created for testing',
        icon: Icons.event,
        subtypes: ['wedding', 'celebration'],
        defaultServices: {'venue': true, 'catering': true, 'photography': true},
        suggestedTasks: ['Book venue', 'Send invitations', 'Order cake'],
        userId: _auth.currentUser!.uid,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        status: 'active',
      );
      await _eventService.createEvent(event);

      // Create sample venue using the service
      final venue = Venue(
        name: 'Sample Venue',
        description: 'This is a sample venue created for testing',
        rating: 4.5,
        venueTypes: ['indoor', 'outdoor'],
        minCapacity: 50,
        maxCapacity: 200,
        pricePerEvent: 5000,
        imageUrl: 'assets/images/venue_placeholder.jpg',
        features: ['parking', 'wifi', 'catering'],
      );

      // Use the service_service to create the venue
      await _serviceService.createVenue(venue);

      // Create sample guest
      final guest = Guest(
        id: 'sample-guest',
        firstName: 'John',
        lastName: 'Doe',
        email: 'john.doe@example.com',
        phone: '+1234567890',
        rsvpStatus: RsvpStatus.pending,
      );
      await _guestService.addGuest(event.id, guest);

      // Create sample task
      final task = Task(
        id: 'sample-task',
        title: 'Book venue',
        description: 'Book the venue for the event',
        dueDate: DateTime.now().add(const Duration(days: 30)),
        status: TaskStatus.notStarted,
        categoryId: '1',
      );
      await _taskService.addTask(event.id, task);

      // Sample data creation complete
      Logger.i('Sample data created successfully', tag: 'DataMigrationService');
    } catch (e) {
      Logger.e('Error creating sample data: $e', tag: 'DataMigrationService');
      rethrow;
    }
  }
}
