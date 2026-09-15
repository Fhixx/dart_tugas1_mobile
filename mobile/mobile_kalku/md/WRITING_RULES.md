# NusaFit — Aturan Penulisan & Implementasi Kode

Dokumen ini adalah aturan wajib untuk semua AI agent dan developer yang menulis atau mengubah source code NusaFit.

## 1. Sumber Kebenaran

Urutan prioritas aturan:

1. `PRD_NusaFit_Lengkap.md` — sumber requirement produk.
2. `WRITING_RULES.md` — aturan penulisan dan implementasi source code.
3. `MENU_IMPLEMENTATION.md` — pembagian fitur dan kode per menu/screen.
4. `COMPUTATION_LOGIC.md` — aturan seluruh logic komputasi.
5. `DESIGN_SYSTEM.md` — visual, layout, warna, typography, spacing, dan komponen UI.
6. Source code existing project — hanya menjadi referensi implementasi; jika bertentangan dengan PRD, PRD menang.

AI agent **dilarang mengubah requirement secara diam-diam**. Jika ada konflik, tulis konflik tersebut sebelum melakukan implementasi.

---

## 2. Prinsip Pemisahan Tanggung Jawab

Source code wajib dipisah berdasarkan tanggung jawab.

```text
UI / Screen
  ↓
Controller / State / Provider
  ↓
Service / Use Case
  ↓
Repository
  ↓
SQLite / Secure Storage / Device API
```

Aturan utama:

- Widget/screen tidak boleh berisi query SQLite langsung.
- Widget/screen tidak boleh berisi algoritma BMI, umur, Hijriah, Weton, atau Saka Bali.
- Widget/screen tidak boleh meng-hash password sendiri.
- Repository tidak boleh menentukan warna atau layout.
- Design token tidak boleh dicampur ke logic komputasi.
- Logic komputasi dibuat pure function sebisa mungkin agar mudah diuji.
- Operasi perangkat seperti biometrik ditempatkan pada service khusus.

---

## 3. Struktur Folder Wajib

Gunakan struktur minimum berikut:

```text
lib/
├── main.dart
├── app.dart
├── core/
│   ├── constants/
│   │   ├── app_colors.dart
│   │   ├── app_dimensions.dart
│   │   ├── app_strings.dart
│   │   └── app_routes.dart
│   ├── database/
│   │   ├── database_helper.dart
│   │   └── migrations/
│   ├── security/
│   │   ├── password_service.dart
│   │   ├── biometric_service.dart
│   │   └── session_service.dart
│   ├── utils/
│   │   ├── validators.dart
│   │   ├── sanitizers.dart
│   │   └── date_utils.dart
│   └── errors/
│       ├── app_exception.dart
│       └── failure.dart
├── data/
│   ├── models/
│   │   ├── user.dart
│   │   └── bmi_record.dart
│   └── repositories/
│       ├── auth_repository.dart
│       └── bmi_repository.dart
├── domain/
│   ├── calculators/
│   │   ├── bmi_calculator.dart
│   │   ├── age_calculator.dart
│   │   ├── hijri_converter.dart
│   │   ├── weton_calculator.dart
│   │   └── bali_calendar_converter.dart
│   └── entities/
├── features/
│   ├── auth/
│   ├── home/
│   ├── members/
│   ├── bmi/
│   ├── date_converter/
│   ├── calendar/
│   ├── stopwatch/
│   └── help/
└── widgets/
    ├── gradient_button.dart
    ├── app_card.dart
    ├── custom_text_field.dart
    └── confirmation_dialog.dart
```

Jika state management dipakai, struktur per feature dapat ditambah:

```text
feature_name/
├── pages/
├── widgets/
├── controller/
└── state/
```

---

## 4. Aturan Nama File

- File Dart: `snake_case.dart`
- Class: `PascalCase`
- Variable/function: `camelCase`
- Constant compile-time: `camelCase` atau central token object yang konsisten.
- Private symbol Dart: awali `_` hanya jika benar-benar scope file/class.

Contoh benar:

```text
bmi_calculator.dart
BmiCalculator
calculateBmi()
selectedDate
```

Hindari:

```text
BMIcalc.dart
CalculateBMI_NOW()
data1
abc
x1
```

---

## 5. Aturan Fungsi

Setiap fungsi harus memiliki satu tujuan yang jelas.

Baik:

```dart
BmiResult calculateBmi({
  required double weightKg,
  required double heightCm,
})
```

Buruk:

```dart
void handleEverything() {
  // validasi + query DB + hitung BMI + pindah screen + snackbar
}
```

Jika fungsi melebihi kira-kira 30–40 baris, cek apakah tanggung jawabnya dapat dipecah.

---

## 6. Aturan Widget

Widget wajib fokus pada presentasi dan interaksi.

Screen boleh:

- membaca state,
- menampilkan state,
- memanggil controller/service melalui abstraction,
- menjalankan `Navigator` sesuai alur,
- menampilkan dialog/snackbar.

Screen tidak boleh:

- menulis SQL,
- menghitung BMI langsung,
- menghitung Weton langsung,
- mengelola hash password,
- melakukan raw parsing kompleks berulang.

Reusable widget dibuat jika komponen dipakai setidaknya 2 kali atau mempunyai visual/behavior kompleks.

---

## 7. Aturan State

Setiap feature yang memuat async operation minimal mengenali state:

```text
initial
loading
success
empty
error
```

Jangan gunakan hanya satu boolean seperti `isLoading` untuk seluruh kemungkinan state jika fitur sudah kompleks.

Contoh:

```dart
enum BmiHistoryStatus {
  initial,
  loading,
  success,
  empty,
  error,
}
```

---

## 8. Aturan Validasi Input

Validasi dilakukan berlapis:

1. Input formatter pada UI.
2. Sanitizer.
3. Validator domain.
4. Constraint database bila relevan.

Jangan menganggap keyboard numeric menjamin input valid.

Wajib menangani:

```text
null
empty string
whitespace
NaN
Infinity
-Infinity
negative number
zero pada denominator
out of range
malformed date
future date
```

---

## 9. Sanitization

String umum:

```text
trim leading/trailing whitespace
collapse whitespace berulang
batasi panjang
jangan interpolasi ke SQL
```

Numeric:

```text
trim
normalisasi koma desimal bila diperlukan
tryParse
isFinite
range validation
```

Semua SQL wajib parameterized.

Dilarang:

```dart
"SELECT * FROM users WHERE username = '$username'"
```

Gunakan:

```dart
where: 'username = ?',
whereArgs: [username],
```

---

## 10. Error Handling

Tidak boleh ada error penting yang dibiarkan tanpa penanganan.

Layering yang disarankan:

- repository menangkap error database dan mengubahnya menjadi failure/domain error,
- controller mengubah failure menjadi UI state,
- UI menampilkan pesan yang dapat dipahami pengguna.

Jangan tampilkan stack trace atau detail SQL kepada pengguna.

Pesan user-facing harus singkat dan actionable.

Contoh:

```text
Data gagal disimpan. Silakan coba lagi.
```

Bukan:

```text
DatabaseException(no such table...) sql 'INSERT ...'
```

---

## 11. Aturan Async

- Gunakan `async/await` secara konsisten.
- Cek `mounted` sebelum menggunakan `context` setelah await pada StatefulWidget.
- Mencegah double submit dengan loading state.
- Timer/stream/controller wajib di-dispose.
- Jangan membuat operasi async di `build()`.

---

## 12. Navigation

Requirement navigasi PRD wajib terlihat nyata dalam aplikasi:

- `Navigator.push()` untuk membuka detail/menu child.
- `Navigator.pop()` untuk kembali.
- `Navigator.pushReplacement()` dari Login menuju Main App.
- Passing data minimal Login → Main dan BMI History → Edit.
- `Navigator.pushAndRemoveUntil()` untuk Logout.

Tidak boleh mengganti seluruh requirement tersebut hanya dengan satu router abstraction jika akibatnya requirement praktikum tidak lagi dapat dibuktikan pada source code. Jika memakai router package, tetap sediakan implementasi yang memenuhi materi praktikum atau dokumentasikan mapping eksplisit.

---

## 13. Database

Database: SQLite.

Wajib:

- database version,
- `onCreate`,
- `onUpgrade`,
- migration yang tidak menghapus seluruh data,
- parameterized queries,
- transaction untuk perubahan multi-step,
- timestamp konsisten.

Timestamp direkomendasikan ISO-8601.

```dart
DateTime.now().toIso8601String()
```

---

## 14. Security

- Password demo `123` boleh untuk requirement tugas, tetapi storage harus berupa hash + salt.
- Jangan simpan plaintext password.
- Session sensitif gunakan secure storage.
- Biometric wajib menggunakan API OS/device.
- Jangan menyimpan fingerprint template atau data wajah.
- Error login jangan membocorkan apakah username valid.

Pesan login gagal:

```text
Username atau password salah.
```

---

## 15. Komentar Kode

Komentar hanya untuk menjelaskan **alasan**, bukan mengulang kode.

Baik:

```dart
// Keep the stopwatch based on elapsed time so UI frame drops do not
// accumulate timing drift.
```

Buruk:

```dart
// Tambah 1 ke count
count++;
```

---

## 16. Dokumentasi Public API

Class/function domain yang non-trivial sebaiknya mempunyai DartDoc.

Contoh:

```dart
/// Calculates BMI from metric body measurements.
/// Throws [ValidationException] when height or weight is outside the PRD range.
BmiResult calculateBmi(...)
```

---

## 17. Testing

Minimal buat unit test untuk:

- BMI boundary,
- umur boundary,
- date future,
- leap year,
- Weton known-date fixtures,
- Saka Bali reference fixtures,
- Hijriah reference fixtures,
- sanitizer,
- repository CRUD.

Widget test minimal:

- Login validation,
- BMI form,
- delete confirmation,
- logout confirmation.

---

## 18. Dilarang Hardcode yang Tidak Perlu

Jangan hardcode ukuran screen seperti:

```dart
width: 393,
height: 852,
```

Gunakan layout responsif.

Jangan duplikasi warna hex di banyak screen. Semua warna di `app_colors.dart`.

Jangan duplikasi spacing. Gunakan `app_dimensions.dart` atau constants.

---

## 19. Urutan Implementasi Setiap Feature

Untuk setiap menu, AI agent wajib bekerja dalam urutan:

1. Baca requirement PRD terkait.
2. Baca bagian menu pada `MENU_IMPLEMENTATION.md`.
3. Jika ada perhitungan, baca `COMPUTATION_LOGIC.md`.
4. Baca `DESIGN_SYSTEM.md` untuk UI.
5. Buat model/entity bila diperlukan.
6. Buat service/calculator/repository.
7. Buat controller/state.
8. Buat screen/widget.
9. Tambahkan navigation.
10. Tambahkan validation/error handling.
11. Tambahkan test.
12. Verifikasi acceptance criteria.

---

## 20. Definition of Done untuk Perubahan Kode

Perubahan dianggap selesai jika:

- sesuai PRD,
- tidak memindahkan logic domain ke UI,
- tidak membuat query SQLite di widget,
- tidak menduplikasi design token,
- validation lengkap,
- loading/error/empty state ditangani bila relevan,
- navigation sesuai requirement,
- test baru/terkait diperbarui,
- analyzer tidak menghasilkan error,
- tidak ada timer/controller leak,
- tidak ada secret/password plaintext baru,
- tidak ada SQL interpolation.

---

## 21. Format Respons AI Agent Saat Mengubah Kode

Sebelum menulis perubahan besar, agent harus menyatakan singkat:

```text
Requirement yang dikerjakan:
File yang akan dibuat/diubah:
Logic domain terkait:
Risiko/edge case utama:
```

Setelah implementasi, agent harus merangkum:

```text
Yang selesai:
Validasi/error handling:
Test:
Hal yang belum selesai (jika ada):
```

Jangan mengklaim test lulus jika test tidak benar-benar dijalankan.
