import 'package:sqflite/sqflite.dart';
import '../../data/model/pengguna.dart';
import '../../inti/keamanan/layanan_kata_sandi.dart';

/// Seeds the database with an admin user (username: 'tofik', password: '123').
/// Idempotent – does nothing if the admin already exists.
class AdminSeed {
  static const _adminUsername = 'tofik';
  static const _adminPassword = '123';
  static const _adminRole = 'admin';

  final PasswordService _passwordService = PasswordService();

  Future<void> run(Database db) async {
    final existing = await db.query(
      'users',
      columns: ['id'],
      where: 'username = ?',
      whereArgs: [_adminUsername],
    );
    if (existing.isNotEmpty) return;

    final credentials = _passwordService.generateHashAndSalt(_adminPassword);
    final now = DateTime.now().toUtc();
    final user = User(
      username: _adminUsername,
      passwordHash: credentials['hash']!,
      passwordSalt: credentials['salt']!,
      role: _adminRole,
      biometricEnabled: false,
      isActive: true,
      createdAt: now,
      updatedAt: now,
    );
    await db.insert('users', user.toMap());
  }
}
