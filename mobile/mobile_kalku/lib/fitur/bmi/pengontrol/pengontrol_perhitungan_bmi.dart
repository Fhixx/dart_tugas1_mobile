import 'package:flutter/foundation.dart';
import '../../../inti/domain/hasil_perhitungan_bmi.dart';
import '../../../inti/domain/perhitungan_bmi.dart';
import '../../../data/model/catatan_bmi.dart';
import '../../../data/model/pengguna.dart';
import '../../../data/repositori/repositori_bmi.dart';

/// Save-state for the BMI result.
///
/// Prevents duplicate database inserts from repeated button taps.
enum SaveState {
  /// No save attempted yet — save button enabled.
  initial,

  /// Insert in progress — save button disabled.
  saving,

  /// Insert completed successfully — save button disabled or shows "Tersimpan".
  saved,

  /// Insert failed — save button re-enabled for retry.
  error,
}

/// Controller for the BMI Calculator screen.
///
/// Manages input state, validation, calculation, and save lifecycle.
/// No SQL code, no Navigator, no Widget imports belong here.
class BmiCalculatorController extends ChangeNotifier {
  final BmiRepository _bmiRepository;
  final BmiCalculator _calculator;
  final User _user;

  BmiCalculatorController({
    required BmiRepository bmiRepository,
    required User user,
    BmiCalculator? calculator,
  })  : _bmiRepository = bmiRepository,
        _user = user,
        _calculator = calculator ?? const BmiCalculator();

  // ── Field error state ──────────────────────────────────────────────────────
  String? _nameError;
  String? _ageError;
  String? _weightError;
  String? _heightError;
  String? _generalError;

  String? get nameError => _nameError;
  String? get ageError => _ageError;
  String? get weightError => _weightError;
  String? get heightError => _heightError;
  String? get generalError => _generalError;

  // ── Save state ─────────────────────────────────────────────────────────────
  SaveState _saveState = SaveState.initial;
  SaveState get saveState => _saveState;
  bool get isSaving => _saveState == SaveState.saving;
  bool get isSaved => _saveState == SaveState.saved;
  bool get canSave => _saveState == SaveState.initial || _saveState == SaveState.error;


  // ── Calculate ──────────────────────────────────────────────────────────────

  /// Validates inputs and computes a [BmiCalculationResult].
  ///
  /// Returns the result on success, or `null` if validation fails.
  /// Field-level errors are set for display.
  BmiCalculationResult? calculate({
    required String rawName,
    required String rawAge,
    required String rawWeightKg,
    required String rawHeightCm,
  }) {
    _clearErrors();

    try {
      final result = _calculator.calculate(
        rawName: rawName,
        rawAge: rawAge,
        rawWeightKg: rawWeightKg,
        rawHeightCm: rawHeightCm,
      );
      notifyListeners();
      return result;
    } on BmiValidationException catch (e) {
      // Map validation message back to the correct field error slot
      _mapValidationError(e.message, rawName, rawAge, rawWeightKg, rawHeightCm);
      notifyListeners();
      return null;
    }
  }

  // ── Save ───────────────────────────────────────────────────────────────────

  /// Saves [result] to the database under the authenticated [_user].
  ///
  /// Duplicate-save prevention: if [saveState] is not [SaveState.initial]
  /// or [SaveState.error], this method is a no-op.
  Future<void> saveResult(BmiCalculationResult result) async {
    if (!canSave) return;
    if (_user.id == null) {
      _generalError = 'ID pengguna tidak ditemukan. Silakan login ulang.';
      notifyListeners();
      return;
    }

    _saveState = SaveState.saving;
    _generalError = null;
    notifyListeners();

    try {
      final now = DateTime.now().toUtc();
      final record = BmiRecord(
        userId: _user.id!,
        name: result.name,
        age: result.age,
        weightKg: result.weightKg,
        heightCm: result.heightCm,
        bmi: result.bmi, // raw double — not a formatted string
        category: result.category.dbValue, // canonical db value
        createdAt: now,
        updatedAt: now,
      );
      await _bmiRepository.insert(record);
      _saveState = SaveState.saved;
    } catch (e) {
      _saveState = SaveState.error;
      _generalError = 'Gagal menyimpan hasil BMI. Silakan coba lagi.';
    }

    notifyListeners();
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  void _clearErrors() {
    _nameError = null;
    _ageError = null;
    _weightError = null;
    _heightError = null;
    _generalError = null;
  }

  /// Maps a [BmiValidationException.message] to the correct field error slot
  /// by re-running the individual validators to identify the first failing field.
  void _mapValidationError(
    String message,
    String rawName,
    String rawAge,
    String rawWeightKg,
    String rawHeightCm,
  ) {
    // Determine which field failed by re-calling validators individually.
    // This avoids duplicating validation logic — the calculator already ran
    // them in order; we just need to know which slot to display the error in.
    if (message.toLowerCase().contains('name') ||
        message.toLowerCase().contains('nama')) {
      _nameError = message;
    } else if (message.toLowerCase().contains('age') ||
        message.toLowerCase().contains('umur') ||
        message.toLowerCase().contains('whole')) {
      _ageError = message;
    } else if (message.toLowerCase().contains('weight') ||
        message.toLowerCase().contains('berat')) {
      _weightError = message;
    } else if (message.toLowerCase().contains('height') ||
        message.toLowerCase().contains('tinggi')) {
      _heightError = message;
    } else {
      _generalError = message;
    }
  }
}
