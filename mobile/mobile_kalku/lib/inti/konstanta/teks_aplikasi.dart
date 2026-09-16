/// Central copy/string tokens for NusaFit.
///
/// Brand name is mandatory per DESIGN_SYSTEM.md #1 — do not rename.
class AppStrings {
  AppStrings._();

  static const String appName = 'Kalkulator BMI';
  static const String appSubtitle = 'BMI & Kalender Nusantara';

  // Bottom navigation
  static const String navHome = 'Home';
  static const String navStopwatch = 'Stopwatch';
  static const String navPanduan = 'Panduan';
  static const String navLogout = 'Logout';

  // Home menu (see PRD #113 Suggested Home Copy)
  static const String menuMembersTitle = 'Daftar Anggota';
  static const String menuMembersDesc = 'Lihat anggota kelompok';

  static const String menuBmiCalculatorTitle = 'Kalkulator BMI';
  static const String menuBmiCalculatorDesc = 'Hitung indeks massa tubuh';

  static const String menuBmiHistoryTitle = 'Riwayat BMI';
  static const String menuBmiHistoryDesc = 'Kelola hasil perhitungan';

  static const String menuDateConverterTitle = 'Konversi Tanggal & Umur';
  static const String menuDateConverterDesc = 'Hitung umur dan kalender';

  static const String menuCalendarTitle = 'Kalender Nusantara';
  static const String menuCalendarDesc = 'Weton Jawa dan Saka Bali';

  // Generic snackbar (DESIGN_SYSTEM.md #20)
  static const String snackbarSaveSuccess = 'Data berhasil disimpan.';
  static const String snackbarSaveError = 'Data gagal disimpan. Silakan coba lagi.';
  static const String snackbarUpdateSuccess = 'Data berhasil diperbarui.';
  static const String snackbarDeleteSuccess = 'Data berhasil dihapus.';

  // Confirmation dialogs
  static const String dialogCancel = 'Batal';
  static const String dialogDeleteConfirmTitle = 'Hapus Data';
  static const String dialogDeleteConfirmAction = 'Hapus';
  static const String dialogLogoutConfirmTitle = 'Logout';
  static const String dialogLogoutConfirmMessage = 'Apakah Anda yakin ingin logout?';
  static const String dialogLogoutConfirmAction = 'Logout';

  // Generic error/empty (feature-specific copy stays in each feature)
  static const String genericErrorMessage = 'Terjadi kesalahan. Silakan coba lagi.';
  static const String genericRetry = 'Coba Lagi';
  static const String genericEmptyTitle = 'Belum Ada Data';
}
