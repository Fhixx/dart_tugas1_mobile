
/// Data model representing a BMI record.
///
/// Provides `fromMap`/`toMap` helpers for SQLite persistence.
class BmiRecord {
  final int? id;
  final int userId;
  final String name;
  final int age;
  final double weightKg;
  final double heightCm;
  final double bmi;
  final String category;
  final DateTime createdAt;
  final DateTime updatedAt;

  BmiRecord({
    this.id,
    required this.userId,
    required this.name,
    required this.age,
    required this.weightKg,
    required this.heightCm,
    required this.bmi,
    required this.category,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now().toUtc(),
        updatedAt = updatedAt ?? DateTime.now().toUtc();

  factory BmiRecord.fromMap(Map<String, dynamic> map) => BmiRecord(
        id: map['id'] as int?,
        userId: map['user_id'] as int,
        name: map['name'] as String,
        age: map['age'] as int,
        weightKg: (map['weight_kg'] as num).toDouble(),
        heightCm: (map['height_cm'] as num).toDouble(),
        bmi: (map['bmi'] as num).toDouble(),
        category: map['category'] as String,
        createdAt: DateTime.parse(map['created_at'] as String).toUtc(),
        updatedAt: DateTime.parse(map['updated_at'] as String).toUtc(),
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'user_id': userId,
        'name': name,
        'age': age,
        'weight_kg': weightKg,
        'height_cm': heightCm,
        'bmi': bmi,
        'category': category,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  BmiRecord copyWith({
    int? id,
    int? userId,
    String? name,
    int? age,
    double? weightKg,
    double? heightCm,
    double? bmi,
    String? category,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) =>
      BmiRecord(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        name: name ?? this.name,
        age: age ?? this.age,
        weightKg: weightKg ?? this.weightKg,
        heightCm: heightCm ?? this.heightCm,
        bmi: bmi ?? this.bmi,
        category: category ?? this.category,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
}
