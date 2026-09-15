import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:mobile_kalku/core/database/database_helper.dart';
import 'package:mobile_kalku/core/domain/bmi_category.dart';
import 'package:mobile_kalku/data/models/bmi_record.dart';
import 'package:mobile_kalku/data/repositories/bmi_repository.dart';

void main() {
  late Database db;
  late BmiRepository repo;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    db = await databaseFactoryFfi.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: (db, version) async {
          await db.execute('PRAGMA foreign_keys = ON');
          await db.execute('''
            CREATE TABLE IF NOT EXISTS users (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              username TEXT NOT NULL UNIQUE,
              password_hash TEXT NOT NULL,
              password_salt TEXT NOT NULL,
              role TEXT NOT NULL DEFAULT 'user',
              biometric_enabled INTEGER NOT NULL DEFAULT 0,
              is_active INTEGER NOT NULL DEFAULT 1,
              created_at TEXT NOT NULL,
              updated_at TEXT NOT NULL
            )
          ''');
          await db.execute('''
            CREATE TABLE IF NOT EXISTS bmi_records (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              user_id INTEGER NOT NULL,
              name TEXT NOT NULL,
              age INTEGER NOT NULL,
              weight_kg REAL NOT NULL,
              height_cm REAL NOT NULL,
              bmi REAL NOT NULL,
              category TEXT NOT NULL,
              created_at TEXT NOT NULL,
              updated_at TEXT NOT NULL,
              FOREIGN KEY (user_id) REFERENCES users(id)
            )
          ''');
        },
      ),
    );
    repo = BmiRepository(db);
  });

  tearDown(() async {
    await db.close();
    await DatabaseHelper.resetForTesting();
  });

  BmiRecord makeRecord({
    int? id,
    int userId = 1,
    String name = 'Tofik',
    int age = 25,
    double weightKg = 70.0,
    double heightCm = 170.0,
    double bmi = 24.22,
    String category = 'Normal',
    DateTime? createdAt,
    DateTime? updatedAt,
  }) =>
      BmiRecord(
        id: id,
        userId: userId,
        name: name,
        age: age,
        weightKg: weightKg,
        heightCm: heightCm,
        bmi: bmi,
        category: category,
        createdAt: createdAt ?? DateTime.utc(2026, 1, 1, 10, 0, 0),
        updatedAt: updatedAt ?? DateTime.utc(2026, 1, 1, 10, 0, 0),
      );

  // ── Insert ─────────────────────────────────────────────────────────────────
  group('insert', () {
    test('returns a positive row id', () async {
      final id = await repo.insert(makeRecord());
      expect(id, greaterThan(0));
    });

    test('inserted record is retrievable by id', () async {
      final id = await repo.insert(makeRecord(userId: 1, name: 'Alice'));
      final found = await repo.getById(id: id, userId: 1);
      expect(found, isNotNull);
      expect(found!.name, 'Alice');
    });

    test('raw bmi double is preserved (full precision)', () async {
      final rawBmi = 24.221453287197233;
      final id = await repo.insert(makeRecord(bmi: rawBmi));
      final found = await repo.getById(id: id, userId: 1);
      expect(found!.bmi, closeTo(rawBmi, 0.000001));
    });

    test('category text stored as canonical db value', () async {
      final id = await repo.insert(
        makeRecord(category: BmiCategory.underweight.dbValue),
      );
      final found = await repo.getById(id: id, userId: 1);
      expect(found!.category, BmiCategory.underweight.dbValue);
    });
  });

  // ── getAllByUser ────────────────────────────────────────────────────────────
  group('getAllByUser', () {
    test('returns empty list for user with no records', () async {
      final records = await repo.getAllByUser(99);
      expect(records, isEmpty);
    });

    test('returns all records for the user', () async {
      await repo.insert(makeRecord(userId: 1, name: 'A'));
      await repo.insert(makeRecord(userId: 1, name: 'B'));
      final records = await repo.getAllByUser(1);
      expect(records.length, 2);
    });

    test('does not return records belonging to another user', () async {
      await repo.insert(makeRecord(userId: 1, name: 'User1Record'));
      await repo.insert(makeRecord(userId: 2, name: 'User2Record'));
      final records = await repo.getAllByUser(1);
      expect(records.length, 1);
      expect(records.first.name, 'User1Record');
    });

    test('ordered newest first (created_at DESC)', () async {
      await repo.insert(makeRecord(
        userId: 1,
        name: 'Older',
        createdAt: DateTime.utc(2026, 1, 1),
      ));
      await repo.insert(makeRecord(
        userId: 1,
        name: 'Newer',
        createdAt: DateTime.utc(2026, 6, 1),
      ));
      final records = await repo.getAllByUser(1);
      expect(records.first.name, 'Newer');
      expect(records.last.name, 'Older');
    });
  });

  // ── getById ────────────────────────────────────────────────────────────────
  group('getById', () {
    test('returns null for non-existent id', () async {
      final result = await repo.getById(id: 9999, userId: 1);
      expect(result, isNull);
    });

    test('returns null when userId does not match (user isolation)', () async {
      final id = await repo.insert(makeRecord(userId: 1));
      final result = await repo.getById(id: id, userId: 2);
      expect(result, isNull);
    });

    test('returns record when id and userId match', () async {
      final id = await repo.insert(makeRecord(userId: 1, name: 'Correct'));
      final result = await repo.getById(id: id, userId: 1);
      expect(result, isNotNull);
      expect(result!.name, 'Correct');
    });
  });

  // ── update ─────────────────────────────────────────────────────────────────
  group('update', () {
    test('updates name and bmi correctly', () async {
      final id = await repo.insert(makeRecord(userId: 1, name: 'Old', bmi: 20.0));
      final original = await repo.getById(id: id, userId: 1);

      final updated = original!.copyWith(
        name: 'New',
        bmi: 25.5,
        category: BmiCategory.overweight.dbValue,
        updatedAt: DateTime.utc(2026, 9, 1),
      );
      final rows = await repo.update(updated);
      expect(rows, 1);

      final fetched = await repo.getById(id: id, userId: 1);
      expect(fetched!.name, 'New');
      expect(fetched.bmi, closeTo(25.5, 0.001));
      expect(fetched.category, BmiCategory.overweight.dbValue);
    });

    test('preserves createdAt on update', () async {
      final createdAt = DateTime.utc(2026, 1, 1, 10, 0, 0);
      final id = await repo.insert(makeRecord(userId: 1, createdAt: createdAt));
      final original = await repo.getById(id: id, userId: 1);
      final updated = original!.copyWith(
        name: 'Updated',
        updatedAt: DateTime.utc(2026, 9, 1),
      );
      await repo.update(updated);
      final fetched = await repo.getById(id: id, userId: 1);
      expect(fetched!.createdAt, createdAt);
    });

    test('wrong userId cannot update record (user isolation)', () async {
      final id = await repo.insert(makeRecord(userId: 1, name: 'Tofik'));
      final original = await repo.getById(id: id, userId: 1);
      // Forge a record claiming ownership by userId=2
      final malicious = original!.copyWith(userId: 2, name: 'Hacked');
      final rows = await repo.update(malicious);
      expect(rows, 0);
      // Original record is untouched
      final fetched = await repo.getById(id: id, userId: 1);
      expect(fetched!.name, 'Tofik');
    });

    test('updatedAt is stored after update', () async {
      final id = await repo.insert(makeRecord(userId: 1));
      final original = await repo.getById(id: id, userId: 1);
      final newUpdatedAt = DateTime.utc(2026, 12, 31);
      final updated = original!.copyWith(updatedAt: newUpdatedAt);
      await repo.update(updated);
      final fetched = await repo.getById(id: id, userId: 1);
      expect(fetched!.updatedAt, newUpdatedAt);
    });
  });

  // ── deleteById ─────────────────────────────────────────────────────────────
  group('deleteById', () {
    test('deletes existing record, returns 1', () async {
      final id = await repo.insert(makeRecord(userId: 1));
      final rows = await repo.deleteById(id: id, userId: 1);
      expect(rows, 1);
      final fetched = await repo.getById(id: id, userId: 1);
      expect(fetched, isNull);
    });

    test('returns 0 for non-existent id', () async {
      final rows = await repo.deleteById(id: 9999, userId: 1);
      expect(rows, 0);
    });

    test('wrong userId cannot delete record (user isolation)', () async {
      final id = await repo.insert(makeRecord(userId: 1));
      final rows = await repo.deleteById(id: id, userId: 2);
      expect(rows, 0);
      final fetched = await repo.getById(id: id, userId: 1);
      expect(fetched, isNotNull);
    });

    test('does not delete records of other users', () async {
      final id1 = await repo.insert(makeRecord(userId: 1, name: 'Keep'));
      await repo.insert(makeRecord(userId: 2, name: 'OtherUser'));
      await repo.deleteById(id: id1, userId: 1);
      final remaining = await repo.getAllByUser(2);
      expect(remaining.length, 1);
      expect(remaining.first.name, 'OtherUser');
    });
  });

  // ── countByUser ────────────────────────────────────────────────────────────
  group('countByUser', () {
    test('returns 0 for user with no records', () async {
      expect(await repo.countByUser(99), 0);
    });

    test('returns correct count', () async {
      await repo.insert(makeRecord(userId: 5));
      await repo.insert(makeRecord(userId: 5));
      expect(await repo.countByUser(5), 2);
    });

    test('count is scoped to user', () async {
      await repo.insert(makeRecord(userId: 1));
      await repo.insert(makeRecord(userId: 2));
      expect(await repo.countByUser(1), 1);
      expect(await repo.countByUser(2), 1);
    });
  });

  // ── Timestamps ─────────────────────────────────────────────────────────────
  group('Timestamps', () {
    test('createdAt and updatedAt are round-tripped as UTC', () async {
      final ts = DateTime.utc(2026, 5, 15, 12, 0, 0);
      final id = await repo.insert(makeRecord(userId: 1, createdAt: ts, updatedAt: ts));
      final fetched = await repo.getById(id: id, userId: 1);
      expect(fetched!.createdAt, ts);
      expect(fetched.updatedAt, ts);
    });
  });
}
