import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mobile_kalku/core/security/session_service.dart';
import 'package:mobile_kalku/data/models/user_session.dart';

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

void main() {
  late FakeSecureStorage fakeStorage;
  late SessionService sessionService;

  const validSession = UserSession(
    userId: 1,
    username: 'tofik',
    role: 'admin',
    isLoggedIn: true,
  );

  setUp(() {
    fakeStorage = FakeSecureStorage();
    sessionService = SessionService(storage: fakeStorage);
  });

  group('SessionService', () {
    test('save then read returns valid session', () async {
      await sessionService.saveSession(validSession);
      final result = await sessionService.readSession();
      expect(result, isNotNull);
      expect(result!.userId, equals(1));
      expect(result.username, equals('tofik'));
      expect(result.role, equals('admin'));
      expect(result.isLoggedIn, isTrue);
    });

    test('hasValidSession is true after save', () async {
      await sessionService.saveSession(validSession);
      expect(await sessionService.hasValidSession(), isTrue);
    });

    test('hasValidSession is false before any save', () async {
      expect(await sessionService.hasValidSession(), isFalse);
    });

    test('clearSession makes hasValidSession false', () async {
      await sessionService.saveSession(validSession);
      await sessionService.clearSession();
      expect(await sessionService.hasValidSession(), isFalse);
    });

    test('readSession returns null after clear', () async {
      await sessionService.saveSession(validSession);
      await sessionService.clearSession();
      final result = await sessionService.readSession();
      expect(result, isNull);
    });

    test('missing username → null session', () async {
      await fakeStorage.write(
          key: 'nusafit_session_userId', value: '1');
      await fakeStorage.write(
          key: 'nusafit_session_role', value: 'admin');
      await fakeStorage.write(
          key: 'nusafit_session_isLoggedIn', value: 'true');
      // username key intentionally absent
      final result = await sessionService.readSession();
      expect(result, isNull);
    });

    test('corrupted userId (non-integer) → null session', () async {
      await fakeStorage.write(
          key: 'nusafit_session_userId', value: 'not_a_number');
      await fakeStorage.write(
          key: 'nusafit_session_username', value: 'tofik');
      await fakeStorage.write(
          key: 'nusafit_session_role', value: 'admin');
      await fakeStorage.write(
          key: 'nusafit_session_isLoggedIn', value: 'true');
      final result = await sessionService.readSession();
      expect(result, isNull);
    });

    test('userId = 0 (non-positive) → null session', () async {
      await fakeStorage.write(
          key: 'nusafit_session_userId', value: '0');
      await fakeStorage.write(
          key: 'nusafit_session_username', value: 'tofik');
      await fakeStorage.write(
          key: 'nusafit_session_role', value: 'admin');
      await fakeStorage.write(
          key: 'nusafit_session_isLoggedIn', value: 'true');
      final result = await sessionService.readSession();
      expect(result, isNull);
    });

    test('isLoggedIn missing → null session', () async {
      await fakeStorage.write(
          key: 'nusafit_session_userId', value: '1');
      await fakeStorage.write(
          key: 'nusafit_session_username', value: 'tofik');
      await fakeStorage.write(
          key: 'nusafit_session_role', value: 'admin');
      // isLoggedIn intentionally absent
      final result = await sessionService.readSession();
      expect(result, isNull);
    });

    test('clearSession does not touch biometric DB flag (no DB interaction)', () async {
      // SessionService clearSession only deletes the four session keys.
      // This test asserts that no additional keys are removed during clear.
      await fakeStorage.write(key: 'some_other_key', value: 'preserved');
      await sessionService.saveSession(validSession);
      await sessionService.clearSession();
      final other = await fakeStorage.read(key: 'some_other_key');
      expect(other, equals('preserved'));
    });
  });
}
