import '../models/user.dart';
import '../../core/database/database_helper.dart';
import '../../core/domain/auth_result.dart';
import '../../core/security/password_service.dart';
import '../../core/utils/sanitizers.dart';
import '../../core/utils/validators.dart';

/// Repository responsible for all user authentication database operations.
///
/// All SQL that accepts user-supplied values uses parameterized queries
/// (whereArgs / insert map). No SQL string interpolation is used.
class AuthRepository {
  final DatabaseHelper _dbHelper;
  final PasswordService _passwordService;

  /// Dependencies are injectable so unit tests can supply fakes/mocks.
  AuthRepository({
    DatabaseHelper? dbHelper,
    PasswordService? passwordService,
  })  : _dbHelper = dbHelper ?? DatabaseHelper.instance,
        _passwordService = passwordService ?? PasswordService();

  // ─── Queries ──────────────────────────────────────────────────────────────

  /// Finds a user by their exact sanitized username.
  /// Returns null if no matching active or inactive record exists.
  Future<User?> findUserByUsername(String username) async {
    final db = await _dbHelper.database;
    final rows = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: [username],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return User.fromMap(rows.first);
  }

  /// Finds a user by their primary key.
  /// Returns null if not found.
  Future<User?> findUserById(int id) async {
    final db = await _dbHelper.database;
    final rows = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return User.fromMap(rows.first);
  }

  /// Returns the first active user with biometric_enabled = 1, or null if none.
  ///
  /// MVP assumption: at most one admin account uses biometric login at a time.
  /// This is documented here intentionally — if multiple accounts become
  /// possible in a future version, the caller must handle the ambiguity.
  Future<User?> findBiometricEnabledUser() async {
    final db = await _dbHelper.database;
    final rows = await db.query(
      'users',
      where: 'biometric_enabled = ? AND is_active = ?',
      whereArgs: [1, 1],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return User.fromMap(rows.first);
  }

  // ─── Mutations ────────────────────────────────────────────────────────────

  /// Sets or clears the biometric login preference for a user.
  ///
  /// Only writes 0 or 1 — does NOT touch OS biometric enrollment.
  Future<void> setBiometricEnabled({
    required int userId,
    required bool enabled,
  }) async {
    final db = await _dbHelper.database;
    await db.update(
      'users',
      {
        'biometric_enabled': enabled ? 1 : 0,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  // ─── Login ────────────────────────────────────────────────────────────────

  /// Authenticates a user with username and password.
  ///
  /// Flow:
  ///   1. Sanitize username.
  ///   2. Basic input validation.
  ///   3. Parameterized query for username.
  ///   4. If not found → [AuthStatus.invalidCredentials] (generic message).
  ///   5. If inactive → [AuthStatus.inactiveUser].
  ///   6. Verify password through [PasswordService].
  ///   7. If mismatch → [AuthStatus.invalidCredentials] (same generic message).
  ///   8. Return [AuthStatus.success] with the [User] object.
  ///
  /// The same generic error is used for "username not found" and "wrong password"
  /// to prevent username enumeration attacks.
  Future<AuthResult> login({
    required String username,
    required String password,
  }) async {
    try {
      // 1. Sanitize
      final sanitizedUsername = Sanitizers.sanitizeUsername(username);

      // 2. Basic validation
      final usernameError = Validators.validateUsername(sanitizedUsername);
      if (usernameError != null) {
        return const AuthResult(
          status: AuthStatus.invalidCredentials,
          safeMessage: 'Username atau password salah.',
        );
      }
      final passwordError = Validators.validatePassword(password);
      if (passwordError != null) {
        return const AuthResult(
          status: AuthStatus.invalidCredentials,
          safeMessage: 'Username atau password salah.',
        );
      }

      // 3. Query
      final user = await findUserByUsername(sanitizedUsername);

      // 4. Not found
      if (user == null) {
        return const AuthResult(
          status: AuthStatus.invalidCredentials,
          safeMessage: 'Username atau password salah.',
        );
      }

      // 5. Inactive
      if (!user.isActive) {
        return const AuthResult(
          status: AuthStatus.inactiveUser,
          safeMessage: 'Akun tidak aktif. Hubungi administrator.',
        );
      }

      // 6. Verify password
      final valid = _passwordService.verifyPassword(
        password,
        user.passwordHash,
        user.passwordSalt,
      );

      // 7. Wrong password (same generic message)
      if (!valid) {
        return const AuthResult(
          status: AuthStatus.invalidCredentials,
          safeMessage: 'Username atau password salah.',
        );
      }

      // 8. Success
      return AuthResult(
        status: AuthStatus.success,
        user: user,
      );
    } catch (_) {
      return const AuthResult(
        status: AuthStatus.databaseError,
        safeMessage: 'Terjadi kesalahan. Silakan coba lagi.',
      );
    }
  }
}
