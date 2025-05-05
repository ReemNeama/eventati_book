# Eventati Book Booking System

This document provides a comprehensive overview of the booking system in the Eventati Book application, including its architecture, components, data flow, and integration with other features.

## Booking System Overview

The booking system allows users to book various services for their events, including venues, catering services, photographers, and event planners. It provides a seamless flow from service selection to booking confirmation, with features for managing, editing, and canceling bookings.

## Booking Flow Diagram

```
┌─────────────────────────────────────────────────────────────────────────┐
│                       SERVICE DETAILS SCREEN                             │
└───────────────────────────────────┬─────────────────────────────────────┘
                                    │
                                    │ User taps "Book Now"
                                    ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                       BOOKING FORM SCREEN                                │
│                                                                         │
│  ┌─────────────────────────────────────────────────────────────────┐    │
│  │  Service Information                                             │    │
│  │  - Service Name                                                  │    │
│  │  - Service Type                                                  │    │
│  │  - Base Price                                                    │    │
│  └─────────────────────────────────────────────────────────────────┘    │
│                                                                         │
│  ┌─────────────────────────────────────────────────────────────────┐    │
│  │  Date and Time Selection                                         │    │
│  │  - Date Picker                                                   │    │
│  │  - Time Picker                                                   │    │
│  │  - Duration Selection                                            │    │
│  └─────────────────────────────────────────────────────────────────┘    │
│                                                                         │
│  ┌─────────────────────────────────────────────────────────────────┐    │
│  │  Guest Information                                               │    │
│  │  - Guest Count                                                   │    │
│  │  - Event Association (optional)                                  │    │
│  └─────────────────────────────────────────────────────────────────┘    │
│                                                                         │
│  ┌─────────────────────────────────────────────────────────────────┐    │
│  │  Service-Specific Options                                        │    │
│  │  - Venue: Layout, Equipment                                      │    │
│  │  - Catering: Menu Selection, Dietary Requirements                │    │
│  │  - Photography: Package Selection, Shot List                     │    │
│  │  - Planner: Package Selection, Planning Areas                    │    │
│  └─────────────────────────────────────────────────────────────────┘    │
│                                                                         │
│  ┌─────────────────────────────────────────────────────────────────┐    │
│  │  Contact Information                                             │    │
│  │  - Name                                                          │    │
│  │  - Email                                                         │    │
│  │  - Phone                                                         │    │
│  └─────────────────────────────────────────────────────────────────┘    │
│                                                                         │
│  ┌─────────────────────────────────────────────────────────────────┐    │
│  │  Special Requests                                                │    │
│  │  - Text Area for Additional Requirements                         │    │
│  └─────────────────────────────────────────────────────────────────┘    │
│                                                                         │
│  ┌─────────────────────────────────────────────────────────────────┐    │
│  │  Price Summary                                                   │    │
│  │  - Base Price                                                    │    │
│  │  - Additional Options                                            │    │
│  │  - Total Price                                                   │    │
│  └─────────────────────────────────────────────────────────────────┘    │
│                                                                         │
│  ┌─────────────────────────────────────────────────────────────────┐    │
│  │  Submit Button                                                   │    │
│  └─────────────────────────────────────────────────────────────────┘    │
└───────────────────────────────────┬─────────────────────────────────────┘
                                    │
                                    │ User submits booking
                                    ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                       BOOKING CONFIRMATION                              │
└───────────────────────────────────┬─────────────────────────────────────┘
                                    │
                                    │ User views bookings
                                    ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                       BOOKING HISTORY SCREEN                            │
│                                                                         │
│  ┌─────────────────────────────────────────────────────────────────┐    │
│  │  Tabs                                                            │    │
│  │  - Upcoming Bookings                                             │    │
│  │  - Past Bookings                                                 │    │
│  └─────────────────────────────────────────────────────────────────┘    │
│                                                                         │
│  ┌─────────────────────────────────────────────────────────────────┐    │
│  │  Booking Cards                                                   │    │
│  │  - Service Name                                                  │    │
│  │  - Service Type                                                  │    │
│  │  - Date and Time                                                 │    │
│  │  - Status                                                        │    │
│  │  - Price                                                         │    │
│  └─────────────────────────────────────────────────────────────────┘    │
└───────────────────────────────────┬─────────────────────────────────────┘
                                    │
                                    │ User taps on a booking
                                    ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                       BOOKING DETAILS SCREEN                            │
│                                                                         │
│  ┌─────────────────────────────────────────────────────────────────┐    │
│  │  Booking Status                                                  │    │
│  │  - Status Badge (Pending, Confirmed, Completed, Cancelled)       │    │
│  │  - Booking ID                                                    │    │
│  │  - Created/Updated Timestamps                                    │    │
│  └─────────────────────────────────────────────────────────────────┘    │
│                                                                         │
│  ┌─────────────────────────────────────────────────────────────────┐    │
│  │  Service Details                                                 │    │
│  │  - Service Name                                                  │    │
│  │  - Service Type                                                  │    │
│  │  - Event Association (if applicable)                             │    │
│  └─────────────────────────────────────────────────────────────────┘    │
│                                                                         │
│  ┌─────────────────────────────────────────────────────────────────┐    │
│  │  Service-Specific Options                                        │    │
│  │  - Selected Options                                              │    │
│  └─────────────────────────────────────────────────────────────────┘    │
│                                                                         │
│  ┌─────────────────────────────────────────────────────────────────┐    │
│  │  Booking Details                                                 │    │
│  │  - Date and Time                                                 │    │
│  │  - Duration                                                      │    │
│  │  - Guest Count                                                   │    │
│  │  - Special Requests                                              │    │
│  └─────────────────────────────────────────────────────────────────┘    │
│                                                                         │
│  ┌─────────────────────────────────────────────────────────────────┐    │
│  │  Contact Information                                             │    │
│  │  - Name                                                          │    │
│  │  - Email                                                         │    │
│  │  - Phone                                                         │    │
│  └─────────────────────────────────────────────────────────────────┘    │
│                                                                         │
│  ┌─────────────────────────────────────────────────────────────────┐    │
│  │  Price Summary                                                   │    │
│  │  - Total Price                                                   │    │
│  └─────────────────────────────────────────────────────────────────┘    │
│                                                                         │
│  ┌─────────────────────────────────────────────────────────────────┐    │
│  │  Action Buttons                                                  │    │
│  │  - Edit (if status is Pending or Confirmed)                      │    │
│  │  - Cancel (if status is Pending or Confirmed)                    │    │
│  └─────────────────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────────────────┘
```

## Booking System Components

### Screens

1. **BookingFormScreen**
   - Purpose: Create or edit a booking
   - Key Features:
     - Service information display
     - Date and time selection with availability checking
     - Guest count and duration selection
     - Service-specific options selection
     - Contact information input
     - Special requests input
     - Dynamic price calculation
     - Form validation

2. **BookingDetailsScreen**
   - Purpose: Display detailed information about a booking
   - Key Features:
     - Booking status display
     - Service details
     - Booking details (date, time, duration, guests)
     - Service-specific options display
     - Contact information
     - Price summary
     - Actions (edit, cancel) based on booking status

3. **BookingHistoryScreen**
   - Purpose: Display a list of all user bookings
   - Key Features:
     - Tab navigation between upcoming and past bookings
     - Booking cards with summary information
     - Status indicators
     - Navigation to booking details

### Models

1. **Booking**
   - Core data model for booking information
   - Properties:
     - id: Unique identifier
     - userId: User who made the booking
     - serviceId: Service being booked
     - serviceType: Type of service (venue, catering, etc.)
     - serviceName: Name of the service
     - bookingDateTime: Date and time of the booking
     - duration: Duration in hours
     - guestCount: Number of guests
     - specialRequests: Additional requirements
     - status: Current booking status (pending, confirmed, completed, cancelled)
     - totalPrice: Total price of the booking
     - createdAt: Creation timestamp
     - updatedAt: Last update timestamp
     - contactName: Contact person name
     - contactEmail: Contact email
     - contactPhone: Contact phone number
     - eventId: Associated event (optional)
     - eventName: Associated event name (optional)
     - serviceOptions: Service-specific options

2. **BookingStatus**
   - Enum representing different booking statuses
   - Values:
     - pending: Initial status when booking is created
     - confirmed: Booking has been confirmed by the service provider
     - completed: Service has been delivered
     - cancelled: Booking has been cancelled

### Providers

1. **BookingProvider**
   - Purpose: Manage booking data and operations
   - Key Responsibilities:
     - Create, read, update, and delete bookings
     - Filter bookings by status (upcoming, past)
     - Check service availability
     - Handle booking status changes
     - Manage booking errors
     - Notify listeners of changes

## Integration with Other Features

### Integration with Event Planning

- Bookings can be associated with events
- Event details (name, ID) are stored with the booking
- Bookings appear in event timelines
- Booking costs are reflected in event budgets

### Integration with Services

- Service details are used to populate booking information
- Service availability is checked before confirming bookings
- Service-specific options are dynamically loaded based on service type
- Service pricing is used for booking cost calculation

### Integration with User Management

- User information is used to pre-fill contact details
- User ID is associated with bookings for access control
- User can view their booking history

## Data Models

### Booking Model

```dart
class Booking {
  final String id;
  final String userId;
  final String serviceId;
  final String serviceType;
  final String serviceName;
  final DateTime bookingDateTime;
  final double duration;
  final int guestCount;
  final String specialRequests;
  final BookingStatus status;
  final double totalPrice;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String contactName;
  final String contactEmail;
  final String contactPhone;
  final String? eventId;
  final String? eventName;
  final Map<String, dynamic> serviceOptions;

  // Constructor, copyWith, and other methods...
}
```

### BookingStatus Enum

```dart
enum BookingStatus {
  pending,
  confirmed,
  completed,
  cancelled;

  // Properties for display name, color, and icon
  String get displayName { ... }
  Color get color { ... }
  IconData get icon { ... }
}
```

## Key Functionality

### Availability Checking

The booking system checks if a service is available at the requested date and time before allowing a booking to be created. This prevents double-booking and ensures that services are only booked when they are available.

```dart
Future<bool> isServiceAvailable(
  String serviceId,
  DateTime dateTime,
  double duration,
) async {
  // Check if the service is available at the specified date and time
  // Return true if available, false otherwise
}
```

### Dynamic Price Calculation

The booking system calculates the total price based on multiple factors:
- Base price of the service
- Duration of the booking
- Number of guests
- Selected service options

```dart
void _calculateTotalPrice() {
  // Base calculation: basePrice * duration
  double price = widget.basePrice * _duration;

  // Add guest count factor (example: 10% extra for each 50 guests over 50)
  if (_guestCount > 50) {
    final extraGuestGroups = (_guestCount - 50) / 50;
    price += price * 0.1 * extraGuestGroups.ceil();
  }

  // Add service-specific options pricing
  // ...

  setState(() {
    _totalPrice = price;
  });
}
```

### Service-Specific Options

The booking system dynamically loads different options based on the service type:
- **Venues**: Layout options, equipment needs, room selection
- **Catering**: Menu selection, dietary requirements, service style
- **Photography**: Package selection, shot list, additional services
- **Planners**: Package selection, planning areas, consultation options

These options are stored in the `serviceOptions` map in the Booking model and are rendered differently based on the service type.

### Booking Status Management

Bookings go through different statuses in their lifecycle:
1. **Pending**: Initial status when a booking is created
2. **Confirmed**: When the service provider accepts the booking
3. **Completed**: After the service has been delivered
4. **Cancelled**: If the booking is cancelled by either party

The UI adapts based on the booking status, showing different actions and information.

### Error Handling

The booking system includes comprehensive error handling:
- Validation errors for form inputs
- Availability conflicts
- Network errors
- Permission errors

Errors are displayed to the user with clear messages and, where appropriate, suggestions for resolution.

## Security Considerations

- Bookings are associated with user IDs for access control
- Only the booking owner can view, edit, or cancel their bookings
- Service providers can only confirm or reject bookings for their services
- Sensitive information is handled securely

## Future Enhancements

Planned enhancements for the booking system include:
- Payment integration for deposits and full payments
- Recurring bookings for regular events
- Booking templates for quick rebooking
- Calendar integration for exporting bookings
- Notification system for booking status changes
- Rating and review system for completed bookings
