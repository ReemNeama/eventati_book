import 'package:flutter_test/flutter_test.dart';
import 'package:eventati_book/utils/utils.dart';

void main() {
  group('StringUtils Tests', () {
    test('capitalize should capitalize the first letter of a string', () {
      // Test with lowercase string
      expect(StringUtils.capitalize('hello'), equals('Hello'));

      // Test with already capitalized string
      expect(StringUtils.capitalize('Hello'), equals('Hello'));

      // Test with empty string
      expect(StringUtils.capitalize(''), equals(''));

      // Test with single character
      expect(StringUtils.capitalize('a'), equals('A'));
    });

    test('capitalizeEachWord should capitalize each word in a string', () {
      // Test with lowercase words
      expect(
        StringUtils.capitalizeEachWord('hello world'),
        equals('Hello World'),
      );

      // Test with mixed case words
      expect(
        StringUtils.capitalizeEachWord('hello World'),
        equals('Hello World'),
      );

      // Test with empty string
      expect(StringUtils.capitalizeEachWord(''), equals(''));

      // Test with single word
      expect(StringUtils.capitalizeEachWord('hello'), equals('Hello'));
    });

    test('truncate should truncate a string to a maximum length', () {
      // Test with string shorter than max length
      expect(StringUtils.truncate('Hello', 10), equals('Hello'));

      // Test with string equal to max length
      expect(StringUtils.truncate('Hello', 5), equals('Hello'));

      // Test with string longer than max length
      expect(StringUtils.truncate('Hello World', 5), equals('Hello...'));

      // Test with custom ellipsis
      expect(
        StringUtils.truncate('Hello World', 5, ellipsis: '...!'),
        equals('Hello...!'),
      );

      // Test with empty string
      expect(StringUtils.truncate('', 5), equals(''));
    });

    test('removeHtmlTags should remove all HTML tags from a string', () {
      // Test with HTML tags
      expect(
        StringUtils.removeHtmlTags('<p>Hello <b>World</b></p>'),
        equals('Hello World'),
      );

      // Test with no HTML tags
      expect(StringUtils.removeHtmlTags('Hello World'), equals('Hello World'));

      // Test with empty string
      expect(StringUtils.removeHtmlTags(''), equals(''));

      // Test with only HTML tags
      expect(StringUtils.removeHtmlTags('<p></p>'), equals(''));
    });

    test('isValidEmail should check if a string is a valid email', () {
      // Test with valid email
      expect(StringUtils.isValidEmail('test@example.com'), isTrue);

      // Test with invalid email (no @)
      expect(StringUtils.isValidEmail('testexample.com'), isFalse);

      // Test with invalid email (no domain)
      expect(StringUtils.isValidEmail('test@'), isFalse);

      // Test with invalid email (no username)
      expect(StringUtils.isValidEmail('@example.com'), isFalse);

      // Test with empty string
      expect(StringUtils.isValidEmail(''), isFalse);
    });

    test(
      'isValidPhoneNumber should check if a string is a valid phone number',
      () {
        // Test with valid phone number
        expect(StringUtils.isValidPhoneNumber('1234567890'), isTrue);

        // Test with valid phone number with country code
        expect(StringUtils.isValidPhoneNumber('+11234567890'), isTrue);

        // Test with invalid phone number (too short)
        expect(StringUtils.isValidPhoneNumber('123456'), isFalse);

        // Test with invalid phone number (contains letters)
        expect(StringUtils.isValidPhoneNumber('123abc4567'), isFalse);

        // Test with empty string
        expect(StringUtils.isValidPhoneNumber(''), isFalse);
      },
    );

    test('formatPhoneNumber should format a phone number for display', () {
      // Test with 10-digit number
      expect(
        StringUtils.formatPhoneNumber('1234567890'),
        equals('(123) 456-7890'),
      );

      // Test with formatted number (should remove non-digits first)
      expect(
        StringUtils.formatPhoneNumber('(123) 456-7890'),
        equals('(123) 456-7890'),
      );

      // Test with number that's not 10 digits
      expect(StringUtils.formatPhoneNumber('123456'), equals('123456'));

      // Test with empty string
      expect(StringUtils.formatPhoneNumber(''), equals(''));
    });

    test('getInitials should get initials from a name', () {
      // Test with first and last name
      expect(StringUtils.getInitials('John Doe'), equals('JD'));

      // Test with single name
      expect(StringUtils.getInitials('John'), equals('J'));

      // Test with multiple names
      expect(StringUtils.getInitials('John Middle Doe'), equals('JD'));

      // Test with empty string
      expect(StringUtils.getInitials(''), equals(''));
    });
  });
}
