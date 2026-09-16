import 'package:flutter/material.dart';

import '../../../inti/konstanta/warna_aplikasi.dart';
import '../../../inti/konstanta/dimensi_aplikasi.dart';
import '../../../inti/konstanta/teks_aplikasi.dart';
import '../../../inti/basis_data/pengelola_basis_data.dart';
import '../../../data/model/pengguna.dart';
import '../../../data/repositori/repositori_bmi.dart';
import '../../bmi/halaman/halaman_perhitungan_bmi.dart';
import '../../bmi/halaman/halaman_riwayat_bmi.dart';
import '../../kalender_nusantara/halaman/halaman_kalender_nusantara.dart';
import '../../konversi_tanggal/halaman/halaman_konversi_tanggal.dart';
import '../../anggota/halaman/halaman_anggota.dart';
import '../komponen/kartu_menu_beranda.dart';

/// Tab Beranda: menampilkan header ucapan selamat datang dan 5 menu utama
/// (Sesuai MENU_IMPLEMENTATION.md #4). Halaman ini tidak berisi logika BMI/kalender
/// — hanya melakukan navigasi menggunakan `Navigator.push()`.
///
/// Parameter [user] adalah pengguna yang terautentikasi dari Splash/Login,
/// yang diteruskan ke halaman BMI (kalkulator, riwayat) agar rekam data sesuai dengan pengguna tersebut.
class HomePage extends StatelessWidget {
  const HomePage({super.key, required this.user});

  final User user;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const _HomeHeader(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(AppDimensions.screenHorizontalPadding),
                children: [
                  HomeMenuCard(
                    icon: Icons.groups_outlined,
                    title: AppStrings.menuMembersTitle,
                    description: AppStrings.menuMembersDesc,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const MembersPage()),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.fieldGap),
                  HomeMenuCard(
                    icon: Icons.monitor_weight_outlined,
                    title: AppStrings.menuBmiCalculatorTitle,
                    description: AppStrings.menuBmiCalculatorDesc,
                    onTap: () async {
                      final db = await DatabaseHelper.instance.database;
                      final repo = BmiRepository(db);
                      if (!context.mounted) return;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BmiCalculatorPage(
                            user: user,
                            bmiRepository: repo,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: AppDimensions.fieldGap),
                  HomeMenuCard(
                    icon: Icons.history_outlined,
                    title: AppStrings.menuBmiHistoryTitle,
                    description: AppStrings.menuBmiHistoryDesc,
                    onTap: () async {
                      final db = await DatabaseHelper.instance.database;
                      final repo = BmiRepository(db);
                      if (!context.mounted) return;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BmiHistoryPage(
                            user: user,
                            bmiRepository: repo,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: AppDimensions.fieldGap),
                  HomeMenuCard(
                    icon: Icons.calendar_month_outlined,
                    title: AppStrings.menuDateConverterTitle,
                    description: AppStrings.menuDateConverterDesc,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const DateConverterPage()),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.fieldGap),
                  HomeMenuCard(
                    icon: Icons.temple_hindu_outlined,
                    title: AppStrings.menuCalendarTitle,
                    description: AppStrings.menuCalendarDesc,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const NusantaraCalendarPage()),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.screenHorizontalPadding,
        AppDimensions.space24,
        AppDimensions.screenHorizontalPadding,
        AppDimensions.space32,
      ),
      decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.appName,
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 4),
          Text(
            AppStrings.appSubtitle,
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
        ],
      ),
    );
  }
}