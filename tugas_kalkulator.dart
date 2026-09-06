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

//bersihkan layar
void clearScreen() {
  if (Platform.isWindows) {
    Process.runSync('cls', [], runInShell: true);
  } else {
    Process.runSync('clear', [], runInShell: true);
  }
}

// ==================================================
// CLASS: Kalkulator Lanjutan (bisa lebih dari 2 angka)
// Cara pakai seperti kalkulator fisik:
// masukkan angka, pilih operator, masukkan angka lagi,
// ulangi terus, ketik "=" kapan saja untuk melihat hasil akhir.
// ==================================================
class Kalkulator {
  void jalankan() {
    print('==============================================================================');
    print('|                         Kalkulator Sederhana                               |');
    print('==============================================================================');
    print('==============================================================================');
    print('--- Kalkulator (+, -, x, :) untuk banyak angka ---');
    print('Operator yang bisa dipakai: + , - , x , :');
    print('Jika memasukkan huruf akan dikonversi jadi nilai 0.');
    print('Ketik = kapan saja untuk melihat hasil dan berhenti.');
    print('==============================================================================');
 
    stdout.write('Masukkan angka    : ');
    double hasil = double.tryParse(stdin.readLineSync() ?? '') ?? 0;
 
    while (true) {
      stdout.write('Masukkan Operator : ');
      String operator = stdin.readLineSync() ?? '';
 
      // Kalau user menekan "=", hitung berhenti dan hasil ditampilkan.
      if (operator == '=') {
        print('\nHasil akhir = $hasil');
        break;
      }
 
      stdout.write('Angka berikutnya  : ');
      double angka = double.tryParse(stdin.readLineSync() ?? '') ?? 0;
 
      if (operator == '+') {
        hasil = hasil + angka;
      } else if (operator == '-') {
        hasil = hasil - angka;
      } else if (operator == 'x' || operator == '*') {
        hasil = hasil * angka;
      } else if (operator == ':' || operator == '/') {
        if (angka == 0) {
          print('Tidak bisa dibagi dengan nol, angka ini dilewati.\n');
        } else {
          hasil = hasil / angka;
        }
      } else {
        print('Operator tidak dikenali, angka ini dilewati.\n');
      }
 
      print('Hasil sementara   : $hasil');
    }
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
    stdout.write('Username: ');
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
    clearScreen();
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
      Kalkulator menu = Kalkulator();
      menu.jalankan();
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