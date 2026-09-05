import 'dart:io';

// ==================================================
// CLASS: Data Kelompok (menampilkan identitas)
// ==================================================
class DataKelompok {
  String mataKuliah = 'Pemrograman Aplikasi Mobile';
  String kelas = 'Kelompok 3 - SI-A';
  List<String> anggota = [
    'Taufik  - 124240070',
    'Sultannang Nandito Setiyawan - 124240083',
  ];




// untuk menampilkan data kelompok saat di call
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

    //function call list nama anggota
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

void cekGanjilGenap() {
  clearScreen();
  print('==============================================================================');
  print('|                        Cek Ganjil/Genap Modulo                             |');
  print('==============================================================================');
   
   print('Note: Ini adalah menu untuk menentukan ganjil genap dari suatu operasi Modulo...');

   stdout.write("Masukkan jumlah angka yang akan di cek: ");
  int inputAngka = int.parse(stdin.readLineSync()!);

  // Membuat List dengan ukuran inputAngka
  List<int> input = List.filled(inputAngka, 0);

  // Mengisi List
  for (int i = 0; i < inputAngka; i++) {
    stdout.write("Masukkan angka ke-${i + 1}: ");
    input[i] = int.parse(stdin.readLineSync()!);
  }

  print("\nHasil:");

  // Mengecek setiap angka
  for (int i = 0; i < input.length; i++) {
    if (input[i] % 2 == 0) {
      print("${input[i]} adalah GENAP");
    } else {
      print("${input[i]} adalah GANJIL");
    }
  }
    print('Tekan Enter untuk melanjutkan...');
      stdin.readLineSync(); // program berhenti di sini sampai user menekan Enter
clearScreen();
}

void jumlahTotalAngka() {
  clearScreen();

  print('==============================================================================');
  print('|                         Jumlah Total Angka                                 |');
  print('==============================================================================');

  print('Note: Menu ini digunakan untuk menjumlahkan seluruh angka yang diinput.');

  stdout.write("Masukkan jumlah angka: ");
  int inputAngka = int.parse(stdin.readLineSync()!);

  // Membuat List dengan ukuran inputAngka
  List<int> input = List.filled(inputAngka, 0);

  // Mengisi List
  for (int i = 0; i < inputAngka; i++) {
    stdout.write("Masukkan angka ke-${i + 1}: ");
    input[i] = int.parse(stdin.readLineSync()!);
  }

  // Menghitung total
  int total = 0;

  for (int i = 0; i < input.length; i++) {
    total += input[i];
  }

  print("\n==============================");
  print("Jumlah Total Angka = $total");
  print("==============================");

  print('\nTekan Enter untuk melanjutkan...');
  stdin.readLineSync();

  clearScreen();
}

void main(){

  clearScreen();
  
  print('=== APLIKASI KALKULATOR SEDERHANA ===');

  // ----- 1. LOGIN (logic-nya langsung di main, pakai perulangan while) -----

  //pass and usn
 
  // Objek DataKelompok dibuat di awal (sebelum login), karena sekarang
  // class inilah yang menyimpan kredensial dan memeriksa login.
  DataKelompok dataKelompok = DataKelompok();

  // ----- 1. LOGIN (logic perulangan tetap di main, tapi pengecekan
  //          username/password dilempar ke dataKelompok.cekLogin()) -----
  bool sudahLogin = false;
  int kesempatan = 3; // jumlah percobaan login yang diperbolehkan



// jika sudah login = true dan kesempatan tidak 0 maka memulai system 
  while (!sudahLogin && kesempatan>0) {

    //stdout.write untuk menulis output bedanya dengan print adalah tidak auto /n setelah output "username"
    stdout.write('\nUsername: ');  
    String username = stdin.readLineSync() ?? ''; // readLineSync untuk membaca input user stdin.readLineSync()


    stdout.write('Password: ');
    String password = stdin.readLineSync() ?? '';


// cek login
   
    if (dataKelompok.cekLogin(username, password)) {
      sudahLogin = true;
      print('\nLogin berhasil!');
    } else {
      kesempatan--; //menurun kan kesempatan ke angka 0 secara bertahap
      print('Username atau password salah, sisa kesempatan: $kesempatan.');
    }
  }



  if (!sudahLogin) { // menuutup progres saat kesempatan habis
  print('\nKesempatan login habis. Program dihentikan.');
  return; //mengembalikan nilai 0 = false =stop while
  }




  
  // ----- 2. TAMPILKAN DATA KELOMPOK (pakai class DataKelompok) -----
  //DataKelompok pertama adalah nama class kemudian "dataKelompok" adalah variabel 
  //kemudian setelah "=" ada datakelompok() berarti membuat 1 unit baru


  //call fungsi tampilkan dari variabel dataKelompok
  dataKelompok.tampilkan();




  // ----- 3. MENU UTAMA (tiap pilihan memanggil class menu masing-masing) -----
  bool aplikasiJalan = true; //selalu true agar while menu selalu jalan


// menjalankan menu kalkulator (inti)
  while (aplikasiJalan) {
    print('\n=== MENU UTAMA ===');
    print('1. Tambah & Kurang');
    print('2. Kali & Bagi');
    print('3. Cek Ganjil/Genap');
    print('4. Jumlah Total Angka');
    print('5. Logout');
    stdout.write('Pilih menu (1-5): ');

    String pilihan = stdin.readLineSync() ?? ''; // input pilihan

    if (pilihan == '1') {
      print("menu 1");
      print('Tekan Enter untuk melanjutkan...');
      stdin.readLineSync(); // program berhenti di sini sampai user menekan Enter

      //menu 1 isi
// ketik disini

      //



    } else if (pilihan == '2') {
      print("menu 2");
      print('Tekan Enter untuk melanjutkan...');
      stdin.readLineSync(); // program berhenti di sini sampai user menekan Enter

      //menu 1 isi
// ketik disini

      //
    }else if (pilihan == '3') {
      print("menu 3");
      print('Tekan Enter untuk melanjutkan...');
      stdin.readLineSync(); // program berhenti di sini sampai user menekan Enter

      //core menu 3
        cekGanjilGenap();

    }else if (pilihan == '4') {
      print("menu 1");
      print('Tekan Enter untuk melanjutkan...');
      stdin.readLineSync(); // program berhenti di sini sampai user menekan Enter

     // core menu 4
jumlahTotalAngka();
      
    }


else if (pilihan == '5') {
      aplikasiJalan = false;
      print('\nAnda telah logout. Sampai jumpa!');
    } else {
      print('Pilihan tidak valid, coba lagi.');
    }
  }
}
