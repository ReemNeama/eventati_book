# Eventati Book Event Planning Tools

This document provides a visual representation of the event planning tools in the Eventati Book application.

## Event Planning Tools Overview

```
┌─────────────────────────────────────────────────────────────────────────┐
│                       EVENT PLANNING TOOLS                              │
└───────────────────────────────────┬─────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                    EVENT PLANNING TOOLS SCREEN                          │
│                                                                         │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐    │
│  │  Budget     │  │  Guest List │  │  Timeline   │  │  Messaging  │    │
│  │  Tool       │  │  Tool       │  │  Tool       │  │  Tool       │    │
│  └──────┬──────┘  └──────┬──────┘  └──────┬──────┘  └──────┬──────┘    │
│         │                │                │                │           │
│         └────────────────┼────────────────┼────────────────┘           │
│                          │                │                            │
└──────────────────────────┼────────────────┼────────────────────────────┘
                           │                │
           ┌───────────────┘                └───────────────┐
           │                                                │
           ▼                                                ▼
┌─────────────────────────────┐              ┌─────────────────────────────┐
│      BUDGET TOOL            │              │      GUEST LIST TOOL        │
│                             │              │                             │
│  ┌─────────────────────┐    │              │  ┌─────────────────────┐    │
│  │  Budget Overview    │    │              │  │  Guest List         │    │
│  │  Screen             │────┼──┐           │  │  Screen             │────┼──┐
│  └─────────────────────┘    │  │           │  └─────────────────────┘    │  │
│                             │  │           │                             │  │
│  ┌─────────────────────┐    │  │           │  ┌─────────────────────┐    │  │
│  │  Budget Details     │◀───┼──┘           │  │  Guest Details      │◀───┼──┘
│  │  Screen             │    │              │  │  Screen             │    │
│  └─────────────────────┘    │              │  └─────────────────────┘    │
│                             │              │                             │
│  ┌─────────────────────┐    │              │  ┌─────────────────────┐    │
│  │  Budget Item Form   │    │              │  │  Guest Form         │    │
│  │  Screen             │    │              │  │  Screen             │    │
│  └─────────────────────┘    │              │  └─────────────────────┘    │
│                             │              │                             │
│  ┌─────────────────────┐    │              │  ┌─────────────────────┐    │
│  │  BudgetProvider     │    │              │  │  Guest Groups       │    │
│  │                     │    │              │  │  Screen             │    │
│  └─────────────────────┘    │              │  └─────────────────────┘    │
│                             │              │                             │
│                             │              │  ┌─────────────────────┐    │
│                             │              │  │  GuestListProvider  │    │
│                             │              │  │                     │    │
│                             │              │  └─────────────────────┘    │
└─────────────────────────────┘              └─────────────────────────────┘

┌─────────────────────────────┐              ┌─────────────────────────────┐
│      TIMELINE TOOL          │              │      MESSAGING TOOL         │
│                             │              │                             │
│  ┌─────────────────────┐    │              │  ┌─────────────────────┐    │
│  │  Timeline Screen    │    │              │  │  Vendor List        │    │
│  │                     │────┼──┐           │  │  Screen             │────┼──┐
│  └─────────────────────┘    │  │           │  └─────────────────────┘    │  │
│                             │  │           │                             │  │
│  ┌─────────────────────┐    │  │           │  ┌─────────────────────┐    │  │
│  │  Checklist Screen   │◀───┼──┘           │  │  Conversation       │◀───┼──┘
│  │                     │    │              │  │  Screen             │    │
│  └─────────────────────┘    │              │  └─────────────────────┘    │
│                             │              │                             │
│  ┌─────────────────────┐    │              │  ┌─────────────────────┐    │
│  │  Task Form Screen   │    │              │  │  MessagingProvider  │    │
│  │                     │    │              │  │                     │    │
│  └─────────────────────┘    │              │  └─────────────────────┘    │
│                             │              │                             │
│  ┌─────────────────────┐    │              │                             │
│  │  TaskProvider       │    │              │                             │
│  │                     │    │              │                             │
│  └─────────────────────┘    │              │                             │
└─────────────────────────────┘              └─────────────────────────────┘
```

## Budget Tool Components

```
┌─────────────────────────────────────────────────────────────────────────┐
│                       BUDGET OVERVIEW SCREEN                            │
└───────────────────────────────────┬─────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                           BUDGET SUMMARY                                │
│                                                                         │
│  ┌─────────────────────────────────────────────────────────────────┐    │
│  │  Total Budget: $25,000                                          │    │
│  │  Spent: $15,000                                                 │    │
│  │  Remaining: $10,000                                             │    │
│  │                                                                 │    │
│  │  [Progress Bar: 60% of budget used]                             │    │
│  └─────────────────────────────────────────────────────────────────┘    │
└───────────────────────────────────┬─────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                           CATEGORY BREAKDOWN                            │
│                                                                         │
│  ┌─────────────────────────────────────────────────────────────────┐    │
│  │  Venue: $8,000 / $10,000                                        │    │
│  │  [Progress Bar: 80% of category budget used]                    │    │
│  └─────────────────────────────────────────────────────────────────┘    │
│                                                                         │
│  ┌─────────────────────────────────────────────────────────────────┐    │
│  │  Catering: $5,000 / $8,000                                      │    │
│  │  [Progress Bar: 62.5% of category budget used]                  │    │
│  └─────────────────────────────────────────────────────────────────┘    │
│                                                                         │
│  ┌─────────────────────────────────────────────────────────────────┐    │
│  │  Photography: $2,000 / $3,000                                   │    │
│  │  [Progress Bar: 66.7% of category budget used]                  │    │
│  └─────────────────────────────────────────────────────────────────┘    │
│                                                                         │
│  ┌─────────────────────────────────────────────────────────────────┐    │
│  │  Decorations: $0 / $2,000                                       │    │
│  │  [Progress Bar: 0% of category budget used]                     │    │
│  └─────────────────────────────────────────────────────────────────┘    │
└───────────────────────────────────┬─────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                           ACTION BUTTONS                                │
│                                                                         │
│  ┌─────────────────────────────────────────────────┐  ┌─────────────┐  │
│  │  View All Items                                 │  │  Add Item   │  │
│  │                                                 │  │             │  │
│  └─────────────────────────────────────────────────┘  └─────────────┘  │
└─────────────────────────────────────────────────────────────────────────┘
```

## Guest List Tool Components

```
┌─────────────────────────────────────────────────────────────────────────┐
│                       GUEST LIST SCREEN                                 │
└───────────────────────────────────┬─────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                           GUEST SUMMARY                                 │
│                                                                         │
│  ┌─────────────────────────────────────────────────────────────────┐    │
│  │  Total Guests: 150                                              │    │
│  │  Confirmed: 100                                                 │    │
│  │  Pending: 50                                                    │    │
│  │  Declined: 0                                                    │    │
│  └─────────────────────────────────────────────────────────────────┘    │
└───────────────────────────────────┬─────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                           SEARCH & FILTER                               │
│                                                                         │
│  ┌─────────────────────────────────────────────────┐  ┌─────────────┐  │
│  │  Search Guests                                  │  │  Filter     │  │
│  │                                                 │  │             │  │
│  └─────────────────────────────────────────────────┘  └─────────────┘  │
└───────────────────────────────────┬─────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                           GUEST LIST                                    │
│                                                                         │
│  ┌─────────────────────────────────────────────────────────────────┐    │
│  │  GUEST ITEM                                                     │    │
│  │                                                                 │    │
│  │  Name: John Smith                                              │    │
│  │  Status: Confirmed                                             │    │
│  │  Group: Family                                                 │    │
│  │  Meal Preference: Vegetarian                                   │    │
│  │                                                                 │    │
│  │  [View Details]                                                │    │
│  └─────────────────────────────────────────────────────────────────┘    │
│                                                                         │
│  ┌─────────────────────────────────────────────────────────────────┐    │
│  │  GUEST ITEM                                                     │    │
│  │                                                                 │    │
│  │  Name: Jane Doe                                                │    │
│  │  Status: Pending                                               │    │
│  │  Group: Friends                                                │    │
│  │  Meal Preference: None                                         │    │
│  │                                                                 │    │
│  │  [View Details]                                                │    │
│  └─────────────────────────────────────────────────────────────────┘    │
└───────────────────────────────────┬─────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                           ACTION BUTTONS                                │
│                                                                         │
│  ┌─────────────────────┐  ┌─────────────────────┐  ┌─────────────────┐ │
│  │  Add Guest          │  │  Manage Groups      │  │  Export List    │ │
│  │                     │  │                     │  │                 │ │
│  └─────────────────────┘  └─────────────────────┘  └─────────────────┘ │
└─────────────────────────────────────────────────────────────────────────┘
```

## Timeline Tool Components

```
┌─────────────────────────────────────────────────────────────────────────┐
│                       TIMELINE SCREEN                                   │
└───────────────────────────────────┬─────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                           VIEW TOGGLE                                   │
│                                                                         │
│  ┌─────────────────────────────────────────────────────────────────┐    │
│  │  [Timeline View]  |  Checklist View                             │    │
│  └─────────────────────────────────────────────────────────────────┘    │
└───────────────────────────────────┬─────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                           TIMELINE                                      │
│                                                                         │
│  ┌─────────────────────────────────────────────────────────────────┐    │
│  │  12 Months Before                                               │    │
│  │  ├── Book venue                                                 │    │
│  │  ├── Set budget                                                 │    │
│  │  └── Create guest list                                          │    │
│  └─────────────────────────────────────────────────────────────────┘    │
│                                                                         │
│  ┌─────────────────────────────────────────────────────────────────┐    │
│  │  9 Months Before                                                │    │
│  │  ├── Book caterer                                               │    │
│  │  ├── Book photographer                                          │    │
│  │  └── Send save-the-dates                                        │    │
│  └─────────────────────────────────────────────────────────────────┘    │
│                                                                         │
│  ┌─────────────────────────────────────────────────────────────────┐    │
│  │  6 Months Before                                                │    │
│  │  ├── Order invitations                                          │    │
│  │  ├── Book florist                                               │    │
│  │  └── Book entertainment                                         │    │
│  └─────────────────────────────────────────────────────────────────┘    │
│                                                                         │
│  ┌─────────────────────────────────────────────────────────────────┐    │
│  │  3 Months Before                                                │    │
│  │  ├── Send invitations                                           │    │
│  │  ├── Order cake                                                 │    │
│  │  └── Finalize menu                                              │    │
│  └─────────────────────────────────────────────────────────────────┘    │
└───────────────────────────────────┬─────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                           ACTION BUTTONS                                │
│                                                                         │
│  ┌─────────────────────────────────────────────────┐  ┌─────────────┐  │
│  │  Switch to Checklist                            │  │  Add Task   │  │
│  │                                                 │  │             │  │
│  └─────────────────────────────────────────────────┘  └─────────────┘  │
└─────────────────────────────────────────────────────────────────────────┘
```

## Messaging Tool Components

```
┌─────────────────────────────────────────────────────────────────────────┐
│                       VENDOR LIST SCREEN                                │
└───────────────────────────────────┬─────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                           VENDOR SEARCH                                 │
│                                                                         │
│  ┌─────────────────────────────────────────────────────────────────┐    │
│  │  Search Vendors                                                 │    │
│  └─────────────────────────────────────────────────────────────────┘    │
└───────────────────────────────────┬─────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                           VENDOR LIST                                   │
│                                                                         │
│  ┌─────────────────────────────────────────────────────────────────┐    │
│  │  VENDOR CARD                                                    │    │
│  │                                                                 │    │
│  │  ┌─────────────┐  ┌─────────────────────────────────────────┐  │    │
│  │  │  Vendor     │  │  Vendor Name                            │  │    │
│  │  │  Icon       │  │                                         │  │    │
│  │  │             │  │  Vendor Type: Venue                     │  │    │
│  │  │             │  │                                         │  │    │
│  │  │             │  │  Last Message: 2 days ago               │  │    │
│  │  │             │  │                                         │  │    │
│  │  │             │  │  Unread Messages: 1                     │  │    │
│  │  └─────────────┘  └─────────────────────────────────────────┘  │    │
│  │                                                                 │    │
│  └─────────────────────────────────────────────────────────────────┘    │
│                                                                         │
│  ┌─────────────────────────────────────────────────────────────────┐    │
│  │  VENDOR CARD                                                    │    │
│  │                                                                 │    │
│  │  ┌─────────────┐  ┌─────────────────────────────────────────┐  │    │
│  │  │  Vendor     │  │  Vendor Name                            │  │    │
│  │  │  Icon       │  │                                         │  │    │
│  │  │             │  │  Vendor Type: Catering                  │  │    │
│  │  │             │  │                                         │  │    │
│  │  │             │  │  Last Message: 1 week ago               │  │    │
│  │  │             │  │                                         │  │    │
│  │  │             │  │  Unread Messages: 0                     │  │    │
│  │  └─────────────┘  └─────────────────────────────────────────┘  │    │
│  │                                                                 │    │
│  └─────────────────────────────────────────────────────────────────┘    │
└───────────────────────────────────┬─────────────────────────────────────┘
                                    │
                                    │ User taps on a vendor card
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                       CONVERSATION SCREEN                               │
└───────────────────────────────────┬─────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                           CONVERSATION HEADER                           │
│                                                                         │
│  ┌─────────────┐  ┌─────────────────────────────────┐  ┌─────────────┐  │
│  │  Back       │  │  Vendor Name                    │  │  Info       │  │
│  │  Button     │  │  Vendor Type                    │  │  Button     │  │
│  └─────────────┘  └─────────────────────────────────┘  └─────────────┘  │
└───────────────────────────────────┬─────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                           MESSAGE LIST                                  │
│                                                                         │
│  ┌─────────────────────────────────────────────────────────────────┐    │
│  │  DATE SEPARATOR                                                 │    │
│  │  May 1, 2023                                                    │    │
│  └─────────────────────────────────────────────────────────────────┘    │
│                                                                         │
│  ┌─────────────────────────────────────────────────────────────────┐    │
│  │  VENDOR MESSAGE                                                 │    │
│  │  Hello! Thank you for your interest in our venue.               │    │
│  │  10:30 AM                                                       │    │
│  └─────────────────────────────────────────────────────────────────┘    │
│                                                                         │
│  ┌─────────────────────────────────────────────────────────────────┐    │
│  │  USER MESSAGE                                                   │    │
│  │  Hi! I'd like to know about availability for May 15th next year.│    │
│  │  11:45 AM                                                       │    │
│  └─────────────────────────────────────────────────────────────────┘    │
│                                                                         │
│  ┌─────────────────────────────────────────────────────────────────┐    │
│  │  DATE SEPARATOR                                                 │    │
│  │  Today                                                          │    │
│  └─────────────────────────────────────────────────────────────────┘    │
│                                                                         │
│  ┌─────────────────────────────────────────────────────────────────┐    │
│  │  VENDOR MESSAGE                                                 │    │
│  │  Yes, we have availability on that date. Would you like to      │    │
│  │  schedule a tour?                                               │    │
│  │  9:15 AM                                                        │    │
│  └─────────────────────────────────────────────────────────────────┘    │
└───────────────────────────────────┬─────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                           MESSAGE INPUT                                 │
│                                                                         │
│  ┌─────────────────────────────────────────────────┐  ┌─────────────┐  │
│  │  Type a message...                              │  │  Send       │  │
│  │                                                 │  │             │  │
│  └─────────────────────────────────────────────────┘  └─────────────┘  │
└─────────────────────────────────────────────────────────────────────────┘
```

## Integration with Other Features

### Integration with Event Wizard

- **Budget Tool**: Initial budget created based on event type and guest count from wizard
- **Guest List Tool**: Initial guest count set from wizard
- **Timeline Tool**: Task templates selected based on event type from wizard
- **Messaging Tool**: Initial vendor contacts added based on services selected in wizard

### Integration with Services

- **Budget Tool**: Service bookings automatically added to budget
- **Timeline Tool**: Service-related tasks added to timeline
- **Messaging Tool**: Communication channel opened with booked service providers

### Integration with Booking System

- **Budget Tool**: Booked services automatically added to budget
- **Timeline Tool**: Service-related tasks added to timeline/checklist
- **Messaging Tool**: Communication channel opened with booked service providers

## Data Models

### Budget Item Model

```
BudgetItem {
  id: string,
  eventId: string,
  category: string,  // "venue", "catering", "photography", etc.
  name: string,
  estimatedCost: double,
  actualCost: double,
  paid: double,
  dueDate: DateTime,
  notes: string,
  isBooked: bool,  // Whether this item is linked to a booking
  bookingId: string,  // Reference to a booking if applicable
}
```

### Guest Model

```
Guest {
  id: string,
  eventId: string,
  name: string,
  email: string,
  phone: string,
  address: string,
  groupId: string,  // Reference to a guest group
  status: string,  // "invited", "confirmed", "declined", "pending"
  rsvpDate: DateTime,
  mealPreference: string,
  plusOneAllowed: bool,
  plusOneName: string,
  notes: string,
}
```

### Task Model

```
Task {
  id: string,
  eventId: string,
  title: string,
  description: string,
  dueDate: DateTime,
  category: string,
  priority: string,  // "high", "medium", "low"
  status: string,  // "not_started", "in_progress", "completed"
  completedDate: DateTime,
  assignedTo: string,
  notes: string,
  isServiceRelated: bool,  // Whether this task is related to a service
  serviceId: string,  // Reference to a service if applicable
}
```

### Vendor Message Model

```
VendorMessage {
  id: string,
  eventId: string,
  vendorId: string,
  senderId: string,
  senderType: string,  // "user" or "vendor"
  content: string,
  timestamp: DateTime,
  isRead: bool,
  attachments: List<string>,  // References to attachments
}
```
