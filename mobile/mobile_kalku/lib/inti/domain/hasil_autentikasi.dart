/// Authentication status returned by [AuthRepository.login].
enum AuthStatus {
  /// Credentials verified; user is active.
  success,

  /// Username not found or password did not match.
  /// Always reported with the same generic message to prevent enumeration.
  invalidCredentials,

  /// User account exists but [User.isActive] is false.
  inactiveUser,

  /// An unexpected database or storage error occurred.
  databaseError,
}

/// Typed result returned by [AuthRepository.login].
///
/// On [AuthStatus.success] the [user] field is guaranteed non-null.
/// On any failure [user] is null and [safeMessage] contains the user-facing
/// message (no internal detail exposed).
class AuthResult {
  final AuthStatus status;

  /// Non-null on [AuthStatus.success].
  final dynamic user; // typed as dynamic to avoid circular import with User model

  /// Safe, user-visible error message; null on success.
  final String? safeMessage;

  const AuthResult({
    required this.status,
    this.user,
    this.safeMessage,
  });

  bool get isSuccess => status == AuthStatus.success;
}
