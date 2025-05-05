# Data Model Diagram

This document provides an interactive data model diagram of the Eventati Book application using Mermaid.

## Entity Relationship Diagram

```mermaid
erDiagram
    USER {
        string id PK
        string name
        string email
        string profileImageUrl
        bool isEmailVerified
        datetime createdAt
    }
    
    EVENT {
        string id PK
        string userId FK
        string name
        string type
        datetime date
        string location
        int guestCount
        double budget
        datetime createdAt
        datetime updatedAt
    }
    
    BUDGET {
        string id PK
        string eventId FK
        double totalBudget
        datetime createdAt
        datetime updatedAt
    }
    
    BUDGET_ITEM {
        string id PK
        string budgetId FK
        string category
        string name
        double estimatedCost
        double actualCost
        double paid
        datetime dueDate
        string notes
        bool isBooked
        string bookingId FK
    }
    
    GUEST_LIST {
        string id PK
        string eventId FK
        int estimatedCount
        datetime createdAt
        datetime updatedAt
    }
    
    GUEST {
        string id PK
        string guestListId FK
        string name
        string email
        string phone
        string group
        string rsvpStatus
        bool plusOne
        string notes
    }
    
    TIMELINE {
        string id PK
        string eventId FK
        datetime createdAt
        datetime updatedAt
    }
    
    MILESTONE {
        string id PK
        string timelineId FK
        string title
        string description
        datetime dueDate
        bool isCompleted
        string category
    }
    
    SERVICE_CATEGORY {
        string id PK
        string name
        string description
        string iconUrl
    }
    
    SERVICE {
        string id PK
        string categoryId FK
        string name
        string description
        double minPrice
        double maxPrice
        int minCapacity
        int maxCapacity
        string location
        double rating
        string[] images
        string[] features
    }
    
    BOOKING {
        string id PK
        string eventId FK
        string serviceId FK
        string userId FK
        datetime bookingDate
        string status
        double amount
        string notes
        datetime createdAt
    }
    
    MESSAGE {
        string id PK
        string bookingId FK
        string senderId FK
        string receiverId FK
        string content
        datetime timestamp
        bool isRead
    }
    
    SUGGESTION {
        string id PK
        string eventId FK
        string serviceId FK
        string type
        string reason
        bool isSaved
        datetime createdAt
    }
    
    USER ||--o{ EVENT : "creates"
    EVENT ||--o| BUDGET : "has"
    EVENT ||--o| GUEST_LIST : "has"
    EVENT ||--o| TIMELINE : "has"
    EVENT ||--o{ BOOKING : "has"
    EVENT ||--o{ SUGGESTION : "receives"
    
    BUDGET ||--o{ BUDGET_ITEM : "contains"
    GUEST_LIST ||--o{ GUEST : "contains"
    TIMELINE ||--o{ MILESTONE : "contains"
    
    SERVICE_CATEGORY ||--o{ SERVICE : "contains"
    SERVICE ||--o{ BOOKING : "receives"
    
    BOOKING ||--o{ MESSAGE : "has"
    BOOKING ||--o| BUDGET_ITEM : "linked to"
    
    USER ||--o{ MESSAGE : "sends/receives"
```

## Class Diagram

```mermaid
classDiagram
    class User {
        +String id
        +String name
        +String email
        +String profileImageUrl
        +bool isEmailVerified
        +DateTime createdAt
        +fromJson(Map json)
        +toJson() Map
    }
    
    class Event {
        +String id
        +String userId
        +String name
        +EventType type
        +DateTime date
        +String location
        +int guestCount
        +double budget
        +DateTime createdAt
        +DateTime updatedAt
        +fromJson(Map json)
        +toJson() Map
    }
    
    class Budget {
        +String id
        +String eventId
        +double totalBudget
        +DateTime createdAt
        +DateTime updatedAt
        +List~BudgetItem~ items
        +double get totalSpent
        +double get totalRemaining
        +fromJson(Map json)
        +toJson() Map
    }
    
    class BudgetItem {
        +String id
        +String budgetId
        +String category
        +String name
        +double estimatedCost
        +double actualCost
        +double paid
        +DateTime dueDate
        +String notes
        +bool isBooked
        +String bookingId
        +double get remaining
        +String get status
        +fromJson(Map json)
        +toJson() Map
    }
    
    class GuestList {
        +String id
        +String eventId
        +int estimatedCount
        +DateTime createdAt
        +DateTime updatedAt
        +List~Guest~ guests
        +int get confirmedCount
        +int get pendingCount
        +int get declinedCount
        +fromJson(Map json)
        +toJson() Map
    }
    
    class Guest {
        +String id
        +String guestListId
        +String name
        +String email
        +String phone
        +String group
        +RsvpStatus rsvpStatus
        +bool plusOne
        +String notes
        +fromJson(Map json)
        +toJson() Map
    }
    
    class Timeline {
        +String id
        +String eventId
        +DateTime createdAt
        +DateTime updatedAt
        +List~Milestone~ milestones
        +int get completedCount
        +int get pendingCount
        +double get progressPercentage
        +fromJson(Map json)
        +toJson() Map
    }
    
    class Milestone {
        +String id
        +String timelineId
        +String title
        +String description
        +DateTime dueDate
        +bool isCompleted
        +String category
        +bool get isOverdue
        +int get daysRemaining
        +fromJson(Map json)
        +toJson() Map
    }
    
    class ServiceCategory {
        +String id
        +String name
        +String description
        +String iconUrl
        +fromJson(Map json)
        +toJson() Map
    }
    
    class Service {
        +String id
        +String categoryId
        +String name
        +String description
        +double minPrice
        +double maxPrice
        +int minCapacity
        +int maxCapacity
        +String location
        +double rating
        +List~String~ images
        +List~String~ features
        +String get priceRange
        +String get capacityRange
        +fromJson(Map json)
        +toJson() Map
    }
    
    class Booking {
        +String id
        +String eventId
        +String serviceId
        +String userId
        +DateTime bookingDate
        +BookingStatus status
        +double amount
        +String notes
        +DateTime createdAt
        +fromJson(Map json)
        +toJson() Map
    }
    
    class Message {
        +String id
        +String bookingId
        +String senderId
        +String receiverId
        +String content
        +DateTime timestamp
        +bool isRead
        +fromJson(Map json)
        +toJson() Map
    }
    
    class Suggestion {
        +String id
        +String eventId
        +String serviceId
        +SuggestionType type
        +String reason
        +bool isSaved
        +DateTime createdAt
        +fromJson(Map json)
        +toJson() Map
    }
    
    User "1" -- "many" Event : creates
    Event "1" -- "1" Budget : has
    Event "1" -- "1" GuestList : has
    Event "1" -- "1" Timeline : has
    Event "1" -- "many" Booking : has
    Event "1" -- "many" Suggestion : receives
    
    Budget "1" -- "many" BudgetItem : contains
    GuestList "1" -- "many" Guest : contains
    Timeline "1" -- "many" Milestone : contains
    
    ServiceCategory "1" -- "many" Service : contains
    Service "1" -- "many" Booking : receives
    
    Booking "1" -- "many" Message : has
    Booking "1" -- "0..1" BudgetItem : "linked to"
    
    User "1" -- "many" Message : "sends/receives"
```

## Data Flow Diagram

```mermaid
flowchart TD
    %% External entities
    User((User))
    Vendor((Vendor))
    
    %% Processes
    AuthProcess[Authentication Process]
    EventCreationProcess[Event Creation Process]
    BudgetManagementProcess[Budget Management Process]
    GuestManagementProcess[Guest Management Process]
    TimelineProcess[Timeline Management Process]
    ServiceBookingProcess[Service Booking Process]
    MessagingProcess[Messaging Process]
    
    %% Data stores
    UserStore[(User Data)]
    EventStore[(Event Data)]
    BudgetStore[(Budget Data)]
    GuestStore[(Guest Data)]
    TimelineStore[(Timeline Data)]
    ServiceStore[(Service Data)]
    BookingStore[(Booking Data)]
    MessageStore[(Message Data)]
    
    %% Data flows - User to processes
    User -->|Login/Register| AuthProcess
    User -->|Create Event| EventCreationProcess
    User -->|Manage Budget| BudgetManagementProcess
    User -->|Manage Guests| GuestManagementProcess
    User -->|Track Timeline| TimelineProcess
    User -->|Book Services| ServiceBookingProcess
    User -->|Send Messages| MessagingProcess
    
    %% Data flows - Vendor to processes
    Vendor -->|Login/Register| AuthProcess
    Vendor -->|Manage Services| ServiceBookingProcess
    Vendor -->|Send Messages| MessagingProcess
    
    %% Data flows - Processes to data stores
    AuthProcess -->|Store User Data| UserStore
    EventCreationProcess -->|Store Event Data| EventStore
    BudgetManagementProcess -->|Store Budget Data| BudgetStore
    GuestManagementProcess -->|Store Guest Data| GuestStore
    TimelineProcess -->|Store Timeline Data| TimelineStore
    ServiceBookingProcess -->|Store Service Data| ServiceStore
    ServiceBookingProcess -->|Store Booking Data| BookingStore
    MessagingProcess -->|Store Message Data| MessageStore
    
    %% Data flows - Data stores to processes
    UserStore -->|Retrieve User Data| AuthProcess
    EventStore -->|Retrieve Event Data| EventCreationProcess
    BudgetStore -->|Retrieve Budget Data| BudgetManagementProcess
    GuestStore -->|Retrieve Guest Data| GuestManagementProcess
    TimelineStore -->|Retrieve Timeline Data| TimelineProcess
    ServiceStore -->|Retrieve Service Data| ServiceBookingProcess
    BookingStore -->|Retrieve Booking Data| ServiceBookingProcess
    MessageStore -->|Retrieve Message Data| MessagingProcess
    
    %% Cross-process data flows
    EventCreationProcess -->|Initialize| BudgetManagementProcess
    EventCreationProcess -->|Initialize| GuestManagementProcess
    EventCreationProcess -->|Initialize| TimelineProcess
    ServiceBookingProcess -->|Update| BudgetManagementProcess
    
    %% Process to user data flows
    AuthProcess -->|Authentication Result| User
    EventCreationProcess -->|Event Creation Result| User
    BudgetManagementProcess -->|Budget Updates| User
    GuestManagementProcess -->|Guest List Updates| User
    TimelineProcess -->|Timeline Updates| User
    ServiceBookingProcess -->|Booking Confirmation| User
    MessagingProcess -->|Message Delivery| User
    MessagingProcess -->|Message Delivery| Vendor
```

## Firebase Collections Structure

```mermaid
graph TD
    %% Root collections
    Firebase[Firebase] --> Users[Users Collection]
    Firebase --> Events[Events Collection]
    Firebase --> Budgets[Budgets Collection]
    Firebase --> GuestLists[Guest Lists Collection]
    Firebase --> Timelines[Timelines Collection]
    Firebase --> Services[Services Collection]
    Firebase --> Bookings[Bookings Collection]
    Firebase --> Messages[Messages Collection]
    Firebase --> Suggestions[Suggestions Collection]
    
    %% Users collection
    Users --> User1[User Document]
    User1 --> UserData1[User Data]
    
    %% Events collection
    Events --> Event1[Event Document]
    Event1 --> EventData1[Event Data]
    
    %% Budgets collection
    Budgets --> Budget1[Budget Document]
    Budget1 --> BudgetData1[Budget Data]
    Budget1 --> BudgetItems1[Budget Items Subcollection]
    BudgetItems1 --> BudgetItem1[Budget Item Document]
    BudgetItem1 --> BudgetItemData1[Budget Item Data]
    
    %% Guest Lists collection
    GuestLists --> GuestList1[Guest List Document]
    GuestList1 --> GuestListData1[Guest List Data]
    GuestList1 --> Guests1[Guests Subcollection]
    Guests1 --> Guest1[Guest Document]
    Guest1 --> GuestData1[Guest Data]
    
    %% Timelines collection
    Timelines --> Timeline1[Timeline Document]
    Timeline1 --> TimelineData1[Timeline Data]
    Timeline1 --> Milestones1[Milestones Subcollection]
    Milestones1 --> Milestone1[Milestone Document]
    Milestone1 --> MilestoneData1[Milestone Data]
    
    %% Services collection
    Services --> ServiceCategories[Service Categories Subcollection]
    ServiceCategories --> Category1[Category Document]
    Category1 --> CategoryData1[Category Data]
    Services --> Service1[Service Document]
    Service1 --> ServiceData1[Service Data]
    
    %% Bookings collection
    Bookings --> Booking1[Booking Document]
    Booking1 --> BookingData1[Booking Data]
    
    %% Messages collection
    Messages --> Message1[Message Document]
    Message1 --> MessageData1[Message Data]
    
    %% Suggestions collection
    Suggestions --> Suggestion1[Suggestion Document]
    Suggestion1 --> SuggestionData1[Suggestion Data]
    
    %% Relationships
    UserData1 -.-> |userId| EventData1
    EventData1 -.-> |eventId| BudgetData1
    EventData1 -.-> |eventId| GuestListData1
    EventData1 -.-> |eventId| TimelineData1
    EventData1 -.-> |eventId| BookingData1
    EventData1 -.-> |eventId| SuggestionData1
    BudgetData1 -.-> |budgetId| BudgetItemData1
    GuestListData1 -.-> |guestListId| GuestData1
    TimelineData1 -.-> |timelineId| MilestoneData1
    CategoryData1 -.-> |categoryId| ServiceData1
    ServiceData1 -.-> |serviceId| BookingData1
    BookingData1 -.-> |bookingId| MessageData1
    BookingData1 -.-> |bookingId| BudgetItemData1
    UserData1 -.-> |userId| MessageData1
    ServiceData1 -.-> |serviceId| SuggestionData1
```

## Model Class Hierarchy

```mermaid
classDiagram
    class BaseModel {
        +String id
        +DateTime createdAt
        +fromJson(Map json)*
        +toJson() Map*
    }
    
    class UserModel {
        +String name
        +String email
        +String profileImageUrl
        +bool isEmailVerified
        +fromJson(Map json)
        +toJson() Map
    }
    
    class EventModel {
        +String userId
        +String name
        +EventType type
        +DateTime date
        +String location
        +int guestCount
        +double budget
        +DateTime updatedAt
        +fromJson(Map json)
        +toJson() Map
    }
    
    class BudgetModel {
        +String eventId
        +double totalBudget
        +DateTime updatedAt
        +List~BudgetItemModel~ items
        +double get totalSpent
        +double get totalRemaining
        +fromJson(Map json)
        +toJson() Map
    }
    
    class BudgetItemModel {
        +String budgetId
        +String category
        +String name
        +double estimatedCost
        +double actualCost
        +double paid
        +DateTime dueDate
        +String notes
        +bool isBooked
        +String bookingId
        +double get remaining
        +String get status
        +fromJson(Map json)
        +toJson() Map
    }
    
    class GuestListModel {
        +String eventId
        +int estimatedCount
        +DateTime updatedAt
        +List~GuestModel~ guests
        +int get confirmedCount
        +int get pendingCount
        +int get declinedCount
        +fromJson(Map json)
        +toJson() Map
    }
    
    class GuestModel {
        +String guestListId
        +String name
        +String email
        +String phone
        +String group
        +RsvpStatus rsvpStatus
        +bool plusOne
        +String notes
        +fromJson(Map json)
        +toJson() Map
    }
    
    class TimelineModel {
        +String eventId
        +DateTime updatedAt
        +List~MilestoneModel~ milestones
        +int get completedCount
        +int get pendingCount
        +double get progressPercentage
        +fromJson(Map json)
        +toJson() Map
    }
    
    class MilestoneModel {
        +String timelineId
        +String title
        +String description
        +DateTime dueDate
        +bool isCompleted
        +String category
        +bool get isOverdue
        +int get daysRemaining
        +fromJson(Map json)
        +toJson() Map
    }
    
    class ServiceCategoryModel {
        +String name
        +String description
        +String iconUrl
        +fromJson(Map json)
        +toJson() Map
    }
    
    class ServiceModel {
        +String categoryId
        +String name
        +String description
        +double minPrice
        +double maxPrice
        +int minCapacity
        +int maxCapacity
        +String location
        +double rating
        +List~String~ images
        +List~String~ features
        +String get priceRange
        +String get capacityRange
        +fromJson(Map json)
        +toJson() Map
    }
    
    class BookingModel {
        +String eventId
        +String serviceId
        +String userId
        +DateTime bookingDate
        +BookingStatus status
        +double amount
        +String notes
        +fromJson(Map json)
        +toJson() Map
    }
    
    class MessageModel {
        +String bookingId
        +String senderId
        +String receiverId
        +String content
        +DateTime timestamp
        +bool isRead
        +fromJson(Map json)
        +toJson() Map
    }
    
    class SuggestionModel {
        +String eventId
        +String serviceId
        +SuggestionType type
        +String reason
        +bool isSaved
        +fromJson(Map json)
        +toJson() Map
    }
    
    BaseModel <|-- UserModel
    BaseModel <|-- EventModel
    BaseModel <|-- BudgetModel
    BaseModel <|-- BudgetItemModel
    BaseModel <|-- GuestListModel
    BaseModel <|-- GuestModel
    BaseModel <|-- TimelineModel
    BaseModel <|-- MilestoneModel
    BaseModel <|-- ServiceCategoryModel
    BaseModel <|-- ServiceModel
    BaseModel <|-- BookingModel
    BaseModel <|-- MessageModel
    BaseModel <|-- SuggestionModel
```

## Provider Dependencies

```mermaid
graph TD
    %% Provider classes
    AuthProvider[Auth Provider]
    EventProvider[Event Provider]
    BudgetProvider[Budget Provider]
    GuestListProvider[Guest List Provider]
    TimelineProvider[Timeline Provider]
    ServiceProvider[Service Provider]
    BookingProvider[Booking Provider]
    MessagingProvider[Messaging Provider]
    SuggestionProvider[Suggestion Provider]
    
    %% Dependencies
    AuthProvider --> EventProvider
    EventProvider --> BudgetProvider
    EventProvider --> GuestListProvider
    EventProvider --> TimelineProvider
    EventProvider --> SuggestionProvider
    
    ServiceProvider --> BookingProvider
    BookingProvider --> BudgetProvider
    BookingProvider --> MessagingProvider
    
    %% Model dependencies
    AuthProvider --> UserModel[User Model]
    EventProvider --> EventModel[Event Model]
    BudgetProvider --> BudgetModel[Budget Model]
    BudgetProvider --> BudgetItemModel[Budget Item Model]
    GuestListProvider --> GuestListModel[Guest List Model]
    GuestListProvider --> GuestModel[Guest Model]
    TimelineProvider --> TimelineModel[Timeline Model]
    TimelineProvider --> MilestoneModel[Milestone Model]
    ServiceProvider --> ServiceCategoryModel[Service Category Model]
    ServiceProvider --> ServiceModel[Service Model]
    BookingProvider --> BookingModel[Booking Model]
    MessagingProvider --> MessageModel[Message Model]
    SuggestionProvider --> SuggestionModel[Suggestion Model]
    
    %% Service dependencies
    AuthProvider --> AuthService[Auth Service]
    EventProvider --> EventService[Event Service]
    BudgetProvider --> BudgetService[Budget Service]
    GuestListProvider --> GuestListService[Guest List Service]
    TimelineProvider --> TimelineService[Timeline Service]
    ServiceProvider --> ServiceService[Service Service]
    BookingProvider --> BookingService[Booking Service]
    MessagingProvider --> MessagingService[Messaging Service]
    SuggestionProvider --> SuggestionService[Suggestion Service]
    
    %% Data storage
    AuthService --> DataStorage[Data Storage]
    EventService --> DataStorage
    BudgetService --> DataStorage
    GuestListService --> DataStorage
    TimelineService --> DataStorage
    ServiceService --> DataStorage
    BookingService --> DataStorage
    MessagingService --> DataStorage
    SuggestionService --> DataStorage
```
