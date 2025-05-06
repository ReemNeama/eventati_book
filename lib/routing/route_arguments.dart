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
  const ResetPasswordArguments() : super();
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
