import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eventati_book/models/models.dart';
import 'package:eventati_book/services/firebase/firestore_service.dart';
import 'package:eventati_book/utils/logger.dart';

/// Service for handling booking-related Firestore operations
class BookingFirestoreService {
  /// Firestore service
  final FirestoreService _firestoreService;

  /// Collection name
  final String _collection = 'bookings';

  /// Constructor
  BookingFirestoreService({FirestoreService? firestoreService})
      : _firestoreService = firestoreService ?? FirestoreService();

  /// Get all bookings for a user
  Future<List<Booking>> getBookingsForUser(String userId) async {
    try {
      final bookings = await _firestoreService.getCollectionWithQueryAs(
        _collection,
        [
          QueryFilter(
            field: 'userId',
            operation: FilterOperation.equalTo,
            value: userId,
          ),
        ],
        (data, id) => _mapToBooking(data, id),
      );
      return bookings;
    } catch (e) {
      Logger.e('Error getting bookings for user: $e', tag: 'BookingFirestoreService');
      rethrow;
    }
  }

  /// Get all bookings for an event
  Future<List<Booking>> getBookingsForEvent(String eventId) async {
    try {
      final bookings = await _firestoreService.getCollectionWithQueryAs(
        _collection,
        [
          QueryFilter(
            field: 'eventId',
            operation: FilterOperation.equalTo,
            value: eventId,
          ),
        ],
        (data, id) => _mapToBooking(data, id),
      );
      return bookings;
    } catch (e) {
      Logger.e('Error getting bookings for event: $e', tag: 'BookingFirestoreService');
      rethrow;
    }
  }

  /// Get a booking by ID
  Future<Booking?> getBookingById(String bookingId) async {
    try {
      final bookingData = await _firestoreService.getDocument(
        _collection,
        bookingId,
      );
      if (bookingData == null) return null;
      return _mapToBooking(bookingData, bookingId);
    } catch (e) {
      Logger.e('Error getting booking by ID: $e', tag: 'BookingFirestoreService');
      rethrow;
    }
  }

  /// Create a new booking
  Future<String> createBooking(Booking booking) async {
    try {
      final bookingId = await _firestoreService.addDocument(
        _collection,
        _mapFromBooking(booking),
      );
      return bookingId;
    } catch (e) {
      Logger.e('Error creating booking: $e', tag: 'BookingFirestoreService');
      rethrow;
    }
  }

  /// Update a booking
  Future<void> updateBooking(Booking booking) async {
    try {
      await _firestoreService.updateDocument(
        _collection,
        booking.id,
        _mapFromBooking(booking),
      );
    } catch (e) {
      Logger.e('Error updating booking: $e', tag: 'BookingFirestoreService');
      rethrow;
    }
  }

  /// Delete a booking
  Future<void> deleteBooking(String bookingId) async {
    try {
      await _firestoreService.deleteDocument(
        _collection,
        bookingId,
      );
    } catch (e) {
      Logger.e('Error deleting booking: $e', tag: 'BookingFirestoreService');
      rethrow;
    }
  }

  /// Get a stream of bookings for a user
  Stream<List<Booking>> getBookingsForUserStream(String userId) {
    return _firestoreService.collectionStreamWithQueryAs(
      _collection,
      [
        QueryFilter(
          field: 'userId',
          operation: FilterOperation.equalTo,
          value: userId,
        ),
      ],
      (data, id) => _mapToBooking(data, id),
    );
  }

  /// Get a stream of bookings for an event
  Stream<List<Booking>> getBookingsForEventStream(String eventId) {
    return _firestoreService.collectionStreamWithQueryAs(
      _collection,
      [
        QueryFilter(
          field: 'eventId',
          operation: FilterOperation.equalTo,
          value: eventId,
        ),
      ],
      (data, id) => _mapToBooking(data, id),
    );
  }

  /// Get a stream of a booking by ID
  Stream<Booking?> getBookingByIdStream(String bookingId) {
    return _firestoreService.documentStreamAs(
      _collection,
      bookingId,
      (data, id) => _mapToBooking(data, id),
    );
  }

  /// Check if a service is available at the requested date and time
  Future<bool> isServiceAvailable(
    String serviceId,
    DateTime dateTime,
    double duration,
  ) async {
    try {
      final startTime = dateTime;
      final endTime = dateTime.add(Duration(minutes: (duration * 60).toInt()));

      // Get all bookings for the service
      final bookings = await _firestoreService.getCollectionWithQueryAs(
        _collection,
        [
          QueryFilter(
            field: 'serviceId',
            operation: FilterOperation.equalTo,
            value: serviceId,
          ),
          QueryFilter(
            field: 'status',
            operation: FilterOperation.notEqualTo,
            value: BookingStatus.cancelled.index,
          ),
        ],
        (data, id) => _mapToBooking(data, id),
      );

      // Check if any booking overlaps with the requested time
      for (final booking in bookings) {
        final bookingStartTime = booking.bookingDateTime;
        final bookingEndTime = booking.bookingDateTime.add(
          Duration(minutes: (booking.duration * 60).toInt()),
        );

        // Check for overlap
        if (startTime.isBefore(bookingEndTime) &&
            endTime.isAfter(bookingStartTime)) {
          return false; // Service is not available
        }
      }

      return true; // Service is available
    } catch (e) {
      Logger.e('Error checking service availability: $e', tag: 'BookingFirestoreService');
      rethrow;
    }
  }

  /// Helper method to map Firestore data to a Booking object
  Booking _mapToBooking(Map<String, dynamic> data, String id) {
    return Booking(
      id: id,
      userId: data['userId'] ?? '',
      serviceId: data['serviceId'] ?? '',
      serviceType: data['serviceType'] ?? '',
      serviceName: data['serviceName'] ?? '',
      bookingDateTime: data['bookingDateTime'] != null
          ? (data['bookingDateTime'] as Timestamp).toDate()
          : DateTime.now(),
      duration: (data['duration'] ?? 0).toDouble(),
      guestCount: data['guestCount'] ?? 0,
      specialRequests: data['specialRequests'] ?? '',
      status: BookingStatus.values[data['status'] ?? 0],
      totalPrice: (data['totalPrice'] ?? 0).toDouble(),
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : DateTime.now(),
      contactName: data['contactName'] ?? '',
      contactEmail: data['contactEmail'] ?? '',
      contactPhone: data['contactPhone'] ?? '',
      eventId: data['eventId'],
      eventName: data['eventName'],
      serviceOptions: data['serviceOptions'] ?? {},
    );
  }

  /// Helper method to map a Booking object to Firestore data
  Map<String, dynamic> _mapFromBooking(Booking booking) {
    return {
      'userId': booking.userId,
      'serviceId': booking.serviceId,
      'serviceType': booking.serviceType,
      'serviceName': booking.serviceName,
      'bookingDateTime': Timestamp.fromDate(booking.bookingDateTime),
      'duration': booking.duration,
      'guestCount': booking.guestCount,
      'specialRequests': booking.specialRequests,
      'status': booking.status.index,
      'totalPrice': booking.totalPrice,
      'createdAt': Timestamp.fromDate(booking.createdAt),
      'updatedAt': Timestamp.fromDate(booking.updatedAt),
      'contactName': booking.contactName,
      'contactEmail': booking.contactEmail,
      'contactPhone': booking.contactPhone,
      'eventId': booking.eventId,
      'eventName': booking.eventName,
      'serviceOptions': booking.serviceOptions,
    };
  }
}
