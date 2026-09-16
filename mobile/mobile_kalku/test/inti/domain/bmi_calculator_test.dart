import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_kalku/inti/domain/perhitungan_bmi.dart';
import 'package:mobile_kalku/inti/domain/kategori_bmi.dart';
import 'package:mobile_kalku/inti/domain/hasil_perhitungan_bmi.dart';

void main() {
  const calc = BmiCalculator();

  // ── Helper ─────────────────────────────────────────────────────────────────
  BmiCalculationResult validCalc({
    String name = 'Tofik',
    String age = '25',
    String weight = '70',
    String height = '170',
  }) =>
      calc.calculate(
        rawName: name,
        rawAge: age,
        rawWeightKg: weight,
        rawHeightCm: height,
      );

  void expectThrows(void Function() fn, [String? containsMessage]) {
    try {
      fn();
      fail('Expected BmiValidationException');
    } on BmiValidationException catch (e) {
      if (containsMessage != null) {
        expect(e.message, contains(containsMessage));
      }
    }
  }

  // ── Formula ────────────────────────────────────────────────────────────────
  group('BMI Formula', () {
    test('known value: 70 kg / 1.7 m^2', () {
      final r = validCalc(weight: '70', height: '170');
      // 70 / (1.70 * 1.70) = 70 / 2.89 ≈ 24.2215
      expect(r.bmi, closeTo(24.2215, 0.001));
    });

    test('decimal weight (75.5 kg)', () {
      final r = validCalc(weight: '75.5', height: '175');
      final expected = 75.5 / (1.75 * 1.75);
      expect(r.bmi, closeTo(expected, 0.0001));
    });

    test('decimal height (172.5 cm)', () {
      final r = validCalc(weight: '60', height: '172.5');
      final expected = 60.0 / (1.725 * 1.725);
      expect(r.bmi, closeTo(expected, 0.0001));
    });

    test('Indonesian comma decimal weight (75,5)', () {
      final r = validCalc(weight: '75,5', height: '175');
      final expected = 75.5 / (1.75 * 1.75);
      expect(r.bmi, closeTo(expected, 0.0001));
    });

    test('Indonesian comma decimal height (172,5)', () {
      final r = validCalc(weight: '60', height: '172,5');
      final expected = 60.0 / (1.725 * 1.725);
      expect(r.bmi, closeTo(expected, 0.0001));
    });

    test('result carries all input metadata', () {
      final r = validCalc(name: 'Alice', age: '30', weight: '55', height: '160');
      expect(r.name, 'Alice');
      expect(r.age, 30);
      expect(r.weightKg, 55.0);
      expect(r.heightCm, 160.0);
    });
  });

  // ── Category Boundaries ────────────────────────────────────────────────────
  group('BMI Category Boundaries', () {
    BmiCategory cat(double bmi) => BmiCategory.fromBmi(bmi);

    test('18.49 → underweight', () {
      expect(cat(18.49), BmiCategory.underweight);
    });

    test('18.50 → normal', () {
      expect(cat(18.50), BmiCategory.normal);
    });

    test('24.99 → normal', () {
      expect(cat(24.99), BmiCategory.normal);
    });

    test('25.00 → overweight', () {
      expect(cat(25.00), BmiCategory.overweight);
    });

    test('29.99 → overweight', () {
      expect(cat(29.99), BmiCategory.overweight);
    });

    test('30.00 → obesity', () {
      expect(cat(30.00), BmiCategory.obesity);
    });

    test('large BMI 40.0 → obesity', () {
      expect(cat(40.0), BmiCategory.obesity);
    });

    test('very small BMI 10.0 → underweight', () {
      expect(cat(10.0), BmiCategory.underweight);
    });

    test('calculator result category matches fromBmi', () {
      // 70 / (1.70^2) ≈ 24.22 → normal
      final r = validCalc(weight: '70', height: '170');
      expect(r.category, BmiCategory.normal);
    });
  });

  // ── Precision Policy ───────────────────────────────────────────────────────
  group('Precision', () {
    test('bmiDisplay formats to exactly 2 decimals', () {
      final r = validCalc(weight: '70', height: '170');
      expect(r.bmiDisplay, matches(RegExp(r'^\d+\.\d{2}$')));
    });

    test('category is based on raw bmi, not rounded display', () {
      // Craft weight/height so raw BMI is just under 25.0
      // 68.0 / (1.65^2) = 68 / 2.7225 ≈ 24.978 → normal (not overweight)
      final r = validCalc(weight: '68', height: '165');
      expect(r.bmi, lessThan(25.0));
      expect(r.category, BmiCategory.normal);
    });
  });

  // ── Validation: Name ───────────────────────────────────────────────────────
  group('Validation – Name', () {
    test('empty name throws', () {
      expectThrows(() => validCalc(name: ''));
    });

    test('1-char name throws', () {
      expectThrows(() => validCalc(name: 'A'));
    });

    test('2-char name is valid', () {
      final r = validCalc(name: 'Ab');
      expect(r.name, 'Ab');
    });

    test('61-char name throws', () {
      expectThrows(() => validCalc(name: 'A' * 61));
    });

    test('60-char name is valid', () {
      final r = validCalc(name: 'A' * 60);
      expect(r.name, 'A' * 60);
    });

    test('unicode name is valid', () {
      final r = validCalc(name: 'Ärjän');
      expect(r.name, 'Ärjän');
    });
  });

  // ── Validation: Age ───────────────────────────────────────────────────────
  group('Validation – Age', () {
    test('age 0 throws', () {
      expectThrows(() => validCalc(age: '0'));
    });

    test('age 1 is valid', () {
      final r = validCalc(age: '1');
      expect(r.age, 1);
    });

    test('age 300 is valid', () {
      final r = validCalc(age: '300');
      expect(r.age, 300);
    });

    test('age 301 throws', () {
      expectThrows(() => validCalc(age: '301'));
    });

    test('negative age throws', () {
      expectThrows(() => validCalc(age: '-1'));
    });

    test('decimal age throws', () {
      expectThrows(() => validCalc(age: '25.5'));
    });

    test('comma decimal age throws', () {
      expectThrows(() => validCalc(age: '25,5'));
    });

    test('empty age throws', () {
      expectThrows(() => validCalc(age: ''));
    });
  });

  // ── Validation: Weight ────────────────────────────────────────────────────
  group('Validation – Weight', () {
    test('weight 0 throws', () {
      expectThrows(() => validCalc(weight: '0'));
    });

    test('negative weight throws', () {
      expectThrows(() => validCalc(weight: '-1'));
    });

    test('weight > 1000 throws', () {
      expectThrows(() => validCalc(weight: '1001'));
    });

    test('weight 1000 is valid', () {
      final r = validCalc(weight: '1000');
      expect(r.weightKg, 1000.0);
    });

    test('NaN weight throws', () {
      expectThrows(() => validCalc(weight: 'NaN'));
    });

    test('Infinity weight throws', () {
      expectThrows(() => validCalc(weight: 'Infinity'));
    });

    test('empty weight throws', () {
      expectThrows(() => validCalc(weight: ''));
    });
  });

  // ── Validation: Height ────────────────────────────────────────────────────
  group('Validation – Height', () {
    test('height 0 throws', () {
      expectThrows(() => validCalc(height: '0'));
    });

    test('negative height throws', () {
      expectThrows(() => validCalc(height: '-1'));
    });

    test('height > 400 throws', () {
      expectThrows(() => validCalc(height: '401'));
    });

    test('height 400 is valid', () {
      final r = validCalc(height: '400');
      expect(r.heightCm, 400.0);
    });

    test('NaN height throws', () {
      expectThrows(() => validCalc(height: 'NaN'));
    });

    test('Infinity height throws', () {
      expectThrows(() => validCalc(height: 'Infinity'));
    });

    test('empty height throws', () {
      expectThrows(() => validCalc(height: ''));
    });
  });

  // ── BmiCategory db serialization ──────────────────────────────────────────
  group('BmiCategory serialization', () {
    test('underweight dbValue', () {
      expect(BmiCategory.underweight.dbValue, 'Kurus');
    });
    test('normal dbValue', () {
      expect(BmiCategory.normal.dbValue, 'Normal');
    });
    test('overweight dbValue', () {
      expect(BmiCategory.overweight.dbValue, 'Gemuk');
    });
    test('obesity dbValue', () {
      expect(BmiCategory.obesity.dbValue, 'Obesitas');
    });
    test('fromDbValue round-trips', () {
      for (final c in BmiCategory.values) {
        expect(BmiCategory.fromDbValue(c.dbValue), c);
      }
    });
    test('fromDbValue unknown throws', () {
      expect(
        () => BmiCategory.fromDbValue('Unknown'),
        throwsA(isA<ArgumentError>()),
      );
    });
  });
}
