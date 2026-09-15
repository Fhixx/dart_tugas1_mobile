import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:mobile_kalku/core/database/database_helper.dart';
import 'package:path/path.dart' hide equals;

void main() {
  setUpAll(() {
    // Initialize FFI for tests outside of an emulator/device
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  tearDownAll(() async {
    // Clean up the DB file after tests
    await DatabaseHelper.resetForTesting();
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'nusa_fit.db');
    await deleteDatabase(path);
  });

  group('DatabaseHelper & Schema', () {
    test('users and bmi_records tables exist with correct schema', () async {
      final db = await DatabaseHelper.getDatabase();

      // Check tables
      final tables = await db.query('sqlite_master', where: 'type = ?', whereArgs: ['table']);
      final tableNames = tables.map((t) => t['name'] as String).toList();
      
      expect(tableNames, contains('users'));
      expect(tableNames, contains('bmi_records'));

      // Verify columns for users
      final userColumnsInfo = await db.rawQuery('PRAGMA table_info(users)');
      final userColumns = userColumnsInfo.map((c) => c['name'] as String).toList();
      expect(userColumns, containsAll(['id', 'username', 'password_hash', 'password_salt', 'role', 'biometric_enabled', 'is_active', 'created_at', 'updated_at']));

      // Verify columns for bmi_records
      final bmiColumnsInfo = await db.rawQuery('PRAGMA table_info(bmi_records)');
      final bmiColumns = bmiColumnsInfo.map((c) => c['name'] as String).toList();
      expect(bmiColumns, containsAll(['id', 'user_id', 'name', 'age', 'weight_kg', 'height_cm', 'bmi', 'category', 'created_at', 'updated_at']));
    });

    test('foreign key enforcement is ON and inserting invalid user_id fails', () async {
      final db = await DatabaseHelper.getDatabase();

      // Verify PRAGMA
      final pragmas = await db.rawQuery('PRAGMA foreign_keys');
      expect(pragmas.first.values.first, equals(1)); // 1 means ON

      // Attempt to insert a BMI record with a non-existent user_id
      try {
        await db.insert('bmi_records', {
          'user_id': 9999, // Does not exist
          'name': 'Test',
          'age': 25,
          'weight_kg': 70,
          'height_cm': 175,
          'bmi': 22.86,
          'category': 'Normal',
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        });
        fail('Should throw due to FOREIGN KEY constraint');
      } catch (e) {
        expect(e.toString().toLowerCase().contains('foreign key'), isTrue);
      }
    });
  });
}
