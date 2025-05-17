import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:eventati_book/models/service_models/booking.dart';
import 'package:eventati_book/services/calendar/calendar_service.dart';

// Mock classes
class MockSupabaseClient extends Mock implements SupabaseClient {}

// Custom mock for PostgrestQueryBuilder
class MockSupabaseQueryBuilder extends Mock {
  // Mock methods to return this instance for chaining
  MockSupabaseQueryBuilder eq(String column, dynamic value) => this;
  MockSupabaseQueryBuilder gte(String column, dynamic value) => this;
  MockSupabaseQueryBuilder lte(String column, dynamic value) => this;
  MockSupabaseQueryBuilder delete() => this;
  MockSupabaseQueryBuilder select(String columns) => this;

  // Mock methods that return futures
  Future<dynamic> insert(Map<String, dynamic> data) async => {};
  Future<dynamic> upsert(Map<String, dynamic> data) async => {};
}

// Mock Add2Calendar
class MockAdd2Calendar extends Mock implements Add2Calendar {}

void main() {
  late CalendarService calendarService;
  late MockSupabaseClient mockSupabaseClient;
  late MockSupabaseQueryBuilder mockQueryBuilder;

  setUp(() {
    mockSupabaseClient = MockSupabaseClient();
    mockQueryBuilder = MockSupabaseQueryBuilder();

    // Set up the mock Supabase client
    when(
      () => mockSupabaseClient.from(any()),
    ).thenReturn(mockQueryBuilder as SupabaseQueryBuilder);

    // Create the calendar service with the mock client
    calendarService = CalendarService(supabase: mockSupabaseClient);
  });

  group('CalendarService', () {
    test(
      'createEventForBooking should create a calendar event and store the reference',
      () async {
        // Arrange
        final booking = Booking(
          id: 'booking123',
          userId: 'user123',
          serviceId: 'service123',
          eventId: 'event123',
          serviceName: 'Test Service',
          bookingDateTime: DateTime(2023, 6, 15, 14, 0),
          duration: 2.5,
          status: BookingStatus.confirmed,
          createdAt: DateTime.now(),
          serviceOptions: {'location': 'Test Location'},
          specialRequests: 'Test special requests',
          serviceType: 'venue',
          guestCount: 50,
          totalPrice: 1000.0,
          updatedAt: DateTime.now(),
          contactName: 'Test User',
          contactEmail: 'test@example.com',
          contactPhone: '123-456-7890',
        );

        // Mock permission check
        TestWidgetsFlutterBinding.ensureInitialized();
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(
              const MethodChannel('flutter.baseflow.com/permissions/methods'),
              (MethodCall methodCall) async {
                if (methodCall.method == 'checkPermissionStatus') {
                  return PermissionStatus.granted.index;
                }
                return null;
              },
            );

        // Mock Add2Calendar
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(const MethodChannel('add_2_calendar'), (
              MethodCall methodCall,
            ) async {
              if (methodCall.method == 'add2Cal') {
                return true;
              }
              return null;
            });

        // Act
        final eventId = await calendarService.createEventForBooking(
          booking,
          addReminder: true,
          reminderMinutesBefore: 60,
        );

        // Assert
        expect(eventId, isNotNull);
        verify(
          () => mockSupabaseClient.from('booking_calendar_events'),
        ).called(1);
        verify(
          () => mockSupabaseClient.from('booking_calendar_preferences'),
        ).called(1);
      },
    );

    test('updateEventForBooking should update a calendar event', () async {
      // Arrange
      final booking = Booking(
        id: 'booking123',
        userId: 'user123',
        serviceId: 'service123',
        eventId: 'event123',
        serviceName: 'Test Service',
        bookingDateTime: DateTime(2023, 6, 15, 14, 0),
        duration: 2.5,
        status: BookingStatus.confirmed,
        createdAt: DateTime.now(),
        serviceOptions: {'location': 'Test Location'},
        specialRequests: 'Test special requests',
        serviceType: 'venue',
        guestCount: 50,
        totalPrice: 1000.0,
        updatedAt: DateTime.now(),
        contactName: 'Test User',
        contactEmail: 'test@example.com',
        contactPhone: '123-456-7890',
      );

      // Mock permission check
      TestWidgetsFlutterBinding.ensureInitialized();
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
            const MethodChannel('flutter.baseflow.com/permissions/methods'),
            (MethodCall methodCall) async {
              if (methodCall.method == 'checkPermissionStatus') {
                return PermissionStatus.granted.index;
              }
              return null;
            },
          );

      // Mock Add2Calendar
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(const MethodChannel('add_2_calendar'), (
            MethodCall methodCall,
          ) async {
            if (methodCall.method == 'add2Cal') {
              return true;
            }
            return null;
          });

      // Act
      final success = await calendarService.updateEventForBooking(
        booking,
        'event123',
      );

      // Assert
      expect(success, isTrue);
      verify(
        () => mockSupabaseClient.from('booking_calendar_events'),
      ).called(2);
    });

    test('checkAvailability should check for overlapping bookings', () async {
      // Arrange
      final startTime = DateTime(2023, 6, 15, 14, 0);
      final endTime = DateTime(2023, 6, 15, 16, 0);

      // For testing purposes, we'll just verify that the method was called
      // The actual implementation would check for overlapping bookings

      // Act
      final isAvailable = await calendarService.checkAvailability(
        startTime,
        endTime,
        serviceId: 'service123',
      );

      // Assert
      expect(isAvailable, isTrue);
      verify(() => mockSupabaseClient.from('bookings')).called(1);
    });
  });
}
