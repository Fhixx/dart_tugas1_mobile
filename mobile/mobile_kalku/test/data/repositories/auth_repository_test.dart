import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart' hide equals;

import 'package:mobile_kalku/core/database/database_helper.dart';
import 'package:mobile_kalku/core/database/admin_seed.dart';
import 'package:mobile_kalku/core/domain/auth_result.dart';
import 'package:mobile_kalku/data/repositories/auth_repository.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  tearDownAll(() async {
    await DatabaseHelper.resetForTesting();
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'nusafit.db');
    await deleteDatabase(path);
  });

  late AuthRepository authRepo;

  setUp(() async {
    // Seed admin account before each test group
    final db = await DatabaseHelper.getDatabase();
    await AdminSeed().run(db);
    authRepo = AuthRepository(dbHelper: DatabaseHelper.instance);
  });

  group('AuthRepository', () {
    test('valid tofik/123 login returns success with user', () async {
      final result = await authRepo.login(username: 'tofik', password: '123');
      expect(result.status, equals(AuthStatus.success));
      expect(result.user, isNotNull);
      expect((result.user as dynamic).username, equals('tofik'));
    });

    test('wrong password returns invalidCredentials', () async {
      final result =
          await authRepo.login(username: 'tofik', password: 'wrong');
      expect(result.status, equals(AuthStatus.invalidCredentials));
      expect(result.safeMessage, equals('Username atau password salah.'));
    });

    test('unknown username returns invalidCredentials (same message)', () async {
      final result =
          await authRepo.login(username: 'nobody', password: '123');
      expect(result.status, equals(AuthStatus.invalidCredentials));
      expect(result.safeMessage, equals('Username atau password salah.'));
    });

    test('username with surrounding whitespace is sanitized before query', () async {
      final result =
          await authRepo.login(username: '  tofik  ', password: '123');
      expect(result.status, equals(AuthStatus.success));
    });

    test('SQL injection username attempt returns invalidCredentials', () async {
      final result = await authRepo.login(
          username: "' OR 1=1 --", password: '123');
      expect(result.status, equals(AuthStatus.invalidCredentials));
    });

    test('empty username returns invalidCredentials', () async {
      final result = await authRepo.login(username: '', password: '123');
      expect(result.status, equals(AuthStatus.invalidCredentials));
    });

    test('empty password returns invalidCredentials', () async {
      final result = await authRepo.login(username: 'tofik', password: '');
      expect(result.status, equals(AuthStatus.invalidCredentials));
    });

    test('inactive user returns inactiveUser', () async {
      // Mark tofik as inactive directly in DB
      final db = await DatabaseHelper.getDatabase();
      await db.update(
        'users',
        {'is_active': 0, 'updated_at': DateTime.now().toIso8601String()},
        where: 'username = ?',
        whereArgs: ['tofik'],
      );
      final result = await authRepo.login(username: 'tofik', password: '123');
      expect(result.status, equals(AuthStatus.inactiveUser));
      // Restore for other tests
      await db.update(
        'users',
        {'is_active': 1, 'updated_at': DateTime.now().toIso8601String()},
        where: 'username = ?',
        whereArgs: ['tofik'],
      );
    });

    test('findUserByUsername finds tofik', () async {
      final user = await authRepo.findUserByUsername('tofik');
      expect(user, isNotNull);
      expect(user!.username, equals('tofik'));
    });

    test('findUserByUsername returns null for unknown', () async {
      final user = await authRepo.findUserByUsername('nobody');
      expect(user, isNull);
    });

    test('findUserById returns correct user', () async {
      final user = await authRepo.findUserByUsername('tofik');
      final byId = await authRepo.findUserById(user!.id!);
      expect(byId, isNotNull);
      expect(byId!.username, equals('tofik'));
    });

    test('setBiometricEnabled sets flag to 1 then 0', () async {
      final user = await authRepo.findUserByUsername('tofik');
      await authRepo.setBiometricEnabled(userId: user!.id!, enabled: true);
      final after = await authRepo.findUserById(user.id!);
      expect(after!.biometricEnabled, isTrue);

      await authRepo.setBiometricEnabled(userId: user.id!, enabled: false);
      final restored = await authRepo.findUserById(user.id!);
      expect(restored!.biometricEnabled, isFalse);
    });

    test('findBiometricEnabledUser returns null when flag is 0', () async {
      final user = await authRepo.findUserByUsername('tofik');
      await authRepo.setBiometricEnabled(userId: user!.id!, enabled: false);
      final result = await authRepo.findBiometricEnabledUser();
      expect(result, isNull);
    });

    test('findBiometricEnabledUser returns user when flag is 1', () async {
      final user = await authRepo.findUserByUsername('tofik');
      await authRepo.setBiometricEnabled(userId: user!.id!, enabled: true);
      final result = await authRepo.findBiometricEnabledUser();
      expect(result, isNotNull);
      expect(result!.username, equals('tofik'));
      // Cleanup
      await authRepo.setBiometricEnabled(userId: user.id!, enabled: false);
    });

    test('disabled user excluded from findBiometricEnabledUser', () async {
      final user = await authRepo.findUserByUsername('tofik');
      // Make biometric enabled but inactive
      await authRepo.setBiometricEnabled(userId: user!.id!, enabled: true);
      final db = await DatabaseHelper.getDatabase();
      await db.update(
        'users',
        {'is_active': 0},
        where: 'username = ?',
        whereArgs: ['tofik'],
      );
      final result = await authRepo.findBiometricEnabledUser();
      expect(result, isNull);
      // Restore
      await db.update(
        'users',
        {'is_active': 1},
        where: 'username = ?',
        whereArgs: ['tofik'],
      );
      await authRepo.setBiometricEnabled(userId: user.id!, enabled: false);
    });
  });
}
