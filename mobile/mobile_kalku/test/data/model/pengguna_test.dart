import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_kalku/data/models/user.dart';

void main() {
  group('User Model', () {
    test('fromMap and toMap', () {
      final now = DateTime.now().toUtc();
      final user = User(
        id: 1,
        username: 'test_user',
        passwordHash: 'hash',
        passwordSalt: 'salt',
        role: 'user',
        biometricEnabled: true,
        isActive: false,
        createdAt: now,
        updatedAt: now,
      );

      final map = user.toMap();
      final userFromMap = User.fromMap(map);

      expect(userFromMap.id, equals(user.id));
      expect(userFromMap.username, equals(user.username));
      expect(userFromMap.passwordHash, equals(user.passwordHash));
      expect(userFromMap.passwordSalt, equals(user.passwordSalt));
      expect(userFromMap.role, equals(user.role));
      expect(userFromMap.biometricEnabled, equals(user.biometricEnabled));
      expect(userFromMap.isActive, equals(user.isActive));
      
      // Compare by string to avoid millisecond/microsecond precision issues with SQLite datetime format
      expect(userFromMap.createdAt.toIso8601String().substring(0, 19), equals(user.createdAt.toIso8601String().substring(0, 19)));
      expect(userFromMap.updatedAt.toIso8601String().substring(0, 19), equals(user.updatedAt.toIso8601String().substring(0, 19)));
    });

    test('copyWith', () {
      final user = User(
        id: 1,
        username: 'old',
        passwordHash: 'hash',
        passwordSalt: 'salt',
        role: 'user',
      );
      final newCopied = user.copyWith(username: 'new');
      expect(newCopied.username, equals('new'));
      expect(newCopied.id, equals(1));
    });
  });
}
