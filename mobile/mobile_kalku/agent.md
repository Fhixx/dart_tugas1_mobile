# NusaFit — Mandatory AI Agent Instructions

> FILE INI WAJIB DIBACA SEBELUM AI AGENT MENULIS, MENGUBAH, MEREFACTOR, ATAU MENGHAPUS KODE NUSAFIT.

## 1. Mandatory Reading Order

Sebelum melakukan pekerjaan apa pun pada repository NusaFit, baca file berikut dalam urutan ini:

1. `PRD_NusaFit_Lengkap.md`
2. `WRITING_RULES.md`
3. `MENU_IMPLEMENTATION.md`
4. `COMPUTATION_LOGIC.md`
5. `DESIGN_SYSTEM.md`

Tidak boleh melewati `PRD_NusaFit_Lengkap.md` dan `WRITING_RULES.md`.

Jika tugas hanya dokumentasi, tetap baca PRD dan aturan penulisan terlebih dahulu agar terminologi konsisten.

---

## 2. Source of Truth Priority

Jika ada konflik:

```text
PRD_NusaFit_Lengkap.md
    > WRITING_RULES.md
    > MENU_IMPLEMENTATION.md
    > COMPUTATION_LOGIC.md
    > DESIGN_SYSTEM.md
    > existing implementation
```

Catatan: untuk persoalan khusus domain, `COMPUTATION_LOGIC.md` menjelaskan cara implementasi requirement PRD tetapi tidak boleh mengubah requirement PRD.

Jika konflik tidak dapat diselesaikan dengan hierarchy tersebut, jangan menebak. Laporkan konflik sebelum mengubah kode.

---

## 3. Hard Requirements yang Tidak Boleh Hilang

- Flutter Android.
- SQLite lokal.
- Offline-first.
- Login username/password.
- Akun demo `tofik / 123` dengan password tersimpan sebagai hash, bukan plaintext.
- Session lokal.
- Fingerprint/face biometric melalui data biometric perangkat/OS.
- Home mempunyai 5 menu vertikal.
- Bottom navigation: Home, Stopwatch, Panduan, Logout.
- BMI + CRUD SQLite.
- Berat maksimum 1000 kg.
- Tinggi maksimum 400 cm.
- Umur maksimum 300 tahun.
- Konversi Masehi, Hijriah, Weton, Saka Bali.
- Satu input tanggal menghasilkan semua konversi.
- Umur realtime tahun/bulan/hari/jam/menit/detik.
- Stopwatch.
- Error handling dan sanitization.
- `Navigator.push()`.
- `Navigator.pop()`.
- `Navigator.pushReplacement()`.
- Passing data antar halaman.
- Logout dengan stack dibersihkan.

---

## 4. Separation Rule

Jangan campur layer.

```text
UI ≠ computation
UI ≠ database
UI ≠ security
repository ≠ design
calculator ≠ navigation
```

Detail:

- penulisan kode → `WRITING_RULES.md`
- menu/screen → `MENU_IMPLEMENTATION.md`
- formula/algoritma → `COMPUTATION_LOGIC.md`
- warna/layout/style → `DESIGN_SYSTEM.md`

---

## 5. Before Coding Checklist

AI agent harus menentukan:

```text
1. Requirement PRD mana yang dikerjakan?
2. Menu/feature mana?
3. Apakah ada logic computation?
4. Apakah ada database/security concern?
5. File apa yang perlu dibuat/diubah?
6. Test apa yang diperlukan?
```

Jangan mulai dengan menulis satu file raksasa.

---

## 6. Prohibited Actions

Dilarang:

- menyimpan password plaintext,
- query SQL dengan string interpolation,
- menyimpan fingerprint/face template,
- membuat algoritma biometrik sendiri,
- menaruh BMI/calendar algorithm di widget,
- menaruh SQLite query langsung di screen,
- hardcode screen width/height tertentu,
- menghapus data user saat migration hanya untuk menghindari migration logic,
- mengarang hasil Saka Bali/Weton tanpa fixture/algoritma terverifikasi,
- mengklaim test lulus tanpa menjalankannya,
- menghapus fitur requirement untuk menyederhanakan kode,
- mengubah credential demo tanpa instruksi user.

---

## 7. Required Agent Workflow

Untuk setiap request coding:

```text
READ
  PRD + rules

PLAN
  file/layer/test

IMPLEMENT
  domain → data → controller → UI

VALIDATE
  analyzer/test/edge cases

REPORT
  perubahan + test + sisa issue
```

---

## 8. Completion Report Format

Setelah perubahan, jawab minimal:

```text
Selesai:
- ...

File berubah:
- ...

Validation/error handling:
- ...

Test yang dijalankan:
- ...

Belum selesai / risiko:
- ...
```

Jika tidak ada test yang dijalankan, tulis eksplisit `Belum menjalankan test`.

---

## 9. Repository Compatibility

File canonical instruction adalah:

```text
agent.md
```

Repository juga menyediakan compatibility files untuk beberapa AI coding agent. Semua compatibility file harus mengarahkan agent kembali ke `agent.md`, bukan membuat aturan berbeda.

Jika Anda adalah AI agent yang mendukung `AGENTS.md`, baca `AGENTS.md`; isinya akan mengarahkan ke `agent.md`.
