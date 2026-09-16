import 'package:flutter/material.dart';
import '../../../inti/keamanan/kontrak_autentikasi.dart';
import '../../../inti/keamanan/layanan_biometrik.dart';
import '../../../inti/keamanan/layanan_sesi.dart';
import '../../../data/model/pengguna.dart';
import '../../../data/repositori/repositori_autentikasi.dart';
import '../pengontrol/pengontrol_login.dart';

/// User login screen supporting credential login and biometric authentication.
class LoginPage extends StatefulWidget {
  final LoginController? controller;
  final AuthenticatedPageBuilder? authenticatedBuilder;

  const LoginPage({
    super.key,
    this.controller,
    this.authenticatedBuilder,
  });

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late final LoginController _controller;
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    if (widget.controller != null) {
      _controller = widget.controller!;
    } else {
      final authRepo = AuthRepository();
      _controller = LoginController(
        authRepository: authRepo,
        sessionService: SessionService(),
        biometricService: BiometricService(authRepository: authRepo),
      );
    }
    _controller.init();
    _controller.addListener(_onControllerUpdate);
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerUpdate);
    if (widget.controller == null) {
      _controller.dispose();
    }
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onControllerUpdate() {
    if (mounted) setState(() {});
  }

  Future<void> _handleCredentialLogin() async {
    final user = await _controller.login(
      rawUsername: _usernameController.text,
      rawPassword: _passwordController.text,
    );

    if (user != null && mounted) {
      _currentUser = user;
      await _checkAndOfferBiometrics(user);
    }
  }

  Future<void> _handleBiometricLogin() async {
    final user = await _controller.loginWithBiometrics();
    if (user != null && mounted) {
      _currentUser = user;
      _navigateToMain();
    }
  }

  Future<void> _checkAndOfferBiometrics(User user) async {
    if (_controller.isBiometricAvailable && !user.biometricEnabled && user.id != null) {
      final bool? wantEnable = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.fingerprint, color: Colors.blue),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  "Aktifkan Biometrik",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          content: const Text(
            "Login lebih cepat dan aman dengan sidik jari atau wajah Anda di lain waktu.",
            style: TextStyle(fontSize: 14, color: Colors.black54),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text(
                "Nanti",
                style: TextStyle(color: Colors.black54),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text("Aktifkan"),
            ),
          ],
        ),
      );

      if (wantEnable == true && user.id != null) {
        await _controller.enableBiometricForUser(user.id!);
      }
    }

    if (mounted) {
      _navigateToMain();
    }
  }

  void _navigateToMain() {
    if (widget.authenticatedBuilder != null && _currentUser != null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (ctx) => widget.authenticatedBuilder!(ctx, _currentUser!),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Navigation error or user not found.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ── Brand Header ─────────────────────────────────────────────
                _buildHeader(),
                const SizedBox(height: 24),

                // ── Login Card ───────────────────────────────────────────────
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          "Selamat Datang",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          "Silakan masuk ke akun Anda",
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Error Alert Banner
                        if (_controller.generalError != null) ...[
                          _buildErrorBanner(_controller.generalError!),
                          const SizedBox(height: 16),
                        ],

                        // Username Input
                        TextFormField(
                          controller: _usernameController,
                          decoration: InputDecoration(
                            labelText: "Username",
                            hintText: "Masukkan username Anda",
                            errorText: _controller.usernameError,
                            prefixIcon: const Icon(
                              Icons.person_outline_rounded,
                              color: Colors.blue,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          textInputAction: TextInputAction.next,
                          enabled: !_controller.isLoading,
                        ),
                        const SizedBox(height: 16),

                        // Password Input
                        TextFormField(
                          controller: _passwordController,
                          decoration: InputDecoration(
                            labelText: "Password",
                            hintText: "Masukkan password Anda",
                            errorText: _controller.passwordError,
                            prefixIcon: const Icon(
                              Icons.lock_outline_rounded,
                              color: Colors.blue,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _controller.isPasswordVisible
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: Colors.black38,
                              ),
                              onPressed: _controller.togglePasswordVisibility,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          obscureText: !_controller.isPasswordVisible,
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => _handleCredentialLogin(),
                          enabled: !_controller.isLoading,
                        ),
                        const SizedBox(height: 24),

                        // Submit Button
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: _controller.isLoading ? null : _handleCredentialLogin,
                          child: _controller.isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  "Masuk",
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                        ),

                        // Biometric Login Button
                        if (_controller.canShowBiometricButton) ...[
                          const SizedBox(height: 16),
                          OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 48),
                              side: const BorderSide(color: Colors.blue),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: _controller.isLoading ? null : _handleBiometricLogin,
                            icon: const Icon(Icons.fingerprint, color: Colors.blue),
                            label: const Text(
                              "Login dengan Biometrik",
                              style: TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: const BoxDecoration(
            color: Colors.blue,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 12,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: const Center(
            child: Icon(
              Icons.health_and_safety_rounded,
              size: 40,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          "NusaFit",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          "Aplikasi Kesehatan Terpadu",
          style: TextStyle(
            fontSize: 14,
            color: Colors.black54,
          ),
        ),
      ],
    );
  }

  Widget _buildErrorBanner(String message) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: Colors.red,
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.red,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
