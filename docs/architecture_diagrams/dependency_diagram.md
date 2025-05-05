# Eventati Book Dependency Architecture

This document provides a detailed overview of the dependency architecture in the Eventati Book application, showing how different components depend on each other and how dependencies are managed.

## Dependency Overview

The Eventati Book application follows a layered architecture with clear dependency rules to maintain separation of concerns and ensure maintainability.

```
┌─────────────────────────────────────────────────────────────────────────┐
│                       DEPENDENCY ARCHITECTURE                           │
└───────────────────────────────────┬─────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                         DEPENDENCY DIRECTION                            │
│                                                                         │
│  ┌─────────────────┐      ┌─────────────────┐      ┌─────────────────┐  │
│  │                 │      │                 │      │                 │  │
│  │    UI Layer     │─────▶│  Business Layer │─────▶│   Data Layer   │  │
│  │                 │      │                 │      │                 │  │
│  └─────────────────┘      └─────────────────┘      └─────────────────┘  │
│                                                                         │
│  Dependencies flow downward: UI depends on Business, Business depends   │
│  on Data, but Data does not depend on Business or UI.                   │
└─────────────────────────────────────────────────────────────────────────┘
```

## Component Dependencies

This diagram shows the dependencies between different components in the application:

```
┌─────────────────────────────────────────────────────────────────────────┐
│                         COMPONENT DEPENDENCIES                          │
└─────────────────────────────────────────────────────────────────────────┘

┌─────────────┐         ┌─────────────┐         ┌─────────────┐
│   Screens   │────────▶│   Widgets   │────────▶│   Styles    │
└─────────────┘         └─────────────┘         └─────────────┘
      │                       │                       │
      │                       │                       │
      ▼                       ▼                       │
┌─────────────┐         ┌─────────────┐              │
│  Providers  │────────▶│   Utils     │◀─────────────┘
└─────────────┘         └─────────────┘
      │                       ▲
      │                       │
      ▼                       │
┌─────────────┐         ┌─────────────┐
│  Services   │────────▶│   Models    │
└─────────────┘         └─────────────┘
      │                       ▲
      │                       │
      ▼                       │
┌─────────────┐               │
│   TempDB    │───────────────┘
└─────────────┘
```

## Detailed Dependencies by Layer

### UI Layer Dependencies

```
┌─────────────────────────────────────────────────────────────────────────┐
│                         UI LAYER DEPENDENCIES                           │
└───────────────────────────────────┬─────────────────────────────────────┘
                                    │
                ┌───────────────────┼───────────────────┐
                │                   │                   │
                ▼                   ▼                   ▼
┌───────────────────────┐ ┌───────────────────┐ ┌───────────────────────┐
│       SCREENS         │ │      WIDGETS      │ │       STYLES          │
│                       │ │                   │ │                        │
│  Dependencies:        │ │  Dependencies:    │ │  Dependencies:        │
│  - Widgets            │ │  - Styles         │ │  - None               │
│  - Providers          │ │  - Utils          │ │                        │
│  - Utils              │ │  - Providers      │ │                        │
│  - Styles             │ │  - Models         │ │                        │
└───────────────────────┘ └───────────────────┘ └───────────────────────┘
```

### Business Layer Dependencies

```
┌─────────────────────────────────────────────────────────────────────────┐
│                      BUSINESS LAYER DEPENDENCIES                        │
└───────────────────────────────────┬─────────────────────────────────────┘
                                    │
                ┌───────────────────┼───────────────────┐
                │                   │                   │
                ▼                   ▼                   ▼
┌───────────────────────┐ ┌───────────────────┐ ┌───────────────────────┐
│      PROVIDERS        │ │     SERVICES      │ │        UTILS          │
│                       │ │                   │ │                        │
│  Dependencies:        │ │  Dependencies:    │ │  Dependencies:        │
│  - Services           │ │  - Models         │ │  - None               │
│  - Models             │ │  - Utils          │ │                        │
│  - Utils              │ │  - TempDB         │ │                        │
│  - Other Providers    │ │                   │ │                        │
└───────────────────────┘ └───────────────────┘ └───────────────────────┘
```

### Data Layer Dependencies

```
┌─────────────────────────────────────────────────────────────────────────┐
│                       DATA LAYER DEPENDENCIES                           │
└───────────────────────────────────┬─────────────────────────────────────┘
                                    │
                ┌───────────────────┼───────────────────┐
                │                   │                   │
                ▼                   ▼                   ▼
┌───────────────────────┐ ┌───────────────────┐ ┌───────────────────────┐
│       MODELS          │ │      TEMPDB       │ │      (FIREBASE)       │
│                       │ │                   │ │                        │
│  Dependencies:        │ │  Dependencies:    │ │  Dependencies:        │
│  - None               │ │  - Models         │ │  - Models             │
│                       │ │                   │ │                        │
└───────────────────────┘ └───────────────────┘ └───────────────────────┘
```

## Feature-Specific Dependencies

### Event Wizard Feature Dependencies

```
┌─────────────────────────────────────────────────────────────────────────┐
│                    EVENT WIZARD FEATURE DEPENDENCIES                    │
└─────────────────────────────────────────────────────────────────────────┘

┌─────────────────────┐
│ WizardProvider      │
└─────────────────────┘
         ▲
         │
         │ depends on
         │
┌─────────────────────┐      ┌─────────────────────┐
│ EventProvider       │◀─────│ WizardService       │
└─────────────────────┘      └─────────────────────┘
         ▲                            ▲
         │                            │
         │ depends on                 │ depends on
         │                            │
┌─────────────────────┐      ┌─────────────────────┐
│ WizardScreen        │─────▶│ EventModel          │
└─────────────────────┘      └─────────────────────┘
         │                            ▲
         │                            │
         ▼                            │
┌─────────────────────┐               │
│ WizardWidgets       │───────────────┘
└─────────────────────┘
```

### Booking System Feature Dependencies

```
┌─────────────────────────────────────────────────────────────────────────┐
│                   BOOKING SYSTEM FEATURE DEPENDENCIES                   │
└─────────────────────────────────────────────────────────────────────────┘

┌─────────────────────┐
│ BookingProvider     │
└─────────────────────┘
         ▲
         │
         │ depends on
         │
┌─────────────────────┐      ┌─────────────────────┐
│ ServiceProvider     │◀─────│ BookingService      │
└─────────────────────┘      └─────────────────────┘
         ▲                            ▲
         │                            │
         │ depends on                 │ depends on
         │                            │
┌─────────────────────┐      ┌─────────────────────┐
│ BookingScreen       │─────▶│ BookingModel        │
└─────────────────────┘      └─────────────────────┘
         │                            ▲
         │                            │
         ▼                            │
┌─────────────────────┐               │
│ BookingWidgets      │───────────────┘
└─────────────────────┘
```

### Service Comparison Feature Dependencies

```
┌─────────────────────────────────────────────────────────────────────────┐
│                SERVICE COMPARISON FEATURE DEPENDENCIES                  │
└─────────────────────────────────────────────────────────────────────────┘

┌─────────────────────┐
│ ComparisonProvider  │
└─────────────────────┘
         ▲
         │
         │ depends on
         │
┌─────────────────────┐      ┌─────────────────────┐
│ ServiceProvider     │◀─────│ ComparisonService   │
└─────────────────────┘      └─────────────────────┘
         ▲                            ▲
         │                            │
         │ depends on                 │ depends on
         │                            │
┌─────────────────────┐      ┌─────────────────────┐
│ ComparisonScreen    │─────▶│ SavedComparisonModel│
└─────────────────────┘      └─────────────────────┘
         │                            ▲
         │                            │
         ▼                            │
┌─────────────────────┐               │
│ ComparisonWidgets   │───────────────┘
└─────────────────────┘
```

## Package Dependencies

This diagram shows the external package dependencies of the application:

```
┌─────────────────────────────────────────────────────────────────────────┐
│                         PACKAGE DEPENDENCIES                            │
└───────────────────────────────────┬─────────────────────────────────────┘
                                    │
                ┌───────────────────┼───────────────────┐
                │                   │                   │
                ▼                   ▼                   ▼
┌───────────────────────┐ ┌───────────────────┐ ┌───────────────────────┐
│    CORE PACKAGES      │ │   UI PACKAGES     │ │   SERVICE PACKAGES    │
│                       │ │                   │ │                        │
│  - flutter            │ │  - flutter_svg    │ │  - http               │
│  - provider           │ │  - google_fonts   │ │  - shared_preferences │
│  - intl               │ │  - flutter_rating_bar│  - path_provider     │
│  - uuid               │ │  - image_picker   │ │  - path               │
│  - collection         │ │  - flutter_slidable│ │  - url_launcher      │
│                       │ │  - table_calendar  │ │  - firebase_core     │
│                       │ │  - flutter_form_builder│ - firebase_auth    │
│                       │ │  - flutter_datetime_picker│ - cloud_firestore│
│                       │ │                   │ │  - firebase_storage   │
└───────────────────────┘ └───────────────────┘ └───────────────────────┘
```

## Dependency Injection

The application uses Provider for dependency injection:

```
┌─────────────────────────────────────────────────────────────────────────┐
│                         DEPENDENCY INJECTION                            │
└───────────────────────────────────┬─────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                             MAIN.DART                                   │
│                                                                         │
│  ┌─────────────────────────────────────────────────────────────────┐    │
│  │  MultiProvider(                                                 │    │
│  │    providers: [                                                 │    │
│  │      ChangeNotifierProvider(create: (_) => AuthProvider()),     │    │
│  │      ChangeNotifierProvider(create: (_) => ThemeProvider()),    │    │
│  │      ChangeNotifierProxyProvider<AuthProvider, EventProvider>(  │    │
│  │        create: (_) => EventProvider(null),                      │    │
│  │        update: (_, auth, __) => EventProvider(auth),            │    │
│  │      ),                                                         │    │
│  │      // Other providers...                                      │    │
│  │    ],                                                           │    │
│  │    child: MaterialApp(...),                                     │    │
│  │  )                                                              │    │
│  └─────────────────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────────────────┘
```

## Dependency Management Best Practices

The application follows these dependency management best practices:

1. **Dependency Inversion**: High-level modules do not depend on low-level modules
2. **Interface Segregation**: Clients only depend on the interfaces they use
3. **Single Responsibility**: Each class has a single responsibility
4. **Dependency Injection**: Dependencies are injected rather than created internally
5. **Loose Coupling**: Components are loosely coupled for better maintainability
6. **Testability**: Dependencies are designed to be easily mocked for testing
7. **Circular Dependency Avoidance**: The architecture avoids circular dependencies

## Future Dependency Enhancements

Planned enhancements for dependency management include:

1. **Service Locator Pattern**: For more flexible dependency resolution
2. **Modularization**: Breaking the app into feature modules with clear boundaries
3. **Dependency Graphs**: Automated dependency graph generation for documentation
4. **Dependency Validation**: Runtime validation of dependency correctness
5. **Dynamic Dependencies**: Support for dynamic dependency resolution based on configuration
