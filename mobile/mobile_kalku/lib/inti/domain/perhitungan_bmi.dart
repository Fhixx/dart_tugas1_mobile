import '../utilitas/pembersih_input.dart';
import '../utilitas/validator_input.dart';
import 'hasil_perhitungan_bmi.dart';
import 'kategori_bmi.dart';

/// Pure-domain BMI calculator.
///
/// Validates raw string inputs (as received from UI text fields),
/// computes the BMI using the standard formula, and returns a typed
/// [BmiCalculationResult]. No SQLite code, no Navigator, no Widget
/// dependencies belong here.
///
/// Formula:
///   heightMeters = heightCm / 100
///   bmi = weightKg / (heightMeters * heightMeters)
class BmiCalculator {
  const BmiCalculator();

  /// Validates and calculates BMI from raw text-field strings.
  ///
  /// Returns a [BmiCalculationResult] on success.
  /// Throws [BmiValidationException] on any invalid input.
  ///
  /// All inputs are sanitized before parsing:
  ///   - name: trimmed and collapsed whitespace
  ///   - age: trimmed
  ///   - weight/height: Indonesian decimal comma replaced with dot
  BmiCalculationResult calculate({
    required String rawName,
    required String rawAge,
    required String rawWeightKg,
    required String rawHeightCm,
  }) {
    final nameError = Validators.validateName(rawName);
    if (nameError != null) throw BmiValidationException(nameError);

    final ageError = Validators.validateAge(rawAge);
    if (ageError != null) throw BmiValidationException(ageError);

    final weightError = Validators.validateWeight(rawWeightKg);
    if (weightError != null) throw BmiValidationException(weightError);

    final heightError = Validators.validateHeight(rawHeightCm);
    if (heightError != null) throw BmiValidationException(heightError);

    final name = Sanitizers.sanitizeName(rawName);
    final age = int.parse(rawAge.trim());
    final weightKg = double.parse(Sanitizers.sanitizeNumeric(rawWeightKg));
    final heightCm = double.parse(Sanitizers.sanitizeNumeric(rawHeightCm));

    final heightMeters = heightCm / 100.0;
    final bmi = weightKg / (heightMeters * heightMeters);

    // Safety guard: should never happen given validated inputs, but
    // defend against any edge-case floating-point pathology.
    if (bmi.isNaN || bmi.isInfinite) {
      throw const BmiValidationException('BMI calculation produced an invalid result.');
    }

    final category = BmiCategory.fromBmi(bmi);

    return BmiCalculationResult(
      name: name,
      age: age,
      weightKg: weightKg,
      heightCm: heightCm,
      bmi: bmi,
      category: category,
    );
  }
}

/// Exception thrown when BMI input validation fails.
class BmiValidationException implements Exception {
  final String message;
  const BmiValidationException(this.message);

  @override
  String toString() => 'BmiValidationException: $message';
}
