import 'package:eventati_book/routing/navigation_service.dart';
import 'package:eventati_book/services/interfaces/auth_service_interface.dart';
import 'package:eventati_book/services/interfaces/database_service_interface.dart';
import 'package:eventati_book/services/interfaces/messaging_service_interface.dart';
import 'package:eventati_book/services/interfaces/storage_service_interface.dart';
import 'package:eventati_book/services/firebase/firebase_auth_service.dart';
import 'package:eventati_book/services/firebase/firebase_messaging_service.dart';
import 'package:eventati_book/services/firebase/firestore_service.dart';
import 'package:eventati_book/services/firebase/firebase_storage_service.dart';
import 'package:eventati_book/services/firebase/user_firestore_service.dart';
import 'package:eventati_book/services/firebase/event_firestore_service.dart';
import 'package:eventati_book/utils/file_utils.dart';

/// Simple service locator for dependency injection
class ServiceLocator {
  static final ServiceLocator _instance = ServiceLocator._internal();

  factory ServiceLocator() => _instance;

  ServiceLocator._internal();

  final Map<Type, dynamic> _services = {};

  /// Get a registered service
  T get<T>() {
    if (!_services.containsKey(T)) {
      throw Exception('Service of type $T not registered');
    }
    return _services[T] as T;
  }

  /// Register a singleton service
  void registerSingleton<T>(T service) {
    _services[T] = service;
  }

  /// Reset all registered services
  void reset() {
    _services.clear();
  }

  /// Initialize the service locator with default services
  void initialize() {
    // Register core services
    registerSingleton<NavigationService>(NavigationService());

    // Register Firebase services
    registerSingleton<AuthServiceInterface>(FirebaseAuthService());
    registerSingleton<DatabaseServiceInterface>(FirestoreService());
    registerSingleton<StorageServiceInterface>(FirebaseStorageService());
    registerSingleton<MessagingServiceInterface>(FirebaseMessagingService());
    registerSingleton<UserFirestoreService>(UserFirestoreService());
    registerSingleton<EventFirestoreService>(EventFirestoreService());

    // Initialize FileUtils with the storage service
    FileUtils.setStorageService(get<StorageServiceInterface>());

    // Initialize messaging service
    get<MessagingServiceInterface>().initialize();
  }

  /// Get the navigation service
  NavigationService get navigationService => get<NavigationService>();

  /// Get the authentication service
  AuthServiceInterface get authService => get<AuthServiceInterface>();

  /// Get the database service
  DatabaseServiceInterface get databaseService =>
      get<DatabaseServiceInterface>();

  /// Get the user Firestore service
  UserFirestoreService get userFirestoreService => get<UserFirestoreService>();

  /// Get the event Firestore service
  EventFirestoreService get eventFirestoreService =>
      get<EventFirestoreService>();

  /// Get the storage service
  StorageServiceInterface get storageService => get<StorageServiceInterface>();

  /// Get the messaging service
  MessagingServiceInterface get messagingService =>
      get<MessagingServiceInterface>();
}

/// Global instance of the service locator
final serviceLocator = ServiceLocator();
