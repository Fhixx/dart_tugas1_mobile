/// Status codes for a biometric authentication attempt.
enum BiometricStatus {
  /// OS verified the biometric successfully.
  success,

  /// Biometric hardware not present on this device.
  unavailable,

  /// Hardware present but no biometrics enrolled in the OS.
  notEnrolled,

  /// Authentication attempt failed (wrong finger/face).
  failed,

  /// User dismissed / cancelled the OS prompt.
  cancelled,

  /// Temporarily locked after too many failures. Retry after a brief wait.
  lockedOut,

  /// Permanently locked; requires device PIN/password to unlock.
  permanentlyLockedOut,

  /// Application-level preference has biometric login disabled for this user.
  disabledByUser,

  /// An unclassified platform error occurred.
  error,
}

/// Typed result returned by [BiometricService.authenticate].
class BiometricAuthResult {
  final BiometricStatus status;

  /// Optional safe, user-visible message for failure states.
  final String? safeMessage;

  const BiometricAuthResult({
    required this.status,
    this.safeMessage,
  });

  bool get isSuccess => status == BiometricStatus.success;
}

/// Availability of biometric authentication on the current device.
enum BiometricAvailability {
  /// Hardware exists and at least one biometric is enrolled.
  available,

  /// Hardware exists but no biometrics are enrolled.
  notEnrolled,

  /// No biometric hardware detected.
  unavailable,
}
