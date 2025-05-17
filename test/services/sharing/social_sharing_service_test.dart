import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:share_plus/share_plus.dart';
import 'package:eventati_book/models/event_models/event.dart';
import 'package:eventati_book/models/service_models/booking.dart';
import 'package:eventati_book/models/feature_models/saved_comparison.dart';
import 'package:eventati_book/services/sharing/social_sharing_service.dart';
import 'package:eventati_book/services/analytics_service.dart';
import 'package:eventati_book/utils/service/pdf_export_utils.dart';

// Mock classes
class MockAnalyticsService extends Mock implements AnalyticsService {}
class MockPDFExportUtils extends Mock implements PDFExportUtils {}
class MockShare extends Mock {}

void main() {
  late SocialSharingService sharingService;
  late MockAnalyticsService mockAnalyticsService;

  setUp(() {
    mockAnalyticsService = MockAnalyticsService();
    
    // Create the sharing service with the mock
    sharingService = SocialSharingService(
      analyticsService: mockAnalyticsService,
    );
    
    // Mock Share.share
    Share.share = (String text, {String? subject, Rect? sharePositionOrigin}) async {
      return;
    };
    
    // Mock Share.shareXFiles
    Share.shareXFiles = (List<XFile> files, {String? text, String? subject, Rect? sharePositionOrigin}) async {
      return;
    };
    
    // Mock analytics tracking
    when(() => mockAnalyticsService.trackShare(
      contentType: any(named: 'contentType'),
      itemId: any(named: 'itemId'),
      method: any(named: 'method'),
    )).thenAnswer((_) async {});
  });

  group('SocialSharingService', () {
    test('shareContent should share text content', () async {
      // Arrange
      final text = 'Test content';
      final subject = 'Test subject';
      
      // Act
      await sharingService.shareContent(
        text: text,
        subject: subject,
      );
      
      // Assert
      verify(() => mockAnalyticsService.trackShare(
        contentType: 'text',
        itemId: 'generic_share',
        method: 'platform_share',
      )).called(1);
    });
    
    test('shareEvent should share an event with deep link', () async {
      // Arrange
      final event = Event(
        id: 'event123',
        name: 'Test Event',
        type: EventType.wedding,
        date: DateTime(2023, 6, 15),
        location: 'Test Location',
        description: 'Test description',
        budget: 1000.0,
        guestCount: 50,
        createdAt: DateTime.now(),
      );
      
      // Act
      await sharingService.shareEvent(event);
      
      // Assert
      verify(() => mockAnalyticsService.trackShare(
        contentType: 'event',
        itemId: 'event123',
        method: 'platform_share',
      )).called(1);
    });
    
    test('shareBooking should share a booking', () async {
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
      
      // Act
      await sharingService.shareBooking(booking);
      
      // Assert
      verify(() => mockAnalyticsService.trackShare(
        contentType: 'booking',
        itemId: 'booking123',
        method: 'platform_share',
      )).called(1);
    });
    
    test('shareComparison should share a comparison as PDF', () async {
      // Arrange
      final comparison = SavedComparison(
        id: 'comparison123',
        title: 'Test Comparison',
        serviceType: 'venue',
        serviceIds: ['service1', 'service2'],
        serviceNames: ['Service 1', 'Service 2'],
        createdAt: DateTime.now(),
        userId: 'user123',
        eventId: 'event123',
      );
      
      // Mock PDF generation
      PDFExportUtils.generateComparisonPDF = (
        SavedComparison comparison, {
        bool includeNotes = true,
        bool includeHighlights = true,
      }) async {
        return Uint8List(0);
      };
      
      // Mock PDF sharing
      PDFExportUtils.sharePDF = (
        Uint8List pdfBytes,
        String fileName, {
        String subject = 'Eventati Book Comparison',
        String text = 'Here is your comparison from Eventati Book.',
      }) async {
        return;
      };
      
      // Act
      await sharingService.shareComparison(comparison);
      
      // Assert
      verify(() => mockAnalyticsService.trackShare(
        contentType: 'comparison',
        itemId: 'comparison123',
        method: 'pdf_share',
      )).called(1);
    });
  });
}

// Mock Uint8List for PDF testing
class Uint8List {
  final int length;
  Uint8List(this.length);
}
