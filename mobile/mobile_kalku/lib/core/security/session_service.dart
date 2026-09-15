import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../data/models/user_session.dart';

/// Manages the application login session using [FlutterSecureStorage].
///
/// ## Hard Timeout Policy
/// This service enforces an ABSOLUTE 30-minute session timeout.
/// The session expires at `authenticatedAt + 30 minutes`, regardless of
/// any user activity. Activity MUST NOT extend the expiration.
///
/// Keys are namespaced under `nusafit_session_*` to avoid collisions with
/// other packages or future keys.
///
/// ## Stored values
///   - userId
///   - username
///   - role
///   - isLoggedIn
///   - authenticatedAt  (UTC ISO-8601)
///   - expiresAt        (UTC ISO-8601)
///
/// ## NOT stored
///   - password, password_hash, password_salt, or any biometric template.
///
/// ## Corrupt/incomplete storage state
///   Treated as "no valid session"; caller falls back to the Login screen.
///
/// ## Developer 2 Integration Contract
///
/// ### Foreground / App Resume Check
/// When the app returns to foreground (`AppLifecycleState.resumed`), Dev2
/// must call `SessionService.isSessionExpired()` and force logout if true:
///
/// ```dart
/// final expired = await sessionService.isSessionExpired();
/// if (expired) {
///   await sessionService.clearSession();
///   Navigator.pushAndRemoveUntil(context, LoginRoute, (_) => false);
/// }
/// ```
///
/// ### Live 30-minute Expiration Timer
/// Dev2 should schedule a one-shot Timer in MainShell after login:
///
/// ```dart
/// final expiry = sessionService.getSessionExpiry(); // from readSession
/// final remaining = expiry?.difference(DateTime.now().toUtc());
/// if (remaining != null && remaining > Duration.zero) {
///   _sessionTimer = Timer(remaining, () async {
///     if (await sessionService.isSessionExpired()) {
///       await sessionService.clearSession();
///       Navigator.pushAndRemoveUntil(context, LoginRoute, (_) => false);
///     }
///   });
/// }
/// ```
/// Timer MUST be cancelled/disposed in `dispose()` of MainShell.
/// User activity MUST NOT reset this timer.
/// SessionService remains the source of truth — always re-check
/// `isSessionExpired()` when the timer fires, do not trust timer timing alone.
class SessionService {
  /// Canonical hard timeout duration. Do NOT scatter literal `30` through code.
  static const Duration sessionTimeout = Duration(minutes: 30);

  static const String _keyUserId = 'nusafit_session_userId';
  static const String _keyUsername = 'nusafit_session_username';
  static const String _keyRole = 'nusafit_session_role';
  static const String _keyIsLoggedIn = 'nusafit_session_isLoggedIn';
  static const String _keyAuthenticatedAt = 'nusafit_session_authenticatedAt';
  static const String _keyExpiresAt = 'nusafit_session_expiresAt';

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
  ///   - any value is unparseable (corrupt timestamp, invalid userId, etc.),
  ///   - the session is structurally invalid,
  ///   - an exception occurs (treated as corrupt storage).
  ///
  /// NOTE: This method does NOT perform expiration checking.
  /// Callers must separately call [isSessionExpired] to enforce hard timeout.
  Future<UserSession?> readSession() async {
    try {
      final map = <String, String?>{
        'userId': await _storage.read(key: _keyUserId),
        'username': await _storage.read(key: _keyUsername),
        'role': await _storage.read(key: _keyRole),
        'isLoggedIn': await _storage.read(key: _keyIsLoggedIn),
        'authenticatedAt': await _storage.read(key: _keyAuthenticatedAt),
        'expiresAt': await _storage.read(key: _keyExpiresAt),
      };
      final session = UserSession.fromStorageMap(map);
      return (session != null && session.isValid) ? session : null;
    } catch (_) {
      // Storage error treated as missing session; falls back to login.
      return null;
    }
  }

  // ─── Validate ─────────────────────────────────────────────────────────────

  /// Returns true only when a structurally valid, unexpired session exists.
  ///
  /// This is the primary guard method for Splash/startup authentication check.
  Future<bool> hasValidSession() async {
    final session = await readSession();
    if (session == null) return false;
    return !_isExpired(session);
  }

  /// Returns true when the stored session has passed its absolute expiry time.
  ///
  /// Returns true (expired/invalid) when:
  ///   - no session exists in storage,
  ///   - the session is structurally invalid,
  ///   - now >= expiresAt (at the exact boundary the session is expired).
  ///
  /// Uses UTC for all comparisons.
  Future<bool> isSessionExpired() async {
    final session = await readSession();
    if (session == null) return true;
    return _isExpired(session);
  }

  /// Returns the remaining duration until this session expires, or null if
  /// no valid session exists. A zero or negative value means already expired.
  ///
  /// Dev2 may use this to schedule the live-expiration Timer in MainShell.
  Future<Duration?> remainingSessionDuration() async {
    final session = await readSession();
    if (session == null) return null;
    final now = DateTime.now().toUtc();
    return session.expiresAt.difference(now);
  }

  /// Returns the absolute UTC expiry time of the current session, or null if
  /// no valid session exists.
  ///
  /// Dev2 may use this to schedule the live-expiration Timer in MainShell.
  Future<DateTime?> getSessionExpiry() async {
    final session = await readSession();
    return session?.expiresAt;
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
    await _storage.delete(key: _keyAuthenticatedAt);
    await _storage.delete(key: _keyExpiresAt);
  }

  // ─── Internal ─────────────────────────────────────────────────────────────

  /// Returns true when [session] has reached or passed its expiry time.
  ///
  /// At exactly expiresAt: session is considered expired.
  bool _isExpired(UserSession session) {
    final now = DateTime.now().toUtc();
    // not.isBefore(expiresAt) ≡ now >= expiresAt
    return !now.isBefore(session.expiresAt);
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
      case 'authenticatedAt':
        return _keyAuthenticatedAt;
      case 'expiresAt':
        return _keyExpiresAt;
      default:
        throw ArgumentError('Unknown session field: $field');
    }
  }
}
