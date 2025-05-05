# Navigation Flow Diagram

This document provides an interactive navigation flow diagram of the Eventati Book application using Mermaid.

## Main Navigation Flow

```mermaid
flowchart TD
    %% Main screens
    SplashScreen[Splash Screen]
    OnboardingScreen[Onboarding Screen]
    AuthScreen[Auth Screen]
    DashboardScreen[Dashboard Screen]
    EventsScreen[Events Screen]
    ServicesScreen[Services Screen]
    PlanningToolsScreen[Planning Tools Screen]
    ProfileScreen[Profile Screen]
    
    %% Navigation flow
    SplashScreen --> OnboardingScreen
    OnboardingScreen --> AuthScreen
    AuthScreen --> DashboardScreen
    
    %% Bottom navigation
    DashboardScreen <--> EventsScreen
    EventsScreen <--> ServicesScreen
    ServicesScreen <--> PlanningToolsScreen
    PlanningToolsScreen <--> ProfileScreen
    ProfileScreen <--> DashboardScreen
    
    %% Styling
    classDef primary fill:#f9f,stroke:#333,stroke-width:2px
    classDef secondary fill:#bbf,stroke:#333,stroke-width:1px
    
    class SplashScreen,OnboardingScreen,AuthScreen,DashboardScreen primary
    class EventsScreen,ServicesScreen,PlanningToolsScreen,ProfileScreen secondary
```

## Detailed Navigation Map

```mermaid
flowchart TD
    %% Main entry points
    SplashScreen[Splash Screen]
    OnboardingScreen[Onboarding Screen]
    AuthScreen[Auth Screen]
    
    %% Authentication flow
    LoginScreen[Login Screen]
    RegisterScreen[Register Screen]
    ForgotPasswordScreen[Forgot Password Screen]
    VerificationScreen[Verification Screen]
    
    %% Main navigation
    DashboardScreen[Dashboard Screen]
    EventsScreen[Events Screen]
    ServicesScreen[Services Screen]
    PlanningToolsScreen[Planning Tools Screen]
    ProfileScreen[Profile Screen]
    
    %% Event creation flow
    EventTypeScreen[Event Type Screen]
    WeddingWizardScreen[Wedding Wizard Screen]
    CelebrationWizardScreen[Celebration Wizard Screen]
    BusinessEventWizardScreen[Business Event Wizard Screen]
    EventCreatedScreen[Event Created Screen]
    SuggestionsScreen[Suggestions Screen]
    
    %% Event management
    EventDashboardScreen[Event Dashboard Screen]
    EventDetailsScreen[Event Details Screen]
    EventEditScreen[Event Edit Screen]
    
    %% Planning tools
    BudgetScreen[Budget Screen]
    BudgetDetailsScreen[Budget Details Screen]
    BudgetItemFormScreen[Budget Item Form Screen]
    
    GuestListScreen[Guest List Screen]
    GuestFormScreen[Guest Form Screen]
    GuestGroupsScreen[Guest Groups Screen]
    
    TimelineScreen[Timeline Screen]
    MilestoneDetailsScreen[Milestone Details Screen]
    MilestoneFormScreen[Milestone Form Screen]
    
    MessagingScreen[Messaging Screen]
    ConversationScreen[Conversation Screen]
    ComposeMessageScreen[Compose Message Screen]
    
    %% Services flow
    ServiceCategoriesScreen[Service Categories Screen]
    ServiceListScreen[Service List Screen]
    ServiceDetailsScreen[Service Details Screen]
    ServiceComparisonScreen[Service Comparison Screen]
    BookingFormScreen[Booking Form Screen]
    BookingConfirmationScreen[Booking Confirmation Screen]
    
    %% Booking management
    BookingHistoryScreen[Booking History Screen]
    BookingDetailsScreen[Booking Details Screen]
    
    %% Profile management
    ProfileEditScreen[Profile Edit Screen]
    SettingsScreen[Settings Screen]
    NotificationsScreen[Notifications Screen]
    
    %% Initial flow
    SplashScreen --> OnboardingScreen
    OnboardingScreen --> AuthScreen
    
    %% Auth flow
    AuthScreen --> LoginScreen
    AuthScreen --> RegisterScreen
    LoginScreen --> ForgotPasswordScreen
    RegisterScreen --> VerificationScreen
    LoginScreen --> DashboardScreen
    VerificationScreen --> DashboardScreen
    
    %% Main navigation
    DashboardScreen <--> EventsScreen
    EventsScreen <--> ServicesScreen
    ServicesScreen <--> PlanningToolsScreen
    PlanningToolsScreen <--> ProfileScreen
    ProfileScreen <--> DashboardScreen
    
    %% Event creation
    EventsScreen --> EventTypeScreen
    EventTypeScreen --> WeddingWizardScreen
    EventTypeScreen --> CelebrationWizardScreen
    EventTypeScreen --> BusinessEventWizardScreen
    WeddingWizardScreen --> EventCreatedScreen
    CelebrationWizardScreen --> EventCreatedScreen
    BusinessEventWizardScreen --> EventCreatedScreen
    EventCreatedScreen --> SuggestionsScreen
    SuggestionsScreen --> EventDashboardScreen
    
    %% Event management
    EventsScreen --> EventDashboardScreen
    EventDashboardScreen --> EventDetailsScreen
    EventDetailsScreen --> EventEditScreen
    
    %% Planning tools navigation
    PlanningToolsScreen --> BudgetScreen
    BudgetScreen --> BudgetDetailsScreen
    BudgetDetailsScreen --> BudgetItemFormScreen
    
    PlanningToolsScreen --> GuestListScreen
    GuestListScreen --> GuestFormScreen
    GuestListScreen --> GuestGroupsScreen
    
    PlanningToolsScreen --> TimelineScreen
    TimelineScreen --> MilestoneDetailsScreen
    MilestoneDetailsScreen --> MilestoneFormScreen
    
    PlanningToolsScreen --> MessagingScreen
    MessagingScreen --> ConversationScreen
    ConversationScreen --> ComposeMessageScreen
    
    %% Services flow
    ServicesScreen --> ServiceCategoriesScreen
    ServiceCategoriesScreen --> ServiceListScreen
    ServiceListScreen --> ServiceDetailsScreen
    ServiceDetailsScreen --> ServiceComparisonScreen
    ServiceDetailsScreen --> BookingFormScreen
    BookingFormScreen --> BookingConfirmationScreen
    
    %% Booking management
    ProfileScreen --> BookingHistoryScreen
    BookingHistoryScreen --> BookingDetailsScreen
    BookingDetailsScreen --> ConversationScreen
    
    %% Profile management
    ProfileScreen --> ProfileEditScreen
    ProfileScreen --> SettingsScreen
    SettingsScreen --> NotificationsScreen
    
    %% Cross-connections
    EventDashboardScreen --> BudgetScreen
    EventDashboardScreen --> GuestListScreen
    EventDashboardScreen --> TimelineScreen
    EventDashboardScreen --> MessagingScreen
    EventDashboardScreen --> ServiceCategoriesScreen
    
    BookingConfirmationScreen --> BudgetItemFormScreen
    BookingDetailsScreen --> BudgetDetailsScreen
    
    %% Styling
    classDef primary fill:#f9f,stroke:#333,stroke-width:2px
    classDef secondary fill:#bbf,stroke:#333,stroke-width:1px
    classDef tertiary fill:#ddf,stroke:#333,stroke-width:1px
    
    class SplashScreen,OnboardingScreen,AuthScreen,DashboardScreen primary
    class EventsScreen,ServicesScreen,PlanningToolsScreen,ProfileScreen primary
    class LoginScreen,RegisterScreen,EventTypeScreen,EventDashboardScreen secondary
    class BudgetScreen,GuestListScreen,TimelineScreen,MessagingScreen secondary
    class ServiceCategoriesScreen,BookingHistoryScreen,ProfileEditScreen secondary
```

## Authentication Flow

```mermaid
stateDiagram-v2
    [*] --> SplashScreen
    SplashScreen --> CheckAuthState
    
    state CheckAuthState {
        [*] --> IsUserLoggedIn
        IsUserLoggedIn --> Yes: User token exists
        IsUserLoggedIn --> No: No token
        
        Yes --> ValidateToken
        ValidateToken --> TokenValid: Token is valid
        ValidateToken --> TokenInvalid: Token expired
        
        TokenValid --> [*]: Authenticated
        TokenInvalid --> [*]: Unauthenticated
        No --> [*]: Unauthenticated
    }
    
    CheckAuthState --> OnboardingScreen: First time & Unauthenticated
    CheckAuthState --> AuthScreen: Not first time & Unauthenticated
    CheckAuthState --> DashboardScreen: Authenticated
    
    OnboardingScreen --> AuthScreen
    
    state AuthScreen {
        [*] --> LoginTab
        LoginTab --> RegisterTab: Switch tab
        RegisterTab --> LoginTab: Switch tab
        
        LoginTab --> LoginForm
        RegisterTab --> RegisterForm
        
        LoginForm --> SubmitLogin: Enter credentials
        RegisterForm --> SubmitRegister: Enter details
        
        SubmitLogin --> LoginSuccess: Valid credentials
        SubmitLogin --> LoginFailure: Invalid credentials
        
        SubmitRegister --> RegisterSuccess: Valid details
        SubmitRegister --> RegisterFailure: Invalid details
        
        LoginFailure --> LoginForm: Show error
        RegisterFailure --> RegisterForm: Show error
        
        LoginForm --> ForgotPassword: Tap forgot password
        ForgotPassword --> ResetEmailSent: Submit email
        ResetEmailSent --> LoginForm: Return to login
        
        RegisterSuccess --> VerificationScreen: Email verification required
        LoginSuccess --> [*]: Authenticated
        VerificationScreen --> [*]: Verified
    }
    
    AuthScreen --> DashboardScreen: Authentication successful
```

## Event Creation Flow

```mermaid
stateDiagram-v2
    [*] --> DashboardScreen
    DashboardScreen --> EventsScreen: Navigate to Events
    EventsScreen --> EventTypeScreen: Create New Event
    
    state EventTypeScreen {
        [*] --> SelectEventType
        SelectEventType --> WeddingSelected: Wedding
        SelectEventType --> CelebrationSelected: Celebration
        SelectEventType --> BusinessSelected: Business Event
    }
    
    EventTypeScreen --> WeddingWizardScreen: Wedding selected
    EventTypeScreen --> CelebrationWizardScreen: Celebration selected
    EventTypeScreen --> BusinessEventWizardScreen: Business event selected
    
    state WeddingWizardScreen {
        [*] --> BasicInfo
        BasicInfo --> GuestInfo: Next
        GuestInfo --> Services: Next
        Services --> Budget: Next
        Budget --> Preferences: Next
        Preferences --> Review: Next
        Review --> Submit: Create Event
    }
    
    state CelebrationWizardScreen {
        [*] --> CelebrationBasicInfo
        CelebrationBasicInfo --> CelebrationGuestInfo: Next
        CelebrationGuestInfo --> CelebrationServices: Next
        CelebrationServices --> CelebrationBudget: Next
        CelebrationBudget --> CelebrationPreferences: Next
        CelebrationPreferences --> CelebrationReview: Next
        CelebrationReview --> CelebrationSubmit: Create Event
    }
    
    state BusinessEventWizardScreen {
        [*] --> BusinessBasicInfo
        BusinessBasicInfo --> BusinessGuestInfo: Next
        BusinessGuestInfo --> BusinessServices: Next
        BusinessServices --> BusinessBudget: Next
        BusinessBudget --> BusinessPreferences: Next
        BusinessPreferences --> BusinessReview: Next
        BusinessReview --> BusinessSubmit: Create Event
    }
    
    WeddingWizardScreen --> EventCreatedScreen: Event created
    CelebrationWizardScreen --> EventCreatedScreen: Event created
    BusinessEventWizardScreen --> EventCreatedScreen: Event created
    
    EventCreatedScreen --> SuggestionsScreen: Show suggestions
    SuggestionsScreen --> EventDashboardScreen: Continue to dashboard
```

## Service Booking Flow

```mermaid
stateDiagram-v2
    [*] --> DashboardScreen
    DashboardScreen --> ServicesScreen: Navigate to Services
    
    state ServicesScreen {
        [*] --> BrowseCategories
        BrowseCategories --> SelectCategory: Tap category
    }
    
    ServicesScreen --> ServiceCategoriesScreen: View all categories
    ServiceCategoriesScreen --> ServiceListScreen: Select category
    
    state ServiceListScreen {
        [*] --> BrowseServices
        BrowseServices --> FilterServices: Tap filter
        FilterServices --> ApplyFilters: Set criteria
        ApplyFilters --> FilteredServices: Apply
        FilteredServices --> SelectService: Tap service
        BrowseServices --> SelectService: Tap service
        BrowseServices --> SortServices: Tap sort
        SortServices --> SortedServices: Select sort option
        SortedServices --> SelectService: Tap service
    }
    
    ServiceListScreen --> ServiceDetailsScreen: Select service
    
    state ServiceDetailsScreen {
        [*] --> ViewDetails
        ViewDetails --> ViewGallery: Tap gallery
        ViewDetails --> ViewPackages: Tap packages tab
        ViewDetails --> ViewReviews: Tap reviews tab
        ViewDetails --> AddToCompare: Tap compare
        ViewDetails --> BookNow: Tap book now
    }
    
    ServiceDetailsScreen --> ServiceComparisonScreen: Add to compare
    ServiceComparisonScreen --> ServiceDetailsScreen: Select service
    ServiceDetailsScreen --> BookingFormScreen: Book now
    
    state BookingFormScreen {
        [*] --> SelectDate
        SelectDate --> SelectPackage: Choose date
        SelectPackage --> EnterDetails: Select package
        EnterDetails --> ReviewBooking: Enter details
        ReviewBooking --> ConfirmBooking: Review
    }
    
    BookingFormScreen --> BookingConfirmationScreen: Booking confirmed
    BookingConfirmationScreen --> BookingDetailsScreen: View booking
    BookingConfirmationScreen --> EventDashboardScreen: Return to event
```

## Planning Tools Navigation

```mermaid
stateDiagram-v2
    [*] --> DashboardScreen
    DashboardScreen --> PlanningToolsScreen: Navigate to Planning Tools
    
    state PlanningToolsScreen {
        [*] --> SelectTool
        SelectTool --> BudgetTool: Budget
        SelectTool --> GuestListTool: Guest List
        SelectTool --> TimelineTool: Timeline
        SelectTool --> MessagingTool: Messaging
    }
    
    PlanningToolsScreen --> BudgetScreen: Select Budget
    
    state BudgetScreen {
        [*] --> BudgetOverview
        BudgetOverview --> ViewCategory: Tap category
        BudgetOverview --> AddItem: Tap add
    }
    
    BudgetScreen --> BudgetDetailsScreen: View category
    BudgetScreen --> BudgetItemFormScreen: Add new item
    BudgetDetailsScreen --> BudgetItemFormScreen: Edit item
    
    PlanningToolsScreen --> GuestListScreen: Select Guest List
    
    state GuestListScreen {
        [*] --> GuestOverview
        GuestOverview --> ViewGuest: Tap guest
        GuestOverview --> AddGuest: Tap add
        GuestOverview --> ManageGroups: Tap groups
    }
    
    GuestListScreen --> GuestFormScreen: Add/edit guest
    GuestListScreen --> GuestGroupsScreen: Manage groups
    
    PlanningToolsScreen --> TimelineScreen: Select Timeline
    
    state TimelineScreen {
        [*] --> TimelineOverview
        TimelineOverview --> ViewMilestone: Tap milestone
        TimelineOverview --> AddMilestone: Tap add
    }
    
    TimelineScreen --> MilestoneDetailsScreen: View milestone
    TimelineScreen --> MilestoneFormScreen: Add milestone
    MilestoneDetailsScreen --> MilestoneFormScreen: Edit milestone
    
    PlanningToolsScreen --> MessagingScreen: Select Messaging
    
    state MessagingScreen {
        [*] --> ConversationsList
        ConversationsList --> ViewConversation: Tap conversation
        ConversationsList --> NewMessage: Tap new
    }
    
    MessagingScreen --> ConversationScreen: View conversation
    MessagingScreen --> ComposeMessageScreen: New message
    ConversationScreen --> ComposeMessageScreen: Reply
```

## Bottom Navigation Flow

```mermaid
graph LR
    %% Bottom navigation bar
    subgraph "Bottom Navigation"
        Dashboard[Dashboard]
        Events[Events]
        Services[Services]
        Planning[Planning]
        Profile[Profile]
    end
    
    %% Navigation flow
    Dashboard <--> Events
    Events <--> Services
    Services <--> Planning
    Planning <--> Profile
    Profile <--> Dashboard
    
    %% Styling
    classDef active fill:#f96,stroke:#333,stroke-width:2px
    classDef inactive fill:#ddd,stroke:#333,stroke-width:1px
    
    class Dashboard active
    class Events,Services,Planning,Profile inactive
```

## Deep Linking Structure

```mermaid
graph TD
    %% Root
    Root[eventati://] --> Auth[eventati://auth]
    Root --> Dashboard[eventati://dashboard]
    Root --> Events[eventati://events]
    Root --> Services[eventati://services]
    Root --> Planning[eventati://planning]
    Root --> Profile[eventati://profile]
    
    %% Auth links
    Auth --> Login[eventati://auth/login]
    Auth --> Register[eventati://auth/register]
    Auth --> Verify[eventati://auth/verify]
    Auth --> Reset[eventati://auth/reset]
    
    %% Event links
    Events --> EventsList[eventati://events/list]
    Events --> EventCreate[eventati://events/create]
    Events --> EventDetails[eventati://events/{eventId}]
    EventDetails --> EventEdit[eventati://events/{eventId}/edit]
    
    %% Service links
    Services --> ServiceCategories[eventati://services/categories]
    Services --> ServiceList[eventati://services/list]
    Services --> ServiceDetails[eventati://services/{serviceId}]
    Services --> ServiceCompare[eventati://services/compare]
    
    %% Planning links
    Planning --> Budget[eventati://planning/budget]
    Planning --> GuestList[eventati://planning/guests]
    Planning --> Timeline[eventati://planning/timeline]
    Planning --> Messaging[eventati://planning/messaging]
    
    %% Budget links
    Budget --> BudgetDetails[eventati://planning/budget/{categoryId}]
    Budget --> BudgetItem[eventati://planning/budget/item/{itemId}]
    
    %% Guest list links
    GuestList --> GuestDetails[eventati://planning/guests/{guestId}]
    GuestList --> GuestGroups[eventati://planning/guests/groups]
    
    %% Timeline links
    Timeline --> MilestoneDetails[eventati://planning/timeline/{milestoneId}]
    
    %% Messaging links
    Messaging --> Conversation[eventati://planning/messaging/{conversationId}]
    
    %% Profile links
    Profile --> ProfileEdit[eventati://profile/edit]
    Profile --> Settings[eventati://profile/settings]
    Profile --> Bookings[eventati://profile/bookings]
    Bookings --> BookingDetails[eventati://profile/bookings/{bookingId}]
    
    %% Styling
    classDef root fill:#f9f,stroke:#333,stroke-width:2px
    classDef main fill:#bbf,stroke:#333,stroke-width:1px
    classDef sub fill:#ddf,stroke:#333,stroke-width:1px
    
    class Root root
    class Auth,Dashboard,Events,Services,Planning,Profile main
    class Login,Register,EventsList,ServiceCategories,Budget,GuestList,Timeline,Messaging,ProfileEdit sub
```

## Screen Transitions

```mermaid
sequenceDiagram
    participant User
    participant CurrentScreen
    participant Navigation
    participant NextScreen
    
    User->>CurrentScreen: Tap navigation element
    CurrentScreen->>Navigation: Navigate to route
    Navigation->>NextScreen: Build screen
    NextScreen-->>User: Display screen
    
    Note over Navigation: Transition Animations
    
    alt Page Transition
        Navigation->>NextScreen: Slide from right
    else Modal Transition
        Navigation->>NextScreen: Slide from bottom
    else Tab Transition
        Navigation->>NextScreen: Fade transition
    end
```

## Navigation Architecture

```mermaid
classDiagram
    class AppRouter {
        +Map<String, WidgetBuilder> routes
        +Route onGenerateRoute(RouteSettings)
        +Route onUnknownRoute(RouteSettings)
    }
    
    class NavigationService {
        +GlobalKey<NavigatorState> navigatorKey
        +Future<T> navigateTo<T>(String routeName)
        +Future<T> navigateToWithArgs<T>(String routeName, Object args)
        +void goBack<T>([T result])
        +void popUntil(String routeName)
        +void popAndPushNamed(String routeName)
    }
    
    class RouteNames {
        +static String splash
        +static String onboarding
        +static String auth
        +static String dashboard
        +static String events
        +static String services
        +static String planning
        +static String profile
        +static String eventWizard
        +static String eventDashboard
    }
    
    class RouteArguments {
        +dynamic data
    }
    
    class BottomNavigation {
        +int currentIndex
        +List<BottomNavigationBarItem> items
        +Function(int) onTap
    }
    
    AppRouter --> NavigationService: uses
    AppRouter --> RouteNames: references
    NavigationService --> RouteArguments: passes
    BottomNavigation --> NavigationService: uses
```
