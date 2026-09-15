# NusaFit — Pembagian Produksi 2 Orang

> Dokumen ini adalah rencana eksekusi produksi/implementasi untuk 2 developer. Dokumen ini **tidak menggantikan PRD**. Semua pekerjaan wajib tetap mengikuti `PRD_NusaFit_Lengkap.md`, `WRITING_RULES.md`, `MENU_IMPLEMENTATION.md`, `COMPUTATION_LOGIC.md`, dan `DESIGN_SYSTEM.md`.

---

# 1. Status Tahap Proyek

Tahap berikutnya **sudah dapat masuk ke produksi/implementasi** karena requirement produk, aturan penulisan, pembagian menu, logic komputasi, design system, database, navigation, error handling, dan acceptance criteria sudah terdokumentasi.

Produksi dimulai dengan urutan:

```text
Bootstrap project
→ kontrak data/domain
→ database & security
→ navigation shell
→ implementasi feature per pemilik
→ integrasi
→ testing
→ hardening
→ demo/release build
→ laporan
```

Tidak boleh langsung membuat seluruh UI tanpa menyiapkan kontrak model, database, validator, dan service yang diperlukan.

---

# 2. Aturan Wajib Sebelum Coding

Kedua developer wajib membaca:

1. `agent.md`
2. `md/PRD_NusaFit_Lengkap.md`
3. `md/WRITING_RULES.md`
4. `md/MENU_IMPLEMENTATION.md`
5. `md/COMPUTATION_LOGIC.md`
6. `md/DESIGN_SYSTEM.md`
7. dokumen ini: `md/PRODUCTION_SPLIT_2_PERSON.md`

Jika struktur repository saat ini belum memindahkan dokumentasi ke `/md`, gunakan path aktual tetapi pertahankan urutan bacaan yang sama.

---

# 3. Prinsip Pembagian Kerja

Pembagian dibuat berdasarkan **ownership file/layer**, bukan hanya berdasarkan halaman. Tujuannya mengurangi merge conflict dan memastikan tidak ada object yang dikerjakan ganda atau justru tidak memiliki pemilik.

## Developer 1 — Core, Data, Security, Auth, BMI & CRUD

Fokus utama:

- bootstrap aplikasi,
- SQLite,
- migration,
- user seed,
- password hashing,
- session,
- biometric,
- login,
- BMI calculation,
- BMI CRUD,
- repository,
- data model,
- error/domain foundation,
- integration build dan dependency ownership.

## Developer 2 — Design, Navigation Shell, Home, Date/Calendar, Stopwatch, Help

Fokus utama:

- design system,
- reusable UI,
- MainShell,
- bottom navigation,
- Home,
- daftar anggota,
- konversi tanggal,
- umur realtime,
- Hijriah,
- Weton,
- Saka Bali,
- Stopwatch,
- Panduan,
- responsive/accessibility UI.

---

# 4. Ownership Rule

Setiap file mempunyai **satu owner utama**. Developer lain boleh memberi review, tetapi tidak mengubah file milik developer lain tanpa koordinasi.

Kode yang sifatnya shared wajib memiliki pemilik eksplisit.

| Area shared | Owner utama | Reviewer |
|---|---|---|
| `pubspec.yaml` | Developer 1 | Developer 2 |
| `lib/main.dart` | Developer 1 | Developer 2 |
| `lib/app.dart` | Developer 2 | Developer 1 |
| theme/design tokens | Developer 2 | Developer 1 |
| SQLite & migration | Developer 1 | Developer 2 |
| navigation shell | Developer 2 | Developer 1 |
| auth/session/security | Developer 1 | Developer 2 |
| computation date/calendar | Developer 2 | Developer 1 |
| BMI domain/data | Developer 1 | Developer 2 |
| global widgets | Developer 2 | Developer 1 |
| release/integration branch | Developer 1 | Developer 2 |
| final QA checklist | Bersama | Bersama |

---

# 5. Struktur Branch yang Disarankan

```text
main
└── develop
    ├── feat/dev1-core-auth-bmi
    └── feat/dev2-ui-calendar-stopwatch
```

Aturan:

- jangan commit langsung ke `main`,
- merge feature ke `develop`,
- kedua developer review sebelum merge ke `main`,
- jangan force push ke branch orang lain,
- setiap merge besar harus menjalankan analyzer + test.

---

# 6. Developer 1 — Porsi Lengkap

## 6.1 Bootstrap dan dependency

Owner file:

```text
pubspec.yaml
lib/main.dart
```

Tugas:

- siapkan dependency minimum,
- pastikan project compile,
- inisialisasi database sebelum flow auth bila diperlukan,
- siapkan dependency untuk SQLite, secure storage, local auth, crypto, intl/state management sesuai keputusan final,
- jangan menambahkan dependency yang duplikatif tanpa alasan.

Dependency requirement minimum dari PRD:

```text
sqflite
path
flutter_secure_storage
local_auth
intl
provider atau state management yang disepakati
crypto
```

## 6.2 Core error foundation

Owner:

```text
lib/core/errors/app_exception.dart
lib/core/errors/failure.dart
```

Object wajib:

```text
AppException
Failure
ValidationFailure
DatabaseFailure
AuthenticationFailure
BiometricFailure
UnsupportedRangeFailure bila digunakan lintas layer
```

Failure boleh disederhanakan selama typed error tetap jelas dan konsisten.

## 6.3 SQLite architecture

Owner:

```text
lib/core/database/database_helper.dart
lib/core/database/migrations/
```

Wajib:

- DB name `nusafit.db`,
- versioning,
- `onCreate`,
- `onUpgrade`,
- foreign key bila digunakan,
- parameterized query,
- transaction bila operasi multi-query,
- tidak menghapus DB hanya untuk migration.

### Table `users`

Wajib mencakup:

```text
id                INTEGER PRIMARY KEY
username          TEXT UNIQUE
password_hash     TEXT
password_salt     TEXT
role              TEXT
biometric_enabled INTEGER
is_active         INTEGER
created_at        TEXT
updated_at        TEXT
```

### Table `bmi_records`

Wajib mencakup:

```text
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

Relasi:

```text
bmi_records.user_id → users.id
```

## 6.4 Seed akun admin

Wajib:

```text
username: tofik
password: 123
role: admin
```

Tetapi database menyimpan:

```text
password_hash
password_salt
```

Dilarang menyimpan password plaintext.

Seed hanya dilakukan jika akun default belum ada.

## 6.5 Security services

Owner:

```text
lib/core/security/password_service.dart
lib/core/security/session_service.dart
lib/core/security/biometric_service.dart
```

### `PasswordService`

Wajib:

- generate salt,
- hash password,
- verify password,
- tidak expose plaintext password,
- mempunyai unit test.

### `SessionService`

Wajib menangani:

```text
user_id
username
role
isLoggedIn
```

Wajib:

- save session,
- read session,
- validate session,
- clear session,
- corrupt session fallback ke login.

### `BiometricService`

Wajib:

- cek hardware,
- cek enrollment,
- authenticate via OS,
- hasil sukses/gagal/cancel/lockout/unavailable,
- tidak menyimpan fingerprint template atau face template,
- username/password tetap fallback.

## 6.6 Data model

Owner:

```text
lib/data/models/user.dart
lib/data/models/bmi_record.dart
```

### `User`

Field minimal:

```text
id
username
role
biometricEnabled
isActive
```

Jika model persistence memerlukan timestamp/hash metadata, boleh ditambahkan secara internal.

### `BmiRecord`

Field minimal:

```text
id
userId
name
age
weightKg
heightCm
bmi
category
createdAt
updatedAt
```

Wajib ada mapping:

```text
fromMap
/toMap atau equivalent
copyWith bila dipakai pada edit
```

## 6.7 Repository

Owner:

```text
lib/data/repositories/auth_repository.dart
lib/data/repositories/bmi_repository.dart
```

### `AuthRepository`

Kontrak minimum:

```dart
Future<User?> findUserByUsername(String username);
Future<AuthResult> login({
  required String username,
  required String password,
});
```

Tanggung jawab:

- query user secara parameterized,
- verify hash melalui `PasswordService`,
- tidak mengatur UI,
- tidak melakukan Navigator.

### `BmiRepository`

Kontrak minimum:

```dart
Future<int> insert(BmiRecord record);
Future<List<BmiRecord>> getAllByUser(int userId);
Future<BmiRecord?> getById(int id);
Future<int> update(BmiRecord record);
Future<int> deleteById(int id);
```

Tambahan boleh:

```text
searchByName
countByUser
```

hanya jika benar-benar dipakai.

## 6.8 Validator & sanitizer foundation

Owner utama logic umum:

```text
lib/core/utils/validators.dart
lib/core/utils/sanitizers.dart
```

Harus mencakup:

- username,
- password presence,
- nama,
- umur 1..300,
- berat >0..1000,
- tinggi >0..400,
- finite numeric,
- empty/whitespace,
- decimal separator Indonesia bila diaktifkan,
- malformed number,
- future date helper dapat dikoordinasikan dengan Developer 2.

## 6.9 Splash/Auth Gate

Owner feature:

```text
lib/features/auth/pages/splash_page.dart
```

Flow:

```text
initialize DB
→ seed admin
→ read session
→ session valid ? MainShell : LoginPage
```

Error:

- DB gagal → error state + retry,
- corrupt session → clear → login.

## 6.10 Login

Owner:

```text
lib/features/auth/pages/login_page.dart
lib/features/auth/controller/login_controller.dart
```

Wajib:

- username,
- password,
- show/hide password,
- sanitize,
- validate,
- credential login,
- biometric button bila tersedia,
- biometric enrollment offer setelah credential login pertama bila sesuai flow,
- `Navigator.pushReplacement()` ke MainShell,
- generic credential error,
- double-submit prevention.

## 6.11 BMI domain

Owner:

```text
lib/domain/calculators/bmi_calculator.dart
```

Object:

```text
BmiResult
BmiCategory
BmiCalculator
```

Formula:

```text
heightM = heightCm / 100
BMI = weightKg / (heightM × heightM)
```

Category:

```text
< 18.5          underweight
18.5..<25.0     normal
25.0..<30.0     overweight
>= 30.0         obesity
```

Display 2 desimal, tetapi domain tidak boleh kehilangan precision terlalu awal.

## 6.12 BMI Calculator feature

Owner:

```text
lib/features/bmi/pages/bmi_calculator_page.dart
lib/features/bmi/controller/bmi_controller.dart
```

Input:

```text
nama
umur
berat kg
tinggi cm
```

Flow:

```text
sanitize
→ validate
→ calculate BMI
→ Navigator.push(BmiResultPage(result))
```

## 6.13 BMI Result

Owner:

```text
lib/features/bmi/pages/bmi_result_page.dart
lib/features/bmi/widgets/bmi_result_panel.dart
```

Wajib menerima via constructor:

```text
nama
umur
berat
tinggi
bmi
kategori
```

Wajib:

- passing data terlihat jelas,
- save result,
- duplicate insert prevention,
- success/error state,
- kategori berasal dari domain,
- visual mengikuti token Developer 2.

## 6.14 BMI History

Owner:

```text
lib/features/bmi/pages/bmi_history_page.dart
lib/features/bmi/controller/bmi_history_controller.dart
```

State:

```text
initial
loading
success
empty
error
```

List item:

```text
nama
berat
tinggi
BMI
kategori
timestamp
```

Action:

```text
Lihat
Edit
Hapus
```

Delete wajib confirmation.

## 6.15 BMI Detail

Owner:

```text
lib/features/bmi/pages/bmi_detail_page.dart
```

Field:

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

Back:

```text
Navigator.pop()
```

## 6.16 BMI Edit

Owner:

```text
lib/features/bmi/pages/bmi_edit_page.dart
lib/features/bmi/controller/bmi_edit_controller.dart
```

Editable:

```text
nama
umur
berat
tinggi
```

Tidak editable manual:

```text
BMI
kategori
```

Save:

```text
validate
→ recalculate
→ update timestamp
→ repository update
→ pop success
→ history refresh
```

## 6.17 Logout data/security side

Developer 1 menyediakan:

```text
SessionService.clearSession()
```

Developer 2 menangani dialog/navigation UI logout.

Data BMI tidak dihapus saat logout.

## 6.18 Platform biometric configuration

Owner Developer 1.

Android configuration yang diperlukan oleh package biometric wajib dipasang dan diuji pada perangkat/emulator yang sesuai.

Tidak membuat custom face recognition.

## 6.19 Testing Developer 1

Minimum test:

```text
password hash/verify
admin seed tidak duplicate
session save/read/clear
login benar
login salah
SQL injection username
BMI formula
BMI boundary category
age input validation 1 dan 300
weight 0 / 1000 / >1000
height 0 / 400 / >400
NaN / Infinity rejection
BMI repository CRUD
update recalculates BMI
parameterized SQL behavior
biometric typed states/service wrapper
```

---

# 7. Developer 2 — Porsi Lengkap

## 7.1 App shell dan theme entry

Owner:

```text
lib/app.dart
```

Tugas:

- MaterialApp/theme entry,
- global route/theme linkage sesuai arsitektur,
- jangan menaruh DB logic di `app.dart`.

## 7.2 Design tokens

Owner:

```text
lib/core/constants/app_colors.dart
lib/core/constants/app_dimensions.dart
lib/core/constants/app_strings.dart
lib/core/constants/app_routes.dart
```

Warna wajib:

```text
primaryDark  #114177
primary      #006A9A
primaryTeal  #17A18A
background   #EEEEEE
surface      #FFFFFF
textPrimary  #1F2937
textSecondary #6B7280
divider      #E5E7EB
success      #2E7D32
warning      #ED6C02
danger       #D32F2F
dangerDark   #B71C1C
disabled     #BDBDBD
```

Gradient:

```text
#114177 → #006A9A → #17A18A
```

Spacing:

```text
4, 8, 12, 16, 24, 32, 40, 48
```

Radius:

```text
8, 12, 14–16, 16, 20
```

## 7.3 Global reusable widgets

Owner:

```text
lib/widgets/gradient_button.dart
lib/widgets/app_card.dart
lib/widgets/custom_text_field.dart
lib/widgets/confirmation_dialog.dart
```

Boleh tambah bila benar-benar reusable:

```text
app_snackbar.dart
loading_view.dart
error_view.dart
empty_state.dart
```

Semua harus mengikuti design system.

## 7.4 Main Shell / Bottom Navigation

Owner:

```text
lib/features/home/pages/main_shell.dart
```

Tab wajib:

```text
0 Home
1 Stopwatch
2 Panduan
3 Logout action
```

Wajib:

- `IndexedStack` untuk Home/Stopwatch/Panduan,
- stopwatch tidak reset saat tab berpindah,
- Logout bukan halaman kosong,
- dialog confirmation,
- setelah clear session gunakan `pushAndRemoveUntil` ke Login.

## 7.5 Home

Owner:

```text
lib/features/home/pages/home_page.dart
lib/features/home/widgets/home_menu_card.dart
```

Tepat 5 menu vertikal:

1. Daftar Anggota
2. Kalkulator BMI
3. Riwayat BMI / CRUD
4. Konversi Tanggal & Umur
5. Kalender Nusantara

Setiap child:

```text
Navigator.push()
```

Home tidak memiliki logic BMI/calendar.

## 7.6 Daftar Anggota

Owner:

```text
lib/features/members/pages/members_page.dart
lib/features/members/models/member.dart
lib/features/members/data/member_data.dart
```

Data:

```text
foto/avatar
nama
NIM
role/tugas
```

Wajib ada fallback avatar/initial jika image gagal.

## 7.7 Date utility bersama

Owner:

```text
lib/core/utils/date_utils.dart
```

Tanggung jawab:

- formatting tanggal,
- validasi helper yang tidak masuk calculator,
- jangan memuat UI,
- koordinasikan function signature dengan Developer 1 jika validator umum memakai helper ini.

## 7.8 Age Calculator

Owner:

```text
lib/domain/calculators/age_calculator.dart
```

Object typed minimum:

```text
AgeResult
```

Komponen:

```text
years
months
days
hours
minutes
seconds
```

Normalisasi:

```text
months 0..11
hours 0..23
minutes 0..59
seconds 0..59
```

Wajib menangani:

- future date reject,
- umur >300 tahun reject,
- leap year,
- tanggal valid,
- waktu default 00:00:00 jika tidak diinput,
- optional jam lahir.

## 7.9 Total elapsed metrics

Jika ditampilkan sesuai PRD:

```text
total months
total days
total hours
total minutes
total seconds
```

Harus dibedakan dari umur kalender ternormalisasi.

## 7.10 Gregorian/Masehi representation

Owner domain/date controller Developer 2.

Masehi adalah default input dan single source of truth.

## 7.11 Hijriah Converter

Owner:

```text
lib/domain/calculators/hijri_converter.dart
```

Object typed minimum:

```text
HijriDateResult
```

Field minimum:

```text
day
month
year
monthName
```

Wajib:

- satu metode konsisten,
- offline,
- unsupported range menghasilkan typed failure,
- tidak crash,
- UI memberi keterangan algoritmik dapat berbeda dari observasional.

## 7.12 Weton Calculator

Owner:

```text
lib/domain/calculators/weton_calculator.dart
```

Output:

```text
dayName
pasaran
wetonLabel
neptuDay
neptuPasaran
totalNeptu
```

Neptu hari:

```text
Minggu 5
Senin 4
Selasa 3
Rabu 7
Kamis 8
Jumat 6
Sabtu 9
```

Neptu pasaran:

```text
Legi 5
Pahing 9
Pon 7
Wage 4
Kliwon 8
```

Wajib menggunakan fixture tanggal referensi terverifikasi.

## 7.13 Saka Bali Converter

Owner:

```text
lib/domain/calculators/bali_calendar_converter.dart
```

Output minimum:

```text
tahun Saka
sasih
tanggal/hari
```

Tambahan opsional hanya jika terverifikasi:

```text
Saptawara
Pancawara
Wuku
```

Dilarang mengarang hasil tanpa algoritma/fixture yang tervalidasi.

## 7.14 Konversi Tanggal & Umur

Owner:

```text
lib/features/date_converter/pages/date_converter_page.dart
lib/features/date_converter/controller/date_converter_controller.dart
```

Single source of truth:

```dart
DateTime selectedDateTime;
```

Dari satu input menghasilkan sekaligus:

```text
Masehi
Hijriah
Weton
Saka Bali
Usia realtime
```

Segment/filter:

```text
Semua
Masehi
Hijriah
Weton
Saka Bali
```

Filter hanya display.

Realtime age:

- update 1 detik,
- cancel Timer pada `dispose()`.

## 7.15 Kalender Nusantara

Owner:

```text
lib/features/calendar/pages/nusantara_calendar_page.dart
lib/features/calendar/controller/nusantara_calendar_controller.dart
```

Fokus:

```text
Weton
Saka Bali
```

Input tetap Masehi.

Weton minimum:

```text
hari
pasaran
weton
neptu
```

Saka Bali minimum:

```text
tahun saka
sasih
tanggal/hari
```

## 7.16 Stopwatch domain/controller

Owner:

```text
lib/features/stopwatch/controller/stopwatch_controller.dart
lib/features/stopwatch/pages/stopwatch_page.dart
```

State:

```text
idle
running
paused
```

Action:

```text
start
pause
continue
reset
```

Timing source:

- gunakan Dart `Stopwatch`/monotonic elapsed,
- Timer hanya refresh display,
- tidak menambah waktu berdasarkan jumlah tick,
- format `HH:MM:SS.CS`,
- dispose timer dengan benar.

## 7.17 Panduan

Owner:

```text
lib/features/help/pages/help_page.dart
lib/features/help/data/help_sections.dart
```

Isi minimum 15 bagian:

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

## 7.18 Logout UI

Owner Developer 2:

```text
Tap Logout
→ confirmation dialog
→ Developer 1 SessionService.clearSession()
→ pushAndRemoveUntil Login
```

## 7.19 Responsive dan accessibility

Developer 2 owner utama.

Wajib:

- minimum 360×640 logical px,
- juga nyaman 393×852 dan 411×915,
- `SafeArea`,
- `SingleChildScrollView` bila perlu,
- keyboard tidak menutup field/action,
- touch target minimum 48×48,
- contrast cukup,
- informasi BMI tidak hanya berdasarkan warna,
- reduce motion: warning BMI menjadi statis bila motion dikurangi.

## 7.20 BMI visual state integration

Walau BMI domain milik Developer 1, visual state milik Developer 2.

Developer 2 memastikan reusable style/token mendukung:

```text
underweight → amber/orange
normal      → green
overweight  → red pulse aman
obesity     → deep red
```

Animation warning:

```text
±700ms dark red
±700ms bright red
repeat
```

Tidak lebih dari 3 flash/detik.

## 7.21 Testing Developer 2

Minimum:

```text
Age normalisasi
future date reject
umur >300 reject
leap year 29-02-2000
invalid 29-02-2023
Hijriah known fixture
Hijriah unsupported range
Weton known fixture
neptu calculation
Saka Bali reference fixtures
Stopwatch state transitions
Stopwatch reset
Stopwatch persistence antar tab
Timer dispose
MainShell tab mapping
Home 5 menu
Panduan 15 bagian
Responsive widget tests utama
```

---

# 8. Object Coverage Matrix — Tidak Boleh Ada yang Terlewat

Tabel ini menjadi inventory final seluruh object produksi utama.

| Object / Artefak | Owner | Status awal |
|---|---|---|
| `pubspec.yaml` | Dev 1 | TODO |
| `lib/main.dart` | Dev 1 | TODO |
| `lib/app.dart` | Dev 2 | TODO |
| `app_colors.dart` | Dev 2 | TODO |
| `app_dimensions.dart` | Dev 2 | TODO |
| `app_strings.dart` | Dev 2 | TODO |
| `app_routes.dart` | Dev 2 | TODO |
| `database_helper.dart` | Dev 1 | TODO |
| migration files | Dev 1 | TODO |
| `app_exception.dart` | Dev 1 | TODO |
| `failure.dart` | Dev 1 | TODO |
| `password_service.dart` | Dev 1 | TODO |
| `session_service.dart` | Dev 1 | TODO |
| `biometric_service.dart` | Dev 1 | TODO |
| `validators.dart` | Dev 1 | TODO |
| `sanitizers.dart` | Dev 1 | TODO |
| `date_utils.dart` | Dev 2 | TODO |
| `user.dart` | Dev 1 | TODO |
| `bmi_record.dart` | Dev 1 | TODO |
| `auth_repository.dart` | Dev 1 | TODO |
| `bmi_repository.dart` | Dev 1 | TODO |
| `bmi_calculator.dart` | Dev 1 | TODO |
| `age_calculator.dart` | Dev 2 | TODO |
| `hijri_converter.dart` | Dev 2 | TODO |
| `weton_calculator.dart` | Dev 2 | TODO |
| `bali_calendar_converter.dart` | Dev 2 | TODO |
| Splash page | Dev 1 | TODO |
| Login page | Dev 1 | TODO |
| Login controller | Dev 1 | TODO |
| MainShell | Dev 2 | TODO |
| Home page | Dev 2 | TODO |
| Home menu card | Dev 2 | TODO |
| Members page | Dev 2 | TODO |
| Member model | Dev 2 | TODO |
| Member local data | Dev 2 | TODO |
| BMI calculator page | Dev 1 | TODO |
| BMI controller | Dev 1 | TODO |
| BMI result page | Dev 1 | TODO |
| BMI result panel | Dev 1 + style Dev 2 | TODO |
| BMI history page | Dev 1 | TODO |
| BMI history controller | Dev 1 | TODO |
| BMI detail page | Dev 1 | TODO |
| BMI edit page | Dev 1 | TODO |
| BMI edit controller | Dev 1 | TODO |
| Date converter page | Dev 2 | TODO |
| Date converter controller | Dev 2 | TODO |
| Nusantara calendar page | Dev 2 | TODO |
| Nusantara calendar controller | Dev 2 | TODO |
| Stopwatch page | Dev 2 | TODO |
| Stopwatch controller | Dev 2 | TODO |
| Help page | Dev 2 | TODO |
| Help sections data | Dev 2 | TODO |
| Gradient button | Dev 2 | TODO |
| App card | Dev 2 | TODO |
| Custom text field | Dev 2 | TODO |
| Confirmation dialog | Dev 2 | TODO |
| Empty state reusable | Dev 2 | TODO |
| Error state reusable | Dev 2 | TODO |
| Loading state reusable | Dev 2 | TODO |
| Snackbar helper/style | Dev 2 | TODO |
| Users table | Dev 1 | TODO |
| BMI records table | Dev 1 | TODO |
| Admin seed | Dev 1 | TODO |
| Session persistence | Dev 1 | TODO |
| Biometric enrollment handling | Dev 1 | TODO |
| Biometric login | Dev 1 | TODO |
| Password show/hide UI | Dev 1 | TODO |
| Login double-submit guard | Dev 1 | TODO |
| SQL parameterization | Dev 1 | TODO |
| DB transaction safety | Dev 1 | TODO |
| BMI save duplicate guard | Dev 1 | TODO |
| BMI delete confirmation | Dev 1 page + Dev 2 shared dialog | TODO |
| BMI empty state | Dev 1 page + Dev 2 reusable UI | TODO |
| BMI loading/error states | Dev 1 | TODO |
| BMI warning animation support | Dev 2 style, Dev 1 page hook | TODO |
| Date single-source-of-truth | Dev 2 | TODO |
| Realtime age timer | Dev 2 | TODO |
| Timer dispose age | Dev 2 | TODO |
| Gregorian output | Dev 2 | TODO |
| Hijriah output | Dev 2 | TODO |
| Weton output | Dev 2 | TODO |
| Neptu output | Dev 2 | TODO |
| Saka Bali output | Dev 2 | TODO |
| Stopwatch state persistence | Dev 2 | TODO |
| Stopwatch reset/start/pause/continue | Dev 2 | TODO |
| Logout confirmation | Dev 2 | TODO |
| Logout clear session | Dev 1 service | TODO |
| Logout stack clearing | Dev 2 | TODO |
| `Navigator.push()` evidence | Dev 2 Home + Dev 1 BMI | TODO |
| `Navigator.pop()` evidence | Dev 1 BMI detail/edit | TODO |
| `Navigator.pushReplacement()` evidence | Dev 1 Login | TODO |
| `pushAndRemoveUntil()` evidence | Dev 2 Logout | TODO |
| Passing Login→MainShell | Dev 1/2 contract | TODO |
| Passing BmiRecord→Edit | Dev 1 | TODO |
| Passing BmiResult→Result page | Dev 1 | TODO |
| Android biometric config | Dev 1 | TODO |
| responsive layout | Dev 2 | TODO |
| accessibility | Dev 2 | TODO |
| reduce motion | Dev 2 | TODO |
| keyboard handling | Dev 2 + Dev 1 form pages | TODO |
| offline operation | Bersama | TODO |
| analyzer clean | Bersama | TODO |
| unit tests | masing-masing | TODO |
| widget tests | masing-masing | TODO |
| integration smoke test | Bersama | TODO |
| release/demo APK | Dev 1 owner, Dev 2 review | TODO |
| laporan aplikasi | dibagi, final bersama | TODO |

---

# 9. Screen Coverage — 13 Screen Utama

Tidak boleh ada screen yang hilang.

| # | Screen | Owner |
|---:|---|---|
| 1 | Splash / Auth Gate | Dev 1 |
| 2 | Login | Dev 1 |
| 3 | Home | Dev 2 |
| 4 | Daftar Anggota | Dev 2 |
| 5 | Kalkulator BMI | Dev 1 |
| 6 | Hasil BMI | Dev 1 |
| 7 | Riwayat BMI | Dev 1 |
| 8 | Detail BMI | Dev 1 |
| 9 | Edit BMI | Dev 1 |
| 10 | Konversi Tanggal & Umur | Dev 2 |
| 11 | Kalender Nusantara | Dev 2 |
| 12 | Stopwatch | Dev 2 |
| 13 | Panduan | Dev 2 |

Tambahan shell/action:

```text
MainShell / Bottom Navigation → Dev 2
Logout action/dialog → Dev 2
Session clear → Dev 1
```

---

# 10. Feature Coverage — PRD Functional Requirements

| ID | Requirement | Owner |
|---|---|---|
| AUTH-01 | Login username/password | Dev 1 |
| AUTH-02 | SQLite user | Dev 1 |
| AUTH-03 | Persistent session | Dev 1 |
| AUTH-04 | Biometric login | Dev 1 |
| AUTH-05 | Logout clear stack | Dev 2 + Dev 1 session |
| NAV-01 | Navigator.push | Dev 2 + Dev 1 |
| NAV-02 | Navigator.pop | Dev 1 |
| NAV-03 | pushReplacement | Dev 1 |
| NAV-04 | Passing data | Dev 1 + Dev 2 contract |
| HOME-01 | 5 menu vertikal | Dev 2 |
| BMI-01 | Name input | Dev 1 |
| BMI-02 | Age validation | Dev 1 |
| BMI-03 | Weight ≤1000 | Dev 1 |
| BMI-04 | Height ≤400 | Dev 1 |
| BMI-05 | BMI calculation | Dev 1 |
| BMI-06 | Result animation | Dev 2 style + Dev 1 integration |
| CRUD-01 | Save result | Dev 1 |
| CRUD-02 | Show history | Dev 1 |
| CRUD-03 | Update | Dev 1 |
| CRUD-04 | Delete | Dev 1 |
| DATE-01 | Gregorian input | Dev 2 |
| DATE-02 | Age realtime | Dev 2 |
| DATE-03 | Hijri conversion | Dev 2 |
| DATE-04 | Weton | Dev 2 |
| DATE-05 | Saka Bali | Dev 2 |
| SW-01 | Start | Dev 2 |
| SW-02 | Pause | Dev 2 |
| SW-03 | Continue | Dev 2 |
| SW-04 | Reset | Dev 2 |
| HELP-01 | User guide | Dev 2 |

---

# 11. Kontrak Integrasi Antar Developer

## 11.1 Login → MainShell

Developer 1 menjamin hasil login menyediakan user/session valid.

Developer 2 menyediakan `MainShell` yang dapat menerima atau membaca identitas user sesuai kontrak final.

Minimal data:

```text
userId
username
role
```

Jangan membuat dua mekanisme user state yang berbeda tanpa alasan.

## 11.2 BMI Result → Design

Developer 1 menyediakan:

```text
BmiCategory
BmiResult
```

Developer 2 menyediakan mapping visual kategori melalui design token.

Domain tidak mengembalikan warna.

## 11.3 Shared Confirmation Dialog

Developer 2 menyediakan komponen dialog.

Developer 1 memakainya untuk delete BMI.

Developer 2 memakainya untuk Logout dan exit app bila dipakai.

## 11.4 Failure Contract

Developer 1 menyediakan base failure.

Developer 2 boleh menambahkan typed failure khusus calendar bila dibutuhkan, tetapi hierarchy dan pola error harus konsisten.

## 11.5 Date validation

Developer 1 memiliki validator umum.

Developer 2 memiliki date calculator/utility.

Sebelum implementasi, sepakati signature sehingga tidak ada duplicate validator future-date atau age range dengan behavior berbeda.

---

# 12. Urutan Produksi Supaya Tidak Saling Menunggu

## Fase 0 — Setup bersama

Durasi pendek, dilakukan bersama.

```text
[ ] clone/init repository
[ ] branch develop
[ ] finalisasi folder structure
[ ] pindahkan docs ke /md bila belum
[ ] agent.md path diperbarui bila docs pindah
[ ] analyzer berjalan
[ ] test command dasar berjalan
```

## Fase 1 — Paralel foundation

### Dev 1

```text
DB
models
repositories
security
validators
seed admin
```

### Dev 2

```text
design tokens
app.dart
shared widgets
MainShell skeleton
Home skeleton
```

## Fase 2 — Paralel core feature

### Dev 1

```text
Splash
Login
BMI calculator
BMI result
```

### Dev 2

```text
Members
Age calculator
Hijriah
Weton
Saka Bali foundation
```

## Fase 3 — Paralel advanced feature

### Dev 1

```text
BMI History
Detail
Edit
Delete
CRUD hardening
```

### Dev 2

```text
Date Converter
Kalender Nusantara
Stopwatch
Panduan
```

## Fase 4 — Integrasi

```text
MainShell + Login
Home + seluruh child routes
BMI + shared design
Logout + SessionService
biometric device test
calendar fixture validation
```

## Fase 5 — QA dan hardening

```text
boundary tests
error states
loading states
empty states
responsive
accessibility
memory/timer dispose
navigation stack
session restart
offline test
```

## Fase 6 — Release dan laporan

```text
final APK/build
screenshots
report
presentation/demo preparation
```

---

# 13. Pembagian Laporan Pembuatan Aplikasi

Agar beban seimbang:

## Developer 1 menulis

```text
BAB II bagian database/security requirement
BAB III arsitektur data, SQLite, ERD, auth
BAB IV Login, Biometric, BMI, CRUD
BAB V test auth, database, BMI, security
Lampiran schema/query penting
```

## Developer 2 menulis

```text
BAB I Pendahuluan draft
BAB II UI/navigation/date requirement
BAB III navigation flow, design system, wireframe
BAB IV Home, Anggota, Date, Calendar, Stopwatch, Panduan
BAB V date/calendar/stopwatch/UI testing
Lampiran design/screenshots
```

## Final bersama

```text
BAB VI Kesimpulan & Saran
proofreading
nomor gambar/tabel
screenshot final
sinkronisasi istilah
```

---

# 14. Test Matrix Bersama

## Authentication

```text
[ ] tofik / 123 sukses
[ ] username salah gagal
[ ] password salah gagal
[ ] field kosong ditolak
[ ] password show/hide
[ ] login tidak double submit
[ ] restart app mempertahankan session
[ ] logout menghapus session
[ ] back setelah login tidak kembali Login
[ ] biometric success
[ ] biometric unavailable
[ ] biometric not enrolled
[ ] biometric cancel
[ ] biometric lockout
```

## BMI

```text
[ ] umur 1 valid
[ ] umur 300 valid
[ ] umur 0 invalid
[ ] umur 301 invalid
[ ] berat 0 invalid
[ ] berat 0.01 valid
[ ] berat 1000 valid
[ ] berat 1000.01 invalid
[ ] tinggi 0 invalid
[ ] tinggi 0.01 valid
[ ] tinggi 400 valid
[ ] tinggi 400.01 invalid
[ ] decimal valid
[ ] comma decimal bila didukung
[ ] NaN invalid
[ ] Infinity invalid
[ ] category underweight
[ ] category normal
[ ] category overweight
[ ] category obesity
[ ] save success
[ ] repeated click tidak duplicate
```

## CRUD

```text
[ ] create
[ ] read list
[ ] read detail
[ ] update
[ ] BMI recalculate saat update
[ ] delete confirmation
[ ] delete success
[ ] empty state
[ ] loading state
[ ] error state
[ ] history refresh setelah edit
```

## Date/Calendar

```text
[ ] default Masehi
[ ] satu input menghasilkan semua output
[ ] future date ditolak
[ ] umur >300 ditolak
[ ] 29-02-2000 valid
[ ] 29-02-2024 valid
[ ] 29-02-2023 invalid
[ ] umur years/months/days normalized
[ ] hours 0..23
[ ] minutes 0..59
[ ] seconds 0..59
[ ] realtime detik berubah
[ ] Timer cancel saat dispose
[ ] Hijriah fixture valid
[ ] Weton fixture valid
[ ] Neptu valid
[ ] Saka Bali fixture valid
[ ] unsupported calendar range tidak crash
[ ] segment hanya mengubah tampilan
```

## Stopwatch

```text
[ ] idle
[ ] start
[ ] pause
[ ] continue
[ ] reset
[ ] format HH:MM:SS.CS
[ ] pindah Home lalu kembali: stopwatch tetap berjalan
[ ] dispose aman
```

## Navigation

```text
[ ] push
[ ] pop
[ ] pushReplacement
[ ] pushAndRemoveUntil
[ ] Login→MainShell passing/identity
[ ] BMI Result passing data
[ ] BMI Record→Edit passing data
```

## Security

```text
[ ] password bukan plaintext DB
[ ] SQL parameterized
[ ] `' OR 1=1 --` tidak bypass login
[ ] malicious text tidak mengeksekusi SQL
[ ] biometric template tidak disimpan
[ ] session tidak menyimpan plaintext password
```

## UI

```text
[ ] 360×640 tidak overflow
[ ] 393×852 nyaman
[ ] 411×915 nyaman
[ ] keyboard tidak menutup form/action
[ ] touch target >=48dp
[ ] BMI status tidak hanya warna
[ ] reduce motion bekerja
[ ] background #EEEEEE
[ ] surface #FFFFFF
[ ] gradient benar
[ ] bottom nav benar
```

---

# 15. Checklist Non-Functional

```text
[ ] seluruh fitur utama offline
[ ] startup tidak hang
[ ] local query responsif
[ ] no uncaught parsing exception
[ ] no division by zero
[ ] no raw SQL interpolation
[ ] no timer leak
[ ] no duplicate controller/timer setelah navigation
[ ] no duplicate DB row dari double tap
[ ] migration tidak menghapus data tanpa alasan
[ ] error message user-friendly
[ ] code mengikuti layer separation
```

---

# 16. Aturan Merge Harian

Setiap developer sebelum merge:

```text
1. pull develop terbaru
2. rebase/merge lokal
3. flutter analyze
4. flutter test
5. jalankan feature yang diubah
6. cek tidak ada file ownership konflik
7. commit message jelas
8. merge request / review silang
```

Format commit contoh:

```text
feat(auth): implement local login and session
feat(bmi): add bmi calculation and save flow
feat(calendar): add weton converter
fix(stopwatch): preserve elapsed state across tabs
```

---

# 17. Stop Condition — Jangan Merge Jika

Jangan merge ke `develop` jika salah satu terjadi:

- analyzer error,
- test existing rusak,
- password plaintext,
- SQL interpolation,
- feature requirement dihapus,
- timer tidak dispose,
- screen overflow parah,
- login/navigation stack rusak,
- Saka Bali/Weton hasil belum tervalidasi tapi diklaim benar,
- merge conflict diselesaikan dengan menghapus kode orang lain tanpa review.

---

# 18. Definition of Done per Feature

Sebuah feature baru dianggap selesai jika:

```text
[ ] requirement PRD terpenuhi
[ ] file berada di layer yang benar
[ ] validation lengkap
[ ] error state tersedia
[ ] loading state tersedia bila async
[ ] empty state tersedia bila list
[ ] navigation benar
[ ] tidak ada SQL di widget
[ ] tidak ada domain algorithm di widget
[ ] dispose resource benar
[ ] test utama tersedia
[ ] UI mengikuti design system
[ ] reviewer developer lain menyetujui
```

---

# 19. Definition of Done Produksi Keseluruhan

Produksi NusaFit dianggap lengkap hanya jika:

```text
[ ] 13 screen utama tersedia
[ ] MainShell tersedia
[ ] 5 menu Home tepat
[ ] 4 item bottom navigation tepat
[ ] akun tofik/123 bekerja
[ ] password hash
[ ] SQLite
[ ] session
[ ] biometric
[ ] BMI
[ ] BMI category
[ ] warning visual
[ ] CRUD lengkap
[ ] konversi Masehi
[ ] Hijriah
[ ] Weton
[ ] Neptu
[ ] Saka Bali
[ ] umur realtime tahun-bulan-hari-jam-menit-detik
[ ] Stopwatch
[ ] Panduan
[ ] Logout
[ ] push
[ ] pop
[ ] pushReplacement
[ ] pushAndRemoveUntil
[ ] passing data
[ ] input sanitization
[ ] error handling
[ ] DB migration
[ ] offline operation
[ ] accessibility minimum
[ ] responsive minimum
[ ] test boundary
[ ] test security
[ ] test calendar
[ ] test biometric
[ ] analyzer clean
[ ] test suite lulus
[ ] APK/demo build berhasil
[ ] laporan selesai
```

---

# 20. Ringkasan Porsi Akhir

## Developer 1

```text
Core foundation
SQLite
Migration
Users
Admin seed
Password hashing
Session
Biometric(berikan tombol off di system dan default off wajib)
Auth repository
BMI repository
User model
BMI model
Validator/sanitizer umum
Splash
Login
BMI Calculator
BMI Result
BMI History
BMI Detail
BMI Edit
BMI CRUD
Security tests
BMI/database tests
Android biometric config
Integration/release build owner
```

## Developer 2

```text
App shell
Design system
Design tokens
Shared widgets
MainShell
Bottom navigation
Home
Daftar Anggota
Age calculator
Gregorian representation
Hijriah converter
Weton converter
Neptu
Saka Bali converter
Date Converter
Kalender Nusantara
Stopwatch
Panduan
Logout UI/navigation
Responsive
Accessibility
Reduce motion
Calendar/stopwatch/UI tests
```

## Bersama

```text
Kontrak antar-layer
Code review silang
Integration
Smoke test
Offline test
Final QA
Laporan final
Demo/presentasi
```

Dengan pembagian ini, seluruh screen, service, repository, model, calculator, database object, navigation requirement, validation, error handling, design requirement, test requirement, platform configuration, laporan, dan release task memiliki pemilik yang jelas.
