# NusaFit AI Context

## Project Identity
- **App Name:** NusaFit
- **Framework:** Flutter (Android focused)
- **Supported Platform:** Android (Offline-first)
- **Database:** SQLite (`nusafit.db`, version 1)
- **Architecture Direction:** Feature-based structure (`lib/features/`, `lib/core/`, `lib/data/`), strict separation between UI, computation, database, and security.

## Authentication
- **Seeded Admin:** Username `tofik`, Password `123`
- **Password Policy:** No plaintext passwords allowed.
- **Password Hashing:** PBKDF2 with salt.
- **Session Policy:** Handled via local session storage (`FlutterSecureStorage`).
- **Biometric Policy:** Integrated via OS `local_auth`. 
- **Biometric Default State:** DEFAULT OFF (`users.biometric_enabled = 0`).

## Navigation
- **Required Navigation Mechanisms:** `Navigator.push()`, `Navigator.pop()`, `Navigator.pushReplacement()`.
- **MainShell Ownership:** Managed by Developer 1 (Dito) initially.
- **Bottom Navigation:** Must include: Home, Stopwatch, Panduan, Logout.
- **Passing Data Requirements:** Handled explicitly through route arguments/constructors.

## Home
- **Menu Entries:** Must contain exactly 5 vertical menu entries.

## BMI
- **Inputs:** Weight, Height, Age, Gender.
- **Limits:** 
  - Weight max: 1000 kg
  - Height max: 400 cm
  - Age max: 300 years
- **Formula:** Standard BMI calculation.
- **Categories:** Standard BMI categories.
- **CRUD:** Handled via SQLite.
- **Database Relationship:** Associated with user records.

## Date & Calendar
- **Gregorian:** Standard input.
- **Age Realtime:** Displayed in years, months, days, hours, minutes, seconds.
- **Hijriah:** Converted from input.
- **Weton:** Converted from input.
- **Saka Bali:** Converted from input.
- **Source-of-Truth Date Behavior:** One date input produces all conversions simultaneously.

## Stopwatch
- **Required Behavior:** Standard start, stop, lap functionality.

## Design
- **Primary Colors:** Brand gradient (`#114177` -> `#006A9A` -> `#17A18A`).
- **Background & Surfaces:** Consistent with brand guidelines.
- **Major UI Constraints:** 8-point grid system spacing.

## Database
- **Filename:** `nusafit.db`
- **Version:** 1
- **Tables:** Initial `users` and `bmi_records`.
- **Important Constraints:** Handled via simple migration object `MigrationV1`.

## Security
- **Sanitization:** All inputs must be sanitized.
- **Parameterized SQL:** Strictly required. String interpolation for SQL is PROHIBITED.
- **Password Storage:** Hashed, never plaintext.
- **Biometric Restrictions:** Do not build custom biometric algorithms, use device data. Do not store biometric templates in DB.

## Developer Ownership
- **Developer 1 (Dito):** Phase 2/3 (Auth, Session, Bio, Splash, Login).
- **Developer 2 (Taufikk):** Phase 1 core elements.
- **Boundary Rules:** Developers must not modify files owned by the other unless explicitly instructed.

## Testing Rules
- **Expected Testing Policy:** Tests required for domain logic, database operations, and controllers.
- **Current Test Status:** Tests are implemented and verified for Phase 1, Phase 2, and Phase 3 (78 passing tests).

## Non-Negotiable Constraints
- SQLite requirement.
- Biometric DEFAULT OFF.
- `nusafit.db` exact filename.
- Parameterized queries.
- Password hashing.

## Source Documents
- `md/PRD_NusaFit_Lengkap.md`
- `md/WRITING_RULES.md`
- `md/MENU_IMPLEMENTATION.md`
- `md/COMPUTATION_LOGIC.md`
- `md/DESIGN_SYSTEM.md`
