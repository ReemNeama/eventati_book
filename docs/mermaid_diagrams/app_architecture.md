# Application Architecture Diagram

This document provides an interactive architecture diagram of the Eventati Book application using Mermaid.

## Application Architecture Overview

```mermaid
graph TD
    subgraph "UI Layer"
        A[Screens] --> B[Widgets]
        B --> C[Custom Components]
    end

    subgraph "State Management"
        D[Providers] --> E[ChangeNotifier]
        D --> F[State Objects]
    end

    subgraph "Data Layer"
        G[Models] --> H[Services]
        H --> I[TempDB / Supabase]
    end

    A --> D
    D --> G
```

## Detailed Architecture Diagram

```mermaid
graph TD
    %% UI Layer
    subgraph "UI Layer"
        Screens[Screens]
        Widgets[Widgets]
        CustomComponents[Custom Components]

        Screens --> Widgets
        Widgets --> CustomComponents
    end

    %% State Management
    subgraph "State Management"
        Providers[Providers]
        ChangeNotifier[ChangeNotifier]
        StateObjects[State Objects]

        Providers --> ChangeNotifier
        Providers --> StateObjects
    end

    %% Data Layer
    subgraph "Data Layer"
        Models[Models]
        Services[Services]
        DataStorage[TempDB / Supabase]

        Models --> Services
        Services --> DataStorage
    end

    %% Cross-layer connections
    Screens --> Providers
    Widgets --> Providers
    Providers --> Models
    Providers --> Services

    %% Specific components
    subgraph "Screen Examples"
        AuthScreen[Auth Screen]
        EventWizardScreen[Event Wizard Screen]
        ServicesScreen[Services Screen]
        PlanningToolsScreen[Planning Tools Screen]

        Screens --> AuthScreen
        Screens --> EventWizardScreen
        Screens --> ServicesScreen
        Screens --> PlanningToolsScreen
    end

    subgraph "Provider Examples"
        AuthProvider[Auth Provider]
        EventProvider[Event Provider]
        ServicesProvider[Services Provider]
        BudgetProvider[Budget Provider]

        Providers --> AuthProvider
        Providers --> EventProvider
        Providers --> ServicesProvider
        Providers --> BudgetProvider
    end

    subgraph "Model Examples"
        UserModel[User Model]
        EventModel[Event Model]
        ServiceModel[Service Model]
        BudgetModel[Budget Model]

        Models --> UserModel
        Models --> EventModel
        Models --> ServiceModel
        Models --> BudgetModel
    end

    %% Specific connections
    AuthScreen --> AuthProvider
    EventWizardScreen --> EventProvider
    ServicesScreen --> ServicesProvider
    PlanningToolsScreen --> BudgetProvider

    AuthProvider --> UserModel
    EventProvider --> EventModel
    ServicesProvider --> ServiceModel
    BudgetProvider --> BudgetModel
```

## Module Dependencies

```mermaid
flowchart TD
    %% Main modules
    App[App] --> Auth[Authentication]
    App --> EventCreation[Event Creation]
    App --> Services[Services]
    App --> Planning[Planning Tools]

    %% Authentication dependencies
    Auth --> UserManagement[User Management]

    %% Event Creation dependencies
    EventCreation --> EventWizard[Event Wizard]
    EventWizard --> WeddingWizard[Wedding Wizard]
    EventWizard --> CelebrationWizard[Celebration Wizard]
    EventWizard --> BusinessWizard[Business Event Wizard]
    EventWizard --> Suggestions[Suggestions]

    %% Services dependencies
    Services --> ServiceCategories[Service Categories]
    Services --> ServiceDetails[Service Details]
    Services --> Booking[Booking]

    %% Planning Tools dependencies
    Planning --> Budget[Budget]
    Planning --> GuestList[Guest List]
    Planning --> Timeline[Timeline]
    Planning --> Messaging[Messaging]

    %% Cross-module dependencies
    EventWizard --> Budget
    EventWizard --> GuestList
    EventWizard --> Timeline
    Booking --> Budget
    Booking --> Services

    %% Styling
    classDef core fill:#f9f,stroke:#333,stroke-width:2px
    classDef feature fill:#bbf,stroke:#333,stroke-width:1px
    classDef subfeature fill:#ddf,stroke:#333,stroke-width:1px

    class App,Auth,EventCreation,Services,Planning core
    class UserManagement,EventWizard,ServiceCategories,ServiceDetails,Booking,Budget,GuestList,Timeline,Messaging feature
    class WeddingWizard,CelebrationWizard,BusinessWizard,Suggestions subfeature
```

## Data Flow Diagram

```mermaid
sequenceDiagram
    actor User
    participant UI as UI Layer
    participant Provider as Provider Layer
    participant Service as Service Layer
    participant Storage as Data Storage

    %% Authentication flow
    User->>UI: Enter credentials
    UI->>Provider: login(email, password)
    Provider->>Service: authenticateUser(email, password)
    Service->>Storage: validateCredentials(email, password)
    Storage-->>Service: User data
    Service-->>Provider: Authentication result
    Provider-->>UI: Update auth state
    UI-->>User: Show success/error

    %% Event creation flow
    User->>UI: Create new event
    UI->>Provider: createEvent(eventData)
    Provider->>Service: saveEvent(eventData)
    Service->>Storage: storeEvent(eventData)
    Storage-->>Service: Event ID
    Service-->>Provider: Event creation result
    Provider-->>UI: Update event state
    UI-->>User: Show success/error

    %% Service booking flow
    User->>UI: Book service
    UI->>Provider: bookService(serviceId, details)
    Provider->>Service: createBooking(serviceId, details)
    Service->>Storage: storeBooking(bookingData)
    Storage-->>Service: Booking ID
    Service-->>Provider: Booking result
    Provider-->>UI: Update booking state
    UI-->>User: Show confirmation
```

## State Management Diagram

```mermaid
stateDiagram-v2
    [*] --> Unauthenticated

    Unauthenticated --> Authenticating: Login/Register
    Authenticating --> AuthenticationFailed: Invalid credentials
    Authenticating --> AuthenticationError: System error
    Authenticating --> Authenticated: Success

    AuthenticationFailed --> Authenticating: Retry
    AuthenticationError --> Authenticating: Retry

    Authenticated --> EventSelection: Navigate to events

    EventSelection --> ExistingEvent: Select event
    EventSelection --> EventCreation: Create new event

    EventCreation --> EventWizard: Select event type
    EventWizard --> EventCreated: Complete wizard
    EventCreated --> EventDashboard: Continue

    ExistingEvent --> EventDashboard: View event

    EventDashboard --> PlanningTools: Access tools
    EventDashboard --> ServiceBooking: Book services

    PlanningTools --> Budget: Manage budget
    PlanningTools --> GuestList: Manage guests
    PlanningTools --> Timeline: View timeline
    PlanningTools --> Messaging: Message vendors

    Budget --> EventDashboard: Return
    GuestList --> EventDashboard: Return
    Timeline --> EventDashboard: Return
    Messaging --> EventDashboard: Return

    ServiceBooking --> ServiceSelection: Browse services
    ServiceSelection --> ServiceDetails: View details
    ServiceDetails --> BookingForm: Book service
    BookingForm --> BookingConfirmation: Confirm booking
    BookingConfirmation --> EventDashboard: Return

    Authenticated --> Unauthenticated: Logout
```

## Component Interaction Diagram

```mermaid
graph TD
    %% Main components
    subgraph "Authentication"
        AuthScreen[Auth Screen]
        LoginScreen[Login Screen]
        RegisterScreen[Register Screen]
        AuthProvider[Auth Provider]
        UserModel[User Model]

        AuthScreen --> LoginScreen
        AuthScreen --> RegisterScreen
        LoginScreen --> AuthProvider
        RegisterScreen --> AuthProvider
        AuthProvider --> UserModel
    end

    subgraph "Event Creation"
        EventTypeScreen[Event Type Screen]
        WizardScreen[Wizard Screen]
        EventProvider[Event Provider]
        EventModel[Event Model]

        EventTypeScreen --> WizardScreen
        WizardScreen --> EventProvider
        EventProvider --> EventModel
    end

    subgraph "Services"
        ServicesScreen[Services Screen]
        ServiceDetailsScreen[Service Details Screen]
        BookingScreen[Booking Screen]
        ServicesProvider[Services Provider]
        ServiceModel[Service Model]
        BookingModel[Booking Model]

        ServicesScreen --> ServiceDetailsScreen
        ServiceDetailsScreen --> BookingScreen
        ServicesScreen --> ServicesProvider
        ServiceDetailsScreen --> ServicesProvider
        BookingScreen --> ServicesProvider
        ServicesProvider --> ServiceModel
        ServicesProvider --> BookingModel
    end

    subgraph "Planning Tools"
        BudgetScreen[Budget Screen]
        GuestListScreen[Guest List Screen]
        TimelineScreen[Timeline Screen]
        MessagingScreen[Messaging Screen]

        BudgetProvider[Budget Provider]
        GuestListProvider[Guest List Provider]
        TimelineProvider[Timeline Provider]
        MessagingProvider[Messaging Provider]

        BudgetModel[Budget Model]
        GuestModel[Guest Model]
        MilestoneModel[Milestone Model]
        MessageModel[Message Model]

        BudgetScreen --> BudgetProvider
        GuestListScreen --> GuestListProvider
        TimelineScreen --> TimelineProvider
        MessagingScreen --> MessagingProvider

        BudgetProvider --> BudgetModel
        GuestListProvider --> GuestModel
        TimelineProvider --> MilestoneModel
        MessagingProvider --> MessageModel
    end

    %% Cross-component interactions
    EventProvider --> BudgetProvider
    EventProvider --> GuestListProvider
    EventProvider --> TimelineProvider

    ServicesProvider --> BudgetProvider
    MessagingProvider --> ServicesProvider

    %% Data storage
    subgraph "Data Storage"
        TempDB[Temporary Database]
        Supabase[Supabase]

        TempDB --> Supabase
    end

    AuthProvider --> TempDB
    EventProvider --> TempDB
    ServicesProvider --> TempDB
    BudgetProvider --> TempDB
    GuestListProvider --> TempDB
    TimelineProvider --> TempDB
    MessagingProvider --> TempDB
```

## Supabase Implementation Plan

```mermaid
timeline
    title Supabase Implementation Timeline

    section Authentication
      Supabase Auth Setup : User registration
      : User login
      : Password reset
      : Email verification

    section Database Structure
      Database Tables : Users table
      : Events table
      : Services table
      : Bookings table

    section Data Migration
      Migrate Local Data : User data
      : Event data
      : Service data
      : Booking data

    section Edge Functions
      Implement Functions : Notification triggers
      : Data validation
      : Scheduled tasks

    section Storage
      Supabase Storage : User profile images
      : Service images
      : Event documents

    section Analytics
      PostHog Analytics : User engagement
      : Feature usage
      : Conversion tracking
```

## User Flow Diagram

```mermaid
journey
    title User Journey through Eventati Book

    section Onboarding
      Discover app: 3: User
      Install app: 4: User
      Create account: 3: User
      Complete profile: 4: User

    section Event Creation
      Select event type: 5: User
      Complete wizard: 4: User
      Review suggestions: 5: User
      Save event: 5: User

    section Planning
      Set up budget: 4: User
      Create guest list: 3: User
      Review timeline: 4: User
      Track milestones: 5: User

    section Service Booking
      Browse services: 3: User
      Compare options: 4: User
      Book services: 5: User
      Communicate with vendors: 4: User

    section Event Management
      Track progress: 5: User
      Manage changes: 3: User
      Complete event: 5: User
```
