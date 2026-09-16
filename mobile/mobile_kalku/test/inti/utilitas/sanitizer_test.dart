import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_kalku/core/utils/sanitizers.dart';

void main() {
  group('Sanitizers', () {
    test('username trimming and normalization', () {
      expect(Sanitizers.sanitizeUsername('  admin  '), equals('admin'));
    });

    test('name whitespace collapse and Unicode preservation', () {
      expect(Sanitizers.sanitizeName('  John    Doe  '), equals('John Doe'));
      expect(Sanitizers.sanitizeName('  Jóhn    Döe  '), equals('Jóhn Döe'));
    });

    test('comma decimal conversion if supported', () {
      expect(Sanitizers.sanitizeNumeric('  75,5  '), equals('75.5'));
      expect(Sanitizers.sanitizeNumeric('75.5'), equals('75.5'));
    });

    test('malformed numeric behavior', () {
      // Just checks that it doesn't crash and replaces comma.
      expect(Sanitizers.sanitizeNumeric('1,2,3'), equals('1.2.3'));
    });
  });
}
