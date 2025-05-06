import 'package:eventati_book/routing/navigation_service.dart';

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
    registerSingleton<NavigationService>(NavigationService());
  }

  /// Get the navigation service
  NavigationService get navigationService => get<NavigationService>();
}

/// Global instance of the service locator
final serviceLocator = ServiceLocator();
