# NusaFit — Deep Source-Code Architecture & Technical Blueprint

Welcome to the **NusaFit** codebase architectural guide. This document provides a complete, human-readable blueprint of the repository's source code, data flow, security model, and structural responsibilities.

---

## 1. Project Overview

**NusaFit** is an offline-first mobile application built with **Flutter** (Dart `^3.10.8`) targeting Android (minimum SDK 23 for native biometric support). It combines modern personal health tracking (BMI calculation and full CRUD health record management) with traditional Indonesian Nusantara calendar utilities (Hijriah, Javanese Weton, and Balinese Saka calendars) and a stopwatch.

### Key Architectural Pillars
- **Framework & Language**: Flutter / Dart `^3.10.8`.
- **Target Platform**: Android (configured with `FlutterFragmentActivity`, `minSdk = 23`, `USE_BIOMETRIC` & `USE_FINGERPRINT` permissions).
- **Offline-First Persistence**: Local SQLite database (`nusafit.db`) via `sqflite` with parameterized queries and enforced foreign keys.
- **Security & Authentication**: Cryptographically strong PBKDF2-HMAC-SHA256 password hashing (100,000 iterations), encrypted OS secure storage via `flutter_secure_storage`, native biometric authentication (`local_auth`), and an absolute **30-Minute Hard Session Timeout**.
- **Clean Architecture & Separation of Concerns**: Strict boundary division between Presentation (Pages/Widgets), State Management (Controllers), Pure Business Computation (Domain Calculators), Data Access (Repositories), Core Security/Persistence Services, and SQLite Database Helpers.
- **Developer Split**:
  - **Developer 1 (Dito)**: Core Infrastructure, Security Services, SQLite Database & Migrations, PBKDF2 Hashing, Secure Storage Session & 30-Minute Hard Timeout, Biometrics Integration, Authentication Repository, Auth UI (`SplashPage`, `LoginPage`), BMI Pure Mathematics Domain, BMI Repository, and Full BMI CRUD Feature Suite (`BmiCalculatorPage`, `BmiResultPage`, `BmiHistoryPage`, `BmiDetailPage`, `BmiEditPage`).
  - **Developer 2**: App Root/Shell (`MainShell`), Global Design System / UI Token Integration, Member Directory (`Daftar Anggota`), Date & Age Conversion, Hijriah & Weton / Saka Bali Calculations, Stopwatch, User Guide (`Panduan`), and Navigation Routing / Logout UI Integration.

---

## 2. Current Implementation Status

| Component / Layer | Implementation Status | Test Coverage | Verification Method |
|---|---|---|---|
| **SQLite Infrastructure & Schema** | **IMPLEMENTED** | Verified | Unit Tests & FFI SQLite (`247/247` pass) |
| **Password Security (PBKDF2)** | **IMPLEMENTED** | Verified | Unit Tests (`100,000` iterations verified) |
| **Session Security & Hard Timeout** | **IMPLEMENTED** | Verified | 30-min absolute hard timeout unit & widget tests |
| **Biometric Integration** | **IMPLEMENTED** | Verified | OS capability vs DB flag preference tests |
| **Auth Repository & Admin Seed** | **IMPLEMENTED** | Verified | Repository integration & seed tests |
| **Auth UI (Splash & Login)** | **IMPLEMENTED** | Verified | Widget tests & navigation boundary tests |
| **BMI Domain Mathematics** | **IMPLEMENTED** | Verified | Precision & boundary unit tests |
| **BMI Repository (CRUD)** | **IMPLEMENTED** | Verified | Parameterized SQL user isolation tests |
| **BMI Calculator & Result UI** | **IMPLEMENTED** | Verified | Controller & widget suite tests |
| **BMI History, Detail & Edit UI** | **IMPLEMENTED** | Verified | Full CRUD lifecycle & modal tests |
| **Android Biometric Config** | **IMPLEMENTED** | Verified | Gradle minSdk 23 & FragmentActivity verified |
| **MainShell & Bottom Nav** | **PENDING (DEV 2)** | - | Awaiting Developer 2 integration |
| **Daftar Anggota UI** | **PENDING (DEV 2)** | - | Awaiting Developer 2 integration |
| **Date / Age / Hijriah / Weton** | **PENDING (DEV 2)** | - | Awaiting Developer 2 integration |
| **Stopwatch & Panduan** | **PENDING (DEV 2)** | - | Awaiting Developer 2 integration |
| **Temporary Root (`_TempDev1App`)** | **TEMPORARY** | Verified | Dev 1 entry point in [`lib/main.dart`](lib/main.dart) |

- **Total Project Tests**: `247` passing tests across `18` test suites.
- **Static Analysis**: `flutter analyze` passes with zero errors and zero warnings.

---

## 3. Architecture at a Glance

NusaFit strictly enforces unidirectional data flow and clean architectural boundaries.

```
UI Layer (Pages / Widgets)
       │
       ▼ (User Interactions / Form Data)
Controller Layer (State Management / Validation Calls)
       │
       ├─────────────────────────┬─────────────────────────┐
       ▼                         ▼                         ▼
Domain Layer             Repository Layer          Security Services
(Pure Math Calculations)  (SQLite Data Access)      (PBKDF2 / Session / Bio)
                                 │                         │
                                 ▼                         ▼
                           DatabaseHelper           Secure Storage / OS
                                 │                         │
                                 ▼                         ▼
                           SQLite Database           Encrypted Storage
```

### Detailed Execution Pipelines

#### 1. Authentication Pipeline
```
[LoginPage] ──(raw form text)──► [LoginController] ──(sanitized input)──► [AuthRepository]
                                                                               │
                                                      (stored hash/salt) ◄─────┴─────► (PBKDF2 Hash Verification)
                                                                                            [PasswordService]
                                                                                                   │
[SplashPage] ◄──(Session Expiry Gate)── [SessionService] ◄──(UserSession)── [LoginController] ◄────┘
     │
     └──► [AuthContract] ──(Authenticated User)──► [Developer 2 Destination]
```

#### 2. BMI Calculation & Persistence Pipeline
```
[BmiCalculatorPage] ──► [BmiCalculatorController] ──► [Validators / Sanitizers]
                                │
                                ▼
                       [BmiCalculator (Math)] ──► [BmiCategory]
                                │
                                ▼
                       [BmiResultPage] ──► [BmiRepository] ──► [SQLite (bmi_records)]
```

### Layer Boundary Rules

1. **Widget / Page Layer**:
   - **MUST**: Render UI elements, handle user gesture events, invoke Controller methods, and trigger Flutter navigation (`Navigator.push`, `pop`, `pushReplacement`).
   - **MUST NOT**: Perform mathematical computations, execute SQL statements, hash passwords, or directly invoke `FlutterSecureStorage`.
2. **Controller Layer**:
   - **MUST**: Hold ephemeral form state, orchestrate calls between Domain/Validators/Repositories, update `loading` and `error` states, and call `notifyListeners()`.
   - **MUST NOT**: Render Flutter UI widgets, directly query SQLite tables, or execute raw platform calls without services.
3. **Domain Layer**:
   - **MUST**: Perform pure, deterministic mathematical computations (e.g., raw BMI formula, category boundary evaluation).
   - **MUST NOT**: Import `package:flutter/material.dart`, execute asynchronous I/O, access database, or depend on controllers.
4. **Repository Layer**:
   - **MUST**: Encapsulate all database queries (`db.query`, `db.insert`, `db.update`, `db.delete`), enforce SQL parameterization (`whereArgs`), and enforce user isolation by scoping queries by `user_id`.
   - **MUST NOT**: Contain UI code, handle Flutter form state, or manage session life cycles.
5. **Service Layer**:
   - **MUST**: Provide specialized security, encryption, session persistence, and hardware platform abstractions (`SessionService`, `PasswordService`, `BiometricService`).
   - **MUST NOT**: Contain UI rendering code or navigation logic.
6. **Database Layer**:
   - **MUST**: Manage SQLite database lifecycle, connection singletons, migration execution, and initial data seeding (`DatabaseHelper`, `MigrationV1`, `AdminSeed`).

---

## 4. Project Directory Structure

```
mobile_kalku/
├── lib/
│   ├── main.dart                                      # Temporary bootstrap app (_TempDev1App)
│   │
│   ├── core/
│   │   ├── database/
│   │   │   ├── admin_seed.dart                       # Idempotent default admin user seed ('tofik' / '123')
│   │   │   ├── database_helper.dart                   # SQLite database connection & lifecycle manager
│   │   │   └── migrations/
│   │   │       └── migration_v1.dart                  # Initial schema migration (users, bmi_records, indexes)
│   │   │
│   │   ├── domain/
│   │   │   ├── auth_result.dart                       # Authentication status enum & result wrapper
│   │   │   ├── biometric_result.dart                  # Biometric status enum & operation result wrapper
│   │   │   ├── bmi_calculation_result.dart            # Immutable BMI computation output holder
│   │   │   ├── bmi_calculator.dart                    # Pure mathematical BMI calculation domain engine
│   │   │   └── bmi_category.dart                      # Canonical BMI category enum & boundary definitions
│   │   │
│   │   ├── errors/
│   │   │   ├── app_exception.dart                     # Base application exception class
│   │   │   ├── authentication_failure.dart            # Authentication domain error class
│   │   │   ├── biometric_failure.dart                 # Biometric hardware error class
│   │   │   ├── database_failure.dart                  # SQLite database error class
│   │   │   ├── failure.dart                           # Abstract base failure class
│   │   │   └── validation_failure.dart                # Input validation error class
│   │   │
│   │   ├── security/
│   │   │   ├── auth_contract.dart                     # AuthenticatedPageBuilder signature definition
│   │   │   ├── biometric_service.dart                 # LocalAuthentication plugin wrapper & capability service
│   │   │   ├── password_service.dart                  # PBKDF2-HMAC-SHA256 password hashing & verification
│   │   │   └── session_service.dart                   # Secure storage session persistence & 30-min hard timeout
│   │   │
│   │   └── utils/
│   │       ├── sanitizers.dart                        # String trimming & whitespace normalization utilities
│   │       └── validators.dart                        # Comprehensive form input validation rules
│   │
│   ├── data/
│   │   ├── models/
│   │   │   ├── bmi_record.dart                        # Immutable BMI record model (SQLite map mapping)
│   │   │   ├── user.dart                              # Immutable User model (SQLite map mapping)
│   │   │   └── user_session.dart                      # Secure session model (storage map serialization)
│   │   │
│   │   └── repositories/
│   │       ├── auth_repository.dart                   # User authentication & credentials repository
│   │       └── bmi_repository.dart                    # User-isolated BMI record CRUD repository
│   │
│   └── features/
│       ├── auth/
│       │   ├── controller/
│       │   │   └── login_controller.dart              # Login state management & biometric authentication coordinator
│       │   └── pages/
│       │       ├── login_page.dart                    # Credential & biometric login user interface
│       │       └── splash_page.dart                   # Application bootstrap, admin seed & session gate
│       │
│       └── bmi/
│           ├── controllers/
│           │   ├── bmi_calculator_controller.dart     # Calculator form state & save lifecycle coordinator
│           │   ├── bmi_edit_controller.dart           # Record editing & recalculated state coordinator
│           │   └── bmi_history_controller.dart        # History list fetching & deletion coordinator
│           │
│           └── pages/
│               ├── bmi_calculator_page.dart           # BMI input form page
│               ├── bmi_detail_page.dart               # Detailed view page for saved BMI record
│               ├── bmi_edit_page.dart                 # Edit form page for existing BMI record
│               ├── bmi_history_page.dart              # Historical list view page with pull-to-refresh
│               └── bmi_result_page.dart               # Calculation result display & save action page
│
├── test/
│   ├── core/
│   │   ├── database/
│   │   │   ├── admin_seed_test.dart                   # AdminSeed idempotency unit tests
│   │   │   └── database_helper_test.dart              # SQLite schema, PRAGMA & foreign key tests
│   │   ├── domain/
│   │   │   └── bmi_calculator_test.dart               # Mathematical BMI & category boundary unit tests
│   │   ├── security/
│   │   │   ├── biometric_service_test.dart            # Biometric service & preference state tests
│   │   │   ├── password_service_test.dart             # PBKDF2 hashing & verification unit tests
│   │   │   └── session_service_test.dart              # Session storage, 30-min hard timeout & boundary tests
│   │   └── utils/
│   │       ├── sanitizer_test.dart                    # Sanitization utility unit tests
│   │       └── validator_test.dart                    # Validation rules unit tests
│   ├── data/
│   │   └── repositories/
│   │       ├── auth_repository_test.dart              # Auth repository SQL & injection prevention tests
│   │       └── bmi_repository_test.dart               # BMI repository CRUD & user isolation tests
│   └── features/
│       ├── auth/
│       │   ├── login_controller_test.dart             # Login controller state & auth flow tests
│       │   ├── login_page_test.dart                   # Login page rendering & interaction tests
│       │   └── splash_page_test.dart                  # Splash page initialization & session expiry tests
│       └── bmi/
│           ├── bmi_calculator_controller_test.dart    # Calculator controller unit tests
│           ├── bmi_edit_controller_test.dart          # Edit controller unit tests
│           ├── bmi_history_controller_test.dart       # History controller unit tests
│           ├── bmi_history_pages_test.dart            # History, Detail & Edit widget tests
│           └── bmi_pages_test.dart                    # Calculator & Result page widget tests
│
├── android/
│   └── app/
│       ├── build.gradle.kts                           # App build config (minSdk = 23)
│       └── src/main/
│           ├── AndroidManifest.xml                    # Manifest permissions (USE_BIOMETRIC, USE_FINGERPRINT)
│           └── kotlin/com/example/mobile_kalku/
│               └── MainActivity.kt                    # FlutterFragmentActivity entry point for biometrics
│
└── md/                                                # Project specifications & guidelines
    ├── COMPUTATION_LOGIC.md
    ├── DESIGN_SYSTEM.md
    ├── MENU_IMPLEMENTATION.md
    ├── PRD_NusaFit_Lengkap.md
    ├── README_AI_GUIDE.md
    └── WRITING_RULES.md
```

---

## 5. Layer Responsibilities

```
┌─────────────────────────────────────────────────────────────────────────┐
│                           PRESENTATION LAYER                            │
│  Pages / Screens: SplashPage, LoginPage, BmiCalculatorPage, etc.       │
└────────────────────────────────────┬────────────────────────────────────┘
                                     │
                                     ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                        STATE MANAGEMENT LAYER                           │
│  Controllers: LoginController, BmiCalculatorController, etc.            │
└────────────────────────────────────┬────────────────────────────────────┘
                                     │
            ┌────────────────────────┼────────────────────────┐
            ▼                        ▼                        ▼
┌───────────────────────┐┌───────────────────────┐┌───────────────────────┐
│     DOMAIN LAYER      ││   REPOSITORY LAYER    ││    SECURITY LAYER     │
│ BmiCalculator         ││ AuthRepository        ││ SessionService        │
│ BmiCategory           ││ BmiRepository         ││ PasswordService       │
│ Validators/Sanitizers ││                       ││ BiometricService      │
└───────────────────────┘└───────────┬───────────┘└───────────┬───────────┘
                                     │                        │
                                     ▼                        ▼
                        ┌───────────────────────┐┌───────────────────────┐
                        │    DATABASE LAYER     ││   PERSISTENCE / OS    │
                        │ DatabaseHelper        ││ FlutterSecureStorage  │
                        │ MigrationV1           ││ LocalAuthentication  │
                        └───────────────────────┘└───────────────────────┘
```

---

## 6. Home Menu → Implementation Map

NusaFit features five primary Home menu modules:

| Menu Entry | Purpose | Status | Owner | Entry Page / Controller | Primary Files |
|---|---|---|---|---|---|
| **1. Daftar Anggota** | Member directory & management | **PENDING** | Developer 2 | Pending | Uses `users` table; UI pending Dev 2 |
| **2. Kalkulator BMI** | BMI input form & calculation | **IMPLEMENTED** | Developer 1 | [`BmiCalculatorPage`](lib/features/bmi/pages/bmi_calculator_page.dart) | [`BmiCalculatorPage`](lib/features/bmi/pages/bmi_calculator_page.dart), [`BmiCalculatorController`](lib/features/bmi/controllers/bmi_calculator_controller.dart), [`BmiCalculator`](lib/core/domain/bmi_calculator.dart), [`BmiCategory`](lib/core/domain/bmi_category.dart), [`BmiResultPage`](lib/features/bmi/pages/bmi_result_page.dart), [`BmiRepository`](lib/data/repositories/bmi_repository.dart) |
| **3. BMI History / CRUD** | History listing, detail, edit, delete | **IMPLEMENTED** | Developer 1 | [`BmiHistoryPage`](lib/features/bmi/pages/bmi_history_page.dart) | [`BmiHistoryPage`](lib/features/bmi/pages/bmi_history_page.dart), [`BmiHistoryController`](lib/features/bmi/controllers/bmi_history_controller.dart), [`BmiDetailPage`](lib/features/bmi/pages/bmi_detail_page.dart), [`BmiEditPage`](lib/features/bmi/pages/bmi_edit_page.dart), [`BmiEditController`](lib/features/bmi/controllers/bmi_edit_controller.dart), [`BmiRepository`](lib/data/repositories/bmi_repository.dart) |
| **4. Date Conversion & Age** | Gregorian, Hijriah & Age converter | **PENDING** | Developer 2 | Pending | Calculation engine & UI pending Dev 2 |
| **5. Weton & Saka Bali** | Javanese Weton & Balinese Saka calendar | **PENDING** | Developer 2 | Pending | Calculation engine & UI pending Dev 2 |

---

## 7. Bottom Navigation → Implementation Map

| Bottom Nav Item | Owner | Target Component | Service / Controller Dependencies | Persistence / Session Behavior |
|---|---|---|---|---|
| **Home** | Dev 2 | `MainShell` Home Tab | Dashboard Controller / Menu Navigation | Renders 5 menu entry cards |
| **Stopwatch** | Dev 2 | `StopwatchPage` (Pending) | Timer State Controller | Ephemeral timer state |
| **Panduan** | Dev 2 | `PanduanPage` (Pending) | Static Guide Controller | Read-only static user guide |
| **Logout** | Dev 1 & 2 | Logout Button / Dialog | [`SessionService.clearSession()`](lib/core/security/session_service.dart#L168-L179) | **Dev 1**: Clears secure session keys.<br>**Dev 2**: Triggers `Navigator.pushAndRemoveUntil` to `LoginPage`. |

---

## 8. Authentication Architecture

The Authentication suite consists of 13 dedicated files:

1. **[`User`](lib/data/models/user.dart)**: Domain entity representing a user database record (`id`, `username`, `passwordHash`, `passwordSalt`, `role`, `biometricEnabled`, `isActive`, `createdAt`, `updatedAt`).
2. **[`UserSession`](lib/data/models/user_session.dart)**: Lightweight model for active session state in secure storage (`userId`, `username`, `role`, `isLoggedIn`, `authenticatedAt`, `expiresAt`).
3. **[`AuthResult`](lib/core/domain/auth_result.dart)**: Result object wrapping `AuthStatus` enum (`success`, `invalidCredentials`, `inactiveUser`).
4. **[`AuthRepository`](lib/data/repositories/auth_repository.dart)**: SQLite authentication queries (`login`, `findUserByUsername`, `findUserById`, `setBiometricEnabled`).
5. **[`PasswordService`](lib/core/security/password_service.dart)**: PBKDF2-HMAC-SHA256 password hashing (100,000 iterations, 128-bit salt, 256-bit derived key).
6. **[`SessionService`](lib/core/security/session_service.dart)**: Encrypted `FlutterSecureStorage` wrapper for session CRUD and 30-minute hard timeout evaluation.
7. **[`BiometricService`](lib/core/security/biometric_service.dart)**: Hardware biometric availability checker & OS authentication invoker (`LocalAuthentication`).
8. **[`BiometricAuthResult`](lib/core/domain/biometric_result.dart)**: Result wrapper for biometric operations (`BiometricStatus`).
9. **[`LoginController`](lib/features/auth/controller/login_controller.dart)**: Presentation state coordinator for credential and biometric login.
10. **[`LoginPage`](lib/features/auth/pages/login_page.dart)**: UI form for username/password login and fingerprint/face login trigger.
11. **[`SplashPage`](lib/features/auth/pages/splash_page.dart)**: Initial entry screen, SQLite initialization, admin seeding, and hard-timeout session validation gate.
12. **[`AuthContract`](lib/core/security/auth_contract.dart)**: Function signature definition (`AuthenticatedPageBuilder`) for handing off authenticated `User` context to Dev 2.
13. **[`AdminSeed`](lib/core/database/admin_seed.dart)**: Idempotent database seeder ensuring default admin account (`tofik` / `123`) exists.

---

## 9. Session Architecture

### Session Data & Storage Key Mapping

All session keys are namespaced under `nusafit_session_*` in `FlutterSecureStorage`:

```
nusafit_session_userId           ──► "1"
nusafit_session_username         ──► "tofik"
nusafit_session_role             ──► "admin"
nusafit_session_isLoggedIn       ──► "true"
nusafit_session_authenticatedAt  ──► "2026-09-16T10:00:00.000Z" (UTC ISO-8601)
nusafit_session_expiresAt        ──► "2026-09-16T10:30:00.000Z" (UTC ISO-8601)
```

> [!IMPORTANT]
> **What is NOT stored in Secure Storage**: Plaintext passwords, password hashes, salts, or biometric template data.

### 30-Minute Absolute Hard Timeout Rules
1. **Absolute Lifetime**: Expiration is calculated as `authenticatedAt + 30 minutes`.
2. **No Extension**: Continuous user activity **MUST NOT** reset or extend `expiresAt`.
3. **Boundary Condition**: At exact boundary `now >= expiresAt`, `isSessionExpired()` returns `true`.
4. **Foreground / Resume Check**: When the app returns from background (`AppLifecycleState.resumed`), Dev 2 must check `isSessionExpired()` and force logout if true.

---

## 10. Session Data Flow Diagram

```
================================================================================
                               1. LOGIN FLOW
================================================================================
[LoginPage]
    │ (raw username & password)
    ▼
[LoginController]
    │ (sanitized username & password)
    ▼
[AuthRepository.login()] ──► Query SQLite 'users' ──► [PasswordService.verify()]
    │                                                          │
    ▼ (valid User)                                             ▼ (hash match)
[LoginController]
    │ (constructs UserSession: authenticatedAt = now, expiresAt = now + 30m)
    ▼
[SessionService.saveSession()] ──► [FlutterSecureStorage (nusafit_session_*)]
    │
    ▼
[AuthContract] ──(Authenticated User)──► [Developer 2 MainShell]


================================================================================
                               2. APP REOPEN FLOW
================================================================================
[SplashPage]
    │
    ▼
[SessionService.readSession()]
    │
    ├─────────────► Null / Corrupt Session ──────► Clear Storage ──► [LoginPage]
    │
    ▼ (Valid UserSession)
[SessionService.isSessionExpired()]
    │
    ├─────────────► True (Expired >= 30m) ───────► Clear Storage ──► [LoginPage]
    │
    ▼ (False - Unexpired)
Query SQLite 'users' by userId ──► Found & Active ──► [AuthenticatedPageBuilder]
                                                             │
                                                             ▼
                                                    [Developer 2 MainShell]
```

---

## 11. Biometric Architecture

NusaFit distinguishes between three distinct biometric concepts:

```
┌─────────────────────────┐     ┌─────────────────────────┐     ┌─────────────────────────┐
│  1. OS Capability       │     │  2. NusaFit Preference  │     │  3. Active Session      │
│  Does device hardware   │ ──► │  Is biometric_enabled=1 │ ──► │  Temporary UserSession  │
│  support biometrics?    │     │  for user in SQLite?    │     │  in SecureStorage       │
└─────────────────────────┘     └─────────────────────────┘     └─────────────────────────┘
```

1. **OS Capability**: Checked via `BiometricService.getAvailability()` (`LocalAuthentication.canCheckBiometrics`).
2. **NusaFit User Preference**: Stored in SQLite `users.biometric_enabled` (Default: `0` / Disabled).
3. **Authenticated Session**: Created in `SessionService` upon successful biometric authentication.

---

## 12. Database Architecture

- **Database File**: `nusafit.db` (Managed by [`DatabaseHelper`](lib/core/database/database_helper.dart)).
- **Foreign Keys**: Enforced via `PRAGMA foreign_keys = ON` on every connection.
- **Data Isolation**: All `bmi_records` queries require `user_id = ?` parameterization.

### Table Schema

```sql
CREATE TABLE users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    username TEXT NOT NULL UNIQUE,
    password_hash TEXT NOT NULL,
    password_salt TEXT NOT NULL,
    role TEXT NOT NULL DEFAULT 'user',
    biometric_enabled INTEGER NOT NULL DEFAULT 0,
    is_active INTEGER NOT NULL DEFAULT 1,
    created_at TEXT NOT NULL,
    updated_at TEXT NOT NULL
);

CREATE TABLE bmi_records (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,
    name TEXT NOT NULL,
    age INTEGER NOT NULL,
    weight_kg REAL NOT NULL,
    height_cm REAL NOT NULL,
    bmi REAL NOT NULL,
    category TEXT NOT NULL,
    created_at TEXT NOT NULL,
    updated_at TEXT NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE INDEX idx_bmi_records_user_id ON bmi_records(user_id);
CREATE INDEX idx_bmi_records_created_at ON bmi_records(created_at);
```

---

## 13. BMI CRUD Architecture

```
                                  BMI CRUD FLOWS
                                  ==============

    CREATE                                              READ
    ------                                              ----
[BmiCalculatorPage]                                [BmiHistoryPage]
        │                                                  │
        ▼                                                  ▼
[BmiCalculatorController]                          [BmiHistoryController]
        │                                                  │
        ▼                                                  ▼
[BmiCalculator (Math)] ──► [BmiResultPage]         [BmiRepository.getRecordsForUser()]
                               │                           │
                               ▼                           ▼
                     [BmiRepository.insertRecord()]   Displays List / [BmiDetailPage]


    UPDATE                                              DELETE
    ------                                              ------
[BmiHistoryPage] ──► Tap Edit                      [BmiHistoryPage] ──► Tap Delete
        │                                                  │
        ▼                                                  ▼
[BmiEditPage] ──► [BmiEditController]              Show Confirmation Dialog
        │                                                  │
        ▼                                                  ▼
[BmiCalculator (Recalculate)]                      [BmiHistoryController.deleteRecord()]
        │                                                  │
        ▼                                                  ▼
[BmiRepository.updateRecord()]                    [BmiRepository.deleteRecordForUser()]
        │                                                  │
        ▼                                                  ▼
Navigator.pop(context, true)                       Refresh List State
```

---

## 14. Computation Architecture & Rules Location

| Business Rule / Computation | Class / File Responsible | Input | Output | Verification Test File |
|---|---|---|---|---|
| **BMI Formula Calculation** | [`BmiCalculator`](lib/core/domain/bmi_calculator.dart) | `weightKg`, `heightCm` | `raw Bmi (double)` | [`bmi_calculator_test.dart`](test/core/domain/bmi_calculator_test.dart) |
| **BMI Category Classification** | [`BmiCategory`](lib/core/domain/bmi_category.dart) | `raw Bmi (double)` | `BmiCategory enum` | [`bmi_calculator_test.dart`](test/core/domain/bmi_calculator_test.dart) |
| **Input Limit Validation** | [`Validators`](lib/core/utils/validators.dart) | Form field values | Error message or `null` | [`validator_test.dart`](test/core/utils/validator_test.dart) |
| **String Sanitization** | [`Sanitizers`](lib/core/utils/sanitizers.dart) | Raw text input | Cleaned string | [`sanitizer_test.dart`](test/core/utils/sanitizer_test.dart) |
| **PBKDF2 Hashing** | [`PasswordService`](lib/core/security/password_service.dart) | Password, Salt | Base64 Hash string | [`password_service_test.dart`](test/core/security/password_service_test.dart) |
| **Session Expiry Calculation** | [`SessionService`](lib/core/security/session_service.dart) | `authenticatedAt`, `expiresAt` | Expiration status `bool` | [`session_service_test.dart`](test/core/security/session_service_test.dart) |
| **User Isolation Scoping** | [`BmiRepository`](lib/data/repositories/bmi_repository.dart) | `userId`, record `id` | Filtered SQL Query | [`bmi_repository_test.dart`](test/data/repositories/bmi_repository_test.dart) |

---

## 15. Navigation Architecture

| Trigger Action | Navigation Method | Source Screen | Destination Screen |
|---|---|---|---|
| **App Launch / Startup** | `Navigator.pushReplacement` | [`SplashPage`](lib/features/auth/pages/splash_page.dart) | [`LoginPage`](lib/features/auth/pages/login_page.dart) or Dev 2 `MainShell` |
| **Successful Login** | `AuthenticatedPageBuilder` | [`LoginPage`](lib/features/auth/pages/login_page.dart) | Dev 2 `MainShell` |
| **Calculate BMI** | `Navigator.push` | [`BmiCalculatorPage`](lib/features/bmi/pages/bmi_calculator_page.dart) | [`BmiResultPage`](lib/features/bmi/pages/bmi_result_page.dart) |
| **View History Record** | `Navigator.push` | [`BmiHistoryPage`](lib/features/bmi/pages/bmi_history_page.dart) | [`BmiDetailPage`](lib/features/bmi/pages/bmi_detail_page.dart) |
| **Edit History Record** | `Navigator.push` | [`BmiHistoryPage`](lib/features/bmi/pages/bmi_history_page.dart) | [`BmiEditPage`](lib/features/bmi/pages/bmi_edit_page.dart) |
| **Save Edited Record** | `Navigator.pop(context, true)` | [`BmiEditPage`](lib/features/bmi/pages/bmi_edit_page.dart) | [`BmiHistoryPage`](lib/features/bmi/pages/bmi_history_page.dart) (triggers refresh) |
| **Logout** | `Navigator.pushAndRemoveUntil` | `MainShell` (Dev 2) | [`LoginPage`](lib/features/auth/pages/login_page.dart) |

---

## 16. Android Platform Architecture

- **[`AndroidManifest.xml`](android/app/src/main/AndroidManifest.xml)**: Declares Android permissions (`USE_BIOMETRIC`, `USE_FINGERPRINT`) and sets label to `NusaFit`.
- **[`MainActivity.kt`](android/app/src/main/kotlin/com/example/mobile_kalku/MainActivity.kt)**: Extends `FlutterFragmentActivity` (required by Android OS for BiometricPrompt dialogs).
- **[`build.gradle.kts`](android/app/build.gradle.kts)**: Configures `minSdk = 23` (required for Android Biometric API).

---

## 17. Testing Architecture

| Test Suite File | Production Files Verified | Test Type | Coverage Focus |
|---|---|---|---|
| [`database_helper_test.dart`](test/core/database/database_helper_test.dart) | [`DatabaseHelper`](lib/core/database/database_helper.dart), [`MigrationV1`](lib/core/database/migrations/migration_v1.dart) | Repository / SQLite | Table schemas, PRAGMA foreign keys, SQLite FFI |
| [`admin_seed_test.dart`](test/core/database/admin_seed_test.dart) | [`AdminSeed`](lib/core/database/admin_seed.dart) | Integration | Default admin creation, idempotency |
| [`password_service_test.dart`](test/core/security/password_service_test.dart) | [`PasswordService`](lib/core/security/password_service.dart) | Unit | PBKDF2 100,000 iterations, salt generation, verification |
| [`session_service_test.dart`](test/core/security/session_service_test.dart) | [`SessionService`](lib/core/security/session_service.dart), [`UserSession`](lib/data/models/user_session.dart) | Unit | Secure storage CRUD, 30-min hard timeout, boundary tests |
| [`biometric_service_test.dart`](test/core/security/biometric_service_test.dart) | [`BiometricService`](lib/core/security/biometric_service.dart) | Unit | Hardware availability, status mapping, preference flag |
| [`sanitizer_test.dart`](test/core/utils/sanitizer_test.dart) | [`Sanitizers`](lib/core/utils/sanitizers.dart) | Unit | String whitespace trimming & normalization |
| [`validator_test.dart`](test/core/utils/validator_test.dart) | [`Validators`](lib/core/utils/validators.dart) | Unit | Username, password, age, weight, height boundary validation |
| [`bmi_calculator_test.dart`](test/core/domain/bmi_calculator_test.dart) | [`BmiCalculator`](lib/core/domain/bmi_calculator.dart), [`BmiCategory`](lib/core/domain/bmi_category.dart) | Unit | Math formula precision, category ranges, invalid input handling |
| [`auth_repository_test.dart`](test/data/repositories/auth_repository_test.dart) | [`AuthRepository`](lib/data/repositories/auth_repository.dart) | Repository / SQLite | SQL parameterization, injection safety, credential lookup |
| [`bmi_repository_test.dart`](test/data/repositories/bmi_repository_test.dart) | [`BmiRepository`](lib/data/repositories/bmi_repository.dart) | Repository / SQLite | CRUD operations, strict user_id data isolation |
| [`login_controller_test.dart`](test/features/auth/login_controller_test.dart) | [`LoginController`](lib/features/auth/controller/login_controller.dart) | Unit | Credential & biometric login state management |
| [`login_page_test.dart`](test/features/auth/login_page_test.dart) | [`LoginPage`](lib/features/auth/pages/login_page.dart) | Widget | Form rendering, error banner display, validation triggers |
| [`splash_page_test.dart`](test/features/auth/splash_page_test.dart) | [`SplashPage`](lib/features/auth/pages/splash_page.dart) | Widget | Initialization, admin seed trigger, hard timeout redirect |
| [`bmi_calculator_controller_test.dart`](test/features/bmi/bmi_calculator_controller_test.dart) | [`BmiCalculatorController`](lib/features/bmi/controllers/bmi_calculator_controller.dart) | Unit | Calculator form state, calculation trigger, save lifecycle |
| [`bmi_pages_test.dart`](test/features/bmi/bmi_pages_test.dart) | [`BmiCalculatorPage`](lib/features/bmi/pages/bmi_calculator_page.dart), [`BmiResultPage`](lib/features/bmi/pages/bmi_result_page.dart) | Widget | Calculator form inputs, navigation to result, save action |
| [`bmi_history_controller_test.dart`](test/features/bmi/bmi_history_controller_test.dart) | [`BmiHistoryController`](lib/features/bmi/controllers/bmi_history_controller.dart) | Unit | Record list state, pull-to-refresh, record deletion |
| [`bmi_edit_controller_test.dart`](test/features/bmi/bmi_edit_controller_test.dart) | [`BmiEditController`](lib/features/bmi/controllers/bmi_edit_controller.dart) | Unit | Edit form state, recalculation, update persistence |
| [`bmi_history_pages_test.dart`](test/features/bmi/bmi_history_pages_test.dart) | [`BmiHistoryPage`](lib/features/bmi/pages/bmi_history_page.dart), [`BmiDetailPage`](lib/features/bmi/pages/bmi_detail_page.dart), [`BmiEditPage`](lib/features/bmi/pages/bmi_edit_page.dart) | Widget | History list, detail view, edit form submission & dialogs |

---

## 18. Developer 1 / Developer 2 Ownership

### Developer 1 (Dito) — COMPLETE
- Database Infrastructure & Migrations ([`DatabaseHelper`](lib/core/database/database_helper.dart), [`MigrationV1`](lib/core/database/migrations/migration_v1.dart), [`AdminSeed`](lib/core/database/admin_seed.dart))
- Security & Password Hashing ([`PasswordService`](lib/core/security/password_service.dart))
- Secure Storage & 30-Minute Hard Session Timeout ([`SessionService`](lib/core/security/session_service.dart), [`UserSession`](lib/data/models/user_session.dart))
- Native Biometric Integration ([`BiometricService`](lib/core/security/biometric_service.dart))
- Authentication Repository & Models ([`AuthRepository`](lib/data/repositories/auth_repository.dart), [`User`](lib/data/models/user.dart))
- Auth Presentation Suite ([`SplashPage`](lib/features/auth/pages/splash_page.dart), [`LoginPage`](lib/features/auth/pages/login_page.dart), [`LoginController`](lib/features/auth/controller/login_controller.dart))
- BMI Domain Computation ([`BmiCalculator`](lib/core/domain/bmi_calculator.dart), [`BmiCategory`](lib/core/domain/bmi_category.dart))
- BMI Data Repository ([`BmiRepository`](lib/data/repositories/bmi_repository.dart), [`BmiRecord`](lib/data/models/bmi_record.dart))
- Full BMI Presentation Suite ([`BmiCalculatorPage`](lib/features/bmi/pages/bmi_calculator_page.dart), [`BmiResultPage`](lib/features/bmi/pages/bmi_result_page.dart), [`BmiHistoryPage`](lib/features/bmi/pages/bmi_history_page.dart), [`BmiDetailPage`](lib/features/bmi/pages/bmi_detail_page.dart), [`BmiEditPage`](lib/features/bmi/pages/bmi_edit_page.dart))
- Android Native Biometric Configuration ([`MainActivity.kt`](android/app/src/main/kotlin/com/example/mobile_kalku/MainActivity.kt), [`AndroidManifest.xml`](android/app/src/main/AndroidManifest.xml), [`build.gradle.kts`](android/app/build.gradle.kts))

### Developer 2 — PENDING
- Main Application Root & Shell (`MainShell` & Bottom Navigation)
- Global Design System UI Tokens & Styling Integration
- Member Directory (`Daftar Anggota` UI)
- Date & Age Converter Module (Gregorian / Hijriah)
- Nusantara Calendar Engine (Javanese Weton & Balinese Saka)
- Stopwatch Feature Module
- User Guide (`Panduan` Page)
- Application Logout UI & Router Integration

---

## 19. Shared Contracts

| Shared Contract Component | Dev 1 Provides | Dev 2 Consumes / Uses |
|---|---|---|
| **Authenticated Handoff** | [`AuthContract`](lib/core/security/auth_contract.dart) (`AuthenticatedPageBuilder`) | Passes `(context, user)` to instantiate `MainShell` |
| **Session Expiration Check** | [`SessionService.isSessionExpired()`](lib/core/security/session_service.dart#L138-L142) | Checks expiration on app resume from background |
| **Session Lifetime Info** | [`SessionService.remainingSessionDuration()`](lib/core/security/session_service.dart#L148-L153) | Schedules live 30-min timer in `MainShell` |
| **Session Clearance** | [`SessionService.clearSession()`](lib/core/security/session_service.dart#L168-L179) | Invokes `clearSession()` upon tapping Logout |
| **Biometric Toggle** | [`BiometricService.enableForUser()`](lib/core/security/biometric_service.dart) | Connects settings screen toggle button |
| **BMI Feature Integration** | [`BmiCalculatorPage`](lib/features/bmi/pages/bmi_calculator_page.dart), [`BmiHistoryPage`](lib/features/bmi/pages/bmi_history_page.dart) | Embeds pages into Home menu dashboard tabs |

---

## 20. Important File Reference Table

| File | Layer | Main Class | Main Responsibility | Called By | Calls | Owner |
|---|---|---|---|---|---|---|
| [`main.dart`](lib/main.dart) | Bootstrap | `_TempDev1App` | Temporary application entry point | Flutter Engine | [`SplashPage`](lib/features/auth/pages/splash_page.dart) | Dev 1 (Temp) |
| [`database_helper.dart`](lib/core/database/database_helper.dart) | Core Database | `DatabaseHelper` | SQLite connection singleton & PRAGMA | Repositories, Splash | `openDatabase` | Dev 1 |
| [`admin_seed.dart`](lib/core/database/admin_seed.dart) | Core Database | `AdminSeed` | Seeds default admin ('tofik'/'123') | [`SplashPage`](lib/features/auth/pages/splash_page.dart) | [`PasswordService`](lib/core/security/password_service.dart), SQLite | Dev 1 |
| [`password_service.dart`](lib/core/security/password_service.dart) | Security | `PasswordService` | PBKDF2 hashing & verification | [`AuthRepository`](lib/data/repositories/auth_repository.dart), `AdminSeed` | Pointycastle PBKDF2 | Dev 1 |
| [`session_service.dart`](lib/core/security/session_service.dart) | Security | `SessionService` | Secure storage CRUD & 30-min hard timeout | [`SplashPage`](lib/features/auth/pages/splash_page.dart), [`LoginController`](lib/features/auth/controller/login_controller.dart) | `FlutterSecureStorage` | Dev 1 |
| [`biometric_service.dart`](lib/core/security/biometric_service.dart) | Security | `BiometricService` | OS biometric hardware check & auth | [`LoginController`](lib/features/auth/controller/login_controller.dart) | `LocalAuthentication` | Dev 1 |
| [`auth_repository.dart`](lib/data/repositories/auth_repository.dart) | Data Repository | `AuthRepository` | SQL query execution for users | [`LoginController`](lib/features/auth/controller/login_controller.dart), `SplashPage` | [`DatabaseHelper`](lib/core/database/database_helper.dart), [`PasswordService`](lib/core/security/password_service.dart) | Dev 1 |
| [`bmi_repository.dart`](lib/data/repositories/bmi_repository.dart) | Data Repository | `BmiRepository` | User-isolated SQL queries for BMI records | BMI Controllers | [`DatabaseHelper`](lib/core/database/database_helper.dart) | Dev 1 |
| [`bmi_calculator.dart`](lib/core/domain/bmi_calculator.dart) | Pure Domain | `BmiCalculator` | Mathematical BMI computation | BMI Controllers | [`BmiCategory`](lib/core/domain/bmi_category.dart) | Dev 1 |
| [`login_controller.dart`](lib/features/auth/controller/login_controller.dart) | Feature State | `LoginController` | Auth form state & login orchestration | [`LoginPage`](lib/features/auth/pages/login_page.dart) | [`AuthRepository`](lib/data/repositories/auth_repository.dart), [`SessionService`](lib/core/security/session_service.dart) | Dev 1 |
| [`splash_page.dart`](lib/features/auth/pages/splash_page.dart) | Presentation | `SplashPage` | App gate & hard timeout evaluator | [`main.dart`](lib/main.dart) | [`DatabaseHelper`](lib/core/database/database_helper.dart), [`SessionService`](lib/core/security/session_service.dart) | Dev 1 |
| [`login_page.dart`](lib/features/auth/pages/login_page.dart) | Presentation | `LoginPage` | User login screen | [`SplashPage`](lib/features/auth/pages/splash_page.dart) | [`LoginController`](lib/features/auth/controller/login_controller.dart) | Dev 1 |
| [`bmi_calculator_page.dart`](lib/features/bmi/pages/bmi_calculator_page.dart) | Presentation | `BmiCalculatorPage` | Form for entering BMI details | Main Menu / Shell | [`BmiCalculatorController`](lib/features/bmi/controllers/bmi_calculator_controller.dart) | Dev 1 |
| [`bmi_result_page.dart`](lib/features/bmi/pages/bmi_result_page.dart) | Presentation | `BmiResultPage` | Calculation result & save screen | [`BmiCalculatorPage`](lib/features/bmi/pages/bmi_calculator_page.dart) | [`BmiRepository`](lib/data/repositories/bmi_repository.dart) | Dev 1 |
| [`bmi_history_page.dart`](lib/features/bmi/pages/bmi_history_page.dart) | Presentation | `BmiHistoryPage` | List screen for user's BMI records | Main Menu / Shell | [`BmiHistoryController`](lib/features/bmi/controllers/bmi_history_controller.dart) | Dev 1 |

---

## 21. Method-Level Reference for Critical Files

### [`SessionService`](lib/core/security/session_service.dart)

| Method | Return Type | Responsibility | Called By |
|---|---|---|---|
| `saveSession(UserSession session)` | `Future<void>` | Persists session keys atomically to secure storage | [`LoginController`](lib/features/auth/controller/login_controller.dart) |
| `readSession()` | `Future<UserSession?>` | Reads and parses session values; returns null if corrupt/absent | [`SplashPage`](lib/features/auth/pages/splash_page.dart), `isSessionExpired` |
| `hasValidSession()` | `Future<bool>` | Returns true if session exists, is valid, and is unexpired | External callers / Guards |
| `isSessionExpired()` | `Future<bool>` | Evaluates if `now >= expiresAt` in UTC | [`SplashPage`](lib/features/auth/pages/splash_page.dart), MainShell timer |
| `remainingSessionDuration()` | `Future<Duration?>` | Returns remaining duration until expiry | Dev 2 MainShell Live Timer |
| `getSessionExpiry()` | `Future<DateTime?>` | Returns absolute UTC expiry timestamp | Dev 2 MainShell |
| `clearSession()` | `Future<void>` | Deletes all `nusafit_session_*` secure storage keys | [`SplashPage`](lib/features/auth/pages/splash_page.dart), Logout flow |

### [`AuthRepository`](lib/data/repositories/auth_repository.dart)

| Method | Return Type | Responsibility | Called By |
|---|---|---|---|
| `login({username, password})` | `Future<AuthResult>` | Authenticates credentials against SQLite using PBKDF2 | [`LoginController`](lib/features/auth/controller/login_controller.dart) |
| `findUserByUsername(username)` | `Future<User?>` | Queries user by sanitized username | `login`, unit tests |
| `findUserById(id)` | `Future<User?>` | Queries active user by primary key | [`SplashPage`](lib/features/auth/pages/splash_page.dart) |
| `findBiometricEnabledUser()` | `Future<User?>` | Queries user with `biometric_enabled = 1` | [`LoginController`](lib/features/auth/controller/login_controller.dart) |
| `setBiometricEnabled({userId, enabled})` | `Future<void>` | Updates `biometric_enabled` DB flag for user | [`BiometricService`](lib/core/security/biometric_service.dart) |

### [`BmiRepository`](lib/data/repositories/bmi_repository.dart)

| Method | Return Type | Responsibility | Called By |
|---|---|---|---|
| `insertRecord(record)` | `Future<int>` | Inserts new record into `bmi_records` | [`BmiCalculatorController`](lib/features/bmi/controllers/bmi_calculator_controller.dart) |
| `getRecordsForUser(userId)` | `Future<List<BmiRecord>>` | Queries all records for user ordered by date DESC | [`BmiHistoryController`](lib/features/bmi/controllers/bmi_history_controller.dart) |
| `getRecordByIdForUser({id, userId})` | `Future<BmiRecord?>` | Queries single record strictly isolated by `user_id` | [`BmiEditController`](lib/features/bmi/controllers/bmi_edit_controller.dart) |
| `updateRecordForUser({record, userId})` | `Future<bool>` | Updates record fields strictly isolated by `user_id` | [`BmiEditController`](lib/features/bmi/controllers/bmi_edit_controller.dart) |
| `deleteRecordForUser({id, userId})` | `Future<bool>` | Deletes record strictly isolated by `user_id` | [`BmiHistoryController`](lib/features/bmi/controllers/bmi_history_controller.dart) |

---

## 22. Where Do I Change Something?

| Task / Change Required | Edit File(s) | Also Verify / Check | DO NOT EDIT |
|---|---|---|---|
| **Change BMI Calculation Formula** | [`BmiCalculator`](lib/core/domain/bmi_calculator.dart) | [`bmi_calculator_test.dart`](test/core/domain/bmi_calculator_test.dart) | [`BmiCalculatorPage`](lib/features/bmi/pages/bmi_calculator_page.dart) |
| **Modify BMI Category Thresholds** | [`BmiCategory`](lib/core/domain/bmi_category.dart) | [`bmi_calculator_test.dart`](test/core/domain/bmi_calculator_test.dart) | Database schema |
| **Change Form Input Limits (Age/Height)** | [`Validators`](lib/core/utils/validators.dart) | [`validator_test.dart`](test/core/utils/validator_test.dart) | Controllers |
| **Modify Database Schema / Add Table** | [`MigrationV1`](lib/core/database/migrations/migration_v1.dart) / `MigrationV2` | [`DatabaseHelper`](lib/core/database/database_helper.dart), [`database_helper_test.dart`](test/core/database/database_helper_test.dart) | Page widgets |
| **Change Session Expiration Duration** | [`SessionService`](lib/core/security/session_service.dart) (`sessionTimeout`) | [`session_service_test.dart`](test/core/security/session_service_test.dart), [`splash_page_test.dart`](test/features/auth/splash_page_test.dart) | `MainShell` |
| **Modify Password Hashing Iterations** | [`PasswordService`](lib/core/security/password_service.dart) | [`password_service_test.dart`](test/core/security/password_service_test.dart) | Repositories |
| **Change Default Admin Account** | [`AdminSeed`](lib/core/database/admin_seed.dart) | [`admin_seed_test.dart`](test/core/database/admin_seed_test.dart) | Auth UI |
| **Android Biometric Permissions** | [`AndroidManifest.xml`](android/app/src/main/AndroidManifest.xml) | [`build.gradle.kts`](android/app/build.gradle.kts), [`MainActivity.kt`](android/app/src/main/kotlin/com/example/mobile_kalku/MainActivity.kt) | Dart UI code |

---

## 23. Why Does One Feature Use Multiple Files?

Consider the **Session Management** feature as an example:

1. **[`UserSession`](lib/data/models/user_session.dart)**: Defines the data model structure.
2. **[`SessionService`](lib/core/security/session_service.dart)**: Handles secure storage encryption and hard timeout mathematics.
3. **[`LoginController`](lib/features/auth/controller/login_controller.dart)**: Instantiates the session upon authentication.
4. **[`SplashPage`](lib/features/auth/pages/splash_page.dart)**: Evaluates session expiration at application startup.
5. **[`AuthContract`](lib/core/security/auth_contract.dart)**: Hands off authenticated user context to Dev 2.

### Why not combine these into a single file?
- **Testability**: `SessionService` can be unit tested in isolation without inflating Flutter widgets.
- **Security**: Database entities (`User`) containing sensitive hashes/salts are kept separate from transient UI sessions (`UserSession`).
- **Maintainability**: Security expiration rules can be updated without touching UI code.

---

## 24. Dependency Direction & Source of Truth

### Source of Truth Reference

| Information Category | Canonical Source of Truth |
|---|---|
| **Active Session & Expiry** | [`SessionService`](lib/core/security/session_service.dart) & `FlutterSecureStorage` |
| **User Account & Credentials** | SQLite Database `users` table |
| **User Biometric Preference** | SQLite Database `users.biometric_enabled` column |
| **BMI Health Records** | SQLite Database `bmi_records` table |
| **BMI Mathematical Rules** | [`BmiCalculator`](lib/core/domain/bmi_calculator.dart) |
| **BMI Category Boundaries** | [`BmiCategory`](lib/core/domain/bmi_category.dart) |
| **Form Input Validation** | [`Validators`](lib/core/utils/validators.dart) |
| **Current Implementation Phase** | [`AI_STATE.md`](AI_STATE.md) |
| **Complete System PRD** | [`PRD_NusaFit_Lengkap.md`](md/PRD_NusaFit_Lengkap.md) |

---

## 25. Temporary / Integration Components

- **[`lib/main.dart`](lib/main.dart)** contains `_TempDev1App`:
  - **Purpose**: Provides a temporary root `MaterialApp` for Developer 1 to launch and test the Auth and BMI flows.
  - **Dev 2 Action**: Developer 2 will replace `_TempDev1App` with the real root widget and `MainShell` navigation router while preserving `SplashPage` as the initial `home:` screen.

---

## 26. Documentation & AI Context Files

The project contains authoritative documentation in the `md/` directory and root directory:

- **[`AI_STATE.md`](AI_STATE.md)**: Tracks real-time phase completion status, test counts, and developer handoffs.
- **[`PRD_NusaFit_Lengkap.md`](md/PRD_NusaFit_Lengkap.md)**: Comprehensive Product Requirements Document.
- **[`COMPUTATION_LOGIC.md`](md/COMPUTATION_LOGIC.md)**: Mathematical specifications for BMI, Weton, and Hijriah calculations.
- **[`DESIGN_SYSTEM.md`](md/DESIGN_SYSTEM.md)**: UI visual guidelines and color tokens.
- **[`MENU_IMPLEMENTATION.md`](md/MENU_IMPLEMENTATION.md)**: Detailed specification for the 5 Home menu items.
- **[`WRITING_RULES.md`](md/WRITING_RULES.md)**: Standard code style, architecture, and security rules.
- **[`README_AI_GUIDE.md`](md/README_AI_GUIDE.md)**: Quick orientation guide for AI assistants.

---

## 27. Menu Implementation Matrix

| Menu Entry | Presentation (UI) | State Controller | Pure Domain | Repository | Data Model | Implementation Status | Owner |
|---|---|---|---|---|---|---|---|
| **Daftar Anggota** | Pending | Pending | - | `AuthRepository` | `User` | **PENDING** | Dev 2 |
| **Kalkulator BMI** | `BmiCalculatorPage`, `BmiResultPage` | `BmiCalculatorController` | `BmiCalculator`, `BmiCategory` | `BmiRepository` | `BmiRecord` | **IMPLEMENTED** | Dev 1 |
| **BMI History & CRUD** | `BmiHistoryPage`, `BmiDetailPage`, `BmiEditPage` | `BmiHistoryController`, `BmiEditController` | `BmiCalculator`, `BmiCategory` | `BmiRepository` | `BmiRecord` | **IMPLEMENTED** | Dev 1 |
| **Date & Age Converter** | Pending | Pending | Pending | - | - | **PENDING** | Dev 2 |
| **Weton & Saka Bali** | Pending | Pending | Pending | - | - | **PENDING** | Dev 2 |
| **Stopwatch** | Pending | Pending | - | - | - | **PENDING** | Dev 2 |
| **Panduan** | Pending | Pending | - | - | - | **PENDING** | Dev 2 |
| **Logout** | Pending | Pending | - | - | - | **SHARED** | Dev 1 & 2 |

---

## 28. Status Legend

- **`IMPLEMENTED`**: Production code is written, active in codebase, and fully functional.
- **`VERIFIED`**: Automated test suite (`flutter test`) and static analysis (`flutter analyze`) confirm correctness.
- **`PENDING`**: Feature scope is defined in PRD/md docs, awaiting Developer 2 implementation.
- **`TEMPORARY`**: Scaffolding code created for testing (e.g. `_TempDev1App` in [`lib/main.dart`](lib/main.dart)) to be replaced during integration.
- **`SHARED CONTRACT`**: Interfaces/services created by Developer 1 for Developer 2 to consume.
- **`DEV1`**: Owned by Developer 1 (Dito).
- **`DEV2`**: Owned by Developer 2.
