# Dependency Injection Directory

This directory contains classes for dependency injection in the Eventati Book application.

## Overview

Dependency injection is a design pattern that allows for loose coupling between components by injecting dependencies rather than creating them directly. This makes the code more modular, testable, and maintainable.

## Components

### ServiceLocator

The `ServiceLocator` is a simple service locator pattern implementation for dependency injection of services. It provides a centralized registry for services that can be accessed throughout the application.

```dart
// Register a service
ServiceLocator().registerSingleton<NavigationService>(NavigationService());

// Access a service
final navigationService = ServiceLocator().navigationService;
```

### ProvidersManager

The `ProvidersManager` centralizes provider registration and initialization, making it easier to manage providers across the application. It works with the Provider pattern to provide state management.

```dart
// In main.dart
MultiProvider(
  providers: ProvidersManager().providers,
  child: MyApp(),
)

// Initialize providers
ProvidersManager().initializeProviders(context);
```

## Usage Guidelines

- Use `ServiceLocator` for services that don't need to be part of the widget tree
- Use `ProvidersManager` for state management providers that need to be part of the widget tree
- Register services in `ServiceLocator.initialize()`
- Register providers in `ProvidersManager.providers`
- Initialize providers that need initialization in `ProvidersManager.initializeProviders()`

## Benefits

- **Centralized Registration**: All service and provider registration is in one place
- **Simplified main.dart**: The main.dart file becomes cleaner and more focused
- **Consistent Initialization**: All initialization happens in one place with a standard pattern
- **Easier Testing**: Dependencies can be easily mocked for testing
- **Better Organization**: Clear separation between services and providers
