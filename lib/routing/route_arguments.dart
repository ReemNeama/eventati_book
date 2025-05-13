/// Base class for route arguments
class RouteArguments {
  final dynamic data;

  const RouteArguments({this.data});
}

/// Arguments for verification screen
class VerificationArguments extends RouteArguments {
  final String email;

  const VerificationArguments({required this.email}) : super();
}

/// Arguments for reset password screen
class ResetPasswordArguments extends RouteArguments {
  /// The out-of-band code from the password reset link
  final String oobCode;

  const ResetPasswordArguments({required this.oobCode}) : super();
}

/// Arguments for main navigation screen
class MainNavigationArguments extends RouteArguments {
  final Function toggleTheme;

  const MainNavigationArguments({required this.toggleTheme}) : super();
}

/// Arguments for booking details screen
class BookingDetailsArguments extends RouteArguments {
  final String bookingId;

  const BookingDetailsArguments({required this.bookingId}) : super();
}

/// Arguments for booking form screen
class BookingFormArguments extends RouteArguments {
  final String serviceId;
  final String serviceType;
  final String serviceName;
  final double basePrice;
  final String? bookingId;
  final String? eventId;
  final String? eventName;

  const BookingFormArguments({
    required this.serviceId,
    required this.serviceType,
    required this.serviceName,
    required this.basePrice,
    this.bookingId,
    this.eventId,
    this.eventName,
  }) : super();
}

/// Arguments for venue details screen
class VenueDetailsArguments extends RouteArguments {
  final String venueId;

  const VenueDetailsArguments({required this.venueId}) : super();
}

/// Arguments for catering details screen
class CateringDetailsArguments extends RouteArguments {
  final String cateringId;

  const CateringDetailsArguments({required this.cateringId}) : super();
}

/// Arguments for photographer details screen
class PhotographerDetailsArguments extends RouteArguments {
  final String photographerId;

  const PhotographerDetailsArguments({required this.photographerId}) : super();
}

/// Arguments for planner details screen
class PlannerDetailsArguments extends RouteArguments {
  final String plannerId;

  const PlannerDetailsArguments({required this.plannerId}) : super();
}

/// Arguments for service comparison screen
class ServiceComparisonArguments extends RouteArguments {
  final String serviceType;

  const ServiceComparisonArguments({required this.serviceType}) : super();
}

/// Arguments for saved comparisons screen
class SavedComparisonsArguments extends RouteArguments {
  const SavedComparisonsArguments() : super();
}

/// Arguments for event planning tools screen
class EventPlanningArguments extends RouteArguments {
  final String eventId;
  final String eventName;
  final String eventType;
  final DateTime eventDate;

  const EventPlanningArguments({
    required this.eventId,
    required this.eventName,
    required this.eventType,
    required this.eventDate,
  }) : super();
}

/// Arguments for budget screen
class BudgetArguments extends RouteArguments {
  final String eventId;
  final String eventName;

  const BudgetArguments({required this.eventId, required this.eventName})
    : super();
}

/// Arguments for guest list screen
class GuestListArguments extends RouteArguments {
  final String eventId;
  final String eventName;

  const GuestListArguments({required this.eventId, required this.eventName})
    : super();
}

/// Arguments for timeline screen
class TimelineArguments extends RouteArguments {
  final String eventId;
  final String eventName;

  const TimelineArguments({required this.eventId, required this.eventName})
    : super();
}

/// Arguments for task dependency screen
class TaskDependencyArguments extends RouteArguments {
  final String eventId;
  final String eventName;
  final String? focusedTaskId;

  const TaskDependencyArguments({
    required this.eventId,
    required this.eventName,
    this.focusedTaskId,
  }) : super();
}

/// Arguments for vendor communication screen
class VendorCommunicationArguments extends RouteArguments {
  final String eventId;
  final String eventName;

  const VendorCommunicationArguments({
    required this.eventId,
    required this.eventName,
  }) : super();
}

/// Arguments for event details screen
class EventDetailsArguments extends RouteArguments {
  final String eventId;

  const EventDetailsArguments({required this.eventId}) : super();
}

/// Arguments for task database test screen
class TaskDatabaseTestArguments extends RouteArguments {
  final String eventId;

  const TaskDatabaseTestArguments({required this.eventId}) : super();
}

/// Arguments for task templates screen
class TaskTemplatesArguments extends RouteArguments {
  final String? eventId;
  final String? eventType;

  const TaskTemplatesArguments({this.eventId, this.eventType}) : super();
}

/// Arguments for task template form screen
class TaskTemplateFormArguments extends RouteArguments {
  final String? templateId;
  final String? eventId;
  final String? eventType;

  const TaskTemplateFormArguments({
    this.templateId,
    this.eventId,
    this.eventType,
  }) : super();
}
