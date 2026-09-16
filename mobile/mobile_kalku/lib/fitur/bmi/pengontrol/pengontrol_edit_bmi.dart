import 'package:flutter/foundation.dart';
import '../../../inti/domain/perhitungan_bmi.dart';
import '../../../data/model/catatan_bmi.dart';
import '../../../data/repositori/repositori_bmi.dart';

/// Save state for the BMI edit process.
enum EditSaveState {
  initial,
  saving,
  saved,
  error,
}

/// Controller managing the edit lifecycle of an existing [BmiRecord].
///
/// Recalculates BMI and category upon save to ensure integrity.
/// Preserves [BmiRecord.id], [BmiRecord.userId], and [BmiRecord.createdAt].
/// Updates [BmiRecord.updatedAt] with a fresh UTC timestamp.
class BmiEditController extends ChangeNotifier {
  final BmiRepository _bmiRepository;
  final BmiCalculator _calculator;
  final BmiRecord _originalRecord;

  BmiEditController({
    required BmiRepository bmiRepository,
    required BmiRecord originalRecord,
    BmiCalculator? calculator,
  })  : _bmiRepository = bmiRepository,
        _originalRecord = originalRecord,
        _calculator = calculator ?? const BmiCalculator();

  BmiRecord get originalRecord => _originalRecord;

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
  EditSaveState _saveState = EditSaveState.initial;
  EditSaveState get saveState => _saveState;

  bool get isSaving => _saveState == EditSaveState.saving;
  bool get isSaved => _saveState == EditSaveState.saved;
  bool get canSave => _saveState == EditSaveState.initial || _saveState == EditSaveState.error;

  /// Recalculates and updates the record in SQLite.
  ///
  /// Returns `true` if update succeeds, `false` otherwise.
  Future<bool> updateRecord({
    required String rawName,
    required String rawAge,
    required String rawWeightKg,
    required String rawHeightCm,
  }) async {
    if (!canSave) return false;

    _clearErrors();

    try {
      // Validate & compute new BMI + category
      final calculation = _calculator.calculate(
        rawName: rawName,
        rawAge: rawAge,
        rawWeightKg: rawWeightKg,
        rawHeightCm: rawHeightCm,
      );

      _saveState = EditSaveState.saving;
      notifyListeners();

      final now = DateTime.now().toUtc();
      final updatedRecord = _originalRecord.copyWith(
        name: calculation.name,
        age: calculation.age,
        weightKg: calculation.weightKg,
        heightCm: calculation.heightCm,
        bmi: calculation.bmi, // raw double
        category: calculation.category.dbValue,
        // Preserve original createdAt, update updatedAt
        createdAt: _originalRecord.createdAt,
        updatedAt: now,
      );

      final affected = await _bmiRepository.update(updatedRecord);
      if (affected > 0) {
        _saveState = EditSaveState.saved;
        notifyListeners();
        return true;
      } else {
        _saveState = EditSaveState.error;
        _generalError = 'Data tidak ditemukan atau tidak dapat diperbarui.';
        notifyListeners();
        return false;
      }
    } on BmiValidationException catch (e) {
      _mapValidationError(e.message);
      _saveState = EditSaveState.initial;
      notifyListeners();
      return false;
    } catch (e) {
      _saveState = EditSaveState.error;
      _generalError = 'Gagal menyimpan perubahan. Silakan coba lagi.';
      notifyListeners();
      return false;
    }
  }

  void _clearErrors() {
    _nameError = null;
    _ageError = null;
    _weightError = null;
    _heightError = null;
    _generalError = null;
  }

  void _mapValidationError(String message) {
    final lower = message.toLowerCase();
    if (lower.contains('name') || lower.contains('nama')) {
      _nameError = message;
    } else if (lower.contains('age') || lower.contains('umur') || lower.contains('whole')) {
      _ageError = message;
    } else if (lower.contains('weight') || lower.contains('berat')) {
      _weightError = message;
    } else if (lower.contains('height') || lower.contains('tinggi')) {
      _heightError = message;
    } else {
      _generalError = message;
    }
  }
}
