import 'package:eventati_book/routing/navigation_service.dart';

/// Simple service locator for dependency injection
class ServiceLocator {
  static final ServiceLocator _instance = ServiceLocator._internal();

  factory ServiceLocator() => _instance;

  ServiceLocator._internal();

  final NavigationService navigationService = NavigationService();
}

/// Global instance of the service locator
final serviceLocator = ServiceLocator();
