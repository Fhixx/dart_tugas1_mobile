import 'package:flutter/material.dart';
import 'features/auth/pages/splash_page.dart';
import 'features/auth/pages/login_page.dart';
import 'features/home/pages/main_shell.dart';
import 'core/security/session_service.dart';
import 'core/security/auth_contract.dart';
import 'data/models/user.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const NusaFitApp());
}

/// Final NusaFit application entry point.
/// Uses SplashPage for initialization, then routes to MainShell when authenticated.
class NusaFitApp extends StatelessWidget {
  const NusaFitApp({super.key});

  @override
  Widget build(BuildContext context) {
    Widget authenticatedBuilder(BuildContext context, User user) {
      return MainShell(
        user: user,
        onLogoutConfirmed: () async {
          final sessionService = SessionService();
          await sessionService.clearSession();
          if (context.mounted) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (ctx) => LoginPage(
                  authenticatedBuilder: authenticatedBuilder,
                ),
              ),
              (_) => false,
            );
          }
        },
      );
    }

    return MaterialApp(
      title: 'NusaFit',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      home: SplashPage(
        authenticatedBuilder: authenticatedBuilder,
      ),
    );
  }
}
