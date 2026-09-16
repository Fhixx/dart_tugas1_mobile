import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_kalku/inti/utilitas/validator_input.dart';

void main() {
  group('Validators', () {
    test('username 2 / 3 / 32 / 33 chars', () {
      expect(Validators.validateUsername('ab'), isNotNull);
      expect(Validators.validateUsername('abc'), isNull);
      expect(Validators.validateUsername('a' * 32), isNull);
      expect(Validators.validateUsername('a' * 33), isNotNull);
    });

    test('empty password', () {
      expect(Validators.validatePassword(''), isNotNull);
      expect(Validators.validatePassword(null), isNotNull);
    });

    test('password "123"', () {
      expect(Validators.validatePassword('123'), isNull);
    });

    test('age boundaries', () {
      expect(Validators.validateAge('0'), isNotNull);
      expect(Validators.validateAge('1'), isNull);
      expect(Validators.validateAge('300'), isNull);
      expect(Validators.validateAge('301'), isNotNull);
    });

    test('decimal age', () {
      expect(Validators.validateAge('25.5'), isNotNull);
      expect(Validators.validateAge('25,5'), isNotNull);
    });

    test('weight boundaries', () {
      expect(Validators.validateWeight('0'), isNotNull);
      expect(Validators.validateWeight('0.1'), isNull);
      expect(Validators.validateWeight('1000'), isNull);
      expect(Validators.validateWeight('1000.1'), isNotNull);
    });

    test('height boundaries', () {
      expect(Validators.validateHeight('0'), isNotNull);
      expect(Validators.validateHeight('0.1'), isNull);
      expect(Validators.validateHeight('400'), isNull);
      expect(Validators.validateHeight('400.1'), isNotNull);
    });

    test('NaN, Infinity, negatives, malformed numeric', () {
      expect(Validators.validateWeight('NaN'), isNotNull);
      expect(Validators.validateWeight('Infinity'), isNotNull);
      expect(Validators.validateWeight('-5'), isNotNull);
      expect(Validators.validateWeight('abc'), isNotNull);

      expect(Validators.validateHeight('NaN'), isNotNull);
      expect(Validators.validateHeight('Infinity'), isNotNull);
      expect(Validators.validateHeight('-10'), isNotNull);
      expect(Validators.validateHeight('1.2.3'), isNotNull);
    });
  });
}
