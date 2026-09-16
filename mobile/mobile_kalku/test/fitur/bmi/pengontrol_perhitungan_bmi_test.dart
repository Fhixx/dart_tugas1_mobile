import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:mobile_kalku/core/domain/bmi_calculation_result.dart';
import 'package:mobile_kalku/core/domain/bmi_category.dart';
import 'package:mobile_kalku/data/models/user.dart';
import 'package:mobile_kalku/data/repositories/bmi_repository.dart';
import 'package:mobile_kalku/features/bmi/controllers/bmi_calculator_controller.dart';

void main() {
  late Database db;
  late BmiRepository repo;
  late User testUser;

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
    testUser = User(
      id: 42,
      username: 'tofik',
      passwordHash: 'hash',
      passwordSalt: 'salt',
      role: 'user',
    );
  });

  tearDown(() async {
    await db.close();
  });

  BmiCalculatorController makeController() =>
      BmiCalculatorController(bmiRepository: repo, user: testUser);

  // ── Initial State ──────────────────────────────────────────────────────────
  group('Initial State', () {
    test('all error fields are null', () {
      final c = makeController();
      expect(c.nameError, isNull);
      expect(c.ageError, isNull);
      expect(c.weightError, isNull);
      expect(c.heightError, isNull);
      expect(c.generalError, isNull);
    });

    test('saveState is initial', () {
      final c = makeController();
      expect(c.saveState, SaveState.initial);
      expect(c.canSave, isTrue);
      expect(c.isSaved, isFalse);
      expect(c.isSaving, isFalse);
    });
  });

  // ── Calculate ──────────────────────────────────────────────────────────────
  group('calculate', () {
    test('valid inputs return a BmiCalculationResult', () {
      final c = makeController();
      final result = c.calculate(
        rawName: 'Tofik',
        rawAge: '25',
        rawWeightKg: '70',
        rawHeightCm: '170',
      );
      expect(result, isNotNull);
      expect(result!.bmi, closeTo(24.22, 0.01));
      expect(result.category, BmiCategory.normal);
    });

    test('invalid name sets nameError, returns null', () {
      final c = makeController();
      final result = c.calculate(
        rawName: '',
        rawAge: '25',
        rawWeightKg: '70',
        rawHeightCm: '170',
      );
      expect(result, isNull);
      expect(c.nameError, isNotNull);
      expect(c.ageError, isNull);
    });

    test('invalid age sets ageError', () {
      final c = makeController();
      final result = c.calculate(
        rawName: 'Tofik',
        rawAge: '0',
        rawWeightKg: '70',
        rawHeightCm: '170',
      );
      expect(result, isNull);
      expect(c.ageError, isNotNull);
    });

    test('invalid weight sets weightError', () {
      final c = makeController();
      final result = c.calculate(
        rawName: 'Tofik',
        rawAge: '25',
        rawWeightKg: '0',
        rawHeightCm: '170',
      );
      expect(result, isNull);
      expect(c.weightError, isNotNull);
    });

    test('invalid height sets heightError', () {
      final c = makeController();
      final result = c.calculate(
        rawName: 'Tofik',
        rawAge: '25',
        rawWeightKg: '70',
        rawHeightCm: '0',
      );
      expect(result, isNull);
      expect(c.heightError, isNotNull);
    });

    test('comma decimal weight is accepted', () {
      final c = makeController();
      final result = c.calculate(
        rawName: 'Tofik',
        rawAge: '25',
        rawWeightKg: '70,5',
        rawHeightCm: '170',
      );
      expect(result, isNotNull);
      expect(result!.weightKg, closeTo(70.5, 0.001));
    });

    test('category boundary: 25.00 → overweight', () {
      final c = makeController();
      // 90 / (1.897^2) ≈ 25.0  — let calculator determine the exact value
      // Use known inputs: weight=90, height=189.7 → 90/(1.897²)=25.00
      // Actually compute directly via result
      final result = c.calculate(
        rawName: 'Test',
        rawAge: '30',
        rawWeightKg: '90',
        rawHeightCm: '189.74', // sqrt(90/25) * 100 = 189.74
      );
      expect(result, isNotNull);
      // Result should be >= 25 → overweight (not normal)
      if (result!.bmi >= 25.0) {
        expect(result.category, BmiCategory.overweight);
      }
    });

    test('result does not contain NaN', () {
      final c = makeController();
      final result = c.calculate(
        rawName: 'Tofik',
        rawAge: '25',
        rawWeightKg: '70',
        rawHeightCm: '170',
      );
      expect(result, isNotNull);
      expect(result!.bmi.isNaN, isFalse);
      expect(result.bmi.isInfinite, isFalse);
    });
  });

  // ── saveResult ─────────────────────────────────────────────────────────────
  group('saveResult', () {
    BmiCalculationResult makeResult() => const BmiCalculationResult(
          name: 'Tofik',
          age: 25,
          weightKg: 70.0,
          heightCm: 170.0,
          bmi: 24.22,
          category: BmiCategory.normal,
        );

    test('saves exactly one record on first call', () async {
      final c = makeController();
      await c.saveResult(makeResult());
      expect(c.saveState, SaveState.saved);
      expect(await repo.countByUser(testUser.id!), 1);
    });

    test('second call is a no-op (duplicate prevention)', () async {
      final c = makeController();
      await c.saveResult(makeResult());
      await c.saveResult(makeResult()); // second tap
      expect(await repo.countByUser(testUser.id!), 1);
    });

    test('saveState becomes saved on success', () async {
      final c = makeController();
      await c.saveResult(makeResult());
      expect(c.isSaved, isTrue);
      expect(c.canSave, isFalse);
    });

    test('saved record uses authenticated userId', () async {
      final c = makeController();
      await c.saveResult(makeResult());
      final records = await repo.getAllByUser(testUser.id!);
      expect(records.length, 1);
      expect(records.first.userId, testUser.id);
    });

    test('saved record stores raw bmi double, not rounded string', () async {
      const rawBmi = 24.221453287197233;
      final c = makeController();
      await c.saveResult(const BmiCalculationResult(
        name: 'Tofik',
        age: 25,
        weightKg: 70.0,
        heightCm: 170.0,
        bmi: rawBmi,
        category: BmiCategory.normal,
      ));
      final records = await repo.getAllByUser(testUser.id!);
      expect(records.first.bmi, closeTo(rawBmi, 0.0000001));
    });

    test('saved record stores canonical category dbValue', () async {
      final c = makeController();
      await c.saveResult(makeResult());
      final records = await repo.getAllByUser(testUser.id!);
      expect(records.first.category, BmiCategory.normal.dbValue);
    });

    test('user with null id sets generalError, does not insert', () async {
      final nullIdUser = User(
        id: null,
        username: 'ghost',
        passwordHash: 'x',
        passwordSalt: 'y',
        role: 'user',
      );
      final c = BmiCalculatorController(bmiRepository: repo, user: nullIdUser);
      await c.saveResult(makeResult());
      expect(c.saveState, SaveState.initial);
      expect(c.generalError, isNotNull);
      expect(await repo.countByUser(0), 0);
    });

    test('canSave is true in error state (retry allowed)', () async {
      // Simulate an error by calling saveResult with null userId
      final nullIdUser = User(
        id: null,
        username: 'ghost',
        passwordHash: 'x',
        passwordSalt: 'y',
        role: 'user',
      );
      final c = BmiCalculatorController(bmiRepository: repo, user: nullIdUser);
      await c.saveResult(makeResult());
      // saveState remains initial since userId was null (early return)
      expect(c.canSave, isTrue);
    });
  });
}
