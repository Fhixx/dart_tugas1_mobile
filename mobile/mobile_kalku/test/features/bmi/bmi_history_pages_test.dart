import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:mobile_kalku/core/database/database_helper.dart';
import 'package:mobile_kalku/data/models/bmi_record.dart';
import 'package:mobile_kalku/data/models/user.dart';
import 'package:mobile_kalku/data/repositories/bmi_repository.dart';
import 'package:mobile_kalku/features/bmi/controllers/bmi_edit_controller.dart';
import 'package:mobile_kalku/features/bmi/controllers/bmi_history_controller.dart';
import 'package:mobile_kalku/features/bmi/pages/bmi_detail_page.dart';
import 'package:mobile_kalku/features/bmi/pages/bmi_edit_page.dart';
import 'package:mobile_kalku/features/bmi/pages/bmi_history_page.dart';

void main() {
  late Database db;
  late BmiRepository repo;

  final testUser = User(
    id: 1,
    username: 'tofik',
    passwordHash: 'hash',
    passwordSalt: 'salt',
    role: 'user',
  );

  final testRecord = BmiRecord(
    id: 10,
    userId: 1,
    name: 'Budi Santoso',
    age: 28,
    weightKg: 70.0,
    heightCm: 170.0,
    bmi: 24.22145,
    category: 'Normal',
    createdAt: DateTime.utc(2026, 3, 15, 8, 30, 0),
    updatedAt: DateTime.utc(2026, 3, 15, 8, 30, 0),
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

  Widget wrapWithMaterial(Widget child) {
    return MaterialApp(
      home: child,
    );
  }

  // ── Fake / Custom State Controller for Widget Tests ─────────────────────
  // Decouples widget rendering tests from native SQLite FFI async zone.
  // Real async SQLite operations are fully tested in bmi_history_controller_test.dart.

  group('BmiHistoryPage Widget Tests', () {
    testWidgets('shows loading indicator when controller is loading', (tester) async {
      final controller = _CustomStateHistoryController(
        bmiRepository: repo,
        user: testUser,
        state: HistoryState.loading,
      );

      await tester.pumpWidget(wrapWithMaterial(
        BmiHistoryPage(
          user: testUser,
          bmiRepository: repo,
          controller: controller,
        ),
      ));

      expect(find.byKey(const ValueKey('history_loading_indicator')), findsOneWidget);
    });

    testWidgets('shows empty state when no records exist', (tester) async {
      final controller = _CustomStateHistoryController(
        bmiRepository: repo,
        user: testUser,
        state: HistoryState.empty,
      );

      await tester.pumpWidget(wrapWithMaterial(
        BmiHistoryPage(
          user: testUser,
          bmiRepository: repo,
          controller: controller,
        ),
      ));
      await tester.pump();

      expect(find.byKey(const ValueKey('history_empty_text')), findsOneWidget);
      expect(find.text('Belum ada riwayat BMI'), findsOneWidget);
    });

    testWidgets('displays list of records with name, category, and 2-decimal BMI', (tester) async {
      final controller = _CustomStateHistoryController(
        bmiRepository: repo,
        user: testUser,
        state: HistoryState.success,
        records: [testRecord],
      );

      await tester.pumpWidget(wrapWithMaterial(
        BmiHistoryPage(
          user: testUser,
          bmiRepository: repo,
          controller: controller,
        ),
      ));
      await tester.pump();

      expect(find.text('Budi Santoso'), findsOneWidget);
      expect(find.text('24.22'), findsOneWidget);
      expect(find.textContaining('Normal'), findsOneWidget);
    });

    testWidgets('delete button opens confirmation dialog with Batal and Hapus', (tester) async {
      final controller = _CustomStateHistoryController(
        bmiRepository: repo,
        user: testUser,
        state: HistoryState.success,
        records: [testRecord],
      );

      await tester.pumpWidget(wrapWithMaterial(
        BmiHistoryPage(
          user: testUser,
          bmiRepository: repo,
          controller: controller,
        ),
      ));
      await tester.pump();

      final deleteBtn = find.byKey(ValueKey('delete_record_${testRecord.id}'));
      expect(deleteBtn, findsOneWidget);

      await tester.tap(deleteBtn);
      await tester.pumpAndSettle();

      expect(find.text('Hapus Data BMI?'), findsOneWidget);
      expect(find.text('Data yang dihapus tidak dapat dikembalikan.'), findsOneWidget);
      expect(find.byKey(const ValueKey('cancel_delete_button')), findsOneWidget);
      expect(find.byKey(const ValueKey('confirm_delete_button')), findsOneWidget);

      // Tap Batal (Cancel)
      await tester.tap(find.byKey(const ValueKey('cancel_delete_button')));
      await tester.pumpAndSettle();

      // Dialog closed and record still exists in UI
      expect(find.text('Hapus Data BMI?'), findsNothing);
      expect(find.text('Budi Santoso'), findsOneWidget);
    });

    testWidgets('shows error state with retry button', (tester) async {
      final controller = _CustomStateHistoryController(
        bmiRepository: repo,
        user: testUser,
        state: HistoryState.error,
        errorMessage: 'Gagal memuat riwayat BMI.',
      );

      await tester.pumpWidget(wrapWithMaterial(
        BmiHistoryPage(
          user: testUser,
          bmiRepository: repo,
          controller: controller,
        ),
      ));
      await tester.pump();

      expect(find.text('Gagal memuat riwayat BMI.'), findsOneWidget);
      expect(find.byKey(const ValueKey('retry_history_button')), findsOneWidget);
    });
  });

  // ── BmiDetailPage Widget Tests ─────────────────────────────────────────────
  group('BmiDetailPage Widget Tests', () {
    testWidgets('displays all required detail fields with 2-decimal BMI', (tester) async {
      await tester.pumpWidget(wrapWithMaterial(
        BmiDetailPage(
          record: testRecord,
        ),
      ));
      await tester.pump();

      expect(find.text('Budi Santoso'), findsOneWidget);
      expect(find.text('Normal'), findsOneWidget);
      expect(find.text('24.22'), findsOneWidget); // 2-decimal BMI
      expect(find.text('28 tahun'), findsOneWidget);
      expect(find.text('70.0 kg'), findsOneWidget);
      expect(find.text('170.0 cm'), findsOneWidget);
      expect(find.byKey(const ValueKey('detail_created_at')), findsOneWidget);
      expect(find.byKey(const ValueKey('detail_updated_at')), findsOneWidget);
    });

    test('user isolation: loading by ID with wrong user returns null', () async {
      final id = await repo.insert(testRecord);
      final result = await repo.getById(id: id, userId: 999);
      expect(result, isNull);
    });
  });

  // ── BmiEditPage Widget Tests ───────────────────────────────────────────────
  group('BmiEditPage Widget Tests', () {
    testWidgets('pre-fills editable fields and has NO direct editable BMI/category fields', (tester) async {
      await tester.pumpWidget(wrapWithMaterial(
        BmiEditPage(
          record: testRecord,
          bmiRepository: repo,
        ),
      ));
      await tester.pump();

      expect(find.byKey(const ValueKey('edit_name_field')), findsOneWidget);
      expect(find.byKey(const ValueKey('edit_age_field')), findsOneWidget);
      expect(find.byKey(const ValueKey('edit_weight_field')), findsOneWidget);
      expect(find.byKey(const ValueKey('edit_height_field')), findsOneWidget);

      final nameField = tester.widget<TextFormField>(find.byKey(const ValueKey('edit_name_field')));
      expect(nameField.controller?.text, 'Budi Santoso');

      final ageField = tester.widget<TextFormField>(find.byKey(const ValueKey('edit_age_field')));
      expect(ageField.controller?.text, '28');

      // Crucial verification: NO editable input for BMI or category
      expect(find.byKey(const ValueKey('edit_bmi_field')), findsNothing);
      expect(find.byKey(const ValueKey('edit_category_field')), findsNothing);
    });

    testWidgets('shows validation errors when invalid input is submitted', (tester) async {
      final controller = BmiEditController(
        bmiRepository: repo,
        originalRecord: testRecord,
      );

      await tester.pumpWidget(wrapWithMaterial(
        BmiEditPage(
          record: testRecord,
          bmiRepository: repo,
          controller: controller,
        ),
      ));
      await tester.pump();

      // Clear name
      await tester.enterText(find.byKey(const ValueKey('edit_name_field')), '');
      await tester.tap(find.byKey(const ValueKey('edit_save_button')));
      await tester.pump();

      expect(find.text('Name is required'), findsOneWidget);
    });
  });
}

class _CustomStateHistoryController extends BmiHistoryController {
  final HistoryState _customState;
  final List<BmiRecord> _customRecords;
  final String? _customErrorMessage;

  _CustomStateHistoryController({
    required super.bmiRepository,
    required super.user,
    required HistoryState state,
    List<BmiRecord> records = const [],
    String? errorMessage,
  })  : _customState = state,
        _customRecords = records,
        _customErrorMessage = errorMessage;

  @override
  HistoryState get state => _customState;

  @override
  bool get isLoading => _customState == HistoryState.loading;

  @override
  bool get isEmpty => _customState == HistoryState.empty;

  @override
  bool get isSuccess => _customState == HistoryState.success;

  @override
  bool get isError => _customState == HistoryState.error;

  @override
  List<BmiRecord> get records => _customRecords;

  @override
  String? get errorMessage => _customErrorMessage;

  @override
  Future<void> loadRecords() async {}

  @override
  Future<void> refresh() async {}
}

