# NusaFit — Panduan Implementasi Kode per Menu

Dokumen ini memisahkan implementasi setiap menu/screen dari design visual. Semua warna, spacing, typography, radius, dan style komponen berada di `DESIGN_SYSTEM.md`. Semua algoritma komputasi berada di `COMPUTATION_LOGIC.md`.

---

# 1. Splash / Auth Gate

## Tujuan

Menentukan apakah user diarahkan ke Login atau Main App berdasarkan session lokal.

## File minimum

```text
features/auth/pages/splash_page.dart
core/security/session_service.dart
```

## Logic

1. Initialize database.
2. Seed akun admin jika database baru.
3. Baca session aman.
4. Jika session valid → buka `MainShell`.
5. Jika session tidak ada → buka `LoginPage`.

## Error handling

- Database gagal dibuka → error screen + tombol `Coba Lagi`.
- Session corrupt → hapus session dan arahkan ke login.

---

# 2. Login

## File minimum

```text
features/auth/pages/login_page.dart
features/auth/controller/login_controller.dart
data/repositories/auth_repository.dart
core/security/password_service.dart
core/security/biometric_service.dart
core/security/session_service.dart
```

## Input

```text
username
password
```

Akun demo:

```text
username: tofik
password: 123
role: admin
```

## Flow credential

```text
input
→ sanitize
→ validate
→ repository cari user
→ verify password hash
→ create session
→ Navigator.pushReplacement(MainShell)
```

## Biometric flow

```text
cek hardware/enrollment
→ authenticate via OS
→ jika sukses dan user pernah enable biometric
→ buat/restore session
→ masuk MainShell
```

## Error handling

- input kosong,
- username invalid,
- credential salah,
- biometric unavailable,
- biometric not enrolled,
- biometric cancelled,
- biometric lockout.

Pesan credential gagal harus generik:

```text
Username atau password salah.
```

---

# 3. Main Shell / Bottom Navigation

## File minimum

```text
features/home/pages/main_shell.dart
```

## Tab

```text
0 Home
1 Stopwatch
2 Panduan
3 Logout action
```

Gunakan `IndexedStack` untuk Home/Stopwatch/Panduan sehingga state Stopwatch tidak hilang saat pindah tab.

Logout bukan screen permanen; klik logout membuka dialog konfirmasi.

## Logout flow

```text
confirm
→ clear session
→ Navigator.pushAndRemoveUntil(LoginPage, false)
```

---

# 4. Home

## File minimum

```text
features/home/pages/home_page.dart
features/home/widgets/home_menu_card.dart
```

## Lima menu vertikal

1. Daftar Anggota
2. Kalkulator BMI
3. Riwayat BMI / CRUD
4. Konversi Tanggal & Umur
5. Kalender Nusantara

Setiap menu child dibuka menggunakan `Navigator.push()`.

Home tidak boleh memuat logic BMI atau kalender.

---

# 5. Daftar Anggota

## File minimum

```text
features/members/pages/members_page.dart
features/members/models/member.dart
features/members/data/member_data.dart
```

## Data

```text
foto/avatar
nama
NIM
role/tugas
```

Karena daftar anggota adalah metadata kelompok, data dapat berupa constant/list lokal.

## Empty/error

Jika foto gagal → fallback avatar/initial.

---

# 6. Kalkulator BMI

## File minimum

```text
features/bmi/pages/bmi_calculator_page.dart
features/bmi/pages/bmi_result_page.dart
features/bmi/controller/bmi_controller.dart
domain/calculators/bmi_calculator.dart
core/utils/validators.dart
```

## Input

```text
nama
umur
berat kg
tinggi cm
```

## Boundary

```text
umur   1..300 tahun
berat  >0..1000 kg
tinggi >0..400 cm
```

## Flow

```text
user input
→ sanitize
→ validate
→ BmiCalculator
→ BmiResult
→ Navigator.push(BmiResultPage(result))
```

## Result action

```text
Simpan Hasil
Kembali
```

Simpan melalui repository, bukan query langsung dari page.

## State kategori

```text
underweight
normal
overweight
obesity
```

Detail formula dan threshold ada di `COMPUTATION_LOGIC.md`.

---

# 7. BMI Result

## File minimum

```text
features/bmi/pages/bmi_result_page.dart
features/bmi/widgets/bmi_result_panel.dart
```

## Data via constructor

```text
nama
umur
berat
tinggi
bmi
kategori
```

Ini sekaligus membuktikan passing data antar halaman.

## Save flow

```text
click Simpan
→ disable button
→ repository insert
→ success snackbar
→ enable / mark saved
```

Cegah duplicate insert dari repeated click/rebuild.

## Animation

Overweight/obesity boleh pulse/blink aman. Logic animation hanya UI; kategori tetap berasal dari domain calculator.

---

# 8. Riwayat BMI

## File minimum

```text
features/bmi/pages/bmi_history_page.dart
features/bmi/controller/bmi_history_controller.dart
data/repositories/bmi_repository.dart
data/models/bmi_record.dart
```

## State

```text
initial
loading
success
empty
error
```

## List item

```text
nama
berat
tinggi
BMI
kategori
timestamp
```

## Action

```text
Lihat
Edit
Hapus
```

Delete wajib confirmation dialog.

---

# 9. Detail BMI

## File minimum

```text
features/bmi/pages/bmi_detail_page.dart
```

## Data

```text
nama
umur
berat
tinggi
BMI
kategori
createdAt
updatedAt
```

Back menggunakan `Navigator.pop()`.

---

# 10. Edit BMI

## File minimum

```text
features/bmi/pages/bmi_edit_page.dart
features/bmi/controller/bmi_edit_controller.dart
```

`BmiRecord` dikirim dari History ke Edit melalui constructor.

User hanya mengedit:

```text
nama
umur
berat
tinggi
```

BMI dan kategori tidak diedit manual.

Saat save:

```text
validate
→ hitung ulang BMI
→ update record
→ update updatedAt
→ pop result success
```

History refresh setelah kembali.

---

# 11. Konversi Tanggal & Umur

## File minimum

```text
features/date_converter/pages/date_converter_page.dart
features/date_converter/controller/date_converter_controller.dart
domain/calculators/age_calculator.dart
domain/calculators/hijri_converter.dart
domain/calculators/weton_calculator.dart
domain/calculators/bali_calendar_converter.dart
```

## Single Source of Truth

Hanya satu nilai utama:

```dart
DateTime selectedDateTime;
```

Dari satu input ini, controller menghitung seluruh representasi.

## Output

```text
Masehi
Hijriah
Weton
Saka Bali
Usia realtime
```

## Segment/filter

```text
Semua
Masehi
Hijriah
Weton
Saka Bali
```

Filter hanya memengaruhi tampilan; jangan mengubah selected date.

## Timer

Age realtime update per 1 detik. Timer wajib cancel pada dispose.

---

# 12. Kalender Nusantara

## File minimum

```text
features/calendar/pages/nusantara_calendar_page.dart
features/calendar/controller/nusantara_calendar_controller.dart
```

Screen ini fokus detail Weton dan Saka Bali.

Input tetap Gregorian/Masehi.

Output minimum Weton:

```text
hari
pasaran
weton
neptu
```

Output minimum Saka Bali:

```text
tahun saka
sasih
tanggal/hari
```

Jika komponen tambahan seperti Wuku/Saptawara/Pancawara berhasil divalidasi terhadap fixture referensi, boleh ditambahkan.

---

# 13. Stopwatch

## File minimum

```text
features/stopwatch/pages/stopwatch_page.dart
features/stopwatch/controller/stopwatch_controller.dart
```

## State

```text
idle
running
paused
```

## Action

```text
start
pause
continue
reset
```

## Timing source

Gunakan elapsed time dari `Stopwatch` Dart atau monotonic elapsed source, bukan menambah counter berdasarkan jumlah tick timer.

Timer UI hanya untuk refresh display.

Format:

```text
HH:MM:SS.CS
```

Stopwatch tidak reset saat berpindah bottom tab.

---

# 14. Panduan

## File minimum

```text
features/help/pages/help_page.dart
features/help/data/help_sections.dart
```

## Isi minimum

1. Cara Login
2. Login biometrik
3. Menu Utama
4. BMI
5. Hasil BMI
6. Riwayat
7. Edit BMI
8. Hapus BMI
9. Konversi tanggal
10. Usia
11. Hijriah
12. Weton
13. Saka Bali
14. Stopwatch
15. Logout

Data panduan dapat berupa immutable local data.

---

# 15. Logout

Logout dipicu dari Main Shell.

## Flow wajib

```text
Tap Logout
→ confirmation dialog
→ user pilih Logout
→ clear secure session
→ pushAndRemoveUntil Login
```

Data BMI tidak dihapus ketika logout.

---

# 16. Repository API yang Disarankan

## AuthRepository

```dart
Future<User?> findUserByUsername(String username);
Future<AuthResult> login({required String username, required String password});
```

## BmiRepository

```dart
Future<int> insert(BmiRecord record);
Future<List<BmiRecord>> getAllByUser(int userId);
Future<BmiRecord?> getById(int id);
Future<int> update(BmiRecord record);
Future<int> deleteById(int id);
```

---

# 17. Passing Data yang Wajib Terlihat

Minimal:

```text
LoginPage
  └─ username/user → MainShell/Home

BmiHistoryPage
  └─ BmiRecord → BmiEditPage

BmiCalculatorPage
  └─ BmiResult → BmiResultPage
```

---

# 18. Checklist per Menu

Sebelum sebuah menu dinyatakan selesai:

```text
[ ] requirement PRD terpenuhi
[ ] logic bukan di UI
[ ] validation lengkap
[ ] loading state bila async
[ ] empty state bila list
[ ] error state
[ ] navigation benar
[ ] dispose timer/controller
[ ] tidak ada SQL di widget
[ ] test utama tersedia
[ ] UI mengikuti DESIGN_SYSTEM.md
```
