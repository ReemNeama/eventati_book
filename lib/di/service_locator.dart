import 'package:eventati_book/routing/navigation_service.dart';
import 'package:eventati_book/services/interfaces/analytics_service_interface.dart';
import 'package:eventati_book/services/interfaces/auth_service_interface.dart';
import 'package:eventati_book/services/interfaces/crashlytics_service_interface.dart';
import 'package:eventati_book/services/interfaces/database_service_interface.dart';
import 'package:eventati_book/services/interfaces/messaging_service_interface.dart';
import 'package:eventati_book/services/interfaces/storage_service_interface.dart';
import 'package:eventati_book/services/supabase/utils/data_migration_service.dart';
import 'package:eventati_book/services/supabase/core/supabase_auth_service.dart';
import 'package:eventati_book/services/supabase/core/posthog_crashlytics_service.dart';
import 'package:eventati_book/services/supabase/core/custom_messaging_service.dart';
import 'package:eventati_book/services/analytics_service.dart';
import 'package:eventati_book/services/supabase/utils/database_service.dart';
import 'package:eventati_book/services/supabase/core/supabase_storage_service.dart';
import 'package:eventati_book/services/supabase/database/user_database_service.dart';
import 'package:eventati_book/services/supabase/database/vendor_recommendation_database_service.dart';
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

    // Register Supabase services
    registerSingleton<AuthServiceInterface>(SupabaseAuthService());
    registerSingleton<DatabaseServiceInterface>(DatabaseService());
    registerSingleton<StorageServiceInterface>(SupabaseStorageService());
    registerSingleton<MessagingServiceInterface>(CustomMessagingService());
    registerSingleton<AnalyticsServiceInterface>(AnalyticsService());
    registerSingleton<CrashlyticsServiceInterface>(PostHogCrashlyticsService());

    // Register data migration service
    registerSingleton<DataMigrationService>(
      DataMigrationService(
        authService: get<AuthServiceInterface>(),
        databaseService: get<DatabaseServiceInterface>(),
        storageService: get<StorageServiceInterface>(),
      ),
    );

    // Initialize FileUtils with the storage service
    FileUtils.setStorageService(get<StorageServiceInterface>());

    // Initialize services
    get<CrashlyticsServiceInterface>().initialize();
    get<MessagingServiceInterface>().initialize();
    get<AnalyticsServiceInterface>().initialize();
  }

  /// Get the navigation service
  NavigationService get navigationService => get<NavigationService>();

  /// Get the authentication service
  AuthServiceInterface get authService => get<AuthServiceInterface>();

  /// Get the database service
  DatabaseServiceInterface get databaseService =>
      get<DatabaseServiceInterface>();

  // Database service getters

  /// Get the user database service
  UserDatabaseService get userDatabaseService {
    if (!_services.containsKey(UserDatabaseService)) {
      registerSingleton<UserDatabaseService>(UserDatabaseService());
    }
    return get<UserDatabaseService>();
  }

  /// Get the vendor recommendation database service
  VendorRecommendationDatabaseService get vendorRecommendationDatabaseService {
    if (!_services.containsKey(VendorRecommendationDatabaseService)) {
      registerSingleton<VendorRecommendationDatabaseService>(
        VendorRecommendationDatabaseService(),
      );
    }
    return get<VendorRecommendationDatabaseService>();
  }

  /// Get the storage service
  StorageServiceInterface get storageService => get<StorageServiceInterface>();

  /// Get the messaging service
  MessagingServiceInterface get messagingService =>
      get<MessagingServiceInterface>();

  /// Get the analytics service
  AnalyticsServiceInterface get analyticsService =>
      get<AnalyticsServiceInterface>();

  /// Get the crashlytics service
  CrashlyticsServiceInterface get crashlyticsService =>
      get<CrashlyticsServiceInterface>();

  /// Get the data migration service
  DataMigrationService get dataMigrationService => get<DataMigrationService>();
}

/// Global instance of the service locator
final serviceLocator = ServiceLocator();
