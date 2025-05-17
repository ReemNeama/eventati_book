import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:eventati_book/models/service_models/booking.dart';
import 'package:eventati_book/models/user_models/user.dart' as app_user;
import 'package:eventati_book/services/notification/email_service.dart';
import 'package:eventati_book/services/supabase/database/user_database_service.dart';

// Mock classes
class MockSupabaseClient extends Mock implements SupabaseClient {}
class MockUserDatabaseService extends Mock implements UserDatabaseService {}
class MockSupabaseFunction extends Mock implements SupabaseFunction {}
class MockSupabaseFunctions extends Mock implements SupabaseFunctions {}
class MockFunctionResponse extends Mock implements FunctionResponse {}

void main() {
  late EmailService emailService;
  late MockSupabaseClient mockSupabaseClient;
  late MockUserDatabaseService mockUserDatabaseService;
  late MockSupabaseFunctions mockSupabaseFunctions;
  late MockSupabaseFunction mockSupabaseFunction;
  late MockFunctionResponse mockFunctionResponse;

  setUp(() {
    mockSupabaseClient = MockSupabaseClient();
    mockUserDatabaseService = MockUserDatabaseService();
    mockSupabaseFunctions = MockSupabaseFunctions();
    mockSupabaseFunction = MockSupabaseFunction();
    mockFunctionResponse = MockFunctionResponse();
    
    // Set up the mock Supabase client
    when(() => mockSupabaseClient.functions).thenReturn(mockSupabaseFunctions);
    when(() => mockSupabaseFunctions.invoke(any(), body: any(named: 'body')))
        .thenAnswer((_) async => mockFunctionResponse);
    when(() => mockFunctionResponse.status).thenReturn(200);
    
    // Create the email service with the mocks
    emailService = EmailService(
      supabase: mockSupabaseClient,
      userDatabaseService: mockUserDatabaseService,
    );
  });

  group('EmailService', () {
    test('sendBookingConfirmationEmail should send a confirmation email', () async {
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
      
      final user = app_user.User(
        id: 'user123',
        email: 'test@example.com',
        displayName: 'Test User',
      );
      
      // Mock user database service
      when(() => mockUserDatabaseService.getUser(any()))
          .thenAnswer((_) async => user);
      
      // Act
      await emailService.sendBookingConfirmationEmail(booking);
      
      // Assert
      verify(() => mockUserDatabaseService.getUser('user123')).called(1);
      verify(() => mockSupabaseFunctions.invoke(
        'send-email',
        body: any(named: 'body'),
      )).called(1);
    });
    
    test('sendBookingUpdateEmail should send an update email', () async {
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
      
      final user = app_user.User(
        id: 'user123',
        email: 'test@example.com',
        displayName: 'Test User',
      );
      
      // Mock user database service
      when(() => mockUserDatabaseService.getUser(any()))
          .thenAnswer((_) async => user);
      
      // Act
      await emailService.sendBookingUpdateEmail(
        booking,
        'Your booking has been updated.',
      );
      
      // Assert
      verify(() => mockUserDatabaseService.getUser('user123')).called(1);
      verify(() => mockSupabaseFunctions.invoke(
        'send-email',
        body: any(named: 'body'),
      )).called(1);
    });
    
    test('sendBookingCancellationEmail should send a cancellation email', () async {
      // Arrange
      final booking = Booking(
        id: 'booking123',
        userId: 'user123',
        serviceId: 'service123',
        eventId: 'event123',
        serviceName: 'Test Service',
        bookingDateTime: DateTime(2023, 6, 15, 14, 0),
        duration: 2.5,
        status: BookingStatus.cancelled,
        createdAt: DateTime.now(),
        serviceOptions: {'location': 'Test Location'},
        specialRequests: 'Test special requests',
      );
      
      final user = app_user.User(
        id: 'user123',
        email: 'test@example.com',
        displayName: 'Test User',
      );
      
      // Mock user database service
      when(() => mockUserDatabaseService.getUser(any()))
          .thenAnswer((_) async => user);
      
      // Act
      await emailService.sendBookingCancellationEmail(booking);
      
      // Assert
      verify(() => mockUserDatabaseService.getUser('user123')).called(1);
      verify(() => mockSupabaseFunctions.invoke(
        'send-email',
        body: any(named: 'body'),
      )).called(1);
    });
    
    test('sendEmailVerification should send a verification email', () async {
      // Arrange
      final email = 'test@example.com';
      final userName = 'Test User';
      
      // Mock Supabase auth
      final mockAuth = MockSupabaseAuth();
      when(() => mockSupabaseClient.auth).thenReturn(mockAuth);
      when(() => mockAuth.signInWithOtp(
        email: any(named: 'email'),
        emailRedirectTo: any(named: 'emailRedirectTo'),
      )).thenAnswer((_) async => AuthResponse());
      
      // Act
      await emailService.sendEmailVerification(email, userName);
      
      // Assert
      verify(() => mockAuth.signInWithOtp(
        email: email,
        emailRedirectTo: any(named: 'emailRedirectTo'),
      )).called(1);
      verify(() => mockSupabaseFunctions.invoke(
        'send-email',
        body: any(named: 'body'),
      )).called(1);
    });
  });
}

// Additional mock classes
class MockSupabaseAuth extends Mock implements GoTrueClient {}
class AuthResponse {}
