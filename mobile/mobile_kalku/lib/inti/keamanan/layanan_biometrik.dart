import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth/error_codes.dart' as auth_error;
import '../domain/biometric_result.dart';
import '../../data/repositories/auth_repository.dart';

/// Handles all device biometric authentication interactions.
///
/// Responsibilities:
///   - Check device hardware support and biometric enrollment.
///   - Invoke OS biometric prompt.
///   - Map PlatformException error codes to typed [BiometricAuthResult].
///   - Read / update biometric preference via [AuthRepository].
///
/// The application NEVER stores fingerprint templates or face data.
/// It only invokes biometric authentication already configured by the OS.
///
/// Biometric login is DEFAULT OFF (users.biometric_enabled = 0).
/// It can only be enabled through explicit user consent after a successful
/// password-based authentication AND a successful biometric verification.
class BiometricService {
  final LocalAuthentication _localAuth;
  final AuthRepository _authRepository;

  /// Dependencies are injectable so unit tests can supply fakes/mocks.
  BiometricService({
    LocalAuthentication? localAuth,
    required AuthRepository authRepository,
  })  : _localAuth = localAuth ?? LocalAuthentication(),
        _authRepository = authRepository;

  // ─── Availability ─────────────────────────────────────────────────────────

  /// Checks whether biometric authentication is available and enrolled on
  /// the current device.
  Future<BiometricAvailability> getAvailability() async {
    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      final isSupported = await _localAuth.isDeviceSupported();

      if (!isSupported || !canCheck) {
        return BiometricAvailability.unavailable;
      }

      final enrolled = await _localAuth.getAvailableBiometrics();
      if (enrolled.isEmpty) {
        return BiometricAvailability.notEnrolled;
      }

      return BiometricAvailability.available;
    } on PlatformException {
      return BiometricAvailability.unavailable;
    }
  }

  // ─── Authentication ────────────────────────────────────────────────────────

  /// Invokes the OS biometric prompt and returns a typed [BiometricAuthResult].
  ///
  /// PlatformExceptions are mapped to [BiometricStatus] values; raw
  /// platform errors never propagate to UI code.
  Future<BiometricAuthResult> authenticate() async {
    try {
      final success = await _localAuth.authenticate(
        localizedReason: 'Verifikasi biometrik untuk masuk ke NusaFit',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );

      if (success) {
        return const BiometricAuthResult(status: BiometricStatus.success);
      }
      // authenticate() returning false means the user cancelled.
      return const BiometricAuthResult(status: BiometricStatus.cancelled);
    } on PlatformException catch (e) {
      return _mapPlatformException(e);
    }
  }

  // ─── Preference helpers ───────────────────────────────────────────────────

  /// Returns true when:
  ///   - the user has biometric_enabled = 1 in the database, AND
  ///   - the device currently supports biometric authentication.
  Future<bool> canUseBiometricLoginForUser(int userId) async {
    final user = await _authRepository.findUserById(userId);
    if (user == null || !user.biometricEnabled) return false;
    final availability = await getAvailability();
    return availability == BiometricAvailability.available;
  }

  /// Enables biometric login for [userId] in the database.
  ///
  /// IMPORTANT: callers MUST invoke OS biometric verification and confirm
  /// success BEFORE calling this method. This method only persists the DB flag.
  Future<void> enableForUser(int userId) async {
    await _authRepository.setBiometricEnabled(userId: userId, enabled: true);
  }

  /// Disables biometric login for [userId] in the database.
  ///
  /// Does NOT remove OS fingerprint/face enrollment — it only clears the
  /// application-level preference (users.biometric_enabled = 0).
  Future<void> disableForUser(int userId) async {
    await _authRepository.setBiometricEnabled(userId: userId, enabled: false);
  }

  // ─── Private ──────────────────────────────────────────────────────────────

  BiometricAuthResult _mapPlatformException(PlatformException e) {
    switch (e.code) {
      case auth_error.notAvailable:
        return const BiometricAuthResult(
          status: BiometricStatus.unavailable,
          safeMessage: 'Biometrik tidak tersedia pada perangkat ini.',
        );
      case auth_error.notEnrolled:
        return const BiometricAuthResult(
          status: BiometricStatus.notEnrolled,
          safeMessage: 'Biometrik belum didaftarkan pada perangkat.',
        );
      case auth_error.lockedOut:
        return const BiometricAuthResult(
          status: BiometricStatus.lockedOut,
          safeMessage: 'Terlalu banyak percobaan. Coba lagi sebentar.',
        );
      case auth_error.permanentlyLockedOut:
        return const BiometricAuthResult(
          status: BiometricStatus.permanentlyLockedOut,
          safeMessage: 'Biometrik terkunci. Gunakan PIN/kata sandi perangkat.',
        );
      default:
        return BiometricAuthResult(
          status: BiometricStatus.error,
          safeMessage: 'Verifikasi gagal. Silakan coba lagi.',
        );
    }
  }
}
