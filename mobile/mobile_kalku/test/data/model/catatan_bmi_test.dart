import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_kalku/data/model/catatan_bmi.dart';

void main() {
  group('BmiRecord Model', () {
    test('fromMap and toMap', () {
      final now = DateTime.now().toUtc();
      final record = BmiRecord(
        id: 10,
        userId: 1,
        name: 'Test Record',
        age: 25,
        weightKg: 70.5,
        heightCm: 175.0,
        bmi: 23.0,
        category: 'Normal',
        createdAt: now,
        updatedAt: now,
      );

      final map = record.toMap();
      final recordFromMap = BmiRecord.fromMap(map);

      expect(recordFromMap.id, equals(record.id));
      expect(recordFromMap.userId, equals(record.userId));
      expect(recordFromMap.name, equals(record.name));
      expect(recordFromMap.age, equals(record.age));
      expect(recordFromMap.weightKg, equals(record.weightKg));
      expect(recordFromMap.heightCm, equals(record.heightCm));
      expect(recordFromMap.bmi, equals(record.bmi));
      expect(recordFromMap.category, equals(record.category));
      
      expect(recordFromMap.createdAt.toIso8601String().substring(0, 19), equals(record.createdAt.toIso8601String().substring(0, 19)));
      expect(recordFromMap.updatedAt.toIso8601String().substring(0, 19), equals(record.updatedAt.toIso8601String().substring(0, 19)));
    });

    test('copyWith', () {
      final record = BmiRecord(
        id: 1,
        userId: 1,
        name: 'old',
        age: 20,
        weightKg: 50.0,
        heightCm: 150.0,
        bmi: 22.2,
        category: 'Normal',
      );
      final newCopied = record.copyWith(name: 'new', weightKg: 55.0);
      expect(newCopied.name, equals('new'));
      expect(newCopied.weightKg, equals(55.0));
      expect(newCopied.id, equals(1));
    });
  });
}
