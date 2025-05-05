# Eventati Book Navigation Architecture

This document provides a detailed overview of the navigation architecture in the Eventati Book application, showing how users navigate through the application and how different screens are connected.

## Navigation Overview

The Eventati Book application uses Flutter's navigation system with named routes for screen navigation. The application has a bottom navigation bar for main sections and uses push/pop navigation for detailed screens.

```
┌─────────────────────────────────────────────────────────────────────────┐
│                       NAVIGATION ARCHITECTURE                           │
└───────────────────────────────────┬─────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                         NAVIGATION COMPONENTS                           │
│                                                                         │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐          │
│  │ Bottom Nav Bar  │  │  Named Routes   │  │ Navigation      │          │
│  │                 │  │                 │  │ Service         │          │
│  │ - Main sections │  │ - Screen paths  │  │                 │          │
│  │ - Tab switching │  │ - Route params  │  │ - Navigation    │          │
│  │                 │  │                 │  │   methods       │          │
│  └─────────────────┘  └─────────────────┘  └─────────────────┘          │
└─────────────────────────────────────────────────────────────────────────┘
```

## Main Navigation Flow

This diagram shows the main navigation flow of the application:

```
┌─────────────────────────────────────────────────────────────────────────┐
│                           MAIN NAVIGATION FLOW                          │
└─────────────────────────────────────────────────────────────────────────┘

┌─────────────┐
│  Splash     │
│  Screen     │
└─────────────┘
      │
      ▼
┌─────────────┐     ┌─────────────┐
│  Login      │────▶│  Register   │
│  Screen     │     │  Screen     │
└─────────────┘     └─────────────┘
      │
      ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                           BOTTOM NAVIGATION BAR                         │
├─────────────┬─────────────┬─────────────┬─────────────┬─────────────────┤
│  Home       │  Services   │  Events     │  Planning   │  Profile        │
│  Tab        │  Tab        │  Tab        │  Tab        │  Tab            │
└─────────────┴─────────────┴─────────────┴─────────────┴─────────────────┘
```

## Bottom Navigation Bar Sections

Each section in the bottom navigation bar has its own navigation flow:

### Home Tab Navigation

```
┌─────────────────────────────────────────────────────────────────────────┐
│                           HOME TAB NAVIGATION                           │
└─────────────────────────────────────────────────────────────────────────┘

┌─────────────┐
│  Home       │
│  Screen     │
└─────────────┘
      │
      ├───────────────────┬───────────────────┬───────────────────┐
      ▼                   ▼                   ▼                   ▼
┌─────────────┐     ┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│  Featured   │     │  Recent     │     │  Popular    │     │  Upcoming   │
│  Services   │     │  Events     │     │  Venues     │     │  Events     │
└─────────────┘     └─────────────┘     └─────────────┘     └─────────────┘
      │                   │                   │                   │
      ▼                   ▼                   ▼                   ▼
┌─────────────┐     ┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│  Service    │     │  Event      │     │  Venue      │     │  Event      │
│  Details    │     │  Details    │     │  Details    │     │  Details    │
└─────────────┘     └─────────────┘     └─────────────┘     └─────────────┘
```

### Services Tab Navigation

```
┌─────────────────────────────────────────────────────────────────────────┐
│                        SERVICES TAB NAVIGATION                          │
└─────────────────────────────────────────────────────────────────────────┘

┌─────────────┐
│  Services   │
│  Screen     │
└─────────────┘
      │
      ├───────────────────┬───────────────────┬───────────────────┐
      ▼                   ▼                   ▼                   ▼
┌─────────────┐     ┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│  Venues     │     │  Catering   │     │ Photography │     │  Planners   │
│  List       │     │  List       │     │  List       │     │  List       │
└─────────────┘     └─────────────┘     └─────────────┘     └─────────────┘
      │                   │                   │                   │
      ▼                   ▼                   ▼                   ▼
┌─────────────┐     ┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│  Venue      │     │  Catering   │     │ Photography │     │  Planner    │
│  Details    │     │  Details    │     │  Details    │     │  Details    │
└─────────────┘     └─────────────┘     └─────────────┘     └─────────────┘
      │                   │                   │                   │
      ▼                   ▼                   ▼                   ▼
┌─────────────┐     ┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│  Booking    │     │  Booking    │     │  Booking    │     │  Booking    │
│  Form       │     │  Form       │     │  Form       │     │  Form       │
└─────────────┘     └─────────────┘     └─────────────┘     └─────────────┘
      │                   │                   │                   │
      └───────────────────┴───────────────────┴───────────────────┘
                                    │
                                    ▼
                              ┌─────────────┐
                              │  Booking    │
                              │ Confirmation│
                              └─────────────┘
```

### Events Tab Navigation

```
┌─────────────────────────────────────────────────────────────────────────┐
│                         EVENTS TAB NAVIGATION                           │
└─────────────────────────────────────────────────────────────────────────┘

┌─────────────┐
│  Events     │
│  Screen     │
└─────────────┘
      │
      ├───────────────────┬───────────────────┐
      ▼                   ▼                   ▼
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│  My Events  │     │  Create     │     │  Event      │
│  List       │     │  Event      │     │  Templates  │
└─────────────┘     └─────────────┘     └─────────────┘
      │                   │                   │
      ▼                   ▼                   ▼
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│  Event      │     │  Event Type │     │  Template   │
│  Details    │     │  Selection  │     │  Details    │
└─────────────┘     └─────────────┘     └─────────────┘
      │                   │                   │
      │                   ▼                   ▼
      │             ┌─────────────┐     ┌─────────────┐
      │             │  Event      │     │  Create from│
      │             │  Wizard     │     │  Template   │
      │             └─────────────┘     └─────────────┘
      │                   │                   │
      │                   └───────────────────┘
      │                             │
      │                             ▼
      │                       ┌─────────────┐
      │                       │  Event      │
      │                       │  Dashboard  │
      │                       └─────────────┘
      │                             │
      └─────────────────────────────┘
```

### Planning Tab Navigation

```
┌─────────────────────────────────────────────────────────────────────────┐
│                        PLANNING TAB NAVIGATION                          │
└─────────────────────────────────────────────────────────────────────────┘

┌─────────────┐
│  Planning   │
│  Screen     │
└─────────────┘
      │
      ├───────────────────┬───────────────────┬───────────────────┬───────────────────┐
      ▼                   ▼                   ▼                   ▼                   ▼
┌─────────────┐     ┌─────────────┐     ┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│  Budget     │     │  Guest List │     │  Timeline   │     │  Messaging  │     │  Bookings   │
│  Calculator │     │  Management │     │  Checklist  │     │             │     │  History    │
└─────────────┘     └─────────────┘     └─────────────┘     └─────────────┘     └─────────────┘
      │                   │                   │                   │                   │
      ▼                   ▼                   ▼                   ▼                   ▼
┌─────────────┐     ┌─────────────┐     ┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│  Budget     │     │  Guest      │     │  Task       │     │  Conversation│     │  Booking    │
│  Details    │     │  Details    │     │  Details    │     │  View       │     │  Details    │
└─────────────┘     └─────────────┘     └─────────────┘     └─────────────┘     └─────────────┘
      │                   │                   │                   │                   │
      ▼                   ▼                   ▼                   │                   ▼
┌─────────────┐     ┌─────────────┐     ┌─────────────┐          │             ┌─────────────┐
│  Add/Edit   │     │  Add/Edit   │     │  Add/Edit   │          │             │  Edit       │
│  Expense    │     │  Guest      │     │  Task       │          │             │  Booking    │
└─────────────┘     └─────────────┘     └─────────────┘          │             └─────────────┘
                          │                                       │
                          ▼                                       ▼
                    ┌─────────────┐                        ┌─────────────┐
                    │  Send       │                        │  Compose    │
                    │  Invitations│                        │  Message    │
                    └─────────────┘                        └─────────────┘
```

### Profile Tab Navigation

```
┌─────────────────────────────────────────────────────────────────────────┐
│                        PROFILE TAB NAVIGATION                           │
└─────────────────────────────────────────────────────────────────────────┘

┌─────────────┐
│  Profile    │
│  Screen     │
└─────────────┘
      │
      ├───────────────────┬───────────────────┬───────────────────┐
      ▼                   ▼                   ▼                   ▼
┌─────────────┐     ┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│  Edit       │     │  Saved      │     │  Settings   │     │  Help &     │
│  Profile    │     │  Comparisons│     │             │     │  Support    │
└─────────────┘     └─────────────┘     └─────────────┘     └─────────────┘
                          │                   │                   │
                          ▼                   ▼                   ▼
                    ┌─────────────┐     ┌─────────────┐     ┌─────────────┐
                    │  Comparison │     │  Theme      │     │  FAQ        │
                    │  Details    │     │  Settings   │     │             │
                    └─────────────┘     └─────────────┘     └─────────────┘
                                              │                   │
                                              ▼                   ▼
                                        ┌─────────────┐     ┌─────────────┐
                                        │  Notification│     │  Contact   │
                                        │  Settings   │     │  Support    │
                                        └─────────────┘     └─────────────┘
```

## Feature-Specific Navigation Flows

### Event Wizard Navigation Flow

```
┌─────────────────────────────────────────────────────────────────────────┐
│                     EVENT WIZARD NAVIGATION FLOW                        │
└─────────────────────────────────────────────────────────────────────────┘

┌─────────────┐
│  Event Type │
│  Selection  │
└─────────────┘
      │
      ├───────────────────┬───────────────────┬───────────────────┐
      ▼                   ▼                   ▼                   │
┌─────────────┐     ┌─────────────┐     ┌─────────────┐          │
│  Wedding    │     │  Business   │     │ Celebration │          │
│  Wizard     │     │  Event      │     │  Wizard     │          │
│  Screen     │     │  Wizard     │     │  Screen     │          │
└─────────────┘     └─────────────┘     └─────────────┘          │
      │                   │                   │                   │
      └───────────────────┴───────────────────┴───────────────────┘
                                    │
                                    ▼
                              ┌─────────────┐
                              │  Step 1:    │
                              │  Basic Info │
                              └─────────────┘
                                    │
                                    ▼
                              ┌─────────────┐
                              │  Step 2:    │
                              │Event Details│
                              └─────────────┘
                                    │
                                    ▼
                              ┌─────────────┐
                              │  Step 3:    │
                              │  Budget &   │
                              │ Preferences │
                              └─────────────┘
                                    │
                                    ▼
                              ┌─────────────┐
                              │  Step 4:    │
                              │  Planning   │
                              │Tools Setup  │
                              └─────────────┘
                                    │
                                    ▼
                              ┌─────────────┐
                              │  Step 5:    │
                              │  Summary &  │
                              │  Creation   │
                              └─────────────┘
                                    │
                                    ▼
                              ┌─────────────┐
                              │  Event      │
                              │  Dashboard  │
                              └─────────────┘
```

### Booking System Navigation Flow

```
┌─────────────────────────────────────────────────────────────────────────┐
│                    BOOKING SYSTEM NAVIGATION FLOW                       │
└─────────────────────────────────────────────────────────────────────────┘

┌─────────────┐
│  Service    │
│  Details    │
└─────────────┘
      │
      ▼
┌─────────────┐
│  Booking    │
│  Form       │
└─────────────┘
      │
      ▼
┌─────────────┐
│  Booking    │
│ Confirmation│
└─────────────┘
      │
      ▼
┌─────────────┐
│  Booking    │
│  History    │
└─────────────┘
      │
      ▼
┌─────────────┐
│  Booking    │
│  Details    │
└─────────────┘
      │
      ├───────────────────┬───────────────────┐
      ▼                   ▼                   ▼
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│  Edit       │     │  Cancel     │     │  View in    │
│  Booking    │     │  Booking    │     │  Event      │
└─────────────┘     └─────────────┘     └─────────────┘
```

### Service Comparison Navigation Flow

```
┌─────────────────────────────────────────────────────────────────────────┐
│                  SERVICE COMPARISON NAVIGATION FLOW                     │
└─────────────────────────────────────────────────────────────────────────┘

┌─────────────┐
│  Service    │
│  Listing    │
└─────────────┘
      │
      ▼
┌─────────────┐
│  Select     │
│  Services   │
└─────────────┘
      │
      ▼
┌─────────────┐
│  Comparison │
│  Screen     │
└─────────────┘
      │
      ├───────────────────┬───────────────────┬───────────────────┐
      ▼                   ▼                   ▼                   ▼
┌─────────────┐     ┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│  Overview   │     │  Features   │     │  Pricing    │     │  Save       │
│  Tab        │     │  Tab        │     │  Tab        │     │  Comparison │
└─────────────┘     └─────────────┘     └─────────────┘     └─────────────┘
                                                                  │
                                                                  ▼
                                                            ┌─────────────┐
                                                            │  Saved      │
                                                            │ Comparisons │
                                                            └─────────────┘
                                                                  │
                                                                  ▼
                                                            ┌─────────────┐
                                                            │ Comparison  │
                                                            │  Details    │
                                                            └─────────────┘
```

## Navigation Implementation

The application implements navigation using Flutter's named routes:

```
┌─────────────────────────────────────────────────────────────────────────┐
│                       NAVIGATION IMPLEMENTATION                         │
└───────────────────────────────────┬─────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                             ROUTES DEFINITION                           │
│                                                                         │
│  ┌─────────────────────────────────────────────────────────────────┐    │
│  │  Map<String, WidgetBuilder> routes = {                          │    │
│  │    '/': (context) => SplashScreen(),                            │    │
│  │    '/login': (context) => LoginScreen(),                        │    │
│  │    '/register': (context) => RegisterScreen(),                  │    │
│  │    '/home': (context) => HomeScreen(),                          │    │
│  │    '/services': (context) => ServicesScreen(),                  │    │
│  │    '/services/venues': (context) => VenueListScreen(),          │    │
│  │    '/services/venues/:id': (context) => VenueDetailsScreen(),   │    │
│  │    '/services/catering': (context) => CateringListScreen(),     │    │
│  │    // More routes...                                            │    │
│  │  };                                                             │    │
│  └─────────────────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────────────────┘
```

## Navigation Service

The application uses a navigation service for centralized navigation management:

```
┌─────────────────────────────────────────────────────────────────────────┐
│                          NAVIGATION SERVICE                             │
└───────────────────────────────────┬─────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                       NAVIGATION SERVICE CLASS                          │
│                                                                         │
│  ┌─────────────────────────────────────────────────────────────────┐    │
│  │  class NavigationService {                                      │    │
│  │    final GlobalKey<NavigatorState> navigatorKey =               │    │
│  │        GlobalKey<NavigatorState>();                             │    │
│  │                                                                 │    │
│  │    Future<dynamic> navigateTo(String routeName, {              │    │
│  │      Map<String, dynamic> arguments                            │    │
│  │    }) {                                                         │    │
│  │      return navigatorKey.currentState.pushNamed(                │    │
│  │        routeName,                                               │    │
│  │        arguments: arguments                                     │    │
│  │      );                                                         │    │
│  │    }                                                            │    │
│  │                                                                 │    │
│  │    Future<dynamic> replaceTo(String routeName, {               │    │
│  │      Map<String, dynamic> arguments                            │    │
│  │    }) {                                                         │    │
│  │      return navigatorKey.currentState.pushReplacementNamed(     │    │
│  │        routeName,                                               │    │
│  │        arguments: arguments                                     │    │
│  │      );                                                         │    │
│  │    }                                                            │    │
│  │                                                                 │    │
│  │    void goBack() {                                              │    │
│  │      return navigatorKey.currentState.pop();                    │    │
│  │    }                                                            │    │
│  │  }                                                              │    │
│  └─────────────────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────────────────┘
```

## Navigation Best Practices

The application follows these navigation best practices:

1. **Consistent Navigation**: Consistent navigation patterns across the application
2. **Deep Linking**: Support for deep linking to specific screens
3. **Back Button Handling**: Proper handling of the back button
4. **Route Parameters**: Passing parameters between routes
5. **Navigation History**: Maintaining navigation history for proper back navigation
6. **Error Handling**: Handling navigation errors gracefully
7. **Transition Animations**: Consistent transition animations between screens

## Future Navigation Enhancements

Planned enhancements for navigation include:

1. **Route Guards**: Implementing route guards for authenticated routes
2. **Navigation Analytics**: Tracking screen navigation for analytics
3. **Dynamic Routes**: Support for dynamic route generation
4. **Nested Navigation**: Implementing nested navigation for complex flows
5. **Tab History**: Maintaining separate navigation history for each tab
