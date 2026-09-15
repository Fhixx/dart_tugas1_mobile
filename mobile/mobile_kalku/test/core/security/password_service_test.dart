
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_kalku/core/security/password_service.dart';

void main() {
  late PasswordService passwordService;

  setUp(() {
    passwordService = PasswordService();
  });

  group('PasswordService', () {
    test('correct password verify = true', () {
      final credentials = passwordService.generateHashAndSalt('my_secret_password');
      final isValid = passwordService.verifyPassword('my_secret_password', credentials['hash']!, credentials['salt']!);
      expect(isValid, isTrue);
    });

    test('wrong password = false', () {
      final credentials = passwordService.generateHashAndSalt('my_secret_password');
      final isValid = passwordService.verifyPassword('wrong_password', credentials['hash']!, credentials['salt']!);
      expect(isValid, isFalse);
    });

    test('stored value != plaintext', () {
      final plaintext = '123456';
      final credentials = passwordService.generateHashAndSalt(plaintext);
      expect(credentials['hash'], isNot(equals(plaintext)));
      expect(credentials['salt'], isNot(equals(plaintext)));
    });

    test('generated salt length correct (16 bytes)', () {
      final salt = passwordService.generateSalt();
      expect(salt.length, equals(16));
    });

    test('two salts differ', () {
      final salt1 = passwordService.generateSalt();
      final salt2 = passwordService.generateSalt();
      expect(salt1, isNot(equals(salt2)));
    });

    test('PBKDF2 deterministic for same password+salt', () {
      final salt = passwordService.generateSalt();
      final hash1 = passwordService.hashPassword('password123', salt);
      final hash2 = passwordService.hashPassword('password123', salt);
      expect(hash1, equals(hash2));
    });
  });
}
