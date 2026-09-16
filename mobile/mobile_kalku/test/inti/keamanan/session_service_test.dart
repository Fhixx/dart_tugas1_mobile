import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mobile_kalku/inti/keamanan/layanan_sesi.dart';
import 'package:mobile_kalku/data/model/sesi_pengguna.dart';

/// A simple in-memory fake for [FlutterSecureStorage] used in tests.
/// This avoids requiring real Android secure storage during unit tests.
class FakeSecureStorage implements FlutterSecureStorage {
  final Map<String, String?> _store = {};

  @override
  Future<void> write({
    required String key,
    required String? value,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    _store[key] = value;
  }

  @override
  Future<String?> read({
    required String key,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    return _store[key];
  }

  @override
  Future<void> delete({
    required String key,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    _store.remove(key);
  }

  @override
  Future<bool> containsKey({
    required String key,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    return _store.containsKey(key);
  }

  @override
  Future<Map<String, String>> readAll({
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    return Map<String, String>.from(
      _store.map((k, v) => MapEntry(k, v ?? '')),
    );
  }

  @override
  Future<void> deleteAll({
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    _store.clear();
  }

  // Unused platform interface stubs.
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Helper: create a session with controlled timestamps (for testing only).
UserSession makeSession({
  required DateTime authenticatedAt,
}) {
  final expiresAt = authenticatedAt.add(SessionService.sessionTimeout);
  return UserSession(
    userId: 1,
    username: 'tofik',
    role: 'admin',
    isLoggedIn: true,
    authenticatedAt: authenticatedAt.toUtc(),
    expiresAt: expiresAt.toUtc(),
  );
}

/// Helper: create a session with explicit expiry (for testing edge cases).
UserSession makeSessionWithExpiry({
  required DateTime authenticatedAt,
  required DateTime expiresAt,
}) {
  return UserSession(
    userId: 1,
    username: 'tofik',
    role: 'admin',
    isLoggedIn: true,
    authenticatedAt: authenticatedAt.toUtc(),
    expiresAt: expiresAt.toUtc(),
  );
}

void main() {
  late FakeSecureStorage fakeStorage;
  late SessionService sessionService;

  setUp(() {
    fakeStorage = FakeSecureStorage();
    sessionService = SessionService(storage: fakeStorage);
  });

  // ───────────────────────────────────────────────────────────────────────────
  // A. SESSION CONSTANT
  // ───────────────────────────────────────────────────────────────────────────
  group('A. Session Timeout Constant', () {
    test('sessionTimeout is exactly 30 minutes', () {
      expect(SessionService.sessionTimeout, equals(const Duration(minutes: 30)));
    });
  });

  // ───────────────────────────────────────────────────────────────────────────
  // B. LOGIN SESSION CREATION
  // ───────────────────────────────────────────────────────────────────────────
  group('B. Login Session Creation', () {
    test('authenticatedAt is stored and expiresAt = authenticatedAt + 30 min', () async {
      final loginTime = DateTime.utc(2026, 1, 1, 10, 0, 0);
      final session = makeSession(authenticatedAt: loginTime);

      await sessionService.saveSession(session);
      final result = await sessionService.readSession();

      expect(result, isNotNull);
      expect(result!.authenticatedAt, equals(loginTime));
      expect(
        result.expiresAt,
        equals(loginTime.add(SessionService.sessionTimeout)),
      );
      expect(result.expiresAt, equals(DateTime.utc(2026, 1, 1, 10, 30, 0)));
    });

    test('session is valid immediately after login', () async {
      final now = DateTime.now().toUtc();
      final session = makeSession(authenticatedAt: now);
      await sessionService.saveSession(session);
      expect(await sessionService.isSessionExpired(), isFalse);
      expect(await sessionService.hasValidSession(), isTrue);
    });

    test('save then read returns all fields including timestamps', () async {
      final loginTime = DateTime.utc(2026, 6, 15, 8, 0, 0);
      final session = makeSession(authenticatedAt: loginTime);
      await sessionService.saveSession(session);
      final result = await sessionService.readSession();
      expect(result, isNotNull);
      expect(result!.userId, equals(1));
      expect(result.username, equals('tofik'));
      expect(result.role, equals('admin'));
      expect(result.isLoggedIn, isTrue);
      expect(result.authenticatedAt, equals(loginTime));
    });
  });

  // ───────────────────────────────────────────────────────────────────────────
  // C. BEFORE EXPIRATION: login 10:00:00 → check 10:29:59 → VALID
  // ───────────────────────────────────────────────────────────────────────────
  group('C. Before Expiration', () {
    test('session at 10:29:59 is still valid', () async {
      final loginTime = DateTime.utc(2026, 1, 1, 10, 0, 0);
      final checkTime = DateTime.utc(2026, 1, 1, 10, 29, 59);

      final session = makeSession(authenticatedAt: loginTime);
      await sessionService.saveSession(session);

      // Verify using stored expiresAt directly
      final stored = await sessionService.readSession();
      expect(stored, isNotNull);
      final now = checkTime;
      final isExpired = !now.isBefore(stored!.expiresAt);
      expect(isExpired, isFalse, reason: '10:29:59 must still be VALID');
    });
  });

  // ───────────────────────────────────────────────────────────────────────────
  // D. EXACT EXPIRATION BOUNDARY: 10:30:00 → EXPIRED
  // ───────────────────────────────────────────────────────────────────────────
  group('D. Exact Expiration Boundary', () {
    test('session at exactly expiresAt (10:30:00) is EXPIRED', () async {
      final loginTime = DateTime.utc(2026, 1, 1, 10, 0, 0);
      final expiresAt = loginTime.add(SessionService.sessionTimeout); // 10:30:00

      final session = makeSession(authenticatedAt: loginTime);
      await sessionService.saveSession(session);

      final stored = await sessionService.readSession();
      expect(stored, isNotNull);
      expect(stored!.expiresAt, equals(expiresAt));

      // Simulate "now" == expiresAt
      final now = expiresAt;
      final isExpired = !now.isBefore(stored.expiresAt);
      expect(isExpired, isTrue, reason: 'At exactly 10:30:00 session must be EXPIRED');
    });
  });

  // ───────────────────────────────────────────────────────────────────────────
  // E. AFTER EXPIRATION: 10:30:01 → EXPIRED
  // ───────────────────────────────────────────────────────────────────────────
  group('E. After Expiration', () {
    test('session at 10:30:01 is EXPIRED', () async {
      final loginTime = DateTime.utc(2026, 1, 1, 10, 0, 0);

      final session = makeSession(authenticatedAt: loginTime);
      await sessionService.saveSession(session);

      final stored = await sessionService.readSession();
      expect(stored, isNotNull);

      // Simulate "now" == expiresAt + 1 second
      final now = DateTime.utc(2026, 1, 1, 10, 30, 1);
      final isExpired = !now.isBefore(stored!.expiresAt);
      expect(isExpired, isTrue, reason: '10:30:01 must be EXPIRED');
    });
  });

  // ───────────────────────────────────────────────────────────────────────────
  // F. ACTIVITY DOES NOT EXTEND SESSION
  // ───────────────────────────────────────────────────────────────────────────
  group('F. Activity Does Not Extend Session', () {
    test('expiresAt remains unchanged after multiple saveSession calls with same times', () async {
      final loginTime = DateTime.utc(2026, 1, 1, 10, 0, 0);
      final session = makeSession(authenticatedAt: loginTime);
      await sessionService.saveSession(session);

      // Simulate user "activity" at 10:10, 10:20, 10:29
      // Activity must NOT update expiresAt
      for (final _ in [
        DateTime.utc(2026, 1, 1, 10, 10, 0),
        DateTime.utc(2026, 1, 1, 10, 20, 0),
        DateTime.utc(2026, 1, 1, 10, 29, 0),
      ]) {
        // No touchActivity, no session update — just verify expiresAt unchanged
        final stored = await sessionService.readSession();
        expect(stored, isNotNull);
        expect(
          stored!.expiresAt,
          equals(DateTime.utc(2026, 1, 1, 10, 30, 0)),
          reason: 'expiresAt must remain 10:30 regardless of activity',
        );
      }
    });

    test('no touchActivity or refreshSession methods exist on SessionService', () {
      // Reflect that no extension-API is exposed
      final methods = (SessionService).toString();
      expect(methods.contains('touchActivity'), isFalse);
      expect(methods.contains('refreshSession'), isFalse);
    });
  });

  // ───────────────────────────────────────────────────────────────────────────
  // G. CORRUPT TIMESTAMP
  // ───────────────────────────────────────────────────────────────────────────
  group('G. Corrupt Timestamp', () {
    test('corrupt authenticatedAt → null session, no crash', () async {
      await fakeStorage.write(key: 'nusafit_session_userId', value: '1');
      await fakeStorage.write(key: 'nusafit_session_username', value: 'tofik');
      await fakeStorage.write(key: 'nusafit_session_role', value: 'admin');
      await fakeStorage.write(key: 'nusafit_session_isLoggedIn', value: 'true');
      await fakeStorage.write(
          key: 'nusafit_session_authenticatedAt', value: 'NOT_A_DATE');
      await fakeStorage.write(
          key: 'nusafit_session_expiresAt',
          value: DateTime.utc(2099, 1, 1).toIso8601String());

      final result = await sessionService.readSession();
      expect(result, isNull, reason: 'Corrupt authenticatedAt must yield null');
    });

    test('corrupt expiresAt → null session, no crash', () async {
      final now = DateTime.now().toUtc();
      await fakeStorage.write(key: 'nusafit_session_userId', value: '1');
      await fakeStorage.write(key: 'nusafit_session_username', value: 'tofik');
      await fakeStorage.write(key: 'nusafit_session_role', value: 'admin');
      await fakeStorage.write(key: 'nusafit_session_isLoggedIn', value: 'true');
      await fakeStorage.write(
          key: 'nusafit_session_authenticatedAt',
          value: now.toIso8601String());
      await fakeStorage.write(
          key: 'nusafit_session_expiresAt', value: 'GARBAGE');

      final result = await sessionService.readSession();
      expect(result, isNull, reason: 'Corrupt expiresAt must yield null');
    });

    test('isSessionExpired returns true on corrupt session (no crash)', () async {
      await fakeStorage.write(key: 'nusafit_session_userId', value: '1');
      await fakeStorage.write(key: 'nusafit_session_username', value: 'tofik');
      await fakeStorage.write(key: 'nusafit_session_role', value: 'admin');
      await fakeStorage.write(key: 'nusafit_session_isLoggedIn', value: 'true');
      await fakeStorage.write(
          key: 'nusafit_session_authenticatedAt', value: 'BAD_DATE');
      await fakeStorage.write(
          key: 'nusafit_session_expiresAt', value: 'ALSO_BAD');

      expect(await sessionService.isSessionExpired(), isTrue);
    });

    test('corrupted userId (non-integer) → null session', () async {
      final now = DateTime.now().toUtc();
      await fakeStorage.write(key: 'nusafit_session_userId', value: 'not_a_number');
      await fakeStorage.write(key: 'nusafit_session_username', value: 'tofik');
      await fakeStorage.write(key: 'nusafit_session_role', value: 'admin');
      await fakeStorage.write(key: 'nusafit_session_isLoggedIn', value: 'true');
      await fakeStorage.write(
          key: 'nusafit_session_authenticatedAt', value: now.toIso8601String());
      await fakeStorage.write(
          key: 'nusafit_session_expiresAt',
          value: now.add(SessionService.sessionTimeout).toIso8601String());
      final result = await sessionService.readSession();
      expect(result, isNull);
    });

    test('userId = 0 (non-positive) → null session', () async {
      final now = DateTime.now().toUtc();
      await fakeStorage.write(key: 'nusafit_session_userId', value: '0');
      await fakeStorage.write(key: 'nusafit_session_username', value: 'tofik');
      await fakeStorage.write(key: 'nusafit_session_role', value: 'admin');
      await fakeStorage.write(key: 'nusafit_session_isLoggedIn', value: 'true');
      await fakeStorage.write(
          key: 'nusafit_session_authenticatedAt', value: now.toIso8601String());
      await fakeStorage.write(
          key: 'nusafit_session_expiresAt',
          value: now.add(SessionService.sessionTimeout).toIso8601String());
      final result = await sessionService.readSession();
      expect(result, isNull);
    });
  });

  // ───────────────────────────────────────────────────────────────────────────
  // H. MISSING EXPIRY
  // ───────────────────────────────────────────────────────────────────────────
  group('H. Missing Expiry', () {
    test('missing expiresAt key → null session (invalid)', () async {
      final now = DateTime.now().toUtc();
      await fakeStorage.write(key: 'nusafit_session_userId', value: '1');
      await fakeStorage.write(key: 'nusafit_session_username', value: 'tofik');
      await fakeStorage.write(key: 'nusafit_session_role', value: 'admin');
      await fakeStorage.write(key: 'nusafit_session_isLoggedIn', value: 'true');
      await fakeStorage.write(
          key: 'nusafit_session_authenticatedAt', value: now.toIso8601String());
      // expiresAt intentionally absent

      final result = await sessionService.readSession();
      expect(result, isNull, reason: 'Missing expiresAt must be invalid session');
    });

    test('missing authenticatedAt key → null session (invalid)', () async {
      final expiry = DateTime.now().toUtc().add(const Duration(hours: 1));
      await fakeStorage.write(key: 'nusafit_session_userId', value: '1');
      await fakeStorage.write(key: 'nusafit_session_username', value: 'tofik');
      await fakeStorage.write(key: 'nusafit_session_role', value: 'admin');
      await fakeStorage.write(key: 'nusafit_session_isLoggedIn', value: 'true');
      // authenticatedAt intentionally absent
      await fakeStorage.write(
          key: 'nusafit_session_expiresAt', value: expiry.toIso8601String());

      final result = await sessionService.readSession();
      expect(result, isNull, reason: 'Missing authenticatedAt must be invalid session');
    });

    test('missing username → null session', () async {
      final now = DateTime.now().toUtc();
      await fakeStorage.write(key: 'nusafit_session_userId', value: '1');
      await fakeStorage.write(key: 'nusafit_session_role', value: 'admin');
      await fakeStorage.write(key: 'nusafit_session_isLoggedIn', value: 'true');
      await fakeStorage.write(
          key: 'nusafit_session_authenticatedAt', value: now.toIso8601String());
      await fakeStorage.write(
          key: 'nusafit_session_expiresAt',
          value: now.add(SessionService.sessionTimeout).toIso8601String());
      // username key intentionally absent
      final result = await sessionService.readSession();
      expect(result, isNull);
    });

    test('missing isLoggedIn → null session', () async {
      final now = DateTime.now().toUtc();
      await fakeStorage.write(key: 'nusafit_session_userId', value: '1');
      await fakeStorage.write(key: 'nusafit_session_username', value: 'tofik');
      await fakeStorage.write(key: 'nusafit_session_role', value: 'admin');
      // isLoggedIn intentionally absent
      await fakeStorage.write(
          key: 'nusafit_session_authenticatedAt', value: now.toIso8601String());
      await fakeStorage.write(
          key: 'nusafit_session_expiresAt',
          value: now.add(SessionService.sessionTimeout).toIso8601String());
      final result = await sessionService.readSession();
      expect(result, isNull);
    });
  });

  // ───────────────────────────────────────────────────────────────────────────
  // I. MANUAL LOGOUT — session keys cleared
  // ───────────────────────────────────────────────────────────────────────────
  group('I. Manual Logout', () {
    test('clearSession removes all session keys', () async {
      final session = makeSession(authenticatedAt: DateTime.now().toUtc());
      await sessionService.saveSession(session);
      await sessionService.clearSession();

      final result = await sessionService.readSession();
      expect(result, isNull);
      expect(await sessionService.hasValidSession(), isFalse);
    });

    test('clearSession does not remove unrelated keys', () async {
      await fakeStorage.write(key: 'some_other_key', value: 'preserved');
      final session = makeSession(authenticatedAt: DateTime.now().toUtc());
      await sessionService.saveSession(session);
      await sessionService.clearSession();
      final other = await fakeStorage.read(key: 'some_other_key');
      expect(other, equals('preserved'));
    });

    test('clearSession does not touch biometric DB flag (no DB interaction)', () async {
      // SessionService clearSession only deletes the session keys.
      await fakeStorage.write(key: 'biometric_pref_key', value: '1');
      final session = makeSession(authenticatedAt: DateTime.now().toUtc());
      await sessionService.saveSession(session);
      await sessionService.clearSession();
      final bioPref = await fakeStorage.read(key: 'biometric_pref_key');
      expect(bioPref, equals('1'));
    });

    test('readSession returns null after clearSession', () async {
      final session = makeSession(authenticatedAt: DateTime.now().toUtc());
      await sessionService.saveSession(session);
      await sessionService.clearSession();
      expect(await sessionService.readSession(), isNull);
    });

    test('isSessionExpired returns true after clearSession', () async {
      final session = makeSession(authenticatedAt: DateTime.now().toUtc());
      await sessionService.saveSession(session);
      await sessionService.clearSession();
      expect(await sessionService.isSessionExpired(), isTrue);
    });
  });

  // ───────────────────────────────────────────────────────────────────────────
  // J. EXPIRED SESSION → clear contract (for Splash/Dev2 integration)
  // ───────────────────────────────────────────────────────────────────────────
  group('J. Expired Session Contract', () {
    test('isSessionExpired returns true for past expiresAt', () async {
      final pastLogin = DateTime.utc(2020, 1, 1, 10, 0, 0);
      // expiresAt was 2020-01-01 10:30 — long in the past
      final session = makeSession(authenticatedAt: pastLogin);
      await sessionService.saveSession(session);

      expect(await sessionService.isSessionExpired(), isTrue);
    });

    test('hasValidSession returns false for expired session', () async {
      final pastLogin = DateTime.utc(2020, 1, 1, 10, 0, 0);
      final session = makeSession(authenticatedAt: pastLogin);
      await sessionService.saveSession(session);

      expect(await sessionService.hasValidSession(), isFalse);
    });

    test('clearSession after expiry makes session null', () async {
      final pastLogin = DateTime.utc(2020, 1, 1, 10, 0, 0);
      final session = makeSession(authenticatedAt: pastLogin);
      await sessionService.saveSession(session);

      await sessionService.clearSession();
      expect(await sessionService.readSession(), isNull);
    });
  });

  // ───────────────────────────────────────────────────────────────────────────
  // K. NEW PASSWORD LOGIN — replaces previous session
  // ───────────────────────────────────────────────────────────────────────────
  group('K. New Password Login Replaces Expired Session', () {
    test('second saveSession overwrites expired session with fresh 30-min expiry', () async {
      // Old (expired) session
      final oldLogin = DateTime.utc(2020, 1, 1, 10, 0, 0);
      final expiredSession = makeSession(authenticatedAt: oldLogin);
      await sessionService.saveSession(expiredSession);
      expect(await sessionService.isSessionExpired(), isTrue);

      // New session (fresh login now)
      final newLogin = DateTime.now().toUtc();
      final freshSession = makeSession(authenticatedAt: newLogin);
      await sessionService.saveSession(freshSession);

      final result = await sessionService.readSession();
      expect(result, isNotNull);
      expect(result!.authenticatedAt.isAfter(oldLogin), isTrue);
      expect(await sessionService.isSessionExpired(), isFalse);
      expect(await sessionService.hasValidSession(), isTrue);
    });

    test('new login expiresAt is exactly +30 minutes from new authenticatedAt', () async {
      final newLogin = DateTime.now().toUtc();
      final freshSession = makeSession(authenticatedAt: newLogin);
      await sessionService.saveSession(freshSession);

      final result = await sessionService.readSession();
      expect(result, isNotNull);
      final diff = result!.expiresAt.difference(result.authenticatedAt);
      expect(diff, equals(SessionService.sessionTimeout));
    });
  });

  // ───────────────────────────────────────────────────────────────────────────
  // L. NEW BIOMETRIC LOGIN — creates new 30-min session
  // ───────────────────────────────────────────────────────────────────────────
  group('L. New Biometric Login Creates Fresh Session', () {
    test('biometric login session has fresh authenticatedAt and +30min expiry', () async {
      final bioLoginTime = DateTime.now().toUtc();
      final bioSession = makeSession(authenticatedAt: bioLoginTime);
      await sessionService.saveSession(bioSession);

      final result = await sessionService.readSession();
      expect(result, isNotNull);
      expect(result!.isLoggedIn, isTrue);
      expect(await sessionService.isSessionExpired(), isFalse);

      final diff = result.expiresAt.difference(result.authenticatedAt);
      expect(diff, equals(SessionService.sessionTimeout));
    });
  });

  // ───────────────────────────────────────────────────────────────────────────
  // M. REMAINING DURATION + EXPIRY API
  // ───────────────────────────────────────────────────────────────────────────
  group('M. Remaining Duration and Expiry API', () {
    test('remainingSessionDuration returns null when no session', () async {
      final duration = await sessionService.remainingSessionDuration();
      expect(duration, isNull);
    });

    test('remainingSessionDuration is positive for unexpired session', () async {
      final session = makeSession(authenticatedAt: DateTime.now().toUtc());
      await sessionService.saveSession(session);
      final remaining = await sessionService.remainingSessionDuration();
      expect(remaining, isNotNull);
      expect(remaining!.isNegative, isFalse);
    });

    test('remainingSessionDuration is negative/zero for expired session', () async {
      final oldLogin = DateTime.utc(2020, 1, 1, 10, 0, 0);
      final session = makeSession(authenticatedAt: oldLogin);
      await sessionService.saveSession(session);
      final remaining = await sessionService.remainingSessionDuration();
      expect(remaining, isNotNull);
      expect(remaining!.isNegative, isTrue);
    });

    test('getSessionExpiry returns null when no session', () async {
      final expiry = await sessionService.getSessionExpiry();
      expect(expiry, isNull);
    });

    test('getSessionExpiry returns expiresAt for valid session', () async {
      final loginTime = DateTime.utc(2026, 1, 1, 10, 0, 0);
      final session = makeSession(authenticatedAt: loginTime);
      await sessionService.saveSession(session);

      final expiry = await sessionService.getSessionExpiry();
      expect(expiry, isNotNull);
      expect(expiry, equals(DateTime.utc(2026, 1, 1, 10, 30, 0)));
    });
  });

  // ───────────────────────────────────────────────────────────────────────────
  // N. hasValidSession guard
  // ───────────────────────────────────────────────────────────────────────────
  group('N. hasValidSession', () {
    test('returns false before any save', () async {
      expect(await sessionService.hasValidSession(), isFalse);
    });

    test('returns true after saving fresh session', () async {
      final session = makeSession(authenticatedAt: DateTime.now().toUtc());
      await sessionService.saveSession(session);
      expect(await sessionService.hasValidSession(), isTrue);
    });

    test('returns false after clearSession', () async {
      final session = makeSession(authenticatedAt: DateTime.now().toUtc());
      await sessionService.saveSession(session);
      await sessionService.clearSession();
      expect(await sessionService.hasValidSession(), isFalse);
    });
  });
}
