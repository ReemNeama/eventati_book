import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:eventati_book/models/service_models/booking.dart';
import 'package:eventati_book/services/calendar/calendar_service.dart';

// Mock classes
class MockSupabaseClient extends Mock implements SupabaseClient {}
class MockSupabaseQueryBuilder extends Mock implements SupabaseQueryBuilder {}
class MockPermissionStatus extends Mock implements PermissionStatus {}
class MockAdd2Calendar extends Mock implements Add2Calendar {}

void main() {
  late CalendarService calendarService;
  late MockSupabaseClient mockSupabaseClient;
  late MockSupabaseQueryBuilder mockQueryBuilder;

  setUp(() {
    mockSupabaseClient = MockSupabaseClient();
    mockQueryBuilder = MockSupabaseQueryBuilder();
    
    // Set up the mock Supabase client
    when(() => mockSupabaseClient.from(any())).thenReturn(mockQueryBuilder);
    
    // Create the calendar service with the mock client
    calendarService = CalendarService(supabase: mockSupabaseClient);
  });

  group('CalendarService', () {
    test('createEventForBooking should create a calendar event and store the reference', () async {
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
      );
      
      // Mock permission check
      TestWidgetsFlutterBinding.ensureInitialized();
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
        const MethodChannel('flutter.baseflow.com/permissions/methods'),
        (MethodCall methodCall) async {
          if (methodCall.method == 'checkPermissionStatus') {
            return PermissionStatus.granted.index;
          }
          return null;
        },
      );
      
      // Mock Supabase insert
      when(() => mockQueryBuilder.insert(any())).thenAnswer((_) async => {});
      when(() => mockQueryBuilder.upsert(any())).thenAnswer((_) async => {});
      
      // Mock Add2Calendar
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
        const MethodChannel('add_2_calendar'),
        (MethodCall methodCall) async {
          if (methodCall.method == 'add2Cal') {
            return true;
          }
          return null;
        },
      );
      
      // Act
      final eventId = await calendarService.createEventForBooking(
        booking,
        addReminder: true,
        reminderMinutesBefore: 60,
      );
      
      // Assert
      expect(eventId, isNotNull);
      verify(() => mockQueryBuilder.insert(any())).called(1);
      verify(() => mockQueryBuilder.upsert(any())).called(1);
    });
    
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
      );
      
      // Mock permission check
      TestWidgetsFlutterBinding.ensureInitialized();
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
        const MethodChannel('flutter.baseflow.com/permissions/methods'),
        (MethodCall methodCall) async {
          if (methodCall.method == 'checkPermissionStatus') {
            return PermissionStatus.granted.index;
          }
          return null;
        },
      );
      
      // Mock Supabase delete and insert
      when(() => mockQueryBuilder.delete()).thenReturn(mockQueryBuilder);
      when(() => mockQueryBuilder.eq(any(), any())).thenReturn(mockQueryBuilder);
      when(() => mockQueryBuilder.insert(any())).thenAnswer((_) async => {});
      
      // Mock Add2Calendar
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
        const MethodChannel('add_2_calendar'),
        (MethodCall methodCall) async {
          if (methodCall.method == 'add2Cal') {
            return true;
          }
          return null;
        },
      );
      
      // Act
      final success = await calendarService.updateEventForBooking(
        booking,
        'event123',
      );
      
      // Assert
      expect(success, isTrue);
      verify(() => mockQueryBuilder.delete()).called(1);
      verify(() => mockQueryBuilder.eq('booking_id', 'booking123')).called(1);
      verify(() => mockQueryBuilder.eq('event_id', 'event123')).called(1);
      verify(() => mockQueryBuilder.insert(any())).called(1);
    });
    
    test('checkAvailability should check for overlapping bookings', () async {
      // Arrange
      final startTime = DateTime(2023, 6, 15, 14, 0);
      final endTime = DateTime(2023, 6, 15, 16, 0);
      
      // Mock Supabase query
      when(() => mockQueryBuilder.select(any())).thenReturn(mockQueryBuilder);
      when(() => mockQueryBuilder.gte(any(), any())).thenReturn(mockQueryBuilder);
      when(() => mockQueryBuilder.lte(any(), any())).thenReturn(mockQueryBuilder);
      when(() => mockQueryBuilder.eq(any(), any())).thenReturn(mockQueryBuilder);
      
      // No overlapping bookings
      when(() => mockQueryBuilder).thenAnswer((_) async => []);
      
      // Act
      final isAvailable = await calendarService.checkAvailability(
        startTime,
        endTime,
        serviceId: 'service123',
      );
      
      // Assert
      expect(isAvailable, isTrue);
      verify(() => mockQueryBuilder.select('*, services:service_id(*)')).called(1);
      verify(() => mockQueryBuilder.gte('booking_date_time', any())).called(1);
      verify(() => mockQueryBuilder.lte('booking_date_time', any())).called(1);
      verify(() => mockQueryBuilder.eq('service_id', 'service123')).called(1);
    });
  });
}
