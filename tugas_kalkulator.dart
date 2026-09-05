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

  void tampilkan() {
    print('\n=== DATA KELOMPOK ===');
    print('Mata Kuliah : $mataKuliah');
    print('Kelas       : $kelas');
    print('Anggota     :');
    for (int i = 0; i < anggota.length; i++) {
      print('  ${i + 1}. ${anggota[i]}');
    }
  }
}


void main(){
  print('=== APLIKASI KALKULATOR SEDERHANA ===');

  // ----- 1. LOGIN (logic-nya langsung di main, pakai perulangan while) -----
  String usernameBenar = 'admin';
  String passwordBenar = '12345';
  bool sudahLogin = false;
  int kesempatan = 3;

  while (!sudahLogin && kesempatan>0) {
    stdout.write('\nUsername: ');
    String username = stdin.readLineSync() ?? '';
    stdout.write('Password: ');
    String password = stdin.readLineSync() ?? '';

    if (username == usernameBenar && password == passwordBenar) {
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
  DataKelompok dataKelompok = DataKelompok();
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