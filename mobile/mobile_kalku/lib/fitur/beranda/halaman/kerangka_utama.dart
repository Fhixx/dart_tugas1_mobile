import 'package:flutter/material.dart';

import '../../../inti/konstanta/warna_aplikasi.dart';
import '../../../inti/konstanta/teks_aplikasi.dart';
import '../../../data/model/pengguna.dart';
import '../../../komponen/dialog_konfirmasi.dart';
import '../../panduan/halaman/halaman_panduan.dart';
import '../../stopwatch/halaman/halaman_stopwatch.dart';
import 'halaman_beranda.dart';

/// Kerangka utama setelah login: menyediakan navigasi bawah (bottom navigation)
/// antara Beranda / Stopwatch / Panduan, serta aksi Keluar (Logout)
/// (Sesuai MENU_IMPLEMENTATION.md #3).
///
/// Menggunakan `IndexedStack` agar Stopwatch tetap berjalan saat pengguna
/// berpindah tab (Sesuai COMPUTATION_LOGIC.md #11 / MENU_IMPLEMENTATION.md #13).
/// Keluar (Logout) BUKANLAH konten tab — menekannya hanya akan memunculkan dialog
/// konfirmasi dan tidak akan pernah mengubah `_currentIndex`.
///
/// [onLogoutConfirmed] adalah titik integrasi untuk `SessionService` dari Developer 1
/// beserta navigasi Login. Sebelum hal tersebut dihubungkan, implementasi bawaan
/// hanya akan menutup dialog dan menampilkan pesan sementara — harus diganti
/// setelah `SessionService.clearSession()` tersedia.
class MainShell extends StatefulWidget {
  const MainShell({
    super.key,
    required this.user,
    this.onLogoutConfirmed,
  });

  final User user;
  final VoidCallback? onLogoutConfirmed;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  List<Widget> get _tabs => [
        HomePage(user: widget.user),
        const StopwatchPage(),
        const HelpPage(),
      ];

  Future<void> _handleTap(int index) async {
    if (index == 3) {
      final confirmed = await ConfirmationDialog.show(
        context,
        title: AppStrings.dialogLogoutConfirmTitle,
        message: AppStrings.dialogLogoutConfirmMessage,
        confirmLabel: AppStrings.dialogLogoutConfirmAction,
      );
      if (confirmed == true) {
        _performLogout();
      }
      return;
    }
    setState(() => _currentIndex = index);
  }

  Future<void> _performLogout() async {
    if (widget.onLogoutConfirmed != null) {
      widget.onLogoutConfirmed!();
      return;
    }
    // TODO(dev1): replace with SessionService.clearSession() then
    // Navigator.pushAndRemoveUntil(context, LoginPage route, (_) => false).
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Logout stub — SessionService Developer 1 belum terpasang.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _tabs),
      bottomNavigationBar: _MainBottomNav(
        currentIndex: _currentIndex,
        onTap: _handleTap,
      ),
    );
  }
}

class _MainBottomNav extends StatelessWidget {
  const _MainBottomNav({required this.currentIndex, required this.onTap});

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: onTap,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: AppColors.navSelected,
          unselectedItemColor: AppColors.navUnselected,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: AppStrings.navHome,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.timer_outlined),
              activeIcon: Icon(Icons.timer),
              label: AppStrings.navStopwatch,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.menu_book_outlined),
              activeIcon: Icon(Icons.menu_book),
              label: AppStrings.navPanduan,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.logout, color: AppColors.navLogout),
              label: AppStrings.navLogout,
            ),
          ],
        ),
      ),
    );
  }
}