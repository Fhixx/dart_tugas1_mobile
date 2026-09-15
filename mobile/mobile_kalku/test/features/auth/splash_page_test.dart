import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:mobile_kalku/core/security/session_service.dart';
import 'package:mobile_kalku/data/models/user_session.dart';
import 'package:mobile_kalku/features/auth/pages/splash_page.dart';

class FakeSplashSessionService implements SessionService {
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

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  tearDown(() async {
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
}
