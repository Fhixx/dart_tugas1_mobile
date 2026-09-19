PENTING

SEBELUM RUN PASTIKAN (flutter pub get)


## Table of Contents

1. [How to Read This Codebase](#how-to-read-this-codebase)
2. [Complete Project Structure](#complete-project-structure)
3. [Lib Folder Cheat Sheet](#lib-folder-cheat-sheet)
4. [File Type Cheat Sheet](#file-type-cheat-sheet)
5. [Understanding the `lib/` Folder](#understanding-the-lib-folder)
   - [`lib/core/`](#libcore)
   - [`lib/data/`](#libdata)
   - [`lib/domain/`](#libdomain)
   - [`lib/features/`](#libfeatures)
   - [`lib/widgets/`](#libwidgets)
6. [Feature Folders Deep Map](#feature-folders-deep-map)
   - [Auth Feature](#auth-feature)
   - [Home Feature](#home-feature)
   - [Members Feature](#members-feature)
   - [BMI Feature](#bmi-feature)
   - [Date Converter Feature](#date-converter-feature)
   - [Calendar Feature](#calendar-feature)
   - [Stopwatch Feature](#stopwatch-feature)
   - [Help/Panduan Feature](#helppanduan-feature)
7. [Why One Feature Uses Many Files](#why-one-feature-uses-many-files)
8. [Feature → File Map](#feature--file-map)
9. [File → Feature Map](#file--feature-map)
10. [Application Startup Flow](#application-startup-flow)
11. [Login Flow](#login-flow)
12. [Session Architecture](#session-architecture)
13. [Authentication Architecture](#authentication-architecture)
14. [Biometric Architecture](#biometric-architecture)
15. [Database Architecture](#database-architecture)
16. [Design System](#design-system)
17. [Android Platform Integration](#android-platform-integration)
18. [Where Do I Change Something?](#where-do-i-change-something)
19. [Debugging Guide](#debugging-guide)
20. [Source of Truth](#source-of-truth)
21. [Developer Ownership](#developer-ownership)
22. [Shared Contracts](#shared-contracts)
23. [Testing Map](#testing-map)
24. [Dependency Map](#dependency-map)
25. [Glossary](#glossary)
26. [Naming Conventions](#naming-conventions)
27. [Temporary / Legacy Components](#temporary--legacy-components)
28. [AI / Project Documentation](#ai--project-documentation)
29. [Current Status](#current-status)

---

## How to Read This Codebase

`lib/` berisi source code utama aplikasi NusaFit.

Pola umum NusaFit:

```
Page (tampilan)
  ↓
Controller (state + pengatur alur)
  ↓
Domain / Calculator (rumus business rules)
  ↓
Repository (akses data)
  ↓
Service / Database (penyimpanan)
```

Penjelasan sederhana:

| Layer | Artinya | Contoh |
|---|---|---|
| **Page** | Tampilan dan interaksi user | `LoginPage`, `BmiCalculatorPage` |
| **Controller** | State sementara dan pengatur alur fitur | `LoginController`, `BmiCalculatorController` |
| **Domain / Calculator** | Rumus / business rules murni | `BmiCalculator`, `AgeCalculator` |
| **Model** | Bentuk data | `User`, `BmiRecord`, `UserSession` |
| **Repository** | Pintu akses database | `AuthRepository`, `BmiRepository` |
| **Service** | Layanan khusus (security, session, biometric) | `SessionService`, `PasswordService`, `BiometricService` |
| **Database Helper** | Lifecycle SQLite | `DatabaseHelper`, `MigrationV1`, `AdminSeed` |
| **Widget** | Komponen UI reusable | `AppCard`, `ConfirmationDialog` |
| **MainShell** | Container utama setelah login | Bottom navigation, session lifecycle |

---

## Complete Project Structure

```
mobile_kalku/
├── lib/
│   ├── main.dart                          # Entry point aplikasi
│   │
│   ├── core/                              # Fondasi bersama
│   │   ├── constants/                     # Desain global: warna, ukuran, string, routes
│   │   ├── database/                      # Infrastruktur database
│   │   │   ├── admin_seed.dart
│   │   │   ├── database_helper.dart
│   │   │   └── migrations/
│   │   │       └── migration_v1.dart
│   │   ├── domain/                        # Enum hasil wrapper
│   │   │   ├── auth_result.dart
│   │   │   ├── biometric_result.dart
│   │   │   ├── bmi_calculation_result.dart
│   │   │   ├── bmi_calculator.dart        # Rumus BMI murni
│   │   │   └── bmi_category.dart          # Enum kategori BMI
│   │   ├── errors/                        # Kelas error hierarkis
│   │   ├── security/                      # Security services
│   │   │   ├── auth_contract.dart
│   │   │   ├── biometric_service.dart
│   │   │   ├── password_service.dart
│   │   │   └── session_service.dart
│   │   └── utils/                         # Helper utilities
│   │       ├── calculation_error_translator.dart
│   │       ├── date_utils.dart
│   │       ├── sanitizers.dart
│   │       └── validators.dart
│   │
│   ├── data/                              # Data layer
│   │   ├── models/                        # Bentuk data
│   │   │   ├── bmi_record.dart
│   │   │   ├── user.dart
│   │   │   └── user_session.dart
│   │   └── repositories/                  # Akses database
│   │       ├── auth_repository.dart
│   │       └── bmi_repository.dart
│   │
│   ├── domain/                            # Pure calculation engines
│   │   └── calculators/
│   │       ├── age_calculator.dart
│   │       ├── bali_calendar_converter.dart
│   │       ├── calculation_error.dart
│   │       ├── hijri_converter.dart
│   │       ├── stopwatch_formatter.dart
│   │       └── weton_calculator.dart
│   │
│   ├── features/                          # Fitur user-facing
│   │   ├── auth/
│   │   │   ├── controller/
│   │   │   │   └── login_controller.dart
│   │   │   └── pages/
│   │   │       ├── login_page.dart
│   │   │       └── splash_page.dart
│   │   ├── bmi/
│   │   │   ├── controllers/
│   │   │   │   ├── bmi_calculator_controller.dart
│   │   │   │   ├── bmi_edit_controller.dart
│   │   │   │   └── bmi_history_controller.dart
│   │   │   └── pages/
│   │   │       ├── bmi_calculator_page.dart
│   │   │       ├── bmi_detail_page.dart
│   │   │       ├── bmi_edit_page.dart
│   │   │       ├── bmi_history_page.dart
│   │   │       └── bmi_result_page.dart
│   │   ├── calendar/
│   │   │   ├── controller/
│   │   │   │   └── nusantara_calendar_controller.dart
│   │   │   └── pages/
│   │   │       └── nusantara_calendar_page.dart
│   │   ├── date_converter/
│   │   │   ├── controller/
│   │   │   │   └── date_converter_controller.dart
│   │   │   └── pages/
│   │   │       └── date_converter_page.dart
│   │   ├── help/
│   │   │   ├── data/
│   │   │   │   └── help_sections.dart
│   │   │   └── pages/
│   │   │       └── help_page.dart
│   │   ├── home/
│   │   │   ├── pages/
│   │   │   │   ├── home_page.dart
│   │   │   │   └── main_shell.dart
│   │   │   └── widgets/
│   │   │       └── home_menu_card.dart
│   │   ├── members/
│   │   │   ├── data/
│   │   │   │   └── member_data.dart
│   │   │   ├── models/
│   │   │   │   └── member.dart
│   │   │   └── pages/
│   │   │       └── members_page.dart
│   │   └── stopwatch/
│   │       ├── controller/
│   │       │   └── stopwatch_controller.dart
│   │       └── pages/
│   │           └── stopwatch_page.dart
│   │
│   └── widgets/                           # UI reusable
│       ├── app_card.dart
│       ├── app_snackbar.dart
│       ├── coming_soon_page.dart
│       ├── confirmation_dialog.dart
│       ├── conversion_result_card.dart
│       ├── custom_text_field.dart
│       ├── gradient_button.dart
│       └── state_views.dart
│
├── test/                                  # Automated tests
│   ├── core/
│   ├── data/
│   └── features/
│
├── android/                               # Android platform
│   └── app/
│       ├── build.gradle.kts
│       └── src/main/
│           ├── AndroidManifest.xml
│           └── kotlin/com/example/mobile_kalku/
│               └── MainActivity.kt
│
├── md/                                    # Project specification docs
│   ├── PRD_NusaFit_Lengkap.md
│   ├── DESIGN_SYSTEM.md
│   ├── MENU_IMPLEMENTATION.md
│   ├── COMPUTATION_LOGIC.md
│   ├── WRITING_RULES.md
│   └── README_AI_GUIDE.md
│
├── pubspec.yaml                           # Dependencies
└── README.md                              # This file
```

---

## Lib Folder Cheat Sheet

| Folder | Simple Meaning | Example |
|---|---|---|
| `lib/core/` | Fondasi aplikasi | DB, security, validators |
| `lib/data/models/` | Bentuk data | User, BmiRecord, UserSession |
| `lib/data/repositories/` | Akses data | AuthRepository, BmiRepository |
| `lib/domain/calculators/` | Rumus/business logic | AgeCalculator, BmiCalculator |
| `lib/features/` | Fitur user-facing | BMI, Stopwatch, Date Converter |
| `lib/widgets/` | UI reusable | AppCard, ConfirmationDialog |
| `lib/main.dart` | Entry point | runApp |

---

## File Type Cheat Sheet

| File Pattern | Artinya |
|---|---|
| `*_page.dart` | Screen / UI |
| `*_controller.dart` | State + orchestrasi fitur |
| `*_repository.dart` | Akses data persistence |
| `*_service.dart` | Layanan khusus (security, session, biometric) |
| `*_calculator.dart` | Pure calculation / business rules |
| `*_model.dart` atau `model/*.dart` | Struktur data |
| `*_test.dart` | Automated verification |
| `main.dart` | Entry point Flutter |

---

## Understanding the `lib/` Folder

`lib/` berisi source code utama aplikasi NusaFit.

---

### `lib/core/`

Berisi logika fondasi yang digunakan oleh banyak fitur.

#### `lib/core/database/`

Infrastruktur database SQLite.

| File | Purpose | Called By |
|---|---|---|
| [`database_helper.dart`](lib/core/database/database_helper.dart) | Singleton SQLite connection, PRAGMA, lifecycle | Semua repository, SplashPage |
| [`admin_seed.dart`](lib/core/database/admin_seed.dart) | Idempotent seed admin `tofik/123` | SplashPage |
| [`migration_v1.dart`](lib/core/database/migrations/migration_v1.dart) | Membuat tabel `users` & `bmi_records` | DatabaseHelper |

#### `lib/core/security/`

Layanan security & session.

| File | Purpose | Called By |
|---|---|---|
| [`password_service.dart`](lib/core/security/password_service.dart) | PBKDF2-HMAC-SHA256 hashing & verification | AuthRepository, AdminSeed |
| [`session_service.dart`](lib/core/security/session_service.dart) | Secure storage session CRUD & 30-min hard timeout | SplashPage, LoginController, MainShell |
| [`biometric_service.dart`](lib/core/security/biometric_service.dart) | OS biometric hardware wrapper | LoginController |
| [`auth_contract.dart`](lib/core/security/auth_contract.dart) | `AuthenticatedPageBuilder` typedef untuk handoff User | SplashPage, LoginPage, MainShell |

#### `lib/core/domain/`

Enum wrapper hasil computation.

| File | Purpose |
|---|---|
| [`auth_result.dart`](lib/core/domain/auth_result.dart) | AuthStatus enum + AuthResult wrapper |
| [`biometric_result.dart`](lib/core/domain/biometric_result.dart) | BiometricStatus enum + BiometricAuthResult wrapper |
| [`bmi_calculation_result.dart`](lib/core/domain/bmi_calculation_result.dart) | Immutable BMI computation output holder |
| [`bmi_calculator.dart`](lib/core/domain/bmi_calculator.dart) | Rumus BMI murni |
| [`bmi_category.dart`](lib/core/domain/bmi_category.dart) | Enum kategori BMI + boundary |

#### `lib/core/errors/`

Hierarki error classes.

| File | Purpose |
|---|---|
| [`failure.dart`](lib/core/errors/failure.dart) | Abstract base failure |
| [`app_exception.dart`](lib/core/errors/app_exception.dart) | Base application exception |
| [`authentication_failure.dart`](lib/core/errors/authentication_failure.dart) | Auth domain error |
| [`biometric_failure.dart`](lib/core/errors/biometric_failure.dart) | Biometric hardware error |
| [`database_failure.dart`](lib/core/errors/database_failure.dart) | SQLite error |
| [`validation_failure.dart`](lib/core/errors/validation_failure.dart) | Input validation error |

#### `lib/core/utils/`

Utilities bersama.

| File | Purpose | Called By |
|---|---|---|
| [`validators.dart`](lib/core/utils/validators.dart) | Cek input valid/invalid | LoginController, BMI Controllers |
| [`sanitizers.dart`](lib/core/utils/sanitizers.dart) | Bersihkan/normalisasi input | Validators |
| [`date_utils.dart`](lib/core/utils/date_utils.dart) | Helper tanggal: leap year, addMonths, format | AgeCalculator, DateConverter |
| [`calculation_error_translator.dart`](lib/core/utils/calculation_error_translator.dart) | Terjemahkan CalculationError ke Bahasa Indonesia | DateConverterPage, NusantaraCalendarPage |

#### `lib/core/constants/`

Desain global: warna, ukuran, string, routes.

| File | Purpose |
|---|---|
| [`app_colors.dart`](lib/core/constants/app_colors.dart) | Palette, gradient primary, nav colors |
| [`app_dimensions.dart`](lib/core/constants/app_dimensions.dart) | Spacing, padding, radius, touch target |
| [`app_strings.dart`](lib/core/constants/app_strings.dart) | Text konstan: app name, menu titles, dialog labels |
| [`app_routes.dart`](lib/core/constants/app_routes.dart) | Route name constants |

---

### `lib/data/`

Mewakili data persisten dan data access.

#### `lib/data/models/`

Bentuk data.

| Model | Disimpan Di | Dibuat Oleh | Dipakai Oleh |
|---|---|---|---|
| [`user.dart`](lib/data/models/user.dart) | SQLite `users` table | AdminSeed, AuthRepository | AuthRepository, LoginController, MainShell |
| [`user_session.dart`](lib/data/models/user_session.dart) | FlutterSecureStorage | LoginController | SessionService |
| [`bmi_record.dart`](lib/data/models/bmi_record.dart) | SQLite `bmi_records` table | BmiRepository | BmiHistoryController, BmiEditController |

**Penting:** `User` ≠ `UserSession`. `User` = akun di database. `UserSession` = sesi login sementara (tanpa password/hash/salt).

#### `lib/data/repositories/`

Akses database.

| Repository | Table | Methods | Called By |
|---|---|---|---|
| [`auth_repository.dart`](lib/data/repositories/auth_repository.dart) | `users` | login, findUserByUsername, findUserById, findBiometricEnabledUser, setBiometricEnabled | LoginController, SplashPage |
| [`bmi_repository.dart`](lib/data/repositories/bmi_repository.dart) | `bmi_records` | insertRecord, getRecordsForUser, getRecordByIdForUser, updateRecordForUser, deleteRecordForUser | BmiCalculatorController, BmiHistoryController, BmiEditController |

**Kenapa SQL di Repository, bukan di Page?**
- Page tidak boleh langsung query database (layer boundary)
- Repository meng-enforce user isolation (`user_id = ?`)
- Testing lebih mudah (mock repository)

---

### `lib/domain/`

Berisi pure calculation — tidak ada UI, tidak ada database, tidak ada async I/O.

| Calculator | Input | Output | Used By | Pure? |
|---|---|---|---|---|
| [`bmi_calculator.dart`](lib/core/domain/bmi_calculator.dart) | weightKg, heightCm | raw BMI double | BmiCalculatorController | ✓ |
| [`bmi_category.dart`](lib/core/domain/bmi_category.dart) | raw BMI | BmiCategory enum | BmiCalculator | ✓ |
| [`age_calculator.dart`](lib/domain/calculators/age_calculator.dart) | birth DateTime, now DateTime | AgeResult (years/months/days/hours/minutes/seconds) | DateConverterController | ✓ |
| [`hijri_converter.dart`](lib/domain/calculators/hijri_converter.dart) | Gregorian DateTime | HijriDateResult (day/month/year/monthName) | DateConverterController | ✓ |
| [`weton_calculator.dart`](lib/domain/calculators/weton_calculator.dart) | Gregorian DateTime | WetonResult (dayName, pasaran, wetonLabel, neptu) | NusantaraCalendarController | ✓ |
| [`bali_calendar_converter.dart`](lib/domain/calculators/bali_calendar_converter.dart) | Gregorian DateTime | SakaCalendarResult (wuku, pancawara, saptawara, sasih, tahunSaka) | NusantaraCalendarController | ✓ |
| [`stopwatch_formatter.dart`](lib/domain/calculators/stopwatch_formatter.dart) | elapsed milliseconds | HH:MM:SS.CS string | StopwatchController | ✓ |
| [`calculation_error.dart`](lib/domain/calculators/calculation_error.dart) | — | CalculationError enum | Semua calculator | ✓ |

**Domain files TIDAK BOLEH handle UI.**

---

### `lib/features/`

Setiap subfolder mewakili satu fitur user-facing.

---

#### Feature Folder: `lib/features/auth/`

**Purpose:** Autentikasi login & session gate.

```
auth/
├── controller/
│   └── login_controller.dart
└── pages/
    ├── login_page.dart
    └── splash_page.dart
```

**Relationship:**

```
LoginPage → LoginController → AuthRepository → PasswordService / SessionService
```

**Files:**

| File | Layer | Role |
|---|---|---|
| [`login_page.dart`](lib/features/auth/pages/login_page.dart) | Presentation | Menampilkan form login, biometric button, error banner |
| [`login_controller.dart`](lib/features/auth/controller/login_controller.dart) | State Management | Mengelola form state, memanggil AuthRepository, mengelola SessionService |
| [`splash_page.dart`](lib/features/auth/pages/splash_page.dart) | Presentation | Startup screen, inisialisasi DB, cek session, tentukan Login vs MainShell |

---

#### Feature Folder: `lib/features/home/`

**Purpose:** Main container setelah login.

```
home/
├── pages/
│   ├── home_page.dart
│   └── main_shell.dart
└── widgets/
    └── home_menu_card.dart
```

| File | Purpose | Owner |
|---|---|---|
| [`main_shell.dart`](lib/features/home/pages/main_shell.dart) | Root shell setelah login, bottom navigation, IndexedStack state preservation, logout integration | Dev 2 |
| [`home_page.dart`](lib/features/home/pages/home_page.dart) | 5 menu cards, navigasi ke fitur lain | Dev 2 |
| [`home_menu_card.dart`](lib/features/home/widgets/home_menu_card.dart) | Satu baris menu: icon + title + desc + chevron | Dev 2 |

**Perbedaan:**
- `MainShell` = container utama, bottom nav, session lifecycle
- `HomePage` = menampilkan 5 menu card, buka halaman fitur

---

#### Feature Folder: `lib/features/members/`

**Purpose:** Daftar anggota tim proyek.

```
members/
├── data/
│   └── member_data.dart
├── models/
│   └── member.dart
└── pages/
    └── members_page.dart
```

**Sifat:** Hanya read-only, menggunakan data statis (`member_data.dart`), tidak ada repository/database.

---

#### Feature Folder: `lib/features/bmi/`

**Purpose:** Kalkulator BMI + full CRUD riwayat.

```
bmi/
├── controllers/
│   ├── bmi_calculator_controller.dart
│   ├── bmi_edit_controller.dart
│   └── bmi_history_controller.dart
└── pages/
    ├── bmi_calculator_page.dart
    ├── bmi_result_page.dart
    ├── bmi_history_page.dart
    ├── bmi_detail_page.dart
    └── bmi_edit_page.dart
```

| File | Unique Purpose |
|---|---|
| `bmi_calculator_page.dart` | Input form BMI |
| `bmi_calculator_controller.dart` | Form state + validasi + orkestrasi hitung + save |
| `bmi_result_page.dart` | Tampilkan hasil + aksi save |
| `bmi_history_page.dart` | List riwayat BMI user |
| `bmi_detail_page.dart` | Detail satu record |
| `bmi_edit_page.dart` | Edit form + recalculate + update |
| `bmi_history_controller.dart` | Load/delete records |
| `bmi_edit_controller.dart` | Edit state + recalculation + update persistence |

---

#### Feature Folder: `lib/features/date_converter/`

**Purpose:** Konversi tanggal + umur realtime.

```
date_converter/
├── controller/
│   └── date_converter_controller.dart
└── pages/
    └── date_converter_page.dart
```

**Flow:**

```
DateConverterPage → DateConverterController
    ├── AgeCalculator (realtime 1-detik timer)
    └── HijriConverter
```

---

#### Feature Folder: `lib/features/calendar/`

**Purpose:** Kalender Nusantara — Weton + Saka Bali.

```
calendar/
├── controller/
│   └── nusantara_calendar_controller.dart
└── pages/
    └── nusantara_calendar_page.dart
```

**Flow:**

```
NusantaraCalendarPage → NusantaraCalendarController
    ├── WetonCalculator
    └── BaliCalendarConverter
```

---

#### Feature Folder: `lib/features/stopwatch/`

**Purpose:** Stopwatch HH:MM:SS.CS.

```
stopwatch/
├── controller/
│   └── stopwatch_controller.dart
└── pages/
    └── stopwatch_page.dart
```

| File | Purpose |
|---|---|
| `stopwatch_page.dart` | UI: elapsed display + Start/Pause/Continue/Reset buttons |
| `stopwatch_controller.dart` | Elapsed time state, monotonic Stopwatch source, Timer hanya untuk UI refresh |

**Mengapa controller dipisah?** Timer logic tidak boleh langsung di UI agar state bisa diuji dan dipertahankan saat tab switch (IndexedStack).

---

#### Feature Folder: `lib/features/help/`

**Purpose:** Panduan statis.

```
help/
├── data/
│   └── help_sections.dart
└── pages/
    └── help_page.dart
```

**Catatan:** Fitur statis — tidak perlu repository/database/domain calculator.

---

### `lib/widgets/`

Komponen UI reusable dipakai oleh banyak screen.

| Widget | File | Purpose | Used By |
|---|---|---|---|
| `AppCard` | [`widgets/app_card.dart`](lib/widgets/app_card.dart) | Card container dengan styling konsisten | HomeMenuCard, MemberCard |
| `GradientButton` | [`widgets/gradient_button.dart`](lib/widgets/gradient_button.dart) | Button dengan primary gradient | StopwatchPage |
| `SecondaryButton` | [`widgets/gradient_button.dart`](lib/widgets/gradient_button.dart) | Button sekunder | StopwatchPage |
| `ConfirmationDialog` | [`widgets/confirmation_dialog.dart`](lib/widgets/confirmation_dialog.dart) | Dialog konfirmasi logout | MainShell |
| `ConversionResultCard` | [`widgets/conversion_result_card.dart`](lib/widgets/conversion_result_card.dart) | Card hasil konversi | DateConverterPage, NusantaraCalendarPage |
| `ConversionErrorCard` | [`widgets/conversion_result_card.dart`](lib/widgets/conversion_result_card.dart) | Card error konversi | DateConverterPage |
| `CustomTextField` | [`widgets/custom_text_field.dart`](lib/widgets/custom_text_field.dart) | Text field reusable | ComingSoonPage |
| `ComingSoonPage` | [`widgets/coming_soon_page.dart`](lib/widgets/coming_soon_page.dart) | Placeholder page | (sementara) |
| `AppSnackbar` | [`widgets/app_snackbar.dart`](lib/widgets/app_snackbar.dart) | Snackbar reusable | (opsional) |
| `StateViews` | [`widgets/state_views.dart`](lib/widgets/state_views.dart) | Loading/error/empty state views | (opsional) |

---

## Why One Feature Uses Many Files

Contoh: **Session**

| File | Job |
|---|---|
| `user_session.dart` | Bentuk data session |
| `session_service.dart` | Simpan/baca/hapus/validasi session di secure storage |
| `login_controller.dart` | Buat session setelah login berhasil |
| `splash_page.dart` | Cek session saat app dibuka |
| `main_shell.dart` | Runtime timeout / lifecycle |
| `login_page.dart` | UI login |

Kenapa tidak digabung jadi satu file?
- Sulit testing
- UI mixed dengan security
- Harder debugging
- Duplicate logic
- Unclear ownership
- Increased regression risk

Contoh lain: **BMI**, **Date Converter**, **Stopwatch** — semuanya mengikuti pola yang sama.

---

## Feature → File Map

| Feature | UI/Page | Controller | Domain/Calculator | Repository | Model | Storage |
|---|---|---|---|---|---|---|
| Login | LoginPage | LoginController | PasswordService | AuthRepository | User | Secure Storage |
| Session | SplashPage | LoginController | SessionService | — | UserSession | Secure Storage |
| Biometric | LoginPage | LoginController | BiometricService | AuthRepository | User | SQLite + Secure Storage |
| Home | MainShell + HomePage | — | — | — | — | — |
| Members | MembersPage | — | — | — | Member | Static data |
| BMI Calculator | BmiCalculatorPage | BmiCalculatorController | BmiCalculator + BmiCategory | BmiRepository | BmiRecord | SQLite |
| BMI History | BmiHistoryPage + Detail + Edit | BmiHistoryController + BmiEditController | BmiCalculator (recalc) | BmiRepository | BmiRecord | SQLite |
| Date Converter | DateConverterPage | DateConverterController | AgeCalculator + HijriConverter | — | — | — |
| Calendar | NusantaraCalendarPage | NusantaraCalendarController | WetonCalculator + BaliCalendarConverter | — | — | — |
| Stopwatch | StopwatchPage | StopwatchController | stopwatch_formatter | — | — | — |
| Panduan | HelpPage | — | — | — | — | — |

---

## File → Feature Map

| File | Belongs To | Main Function |
|---|---|---|
| `main.dart` | Bootstrap | Entry point, NusaFitApp, Splash → MainShell |
| `database_helper.dart` | Database | SQLite singleton |
| `admin_seed.dart` | Database | Seed admin tofik/123 |
| `migration_v1.dart` | Database | Buat tabel users + bmi_records |
| `password_service.dart` | Security | PBKDF2 hash & verify |
| `session_service.dart` | Security | Session CRUD + 30-min hard timeout |
| `biometric_service.dart` | Security | OS biometric wrapper |
| `auth_contract.dart` | Security | AuthenticatedPageBuilder typedef |
| `auth_result.dart` | Domain | AuthStatus enum |
| `biometric_result.dart` | Domain | BiometricStatus enum |
| `bmi_calculation_result.dart` | Domain | Immutable BMI result holder |
| `bmi_calculator.dart` | Domain | BMI formula |
| `bmi_category.dart` | Domain | BMI category enum |
| `user.dart` | Data Model | User database record |
| `user_session.dart` | Data Model | Session data |
| `bmi_record.dart` | Data Model | BMI record |
| `auth_repository.dart` | Data Repository | User queries |
| `bmi_repository.dart` | Data Repository | BMI CRUD |
| `age_calculator.dart` | Domain Calculator | Age years/months/days/hours/minutes/seconds |
| `hijri_converter.dart` | Domain Calculator | Gregorian → Hijri |
| `weton_calculator.dart` | Domain Calculator | Weton + Neptu |
| `bali_calendar_converter.dart` | Domain Calculator | Saka Bali |
| `stopwatch_formatter.dart` | Domain Calculator | HH:MM:SS.CS format |
| `calculation_error.dart` | Domain | CalculationError enum |
| `login_controller.dart` | Auth | Login state + orchestration |
| `login_page.dart` | Auth | Login UI |
| `splash_page.dart` | Auth | Startup gate |
| `main_shell.dart` | Home | Bottom nav + session lifecycle |
| `home_page.dart` | Home | 5 menu cards |
| `home_menu_card.dart` | Home | One menu row |
| `members_page.dart` | Members | Member list |
| `bmi_calculator_page.dart` | BMI | Input form |
| `bmi_calculator_controller.dart` | BMI | Form state + save lifecycle |
| `bmi_result_page.dart` | BMI | Result display |
| `bmi_history_page.dart` | BMI | History list |
| `bmi_detail_page.dart` | BMI | Detail view |
| `bmi_edit_page.dart` | BMI | Edit form |
| `bmi_history_controller.dart` | BMI | History load/delete |
| `bmi_edit_controller.dart` | BMI | Edit + recalculate |
| `date_converter_page.dart` | Date Converter | Conversion UI |
| `date_converter_controller.dart` | Date Converter | Age + Hijri + Weton + Saka |
| `nusantara_calendar_page.dart` | Calendar | Weton + Saka UI |
| `nusantara_calendar_controller.dart` | Calendar | Weton + Saka logic |
| `stopwatch_page.dart` | Stopwatch | UI + buttons |
| `stopwatch_controller.dart` | Stopwatch | Timer state |
| `help_page.dart` | Help | Panduan UI |
| `help_sections.dart` | Help | Static content data |
| `member.dart` | Members | Member model |
| `member_data.dart` | Members | Static member data |
| App constants | Design | Colors, dimensions, strings, routes |
| AppCard, ConfirmationDialog, dll | Widgets | Reusable UI |

---

## Application Startup Flow

```
main()
  → WidgetsFlutterBinding.ensureInitialized()
  → runApp(NusaFitApp)
      → MaterialApp
          → SplashPage
              → DatabaseHelper.instance.database
              → AdminSeed().run(db)
              → SessionService.readSession()
              → isSessionExpired()?
                  ├─ Yes → clearSession() → LoginPage
                  └─ No  → AuthContract(user) → MainShell
```

**Catatan:** `_TempDev1App` sudah dihapus. `NusaFitApp` sekarang live di `lib/main.dart`.

---

## Login Flow

1. User buka `LoginPage`
2. User masukkan username/password
3. `LoginPage` kirim ke `LoginController`
4. Controller sanitize + validasi
5. Controller panggil `AuthRepository.login()`
6. Repository query SQLite `users`
7. `PasswordService.verify()` PBKDF2 hash
8. AuthRepository kembalikan `User` / `AuthResult`
9. `LoginController` buat `UserSession` (authenticatedAt = now, expiresAt = now + 30 menit)
10. `SessionService.saveSession()` → secure storage
11. `LoginPage` navigasi ke `MainShell` via `AuthContract`

---

## Session Architecture — File by File

| File | Role |
|---|---|
| [`user_session.dart`](lib/data/models/user_session.dart) | Data bentuk session |
| [`session_service.dart`](lib/core/security/session_service.dart) | Storage + expiry source of truth |
| [`login_controller.dart`](lib/features/auth/controller/login_controller.dart) | Buat session setelah login berhasil |
| [`splash_page.dart`](lib/features/auth/pages/splash_page.dart) | Cek session saat app dibuka |
| [`main_shell.dart`](lib/features/home/pages/main_shell.dart) | Runtime timeout / lifecycle |
| [`login_page.dart`](lib/features/auth/pages/login_page.dart) | UI login |

---

## Session Hard Timeout

```
expiresAt = authenticatedAt + 30 minutes
```

Contoh:
- 10:00 login → expiresAt = 10:30
- 10:30 apapun aktivitas → expired

**Tidak diperpanjang oleh activity user.**

Responsibility:
- `SessionService` = truth about expiration
- `MainShell` = timer/lifecycle trigger
- `SplashPage` = startup expiry gate
- `LoginController` = creates new session
- `Logout` = clears session

---

## Authentication Architecture

**Dev 1 owns:**
- `AuthRepository`, `PasswordService`, `SessionService`, `BiometricService`
- `LoginController`, `SplashPage`, `LoginPage`
- `User`, `UserSession`, `AuthResult`, `BiometricAuthResult`

**Dev 2 owns:**
- `MainShell`, `LoginPage` UI integration (final)
- Logout UI + navigation

**Shared contract:** `AuthContract` (`AuthenticatedPageBuilder`) — Dev1 provides, Dev2 consumes.

---

## Biometric Architecture

3 konsep terpisah:
1. **OS Capability** — `BiometricService.getAvailability()`
2. **NusaFit Preference** — `users.biometric_enabled` (default 0/OFF)
3. **Active Session** — dibuat di `SessionService` setelah biometric auth berhasil

File terkait:
- [`biometric_service.dart`](lib/core/security/biometric_service.dart)
- [`auth_repository.dart`](lib/data/repositories/auth_repository.dart)
- [`user.dart`](lib/data/models/user.dart) — `biometricEnabled` field
- [`login_controller.dart`](lib/features/auth/controller/login_controller.dart)
- [`login_page.dart`](lib/features/auth/pages/login_page.dart)
- `AndroidManifest.xml` — `USE_BIOMETRIC`, `USE_FINGERPRINT`
- `MainActivity.kt` — `FlutterFragmentActivity`
- `build.gradle.kts` — `minSdk = 23`

---

## Database Architecture

**Filename:** `nusafit.db` (version 1)

**Tables:**
- `users` — id, username, password_hash, password_salt, role, biometric_enabled, is_active, created_at, updated_at
- `bmi_records` — id, user_id, name, age, weight_kg, height_cm, bmi, category, created_at, updated_at (FK → users ON DELETE CASCADE)

**Chain:**

```
SQLite File → DatabaseHelper → MigrationV1 → Repository → Model → Controller → Page
```

---

## Design System

File desain global di `lib/core/constants/`:

| File | Purpose |
|---|---|
| `app_colors.dart` | Primary gradient (#114177 → #006A9A → #17A18A), background #EEEEEE, surface #FFFFFF, text #1F2937, success/warning/danger colors |
| `app_dimensions.dart` | Spacing 8pt grid, padding, radius, touch target |
| `app_strings.dart` | Text konstan |
| `app_routes.dart` | Route name constants |

**DESIGN ≠ DOMAIN.** Contoh: `BmiCategory` bilang "overweight", design system bilang "tampilkan dengan warna merah".

---

## Android Platform Integration

| File | Purpose |
|---|---|
| `AndroidManifest.xml` | Permissions `USE_BIOMETRIC`, `USE_FINGERPRINT`, label NusaFit |
| `MainActivity.kt` | `FlutterFragmentActivity` (dibutuhkan BiometricPrompt) |
| `build.gradle.kts` | `minSdk = 23` |

---

## Where Do I Change Something?

| I Want To Change | Primary File | Also Check | Do NOT Change |
|---|---|---|---|
| BMI formula | [`bmi_calculator.dart`](lib/core/domain/bmi_calculator.dart) | BMI tests | Page/UI |
| BMI category | [`bmi_category.dart`](lib/core/domain/bmi_category.dart) | BMI tests | Database schema |
| BMI form validation | `validators.dart` | Validator tests | Controllers |
| BMI visual style | Design tokens / BMI Page | — | Domain/Repository |
| BMI history query | `bmi_repository.dart` | BMI repository tests | UI files |
| BMI edit behavior | `bmi_edit_controller.dart` | BMI edit tests | — |
| Database schema | `migration_v1.dart` | Database tests | — |
| Database filename | `database_helper.dart` | — | — |
| Admin account seed | `admin_seed.dart` | Admin seed tests | — |
| Password hashing | `password_service.dart` | Password tests | — |
| Login authentication | `auth_repository.dart` | Auth tests | — |
| Session duration | `session_service.dart` | Session tests, MainShell timer | MainShell independent timeout |
| Biometric logic | `biometric_service.dart` | Biometric tests | — |
| Biometric UI | LoginPage | — | — |
| Home cards | `home_page.dart` | — | — |
| Bottom nav | `main_shell.dart` | — | — |
| Global colors | `app_colors.dart` | — | — |
| Members | `members_page.dart` | `member_data.dart` | — |
| Date Converter | `date_converter_page.dart` | Controller, calculators | — |
| Age calculation | `age_calculator.dart` | Age tests | DateConverterPage |
| Hijri conversion | `hijri_converter.dart` | Hijri tests | — |
| Weton | `weton_calculator.dart` | Calendar tests | — |
| Saka Bali | `bali_calendar_converter.dart` | Calendar tests | — |
| Stopwatch logic | `stopwatch_controller.dart` | Stopwatch tests | — |
| Stopwatch UI | `stopwatch_page.dart` | — | — |
| Logout navigation | `main.dart`, `main_shell.dart` | SessionService | — |
| Android biometric permissions | `AndroidManifest.xml` | `MainActivity.kt`, `build.gradle.kts` | — |

---

## Debugging Guide

### LOGIN ERROR
`LoginPage` → `LoginController` → `AuthRepository` → `PasswordService` → `users` table

### SESSION DISAPPEARS
`LoginController` → `UserSession` → `SessionService` → `SplashPage/MainShell`

### BMI VALUE WRONG
`BmiCalculatorPage` → `BmiCalculatorController` → `BmiCalculator` → `BmiCategory`

### BMI NOT SAVED
`BmiResultPage` → `BmiCalculatorController` → `BmiRepository` → `DatabaseHelper` → `bmi_records`

### DATE WRONG
`DateConverterPage` → `DateConverterController` → `AgeCalculator` / `HijriConverter`

### WETON WRONG
`NusantaraCalendarPage` → `NusantaraCalendarController` → `WetonCalculator`

### STOPWATCH DOES NOT UPDATE
`StopwatchPage` → `StopwatchController` → Timer/elapsed logic

### UI RED ERROR / PROVIDER
`Page` → Provider import → pubspec dependency → Controller ChangeNotifier

---

## Source of Truth

| Information | Source of Truth |
|---|---|
| Logged-in session | `SessionService` + secure storage |
| Account data | SQLite `users` |
| Biometric preference | `users.biometric_enabled` |
| BMI records | SQLite `bmi_records` |
| BMI formula | `BmiCalculator` |
| BMI category | `BmiCategory` |
| Age calculation | `AgeCalculator` |
| Hijri conversion | `HijriConverter` |
| Weton calculation | `WetonCalculator` |
| Saka calculation | `BaliCalendarConverter` |
| Stopwatch runtime state | `StopwatchController` |
| Current navigation tab | `MainShell` |
| Global colors | `app_colors.dart` |
| Project implementation status | `AI_STATE.md` |

---

## Developer Ownership

### Developer 1 (Dito)
- Database infrastructure & migrations
- Security: PasswordService, SessionService, BiometricService
- Auth repository & models
- Auth UI: SplashPage, LoginPage, LoginController
- BMI domain, repository, full CRUD
- Android biometric configuration

### Developer 2
- MainShell, Home, BottomNavigation
- Members, Date Converter, Calendar, Stopwatch, Panduan
- Global design system & shared widgets
- Final UI integration & logout navigation

---

## Shared Contracts

Dev 1 Provides ↔ Dev 2 Consumes:
- Authenticated User (via `AuthContract`)
- `SessionService` (session CRUD, expiry check, clear)
- Session expiry / hard timeout
- Logout (clear session + navigate)
- BMI page constructors (accept `User`)
- Biometric state (`users.biometric_enabled`)

---

## Testing Map

| Test File | Production Component | Test Type |
|---|---|---|
| `database_helper_test.dart` | DatabaseHelper, MigrationV1 | SQLite/Repository |
| `admin_seed_test.dart` | AdminSeed | Integration |
| `password_service_test.dart` | PasswordService | Unit |
| `session_service_test.dart` | SessionService, UserSession | Unit |
| `biometric_service_test.dart` | BiometricService | Unit |
| `sanitizer_test.dart` | Sanitizers | Unit |
| `validator_test.dart` | Validators | Unit |
| `bmi_calculator_test.dart` | BmiCalculator, BmiCategory | Unit |
| `auth_repository_test.dart` | AuthRepository | Repository/SQLite |
| `bmi_repository_test.dart` | BmiRepository | Repository/SQLite |
| `login_controller_test.dart` | LoginController | Unit |
| `login_page_test.dart` | LoginPage | Widget |
| `splash_page_test.dart` | SplashPage | Widget |
| `bmi_calculator_controller_test.dart` | BmiCalculatorController | Unit |
| `bmi_pages_test.dart` | BmiCalculatorPage, BmiResultPage | Widget |
| `bmi_history_controller_test.dart` | BmiHistoryController | Unit |
| `bmi_edit_controller_test.dart` | BmiEditController | Unit |
| `bmi_history_pages_test.dart` | BmiHistoryPage, BmiDetailPage, BmiEditPage | Widget |

---

## Dependency Map

| Package | Purpose | Main Files |
|---|---|---|
| `sqflite` | Android runtime SQLite | DatabaseHelper, Repositories |
| `path` | Database path | DatabaseHelper |
| `pointycastle` | PBKDF2 hashing | PasswordService |
| `flutter_secure_storage` | Encrypted session storage | SessionService |
| `local_auth` | Biometric auth | BiometricService |
| `provider` | State management | DateConverter, Calendar, Stopwatch |
| `sqflite_common_ffi` | Host test SQLite (dev) | Tests |

---

## Glossary

| Term | Meaning |
|---|---|
| Page | Screen / UI |
| Widget | Komponen UI reusable |
| Controller | State sementara + pengatur alur fitur |
| ChangeNotifier | Flutter class untuk state management |
| Provider | Package state management (ChangeNotifierProvider) |
| Model | Bentuk data |
| Repository | Akses data persistence |
| Service | Layanan khusus (security, session, biometric) |
| Domain | Business rules / pure calculation |
| Calculator | Rumus matematika murni |
| Migration | Struktur database versioning |
| DatabaseHelper | Lifecycle SQLite singleton |
| MainShell | Container utama setelah login |
| Secure Storage | FlutterSecureStorage (encrypted) |
| SQLite | Database lokal |
| Lifecycle | Siklus hidup app/page |
| Navigator | Navigasi Flutter |
| Future | Async result |
| async/await | Non-blocking I/O |

---

## Naming Conventions

| Pattern | Artinya |
|---|---|
| `*_page.dart` | Screen / UI |
| `*_controller.dart` | State + orchestrasi |
| `*_repository.dart` | Persistence / data access |
| `*_service.dart` | Specialized service |
| `*_calculator.dart` | Pure calculation |
| `*_model.dart` / `models/*.dart` | Data structure |
| `*_test.dart` | Automated verification |

---

## Temporary / Legacy Components

| Component | Status |
|---|---|
| `_TempDev1App` | LEGACY / REMOVED — `NusaFitApp` sekarang di `main.dart` |

---

## AI / Project Documentation

| File | Purpose |
|---|---|
| [`agent.md`](agent.md) | Mandatory AI agent instructions |
| [`AI_CONTEXT.md`](AI_CONTEXT.md) | Project requirements cache |
| [`AI_STATE.md`](AI_STATE.md) | Current implementation state |
| [`PRODUCTION_SPLIT_2_PERSON.md`](PRODUCTION_SPLIT_2_PERSON.md) | Dev1/Dev2 split documentation |
| `md/PRD_NusaFit_Lengkap.md` | Product requirements |
| `md/DESIGN_SYSTEM.md` | Design tokens |
| `md/MENU_IMPLEMENTATION.md` | Menu specs |
| `md/COMPUTATION_LOGIC.md` | Calculation rules |
| `md/WRITING_RULES.md` | Coding rules |

---

## Current Status

- **App bootstrap:** `NusaFitApp` di `lib/main.dart` → SplashPage → MainShell
- **MainShell:** IMPLEMENTED dengan 4 bottom nav items (Home, Stopwatch, Panduan, Logout)
- **Home:** 5 menu lengkap, BMI terhubung ke Dev1 implementation
- **Dev1 features:** IMPLEMENTED (auth, session, biometric, BMI full CRUD, database, security)
- **Dev2 features:** IMPLEMENTED (MainShell, Home, Date Converter, Calendar, Stopwatch, Members, Panduan)
- **Static analysis:** 0 issues
- **Tests:** 213 passing tests

---

## Broken Relative Links

0 broken links.

---

## Production Source Modification Audit

- README modified: YES
- Production source modified: NO

---

## Inconsistencies Discovered

NONE

---

README NOW EXPLAINS HOW NUSAFIT ACTUALLY WORKS

**LIB FOLDER MAP READY**