import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_kalku/core/domain/auth_result.dart';
import 'package:mobile_kalku/core/domain/biometric_result.dart';
import 'package:mobile_kalku/core/security/biometric_service.dart';
import 'package:mobile_kalku/core/security/session_service.dart';
import 'package:mobile_kalku/data/models/user.dart';
import 'package:mobile_kalku/data/models/user_session.dart';
import 'package:mobile_kalku/data/repositories/auth_repository.dart';
import 'package:mobile_kalku/features/auth/controller/login_controller.dart';

class MockAuthRepository implements AuthRepository {
  User? userToReturn;
  AuthResult loginResult = const AuthResult(status: AuthStatus.invalidCredentials);
  User? biometricUser;

  @override
  Future<AuthResult> login({
    required String username,
    required String password,
  }) async {
    return loginResult;
  }

  @override
  Future<User?> findBiometricEnabledUser() async => biometricUser;

  @override
  Future<User?> findUserById(int id) async => userToReturn;

  @override
  Future<User?> findUserByUsername(String username) async => userToReturn;

  @override
  Future<void> setBiometricEnabled({
    required int userId,
    required bool enabled,
  }) async {
    if (userToReturn != null && userToReturn!.id == userId) {
      userToReturn = userToReturn!.copyWith(biometricEnabled: enabled);
    }
  }
}

class MockSessionService implements SessionService {
  UserSession? currentSession;

  @override
  Future<void> saveSession(UserSession session) async {
    currentSession = session;
  }

  @override
  Future<UserSession?> readSession() async => currentSession;

  @override
  Future<bool> hasValidSession() async => currentSession != null;

  @override
  Future<void> clearSession() async {
    currentSession = null;
  }
}

class MockBiometricService implements BiometricService {
  BiometricAvailability availability = BiometricAvailability.available;
  BiometricAuthResult authResult = const BiometricAuthResult(status: BiometricStatus.success);
  int? lastEnabledUserId;

  @override
  Future<BiometricAvailability> getAvailability() async => availability;

  @override
  Future<BiometricAuthResult> authenticate() async => authResult;

  @override
  Future<void> enableForUser(int userId) async {
    lastEnabledUserId = userId;
  }

  @override
  Future<void> disableForUser(int userId) async {}

  @override
  Future<bool> canUseBiometricLoginForUser(int userId) async => true;
}

void main() {
  late MockAuthRepository mockAuthRepo;
  late MockSessionService mockSessionService;
  late MockBiometricService mockBiometricService;
  late LoginController controller;

  setUp(() {
    mockAuthRepo = MockAuthRepository();
    mockSessionService = MockSessionService();
    mockBiometricService = MockBiometricService();
    controller = LoginController(
      authRepository: mockAuthRepo,
      sessionService: mockSessionService,
      biometricService: mockBiometricService,
    );
  });

  group('LoginController Credential Tests', () {
    test('validation fails on empty username', () async {
      final user = await controller.login(rawUsername: '', rawPassword: '123');
      expect(user, isNull);
      expect(controller.usernameError, isNotNull);
      expect(controller.generalError, isNull);
    });

    test('validation fails on empty password', () async {
      final user = await controller.login(rawUsername: 'tofik', rawPassword: '');
      expect(user, isNull);
      expect(controller.passwordError, isNotNull);
      expect(controller.generalError, isNull);
    });

    test('successful login saves session and returns user', () async {
      final validUser = User(
        id: 1,
        username: 'tofik',
        passwordHash: 'hash',
        passwordSalt: 'salt',
        role: 'admin',
        biometricEnabled: false,
        isActive: true,
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      );

      mockAuthRepo.loginResult = AuthResult(status: AuthStatus.success, user: validUser);

      final user = await controller.login(
        rawUsername: 'tofik',
        rawPassword: '123',
      );

      expect(user, equals(validUser));
      expect(controller.generalError, isNull);
      expect(mockSessionService.currentSession, isNotNull);
      expect(mockSessionService.currentSession!.userId, equals(1));
      expect(mockSessionService.currentSession!.username, equals('tofik'));
    });

    test('invalid credentials sets generic error message', () async {
      mockAuthRepo.loginResult = const AuthResult(status: AuthStatus.invalidCredentials);

      final user = await controller.login(
        rawUsername: 'tofik',
        rawPassword: 'wrong',
      );

      expect(user, isNull);
      expect(controller.generalError, equals('Username atau password salah.'));
      expect(mockSessionService.currentSession, isNull);
    });

    test('inactive user sets inactive error message', () async {
      mockAuthRepo.loginResult = const AuthResult(status: AuthStatus.inactiveUser);

      final user = await controller.login(
        rawUsername: 'disabled_user',
        rawPassword: '123',
      );

      expect(user, isNull);
      expect(controller.generalError, contains('dinonaktifkan'));
      expect(mockSessionService.currentSession, isNull);
    });
  });

  group('LoginController Biometric Tests', () {
    test('init updates biometric state', () async {
      mockBiometricService.availability = BiometricAvailability.available;
      mockAuthRepo.biometricUser = User(
        id: 1,
        username: 'tofik',
        passwordHash: 'hash',
        passwordSalt: 'salt',
        role: 'admin',
        biometricEnabled: true,
        isActive: true,
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      );

      await controller.init();

      expect(controller.isBiometricAvailable, isTrue);
      expect(controller.canShowBiometricButton, isTrue);
    });

    test('loginWithBiometrics succeeds and saves session', () async {
      final bioUser = User(
        id: 1,
        username: 'tofik',
        passwordHash: 'hash',
        passwordSalt: 'salt',
        role: 'admin',
        biometricEnabled: true,
        isActive: true,
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      );

      mockAuthRepo.biometricUser = bioUser;
      mockBiometricService.authResult = const BiometricAuthResult(status: BiometricStatus.success);

      final user = await controller.loginWithBiometrics();

      expect(user, equals(bioUser));
      expect(mockSessionService.currentSession, isNotNull);
      expect(mockSessionService.currentSession!.username, equals('tofik'));
    });

    test('enableBiometricForUser calls biometric service', () async {
      await controller.enableBiometricForUser(1);
      expect(mockBiometricService.lastEnabledUserId, equals(1));
    });
  });
}
