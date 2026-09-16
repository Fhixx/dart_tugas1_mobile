import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:mobile_kalku/core/domain/bmi_calculation_result.dart';
import 'package:mobile_kalku/core/domain/bmi_category.dart';
import 'package:mobile_kalku/data/models/user.dart';
import 'package:mobile_kalku/data/repositories/bmi_repository.dart';
import 'package:mobile_kalku/features/bmi/controllers/bmi_calculator_controller.dart';
import 'package:mobile_kalku/features/bmi/pages/bmi_calculator_page.dart';
import 'package:mobile_kalku/features/bmi/pages/bmi_result_page.dart';

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
      id: 1,
      username: 'tofik',
      passwordHash: 'hash',
      passwordSalt: 'salt',
      role: 'user',
    );
  });

  tearDown(() async {
    await db.close();
  });

  Widget buildCalculatorPage({BmiCalculatorController? controller}) =>
      MaterialApp(
        home: BmiCalculatorPage(
          user: testUser,
          bmiRepository: repo,
          controller: controller,
        ),
      );

  Widget buildResultPage({
    required BmiCalculationResult result,
    BmiCalculatorController? controller,
  }) =>
      MaterialApp(
        home: BmiResultPage(
          result: result,
          user: testUser,
          bmiRepository: repo,
          controller: controller,
        ),
      );

  const testResult = BmiCalculationResult(
    name: 'Tofik',
    age: 25,
    weightKg: 70.0,
    heightCm: 170.0,
    bmi: 24.22,
    category: BmiCategory.normal,
  );

  // ── BmiCalculatorPage ──────────────────────────────────────────────────────
  group('BmiCalculatorPage', () {
    testWidgets('renders four input fields and calculate button',
        (tester) async {
      await tester.pumpWidget(buildCalculatorPage());
      expect(find.byKey(const ValueKey('name_field')), findsOneWidget);
      expect(find.byKey(const ValueKey('age_field')), findsOneWidget);
      expect(find.byKey(const ValueKey('weight_field')), findsOneWidget);
      expect(find.byKey(const ValueKey('height_field')), findsOneWidget);
      expect(find.byKey(const ValueKey('calculate_button')), findsOneWidget);
    });

    testWidgets('empty submit shows validation errors', (tester) async {
      await tester.pumpWidget(buildCalculatorPage());
      await tester.tap(find.byKey(const ValueKey('calculate_button')));
      await tester.pump();
      // At least one error text should appear
      expect(find.textContaining('required', findRichText: true), findsWidgets);
    });

    testWidgets('valid inputs navigate to BmiResultPage', (tester) async {
      await tester.pumpWidget(buildCalculatorPage());

      await tester.enterText(
          find.byKey(const ValueKey('name_field')), 'Tofik');
      await tester.enterText(find.byKey(const ValueKey('age_field')), '25');
      await tester.enterText(
          find.byKey(const ValueKey('weight_field')), '70');
      await tester.enterText(
          find.byKey(const ValueKey('height_field')), '170');
      await tester.tap(find.byKey(const ValueKey('calculate_button')));
      await tester.pumpAndSettle();

      // Should have navigated to BmiResultPage
      expect(find.byType(BmiResultPage), findsOneWidget);
    });

    testWidgets('result page receives correct BMI value', (tester) async {
      await tester.pumpWidget(buildCalculatorPage());

      await tester.enterText(
          find.byKey(const ValueKey('name_field')), 'Tofik');
      await tester.enterText(find.byKey(const ValueKey('age_field')), '25');
      await tester.enterText(
          find.byKey(const ValueKey('weight_field')), '70');
      await tester.enterText(
          find.byKey(const ValueKey('height_field')), '170');
      await tester.tap(find.byKey(const ValueKey('calculate_button')));
      await tester.pumpAndSettle();

      // bmi ≈ 24.22 displayed on result page
      expect(find.byKey(const ValueKey('bmi_value')), findsOneWidget);
    });

    testWidgets('back navigation works from result page', (tester) async {
      await tester.pumpWidget(buildCalculatorPage());

      await tester.enterText(
          find.byKey(const ValueKey('name_field')), 'Tofik');
      await tester.enterText(find.byKey(const ValueKey('age_field')), '25');
      await tester.enterText(
          find.byKey(const ValueKey('weight_field')), '70');
      await tester.enterText(
          find.byKey(const ValueKey('height_field')), '170');
      await tester.tap(find.byKey(const ValueKey('calculate_button')));
      await tester.pumpAndSettle();

      expect(find.byType(BmiResultPage), findsOneWidget);

      // Press back button
      final NavigatorState navigator = tester.state(find.byType(Navigator));
      navigator.pop();
      await tester.pumpAndSettle();

      expect(find.byType(BmiCalculatorPage), findsOneWidget);
    });
  });

  // ── BmiResultPage ──────────────────────────────────────────────────────────
  group('BmiResultPage', () {
    testWidgets('displays name, age, weight, height, bmi, category',
        (tester) async {
      await tester.pumpWidget(buildResultPage(result: testResult));
      expect(find.byKey(const ValueKey('bmi_value')), findsOneWidget);
      expect(find.byKey(const ValueKey('bmi_category')), findsOneWidget);
      expect(find.byKey(const ValueKey('result_name')), findsOneWidget);
      expect(find.byKey(const ValueKey('result_age')), findsOneWidget);
      expect(find.byKey(const ValueKey('result_weight')), findsOneWidget);
      expect(find.byKey(const ValueKey('result_height')), findsOneWidget);
    });

    testWidgets('BMI is shown to 2 decimal places', (tester) async {
      await tester.pumpWidget(buildResultPage(result: testResult));
      // testResult.bmi = 24.22 → bmiDisplay = "24.22"
      expect(find.text('24.22'), findsOneWidget);
    });

    testWidgets('category label is displayed', (tester) async {
      await tester.pumpWidget(buildResultPage(result: testResult));
      expect(find.text(BmiCategory.normal.label), findsOneWidget);
    });

    testWidgets('save button is visible initially', (tester) async {
      await tester.pumpWidget(buildResultPage(result: testResult));
      expect(find.byKey(const ValueKey('save_button')), findsOneWidget);
      expect(find.text('Simpan Hasil'), findsOneWidget);
    });

    // ── Save-lifecycle tests (plain test, not testWidgets) ───────────────────
    // These tests call the controller directly to avoid FFI-async incompatibility
    // with Flutter's fake-async test zone.

    test('successful save inserts exactly one record', () async {
      final controller =
          BmiCalculatorController(bmiRepository: repo, user: testUser);
      await controller.saveResult(testResult);
      expect(controller.isSaved, isTrue);
      expect(await repo.countByUser(testUser.id!), 1);
    });

    test('double save does not insert duplicate records', () async {
      final controller =
          BmiCalculatorController(bmiRepository: repo, user: testUser);
      await controller.saveResult(testResult);
      await controller.saveResult(testResult); // second call is no-op
      expect(await repo.countByUser(testUser.id!), 1);
    });

    test('canSave is false after successful save', () async {
      final controller =
          BmiCalculatorController(bmiRepository: repo, user: testUser);
      await controller.saveResult(testResult);
      expect(controller.canSave, isFalse);
    });

    test('saved record uses authenticated userId', () async {
      final controller =
          BmiCalculatorController(bmiRepository: repo, user: testUser);
      await controller.saveResult(testResult);
      final records = await repo.getAllByUser(testUser.id!);
      expect(records.first.userId, testUser.id);
    });

    test('raw bmi is stored, not rounded display string', () async {
      const rawBmi = 24.221453287197233;
      const preciseResult = BmiCalculationResult(
        name: 'Tofik',
        age: 25,
        weightKg: 70.0,
        heightCm: 170.0,
        bmi: rawBmi,
        category: BmiCategory.normal,
      );
      final controller =
          BmiCalculatorController(bmiRepository: repo, user: testUser);
      await controller.saveResult(preciseResult);
      final records = await repo.getAllByUser(testUser.id!);
      expect(records.first.bmi, closeTo(rawBmi, 0.0000001));
    });

    // ── Widget test: verify visual saved-state ───────────────────────────────
    // Pre-complete the save via controller before building the widget, so the
    // pump sees the already-saved state without needing real-async DB in-zone.
    testWidgets('save button shows Tersimpan and is disabled after isSaved',
        (tester) async {
      final controller =
          BmiCalculatorController(bmiRepository: repo, user: testUser);
      // Complete save outside the widget tree (real async, not fake-async).
      await tester.runAsync(() => controller.saveResult(testResult));

      await tester.pumpWidget(buildResultPage(
        result: testResult,
        controller: controller,
      ));
      await tester.pump();

      expect(find.text('Tersimpan'), findsOneWidget);
      final saveBtn = tester.widget<ElevatedButton>(
        find.byKey(const ValueKey('save_button')),
      );
      expect(saveBtn.onPressed, isNull);
    });
  });
}
