import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_kalku/core/domain/auth_result.dart';
import 'package:mobile_kalku/core/domain/biometric_result.dart';
import 'package:mobile_kalku/core/security/biometric_service.dart';
import 'package:mobile_kalku/core/security/session_service.dart';
import 'package:mobile_kalku/data/models/user.dart';
import 'package:mobile_kalku/data/models/user_session.dart';
import 'package:mobile_kalku/data/repositories/auth_repository.dart';
import 'package:mobile_kalku/features/auth/controller/login_controller.dart';
import 'package:mobile_kalku/features/auth/pages/login_page.dart';

class FakeAuthRepo implements AuthRepository {
  AuthResult result = const AuthResult(status: AuthStatus.invalidCredentials);
  User? bioUser;

  @override
  Future<AuthResult> login({required String username, required String password}) async =>
      result;

  @override
  Future<User?> findBiometricEnabledUser() async => bioUser;

  @override
  Future<User?> findUserById(int id) async => null;

  @override
  Future<User?> findUserByUsername(String username) async => null;

  @override
  Future<void> setBiometricEnabled({required int userId, required bool enabled}) async {}
}

class FakeSessionService implements SessionService {
  UserSession? session;

  @override
  Future<void> saveSession(UserSession s) async => session = s;

  @override
  Future<UserSession?> readSession() async => session;

  @override
  Future<bool> hasValidSession() async => session != null;

  @override
  Future<void> clearSession() async => session = null;
}

class FakeBiometricService implements BiometricService {
  @override
  Future<BiometricAvailability> getAvailability() async =>
      BiometricAvailability.available;

  @override
  Future<BiometricAuthResult> authenticate() async =>
      const BiometricAuthResult(status: BiometricStatus.success);

  @override
  Future<void> enableForUser(int userId) async {}

  @override
  Future<void> disableForUser(int userId) async {}

  @override
  Future<bool> canUseBiometricLoginForUser(int userId) async => true;
}

void main() {
  late FakeAuthRepo fakeAuthRepo;
  late FakeSessionService fakeSessionService;
  late FakeBiometricService fakeBioService;
  late LoginController controller;

  setUp(() {
    fakeAuthRepo = FakeAuthRepo();
    fakeSessionService = FakeSessionService();
    fakeBioService = FakeBiometricService();
    controller = LoginController(
      authRepository: fakeAuthRepo,
      sessionService: fakeSessionService,
      biometricService: fakeBioService,
    );
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: LoginPage(controller: controller),
    );
  }

  testWidgets('LoginPage renders header, inputs, and login button', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump();

    expect(find.text('NusaFit'), findsOneWidget);
    expect(find.text('Selamat Datang'), findsOneWidget);
    expect(find.text('Username'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.byType(ElevatedButton), findsWidgets);
  });

  testWidgets('empty submit displays validation error without calling repository',
      (tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump();

    await tester.tap(find.text('Masuk'));
    await tester.pump();

    expect(find.text('Username is required'), findsOneWidget);
    expect(fakeSessionService.session, isNull);
  });

  testWidgets('invalid credentials shows error banner', (tester) async {
    fakeAuthRepo.result = const AuthResult(status: AuthStatus.invalidCredentials);

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump();

    await tester.enterText(find.byType(TextFormField).first, 'tofik');
    await tester.enterText(find.byType(TextFormField).last, 'wrongpass');
    await tester.tap(find.text('Masuk'));
    await tester.pump();

    expect(find.text('Username atau password salah.'), findsOneWidget);
    expect(fakeSessionService.session, isNull);
  });
}
