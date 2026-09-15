import 'package:flutter/material.dart';
import 'features/auth/pages/splash_page.dart';
import 'data/models/user.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const _TempDev1App());
}

/// Minimal temporary app root for Dev 1 to test the Auth module.
/// Developer 2 will replace this logic with the real App/MainShell.
class _TempDev1App extends StatelessWidget {
  const _TempDev1App();

  @override
  Widget build(BuildContext context) {
    Widget dummyBuilder(BuildContext context, User user) {
      return Scaffold(
        appBar: AppBar(title: const Text('Authenticated (Temp)')),
        body: Center(child: Text('Welcome, ${user.username}')),
      );
    }

    return MaterialApp(
      title: 'NusaFit Temp',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      home: SplashPage(
        authenticatedBuilder: dummyBuilder,
      ),
    );
  }
}
