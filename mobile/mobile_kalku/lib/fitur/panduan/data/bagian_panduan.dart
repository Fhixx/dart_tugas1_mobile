import 'package:flutter/material.dart';

/// Immutable content for one accordion section on the Panduan screen.
class HelpSection {
  const HelpSection({
    required this.icon,
    required this.title,
    required this.steps,
  });

  final IconData icon;
  final String title;
  final List<String> steps;
}

/// The 15 required Panduan topics (MENU_IMPLEMENTATION.md #14).
///
/// Step text here is intentionally generic/placeholder-light — refine the
/// wording once each real screen's copy is final, but keep the topic list
/// and order as-is (it's a PRD requirement, not just a suggestion).
const List<HelpSection> kHelpSections = [
  HelpSection(
    icon: Icons.login,
    title: 'Cara Login',
    steps: [
      'Buka aplikasi, masukkan username dan password pada halaman Login.',
      'Tekan tombol Masuk. Jika data benar, Anda akan diarahkan ke Home.',
      'Jika username/password salah, aplikasi menampilkan pesan generik "Username atau password salah."',
    ],
  ),
  HelpSection(
    icon: Icons.fingerprint,
    title: 'Login Biometrik',
    steps: [
      'Pastikan perangkat memiliki sidik jari/wajah yang terdaftar di pengaturan OS.',
      'Pada halaman Login, tekan tombol biometrik.',
      'Ikuti verifikasi dari sistem operasi perangkat Anda.',
      'Jika berhasil dan biometrik pernah diaktifkan untuk akun ini, sesi akan dibuat otomatis.',
    ],
  ),
  HelpSection(
    icon: Icons.home_outlined,
    title: 'Menu Utama',
    steps: [
      'Home menampilkan 5 menu utama secara vertikal.',
      'Ketuk salah satu kartu menu untuk membuka fitur terkait.',
      'Gunakan navigasi bawah untuk berpindah ke Stopwatch, Panduan, atau Logout.',
    ],
  ),
  HelpSection(
    icon: Icons.monitor_weight_outlined,
    title: 'BMI',
    steps: [
      'Buka menu Kalkulator BMI dari Home.',
      'Isi nama, umur, berat (kg), dan tinggi (cm).',
      'Tekan Hitung BMI untuk melihat hasil.',
    ],
  ),
  HelpSection(
    icon: Icons.insights_outlined,
    title: 'Hasil BMI',
    steps: [
      'Halaman hasil menampilkan nilai BMI dan kategorinya (Underweight/Normal/Overweight/Obesitas).',
      'Tekan Simpan Hasil untuk menyimpan ke riwayat, atau Kembali untuk mengubah input.',
    ],
  ),
  HelpSection(
    icon: Icons.history_outlined,
    title: 'Riwayat',
    steps: [
      'Buka menu Riwayat BMI dari Home.',
      'Daftar hasil BMI yang tersimpan ditampilkan terbaru lebih dahulu.',
      'Ketuk salah satu item untuk melihat detail, mengedit, atau menghapus.',
    ],
  ),
  HelpSection(
    icon: Icons.edit_outlined,
    title: 'Edit BMI',
    steps: [
      'Dari Riwayat, ketuk aksi Edit pada data yang ingin diubah.',
      'Ubah nama/umur/berat/tinggi sesuai kebutuhan.',
      'BMI dan kategori dihitung ulang otomatis saat disimpan — tidak bisa diisi manual.',
    ],
  ),
  HelpSection(
    icon: Icons.delete_outline,
    title: 'Hapus BMI',
    steps: [
      'Dari Riwayat, ketuk aksi Hapus pada data yang ingin dihapus.',
      'Konfirmasi pada dialog yang muncul — tindakan ini tidak dapat dibatalkan.',
    ],
  ),
  HelpSection(
    icon: Icons.calendar_month_outlined,
    title: 'Konversi Tanggal',
    steps: [
      'Buka menu Konversi Tanggal & Umur dari Home.',
      'Pilih satu tanggal (dan waktu, opsional) — semua hasil konversi mengikuti tanggal ini.',
      'Gunakan filter segmen untuk menampilkan kartu Masehi/Hijriah/Weton/Saka Bali tertentu saja.',
    ],
  ),
  HelpSection(
    icon: Icons.hourglass_bottom_outlined,
    title: 'Usia',
    steps: [
      'Kartu Usia menampilkan umur real-time: tahun, bulan, hari, jam, menit, detik.',
      'Nilai ini diperbarui otomatis setiap detik selagi halaman terbuka.',
    ],
  ),
  HelpSection(
    icon: Icons.brightness_3_outlined,
    title: 'Hijriah',
    steps: [
      'Tanggal Hijriah dihitung secara algoritmik/offline dari tanggal Masehi yang dipilih.',
      'Hasil dapat berbeda 1-2 hari dari penetapan resmi berbasis rukyat/hisab pemerintah.',
    ],
  ),
  HelpSection(
    icon: Icons.brightness_5_outlined,
    title: 'Weton',
    steps: [
      'Weton menggabungkan hari Masehi (7 hari) dan pasaran Jawa (5 hari: Legi, Pahing, Pon, Wage, Kliwon).',
      'Neptu weton adalah jumlah neptu hari dan neptu pasaran.',
    ],
  ),
  HelpSection(
    icon: Icons.temple_hindu_outlined,
    title: 'Saka Bali',
    steps: [
      'Menampilkan Wuku, Pancawara, dan Saptawara dari tanggal yang dipilih.',
      'Sasih dan Tahun Saka presisi belum tersedia pada versi ini — akan menyusul setelah algoritma lunisolarnya diverifikasi.',
    ],
  ),
  HelpSection(
    icon: Icons.timer_outlined,
    title: 'Stopwatch',
    steps: [
      'Tekan Mulai untuk menjalankan stopwatch.',
      'Tekan Jeda untuk menghentikan sementara, Lanjutkan untuk melanjutkan.',
      'Tekan Reset untuk mengembalikan ke 00:00:00.00.',
      'Stopwatch tetap berjalan meski Anda berpindah ke tab Home/Panduan.',
    ],
  ),
  HelpSection(
    icon: Icons.logout,
    title: 'Logout',
    steps: [
      'Ketuk Logout pada navigasi bawah.',
      'Konfirmasi pada dialog yang muncul.',
      'Sesi lokal akan dihapus dan Anda kembali ke halaman Login. Data BMI tidak ikut terhapus.',
    ],
  ),
];
