

/// Data model representing a user.
///
/// Provides `fromMap`/`toMap` helpers for SQLite persistence.
class User {
  final int? id;
  final String username;
  final String passwordHash;
  final String passwordSalt;
  final String role;
  final bool biometricEnabled;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    this.id,
    required this.username,
    required this.passwordHash,
    required this.passwordSalt,
    required this.role,
    this.biometricEnabled = false,
    this.isActive = true,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now().toUtc(),
        updatedAt = updatedAt ?? DateTime.now().toUtc();

  factory User.fromMap(Map<String, dynamic> map) => User(
        id: map['id'] as int?,
        username: map['username'] as String,
        passwordHash: map['password_hash'] as String,
        passwordSalt: map['password_salt'] as String,
        role: map['role'] as String,
        biometricEnabled: (map['biometric_enabled'] as int) == 1,
        isActive: (map['is_active'] as int) == 1,
        createdAt: DateTime.parse(map['created_at'] as String).toUtc(),
        updatedAt: DateTime.parse(map['updated_at'] as String).toUtc(),
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'username': username,
        'password_hash': passwordHash,
        'password_salt': passwordSalt,
        'role': role,
        'biometric_enabled': biometricEnabled ? 1 : 0,
        'is_active': isActive ? 1 : 0,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  User copyWith({
    int? id,
    String? username,
    String? passwordHash,
    String? passwordSalt,
    String? role,
    bool? biometricEnabled,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) =>
      User(
        id: id ?? this.id,
        username: username ?? this.username,
        passwordHash: passwordHash ?? this.passwordHash,
        passwordSalt: passwordSalt ?? this.passwordSalt,
        role: role ?? this.role,
        biometricEnabled: biometricEnabled ?? this.biometricEnabled,
        isActive: isActive ?? this.isActive,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
}
