import 'kategori_bmi.dart';

/// Typed result object produced by [BmiCalculator.calculate].
///
/// Carries all input metadata together with the computed [bmi] double
/// and its typed [category]. The [bmi] field always holds full double
/// precision. Formatting to 2 decimal places is handled in the UI layer only.
class BmiCalculationResult {
  final String name;
  final int age;
  final double weightKg;
  final double heightCm;

  /// Raw calculated BMI value — full double precision.
  final double bmi;

  /// Typed category derived from [bmi]. Classification is based on the
  /// raw [bmi] value, never on a rounded display string.
  final BmiCategory category;

  const BmiCalculationResult({
    required this.name,
    required this.age,
    required this.weightKg,
    required this.heightCm,
    required this.bmi,
    required this.category,
  });

  /// Returns [bmi] formatted to 2 decimal places for display purposes only.
  String get bmiDisplay => bmi.toStringAsFixed(2);
}
