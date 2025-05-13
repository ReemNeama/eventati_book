# Eventati Book Application Architecture

This document provides a visual representation of the Eventati Book application's architecture.

## Overall Architecture

```
┌─────────────────────────────────────────────────────────────────────────┐
│                           EVENTATI BOOK APP                             │
└───────────────────────────────────┬─────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                               MAIN.DART                                 │
│                                                                         │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐    │
│  │ App Theme   │  │ Provider    │  │ Routes      │  │ Supabase    │    │
│  │ Configuration│  │ Registration│  │ Configuration│  │ Initialization│  │
│  └─────────────┘  └─────────────┘  └─────────────┘  └─────────────┘    │
└───────────────────────────────────┬─────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                           APPLICATION LAYERS                            │
└───────────────────────────────────┬─────────────────────────────────────┘
                                    │
                ┌───────────────────┼───────────────────┐
                │                   │                   │
                ▼                   ▼                   ▼
┌───────────────────────┐ ┌───────────────────┐ ┌───────────────────────┐
│     UI LAYER          │ │  BUSINESS LAYER   │ │     DATA LAYER        │
│                       │ │                   │ │                        │
│  ┌─────────────────┐  │ │ ┌─────────────┐   │ │  ┌─────────────────┐  │
│  │    Screens      │  │ │ │  Providers  │   │ │  │     Models      │  │
│  └────────┬────────┘  │ │ └──────┬──────┘   │ │  └────────┬────────┘  │
│           │           │ │        │          │ │           │           │
│  ┌────────▼────────┐  │ │ ┌──────▼──────┐   │ │  ┌────────▼────────┐  │
│  │    Widgets      │  │ │ │  Services   │   │ │  │     TempDB      │  │
│  └────────┬────────┘  │ │ └──────┬──────┘   │ │  └────────┬────────┘  │
│           │           │ │        │          │ │           │           │
│  ┌────────▼────────┐  │ │ ┌──────▼──────┐   │ │  ┌────────▼────────┐  │
│  │    Styles       │◄─┼─┼─┤   Utils     │◄──┼─┼──┤  (Supabase)     │  │
│  └─────────────────┘  │ │ └─────────────┘   │ │  └─────────────────┘  │
│                       │ │                   │ │                        │
└───────────────────────┘ └───────────────────┘ └───────────────────────┘
```

## UI Layer Components

```
┌─────────────────────────────────────────────────────────────────────────┐
│                               UI LAYER                                  │
└───────────────────────────────────┬─────────────────────────────────────┘
                                    │
        ┌───────────────────────────┼───────────────────────┐
        │                           │                       │
        ▼                           ▼                       ▼
┌─────────────────┐        ┌─────────────────┐      ┌─────────────────┐
│    SCREENS      │        │     WIDGETS     │      │     STYLES      │
│                 │        │                 │      │                 │
│ ┌─────────────┐ │        │ ┌─────────────┐ │      │ ┌─────────────┐ │
│ │Authentication│ │        │ │   Common    │ │      │ │ app_colors  │ │
│ └─────────────┘ │        │ └─────────────┘ │      │ └─────────────┘ │
│                 │        │                 │      │                 │
│ ┌─────────────┐ │        │ ┌─────────────┐ │      │ ┌─────────────┐ │
│ │  Homepage   │ │        │ │    Auth     │ │      │ │app_colors_dark│
│ └─────────────┘ │        │ └─────────────┘ │      │ └─────────────┘ │
│                 │        │                 │      │                 │
│ ┌─────────────┐ │        │ ┌─────────────┐ │      │ ┌─────────────┐ │
│ │Event Wizard │ │        │ │Event Planning│ │      │ │ app_theme   │ │
│ └─────────────┘ │        │ └─────────────┘ │      │ └─────────────┘ │
│                 │        │                 │      │                 │
│ ┌─────────────┐ │        │ ┌─────────────┐ │      │ ┌─────────────┐ │
│ │Event Planning│ │        │ │Event Wizard │ │      │ │ text_styles │ │
│ └─────────────┘ │        │ └─────────────┘ │      │ └─────────────┘ │
│                 │        │                 │      │                 │
│ ┌─────────────┐ │        │ ┌─────────────┐ │      │ ┌─────────────┐ │
│ │  Services   │ │        │ │  Services   │ │      │ │wizard_styles │ │
│ └─────────────┘ │        │ └─────────────┘ │      │ └─────────────┘ │
│                 │        │                 │      │                 │
│ ┌─────────────┐ │        │ ┌─────────────┐ │      │                 │
│ │   Booking   │ │        │ │  Responsive │ │      │                 │
│ └─────────────┘ │        │ └─────────────┘ │      │                 │
│                 │        │                 │      │                 │
│ ┌─────────────┐ │        │ ┌─────────────┐ │      │                 │
│ │   Profile   │ │        │ │  Milestones │ │      │                 │
│ └─────────────┘ │        │ └─────────────┘ │      │                 │
└─────────────────┘        └─────────────────┘      └─────────────────┘
```

## Business Layer Components

```
┌─────────────────────────────────────────────────────────────────────────┐
│                           BUSINESS LAYER                                │
└───────────────────────────────────┬─────────────────────────────────────┘
                                    │
                ┌───────────────────┼───────────────────┐
                │                   │                   │
                ▼                   ▼                   ▼
┌───────────────────────┐ ┌───────────────────┐ ┌───────────────────────┐
│      PROVIDERS        │ │     SERVICES      │ │        UTILS          │
│                       │ │                   │ │                        │
│  ┌─────────────────┐  │ │ ┌─────────────┐   │ │  ┌─────────────────┐  │
│  │  Core Providers │  │ │ │TaskTemplate │   │ │  │      Core       │  │
│  │                 │  │ │ │  Service    │   │ │  │                 │  │
│  │ - AuthProvider  │  │ │ └─────────────┘   │ │  │ - constants     │  │
│  │ - WizardProvider│  │ │                   │ │  │ - extensions    │  │
│  └─────────────────┘  │ │ ┌─────────────┐   │ │  └─────────────────┘  │
│                       │ │ │   Wizard    │   │ │                        │
│  ┌─────────────────┐  │ │ │ Connection  │   │ │  ┌─────────────────┐  │
│  │Feature Providers│  │ │ │   Service   │   │ │  │    Formatting   │  │
│  │                 │  │ │ └─────────────┘   │ │  │                 │  │
│  │ - MilestoneProvider│ │                   │ │  │ - date_utils    │  │
│  │ - SuggestionProvider│ │ ┌─────────────┐   │ │  │ - number_utils  │  │
│  │ - ComparisonProvider│ │ │  Services   │   │ │  │ - string_utils  │  │
│  │ - NotificationProvider│ │             │   │ │  └─────────────────┘  │
│                       │ │ │ - AuthService│   │ │                        │
│  ┌─────────────────┐  │ │ │ - EventService│  │ │  ┌─────────────────┐  │
│  │Planning Providers│  │ │ │ - BookingService│ │  │      Service    │  │
│  │                 │  │ │ │ - NotificationSvc│ │  │                 │  │
│  │ - BudgetProvider│  │ │ │ - StorageService│ │  │ - service_utils  │  │
│  │ - GuestListProvider│ │ └─────────────┘   │ │  │ - validation_utils│ │
│  │ - MessagingProvider│ │                   │ │  │ - file_utils     │  │
│  │ - TaskProvider  │  │ │                   │ │  │ - analytics_utils│  │
│  │ - BookingProvider│  │ │                   │ │  └─────────────────┘  │
│  └─────────────────┘  │ │                   │ │                        │
│                       │ │                   │ │  ┌─────────────────┐  │
│                       │ │                   │ │  │        UI       │  │
│                       │ │                   │ │  │                 │  │
│                       │ │                   │ │  │ - ui_utils      │  │
│                       │ │                   │ │  │ - responsive_utils│ │
│                       │ │                   │ │  │ - form_utils    │  │
│                       │ │                   │ │  │ - navigation_utils│ │
│                       │ │                   │ │  │ - error_handling │  │
│                       │ │                   │ │  │ - accessibility  │  │
│                       │ │                   │ │  └─────────────────┘  │
└───────────────────────┘ └───────────────────┘ └───────────────────────┘
```

## Data Layer Components

```
┌─────────────────────────────────────────────────────────────────────────┐
│                              DATA LAYER                                 │
└───────────────────────────────────┬─────────────────────────────────────┘
                                    │
                ┌───────────────────┼───────────────────┐
                │                   │                   │
                ▼                   ▼                   ▼
┌───────────────────────┐ ┌───────────────────┐ ┌───────────────────────┐
│       MODELS          │ │      TEMPDB       │ │      (SUPABASE)       │
│                       │ │                   │ │                        │
│  ┌─────────────────┐  │ │ ┌─────────────┐   │ │  ┌─────────────────┐  │
│  │  Event Models   │  │ │ │  services   │   │ │  │  Authentication │  │
│  │                 │  │ │ │             │   │ │  │                 │  │
│  │ - event_template│  │ │ │ - venues    │   │ │  │ - User accounts │  │
│  │ - wizard_state  │  │ │ │ - catering  │   │ │  │ - User profiles │  │
│  └─────────────────┘  │ │ │ - photography│  │ │  └─────────────────┘  │
│                       │ │ │ - planners  │   │ │                        │
│  ┌─────────────────┐  │ │ └─────────────┘   │ │  ┌─────────────────┐  │
│  │  User Models    │  │ │                   │ │  │    Database     │  │
│  │                 │  │ │ ┌─────────────┐   │ │  │                 │  │
│  │ - user          │  │ │ │    users    │   │ │  │ - Events        │  │
│  └─────────────────┘  │ │ │             │   │ │  │ - Services      │  │
│                       │ │ │ - profiles  │   │ │  │ - Bookings      │  │
│  ┌─────────────────┐  │ │ │ - auth data │   │ │  │ - Guest lists   │  │
│  │ Planning Models │  │ │ └─────────────┘   │ │  │ - Budgets       │  │
│  │                 │  │ │                   │ │  │ - Tasks         │  │
│  │ - budget_item   │  │ │ ┌─────────────┐   │ │  │ - Messages      │  │
│  │ - guest         │  │ │ │   venues    │   │ │  └─────────────────┘  │
│  │ - milestone     │  │ │ │             │   │ │                        │
│  │ - task          │  │ │ │ - locations │   │ │  ┌─────────────────┐  │
│  │ - vendor_message│  │ │ │ - features  │   │ │  │  Cloud Storage  │  │
│  └─────────────────┘  │ │ │ - packages  │   │ │  │                 │  │
│                       │ │ └─────────────┘   │ │  │ - Images        │  │
│  ┌─────────────────┐  │ │                   │ │  │ - Documents     │  │
│  │ Service Models  │  │ │                   │ │  │ - User uploads  │  │
│  │                 │  │ │                   │ │  └─────────────────┘  │
│  │ - venue         │  │ │                   │ │                        │
│  │ - catering      │  │ │                   │ │  ┌─────────────────┐  │
│  │ - photographer  │  │ │                   │ │  │  Cloud Functions │  │
│  │ - planner       │  │ │                   │ │  │                 │  │
│  │ - booking       │  │ │                   │ │  │ - Notifications │  │
│  └─────────────────┘  │ │                   │ │  │ - Data processing│  │
│                       │ │                   │ │  │ - Integrations  │  │
│  ┌─────────────────┐  │ │                   │ │  └─────────────────┘  │
│  │ Feature Models  │  │ │                   │ │                        │
│  │                 │  │ │                   │ │                        │
│  │ - suggestion    │  │ │                   │ │                        │
│  │ - saved_comparison│ │                   │ │                        │
│  │ - notification  │  │ │                   │ │                        │
│  │ - notification_settings│                │ │                        │
│  └─────────────────┘  │ │                   │ │                        │
└───────────────────────┘ └───────────────────┘ └───────────────────────┘
```

## Data Flow

```
┌──────────────┐     ┌──────────────┐     ┌──────────────┐     ┌──────────────┐
│              │     │              │     │              │     │              │
│    User      │────▶│   Widgets    │────▶│   Screens    │────▶│   Providers  │
│  Interaction │     │              │     │              │     │              │
│              │     │              │     │              │     │              │
└──────────────┘     └──────────────┘     └──────────────┘     └──────────────┘
                                                                      │
                                                                      │
                                                                      ▼
┌──────────────┐     ┌──────────────┐     ┌──────────────┐     ┌──────────────┐
│              │     │              │     │              │     │              │
│    Models    │◀────│   TempDB     │◀────│   Services   │◀────│    Utils     │
│              │     │  (Supabase)  │     │              │     │              │
│              │     │              │     │              │     │              │
└──────────────┘     └──────────────┘     └──────────────┘     └──────────────┘
      │                                          │
      │                                          │
      ▼                                          ▼
┌──────────────┐                          ┌──────────────┐
│              │                          │              │
│   Providers  │◀─────────────────────────│   Screens    │
│              │                          │              │
│              │                          │              │
└──────────────┘                          └──────────────┘
      │                                          │
      │                                          │
      ▼                                          ▼
┌──────────────┐                          ┌──────────────┐
│              │                          │              │
│   Widgets    │◀─────────────────────────│     User     │
│              │                          │  Interface   │
│              │                          │              │
└──────────────┘                          └──────────────┘
```

## Key Relationships

1. **Screens use Widgets**: Screens are composed of reusable widgets
2. **Providers manage state**: Providers hold and manage application state
3. **Services implement business logic**: Services contain core business logic
4. **Models represent data**: Models define the structure of application data
5. **Utils provide helper functions**: Utilities provide common functionality
6. **TempDB simulates backend**: TempDB provides mock data (to be replaced with Supabase)
7. **Styles define appearance**: Styles define the visual appearance of the UI

## Supabase Integration

The TempDB layer has been replaced with Supabase services:

1. **Authentication**: Supabase Authentication for user management
2. **Database**: Supabase PostgreSQL for structured data storage
3. **Storage**: Supabase Storage for files and images
4. **Functions**: Supabase Edge Functions for server-side logic
5. **Realtime**: Supabase Realtime for live updates
