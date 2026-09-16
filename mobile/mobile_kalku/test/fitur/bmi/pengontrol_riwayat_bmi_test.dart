import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:mobile_kalku/inti/basis_data/pengelola_basis_data.dart';
import 'package:mobile_kalku/data/model/catatan_bmi.dart';
import 'package:mobile_kalku/data/model/pengguna.dart';
import 'package:mobile_kalku/data/repositori/repositori_bmi.dart';
import 'package:mobile_kalku/fitur/bmi/pengontrol/pengontrol_riwayat_bmi.dart';

void main() {
  late Database db;
  late BmiRepository repo;

  final userA = User(
    id: 1,
    username: 'tofik',
    passwordHash: 'hash',
    passwordSalt: 'salt',
    role: 'user',
  );

  final userB = User(
    id: 2,
    username: 'other',
    passwordHash: 'hash',
    passwordSalt: 'salt',
    role: 'user',
  );

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
          await db.insert('users', {
            'id': 1,
            'username': 'tofik',
            'password_hash': 'hash',
            'password_salt': 'salt',
            'created_at': DateTime.now().toUtc().toIso8601String(),
            'updated_at': DateTime.now().toUtc().toIso8601String(),
          });
          await db.insert('users', {
            'id': 2,
            'username': 'other',
            'password_hash': 'hash',
            'password_salt': 'salt',
            'created_at': DateTime.now().toUtc().toIso8601String(),
            'updated_at': DateTime.now().toUtc().toIso8601String(),
          });
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
    required int userId,
    String name = 'Test User',
    int age = 25,
    double weightKg = 70.0,
    double heightCm = 170.0,
    double bmi = 24.22,
    String category = 'Normal',
    DateTime? createdAt,
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
        updatedAt: createdAt ?? DateTime.utc(2026, 1, 1, 10, 0, 0),
      );

  group('BmiHistoryController State Lifecycle', () {
    test('initial state is HistoryState.initial with empty records', () {
      final controller = BmiHistoryController(
        bmiRepository: repo,
        user: userA,
      );

      expect(controller.state, HistoryState.initial);
      expect(controller.records, isEmpty);
      expect(controller.errorMessage, isNull);
      expect(controller.isLoading, isFalse);
    });

    test('loadRecords transitions to HistoryState.empty when user has no records', () async {
      final controller = BmiHistoryController(
        bmiRepository: repo,
        user: userA,
      );

      await controller.loadRecords();

      expect(controller.state, HistoryState.empty);
      expect(controller.isEmpty, isTrue);
      expect(controller.records, isEmpty);
    });

    test('loadRecords transitions to HistoryState.success when user has records', () async {
      await repo.insert(makeRecord(userId: userA.id!, name: 'A'));
      final controller = BmiHistoryController(
        bmiRepository: repo,
        user: userA,
      );

      await controller.loadRecords();

      expect(controller.state, HistoryState.success);
      expect(controller.isSuccess, isTrue);
      expect(controller.records.length, 1);
      expect(controller.records.first.name, 'A');
    });

    test('refresh() reloads records from repository', () async {
      final controller = BmiHistoryController(
        bmiRepository: repo,
        user: userA,
      );
      await controller.loadRecords();
      expect(controller.isEmpty, isTrue);

      await repo.insert(makeRecord(userId: userA.id!, name: 'AddedLater'));
      await controller.refresh();

      expect(controller.isSuccess, isTrue);
      expect(controller.records.length, 1);
      expect(controller.records.first.name, 'AddedLater');
    });
  });

  group('Ordering & User Isolation', () {
    test('records are ordered newest first (created_at DESC)', () async {
      await repo.insert(makeRecord(
        userId: userA.id!,
        name: 'Older',
        createdAt: DateTime.utc(2026, 1, 1),
      ));
      await repo.insert(makeRecord(
        userId: userA.id!,
        name: 'Newer',
        createdAt: DateTime.utc(2026, 6, 1),
      ));

      final controller = BmiHistoryController(
        bmiRepository: repo,
        user: userA,
      );
      await controller.loadRecords();

      expect(controller.records.length, 2);
      expect(controller.records.first.name, 'Newer');
      expect(controller.records.last.name, 'Older');
    });

    test('User A cannot see User B records (strict isolation)', () async {
      await repo.insert(makeRecord(userId: userA.id!, name: 'User A Record'));
      await repo.insert(makeRecord(userId: userB.id!, name: 'User B Record'));

      final controllerA = BmiHistoryController(
        bmiRepository: repo,
        user: userA,
      );
      await controllerA.loadRecords();

      expect(controllerA.records.length, 1);
      expect(controllerA.records.first.name, 'User A Record');

      final controllerB = BmiHistoryController(
        bmiRepository: repo,
        user: userB,
      );
      await controllerB.loadRecords();

      expect(controllerB.records.length, 1);
      expect(controllerB.records.first.name, 'User B Record');
    });
  });

  group('Deletion & Scope', () {
    test('deleteRecord deletes owned record and transitions to empty if no more', () async {
      final id = await repo.insert(makeRecord(userId: userA.id!, name: 'ToDelete'));
      final controller = BmiHistoryController(
        bmiRepository: repo,
        user: userA,
      );
      await controller.loadRecords();
      expect(controller.records.length, 1);

      final deleted = await controller.deleteRecord(id);
      expect(deleted, isTrue);
      expect(controller.isEmpty, isTrue);
      expect(controller.records, isEmpty);
      expect(await repo.countByUser(userA.id!), 0);
    });

    test('User A cannot delete User B record', () async {
      final idB = await repo.insert(makeRecord(userId: userB.id!, name: 'User B Private'));
      final controllerA = BmiHistoryController(
        bmiRepository: repo,
        user: userA,
      );
      await controllerA.loadRecords();

      final deleted = await controllerA.deleteRecord(idB);
      expect(deleted, isFalse);

      // Record B remains untouched
      final remaining = await repo.getAllByUser(userB.id!);
      expect(remaining.length, 1);
      expect(remaining.first.name, 'User B Private');
    });

    test('deleting one record does not delete other records of same user', () async {
      final id1 = await repo.insert(makeRecord(userId: userA.id!, name: 'Keep'));
      final id2 = await repo.insert(makeRecord(userId: userA.id!, name: 'DeleteMe'));

      final controller = BmiHistoryController(
        bmiRepository: repo,
        user: userA,
      );
      await controller.loadRecords();
      expect(controller.records.length, 2);

      await controller.deleteRecord(id2);
      expect(controller.records.length, 1);
      expect(controller.records.first.id, id1);
      expect(await repo.countByUser(userA.id!), 1);
    });
  });
}
