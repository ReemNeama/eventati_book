import 'package:flutter_test/flutter_test.dart';
import 'package:eventati_book/utils/utils.dart';

void main() {
  group('ServiceUtils Tests', () {
    test('formatPrice should format price correctly', () {
      // Test default formatting
      expect(ServiceUtils.formatPrice(1000), equals('\$1,000'));

      // Test with decimal places
      expect(
        ServiceUtils.formatPrice(1000, decimalPlaces: 2),
        equals('\$1,000.00'),
      );

      // Test with per person
      expect(
        ServiceUtils.formatPrice(1000, showPerPerson: true),
        equals('\$1,000/person'),
      );

      // Test with per event
      expect(
        ServiceUtils.formatPrice(1000, showPerEvent: true),
        equals('\$1,000/event'),
      );

      // Test with decimal places and per person
      expect(
        ServiceUtils.formatPrice(1000, decimalPlaces: 2, showPerPerson: true),
        equals('\$1,000.00/person'),
      );
    });

    test('formatCapacityRange should format capacity range correctly', () {
      // Test with small numbers
      expect(
        ServiceUtils.formatCapacityRange(10, 50),
        equals('Capacity: 10-50 guests'),
      );

      // Test with large numbers
      expect(
        ServiceUtils.formatCapacityRange(1000, 5000),
        equals('Capacity: 1,000-5,000 guests'),
      );
    });

    test('formatExperience should format experience correctly', () {
      // Test with singular year
      expect(ServiceUtils.formatExperience(1), equals('Experience: 1 year'));

      // Test with multiple years
      expect(ServiceUtils.formatExperience(5), equals('Experience: 5 years'));
    });

    test('formatRating should format rating correctly', () {
      // Test with whole number
      expect(ServiceUtils.formatRating(4.0), equals('4.0'));

      // Test with decimal
      expect(ServiceUtils.formatRating(4.5), equals('4.5'));

      // Test with long decimal
      expect(ServiceUtils.formatRating(4.567), equals('4.6'));
    });

    test('sortByRating should sort services by rating', () {
      // Arrange
      final services = [
        _TestService(name: 'Service A', rating: 3.5),
        _TestService(name: 'Service B', rating: 4.5),
        _TestService(name: 'Service C', rating: 2.5),
      ];

      // Act
      final sorted = ServiceUtils.sortByRating(
        services,
        (service) => service.rating,
      );

      // Assert
      expect(sorted[0].name, equals('Service B')); // Highest rating
      expect(sorted[1].name, equals('Service A')); // Middle rating
      expect(sorted[2].name, equals('Service C')); // Lowest rating
    });

    test('sortByPriceLowToHigh should sort services by price', () {
      // Arrange
      final services = [
        _TestService(name: 'Service A', price: 300),
        _TestService(name: 'Service B', price: 100),
        _TestService(name: 'Service C', price: 500),
      ];

      // Act
      final sorted = ServiceUtils.sortByPriceLowToHigh(
        services,
        (service) => service.price,
      );

      // Assert
      expect(sorted[0].name, equals('Service B')); // Lowest price
      expect(sorted[1].name, equals('Service A')); // Middle price
      expect(sorted[2].name, equals('Service C')); // Highest price
    });
  });
}

// Test class for sorting tests
class _TestService {
  final String name;
  final double rating;
  final double price;

  _TestService({required this.name, this.rating = 0.0, this.price = 0.0});
}
