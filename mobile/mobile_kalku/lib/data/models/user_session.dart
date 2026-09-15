/// Immutable model representing an authenticated user session.
///
/// Stored in secure storage via [SessionService]. Does NOT include
/// password hash or salt — those fields must never enter session data.
class UserSession {
  final int userId;
  final String username;
  final String role;
  final bool isLoggedIn;

  const UserSession({
    required this.userId,
    required this.username,
    required this.role,
    required this.isLoggedIn,
  });

  /// Returns true only when all required fields are structurally valid.
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

      if (userIdStr == null ||
          username == null ||
          role == null ||
          isLoggedInStr == null) {
        return null;
      }

      final userId = int.tryParse(userIdStr);
      if (userId == null || userId <= 0) return null;

      final isLoggedIn = isLoggedInStr == 'true';
      if (username.isEmpty || role.isEmpty) return null;

      return UserSession(
        userId: userId,
        username: username,
        role: role,
        isLoggedIn: isLoggedIn,
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
      };
}
