import 'package:flutter/foundation.dart';
import '../../../core/domain/auth_result.dart';
import '../../../core/domain/biometric_result.dart';
import '../../../core/security/biometric_service.dart';
import '../../../core/security/session_service.dart';
import '../../../core/utils/sanitizers.dart';
import '../../../core/utils/validators.dart';
import '../../../data/models/user.dart';
import '../../../data/models/user_session.dart';
import '../../../data/repositories/auth_repository.dart';

/// State and logic controller for the Login screen.
class LoginController extends ChangeNotifier {
  final AuthRepository _authRepository;
  final SessionService _sessionService;
  final BiometricService _biometricService;

  LoginController({
    required AuthRepository authRepository,
    required SessionService sessionService,
    required BiometricService biometricService,
  })  : _authRepository = authRepository,
        _sessionService = sessionService,
        _biometricService = biometricService;

  bool _isLoading = false;
  bool _isPasswordVisible = false;
  String? _usernameError;
  String? _passwordError;
  String? _generalError;
  BiometricAvailability _biometricAvailability = BiometricAvailability.unavailable;
  bool _isBiometricSupportedForLogin = false;

  // ── Getters ────────────────────────────────────────────────────────────────
  bool get isLoading => _isLoading;
  bool get isPasswordVisible => _isPasswordVisible;
  String? get usernameError => _usernameError;
  String? get passwordError => _passwordError;
  String? get generalError => _generalError;
  bool get isBiometricAvailable =>
      _biometricAvailability == BiometricAvailability.available;
  bool get canShowBiometricButton =>
      isBiometricAvailable && _isBiometricSupportedForLogin;

  // ── Initialization ─────────────────────────────────────────────────────────
  Future<void> init() async {
    _biometricAvailability = await _biometricService.getAvailability();
    final userWithBiometrics = await _authRepository.findBiometricEnabledUser();
    _isBiometricSupportedForLogin = userWithBiometrics != null;
    notifyListeners();
  }

  // ── UI Actions ─────────────────────────────────────────────────────────────
  void togglePasswordVisibility() {
    _isPasswordVisible = !_isPasswordVisible;
    notifyListeners();
  }

  void clearErrors() {
    _usernameError = null;
    _passwordError = null;
    _generalError = null;
    notifyListeners();
  }

  // ── Credential Login ───────────────────────────────────────────────────────
  Future<User?> login({
    required String rawUsername,
    required String rawPassword,
  }) async {
    if (_isLoading) return null;

    clearErrors();

    final username = Sanitizers.sanitizeUsername(rawUsername);
    final password = rawPassword.trim();

    // Validate inputs
    final userVal = Validators.validateUsername(username);
    if (userVal != null) {
      _usernameError = userVal;
      notifyListeners();
      return null;
    }

    final passVal = Validators.validatePassword(password);
    if (passVal != null) {
      _passwordError = passVal;
      notifyListeners();
      return null;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final AuthResult result = await _authRepository.login(
        username: username,
        password: password,
      );

      if (result.isSuccess && result.user != null) {
        final user = result.user as User;
        final session = UserSession(
          userId: user.id ?? 0,
          username: user.username,
          role: user.role,
          isLoggedIn: true,
        );
        await _sessionService.saveSession(session);
        _isLoading = false;
        notifyListeners();
        return user;
      } else if (result.status == AuthStatus.inactiveUser) {
        _generalError = "Akun telah dinonaktifkan.";
      } else {
        _generalError = "Username atau password salah.";
      }
    } catch (_) {
      _generalError = "Username atau password salah.";
    } finally {
      _isLoading = false;
      notifyListeners();
    }

    return null;
  }

  // ── Biometric Login ────────────────────────────────────────────────────────
  Future<User?> loginWithBiometrics() async {
    if (_isLoading) return null;

    clearErrors();
    _isLoading = true;
    notifyListeners();

    try {
      final user = await _authRepository.findBiometricEnabledUser();
      if (user == null) {
        _generalError = "Biometrik tidak diaktifkan untuk akun ini.";
        _isLoading = false;
        notifyListeners();
        return null;
      }

      final BiometricAuthResult bioResult = await _biometricService.authenticate();

      if (bioResult.isSuccess) {
        final session = UserSession(
          userId: user.id ?? 0,
          username: user.username,
          role: user.role,
          isLoggedIn: true,
        );
        await _sessionService.saveSession(session);
        _isLoading = false;
        notifyListeners();
        return user;
      } else {
        switch (bioResult.status) {
          case BiometricStatus.unavailable:
            _generalError = "Fitur biometrik tidak tersedia di perangkat ini.";
            break;
          case BiometricStatus.notEnrolled:
            _generalError = "Tidak ada data sidik jari atau wajah yang terdaftar di perangkat ini.";
            break;
          case BiometricStatus.cancelled:
            _generalError = "Autentikasi biometrik dibatalkan.";
            break;
          case BiometricStatus.lockedOut:
          case BiometricStatus.permanentlyLockedOut:
            _generalError = "Biometrik terkunci sementara. Silakan coba lagi nanti atau gunakan password.";
            break;
          default:
            _generalError = bioResult.safeMessage ?? "Username atau password salah.";
        }
      }
    } catch (_) {
      _generalError = "Username atau password salah.";
    } finally {
      _isLoading = false;
      notifyListeners();
    }

    return null;
  }

  // ── Biometric Enrollment Offer ─────────────────────────────────────────────
  Future<void> enableBiometricForUser(int userId) async {
    await _biometricService.enableForUser(userId);
    _isBiometricSupportedForLogin = true;
    notifyListeners();
  }
}
