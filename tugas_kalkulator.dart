import 'dart:io';

// ==================================================
// CLASS: Data Kelompok (menampilkan identitas)
// ==================================================
class DataKelompok {
  String mataKuliah = 'Pemrograman Aplikasi Mobile';
  String kelas = 'Kelompok 3 - SI-A';
  List<String> anggota = [
    'Taufik  - 124240070',
    'Dito    - 1242400xx',
  ];

  // Kredensial login disimpan privat (underscore) di dalam class ini,
  // sekarang berupa DAFTAR akun supaya bisa lebih dari satu admin.
  // Setiap akun adalah satu Map berisi 'username' dan 'password'.
  List<Map<String, String>> _daftarAkun = [
    {'username': 'admin', 'password': '12345'},
    {'username': 'admin2', 'password': '67890'},
  ];

  void tampilkan() {
    print('\n=== DATA KELOMPOK ===');
    print('Mata Kuliah : $mataKuliah');
    print('Kelas       : $kelas');
    print('Anggota     :');
    for (int i = 0; i < anggota.length; i++) {
      print('  ${i + 1}. ${anggota[i]}');
    }
  }

  // Sekarang cekLogin() melakukan perulangan (for) untuk mencocokkan
  // input dengan SETIAP akun di dalam _daftarAkun. Begitu ada satu
  // akun yang cocok, langsung balas true (tidak perlu cek sisanya).
  bool cekLogin(String usernameInput, String passwordInput) {
    for (var akun in _daftarAkun) {
      if (akun['username'] == usernameInput &&
          akun['password'] == passwordInput) {
        return true;
      }
    }
    return false; // tidak ada akun yang cocok
  }
}


void main(){
  print('=== APLIKASI KALKULATOR SEDERHANA ===');

  // Objek DataKelompok dibuat di awal (sebelum login), karena sekarang
  // class inilah yang menyimpan kredensial dan memeriksa login.
  DataKelompok dataKelompok = DataKelompok();

  // ----- 1. LOGIN (logic perulangan tetap di main, tapi pengecekan
  //          username/password dilempar ke dataKelompok.cekLogin()) -----
  bool sudahLogin = false;
  int kesempatan = 3; // jumlah percobaan login yang diperbolehkan

  while (!sudahLogin && kesempatan>0) {
    stdout.write('\nUsername: ');
    String username = stdin.readLineSync() ?? '';
    stdout.write('Password: ');
    String password = stdin.readLineSync() ?? '';

    if (dataKelompok.cekLogin(username, password)) {
      sudahLogin = true;
      print('\nLogin berhasil!');
    } else {
      kesempatan--;
      print('Username atau password salah, sisa kesempatan: $kesempatan.');
    }
  }

  if (!sudahLogin) {
  print('\nKesempatan login habis. Program dihentikan.');
  return;
  }
  // ----- 2. TAMPILKAN DATA KELOMPOK (pakai class DataKelompok) -----
  dataKelompok.tampilkan();

  // ----- 3. MENU UTAMA (tiap pilihan memanggil class menu masing-masing) -----
  bool aplikasiJalan = true;

  while (aplikasiJalan) {
    print('\n=== MENU UTAMA ===');
    print('1. Tambah & Kurang');
    print('2. Kali & Bagi');
    print('3. Cek Ganjil/Genap');
    print('4. Jumlah Total Angka');
    print('5. Logout');
    stdout.write('Pilih menu (1-5): ');

    String pilihan = stdin.readLineSync() ?? '';

    if (pilihan == '1') {
      print("menu 1");
      print('Tekan Enter untuk melanjutkan...');
      stdin.readLineSync(); // program berhenti di sini sampai user menekan Enter
    } else if (pilihan == '5') {
      aplikasiJalan = false;
      print('\nAnda telah logout. Sampai jumpa!');
    } else {
      print('Pilihan tidak valid, coba lagi.');
    }
  }
}