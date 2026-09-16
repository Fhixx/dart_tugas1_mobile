/// Entri tunggal anggota kelompok yang ditampilkan pada layar "Daftar Anggota".
///
/// Ini adalah metadata konstan (Sesuai MENU_IMPLEMENTATION.md #5), bukan sesuatu
/// yang disimpan dalam SQLite.
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

  /// Path aset lokal opsional. Jika null atau aset gagal dimuat,
  /// UI akan menggunakan inisial sebagai avatar sesuai MENU_IMPLEMENTATION.md #5.
  final String? avatarAssetPath;

  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }
}
