/// Arguments for the booking form screen
class BookingFormArguments {
  /// Service ID for the booking
  final String serviceId;

  /// Service type (venue, catering, photography, etc.)
  final String serviceType;

  /// Service name
  final String serviceName;

  /// Base price per hour
  final double basePrice;

  /// Existing booking ID (for editing)
  final String? bookingId;

  /// Event ID (optional)
  final String? eventId;

  /// Event name (optional)
  final String? eventName;

  /// Constructor
  const BookingFormArguments({
    required this.serviceId,
    required this.serviceType,
    required this.serviceName,
    required this.basePrice,
    this.bookingId,
    this.eventId,
    this.eventName,
  });
}
