/// Immutable model representing an authenticated user session.
///
/// Stored in secure storage via [SessionService]. Does NOT include
/// password hash or salt — those fields must never enter session data.
///
/// Timestamps are stored and compared in UTC to avoid timezone issues.
class UserSession {
  final int userId;
  final String username;
  final String role;
  final bool isLoggedIn;

  /// UTC timestamp when the user successfully authenticated.
  final DateTime authenticatedAt;

  /// UTC timestamp when this session expires (authenticatedAt + 30 minutes).
  final DateTime expiresAt;

  const UserSession({
    required this.userId,
    required this.username,
    required this.role,
    required this.isLoggedIn,
    required this.authenticatedAt,
    required this.expiresAt,
  });

  /// Returns true only when all required fields are structurally valid.
  ///
  /// NOTE: This checks structural validity only (fields not empty/zero).
  /// Expiration must be checked separately via [SessionService.isSessionExpired].
  bool get isValid =>
      userId > 0 && username.isNotEmpty && role.isNotEmpty && isLoggedIn;

  /// Deserialises from the flat map stored in secure storage.
  /// Returns null if any required key is absent or unparseable.
  static UserSession? fromStorageMap(Map<String, String?> map) {
    try {
      final userIdStr = map['userId'];
      final username = map['username'];
      final role = map['role'];
      final isLoggedInStr = map['isLoggedIn'];
      final authenticatedAtStr = map['authenticatedAt'];
      final expiresAtStr = map['expiresAt'];

      if (userIdStr == null ||
          username == null ||
          role == null ||
          isLoggedInStr == null ||
          authenticatedAtStr == null ||
          expiresAtStr == null) {
        return null;
      }

      final userId = int.tryParse(userIdStr);
      if (userId == null || userId <= 0) return null;

      final isLoggedIn = isLoggedInStr == 'true';
      if (username.isEmpty || role.isEmpty) return null;

      final authenticatedAt = DateTime.tryParse(authenticatedAtStr);
      if (authenticatedAt == null) return null;

      final expiresAt = DateTime.tryParse(expiresAtStr);
      if (expiresAt == null) return null;

      return UserSession(
        userId: userId,
        username: username,
        role: role,
        isLoggedIn: isLoggedIn,
        authenticatedAt: authenticatedAt.toUtc(),
        expiresAt: expiresAt.toUtc(),
      );
    } catch (_) {
      return null;
    }
  }

  /// Serialises to a flat map for secure storage.
  Map<String, String> toStorageMap() => {
        'userId': userId.toString(),
        'username': username,
        'role': role,
        'isLoggedIn': isLoggedIn.toString(),
        'authenticatedAt': authenticatedAt.toUtc().toIso8601String(),
        'expiresAt': expiresAt.toUtc().toIso8601String(),
      };
}
