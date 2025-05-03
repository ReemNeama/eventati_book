import 'package:flutter/material.dart';
import 'package:eventati_book/models/service_options/service_options.dart';

/// Enum representing the status of a booking
enum BookingStatus { pending, confirmed, cancelled, completed, noShow }

/// Extension to add helper methods to BookingStatus
extension BookingStatusExtension on BookingStatus {
  /// Get the display name of the booking status
  String get displayName {
    switch (this) {
      case BookingStatus.pending:
        return 'Pending';
      case BookingStatus.confirmed:
        return 'Confirmed';
      case BookingStatus.cancelled:
        return 'Cancelled';
      case BookingStatus.completed:
        return 'Completed';
      case BookingStatus.noShow:
        return 'No Show';
    }
  }

  /// Get the color associated with the booking status
  Color get color {
    switch (this) {
      case BookingStatus.pending:
        return Colors.orange;
      case BookingStatus.confirmed:
        return Colors.green;
      case BookingStatus.cancelled:
        return Colors.red;
      case BookingStatus.completed:
        return Colors.blue;
      case BookingStatus.noShow:
        return Colors.grey;
    }
  }

  /// Get the icon associated with the booking status
  IconData get icon {
    switch (this) {
      case BookingStatus.pending:
        return Icons.hourglass_empty;
      case BookingStatus.confirmed:
        return Icons.check_circle;
      case BookingStatus.cancelled:
        return Icons.cancel;
      case BookingStatus.completed:
        return Icons.done_all;
      case BookingStatus.noShow:
        return Icons.person_off;
    }
  }
}

/// Model representing a booking
class Booking {
  /// Unique identifier for the booking
  final String id;

  /// ID of the user who made the booking
  final String userId;

  /// ID of the service being booked
  final String serviceId;

  /// Type of service (venue, catering, photography, etc.)
  final String serviceType;

  /// Name of the service
  final String serviceName;

  /// Date and time of the booking
  final DateTime bookingDateTime;

  /// Duration of the booking in hours
  final double duration;

  /// Number of guests for the booking
  final int guestCount;

  /// Special requests or notes for the booking
  final String specialRequests;

  /// Status of the booking
  final BookingStatus status;

  /// Total price of the booking
  final double totalPrice;

  /// Service-specific options for the booking
  final Map<String, dynamic> serviceOptions;

  /// Date and time when the booking was created
  final DateTime createdAt;

  /// Date and time when the booking was last updated
  final DateTime updatedAt;

  /// Contact information for the booking
  final String contactName;
  final String contactEmail;
  final String contactPhone;

  /// Event ID associated with the booking (if any)
  final String? eventId;

  /// Event name associated with the booking (if any)
  final String? eventName;

  /// Constructor
  Booking({
    required this.id,
    required this.userId,
    required this.serviceId,
    required this.serviceType,
    required this.serviceName,
    required this.bookingDateTime,
    required this.duration,
    required this.guestCount,
    this.specialRequests = '',
    required this.status,
    required this.totalPrice,
    required this.createdAt,
    required this.updatedAt,
    required this.contactName,
    required this.contactEmail,
    required this.contactPhone,
    this.eventId,
    this.eventName,
    this.serviceOptions = const {},
  });

  /// Create a copy of this booking with modified fields
  Booking copyWith({
    String? id,
    String? userId,
    String? serviceId,
    String? serviceType,
    String? serviceName,
    DateTime? bookingDateTime,
    double? duration,
    int? guestCount,
    String? specialRequests,
    BookingStatus? status,
    double? totalPrice,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? contactName,
    String? contactEmail,
    String? contactPhone,
    String? eventId,
    String? eventName,
    Map<String, dynamic>? serviceOptions,
  }) {
    return Booking(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      serviceId: serviceId ?? this.serviceId,
      serviceType: serviceType ?? this.serviceType,
      serviceName: serviceName ?? this.serviceName,
      bookingDateTime: bookingDateTime ?? this.bookingDateTime,
      duration: duration ?? this.duration,
      guestCount: guestCount ?? this.guestCount,
      specialRequests: specialRequests ?? this.specialRequests,
      status: status ?? this.status,
      totalPrice: totalPrice ?? this.totalPrice,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      contactName: contactName ?? this.contactName,
      contactEmail: contactEmail ?? this.contactEmail,
      contactPhone: contactPhone ?? this.contactPhone,
      eventId: eventId ?? this.eventId,
      eventName: eventName ?? this.eventName,
      serviceOptions: serviceOptions ?? this.serviceOptions,
    );
  }

  /// Convert booking to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'serviceId': serviceId,
      'serviceType': serviceType,
      'serviceName': serviceName,
      'bookingDateTime': bookingDateTime.toIso8601String(),
      'duration': duration,
      'guestCount': guestCount,
      'specialRequests': specialRequests,
      'status': status.index,
      'totalPrice': totalPrice,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'contactName': contactName,
      'contactEmail': contactEmail,
      'contactPhone': contactPhone,
      'eventId': eventId,
      'eventName': eventName,
      'serviceOptions': serviceOptions,
    };
  }

  /// Create booking from JSON
  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'],
      userId: json['userId'],
      serviceId: json['serviceId'],
      serviceType: json['serviceType'],
      serviceName: json['serviceName'],
      bookingDateTime: DateTime.parse(json['bookingDateTime']),
      duration: json['duration'].toDouble(),
      guestCount: json['guestCount'],
      specialRequests: json['specialRequests'] ?? '',
      status: BookingStatus.values[json['status']],
      totalPrice: json['totalPrice'].toDouble(),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      contactName: json['contactName'],
      contactEmail: json['contactEmail'],
      contactPhone: json['contactPhone'],
      eventId: json['eventId'],
      eventName: json['eventName'],
      serviceOptions: json['serviceOptions'] ?? {},
    );
  }

  /// Check if the booking is upcoming
  bool get isUpcoming =>
      bookingDateTime.isAfter(DateTime.now()) &&
      status != BookingStatus.cancelled;

  /// Check if the booking is past
  bool get isPast =>
      bookingDateTime.isBefore(DateTime.now()) ||
      status == BookingStatus.cancelled ||
      status == BookingStatus.completed ||
      status == BookingStatus.noShow;

  /// Format the booking date for display
  String get formattedDate =>
      '${bookingDateTime.day}/${bookingDateTime.month}/${bookingDateTime.year}';

  /// Format the booking time for display
  String get formattedTime =>
      '${bookingDateTime.hour.toString().padLeft(2, '0')}:${bookingDateTime.minute.toString().padLeft(2, '0')}';

  /// Get the formatted duration
  String get formattedDuration {
    if (duration == 1) {
      return '1 hour';
    } else if (duration % 1 == 0) {
      return '${duration.toInt()} hours';
    } else {
      final hours = duration.floor();
      final minutes = ((duration - hours) * 60).round();
      if (hours == 0) {
        return '$minutes minutes';
      } else if (hours == 1) {
        return '1 hour $minutes minutes';
      } else {
        return '$hours hours $minutes minutes';
      }
    }
  }

  /// Get the formatted price
  String get formattedPrice => '\$${totalPrice.toStringAsFixed(2)}';

  /// Get venue options for this booking
  VenueOptions? getVenueOptions() {
    if (serviceType != 'venue' || !serviceOptions.containsKey('venue')) {
      return null;
    }
    return VenueOptions.fromJson(serviceOptions['venue']);
  }

  /// Get catering options for this booking
  CateringOptions? getCateringOptions() {
    if (serviceType != 'catering' || !serviceOptions.containsKey('catering')) {
      return null;
    }
    return CateringOptions.fromJson(serviceOptions['catering']);
  }

  /// Get photography options for this booking
  PhotographyOptions? getPhotographyOptions() {
    if (serviceType != 'photography' ||
        !serviceOptions.containsKey('photography')) {
      return null;
    }
    return PhotographyOptions.fromJson(serviceOptions['photography']);
  }

  /// Get planner options for this booking
  PlannerOptions? getPlannerOptions() {
    if (serviceType != 'planner' || !serviceOptions.containsKey('planner')) {
      return null;
    }
    return PlannerOptions.fromJson(serviceOptions['planner']);
  }

  /// Set venue options for this booking
  Booking withVenueOptions(VenueOptions options) {
    final newOptions = Map<String, dynamic>.from(serviceOptions);
    newOptions['venue'] = options.toJson();
    return copyWith(serviceOptions: newOptions);
  }

  /// Set catering options for this booking
  Booking withCateringOptions(CateringOptions options) {
    final newOptions = Map<String, dynamic>.from(serviceOptions);
    newOptions['catering'] = options.toJson();
    return copyWith(serviceOptions: newOptions);
  }

  /// Set photography options for this booking
  Booking withPhotographyOptions(PhotographyOptions options) {
    final newOptions = Map<String, dynamic>.from(serviceOptions);
    newOptions['photography'] = options.toJson();
    return copyWith(serviceOptions: newOptions);
  }

  /// Set planner options for this booking
  Booking withPlannerOptions(PlannerOptions options) {
    final newOptions = Map<String, dynamic>.from(serviceOptions);
    newOptions['planner'] = options.toJson();
    return copyWith(serviceOptions: newOptions);
  }
}
