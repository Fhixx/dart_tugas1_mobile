import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:mobile_kalku/inti/basis_data/pengelola_basis_data.dart';
import 'package:mobile_kalku/inti/domain/kategori_bmi.dart';
import 'package:mobile_kalku/data/model/catatan_bmi.dart';
import 'package:mobile_kalku/data/repositori/repositori_bmi.dart';
import 'package:mobile_kalku/fitur/bmi/pengontrol/pengontrol_edit_bmi.dart';

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
              updated_at TEXT NOT NULL
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
    String name = 'Original Name',
    int age = 25,
    double weightKg = 70.0,
    double heightCm = 170.0,
    double bmi = 24.221453287197233,
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

  group('BmiEditController Validation', () {
    test('initializes with original record', () {
      final record = makeRecord(id: 42);
      final controller = BmiEditController(
        bmiRepository: repo,
        originalRecord: record,
      );

      expect(controller.originalRecord.id, 42);
      expect(controller.saveState, EditSaveState.initial);
      expect(controller.canSave, isTrue);
      expect(controller.isSaving, isFalse);
    });

    test('rejects invalid name (empty / too short)', () async {
      final record = makeRecord(id: 1);
      final controller = BmiEditController(
        bmiRepository: repo,
        originalRecord: record,
      );

      final success = await controller.updateRecord(
        rawName: ' ',
        rawAge: '25',
        rawWeightKg: '70',
        rawHeightCm: '170',
      );

      expect(success, isFalse);
      expect(controller.nameError, isNotNull);
      expect(controller.saveState, EditSaveState.initial);
    });

    test('rejects invalid age (decimal or out of bounds)', () async {
      final record = makeRecord(id: 1);
      final controller = BmiEditController(
        bmiRepository: repo,
        originalRecord: record,
      );

      final decimalAge = await controller.updateRecord(
        rawName: 'Valid Name',
        rawAge: '25.5',
        rawWeightKg: '70',
        rawHeightCm: '170',
      );
      expect(decimalAge, isFalse);
      expect(controller.ageError, isNotNull);

      final excessiveAge = await controller.updateRecord(
        rawName: 'Valid Name',
        rawAge: '350',
        rawWeightKg: '70',
        rawHeightCm: '170',
      );
      expect(excessiveAge, isFalse);
      expect(controller.ageError, isNotNull);
    });

    test('rejects invalid weight (<= 0 or > 1000)', () async {
      final record = makeRecord(id: 1);
      final controller = BmiEditController(
        bmiRepository: repo,
        originalRecord: record,
      );

      final zeroWeight = await controller.updateRecord(
        rawName: 'Valid Name',
        rawAge: '25',
        rawWeightKg: '0',
        rawHeightCm: '170',
      );
      expect(zeroWeight, isFalse);
      expect(controller.weightError, isNotNull);

      final excessiveWeight = await controller.updateRecord(
        rawName: 'Valid Name',
        rawAge: '25',
        rawWeightKg: '1500',
        rawHeightCm: '170',
      );
      expect(excessiveWeight, isFalse);
      expect(controller.weightError, isNotNull);
    });

    test('rejects invalid height (<= 0 or > 400)', () async {
      final record = makeRecord(id: 1);
      final controller = BmiEditController(
        bmiRepository: repo,
        originalRecord: record,
      );

      final zeroHeight = await controller.updateRecord(
        rawName: 'Valid Name',
        rawAge: '25',
        rawWeightKg: '70',
        rawHeightCm: '0',
      );
      expect(zeroHeight, isFalse);
      expect(controller.heightError, isNotNull);

      final excessiveHeight = await controller.updateRecord(
        rawName: 'Valid Name',
        rawAge: '25',
        rawWeightKg: '70',
        rawHeightCm: '450',
      );
      expect(excessiveHeight, isFalse);
      expect(controller.heightError, isNotNull);
    });
  });

  group('BmiEditController Update & Recalculation', () {
    test('updates fields and recalculates BMI & category (normal -> overweight)', () async {
      final initialId = await repo.insert(makeRecord(
        weightKg: 70.0,
        heightCm: 170.0,
        bmi: 24.22,
        category: BmiCategory.normal.dbValue,
      ));
      final record = (await repo.getById(id: initialId, userId: 1))!;

      final controller = BmiEditController(
        bmiRepository: repo,
        originalRecord: record,
      );

      // 75kg / (1.70m)^2 = 25.951557... -> Overweight ('Gemuk')
      final success = await controller.updateRecord(
        rawName: 'New Name',
        rawAge: '30',
        rawWeightKg: '75',
        rawHeightCm: '170',
      );

      expect(success, isTrue);
      expect(controller.saveState, EditSaveState.saved);

      final updated = (await repo.getById(id: initialId, userId: 1))!;
      expect(updated.name, 'New Name');
      expect(updated.age, 30);
      expect(updated.weightKg, 75.0);
      expect(updated.heightCm, 170.0);
      expect(updated.bmi, closeTo(25.95, 0.01));
      expect(updated.category, BmiCategory.overweight.dbValue);
      expect(updated.category, 'Gemuk');
    });

    test('category transition: overweight -> normal', () async {
      final initialId = await repo.insert(makeRecord(
        weightKg: 80.0,
        heightCm: 170.0,
        bmi: 27.68,
        category: BmiCategory.overweight.dbValue,
      ));
      final record = (await repo.getById(id: initialId, userId: 1))!;

      final controller = BmiEditController(
        bmiRepository: repo,
        originalRecord: record,
      );

      // 65kg / (1.70m)^2 = 22.4913... -> Normal
      final success = await controller.updateRecord(
        rawName: 'Trimmed Name',
        rawAge: '28',
        rawWeightKg: '65',
        rawHeightCm: '170',
      );

      expect(success, isTrue);
      final updated = (await repo.getById(id: initialId, userId: 1))!;
      expect(updated.bmi, closeTo(22.49, 0.01));
      expect(updated.category, BmiCategory.normal.dbValue);
      expect(updated.category, 'Normal');
    });

    test('category transition: normal -> obesity', () async {
      final initialId = await repo.insert(makeRecord(
        weightKg: 68.0,
        heightCm: 170.0,
        bmi: 23.53,
        category: BmiCategory.normal.dbValue,
      ));
      final record = (await repo.getById(id: initialId, userId: 1))!;

      final controller = BmiEditController(
        bmiRepository: repo,
        originalRecord: record,
      );

      // 95kg / (1.70m)^2 = 32.8719... -> Obesity ('Obesitas')
      final success = await controller.updateRecord(
        rawName: 'Heavier',
        rawAge: '25',
        rawWeightKg: '95',
        rawHeightCm: '170',
      );

      expect(success, isTrue);
      final updated = (await repo.getById(id: initialId, userId: 1))!;
      expect(updated.bmi, closeTo(32.87, 0.01));
      expect(updated.category, BmiCategory.obesity.dbValue);
      expect(updated.category, 'Obesitas');
    });

    test('preserves createdAt and updates updatedAt to new UTC timestamp', () async {
      final originalCreatedAt = DateTime.utc(2025, 5, 1, 10, 0, 0);
      final originalUpdatedAt = DateTime.utc(2025, 5, 1, 10, 0, 0);
      final initialId = await repo.insert(makeRecord(
        createdAt: originalCreatedAt,
        updatedAt: originalUpdatedAt,
      ));
      final record = (await repo.getById(id: initialId, userId: 1))!;

      final controller = BmiEditController(
        bmiRepository: repo,
        originalRecord: record,
      );

      final beforeUpdate = DateTime.now().toUtc().subtract(const Duration(seconds: 1));
      await controller.updateRecord(
        rawName: 'Updated Name',
        rawAge: '26',
        rawWeightKg: '72',
        rawHeightCm: '172',
      );
      final afterUpdate = DateTime.now().toUtc().add(const Duration(seconds: 1));

      final updated = (await repo.getById(id: initialId, userId: 1))!;
      expect(updated.createdAt, originalCreatedAt);
      expect(updated.updatedAt.isAfter(beforeUpdate), isTrue);
      expect(updated.updatedAt.isBefore(afterUpdate), isTrue);
      expect(updated.userId, record.userId);
      expect(updated.id, record.id);
    });

    test('prevents double submission while isSaving or saved', () async {
      final initialId = await repo.insert(makeRecord());
      final record = (await repo.getById(id: initialId, userId: 1))!;

      final controller = BmiEditController(
        bmiRepository: repo,
        originalRecord: record,
      );

      final firstSuccess = await controller.updateRecord(
        rawName: 'First Submission',
        rawAge: '26',
        rawWeightKg: '70',
        rawHeightCm: '170',
      );
      expect(firstSuccess, isTrue);
      expect(controller.isSaved, isTrue);
      expect(controller.canSave, isFalse);

      // Second call must be rejected (no-op)
      final secondSuccess = await controller.updateRecord(
        rawName: 'Second Submission',
        rawAge: '27',
        rawWeightKg: '71',
        rawHeightCm: '171',
      );
      expect(secondSuccess, isFalse);

      final fetched = (await repo.getById(id: initialId, userId: 1))!;
      expect(fetched.name, 'First Submission');
    });
  });
}
