# PRODUCT REQUIREMENTS DOCUMENT (PRD)

## NusaFit — BMI, Usia & Kalender Nusantara

**Versi:** 1.0  
**Platform utama:** Flutter Android  
**Database:** SQLite lokal  
**Mode:** Offline-first  
**Tema utama:** BMI + konversi tanggal/kalender  
**Status:** Ready for UI design & implementation

PRD ini menggabungkan kebutuhan tugas pada modul, requirement dari screenshot, serta spesifikasi fitur yang diberikan. Modul praktikum secara khusus menjelaskan penggunaan `Navigator.push()`, `Navigator.pop()`, `Navigator.pushReplacement()`, passing data antarscreen, serta logout dengan penghapusan navigation stack. Implementasi di bawah sengaja memasukkan semua mekanisme tersebut agar sesuai materi praktikum.

**Referensi utama:** `Module 4 - Navigation Revisi.pdf`, terutama materi Navigator, passing data, callback, serta implementasi logout pada halaman 49–67 modul.

---

# 1. Product Overview

**NusaFit** adalah aplikasi utilitas mobile berbasis Flutter yang menggabungkan:

1. autentikasi lokal,
2. autentikasi biometrik perangkat,
3. kalkulator BMI,
4. penyimpanan dan CRUD riwayat BMI,
5. penghitungan usia realtime,
6. konversi kalender Masehi,
7. kalender Hijriah,
8. kalender Jawa/Weton,
9. kalender Saka Bali,
10. stopwatch,
11. panduan penggunaan,
12. manajemen sesi dan logout.

Seluruh data utama disimpan **secara lokal**. Aplikasi tidak membutuhkan server untuk MVP.

---

# 2. Tujuan Produk

Tujuan utama aplikasi adalah memenuhi seluruh requirement praktikum sekaligus menghasilkan aplikasi yang terlihat seperti produk jadi, bukan sekadar kumpulan halaman tugas.

### Sasaran utama

- Menerapkan navigation Flutter dengan benar.
- Menggunakan SQLite sebagai database lokal.
- Menyediakan login dan session.
- Menyediakan biometric authentication.
- Menyediakan fitur komputasi utama berupa BMI.
- Menyediakan CRUD berdasarkan tema BMI.
- Menyediakan konversi tanggal dan umur.
- Menyediakan kalender Hijriah, Jawa/Weton, dan Saka Bali.
- Menyediakan stopwatch.
- Memiliki UI konsisten dengan referensi warna yang diberikan.
- Menangani input salah dan edge case secara menyeluruh.
- Tetap berfungsi secara offline.

---

# 3. Scope

## In Scope

| Area | Fitur |
|---|---|
| Authentication | Username/password |
| Authentication | Fingerprint / biometric |
| Authentication | Face authentication jika didukung perangkat |
| Session | Persistent local session |
| Database | SQLite |
| Home | 5 menu vertikal |
| Anggota | Informasi anggota kelompok |
| BMI | Kalkulator BMI |
| BMI | Riwayat BMI |
| BMI | Create, Read, Update, Delete |
| Kalender | Gregorian/Masehi |
| Kalender | Hijriah |
| Kalender | Weton Jawa |
| Kalender | Saka Bali |
| Umur | Tahun sampai detik |
| Stopwatch | Start, pause, continue, reset |
| Bantuan | Panduan aplikasi |
| Logout | Konfirmasi + session clear |
| Error Handling | Form, DB, biometric, tanggal, angka |
| Security | Sanitization dan parameterized query |

## Out of Scope untuk MVP

- Cloud synchronization.
- Firebase authentication.
- Registrasi akun publik.
- Multi-device sync.
- Social login.
- Dashboard web.
- Online API.
- Kamera untuk membuat sistem pengenalan wajah sendiri.
- Rekam medis.

---

# 4. Akun Demo

Akun default praktikum:

| Field | Nilai |
|---|---|
| Role | Admin |
| Username | `tofik` |
| Password | `123` |

Credential ini adalah **credential demo/tugas**, bukan credential yang layak digunakan pada production.

Password **tidak boleh disimpan dalam plaintext** di database.

Pada instalasi pertama aplikasi melakukan seed user:

```text
username    : tofik
password    : 123
role        : admin
is_active   : true
```

Tetapi yang masuk SQLite:

```text
username
password_hash
password_salt
role
created_at
updated_at
```

Bukan:

```text
password = "123"
```

---

# 5. User Persona

### Admin / Pengguna Utama

Pengguna dapat:

- login,
- membuka semua fitur,
- menghitung BMI,
- menyimpan BMI,
- melihat riwayat,
- mengubah data BMI,
- menghapus data BMI,
- melakukan konversi kalender,
- menghitung umur,
- menggunakan stopwatch,
- membaca panduan,
- logout.

Tidak diperlukan role kedua untuk MVP.

---

# 6. Information Architecture

Struktur utama:

```text
Splash / Auth Gate
│
├── Login
│
└── Main Application
    │
    ├── Bottom Navigation
    │   ├── Home
    │   ├── Stopwatch
    │   ├── Panduan
    │   └── Logout
    │
    └── Home
        ├── Daftar Anggota
        ├── Kalkulator BMI
        ├── Riwayat BMI / CRUD
        ├── Konversi Tanggal & Umur
        └── Kalender Weton & Saka Bali
```

Dengan struktur ini, **Home tetap memiliki tepat 5 menu vertikal**, sesuai requirement tugas.

Stopwatch dan Panduan mendapatkan akses langsung melalui bottom navigation.

---

# 7. Navigation Requirement

Materi Modul IV menjelaskan stack navigation melalui `push`, `pop`, `pushReplacement`, passing data, serta penggunaan `pushAndRemoveUntil` untuk logout. Semua konsep tersebut diterapkan di aplikasi.

| Perpindahan | Navigation |
|---|---|
| Login → Main App | `pushReplacement()` |
| Home → BMI | `push()` |
| Home → Anggota | `push()` |
| Home → Konversi | `push()` |
| BMI → Riwayat | `push()` |
| Riwayat → Edit | `push()` |
| Detail → kembali | `pop()` |
| Logout → Login | `pushAndRemoveUntil()` |

### Passing Data

Digunakan minimal pada:

```text
Login
   ↓ username
MainShell / Home
```

dan:

```text
BMI History
   ↓ BMIRecord
Edit BMI
```

Contoh secara konsep:

```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => EditBmiPage(record: selectedRecord),
  ),
);
```

Dengan demikian requirement `passing data` juga terpenuhi.

---

# 8. Splash / Authentication Gate

Saat aplikasi dijalankan:

```text
OPEN APP
   ↓
Check Session
   ↓
┌──────────────┐
│ Ada Session? │
└──────┬───────┘
       │
    YES│          NO
       ↓           ↓
   Main App      Login
```

Jika pengguna sebelumnya sudah login dan belum logout:

```text
Splash → Home
```

Jika session tidak ada:

```text
Splash → Login
```

Splash maksimum sekitar **1–1.5 detik**, kecuali initialization database memerlukan waktu lebih lama.

---

# 9. Login Screen

## Layout

```text
┌────────────────────────────┐
│                            │
│        NusaFit Logo        │
│                            │
│       Selamat Datang       │
│                            │
│ ┌────────────────────────┐ │
│ │ Username               │ │
│ └────────────────────────┘ │
│                            │
│ ┌────────────────────────┐ │
│ │ Password          👁   │ │
│ └────────────────────────┘ │
│                            │
│ ┌────────────────────────┐ │
│ │         LOGIN          │ │
│ └────────────────────────┘ │
│                            │
│        ─── atau ───        │
│                            │
│   [ Fingerprint / Face ]   │
│                            │
└────────────────────────────┘
```

---

# 10. Login Validation

### Username

Aturan:

```text
minimum   : 3 karakter
maximum   : 32 karakter
trim      : true
case      : dinormalisasi
```

Input dibersihkan sebelum query.

Contoh:

```text
"   tofik   "
```

menjadi:

```text
"tofik"
```

SQL tidak boleh dibuat seperti:

```dart
"SELECT * FROM users WHERE username = '$username'"
```

Gunakan parameter:

```dart
db.query(
  'users',
  where: 'username = ?',
  whereArgs: [username],
);
```

Ini mencegah SQL injection.

---

# 11. Password Validation

Karena akun demo menggunakan:

```text
123
```

MVP harus mengizinkan password tersebut.

Tetapi:

- field tidak boleh kosong;
- panjang maksimal 64;
- whitespace accidental dapat ditolak;
- tidak boleh langsung dimasukkan ke query SQL;
- password dibandingkan terhadap hash.

Pesan gagal:

> Username atau password salah.

Jangan tampilkan:

> Username benar tetapi password salah.

Ini mencegah username enumeration.

---

# 12. Password Visibility

Field password mempunyai:

```text
👁 Show
👁‍🗨 Hide
```

Default:

```text
obscureText = true
```

---

# 13. Biometric Authentication

Aplikasi mendukung biometrik **berdasarkan data yang sudah terdaftar pada perangkat**.

Tidak membuat sistem face recognition sendiri.

### Bentuk biometric

Pada Android:

- fingerprint,
- face authentication jika disediakan OS/perangkat,
- biometric lainnya yang dikenali sistem.

Pada iOS:

- Face ID,
- Touch ID.

Flutter dapat menggunakan mekanisme OS melalui plugin seperti `local_auth`.

---

# 14. Biometric Enrollment Flow

Login pertama:

```text
Username + Password
        ↓
Login berhasil
        ↓
Device mendukung biometric?
        ↓
       Ya
        ↓
"Aktifkan login biometrik?"
```

Pilihan:

```text
Aktifkan
Nanti
```

Jika aktif:

```text
biometric_enabled = true
```

Yang disimpan hanya status penggunaannya.

**Fingerprint template atau data wajah tidak pernah disimpan aplikasi.**

---

# 15. Biometric Error Handling

| Kondisi | Respons |
|---|---|
| Tidak ada sensor | Sembunyikan tombol biometric |
| Belum enroll | "Biometrik belum didaftarkan pada perangkat." |
| Gagal membaca | "Verifikasi gagal. Silakan coba lagi." |
| User cancel | Tetap di Login |
| Sensor lockout | Gunakan username dan password |
| Hardware unavailable | Gunakan login biasa |
| App restart | biometric dapat digunakan kembali |

---

# 16. Session

Session menyimpan minimal:

```text
user_id
username
role
isLoggedIn
```

Untuk data session sensitif gunakan secure storage.

Password **tidak disimpan pada session**.

### Logout

Logout harus:

1. menampilkan confirmation dialog,
2. clear session,
3. tidak menghapus data BMI,
4. menghapus seluruh navigation stack,
5. kembali ke Login.

Implementasi:

```dart
Navigator.pushAndRemoveUntil(
  context,
  MaterialPageRoute(builder: (_) => LoginPage()),
  (route) => false,
);
```

Pendekatan ini juga sesuai mekanisme logout yang dijelaskan pada halaman akhir Modul IV.

---

# 17. Main Bottom Navigation

Final navbar:

```text
┌────────────────────────────────────────┐
│   Home     Stopwatch    Panduan Logout │
│    🏠         ⏱          ❔       ⇥    │
└────────────────────────────────────────┘
```

### Menu

| Index | Menu | Icon |
|---:|---|---|
| 0 | Home | Home |
| 1 | Stopwatch | Timer |
| 2 | Panduan | Help |
| 3 | Logout | Logout |

Logout sebenarnya **action**, bukan halaman.

Jika dipilih:

```text
Logout
  ↓
Dialog konfirmasi
```

---

# 18. Logout Confirmation

```text
Keluar dari aplikasi?

Session login pada perangkat ini akan dihentikan.
Data BMI yang telah disimpan tidak akan dihapus.

[Batal] [Logout]
```

Logout hanya berjalan jika tombol `Logout` ditekan.

---

# 19. Home Screen

Home mempunyai **5 menu utama vertikal**.

```text
┌────────────────────────────┐
│ NusaFit                     │
│ Halo, tofik                 │
│                            │
│ ┌────────────────────────┐ │
│ │ 👥 Daftar Anggota      │ │
│ └────────────────────────┘ │
│                            │
│ ┌────────────────────────┐ │
│ │ ⚖ Kalkulator BMI       │ │
│ └────────────────────────┘ │
│                            │
│ ┌────────────────────────┐ │
│ │ 🗂 Riwayat BMI         │ │
│ └────────────────────────┘ │
│                            │
│ ┌────────────────────────┐ │
│ │ 📅 Konversi & Umur     │ │
│ └────────────────────────┘ │
│                            │
│ ┌────────────────────────┐ │
│ │ 🌙 Weton & Saka Bali   │ │
│ └────────────────────────┘ │
│                            │
├────────────────────────────┤
│ Home  Stopwatch Panduan ⇥  │
└────────────────────────────┘
```

Menu berada di tengah layar secara vertikal dan dapat menjadi `SingleChildScrollView` pada layar kecil.

---

# 20. Menu 1 — Daftar Anggota

Screen menampilkan anggota kelompok.

Contoh:

```text
Daftar Anggota

┌──────────────────────────┐
│ [Foto] Nama Anggota 1    │
│        NIM               │
│        Role              │
└──────────────────────────┘

┌──────────────────────────┐
│ [Foto] Nama Anggota 2    │
│        NIM               │
│        Role              │
└──────────────────────────┘
```

Field:

```text
foto
nama
NIM
role/tugas
```

Contoh role:

- Project Manager
- UI/UX
- Flutter Developer
- Database Developer

Data anggota dapat disimpan sebagai constant karena bukan data bisnis yang berubah.

---

# 21. Menu 2 — BMI Calculator

## Input

BMI membutuhkan:

```text
Nama
Umur
Berat badan
Tinggi badan
```

Form:

```text
Nama
[________________________]

Umur
[________________________] tahun

Berat
[________________________] kg

Tinggi
[________________________] cm

          [ HITUNG BMI ]
```

---

# 22. BMI Input Rules

### Nama

```text
minimum : 2 karakter
maximum : 60 karakter
```

Dukungan:

- huruf Unicode,
- spasi,
- `'`,
- `-`.

Input dibersihkan:

```text
trim()
collapse duplicate whitespace
```

---

# 23. Umur

Requirement:

```text
minimum : 1 tahun
maximum : 300 tahun
```

Valid:

```text
1
20
25
100
300
```

Invalid:

```text
0
-1
301
abc
20.5
1e10
```

Pesan:

> Umur harus berupa angka bulat antara 1–300 tahun.

---

# 24. Berat Badan

Requirement maksimum:

```text
1000 kg
```

Range:

```text
> 0
≤ 1000 kg
```

Decimal diperbolehkan:

```text
70
70.5
70.25
```

Invalid:

```text
0
-12
1000.1
abc
NaN
Infinity
1e999
```

Pesan:

> Berat badan harus lebih dari 0 dan maksimal 1000 kg.

---

# 25. Tinggi Badan

Requirement maksimum:

```text
400 cm
```

Range:

```text
> 0
≤ 400 cm
```

Contoh valid:

```text
175
175.5
```

Invalid:

```text
0
-175
401
abc
NaN
Infinity
```

Pesan:

> Tinggi badan harus lebih dari 0 dan maksimal 400 cm.

---

# 26. Numeric Sanitization

Field numeric menggunakan keyboard numeric.

Karakter tidak valid tidak boleh diterima.

Contoh:

```text
12abc
<>123
--50
12..3
```

harus dicegah sebelum proses kalkulasi.

Sistem juga harus mengecek hasil parsing:

```dart
final value = double.tryParse(input);
```

Jika:

```dart
value == null
```

proses berhenti.

---

# 27. Formula BMI

Formula:

\[
BMI=\frac{berat\ (kg)}{tinggi(m)^2}
\]

Contoh:

```text
Berat = 70 kg
Tinggi = 175 cm

Tinggi meter = 1.75
BMI = 70 / (1.75 × 1.75)

BMI = 22.86
```

Display:

```text
22.86
```

Maksimal dua digit decimal.

---

# 28. Kategori BMI

Untuk kebutuhan aplikasi praktikum digunakan:

| BMI | Kategori |
|---:|---|
| < 18.5 | Kurang berat badan |
| 18.5 – 24.9 | Normal |
| 25.0 – 29.9 | Overweight |
| ≥ 30 | Obesitas |

Aplikasi ini adalah **aplikasi edukasi/praktikum**, bukan alat diagnosis medis.

---

# 29. BMI Result — Normal

Apabila BMI normal:

```text
BACKGROUND:
GREEN
```

Contoh:

```text
╔════════════════════════════╗
║                            ║
║            ✓               ║
║                            ║
║          22.86             ║
║          NORMAL            ║
║                            ║
║      Kondisi BMI normal    ║
║                            ║
║ [Simpan]      [Kembali]    ║
╚════════════════════════════╝
```

Warna utama:

```text
#2E7D32
```

---

# 30. BMI Result — Overweight

Apabila:

```text
BMI >= 25
```

maka tampilan berubah drastis.

```text
████████████████████████████
██                        ██
██          ⚠             ██
██                        ██
██         27.42          ██
██      OVERWEIGHT        ██
██                        ██
██  Berat badan melebihi  ██
██  rentang BMI normal    ██
██                        ██
████████████████████████████
```

Background:

```text
RED
```

Dengan animasi pulse/blinking.

### Animation

Bukan flash ekstrem.

Gunakan transisi misalnya:

```text
700 ms red dark
700 ms red bright
repeat
```

Jangan lebih dari **3 flash per detik**.

Jika perangkat memiliki setting Reduce Motion, animasi dihentikan dan menggunakan background merah statis.

---

# 31. BMI Underweight

Untuk BMI `<18.5`:

```text
warna amber/orange
```

Contoh:

```text
#ED6C02
```

Bukan merah karena merah secara khusus dipakai sebagai warning overweight/obesitas.

---

# 32. BMI Obesity

Jika:

```text
BMI >= 30
```

gunakan:

```text
deep red
```

Dengan pesan:

> BMI berada pada kategori obesitas.

---

# 33. Penyimpanan BMI

Setelah hitung berhasil:

```text
[Simpan Hasil]
```

Ketika ditekan:

```text
INSERT bmi_records
```

Field:

```text
name
age
weight
height
bmi
category
created_at
```

Jika sukses:

> Hasil BMI berhasil disimpan.

Jika record belum disimpan, jangan membuat duplikasi hanya karena rebuild widget.

---

# 34. Menu 3 — Riwayat BMI / CRUD

CRUD harus lengkap:

```text
C = Create
R = Read
U = Update
D = Delete
```

---

# 35. BMI History List

```text
Riwayat BMI

🔎 Cari nama

┌────────────────────────────┐
│ Taufik                     │
│ 70 kg • 175 cm             │
│ BMI 22.86 • Normal         │
│ 15 Sep 2026 20:15          │
│                    ⋮       │
└────────────────────────────┘
```

Actions:

```text
Lihat
Edit
Hapus
```

---

# 36. Create

Create terjadi setelah BMI dihitung dan user memilih:

```text
Simpan Hasil
```

atau tombol:

```text
+ Tambah
```

dari halaman history.

---

# 37. Read

Pengguna dapat melihat:

```text
Nama
Umur
Berat
Tinggi
BMI
Kategori
Tanggal dibuat
Terakhir diperbarui
```

---

# 38. Update

Edit BMI record:

```text
Edit Data BMI

Nama
Umur
Berat
Tinggi

[Hitung Ulang & Simpan]
```

Saat berat atau tinggi berubah:

```text
BMI wajib dihitung ulang
kategori wajib dihitung ulang
updated_at diperbarui
```

Tidak boleh mengedit nilai BMI secara manual.

---

# 39. Delete

Pengguna memilih:

```text
Hapus
```

Confirmation:

```text
Hapus data BMI?

Data BMI "Taufik - 22.86" akan dihapus permanen.

[Batal]
[Hapus]
```

Baru setelah confirmation:

```sql
DELETE ...
```

---

# 40. Empty State

Jika belum mempunyai history:

```text
📋

Belum Ada Riwayat BMI

Hitung BMI terlebih dahulu untuk
menyimpan riwayat pengukuran.

[Hitung BMI]
```

Jangan menampilkan blank screen.

---

# 41. Menu 4 — Konversi Tanggal & Umur

Ini menjadi salah satu fitur utama.

Konsep:

> **Sekali input tanggal → semua hasil otomatis tersedia.**

Default kalender input:

```text
MASEHI
```

Contoh:

```text
Input:
01 Januari 1999
```

Sistem langsung menghasilkan:

```text
Masehi
Hijriah
Weton
Saka Bali
Usia
```

Tidak perlu melakukan konversi satu per satu.

---

# 42. UI Tanggal

```text
Konversi Tanggal

Tanggal Masehi
┌───────────────────────────┐
│ 📅 01 Januari 1999        │
└───────────────────────────┘

[ SEMUA ] [ HIJRIAH ] [ WETON ] [ BALI ]

Masehi
01 Januari 1999

Hijriah
....

Weton
....

Saka Bali
....

Usia Sekarang
27 Tahun
8 Bulan
14 Hari
20 Jam
41 Menit
37 Detik
```

---

# 43. Default Kalender

Setiap kali screen dibuka:

```text
Input Calendar = Masehi
```

User hanya memilih tanggal satu kali.

Hasil kalender lain dihitung secara bersamaan.

---

# 44. Real-Time Switch

Segment:

```text
Semua
Masehi
Hijriah
Weton
Saka Bali
```

Jika:

```text
Semua
```

seluruh kalender tampil.

Jika memilih:

```text
Hijriah
```

fokus UI berpindah ke detail Hijriah, tetapi nilai kalender lain tetap tersimpan di state.

Tidak dilakukan kalkulasi ulang yang tidak diperlukan.

---

# 45. Umur Realtime

Setelah tanggal lahir dipilih:

```text
now - birthDateTime
```

Display:

```text
27 tahun
8 bulan
14 hari
20 jam
41 menit
32 detik
```

Detik berubah:

```text
32
33
34
35
...
```

secara realtime.

Gunakan timer setiap:

```text
1 second
```

Timer wajib di-cancel pada:

```dart
dispose()
```

agar tidak terjadi memory leak.

---

# 46. Format Usia

Usia terurai harus **dinormalisasi**:

```text
tahun   : bebas
bulan   : 0–11
hari    : sesuai remainder kalender
jam     : 0–23
menit   : 0–59
detik   : 0–59
```

Contoh:

```text
27 tahun 8 bulan 14 hari
20 jam 41 menit 32 detik
```

Jangan menghasilkan kombinasi tidak ternormalisasi seperti:

```text
22 tahun 19 bulan 122 hari
```

Sebagai tambahan, aplikasi dapat menampilkan:

### Total elapsed

```text
Total bulan
Total hari
Total jam
Total menit
Total detik
```

Sehingga kebutuhan untuk mengetahui durasi total tetap terpenuhi tanpa merusak format umur kalender.

---

# 47. Date of Birth Time

Jika user hanya memilih tanggal:

```text
time = 00:00:00 local time
```

Opsional terdapat:

```text
Pilih Jam Lahir
```

Jika dipilih:

```text
Tanggal : 01/01/1999
Jam     : 13:20:00
```

umur jam/menit/detik akan lebih presisi.

---

# 48. Date Validation

Tanggal lahir tidak boleh:

```text
> waktu sekarang
```

Pesan:

> Tanggal lahir tidak boleh berada di masa depan.

Tanggal juga dibatasi:

```text
maksimal umur = 300 tahun
```

Jika lebih tua:

> Umur maksimal yang didukung adalah 300 tahun.

---

# 49. Leap Year Handling

Harus menangani:

```text
29 Februari 2000
29 Februari 2004
29 Februari 2024
```

dan menolak:

```text
29 Februari 2023
31 April
32 Januari
```

Penggunaan `DatePicker` lebih disukai agar tanggal invalid tidak dapat dimasukkan sejak awal.

---

# 50. Hijriah Conversion

Output minimal:

```text
hari
bulan Hijriah
tahun Hijriah
```

Contoh display:

```text
Kalender Hijriah

12 Rabiul Awal 1448 H
```

Karena kalender Hijriah berbasis sistem lunar dan metode kalender dapat berbeda, hasil offline harus menggunakan **satu metode yang konsisten**.

UI dapat menampilkan catatan kecil:

> Konversi Hijriah dihitung secara algoritmik dan pada kondisi tertentu dapat berbeda dari penetapan observasional.

---

# 51. Weton Jawa

Output:

```text
Hari Gregorian/Jawa
Pasaran
Weton
Neptu
```

Contoh format:

```text
Hari      : Jumat
Pasaran   : Legi
Weton     : Jumat Legi
Neptu     : 11
```

Pasaran:

```text
Legi
Pahing
Pon
Wage
Kliwon
```

---

# 52. Neptu

Contoh model data:

### Hari

| Hari | Nilai |
|---|---:|
| Minggu | 5 |
| Senin | 4 |
| Selasa | 3 |
| Rabu | 7 |
| Kamis | 8 |
| Jumat | 6 |
| Sabtu | 9 |

### Pasaran

| Pasaran | Nilai |
|---|---:|
| Legi | 5 |
| Pahing | 9 |
| Pon | 7 |
| Wage | 4 |
| Kliwon | 8 |

Kemudian:

```text
neptu = nilaiHari + nilaiPasaran
```

---

# 53. Saka Bali

Output dibuat dalam card terpisah:

```text
Kalender Saka Bali

Tahun Saka   : ...
Sasih        : ...
Tanggal      : ...
Hari         : ...
```

Jika implementasi memasukkan komponen Pawukon, dapat diperluas menjadi:

```text
Saptawara
Pancawara
Wuku
Sasih
Tahun Saka
```

Algoritma Saka Bali harus diuji menggunakan dataset tanggal referensi karena perhitungannya lebih kompleks daripada Gregorian.

---

# 54. Prinsip Konversi

Satu tanggal:

```text
DateTime selectedDate
```

menjadi satu **single source of truth**.

Kemudian:

```text
selectedDate
 ├── GregorianConverter
 ├── HijriConverter
 ├── WetonCalculator
 ├── BaliCalendarConverter
 └── AgeCalculator
```

Tidak memiliki empat field tanggal berbeda.

Ini mencegah data tidak sinkron.

---

# 55. Menu 5 — Kalender Nusantara

Card ini fokus pada eksplorasi lebih detail:

```text
Weton Jawa
Saka Bali
```

Input masih:

```text
Tanggal Masehi
```

Output menggunakan card detail.

Dengan begitu requirement kalender mempunyai halaman tersendiri, walaupun versi ringkasnya juga dapat tampil pada halaman Konversi.

---

# 56. Stopwatch

Bottom navbar:

```text
STOPWATCH
```

UI dibuat berbeda dari stopwatch generik.

```text
┌─────────────────────────────┐
│         STOPWATCH           │
│                             │
│          ◯◯◯◯◯             │
│      ╭─────────────╮        │
│      │ 00:00:00.00 │        │
│      ╰─────────────╯        │
│                             │
│  [RESET]       [START]      │
│                             │
└─────────────────────────────┘
```

Background dapat mempunyai siluet jam besar transparan.

---

# 57. Stopwatch States

State:

```text
idle
running
paused
```

### Idle

```text
00:00:00.00
START aktif
RESET nonaktif / neutral
```

### Running

```text
START → PAUSE
RESET tersedia
```

### Paused

```text
PAUSE → CONTINUE
RESET tersedia
```

---

# 58. Stopwatch Format

```text
HH : MM : SS . CS
```

Contoh:

```text
01:23:41.56
```

`CS` = centisecond.

Internal time sebaiknya berdasarkan elapsed time, bukan hanya menghitung jumlah callback timer, agar lebih akurat.

---

# 59. Stopwatch Navigation Behavior

Gunakan `IndexedStack` pada main shell sehingga jika user:

```text
Start Stopwatch
→ Home
→ Stopwatch
```

state stopwatch **tetap berjalan**.

Jangan mereset karena pindah bottom navigation tab.

---

# 60. Panduan

Bottom menu:

```text
Panduan
```

Konten:

```text
1. Cara Login
2. Login Fingerprint / Face
3. Menu Utama
4. Menghitung BMI
5. Membaca Hasil BMI
6. Menyimpan Riwayat
7. Edit Data BMI
8. Menghapus Data BMI
9. Konversi Tanggal
10. Menghitung Umur
11. Kalender Hijriah
12. Weton Jawa
13. Kalender Saka Bali
14. Stopwatch
15. Logout
```

Dapat menggunakan:

```dart
ExpansionTile
```

agar tidak terlalu panjang.

---

# 61. Design System

## Primary Gradient

Mengikuti screenshot referensi:

```text
0%   #114177
50%  #006A9A
100% #17A18A
```

Gradient:

```text
#114177
    ↓
#006A9A
    ↓
#17A18A
```

Untuk horizontal:

```text
#114177 → #006A9A → #17A18A
```

---

# 62. Color Palette

| Token | Hex | Fungsi |
|---|---|---|
| Primary Dark | `#114177` | Gradient awal |
| Primary | `#006A9A` | Brand |
| Primary Teal | `#17A18A` | Gradient akhir |
| Surface | `#FFFFFF` | Card |
| Secondary Background | `#EEEEEE` | Background |
| Text Primary | `#1F2937` | Judul |
| Text Secondary | `#6B7280` | Description |
| Success | `#2E7D32` | BMI normal |
| Warning | `#ED6C02` | Underweight |
| Danger | `#D32F2F` | Overweight |
| Danger Dark | `#B71C1C` | Obesitas |
| Divider | `#E5E7EB` | Border |

Dengan requirement user:

```text
Secondary = #EEEEEE
White     = #FFFFFF
```

---

# 63. Gradient Usage

Gradient digunakan pada:

- app bar,
- primary button,
- logo background,
- selected navigation indicator,
- accent component,
- splash screen.

Jangan digunakan pada seluruh card karena akan membuat hierarchy visual kacau.

---

# 64. Screen Background

Default:

```text
#EEEEEE
```

Card:

```text
#FFFFFF
```

Contoh:

```text
Background #EEEEEE

   ┌────────────────────┐
   │ White Card #FFFFFF │
   └────────────────────┘
```

---

# 65. Border Radius

Standard:

```text
Small  : 8 px
Input  : 12 px
Card   : 16 px
Button : 14–16 px
Dialog : 20 px
```

Home cards:

```text
16 px
```

---

# 66. Spacing

Gunakan sistem 8-point:

```text
4
8
12
16
24
32
40
48
```

Standard horizontal padding:

```text
20–24 px
```

---

# 67. Typography

Gunakan Material typography / Roboto agar tidak membutuhkan font tambahan.

### H1

```text
28sp
Bold
```

### H2

```text
22sp
SemiBold
```

### Card Title

```text
16–18sp
SemiBold
```

### Body

```text
14–16sp
Regular
```

### Caption

```text
12–13sp
```

### Stopwatch

```text
48–56sp
Bold
Tabular numbers
```

---

# 68. Bottom Navigation Design

Terinspirasi screenshot yang diberikan:

```text
white container
rounded upper corners
soft shadow
icon + label
```

Height sekitar:

```text
72–80 dp
```

Selected item menggunakan:

```text
#006A9A
```

atau gradient accent.

Unselected:

```text
#9CA3AF
```

Logout:

```text
#D32F2F
```

ketika aktif/ditekan.

---

# 69. Home Card Design

```text
┌──────────────────────────────┐
│ ┌──────┐                     │
│ │ ICON │  Kalkulator BMI  >  │
│ └──────┘                     │
│          Hitung BMI Anda     │
└──────────────────────────────┘
```

Card:

```text
background     #FFFFFF
radius         16
elevation      low
height         ~84–96
```

---

# 70. AppBar

Contoh:

```text
╔══════════════════════════════╗
║ ←  Kalkulator BMI            ║
╚══════════════════════════════╝
```

Gradient:

```text
#114177 → #006A9A → #17A18A
```

Text:

```text
white
```

---

# 71. Button System

### Primary Button

Gradient.

```text
[ HITUNG BMI ]
```

### Secondary

White dengan border primary.

```text
[ BATAL ]
```

### Destructive

```text
#D32F2F
```

```text
[ HAPUS ]
```

---

# 72. Loading State

Database action sangat cepat, tetapi tombol tetap harus mencegah double submit.

Saat saving:

```text
[Simpan]
```

menjadi:

```text
[ ◌ Menyimpan... ]
```

Button disabled.

---

# 73. SQLite Architecture

Database:

```text
nusafit.db
```

Version:

```text
1
```

---

# 74. Table `users`

```sql
users
--------------------------------
id                INTEGER PK
username          TEXT UNIQUE
password_hash     TEXT
password_salt     TEXT
role              TEXT
biometric_enabled INTEGER
is_active         INTEGER
created_at        TEXT
updated_at        TEXT
```

Seed:

```text
username = tofik
role = admin
```

---

# 75. Table `bmi_records`

```sql
bmi_records
--------------------------------
id          INTEGER PRIMARY KEY
user_id     INTEGER
name        TEXT
age         INTEGER
weight_kg   REAL
height_cm   REAL
bmi         REAL
category    TEXT
created_at  TEXT
updated_at  TEXT
```

Foreign key:

```text
user_id → users.id
```

---

# 76. SQLite Query Security

Tidak boleh:

```dart
db.rawQuery(
  "SELECT * FROM users WHERE username = '$username'"
);
```

Gunakan:

```dart
db.query(
  'users',
  where: 'username = ?',
  whereArgs: [username],
);
```

Delete:

```dart
db.delete(
  'bmi_records',
  where: 'id = ?',
  whereArgs: [id],
);
```

Update:

```dart
db.update(
  'bmi_records',
  values,
  where: 'id = ?',
  whereArgs: [id],
);
```

---

# 77. Data Model

### User

```text
User
├── id
├── username
├── role
├── biometricEnabled
└── isActive
```

### BMIRecord

```text
BMIRecord
├── id
├── userId
├── name
├── age
├── weightKg
├── heightCm
├── bmi
├── category
├── createdAt
└── updatedAt
```

---

# 78. Recommended Flutter Architecture

Untuk ukuran tugas ini:

```text
UI
 ↓
Controller / Provider
 ↓
Service
 ↓
Repository
 ↓
SQLite
```

Jangan menulis semua query langsung di widget.

---

# 79. Suggested Folder Structure

```text
lib/
│
├── main.dart
│
├── app.dart
│
├── core/
│   ├── constants/
│   │   ├── colors.dart
│   │   ├── dimensions.dart
│   │   └── routes.dart
│   │
│   ├── database/
│   │   └── database_helper.dart
│   │
│   ├── security/
│   │   ├── password_service.dart
│   │   └── biometric_service.dart
│   │
│   └── utils/
│       ├── validators.dart
│       ├── bmi_calculator.dart
│       ├── age_calculator.dart
│       ├── hijri_converter.dart
│       ├── weton_calculator.dart
│       └── bali_calendar_converter.dart
│
├── data/
│   ├── models/
│   │   ├── user.dart
│   │   └── bmi_record.dart
│   │
│   └── repositories/
│       ├── auth_repository.dart
│       └── bmi_repository.dart
│
├── features/
│   ├── auth/
│   ├── home/
│   ├── members/
│   ├── bmi/
│   ├── date_converter/
│   ├── calendar/
│   ├── stopwatch/
│   └── help/
│
└── widgets/
    ├── gradient_button.dart
    ├── app_card.dart
    ├── custom_text_field.dart
    └── confirmation_dialog.dart
```

---

# 80. Suggested Dependencies

Tanpa mengikat ke versi tertentu:

```text
sqflite
path
flutter_secure_storage
local_auth
intl
provider
crypto
```

Untuk kalender Hijriah dapat menggunakan package terpercaya atau implementasi utility yang tervalidasi.

Weton dan Saka Bali dapat dibuat sebagai local calculation service.

---

# 81. Error Handling Standard

Tidak boleh ada silent error.

Semua operasi memiliki:

```text
success state
validation state
error state
```

---

# 82. Form Error Matrix

| Kasus | Respons |
|---|---|
| Nama kosong | "Nama wajib diisi." |
| Umur kosong | "Umur wajib diisi." |
| Umur nonnumeric | "Umur harus berupa angka." |
| Umur >300 | "Umur maksimal 300 tahun." |
| Berat kosong | "Berat badan wajib diisi." |
| Berat <=0 | "Berat harus lebih dari 0 kg." |
| Berat >1000 | "Berat maksimal 1000 kg." |
| Tinggi kosong | "Tinggi badan wajib diisi." |
| Tinggi <=0 | "Tinggi harus lebih dari 0 cm." |
| Tinggi >400 | "Tinggi maksimal 400 cm." |
| Tanggal future | "Tanggal tidak boleh berada di masa depan." |
| Umur >300 | "Tanggal berada di luar rentang yang didukung." |

---

# 83. Database Error Handling

Jika insert gagal:

> Data gagal disimpan. Silakan coba lagi.

Update gagal:

> Perubahan gagal disimpan.

Delete gagal:

> Data gagal dihapus.

Database init gagal:

```text
Halaman Error
Database tidak dapat dibuka.

[Coba Lagi]
```

Aplikasi tidak crash langsung.

---

# 84. Double Click Prevention

Tombol seperti:

```text
Login
Simpan
Hapus
Update
```

harus disable saat operasi sedang berlangsung.

Contoh:

```text
isSubmitting == true
```

maka button disabled.

Ini mencegah duplicate row.

---

# 85. Input Sanitization

Sanitization dilakukan **sebelum validation dan storage**.

Contoh string:

```text
"    Taufik    Maulana "
```

menjadi:

```text
"Taufik Maulana"
```

Numeric:

```text
70,5
```

dapat dinormalisasi menjadi:

```text
70.5
```

jika locale Indonesia didukung.

---

# 86. Forbidden Numeric Values

Sistem tidak boleh menerima:

```text
NaN
Infinity
-Infinity
1e999999
```

Cek:

```dart
value.isFinite
```

---

# 87. Transaction Safety

Untuk operasi yang membutuhkan lebih dari satu query gunakan transaction.

Contoh:

```text
create user
+ create related setting
```

Jika query kedua gagal:

```text
rollback
```

---

# 88. Offline Requirement

Fitur berikut harus 100% berfungsi tanpa internet:

```text
Login
Fingerprint/Face
BMI
CRUD BMI
Tanggal
Usia
Hijriah
Weton
Saka Bali
Stopwatch
Panduan
Logout
```

Tidak boleh membutuhkan API remote.

---

# 89. Performance Requirements

Target:

| Operasi | Target |
|---|---:|
| Startup | < 2 s |
| Login local | < 500 ms |
| BMI calculation | < 50 ms |
| History query | < 500 ms |
| Date conversion | < 200 ms |
| Screen navigation | smooth |
| Stopwatch UI | responsive |

Untuk tugas kuliah, angka ini adalah target engineering, bukan hard SLA.

---

# 90. Accessibility

Minimum touch target:

```text
48 × 48 dp
```

Contrast normal text:

```text
≥ 4.5 : 1
```

Informasi BMI tidak boleh diberikan hanya berdasarkan warna.

Contoh jangan hanya:

```text
RED
```

Tetapi:

```text
OVERWEIGHT
BMI 27.4
```

---

# 91. Reduce Motion

Blinking BMI warning harus mengikuti setting aksesibilitas sebisa mungkin.

Jika reduced motion aktif:

```text
animation = false
```

Background tetap merah.

---

# 92. Responsive Layout

Minimum target:

```text
360 × 640 logical pixel
```

Juga harus nyaman pada:

```text
393 × 852
411 × 915
```

Jangan hardcode:

```dart
width: 393
```

Gunakan:

```dart
MediaQuery
LayoutBuilder
Expanded
Flexible
```

---

# 93. Keyboard Handling

Saat keyboard muncul:

```text
field tidak tertutup
button tetap dapat dijangkau
```

Form menggunakan:

```text
SingleChildScrollView
```

dan focus traversal.

---

# 94. Back Button

### Detail page

Android Back:

```text
Navigator.pop()
```

### Main Home

Back dapat memunculkan:

```text
Keluar dari aplikasi?
```

Bukan kembali ke Login.

Karena Login sudah direplace dari stack.

Ini adalah perilaku yang juga sejalan dengan tujuan penggunaan `pushReplacement()` pada Modul IV.

---

# 95. Complete Main Flow

```text
OPEN APP
   │
   ↓
Splash
   │
   ├── Session Valid ───────────┐
   │                            │
   ↓                            │
Login                           │
   │                            │
   ├── Credential               │
   └── Biometric                │
       │                        │
       ↓                        │
     Home ◄─────────────────────┘
       │
       ├── Daftar Anggota
       │
       ├── BMI
       │      ├── Result
       │      └── Save
       │
       ├── BMI History
       │      ├── Detail
       │      ├── Edit
       │      └── Delete
       │
       ├── Tanggal & Umur
       │      ├── Masehi
       │      ├── Hijriah
       │      ├── Weton
       │      └── Saka Bali
       │
       └── Kalender Nusantara

Bottom Navigation
       │
       ├── Home
       ├── Stopwatch
       ├── Panduan
       └── Logout
```

---

# 96. Functional Requirement IDs

| ID | Requirement | Priority |
|---|---|---|
| AUTH-01 | Login username/password | Must |
| AUTH-02 | SQLite user | Must |
| AUTH-03 | Persistent session | Must |
| AUTH-04 | Biometric login | Must |
| AUTH-05 | Logout clear stack | Must |
| NAV-01 | Navigator.push | Must |
| NAV-02 | Navigator.pop | Must |
| NAV-03 | pushReplacement | Must |
| NAV-04 | Passing data | Must |
| HOME-01 | 5 vertical menus | Must |
| BMI-01 | Name input | Must |
| BMI-02 | Age validation | Must |
| BMI-03 | Weight ≤1000 | Must |
| BMI-04 | Height ≤400 | Must |
| BMI-05 | BMI calculation | Must |
| BMI-06 | Result animation | Must |
| CRUD-01 | Save result | Must |
| CRUD-02 | Show history | Must |
| CRUD-03 | Update | Must |
| CRUD-04 | Delete | Must |
| DATE-01 | Gregorian input | Must |
| DATE-02 | Age realtime | Must |
| DATE-03 | Hijri conversion | Must |
| DATE-04 | Weton | Must |
| DATE-05 | Saka Bali | Must |
| SW-01 | Start | Must |
| SW-02 | Pause | Must |
| SW-03 | Continue | Must |
| SW-04 | Reset | Must |
| HELP-01 | User guide | Must |

---

# 97. Acceptance Criteria — Authentication

Login dianggap selesai jika:

- `tofik / 123` dapat login.
- Password salah tidak bisa login.
- Username salah tidak bisa login.
- Input kosong memiliki error message.
- Password dapat show/hide.
- Login sukses tidak dapat kembali ke login melalui Back.
- Session tersimpan.
- Restart aplikasi mempertahankan session.
- Logout menghapus session.
- Logout menghapus navigation stack.
- Biometric tersedia jika device mendukung.
- Login credential selalu menjadi fallback biometric.

---

# 98. Acceptance Criteria — BMI

BMI selesai jika:

- menerima decimal,
- menolak huruf,
- menolak berat >1000,
- menolak tinggi >400,
- menolak umur >300,
- mencegah tinggi 0,
- mencegah division by zero,
- BMI dibulatkan 2 decimal,
- hasil normal berwarna hijau,
- overweight berwarna merah,
- overweight memiliki animation warning,
- hasil dapat disimpan,
- saved data muncul di history.

---

# 99. Acceptance Criteria — CRUD

CRUD dianggap lengkap jika:

```text
Create → berhasil
Read   → berhasil
Update → berhasil
Delete → berhasil
```

Selain itu:

- update menghitung BMI ulang,
- delete mempunyai confirmation,
- deleted row hilang dari list,
- list update tanpa restart app,
- empty state tampil saat data kosong.

---

# 100. Acceptance Criteria — Date

Tanggal selesai jika:

- default Gregorian/Masehi,
- satu kali input,
- seluruh output langsung dihitung,
- Hijriah tampil,
- Weton tampil,
- Saka Bali tampil,
- umur tampil,
- detik realtime,
- future date ditolak,
- >300 tahun ditolak,
- leap year tertangani.

---

# 101. Acceptance Criteria — Stopwatch

- Start bekerja.
- Pause bekerja.
- Continue bekerja.
- Reset bekerja.
- Navigasi Home tidak me-reset stopwatch.
- Tidak membuat timer leak.
- Tombol besar dan mudah ditekan.
- Layout tidak overflow.

---

# 102. Acceptance Criteria — Bottom Navbar

Harus terdapat:

```text
Home
Stopwatch
Panduan
Logout
```

Home, Stopwatch dan Panduan berpindah melalui shell navigation.

Logout memunculkan dialog.

---

# 103. Test Case Penting

### BMI Boundary Test

```text
Weight:
0
0.01
999.99
1000
1000.01

Height:
0
0.01
399.99
400
400.01

Age:
0
1
299
300
301
```

---

# 104. Security Test

Masukkan username:

```text
' OR 1=1 --
```

Hasil:

```text
LOGIN GAGAL
```

Bukan login sukses.

Masukkan nama:

```text
Robert'); DROP TABLE bmi_records;--
```

harus diperlakukan sebagai string biasa, tidak mengeksekusi SQL.

---

# 105. Date Boundary Test

Test:

```text
29-02-2000
29-02-2004
29-02-2024
28-02-2100
```

Test invalid:

```text
29-02-2023
31-04-2020
future date
>300 year ago
```

---

# 106. Biometric Test

Test minimal:

```text
biometric tersedia
biometric tidak tersedia
belum enroll
success
failed
cancel
lockout
```

Tidak boleh crash dalam seluruh kondisi tersebut.

---

# 107. Database Migration

SQLite wajib mempunyai:

```text
database version
onCreate()
onUpgrade()
```

Jangan hanya:

```text
delete database and recreate
```

setiap schema berubah.

Itu akan menghilangkan data user.

---

# 108. UI State

Setiap page minimal memiliki state:

```text
initial
loading
success
empty
error
```

History contoh:

```text
loading → spinner
empty   → empty state
success → records
error   → retry
```

---

# 109. Confirmation Dialog Standard

Digunakan pada:

```text
Delete BMI
Logout
Exit application
```

Destructive button selalu jelas.

```text
Batal
Hapus
```

Jangan menjadikan destructive action default button.

---

# 110. Snackbar Standard

Success:

> Data berhasil disimpan.

Error:

> Data gagal disimpan.

Delete:

> Data berhasil dihapus.

Update:

> Data berhasil diperbarui.

---

# 111. Suggested App Name & Identity

Nama kerja:

# **NusaFit**

Subtitle:

> **BMI & Kalender Nusantara**

Alasan cocok:

- BMI → Fit
- Weton dan Saka Bali → Nusa
- tidak terlalu panjang
- dapat dibuat logo `N + heartbeat/calendar`.

---

# 112. Logo Concept

```text
      N
    ╱   ╲
   ♥  📅
```

Atau icon:

```text
calendar outline
+
heartbeat line
```

Gradient:

```text
#114177
#006A9A
#17A18A
```

---

# 113. Suggested Home Copy

Header:

```text
Halo, tofik
Apa yang ingin kamu gunakan?
```

Cards:

```text
Daftar Anggota
Lihat anggota kelompok

Kalkulator BMI
Hitung indeks massa tubuh

Riwayat BMI
Kelola hasil perhitungan

Konversi Tanggal & Umur
Hitung umur dan kalender

Kalender Nusantara
Weton Jawa dan Saka Bali
```

---

# 114. Laporan Pembuatan Aplikasi

Karena tugas juga meminta laporan, struktur laporan sebaiknya:

```text
BAB I PENDAHULUAN
1.1 Latar Belakang
1.2 Tujuan
1.3 Manfaat

BAB II ANALISIS KEBUTUHAN
2.1 Functional Requirement
2.2 Non-functional Requirement
2.3 Use Case
2.4 User Flow

BAB III PERANCANGAN
3.1 Arsitektur Aplikasi
3.2 Navigation Flow
3.3 Database SQLite
3.4 ERD
3.5 Design System
3.6 Wireframe

BAB IV IMPLEMENTASI
4.1 Login
4.2 Biometric
4.3 Home
4.4 BMI
4.5 CRUD
4.6 Kalender
4.7 Stopwatch
4.8 Panduan
4.9 Logout

BAB V PENGUJIAN
5.1 Functional Testing
5.2 Input Validation
5.3 Boundary Testing
5.4 Database Testing
5.5 Biometric Testing

BAB VI PENUTUP
6.1 Kesimpulan
6.2 Saran

LAMPIRAN
- Screenshot
- Source code penting
- Struktur database
```

---

# 115. ERD

```text
┌──────────────────────┐
│ USERS                │
├──────────────────────┤
│ PK id                │
│ username             │
│ password_hash        │
│ password_salt        │
│ role                 │
│ biometric_enabled    │
│ is_active            │
│ created_at           │
│ updated_at           │
└─────────┬────────────┘
          │ 1
          │
          │ N
┌─────────▼────────────┐
│ BMI_RECORDS          │
├──────────────────────┤
│ PK id                │
│ FK user_id           │
│ name                 │
│ age                  │
│ weight_kg            │
│ height_cm            │
│ bmi                  │
│ category             │
│ created_at           │
│ updated_at           │
└──────────────────────┘
```

---

# 116. Non-Functional Requirements

### Reliability

Tidak boleh crash karena:

- field kosong,
- input huruf,
- database kosong,
- biometric tidak tersedia,
- tanggal salah,
- timer aktif,
- back navigation.

### Maintainability

Business logic tidak berada seluruhnya dalam widget.

### Security

- SQL parameterized.
- Password hash.
- session secure storage.
- biometric melalui OS.
- no biometric templates stored.

### Performance

Seluruh komputasi utama offline dan hampir instan.

### Usability

Maximum 2–3 taps untuk mencapai fitur utama.

---

# 117. Definition of Done

Aplikasi baru dianggap **selesai** jika seluruh poin berikut terpenuhi:

- Login `tofik / 123` berfungsi.
- Password disimpan dalam bentuk hash.
- Session bekerja.
- Fingerprint/face device authentication bekerja apabila tersedia.
- Home berisi 5 menu vertikal.
- BMI lengkap.
- BMI warning merah bekerja.
- BMI normal hijau.
- Berat maksimal 1000 kg.
- Tinggi maksimal 400 cm.
- Umur maksimal 300 tahun.
- CRUD BMI lengkap.
- Konversi tanggal satu kali input.
- Masehi default.
- Hijriah keluar otomatis.
- Weton keluar otomatis.
- Saka Bali keluar otomatis.
- Umur tahun–detik berjalan realtime.
- Stopwatch start/pause/resume/reset.
- Panduan lengkap.
- Bottom navigation berisi Home, Stopwatch, Panduan, Logout.
- Logout clear session dan navigation stack.
- `push` digunakan.
- `pop` digunakan.
- `pushReplacement` digunakan.
- passing data digunakan.
- SQLite digunakan.
- Tidak ada SQL interpolation berbahaya.
- Tidak ada uncaught parsing error.
- Tidak ada division by zero.
- Tidak ada timer leak.
- Layout tidak overflow di HP kecil.
- Empty state tersedia.
- Loading state tersedia.
- Error state tersedia.
- Confirmation delete tersedia.
- Confirmation logout tersedia.
- UI mengikuti gradient referensi.
- Background menggunakan `#EEEEEE`.
- Surface/card menggunakan `#FFFFFF`.

---

# 118. Final Screen Inventory

Total screen utama yang direkomendasikan:

| # | Screen |
|---:|---|
| 1 | Splash / Auth Gate |
| 2 | Login |
| 3 | Home |
| 4 | Daftar Anggota |
| 5 | Kalkulator BMI |
| 6 | Hasil BMI |
| 7 | Riwayat BMI |
| 8 | Detail BMI |
| 9 | Edit BMI |
| 10 | Konversi Tanggal & Umur |
| 11 | Kalender Nusantara |
| 12 | Stopwatch |
| 13 | Panduan |

Total:

**13 screen utama**, ditambah dialog dan bottom navigation shell.

---

# 119. Prioritas Implementasi

Urutan development yang paling aman:

```text
1. Project + theme
      ↓
2. SQLite
      ↓
3. User seed + login
      ↓
4. Session
      ↓
5. Main navigation
      ↓
6. Home
      ↓
7. BMI
      ↓
8. CRUD BMI
      ↓
9. Date + Age
      ↓
10. Hijriah
      ↓
11. Weton
      ↓
12. Saka Bali
      ↓
13. Stopwatch
      ↓
14. Panduan
      ↓
15. Biometric
      ↓
16. Error handling
      ↓
17. Testing
      ↓
18. Laporan
```

Ini juga mengurangi risiko fitur biometrik atau kalender yang lebih kompleks menghambat fitur inti.

---

## Spesifikasi final yang harus dijadikan patokan

**Home:**

```text
1. Daftar Anggota
2. Kalkulator BMI
3. Riwayat BMI / CRUD
4. Konversi Tanggal & Umur
5. Kalender Weton & Saka Bali
```

**Bottom Navbar:**

```text
1. Home
2. Stopwatch
3. Panduan
4. Logout
```

**Input BMI:**

```text
Nama
Umur ≤300
Berat >0 dan ≤1000 kg
Tinggi >0 dan ≤400 cm
```

**Tanggal:**

```text
1x input Masehi
→ Umur realtime
→ Masehi
→ Hijriah
→ Weton
→ Saka Bali
```

**Auth:**

```text
username : tofik
password : 123
role     : admin

+ fingerprint
+ face/device biometric
+ session
```

**Design:**

```text
Primary gradient:
#114177 → #006A9A → #17A18A

Background:
#EEEEEE

Surface:
#FFFFFF
```

Secara requirement, rancangan ini sudah memasukkan materi navigasi yang diminta modul—termasuk `push`, `pop`, `pushReplacement`, passing data, dan logout dengan penghapusan stack—sekaligus memperluasnya menjadi aplikasi penuh dengan database, CRUD, komputasi, dan navigasi yang konsisten.
