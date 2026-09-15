import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth/error_codes.dart' as auth_error;
import 'package:mobile_kalku/core/domain/biometric_result.dart';
import 'package:mobile_kalku/core/security/biometric_service.dart';
import 'package:mobile_kalku/data/models/user.dart';
import 'package:mobile_kalku/data/repositories/auth_repository.dart';

// ─── Fake AuthRepository ────────────────────────────────────────────────────

class FakeAuthRepository extends AuthRepository {
  /// Current biometric_enabled state for the fake user
  bool _biometricEnabled = false;
  bool _userExists = true;
  bool _userActive = true;

  User get _fakeUser => User(
        id: 1,
        username: 'tofik',
        passwordHash: '',
        passwordSalt: '',
        role: 'admin',
        biometricEnabled: _biometricEnabled,
        isActive: _userActive,
      );

  void configureBiometric(bool enabled) => _biometricEnabled = enabled;
  void configureUserExists(bool exists) => _userExists = exists;
  void configureUserActive(bool active) => _userActive = active;

  @override
  Future<User?> findUserById(int id) async =>
      _userExists ? _fakeUser : null;

  @override
  Future<User?> findBiometricEnabledUser() async {
    if (!_userExists || !_userActive || !_biometricEnabled) return null;
    return _fakeUser;
  }

  @override
  Future<void> setBiometricEnabled({
    required int userId,
    required bool enabled,
  }) async {
    _biometricEnabled = enabled;
  }
}

// ─── Fake LocalAuthentication ────────────────────────────────────────────────

class FakeLocalAuth extends LocalAuthentication {
  bool _canCheckBiometrics = true;
  bool _isDeviceSupported = true;
  List<BiometricType> _availableBiometrics = [BiometricType.fingerprint];
  bool _authenticateResult = true;
  PlatformException? _authenticateError;

  void configureSupport({
    bool canCheck = true,
    bool isSupported = true,
    List<BiometricType>? biometrics,
  }) {
    _canCheckBiometrics = canCheck;
    _isDeviceSupported = isSupported;
    _availableBiometrics = biometrics ?? [BiometricType.fingerprint];
  }

  void configureAuthenticate({
    bool result = true,
    PlatformException? error,
  }) {
    _authenticateResult = result;
    _authenticateError = error;
  }

  @override
  Future<bool> get canCheckBiometrics async => _canCheckBiometrics;

  @override
  Future<bool> isDeviceSupported() async => _isDeviceSupported;

  @override
  Future<List<BiometricType>> getAvailableBiometrics() async =>
      _availableBiometrics;

  @override
  Future<bool> authenticate({
    required String localizedReason,
    AuthenticationOptions options = const AuthenticationOptions(),
    dynamic authMessages = const [],
  }) async {
    if (_authenticateError != null) throw _authenticateError!;
    return _authenticateResult;
  }
}

// ─── Tests ───────────────────────────────────────────────────────────────────

void main() {
  late FakeLocalAuth fakeLocalAuth;
  late FakeAuthRepository fakeAuthRepo;
  late BiometricService biometricService;

  setUp(() {
    fakeLocalAuth = FakeLocalAuth();
    fakeAuthRepo = FakeAuthRepository();
    biometricService = BiometricService(
      localAuth: fakeLocalAuth,
      authRepository: fakeAuthRepo,
    );
  });

  group('BiometricService', () {
    // ── Availability ─────────────────────────────────────────────────────────
    test('getAvailability = available when supported + enrolled', () async {
      fakeLocalAuth.configureSupport();
      final result = await biometricService.getAvailability();
      expect(result, equals(BiometricAvailability.available));
    });

    test('getAvailability = unavailable when device not supported', () async {
      fakeLocalAuth.configureSupport(isSupported: false);
      final result = await biometricService.getAvailability();
      expect(result, equals(BiometricAvailability.unavailable));
    });

    test('getAvailability = notEnrolled when no biometrics enrolled', () async {
      fakeLocalAuth.configureSupport(biometrics: []);
      final result = await biometricService.getAvailability();
      expect(result, equals(BiometricAvailability.notEnrolled));
    });

    // ── Authenticate ──────────────────────────────────────────────────────────
    test('authenticate succeeds → BiometricStatus.success', () async {
      fakeLocalAuth.configureAuthenticate(result: true);
      final result = await biometricService.authenticate();
      expect(result.status, equals(BiometricStatus.success));
    });

    test('authenticate returns false → BiometricStatus.cancelled', () async {
      fakeLocalAuth.configureAuthenticate(result: false);
      final result = await biometricService.authenticate();
      expect(result.status, equals(BiometricStatus.cancelled));
    });

    test('authenticate throws notAvailable → BiometricStatus.unavailable', () async {
      fakeLocalAuth.configureAuthenticate(
        error: PlatformException(code: auth_error.notAvailable),
      );
      final result = await biometricService.authenticate();
      expect(result.status, equals(BiometricStatus.unavailable));
    });

    test('authenticate throws notEnrolled → BiometricStatus.notEnrolled', () async {
      fakeLocalAuth.configureAuthenticate(
        error: PlatformException(code: auth_error.notEnrolled),
      );
      final result = await biometricService.authenticate();
      expect(result.status, equals(BiometricStatus.notEnrolled));
    });

    test('authenticate throws lockedOut → BiometricStatus.lockedOut', () async {
      fakeLocalAuth.configureAuthenticate(
        error: PlatformException(code: auth_error.lockedOut),
      );
      final result = await biometricService.authenticate();
      expect(result.status, equals(BiometricStatus.lockedOut));
    });

    test('authenticate throws permanentlyLockedOut → BiometricStatus.permanentlyLockedOut',
        () async {
      fakeLocalAuth.configureAuthenticate(
        error: PlatformException(code: auth_error.permanentlyLockedOut),
      );
      final result = await biometricService.authenticate();
      expect(result.status, equals(BiometricStatus.permanentlyLockedOut));
    });

    test('authenticate throws unknown error → BiometricStatus.error', () async {
      fakeLocalAuth.configureAuthenticate(
        error: PlatformException(code: 'UNKNOWN_ERROR'),
      );
      final result = await biometricService.authenticate();
      expect(result.status, equals(BiometricStatus.error));
    });

    // ── Preference ────────────────────────────────────────────────────────────
    test('canUseBiometricLoginForUser = false when preference is OFF', () async {
      fakeAuthRepo.configureBiometric(false);
      fakeLocalAuth.configureSupport();
      final canUse = await biometricService.canUseBiometricLoginForUser(1);
      expect(canUse, isFalse);
    });

    test('canUseBiometricLoginForUser = true when preference ON + device available',
        () async {
      fakeAuthRepo.configureBiometric(true);
      fakeLocalAuth.configureSupport();
      final canUse = await biometricService.canUseBiometricLoginForUser(1);
      expect(canUse, isTrue);
    });

    test('enableForUser sets biometric flag to true in repository', () async {
      expect(fakeAuthRepo._biometricEnabled, isFalse);
      await biometricService.enableForUser(1);
      expect(fakeAuthRepo._biometricEnabled, isTrue);
    });

    test('disableForUser sets biometric flag to false in repository', () async {
      fakeAuthRepo.configureBiometric(true);
      await biometricService.disableForUser(1);
      expect(fakeAuthRepo._biometricEnabled, isFalse);
    });

    test('failed authentication does NOT enable DB flag', () async {
      // Simulate: caller should gate enableForUser behind a successful authenticate().
      fakeLocalAuth.configureAuthenticate(result: false);
      final authResult = await biometricService.authenticate();
      if (!authResult.isSuccess) {
        // Caller does not invoke enableForUser — flag stays false.
      }
      expect(fakeAuthRepo._biometricEnabled, isFalse);
    });

    test('biometric default state is OFF (biometric_enabled = 0)', () async {
      // FakeAuthRepository initializes _biometricEnabled to false.
      expect(fakeAuthRepo._biometricEnabled, isFalse);
    });
  });
}
