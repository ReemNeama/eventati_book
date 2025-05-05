# Interactive Event Planning Process Diagram

This document provides an interactive diagram of the event planning process in the Eventati Book application.

## Event Planning Process Overview

```mermaid
%%{init: {'theme': 'base', 'themeVariables': { 'primaryColor': '#f0d0ff', 'primaryTextColor': '#303030', 'primaryBorderColor': '#9370db', 'lineColor': '#9370db', 'secondaryColor': '#d0e0ff', 'tertiaryColor': '#fff0f0'}}}%%
flowchart TD
    Start([Start Planning]) --> EventType{Choose Event Type}
    
    EventType -->|Wedding| Wedding[Wedding Event]
    EventType -->|Celebration| Celebration[Celebration Event]
    EventType -->|Business| Business[Business Event]
    
    Wedding --> BasicInfo[Enter Basic Information]
    Celebration --> BasicInfo
    Business --> BasicInfo
    
    BasicInfo --> GuestInfo[Define Guest Information]
    GuestInfo --> Services[Select Required Services]
    Services --> Budget[Set Budget Parameters]
    Budget --> Preferences[Specify Preferences]
    Preferences --> Review[Review Details]
    Review --> Create[Create Event]
    
    Create --> Planning{Planning Phase}
    
    Planning -->|Budget| BudgetTool[Budget Management]
    Planning -->|Guests| GuestTool[Guest List Management]
    Planning -->|Timeline| TimelineTool[Timeline Management]
    Planning -->|Messaging| MessagingTool[Vendor Communication]
    
    BudgetTool --> ServiceBooking[Book Services]
    GuestTool --> TrackRSVPs[Track RSVPs]
    TimelineTool --> TrackProgress[Track Progress]
    MessagingTool --> VendorComm[Communicate with Vendors]
    
    ServiceBooking --> EventReady[Event Ready]
    TrackRSVPs --> EventReady
    TrackProgress --> EventReady
    VendorComm --> EventReady
    
    EventReady --> End([Event Day])
    
    click Wedding "#wedding-event" "View Wedding Event Details"
    click Celebration "#celebration-event" "View Celebration Event Details"
    click Business "#business-event" "View Business Event Details"
    click BudgetTool "#budget-management" "View Budget Management Details"
    click GuestTool "#guest-management" "View Guest Management Details"
    click TimelineTool "#timeline-management" "View Timeline Management Details"
    click MessagingTool "#messaging" "View Messaging Details"
    click ServiceBooking "#service-booking" "View Service Booking Details"
```

## Event Types

### Wedding Event {#wedding-event}

Wedding events in Eventati Book include specialized features for planning the perfect wedding:

```mermaid
%%{init: {'theme': 'base', 'themeVariables': { 'primaryColor': '#fff0f0', 'primaryTextColor': '#303030', 'primaryBorderColor': '#ff9999', 'lineColor': '#ff9999', 'secondaryColor': '#ffe6e6', 'tertiaryColor': '#fff0f0'}}}%%
mindmap
  root((Wedding<br>Planning))
    Basic Information
      Wedding couple names
      Wedding date
      Venue type preferences
      Wedding style/theme
    Guest Management
      Wedding party
      Family groups
      Plus-ones
      Special accommodations
    Services
      Venue
      Catering
      Photography/Videography
      Flowers/Decorations
      Music/Entertainment
      Wedding attire
      Transportation
    Budget Categories
      Venue & Catering
      Attire & Beauty
      Photography & Video
      Decorations & Flowers
      Entertainment
      Stationery
      Gifts
    Special Features
      Wedding website
      Registry management
      Seating arrangements
      Wedding timeline
      Ceremony planning
      Reception planning
```

### Celebration Event {#celebration-event}

Celebration events cover birthdays, anniversaries, and other special occasions:

```mermaid
%%{init: {'theme': 'base', 'themeVariables': { 'primaryColor': '#f0fff0', 'primaryTextColor': '#303030', 'primaryBorderColor': '#99cc99', 'lineColor': '#99cc99', 'secondaryColor': '#e6ffe6', 'tertiaryColor': '#f0fff0'}}}%%
mindmap
  root((Celebration<br>Planning))
    Basic Information
      Celebration type
      Honoree information
      Date and time
      Occasion theme
    Guest Management
      Age groups
      Special guests
      Group invitations
      RSVP tracking
    Services
      Venue
      Catering
      Entertainment
      Decorations
      Photography
      Cake/Desserts
    Budget Categories
      Venue
      Food & Drinks
      Entertainment
      Decorations
      Photography
      Gifts/Favors
    Special Features
      Activity planning
      Special moments
      Surprise elements
      Theme coordination
      Memory sharing
```

### Business Event {#business-event}

Business events include conferences, seminars, team-building, and corporate functions:

```mermaid
%%{init: {'theme': 'base', 'themeVariables': { 'primaryColor': '#f0f0ff', 'primaryTextColor': '#303030', 'primaryBorderColor': '#9999cc', 'lineColor': '#9999cc', 'secondaryColor': '#e6e6ff', 'tertiaryColor': '#f0f0ff'}}}%%
mindmap
  root((Business<br>Event))
    Basic Information
      Event purpose
      Company information
      Date and duration
      Event format
    Attendee Management
      Registration
      Attendee types
      VIP management
      Capacity planning
    Services
      Venue
      Catering
      AV equipment
      Accommodations
      Transportation
      Printing/Materials
    Budget Categories
      Venue & Equipment
      Catering & Refreshments
      Speaker/Presenter Fees
      Marketing & Promotion
      Staff & Management
      Materials & Supplies
    Special Features
      Agenda planning
      Speaker management
      Presentation setup
      Networking opportunities
      Branding elements
      Feedback collection
```

## Planning Tools

### Budget Management {#budget-management}

The budget management tool helps track expenses and stay within budget:

```mermaid
%%{init: {'theme': 'base', 'themeVariables': { 'primaryColor': '#fffff0', 'primaryTextColor': '#303030', 'primaryBorderColor': '#cccc99', 'lineColor': '#cccc99', 'secondaryColor': '#ffffe6', 'tertiaryColor': '#fffff0'}}}%%
graph TD
    BudgetStart([Budget Planning]) --> SetTotal[Set Total Budget]
    SetTotal --> AllocateCategories[Allocate to Categories]
    
    AllocateCategories --> TrackExpenses[Track Expenses]
    TrackExpenses --> AddItems[Add Budget Items]
    
    AddItems --> EstimateCosts[Estimate Costs]
    EstimateCosts --> RecordActual[Record Actual Costs]
    RecordActual --> TrackPayments[Track Payments]
    
    TrackPayments --> MonitorStatus{Monitor Status}
    
    MonitorStatus -->|Under Budget| GoodStatus[Good Standing]
    MonitorStatus -->|Over Budget| AdjustBudget[Adjust Budget]
    
    AdjustBudget --> ReallocateFunds[Reallocate Funds]
    ReallocateFunds --> MonitorStatus
    
    GoodStatus --> BudgetComplete([Budget Complete])
    
    click SetTotal "#set-total-budget" "Set Total Budget"
    click AllocateCategories "#allocate-categories" "Allocate to Categories"
    click AddItems "#add-budget-items" "Add Budget Items"
    click TrackPayments "#track-payments" "Track Payments"
```

#### Set Total Budget {#set-total-budget}

Setting the total budget involves:

1. Determining overall budget amount
2. Considering funding sources
3. Setting budget flexibility (±10%)
4. Establishing budget timeline

#### Allocate Categories {#allocate-categories}

Budget categories are allocated based on:

1. Event type (wedding, celebration, business)
2. Typical percentage breakdowns
3. Priority services
4. Custom category creation

#### Add Budget Items {#add-budget-items}

Budget items include:

1. Item name and category
2. Estimated cost
3. Actual cost (updated later)
4. Payment tracking
5. Due dates
6. Notes and vendor information

#### Track Payments {#track-payments}

Payment tracking includes:

1. Recording deposits
2. Tracking payment schedules
3. Managing final payments
4. Tracking payment methods
5. Storing receipts/invoices

### Guest Management {#guest-management}

The guest management tool helps organize attendees:

```mermaid
%%{init: {'theme': 'base', 'themeVariables': { 'primaryColor': '#f0ffff', 'primaryTextColor': '#303030', 'primaryBorderColor': '#99cccc', 'lineColor': '#99cccc', 'secondaryColor': '#e6ffff', 'tertiaryColor': '#f0ffff'}}}%%
graph TD
    GuestStart([Guest Management]) --> EstimateCount[Estimate Guest Count]
    EstimateCount --> CreateGroups[Create Guest Groups]
    
    CreateGroups --> AddGuests[Add Guests]
    AddGuests --> CollectInfo[Collect Guest Information]
    
    CollectInfo --> SendInvites[Send Invitations]
    SendInvites --> TrackRSVPs[Track RSVPs]
    
    TrackRSVPs --> ManageChanges[Manage Changes]
    ManageChanges --> FinalizeList[Finalize Guest List]
    
    FinalizeList --> GuestComplete([Guest List Complete])
    
    click EstimateCount "#estimate-guest-count" "Estimate Guest Count"
    click CreateGroups "#create-guest-groups" "Create Guest Groups"
    click CollectInfo "#collect-guest-information" "Collect Guest Information"
    click TrackRSVPs "#track-rsvps" "Track RSVPs"
```

#### Estimate Guest Count {#estimate-guest-count}

Estimating guest count involves:

1. Setting initial target number
2. Considering venue capacity
3. Aligning with budget constraints
4. Planning for different scenarios

#### Create Guest Groups {#create-guest-groups}

Guest groups help organize attendees by:

1. Relationship (family, friends, colleagues)
2. Table assignments
3. Priority tiers
4. Special categories (VIPs, wedding party)

#### Collect Guest Information {#collect-guest-information}

Guest information includes:

1. Name and contact details
2. Email and phone number
3. Dietary restrictions
4. Accommodation needs
5. Plus-one status
6. Special notes

#### Track RSVPs {#track-rsvps}

RSVP tracking includes:

1. Recording responses (attending, declined, pending)
2. Tracking meal choices
3. Managing plus-ones
4. Sending reminders
5. Updating final counts

### Timeline Management {#timeline-management}

The timeline management tool helps track planning milestones:

```mermaid
%%{init: {'theme': 'base', 'themeVariables': { 'primaryColor': '#fff0ff', 'primaryTextColor': '#303030', 'primaryBorderColor': '#cc99cc', 'lineColor': '#cc99cc', 'secondaryColor': '#ffe6ff', 'tertiaryColor': '#fff0ff'}}}%%
graph TD
    TimelineStart([Timeline Planning]) --> CreateTimeline[Create Timeline]
    CreateTimeline --> AddMilestones[Add Milestones]
    
    AddMilestones --> SetDueDates[Set Due Dates]
    SetDueDates --> AssignCategories[Assign Categories]
    
    AssignCategories --> TrackProgress[Track Progress]
    TrackProgress --> ReceiveReminders[Receive Reminders]
    
    ReceiveReminders --> CompleteTasks[Complete Tasks]
    CompleteTasks --> UpdateStatus[Update Status]
    
    UpdateStatus --> TimelineComplete([Timeline Complete])
    
    click CreateTimeline "#create-timeline" "Create Timeline"
    click AddMilestones "#add-milestones" "Add Milestones"
    click TrackProgress "#track-progress" "Track Progress"
    click ReceiveReminders "#receive-reminders" "Receive Reminders"
```

#### Create Timeline {#create-timeline}

Creating a timeline involves:

1. Setting event date as anchor point
2. Working backward to establish planning schedule
3. Identifying key planning phases
4. Setting up timeline structure

#### Add Milestones {#add-milestones}

Milestones include:

1. Task name and description
2. Category assignment
3. Priority level
4. Dependencies on other tasks
5. Notes and details

#### Track Progress {#track-progress}

Progress tracking includes:

1. Marking tasks as complete
2. Viewing percentage complete
3. Identifying overdue tasks
4. Adjusting timeline as needed
5. Visualizing progress

#### Receive Reminders {#receive-reminders}

Reminders help stay on track with:

1. Upcoming deadline notifications
2. Overdue task alerts
3. Important milestone reminders
4. Weekly planning summaries
5. Critical path notifications

### Messaging {#messaging}

The messaging tool facilitates communication with vendors:

```mermaid
%%{init: {'theme': 'base', 'themeVariables': { 'primaryColor': '#ffe0cc', 'primaryTextColor': '#303030', 'primaryBorderColor': '#ff9933', 'lineColor': '#ff9933', 'secondaryColor': '#fff0e6', 'tertiaryColor': '#fff5ee'}}}%%
graph TD
    MessagingStart([Vendor Communication]) --> ViewVendors[View Vendor List]
    ViewVendors --> SelectVendor[Select Vendor]
    
    SelectVendor --> ViewConversation[View Conversation History]
    ViewConversation --> ComposeMessage[Compose Message]
    
    ComposeMessage --> SendMessage[Send Message]
    SendMessage --> ReceiveResponse[Receive Response]
    
    ReceiveResponse --> ContinueConversation[Continue Conversation]
    ContinueConversation --> ResolveInquiry[Resolve Inquiry]
    
    ResolveInquiry --> MessagingComplete([Communication Complete])
    
    click ViewVendors "#view-vendors" "View Vendor List"
    click ViewConversation "#view-conversation" "View Conversation History"
    click ComposeMessage "#compose-message" "Compose Message"
    click ReceiveResponse "#receive-response" "Receive Response"
```

#### View Vendors {#view-vendors}

Vendor management includes:

1. Viewing all booked vendors
2. Sorting by service category
3. Seeing contact information
4. Viewing booking details
5. Managing vendor status

#### View Conversation {#view-conversation}

Conversation history shows:

1. Complete message thread
2. Date and time stamps
3. Read/unread status
4. Attachments and shared files
5. Important message flags

#### Compose Message {#compose-message}

Message composition includes:

1. Writing message content
2. Adding attachments
3. Setting priority level
4. Saving drafts
5. Using templates

#### Receive Response {#receive-response}

Response handling includes:

1. Notification of new messages
2. Quick reply options
3. Message forwarding
4. Marking important information
5. Setting follow-up reminders

## Service Booking {#service-booking}

The service booking process helps secure vendors for the event:

```mermaid
%%{init: {'theme': 'base', 'themeVariables': { 'primaryColor': '#e6f2ff', 'primaryTextColor': '#303030', 'primaryBorderColor': '#4d94ff', 'lineColor': '#4d94ff', 'secondaryColor': '#f0f7ff', 'tertiaryColor': '#f5faff'}}}%%
graph TD
    BookingStart([Service Booking]) --> BrowseServices[Browse Service Categories]
    BrowseServices --> FilterOptions[Filter Options]
    
    FilterOptions --> ViewDetails[View Service Details]
    ViewDetails --> CompareServices[Compare Services]
    
    CompareServices --> SelectService[Select Service]
    SelectService --> BookingForm[Complete Booking Form]
    
    BookingForm --> ConfirmBooking[Confirm Booking]
    ConfirmBooking --> ReceiveConfirmation[Receive Confirmation]
    
    ReceiveConfirmation --> UpdateBudget[Update Budget]
    UpdateBudget --> CommunicateVendor[Communicate with Vendor]
    
    CommunicateVendor --> BookingComplete([Booking Complete])
    
    click BrowseServices "#browse-services" "Browse Service Categories"
    click FilterOptions "#filter-options" "Filter Options"
    click ViewDetails "#view-details" "View Service Details"
    click BookingForm "#booking-form" "Complete Booking Form"
    click UpdateBudget "#update-budget" "Update Budget"
```

#### Browse Services {#browse-services}

Service browsing includes:

1. Viewing service categories
2. Seeing featured services
3. Browsing recommended options
4. Searching for specific vendors
5. Viewing recently viewed services

#### Filter Options {#filter-options}

Filtering options include:

1. Price range
2. Location/distance
3. Capacity (for venues)
4. Rating/reviews
5. Availability
6. Features and amenities

#### View Details {#view-details}

Service details include:

1. Description and overview
2. Photo gallery
3. Pricing and packages
4. Reviews and ratings
5. Availability calendar
6. Features and amenities
7. Policies and terms

#### Booking Form {#booking-form}

The booking form includes:

1. Date and time selection
2. Package/option selection
3. Special requirements
4. Contact information
5. Payment details
6. Terms acceptance

#### Update Budget {#update-budget}

Budget updates include:

1. Adding booking to budget
2. Recording deposit amount
3. Setting payment schedule
4. Linking to budget category
5. Updating budget status

## Interactive Event Planning Timeline

```mermaid
%%{init: {'theme': 'base', 'themeVariables': { 'primaryColor': '#f5f5f5', 'primaryTextColor': '#303030', 'primaryBorderColor': '#999999', 'lineColor': '#999999', 'secondaryColor': '#f9f9f9', 'tertiaryColor': '#fcfcfc'}}}%%
timeline
    title Event Planning Timeline
    
    section 12+ Months Before
      Create event : Set date
      : Set budget
      : Start guest list
      : Research venues
    
    section 9-12 Months Before
      Book venue : Secure date
      : Research vendors
      : Create wedding website
      : Send save-the-dates
    
    section 6-9 Months Before
      Book key vendors : Catering
      : Photography
      : Entertainment
      : Attire
    
    section 4-6 Months Before
      Finalize details : Menu selection
      : Order invitations
      : Book accommodations
      : Plan honeymoon
    
    section 2-4 Months Before
      Send invitations : Track RSVPs
      : Finalize guest count
      : Confirm vendors
      : Purchase rings
    
    section 1-2 Months Before
      Final preparations : Finalize timeline
      : Confirm details
      : Final payments
      : Rehearsal planning
    
    section 1-2 Weeks Before
      Last details : Final guest count
      : Seating arrangements
      : Vendor confirmations
      : Pack essentials
    
    section Event Day
      Execution : Setup
      : Coordination
      : Celebration
      : Memories
```

## Event Planning Checklist

```mermaid
%%{init: {'theme': 'base', 'themeVariables': { 'primaryColor': '#f0f0f0', 'primaryTextColor': '#303030', 'primaryBorderColor': '#999999', 'lineColor': '#999999', 'secondaryColor': '#f5f5f5', 'tertiaryColor': '#fafafa'}}}%%
journey
    title Event Planning Progress
    
    section Initial Planning
      Set date: 5: Done
      Set budget: 5: Done
      Create guest list: 4: In Progress
      Research venues: 5: Done
    
    section Booking Phase
      Book venue: 5: Done
      Book catering: 5: Done
      Book photography: 5: Done
      Book entertainment: 3: In Progress
      Book transportation: 1: Not Started
    
    section Details Phase
      Order invitations: 5: Done
      Send invitations: 4: In Progress
      Track RSVPs: 3: In Progress
      Finalize menu: 4: In Progress
      Create timeline: 2: Not Started
    
    section Final Preparations
      Final vendor confirmations: 1: Not Started
      Final guest count: 1: Not Started
      Seating arrangements: 1: Not Started
      Final payments: 1: Not Started
      Rehearsal planning: 1: Not Started
```
