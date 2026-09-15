/// Typed enumeration of BMI categories per WHO classification.
///
/// Category boundaries (raw BMI double, not rounded):
///   UNDERWEIGHT : BMI < 18.5
///   NORMAL      : 18.5 <= BMI < 25.0
///   OVERWEIGHT  : 25.0 <= BMI < 30.0
///   OBESITY     : BMI >= 30.0
enum BmiCategory {
  underweight,
  normal,
  overweight,
  obesity;

  /// Returns the canonical TEXT string stored in the `bmi_records.category` column.
  String get dbValue {
    switch (this) {
      case BmiCategory.underweight:
        return 'Kurus';
      case BmiCategory.normal:
        return 'Normal';
      case BmiCategory.overweight:
        return 'Gemuk';
      case BmiCategory.obesity:
        return 'Obesitas';
    }
  }

  /// Human-readable label for UI display.
  String get label => dbValue;

  /// Classifies a raw BMI double into a [BmiCategory].
  ///
  /// Classification uses the raw value – never a rounded or formatted string.
  static BmiCategory fromBmi(double bmi) {
    if (bmi < 18.5) return BmiCategory.underweight;
    if (bmi < 25.0) return BmiCategory.normal;
    if (bmi < 30.0) return BmiCategory.overweight;
    return BmiCategory.obesity;
  }

  /// Parses a [BmiCategory] from a [dbValue] string (for reading from SQLite).
  static BmiCategory fromDbValue(String value) {
    switch (value) {
      case 'Kurus':
        return BmiCategory.underweight;
      case 'Normal':
        return BmiCategory.normal;
      case 'Gemuk':
        return BmiCategory.overweight;
      case 'Obesitas':
        return BmiCategory.obesity;
      default:
        throw ArgumentError('Unknown BmiCategory db value: $value');
    }
  }
}
