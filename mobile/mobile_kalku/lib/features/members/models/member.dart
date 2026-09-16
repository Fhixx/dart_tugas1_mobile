/// A single group-member entry shown on the "Daftar Anggota" screen.
///
/// This is constant metadata (MENU_IMPLEMENTATION.md #5), not something
/// stored in SQLite.
class Member {
  const Member({
    required this.name,
    required this.nim,
    required this.role,
    this.avatarAssetPath,
  });

  final String name;
  final String nim;
  final String role;

  /// Optional local asset path. When null or the asset fails to load,
  /// the UI falls back to an initials avatar per MENU_IMPLEMENTATION.md #5.
  final String? avatarAssetPath;

  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }
}
