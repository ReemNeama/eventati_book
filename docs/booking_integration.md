# Eventati Book Booking Integration

This document provides a visual representation of how the booking system integrates with services in the Eventati Book application.

## Booking System Overview

```
┌─────────────────────────────────────────────────────────────────────────┐
│                           BOOKING SYSTEM                                │
└───────────────────────────────────┬─────────────────────────────────────┘
                                    │
                ┌───────────────────┼───────────────────┐
                │                   │                   │
                ▼                   ▼                   ▼
┌───────────────────────┐ ┌───────────────────┐ ┌───────────────────────┐
│   SERVICE DETAILS     │ │   BOOKING FORM    │ │   BOOKING HISTORY     │
│                       │ │                   │ │                        │
│  User views service   │ │  User selects     │ │  User views all       │
│  details and decides  │ │  options, date,   │ │  current and past     │
│  to book              │ │  time, and books  │ │  bookings             │
│                       │ │                   │ │                        │
└──────────┬────────────┘ └────────┬──────────┘ └────────────┬───────────┘
           │                       │                         │
           │                       │                         │
           ▼                       ▼                         ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                           BOOKING PROVIDER                              │
│                                                                         │
│  Manages booking state, communicates with services, and stores bookings │
└───────────────────────────────────┬─────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                           BOOKING MODEL                                 │
│                                                                         │
│  Represents booking data structure with all necessary information       │
└───────────────────────────────────┬─────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                           TEMPDB / FIREBASE                             │
│                                                                         │
│  Stores booking data (currently in TempDB, will be Firebase in future)  │
└─────────────────────────────────────────────────────────────────────────┘
```

## Booking Flow

```
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│                 │     │                 │     │                 │
│  Service Detail │────▶│  Booking Form   │────▶│ Booking         │
│  Screen         │     │  Screen         │     │ Confirmation    │
│                 │     │                 │     │                 │
└─────────────────┘     └─────────────────┘     └─────────────────┘
                                                        │
                                                        │
                                                        ▼
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│                 │     │                 │     │                 │
│  Booking        │◀────│  Booking        │◀────│ Booking Details │
│  History Screen │     │  Provider       │     │ Screen          │
│                 │     │                 │     │                 │
└─────────────────┘     └─────────────────┘     └─────────────────┘
```

## Service Details to Booking Form

```
┌─────────────────────────────────────────────────────────────────────────┐
│                       SERVICE DETAILS SCREEN                            │
└───────────────────────────────────┬─────────────────────────────────────┘
                                    │
                                    │ User clicks "Book Now" button
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                           BOOKING FORM SCREEN                           │
│                                                                         │
│  ┌─────────────────────────────────────────────────────────────────┐    │
│  │  Selected Service Information                                   │    │
│  │  - Service Name                                                 │    │
│  │  - Package Selected (if applicable)                             │    │
│  │  - Base Price                                                   │    │
│  └─────────────────────────────────────────────────────────────────┘    │
│                                                                         │
│  ┌─────────────────────────────────────────────────────────────────┐    │
│  │  Date & Time Selection                                          │    │
│  │  - Calendar for date selection                                  │    │
│  │  - Time slots available for selected date                       │    │
│  └─────────────────────────────────────────────────────────────────┘    │
│                                                                         │
│  ┌─────────────────────────────────────────────────────────────────┐    │
│  │  Additional Options                                             │    │
│  │  - Service-specific options (varies by service type)            │    │
│  │  - Each option may affect the total price                       │    │
│  └─────────────────────────────────────────────────────────────────┘    │
│                                                                         │
│  ┌─────────────────────────────────────────────────────────────────┐    │
│  │  Contact Information                                            │    │
│  │  - Name                                                         │    │
│  │  - Email                                                        │    │
│  │  - Phone                                                        │    │
│  └─────────────────────────────────────────────────────────────────┘    │
│                                                                         │
│  ┌─────────────────────────────────────────────────────────────────┐    │
│  │  Special Requests                                               │    │
│  │  - Text area for any special requests or notes                  │    │
│  └─────────────────────────────────────────────────────────────────┘    │
│                                                                         │
│  ┌─────────────────────────────────────────────────────────────────┐    │
│  │  Price Summary                                                  │    │
│  │  - Base price                                                   │    │
│  │  - Additional options                                           │    │
│  │  - Total price                                                  │    │
│  └─────────────────────────────────────────────────────────────────┘    │
│                                                                         │
│  ┌─────────────────────────────────────────────────┐  ┌─────────────┐  │
│  │  Cancel                                         │  │  Book Now   │  │
│  │                                                 │  │             │  │
│  └─────────────────────────────────────────────────┘  └─────────────┘  │
└───────────────────────────────────┬─────────────────────────────────────┘
                                    │
                                    │ User clicks "Book Now" button
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                       BOOKING CONFIRMATION SCREEN                       │
│                                                                         │
│  ┌─────────────────────────────────────────────────────────────────┐    │
│  │  Confirmation Message                                           │    │
│  │  - Success message                                              │    │
│  │  - Booking reference number                                     │    │
│  └─────────────────────────────────────────────────────────────────┘    │
│                                                                         │
│  ┌─────────────────────────────────────────────────────────────────┐    │
│  │  Booking Details                                                │    │
│  │  - Service booked                                               │    │
│  │  - Date and time                                                │    │
│  │  - Selected options                                             │    │
│  │  - Total price                                                  │    │
│  └─────────────────────────────────────────────────────────────────┘    │
│                                                                         │
│  ┌─────────────────────────────────────────────────┐  ┌─────────────┐  │
│  │  View All Bookings                              │  │  Done       │  │
│  │                                                 │  │             │  │
│  └─────────────────────────────────────────────────┘  └─────────────┘  │
└─────────────────────────────────────────────────────────────────────────┘
```

## Booking History and Details

```
┌─────────────────────────────────────────────────────────────────────────┐
│                       BOOKING HISTORY SCREEN                            │
└───────────────────────────────────┬─────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                           BOOKING FILTERS                               │
│                                                                         │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐    │
│  │  All        │  │  Upcoming   │  │  Past       │  │  Canceled   │    │
│  │  Bookings   │  │  Bookings   │  │  Bookings   │  │  Bookings   │    │
│  └─────────────┘  └─────────────┘  └─────────────┘  └─────────────┘    │
└───────────────────────────────────┬─────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                           BOOKING CARDS LIST                            │
│                                                                         │
│  ┌─────────────────────────────────────────────────────────────────┐    │
│  │  BOOKING CARD                                                   │    │
│  │                                                                 │    │
│  │  ┌─────────────┐  ┌─────────────────────────────────────────┐  │    │
│  │  │  Service    │  │  Service Name                           │  │    │
│  │  │  Icon       │  │                                         │  │    │
│  │  │             │  │  Date: May 15, 2023                     │  │    │
│  │  │             │  │  Time: 2:00 PM                          │  │    │
│  │  │             │  │                                         │  │    │
│  │  │             │  │  Status: Confirmed                      │  │    │
│  │  │             │  │                                         │  │    │
│  │  │             │  │  Reference: #B12345                     │  │    │
│  │  └─────────────┘  └─────────────────────────────────────────┘  │    │
│  │                                                                 │    │
│  │  ┌─────────────────────┐  ┌─────────────────────────────────┐  │    │
│  │  │  Cancel Booking     │  │  View Details                   │  │    │
│  │  └─────────────────────┘  └─────────────────────────────────┘  │    │
│  └─────────────────────────────────────────────────────────────────┘    │
│                                                                         │
│  ┌─────────────────────────────────────────────────────────────────┐    │
│  │  BOOKING CARD                                                   │    │
│  └─────────────────────────────────────────────────────────────────┘    │
│                                                                         │
│  ┌─────────────────────────────────────────────────────────────────┐    │
│  │  BOOKING CARD                                                   │    │
│  └─────────────────────────────────────────────────────────────────┘    │
└───────────────────────────────────┬─────────────────────────────────────┘
                                    │
                                    │ User clicks "View Details" button
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                       BOOKING DETAILS SCREEN                            │
│                                                                         │
│  ┌─────────────────────────────────────────────────────────────────┐    │
│  │  Booking Information                                            │    │
│  │  - Booking reference number                                     │    │
│  │  - Status (Confirmed, Pending, Canceled)                        │    │
│  │  - Date booked                                                  │    │
│  └─────────────────────────────────────────────────────────────────┘    │
│                                                                         │
│  ┌─────────────────────────────────────────────────────────────────┐    │
│  │  Service Information                                            │    │
│  │  - Service name                                                 │    │
│  │  - Service type                                                 │    │
│  │  - Package selected                                             │    │
│  │  - Date and time of service                                     │    │
│  └─────────────────────────────────────────────────────────────────┘    │
│                                                                         │
│  ┌─────────────────────────────────────────────────────────────────┐    │
│  │  Selected Options                                               │    │
│  │  - List of additional options selected                          │    │
│  │  - Special requests                                             │    │
│  └─────────────────────────────────────────────────────────────────┘    │
│                                                                         │
│  ┌─────────────────────────────────────────────────────────────────┐    │
│  │  Price Breakdown                                                │    │
│  │  - Base price                                                   │    │
│  │  - Additional options                                           │    │
│  │  - Total price                                                  │    │
│  └─────────────────────────────────────────────────────────────────┘    │
│                                                                         │
│  ┌─────────────────────────────────────────────────┐  ┌─────────────┐  │
│  │  Cancel Booking                                 │  │  Back       │  │
│  │                                                 │  │             │  │
│  └─────────────────────────────────────────────────┘  └─────────────┘  │
└─────────────────────────────────────────────────────────────────────────┘
```

## Service-Specific Booking Options

### Venue Booking Options

- **Date and Time**: Event date and time range
- **Guest Count**: Expected number of guests
- **Setup Options**: Room layout, seating arrangements
- **Additional Services**: 
  - A/V equipment
  - Decoration packages
  - Catering options (if provided by venue)
  - Parking arrangements

### Catering Booking Options

- **Date and Time**: Service date and time
- **Guest Count**: Number of guests to serve
- **Menu Selection**: 
  - Package selection (Bronze, Silver, Gold)
  - Specific dishes from menu
  - Dietary restrictions
- **Service Style**: Buffet, plated, family-style, etc.
- **Staff Options**: Number of servers, bartenders, etc.
- **Equipment**: Tables, chairs, linens, tableware

### Photography Booking Options

- **Date and Time**: Service date and time range
- **Package Selection**: Basic, Standard, Premium
- **Team Size**: Single photographer or team
- **Coverage Options**:
  - Hours of coverage
  - Locations to cover
  - Specific shots requested
- **Delivery Options**: Digital, prints, albums, etc.

### Planner Booking Options

- **Package Selection**: Day-of coordination, partial planning, full planning
- **Timeline**: Event date and planning start date
- **Services Needed**:
  - Vendor coordination
  - Budget management
  - Design and decor
  - Guest management
  - Timeline creation

## Booking Data Model

```
Booking {
  id: string,
  userId: string,
  serviceId: string,
  serviceType: string,  // "venue", "catering", "photography", "planner"
  packageId: string,    // If a specific package was selected
  dateTime: DateTime,
  status: string,       // "confirmed", "pending", "canceled", "completed"
  totalPrice: double,
  createdAt: DateTime,
  updatedAt: DateTime,
  
  // Contact information
  contactName: string,
  contactEmail: string,
  contactPhone: string,
  
  // Service-specific options (stored as JSON)
  options: {
    // Varies by service type
    // Examples:
    guestCount: int,
    setupOption: string,
    menuSelections: List<string>,
    staffCount: int,
    hoursOfCoverage: int,
    // etc.
  },
  
  // Special requests
  specialRequests: string,
  
  // Price breakdown
  priceBreakdown: {
    basePrice: double,
    additionalOptions: List<{name: string, price: double}>,
    discounts: List<{name: string, amount: double}>,
  }
}
```

## Integration with Planning Tools

- **Budget Tool**: Booked services automatically added to budget
- **Timeline**: Service-related tasks added to timeline/checklist
- **Vendor Messaging**: Communication channel opened with booked service providers
- **Guest List**: Venue capacity linked to guest list management
