import 'package:flutter/material.dart';
import 'fitur/autentikasi/halaman/halaman_splash.dart';
import 'fitur/autentikasi/halaman/halaman_login.dart';
import 'fitur/beranda/halaman/kerangka_utama.dart';
import 'inti/keamanan/layanan_sesi.dart';
import 'data/model/pengguna.dart';

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