import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../data/models/user_session.dart';

/// Manages the application login session using [FlutterSecureStorage].
///
/// Keys are namespaced under `nusafit_session_*` to avoid collisions with
/// other packages or future keys.
///
/// Stored values:
///   - userId
///   - username
///   - role
///   - isLoggedIn
///
/// NOT stored:
///   - password, password_hash, password_salt, or any biometric template.
///
/// A corrupt or incomplete storage state is treated as "no valid session"
/// and the caller falls back to the Login screen.
class SessionService {
  static const String _keyUserId = 'nusafit_session_userId';
  static const String _keyUsername = 'nusafit_session_username';
  static const String _keyRole = 'nusafit_session_role';
  static const String _keyIsLoggedIn = 'nusafit_session_isLoggedIn';

  final FlutterSecureStorage _storage;

  /// [storage] is injectable so unit tests can supply a fake implementation.
  SessionService({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  // ─── Write ────────────────────────────────────────────────────────────────

  /// Persists all session values atomically (each key written sequentially).
  /// Call this only after a successful authentication.
  Future<void> saveSession(UserSession session) async {
    final map = session.toStorageMap();
    for (final entry in map.entries) {
      await _storage.write(key: _keyFor(entry.key), value: entry.value);
    }
  }

  // ─── Read ─────────────────────────────────────────────────────────────────

  /// Reads session values from secure storage and returns a [UserSession].
  ///
  /// Returns null if:
  ///   - any required key is absent,
  ///   - any value is unparseable,
  ///   - an exception occurs (treated as corrupt storage).
  Future<UserSession?> readSession() async {
    try {
      final map = <String, String?>{
        'userId': await _storage.read(key: _keyUserId),
        'username': await _storage.read(key: _keyUsername),
        'role': await _storage.read(key: _keyRole),
        'isLoggedIn': await _storage.read(key: _keyIsLoggedIn),
      };
      final session = UserSession.fromStorageMap(map);
      return (session != null && session.isValid) ? session : null;
    } catch (_) {
      // Storage error treated as missing session; falls back to login.
      return null;
    }
  }

  // ─── Validate ─────────────────────────────────────────────────────────────

  /// Returns true only when a structurally valid session exists in storage.
  Future<bool> hasValidSession() async {
    final session = await readSession();
    return session != null;
  }

  // ─── Clear ────────────────────────────────────────────────────────────────

  /// Clears the application login session keys.
  ///
  /// Does NOT:
  ///   - delete BMI records from the database,
  ///   - reset users.biometric_enabled in the database,
  ///   - remove OS-level fingerprint/face enrollment.
  Future<void> clearSession() async {
    await _storage.delete(key: _keyUserId);
    await _storage.delete(key: _keyUsername);
    await _storage.delete(key: _keyRole);
    await _storage.delete(key: _keyIsLoggedIn);
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  /// Maps a storage-map field name to its namespaced storage key.
  String _keyFor(String field) {
    switch (field) {
      case 'userId':
        return _keyUserId;
      case 'username':
        return _keyUsername;
      case 'role':
        return _keyRole;
      case 'isLoggedIn':
        return _keyIsLoggedIn;
      default:
        throw ArgumentError('Unknown session field: $field');
    }
  }
}
