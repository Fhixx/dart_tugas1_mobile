import 'package:flutter/material.dart';

// ==================================================
// ENTRY POINT: Titik masuk aplikasi Flutter
// runApp() memulai seluruh aplikasi dengan widget MainApp
// const dihilangkan agar MainApp bisa pakai StatefulWidget di dalamnya
// ==================================================
void main() {
  runApp(MainApp());
}

// ==================================================
// CLASS: DataKelompok
// Menyimpan data identitas kelompok dan logika login.
// Diambil 100% dari file asli tanpa perubahan logika.
// ==================================================
class DataKelompok {
  String mataKuliah = 'Pemrograman Aplikasi Mobile';
  String kelas = 'Kelompok 3 - SI-A';

  // List anggota kelompok - ditampilkan di UI saat card diklik
  List<String> anggota = [
    'Taufik Nur Hidayah - 124240070',
    'Sultannang Nandito Setiyawan - 124240083',
  ];

  // Kredensial login disimpan privat (underscore) di dalam class ini,
  // sekarang berupa DAFTAR akun supaya bisa lebih dari satu admin.
  // Setiap akun adalah satu Map berisi 'username' dan 'password'.
  final List<Map<String, String>> _daftarAkun = [
    {'username': 'fix', 'password': '123'},
    {'username': 'dito', 'password': '678'},
  ];

  // cekLogin() melakukan perulangan (for) untuk mencocokkan
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

// ==================================================
// CLASS: Kalkulator Lanjutan
// Bisa menghitung lebih dari 2 angka secara berantai.
// Operator: + - x :
// Logika 100% sama dari file asli.
// ==================================================
class Kalkulator {
  // hitungBerantai() menerima list operasi berupa Map:
  // [{'op': '+', 'angka': 5}, {'op': '-', 'angka': 2}, ...]
  // dan angka awal, lalu mengembalikan hasil akhir (double).
  double hitungBerantai(double angkaAwal, List<Map<String, dynamic>> operasi) {
    double hasil = angkaAwal; // mulai dari angka pertama yang diinput user

    for (var item in operasi) {
      String operator = item['op'];   // ambil operator
      double angka    = item['angka']; // ambil angka berikutnya

      // logika operator - 100% sama dengan aslinya
      if (operator == '+') {
        hasil = hasil + angka;
      } else if (operator == '-') {
        hasil = hasil - angka;
      } else if (operator == 'x' || operator == '*') {
        hasil = hasil * angka;
      } else if (operator == ':' || operator == '/') {
        if (angka == 0) {
          // tidak bisa dibagi nol, dilewati (sesuai asli)
        } else {
          hasil = hasil / angka;
        }
      }
      // operator tidak dikenali -> dilewati (sesuai asli)
    }

    return hasil;
  }
}

// ==================================================
// FUNGSI: cekGanjilGenap
// Menerima list angka, mengembalikan list hasil string.
// Logika 100% sama dengan file asli (modulo 2).
// ==================================================
List<String> cekGanjilGenap(List<int> input) {
  List<String> hasil = []; // tempat menyimpan hasil

  // Mengecek setiap angka dengan modulo 2
  for (int i = 0; i < input.length; i++) {
    if (input[i] % 2 == 0) {
      hasil.add('${input[i]} adalah GENAP');
    } else {
      hasil.add('${input[i]} adalah GANJIL');
    }
  }

  return hasil;
}

// ==================================================
// FUNGSI: jumlahTotalAngka
// Menerima list angka, mengembalikan total penjumlahan.
// Logika 100% sama dengan file asli.
// ==================================================
int jumlahTotalAngka(List<int> input) {
  // Menghitung total dengan perulangan for
  int total = 0;

  for (int i = 0; i < input.length; i++) {
    total += input[i]; // akumulasi penjumlahan
  }

  return total;
}

// ==================================================
// WIDGET UTAMA: MainApp
// Root widget aplikasi, menyetel tema warna dan halaman utama.
// ==================================================
class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kalkulator Kelompok 3',
      debugShowCheckedModeBanner: false, // hilangkan label "debug" di pojok
      theme: ThemeData(
        // --- Tema warna dominan BIRU ---
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1565C0), // biru tua (blue 800)
          brightness: Brightness.light,
        ),
        useMaterial3: true, // pakai Material Design 3 (modern)
      ),
      home: HalamanUtama(), // halaman satu-satunya (single page)
    );
  }
}

// ==================================================
// WIDGET HALAMAN UTAMA: HalamanUtama
// Menggunakan StatefulWidget karena ada state yang berubah:
//   - _showAnggota: apakah card anggota sedang ditampilkan
//   - _sudahLogin: status login user
//   - berbagai state untuk tiap menu
// ==================================================
class HalamanUtama extends StatefulWidget {
  const HalamanUtama({super.key});

  @override
  State<HalamanUtama> createState() => _HalamanUtamaState();
}

class _HalamanUtamaState extends State<HalamanUtama> {
  // ---- Objek dari class yang sudah ada ----
  final DataKelompok _dataKelompok = DataKelompok(); // data identitas kelompok
  final Kalkulator   _kalkulator   = Kalkulator();   // objek kalkulator

  // ---- State login ----
  bool   _sudahLogin  = false; // apakah user sudah login?
  int    _kesempatan  = 3;     // sisa kesempatan login (sama dengan asli)
  String _pesanLogin  = '';    // pesan error/sukses login

  // ---- State navigasi / tampilan ----
  // null = tampilkan menu utama, nilai lain = tampilkan menu tersebut
  String? _menuAktif;

  // ---- State card anggota ----
  bool _showAnggota = false; // toggle: klik card -> tampilkan/sembunyikan anggota

  // ---- State input login ----
  final TextEditingController _userCtrl = TextEditingController();
  final TextEditingController _passCtrl = TextEditingController();
  bool _passVisible = false; // toggle tampilkan/sembunyikan password

  // ---- State Kalkulator ----
  final TextEditingController _kalkulatorAngkaAwalCtrl = TextEditingController();
  double?  _kalkulatorAngkaAwal;           // angka pertama
  List<Map<String, dynamic>> _operasi = []; // list operasi berantai
  double?  _kalkulatorHasil;              // hasil akhir kalkulator
  String   _selectedOperator = '+';        // operator yang dipilih saat ini
  final TextEditingController _angkaBerikutnyaCtrl = TextEditingController();

  // ---- State Ganjil/Genap ----
  final TextEditingController _jumlahAngkaGanjilCtrl = TextEditingController();
  List<TextEditingController> _ganjilInputCtrls = []; // controller per input
  List<String> _hasilGanjilGenap = [];                // hasil cek ganjil/genap
  bool _ganjilInputReady = false; // apakah input field sudah ditampilkan?

  // ---- State Jumlah Total ----
  final TextEditingController _jumlahAngkaTotalCtrl = TextEditingController();
  List<TextEditingController> _totalInputCtrls = []; // controller per input
  int?   _hasilJumlahTotal;   // hasil penjumlahan total
  bool   _totalInputReady = false; // apakah input field sudah ditampilkan?

  // ==================================================
  // FUNGSI: _prosesLogin
  // Menjalankan logika login yang sama persis dengan asli:
  // - Cek username + password via dataKelompok.cekLogin()
  // - Kurangi kesempatan jika salah
  // - Hentikan jika kesempatan habis
  // ==================================================
  void _prosesLogin() {
    String username = _userCtrl.text.trim();
    String password = _passCtrl.text.trim();

    if (_dataKelompok.cekLogin(username, password)) {
      // Login berhasil
      setState(() {
        _sudahLogin = true;
        _pesanLogin = 'Login berhasil! Selamat datang, $username';
      });
    } else {
      // Login gagal - kurangi kesempatan (sama dengan asli: kesempatan--)
      setState(() {
        _kesempatan--;
        if (_kesempatan <= 0) {
          _pesanLogin = 'Kesempatan login habis. Hubungi admin.';
        } else {
          _pesanLogin =
              'Username atau password salah, sisa kesempatan: $_kesempatan.';
        }
      });
    }

    // Reset field password setelah percobaan
    _passCtrl.clear();
  }

  // ==================================================
  // FUNGSI: _logout
  // Mereset semua state kembali ke awal (mirip "logout" di asli)
  // ==================================================
  void _logout() {
    setState(() {
      _sudahLogin  = false;
      _kesempatan  = 3;
      _pesanLogin  = '';
      _menuAktif   = null;
      _showAnggota = false;
      _userCtrl.clear();
      _passCtrl.clear();
      _resetSemuaMenu();
    });
  }

  // ==================================================
  // FUNGSI: _resetSemuaMenu
  // Membersihkan state semua menu saat berpindah/logout
  // ==================================================
  void _resetSemuaMenu() {
    _kalkulatorAngkaAwalCtrl.clear();
    _kalkulatorAngkaAwal  = null;
    _operasi              = [];
    _kalkulatorHasil      = null;
    _selectedOperator     = '+';
    _angkaBerikutnyaCtrl.clear();

    _jumlahAngkaGanjilCtrl.clear();
    _ganjilInputCtrls = [];
    _hasilGanjilGenap = [];
    _ganjilInputReady = false;

    _jumlahAngkaTotalCtrl.clear();
    _totalInputCtrls  = [];
    _hasilJumlahTotal = null;
    _totalInputReady  = false;
  }

  // ==================================================
  // BUILD: Titik utama Flutter merender UI
  // Setiap kali setState() dipanggil, build() dijalankan ulang.
  // ==================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // --- AppBar di bagian atas ---
      appBar: AppBar(
        backgroundColor: const Color(0xFF1565C0), // biru tua
        foregroundColor: Colors.white,
        title: const Text(
          'Kalkulator Kelompok 3 - SI-A',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        // Tombol logout muncul hanya saat sudah login
        actions: _sudahLogin
            ? [
                IconButton(
                  icon: const Icon(Icons.logout),
                  tooltip: 'Logout',
                  onPressed: _logout,
                ),
              ]
            : [],
      ),

      // Background biru muda
      backgroundColor: const Color(0xFFE3F2FD),

      // Body: SingleChildScrollView supaya konten bisa di-scroll
      // jika layar tidak cukup (single page tapi scrollable)
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: _sudahLogin
            ? _buildHalamanMenu()   // tampilkan menu jika sudah login
            : _buildHalamanLogin(), // tampilkan login jika belum
      ),
    );
  }

  // ==================================================
  // WIDGET: _buildHalamanLogin
  // Form login sederhana dengan 3 kesempatan.
  // ==================================================
  Widget _buildHalamanLogin() {
    return Column(
      children: [
        // Header
        const SizedBox(height: 30),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF1565C0),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Column(
            children: [
              Icon(Icons.lock_person, color: Colors.white, size: 50),
              SizedBox(height: 8),
              Text(
                'Silakan Login Dulu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Pemrograman Aplikasi Mobile',
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Kotak form login
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withValues(alpha: 0.15),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              // Field username
              TextField(
                controller: _userCtrl,
                enabled: _kesempatan > 0 && !_sudahLogin,
                decoration: const InputDecoration(
                  labelText: 'Username',
                  prefixIcon: Icon(Icons.person, color: Color(0xFF1565C0)),
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Color(0xFF1565C0), width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Field password
              TextField(
                controller: _passCtrl,
                obscureText: !_passVisible, // sembunyikan karakter password
                enabled: _kesempatan > 0 && !_sudahLogin,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon:
                      const Icon(Icons.lock, color: Color(0xFF1565C0)),
                  border: const OutlineInputBorder(),
                  focusedBorder: const OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Color(0xFF1565C0), width: 2),
                  ),
                  // Ikon mata untuk toggle tampil/sembunyikan password
                  suffixIcon: IconButton(
                    icon: Icon(
                      _passVisible ? Icons.visibility : Icons.visibility_off,
                      color: Colors.grey,
                    ),
                    onPressed: () =>
                        setState(() => _passVisible = !_passVisible),
                  ),
                ),
                onSubmitted: (_) =>
                    _kesempatan > 0 ? _prosesLogin() : null,
              ),
              const SizedBox(height: 16),

              // Tombol Login
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _kesempatan > 0 ? _prosesLogin : null,
                  icon: const Icon(Icons.login),
                  label: const Text('Masuk',
                      style: TextStyle(fontSize: 16)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1565C0),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Pesan login (error / sukses / kesempatan habis)
              if (_pesanLogin.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _kesempatan <= 0
                        ? Colors.red.shade50
                        : Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _kesempatan <= 0
                          ? Colors.red
                          : Colors.orange,
                    ),
                  ),
                  child: Text(
                    _pesanLogin,
                    style: TextStyle(
                      color: _kesempatan <= 0
                          ? Colors.red
                          : Colors.orange.shade800,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

              const SizedBox(height: 8),
              // Info sisa kesempatan
              Text(
                'Sisa kesempatan: $_kesempatan / 3',
                style: TextStyle(
                  color: _kesempatan <= 1 ? Colors.red : Colors.grey,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 12),

              // =========================================================================
              // PENJELASAN ISTILAH FLUTTER / DART UNTUK PROGRAMMER C++:
              //
              // 1. Container: Widget pembungkus (bounding box) visual 2D. Di C++ tidak ada ini,
              //    di Flutter ini digunakan untuk mengatur ukuran, jarak, warna background, dan border.
              //
              // 2. double.infinity:
              //    - `double.infinity` adalah nilai tak hingga (mirip std::numeric_limits<double>::infinity() di C++).
              //    - Di Flutter, jika `width` diisi `double.infinity`, artinya "ambil lebar MAKSIMAL
              //      yang diberikan oleh parent-nya" (match parent / fill width).
              //
              // 3. padding:
              //    - Jarak bagian dalam (inner spacing) antara garis tepi Container dengan elemen di dalamnya.
              //
              // 4. EdgeInsets (Edge + Insets):
              //    - `Edge`   = Tepi/Batas luar dari sebuah bidang 2D (Top, Bottom, Left, Right).
              //    - `Insets` = Jarak penjorokan / pergeseran ke arah dalam dari tepi tersebut.
              //    - `EdgeInsets` = Struct/Class imutabel pembawa offset pergeseran ke-4 sisi tepi.
              //
              // 5. .all(10):
              //    - Named constructor static pada class `EdgeInsets` (mirip factory method di C++).
              //    - `.all(10)` menerapkan jarak 10 piksel yang SAMA ke seluruh (all) 4 sisi tepi:
              //      {left: 10, top: 10, right: 10, bottom: 10}.
              //
              // 6. decoration (BoxDecoration):
              //    - `decoration` = Properti pengatur gaya visual luar (latar, border, sudut tumpul).
              //    - `BoxDecoration` = Implementasi konkret untuk mendekorasi objek berbentuk kotak (Box).
              //
              // 7. borderRadius & BorderRadius.circular(8):
              //    - Memberikan efek sudut tumpul/melengkung pada 4 pojok kotak.
              //    - `.circular(8)` = kelengkungan busur lingkaran dengan radius 8 piksel.
              //
              // 8. Border.all():
              //    - Named constructor pembuat garis outline tepi di ke-4 sisi secara bersamaan.
              //
              // 9. .withValues(alpha: 0.3):
              //    - Method pada Color untuk mengatur transparansi (Channel Alpha RGBA).
              //    - 0.3 = opasitas 30% (transparan 70%).
              //
              // 10. Column & Row:
              //    - Tata letak Flexbox 2D.
              //    - Column = menyusun anak vertikal (sumbu Y).
              //    - Row    = menyusun anak horizontal (sumbu X).
              //
              // 11. MainAxisAlignment.center:
              //    - Mengatur perataan elemen sepanjang sumbu utama (Main Axis).
              //    - Pada Row, sumbu utamanya adalah Horizontal (X), jadi `.center` menaruh elemen tepat di tengah.
              // =========================================================================
              Container(
                width: double.infinity, // Lebar maksimal mengikuti lebar parent
                padding: const EdgeInsets.all(10), // Padding 10px di ke-4 sisi tepi
                decoration: BoxDecoration(
                  color: Colors.blue.shade50, // Warna background biru muda
                  borderRadius: BorderRadius.circular(8), // Sudut tumpul radius 8px
                  border: Border.all(
                    color: const Color(0xFF1565C0).withValues(alpha: 0.3), // Garis border biru transparan (Alpha 30%)
                  ),
                ),
                child: const Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center, // Ratakan isi Row ke tengah horizontal
                      children: [
                        Icon(Icons.info_outline,
                            size: 14, color: Color(0xFF1565C0)),
                        SizedBox(width: 4),
                        Text(
                          'Info Akun Login (Username / Password):',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1565C0),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Text(
                      '• fix / 123   • dito / 678',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ==================================================
  // WIDGET: _buildHalamanMenu
  // Tampilan utama setelah login:
  //   - Card anggota (toggle klik)
  //   - Konten menu aktif (di bawah card anggota, di atas grid)
  //   - Grid 2x2 menu
  // ==================================================
  Widget _buildHalamanMenu() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ---- CARD ANGGOTA (1 kotak tambahan, toggle klik) ----
        _buildCardAnggota(),
        const SizedBox(height: 16),

        // ---- KONTEN MENU AKTIF (Tampil di bawah kotak anggota & di atas "Pilih Menu:") ----
        if (_menuAktif != null) ...[
          _buildKontenMenu(),
          const SizedBox(height: 16),
        ],

        // ---- LABEL MENU ----
        const Text(
          'Pilih Menu:',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1565C0),
          ),
        ),
        const SizedBox(height: 10),

        // ---- GRID MENU 2 KOLOM x 2 BARIS ----
        // crossAxisCount: 2  -> 2 kolom
        // mainAxisSpacing    -> jarak vertikal
        // crossAxisSpacing   -> jarak horizontal
        GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.3,
          shrinkWrap: true,     // ukuran grid sesuai isi
          physics: const NeverScrollableScrollPhysics(), // scroll dihandle parent
          children: [
            // Baris 1, Kolom 1: Kalkulator
            _buildMenuCard(
              judul: 'Kalkulator\nSederhana',
              ikon: Icons.calculate,
              kodeMenu: 'kalkulator',
              warnaBg: const Color(0xFF1565C0),
              warnaAksen: const Color(0xFF42A5F5),
            ),
            // Baris 1, Kolom 2: Ganjil/Genap
            _buildMenuCard(
              judul: 'Cek Ganjil\n/ Genap',
              ikon: Icons.exposure,
              kodeMenu: 'ganjilgenap',
              warnaBg: const Color(0xFF2E7D32),    // hijau daun tua
              warnaAksen: const Color(0xFF66BB6A),
            ),
            // Baris 2, Kolom 1: Jumlah Total
            _buildMenuCard(
              judul: 'Jumlah Total\nAngka',
              ikon: Icons.functions,
              kodeMenu: 'jumlahtotal',
              warnaBg: const Color(0xFF1565C0),
              warnaAksen: const Color(0xFF42A5F5),
            ),
            // Baris 2, Kolom 2: Logout
            _buildMenuCard(
              judul: 'Logout',
              ikon: Icons.exit_to_app,
              kodeMenu: 'logout',
              warnaBg: const Color(0xFF4E342E),
              warnaAksen: const Color(0xFF8D6E63),
            ),
          ],
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  // ==================================================
  // WIDGET: _buildCardAnggota
  // Card khusus untuk menampilkan nama anggota kelompok.
  // Klik = toggle tampil/sembunyikan.
  // ==================================================
  Widget _buildCardAnggota() {
    return GestureDetector(
      onTap: () {
        // Toggle: true -> false, false -> true
        setState(() {
          _showAnggota = !_showAnggota;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          // Gradasi hijau daun tua
          gradient: const LinearGradient(
            colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.green.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header card anggota
            Row(
              children: [
                const Icon(Icons.group, color: Colors.white, size: 24),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _dataKelompok.kelas,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        _dataKelompok.mataKuliah,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                // Ikon panah berputar 180 derajat saat expand
                AnimatedRotation(
                  turns: _showAnggota ? 0.5 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child: const Icon(
                    Icons.keyboard_arrow_down,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              _showAnggota
                  ? 'Ketuk untuk sembunyikan'
                  : 'Ketuk untuk lihat anggota kelompok',
              style: const TextStyle(color: Colors.white54, fontSize: 11),
            ),

            // Daftar anggota - hanya muncul jika _showAnggota = true
            if (_showAnggota) ...[
              const SizedBox(height: 12),
              const Divider(color: Colors.white30),
              const SizedBox(height: 6),
              // Sama dengan for loop tampilkan anggota di file asli
              for (int i = 0; i < _dataKelompok.anggota.length; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      // Nomor dalam lingkaran
                      Container(
                        width: 24,
                        height: 24,
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(
                          color: Colors.white24,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '${i + 1}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _dataKelompok.anggota[i],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  // ==================================================
  // WIDGET: _buildMenuCard
  // Card tombol menu yang bisa diklik.
  // ==================================================
  Widget _buildMenuCard({
    required String judul,
    required IconData ikon,
    required String kodeMenu,
    required Color warnaBg,
    required Color warnaAksen,
  }) {
    bool isAktif = _menuAktif == kodeMenu; // apakah menu ini sedang aktif?

    return GestureDetector(
      onTap: () {
        if (kodeMenu == 'logout') {
          _logout(); // langsung logout
        } else {
          setState(() {
            _menuAktif = isAktif ? null : kodeMenu; // toggle aktif
            _resetSemuaMenu(); // bersihkan state menu sebelumnya
          });
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isAktif
                ? [warnaAksen, warnaBg]  // lebih terang jika aktif
                : [warnaBg, warnaBg],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          // Border putih jika aktif
          border: isAktif
              ? Border.all(color: Colors.white, width: 2)
              : null,
          boxShadow: [
            BoxShadow(
              color: warnaBg.withValues(alpha: 0.4),
              blurRadius: isAktif ? 12 : 6,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(ikon, color: Colors.white, size: 36),
            const SizedBox(height: 8),
            Text(
              judul,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================================================
  // WIDGET: _buildKontenMenu
  // Pembungkus konten menu aktif.
  // ==================================================
  Widget _buildKontenMenu() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withValues(alpha: 0.12),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_menuAktif == 'kalkulator')  _buildMenuKalkulator(),
          if (_menuAktif == 'ganjilgenap') _buildMenuGanjilGenap(),
          if (_menuAktif == 'jumlahtotal') _buildMenuJumlahTotal(),
        ],
      ),
    );
  }

  // ==================================================
  // WIDGET: _buildMenuKalkulator
  // UI untuk Kalkulator Sederhana (Menu 1).
  // Menggunakan Kalkulator.hitungBerantai() - 100% logika asli.
  // ==================================================
  Widget _buildMenuKalkulator() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildJudulMenu('Kalkulator Sederhana', Icons.calculate,
            const Color(0xFF1565C0)),
        const SizedBox(height: 4),
        const Text(
          'Operator: +  -  x  :   (bisa lebih dari 2 angka)',
          style: TextStyle(color: Colors.grey, fontSize: 12),
        ),
        const SizedBox(height: 16),

        // --- TAHAP 1: Input angka awal ---
        if (_kalkulatorAngkaAwal == null) ...[
          const Text('Masukkan angka pertama:',
              style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _kalkulatorAngkaAwalCtrl,
                  keyboardType: const TextInputType.numberWithOptions(
                      decimal: true, signed: true),
                  decoration: _inputDecor('Angka awal (misal: 10)'),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  // double.tryParse: jika bukan angka -> null -> 0 (sama asli)
                  double val = double.tryParse(
                          _kalkulatorAngkaAwalCtrl.text) ??
                      0;
                  setState(() {
                    _kalkulatorAngkaAwal = val;
                    _operasi = [];
                    _kalkulatorHasil = null;
                  });
                },
                style: _tombolStyle(const Color(0xFF1565C0)),
                child: const Text('Set'),
              ),
            ],
          ),
        ],

        // --- TAHAP 2: Input operasi berantai ---
        if (_kalkulatorAngkaAwal != null && _kalkulatorHasil == null) ...[
          // Tampilkan riwayat operasi
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFE3F2FD),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Angka awal: $_kalkulatorAngkaAwal',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                for (var op in _operasi)
                  Text(
                    '  ${op['op']}  ${op['angka']}',
                    style: const TextStyle(color: Color(0xFF1565C0)),
                  ),
                const Text('  → tekan = untuk hasil akhir',
                    style: TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Pilih operator via ChoiceChip
          const Text('Operator:',
              style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            children: ['+', '-', 'x', ':'].map((op) {
              return ChoiceChip(
                label: Text(op,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
                selected: _selectedOperator == op,
                selectedColor: const Color(0xFF1565C0),
                labelStyle: TextStyle(
                  color: _selectedOperator == op
                      ? Colors.white
                      : Colors.black,
                ),
                onSelected: (_) =>
                    setState(() => _selectedOperator = op),
              );
            }).toList(),
          ),
          const SizedBox(height: 10),

          // Input angka berikutnya
          const Text('Angka berikutnya:',
              style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _angkaBerikutnyaCtrl,
                  keyboardType: const TextInputType.numberWithOptions(
                      decimal: true, signed: true),
                  decoration: _inputDecor('Angka'),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  double angka =
                      double.tryParse(_angkaBerikutnyaCtrl.text) ?? 0;
                  setState(() {
                    _operasi.add(
                        {'op': _selectedOperator, 'angka': angka});
                    _angkaBerikutnyaCtrl.clear();
                  });
                },
                style: _tombolStyle(const Color(0xFF1565C0)),
                child: const Text('+ Tambah'),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Tombol "=" -> hitung hasil akhir
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                // Panggil hitungBerantai (logika 100% sama)
                double hasil = _kalkulator.hitungBerantai(
                  _kalkulatorAngkaAwal!,
                  _operasi,
                );
                setState(() => _kalkulatorHasil = hasil);
              },
              icon: const Icon(Icons.drag_handle),
              label: const Text('= Hitung Hasil Akhir',
                  style: TextStyle(fontSize: 15)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32), // hijau daun tua
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ],

        // --- TAHAP 3: Tampilkan hasil akhir ---
        if (_kalkulatorHasil != null) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF2E7D32),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                const Text('Hasil Akhir',
                    style:
                        TextStyle(color: Colors.white70, fontSize: 13)),
                Text(
                  _kalkulatorHasil.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: () => setState(() {
              _kalkulatorAngkaAwal = null;
              _operasi = [];
              _kalkulatorHasil = null;
              _kalkulatorAngkaAwalCtrl.clear();
            }),
            icon: const Icon(Icons.refresh),
            label: const Text('Hitung Ulang'),
          ),
        ],
      ],
    );
  }

  // ==================================================
  // WIDGET: _buildMenuGanjilGenap
  // UI untuk Cek Ganjil/Genap (Menu 2).
  // Menggunakan fungsi cekGanjilGenap() - 100% logika asli.
  // ==================================================
  Widget _buildMenuGanjilGenap() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildJudulMenu('Cek Ganjil / Genap', Icons.exposure,
            const Color(0xFF2E7D32)),
        const SizedBox(height: 4),
        const Text(
          'Cek setiap angka apakah ganjil atau genap menggunakan modulo 2',
          style: TextStyle(color: Colors.grey, fontSize: 12),
        ),
        const SizedBox(height: 16),

        // Input berapa angka yang akan dicek
        const Text('Masukkan jumlah angka yang akan dicek:',
            style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _jumlahAngkaGanjilCtrl,
                keyboardType: TextInputType.number,
                decoration: _inputDecor('Jumlah angka (misal: 3)'),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () {
                int? n = int.tryParse(_jumlahAngkaGanjilCtrl.text);
                if (n != null && n > 0) {
                  setState(() {
                    // Buat controller sebanyak n (sama: List.filled(n,0))
                    _ganjilInputCtrls =
                        List.generate(n, (_) => TextEditingController());
                    _hasilGanjilGenap = [];
                    _ganjilInputReady = true;
                  });
                }
              },
              style: _tombolStyle(const Color(0xFF2E7D32)),
              child: const Text('Siapkan'),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Input angka satu per satu
        if (_ganjilInputReady) ...[
          for (int i = 0; i < _ganjilInputCtrls.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: TextField(
                controller: _ganjilInputCtrls[i],
                keyboardType: TextInputType.number,
                decoration: _inputDecor('Angka ke-${i + 1}'),
              ),
            ),
          const SizedBox(height: 8),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                // Kumpulkan input -> List<int> (sama dengan asli)
                List<int> input = _ganjilInputCtrls
                    .map((c) => int.tryParse(c.text) ?? 0)
                    .toList();
                // Panggil cekGanjilGenap (logika 100% sama)
                setState(() {
                  _hasilGanjilGenap = cekGanjilGenap(input);
                });
              },
              icon: const Icon(Icons.check_circle),
              label: const Text('Cek Ganjil/Genap',
                  style: TextStyle(fontSize: 15)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ],

        // Tampilkan hasil
        if (_hasilGanjilGenap.isNotEmpty) ...[
          const SizedBox(height: 16),
          const Text('Hasil:',
              style: TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 8),
          for (String hasil in _hasilGanjilGenap)
            Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: hasil.contains('GENAP')
                    ? const Color(0xFFE3F2FD)
                    : const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: hasil.contains('GENAP')
                      ? const Color(0xFF1565C0)
                      : const Color(0xFF2E7D32),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    hasil.contains('GENAP')
                        ? Icons.looks_two
                        : Icons.looks_one,
                    color: hasil.contains('GENAP')
                        ? const Color(0xFF1565C0)
                        : const Color(0xFF2E7D32),
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(hasil,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ),
        ],
      ],
    );
  }

  // ==================================================
  // WIDGET: _buildMenuJumlahTotal
  // UI untuk Jumlah Total Angka (Menu 3).
  // Menggunakan fungsi jumlahTotalAngka() - 100% logika asli.
  // ==================================================
  Widget _buildMenuJumlahTotal() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildJudulMenu('Jumlah Total Angka', Icons.functions,
            const Color(0xFF1565C0)),
        const SizedBox(height: 4),
        const Text(
          'Menjumlahkan seluruh angka yang diinput menggunakan perulangan for',
          style: TextStyle(color: Colors.grey, fontSize: 12),
        ),
        const SizedBox(height: 16),

        const Text('Masukkan jumlah angka:',
            style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _jumlahAngkaTotalCtrl,
                keyboardType: TextInputType.number,
                decoration: _inputDecor('Jumlah angka (misal: 4)'),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () {
                int? n = int.tryParse(_jumlahAngkaTotalCtrl.text);
                if (n != null && n > 0) {
                  setState(() {
                    _totalInputCtrls =
                        List.generate(n, (_) => TextEditingController());
                    _hasilJumlahTotal = null;
                    _totalInputReady = true;
                  });
                }
              },
              style: _tombolStyle(const Color(0xFF1565C0)),
              child: const Text('Siapkan'),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Input angka satu per satu
        if (_totalInputReady) ...[
          for (int i = 0; i < _totalInputCtrls.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: TextField(
                controller: _totalInputCtrls[i],
                keyboardType: TextInputType.number,
                decoration: _inputDecor('Angka ke-${i + 1}'),
              ),
            ),
          const SizedBox(height: 8),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                // Kumpulkan input -> List<int> (sama dengan asli)
                List<int> input = _totalInputCtrls
                    .map((c) => int.tryParse(c.text) ?? 0)
                    .toList();
                // Panggil jumlahTotalAngka (logika 100% sama: for + total+=)
                setState(() {
                  _hasilJumlahTotal = jumlahTotalAngka(input);
                });
              },
              icon: const Icon(Icons.calculate),
              label: const Text('Hitung Total',
                  style: TextStyle(fontSize: 15)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1565C0),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ],

        // Tampilkan hasil
        if (_hasilJumlahTotal != null) ...[
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1565C0),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                const Text('Jumlah Total Angka',
                    style: TextStyle(
                        color: Colors.white70, fontSize: 13)),
                Text(
                  '$_hasilJumlahTotal',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: () => setState(() {
              _totalInputCtrls = [];
              _hasilJumlahTotal = null;
              _totalInputReady = false;
              _jumlahAngkaTotalCtrl.clear();
            }),
            icon: const Icon(Icons.refresh),
            label: const Text('Hitung Ulang'),
          ),
        ],
      ],
    );
  }

  // ==================================================
  // HELPER: _buildJudulMenu
  // Widget judul standar tiap halaman menu.
  // ==================================================
  Widget _buildJudulMenu(String judul, IconData ikon, Color warna) {
    return Row(
      children: [
        Icon(ikon, color: warna, size: 24),
        const SizedBox(width: 8),
        Text(
          judul,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: warna,
          ),
        ),
      ],
    );
  }

  // ==================================================
  // HELPER: _inputDecor
  // Style InputDecoration seragam untuk semua TextField.
  // ==================================================
  InputDecoration _inputDecor(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide:
            const BorderSide(color: Color(0xFF1565C0), width: 2),
      ),
    );
  }

  // ==================================================
  // HELPER: _tombolStyle
  // Style ButtonStyle seragam untuk tombol-tombol kecil.
  // ==================================================
  ButtonStyle _tombolStyle(Color warna) {
    return ElevatedButton.styleFrom(
      backgroundColor: warna,
      foregroundColor: Colors.white,
      padding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8)),
    );
  }

  // ==================================================
  // dispose: Bersihkan semua controller saat widget dihapus.
  // PENTING: mencegah memory leak!
  // ==================================================
  @override
  void dispose() {
    _userCtrl.dispose();
    _passCtrl.dispose();
    _kalkulatorAngkaAwalCtrl.dispose();
    _angkaBerikutnyaCtrl.dispose();
    _jumlahAngkaGanjilCtrl.dispose();
    _jumlahAngkaTotalCtrl.dispose();
    for (var c in _ganjilInputCtrls) { c.dispose(); }
    for (var c in _totalInputCtrls) { c.dispose(); }
    super.dispose();
  }
}

