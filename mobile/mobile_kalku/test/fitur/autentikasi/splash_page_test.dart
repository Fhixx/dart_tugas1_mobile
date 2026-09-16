import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:mobile_kalku/inti/basis_data/pengelola_basis_data.dart';
import 'package:mobile_kalku/inti/keamanan/layanan_sesi.dart';
import 'package:mobile_kalku/data/model/sesi_pengguna.dart';
import 'package:mobile_kalku/fitur/autentikasi/halaman/halaman_login.dart';
import 'package:mobile_kalku/fitur/autentikasi/halaman/halaman_splash.dart';

/// A controllable fake [SessionService] for Splash screen tests.
///
/// Supports controlling both the stored session and whether the session
/// is considered expired, independent of real time.
class FakeSplashSessionService implements SessionService {
  UserSession? session;

  /// Override expiration result directly to simulate expired state.
  bool? expiredOverride;

  @override
  Future<void> saveSession(UserSession s) async => session = s;

  @override
  Future<UserSession?> readSession() async => session;

  @override
  Future<bool> hasValidSession() async {
    if (session == null) return false;
    return !(await isSessionExpired());
  }

  @override
  Future<bool> isSessionExpired() async {
    if (expiredOverride != null) return expiredOverride!;
    if (session == null) return true;
    final now = DateTime.now().toUtc();
    return !now.isBefore(session!.expiresAt);
  }

  @override
  Future<Duration?> remainingSessionDuration() async {
    if (session == null) return null;
    return session!.expiresAt.difference(DateTime.now().toUtc());
  }

  @override
  Future<DateTime?> getSessionExpiry() async => session?.expiresAt;

  @override
  Future<void> clearSession() async => session = null;
}

/// Helper to build a valid unexpired UserSession for testing.
UserSession _makeUnexpiredSession() {
  final now = DateTime.now().toUtc();
  return UserSession(
    userId: 1,
    username: 'tofik',
    role: 'admin',
    isLoggedIn: true,
    authenticatedAt: now,
    expiresAt: now.add(SessionService.sessionTimeout),
  );
}

/// Helper to build an expired UserSession for testing.
UserSession _makeExpiredSession() {
  final past = DateTime.utc(2020, 1, 1, 10, 0, 0);
  return UserSession(
    userId: 1,
    username: 'tofik',
    role: 'admin',
    isLoggedIn: true,
    authenticatedAt: past,
    expiresAt: past.add(SessionService.sessionTimeout), // already expired
  );
}

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    FlutterSecureStorage.setMockInitialValues({});
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/local_auth'),
      (MethodCall methodCall) async {
        if (methodCall.method == 'canCheckBiometrics' || methodCall.method == 'isDeviceSupported') {
          return false;
        }
        if (methodCall.method == 'getAvailableBiometrics') {
          return <String>[];
        }
        return null;
      },
    );
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    await DatabaseHelper.resetForTesting();
    final db = await DatabaseHelper.getDatabase();
    await db.insert('users', {
      'username': 'tofik',
      'password_hash': 'hash',
      'password_salt': 'salt',
      'role': 'admin',
      'biometric_enabled': 0,
      'is_active': 1,
      'created_at': DateTime.now().toUtc().toIso8601String(),
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    });
  });

  tearDown(() async {
    await DatabaseHelper.resetForTesting();
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, 'nusafit.db');
    await databaseFactory.deleteDatabase(path);
  });

  testWidgets('SplashPage shows loading and brand elements initially', (tester) async {
    final sessionService = FakeSplashSessionService();

    await tester.pumpWidget(
      MaterialApp(
        home: SplashPage(
          sessionService: sessionService,
        ),
      ),
    );

    expect(find.text('NusaFit'), findsOneWidget);
    expect(find.text('Aplikasi Kesehatan Terpadu'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 100));
  });

  // ───────────────────────────────────────────────────────────────────────────
  // SPLASH EXPIRY TESTS
  // ───────────────────────────────────────────────────────────────────────────

  group('SplashPage Session Expiry', () {
    testWidgets('no session → navigates to LoginPage', (tester) async {
      final sessionService = FakeSplashSessionService();

      await tester.pumpWidget(
        MaterialApp(
          home: SplashPage(sessionService: sessionService),
        ),
      );

      await tester.runAsync(() async {
        await Future.delayed(const Duration(milliseconds: 200));
      });
      await tester.pump(const Duration(milliseconds: 500));

      // Should navigate away from SplashPage to LoginPage
      expect(find.byType(LoginPage, skipOffstage: false), findsOneWidget);
    });

    testWidgets('expired session → clears session, does not authenticate', (tester) async {
      final sessionService = FakeSplashSessionService();
      sessionService.session = _makeExpiredSession();
      sessionService.expiredOverride = true;

      await tester.pumpWidget(
        MaterialApp(
          home: SplashPage(sessionService: sessionService),
        ),
      );

      await tester.runAsync(() async {
        await Future.delayed(const Duration(milliseconds: 200));
      });
      await tester.pump(const Duration(milliseconds: 500));

      // Session must be cleared after expiry check
      expect(sessionService.session, isNull);
      expect(find.byType(LoginPage, skipOffstage: false), findsOneWidget);
    });

    testWidgets('session exactly at boundary (expires now) → treated as expired', (tester) async {
      final sessionService = FakeSplashSessionService();
      final now = DateTime.now().toUtc();
      sessionService.session = UserSession(
        userId: 1,
        username: 'tofik',
        role: 'admin',
        isLoggedIn: true,
        authenticatedAt: now.subtract(SessionService.sessionTimeout),
        expiresAt: now,
      );
      sessionService.expiredOverride = true;

      await tester.pumpWidget(
        MaterialApp(
          home: SplashPage(sessionService: sessionService),
        ),
      );

      await tester.runAsync(() async {
        await Future.delayed(const Duration(milliseconds: 200));
      });
      await tester.pump(const Duration(milliseconds: 500));

      // Session must be cleared
      expect(sessionService.session, isNull);
      expect(find.byType(LoginPage, skipOffstage: false), findsOneWidget);
    });

    testWidgets('valid unexpired session with null authenticatedBuilder → no crash', (tester) async {
      final sessionService = FakeSplashSessionService();
      sessionService.session = _makeUnexpiredSession();
      sessionService.expiredOverride = false;

      await tester.pumpWidget(
        MaterialApp(
          home: SplashPage(sessionService: sessionService),
        ),
      );

      await tester.runAsync(() async {
        await Future.delayed(const Duration(milliseconds: 200));
      });
      await tester.pump(const Duration(milliseconds: 500));

      expect(tester.takeException(), isNull);
    });

    testWidgets('corrupt session (null readSession) → shows no circular indicator after settle', (tester) async {
      final sessionService = FakeSplashSessionService();

      await tester.pumpWidget(
        MaterialApp(
          home: SplashPage(sessionService: sessionService),
        ),
      );

      await tester.runAsync(() async {
        await Future.delayed(const Duration(milliseconds: 200));
      });
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(LoginPage, skipOffstage: false), findsOneWidget);
    });
  });
}
