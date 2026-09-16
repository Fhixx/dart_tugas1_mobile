import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:mobile_kalku/inti/basis_data/pengelola_basis_data.dart';
import 'package:mobile_kalku/inti/basis_data/data_awal_admin.dart';
import 'package:path/path.dart' hide equals;

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  tearDownAll(() async {
    await DatabaseHelper.resetForTesting();
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'nusa_fit.db');
    await deleteDatabase(path);
  });

  group('AdminSeed', () {
    test('first run creates one admin, second run does not duplicate or modify', () async {
      final db = await DatabaseHelper.getDatabase();
      final seed = AdminSeed();

      // First run
      await seed.run(db);

      var users = await db.query('users', where: 'username = ?', whereArgs: ['tofik']);
      expect(users.length, equals(1));
      
      final admin = users.first;
      expect(admin['role'], equals('admin'));
      expect(admin['biometric_enabled'], equals(0)); // 0 = false
      expect(admin['password_hash'], isNot(equals('123'))); // Should be hashed
      
      final firstHash = admin['password_hash'];
      final firstUpdatedAt = admin['updated_at'];

      // Second run (idempotency test)
      await seed.run(db);

      users = await db.query('users', where: 'username = ?', whereArgs: ['tofik']);
      expect(users.length, equals(1)); // Still exactly one

      final adminAfterSecondRun = users.first;
      // Existing admin is not modified
      expect(adminAfterSecondRun['password_hash'], equals(firstHash));
      expect(adminAfterSecondRun['updated_at'], equals(firstUpdatedAt));
    });
  });
}
