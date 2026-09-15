# NusaFit — Design System & Layout Specification

Dokumen ini hanya membahas visual dan tata letak. Jangan menaruh logic komputasi atau query database di file UI hanya karena dibutuhkan oleh design.

---

# 1. Brand

Nama aplikasi:

```text
Kalkulator BMI (mutlak abaikan penamaan lain!!!)
```

Subtitle:

```text
BMI & Kalender Nusantara
```

Karakter visual:

- modern,
- bersih,
- utilitarian,
- friendly tetapi tidak kekanak-kanakan,
- gradient biru–teal sebagai identitas.

---

# 2. Primary Gradient

```text
0%   #114177
50%  #006A9A
100% #17A18A
```

Representasi:

```text
#114177 → #006A9A → #17A18A
```

Gunakan pada:

- splash/header,
- primary button,
- selected accent,
- AppBar tertentu,
- icon/logo background.

Jangan memenuhi semua card dengan gradient.

---

# 3. Color Tokens

| Token | Hex | Penggunaan |
|---|---|---|
| `primaryDark` | `#114177` | Gradient awal |
| `primary` | `#006A9A` | Brand utama |
| `primaryTeal` | `#17A18A` | Gradient akhir |
| `background` | `#EEEEEE` | Background screen |
| `surface` | `#FFFFFF` | Card/input surface |
| `textPrimary` | `#1F2937` | Judul/body utama |
| `textSecondary` | `#6B7280` | Caption/helper |
| `divider` | `#E5E7EB` | Divider/border ringan |
| `success` | `#2E7D32` | BMI normal/success |
| `warning` | `#ED6C02` | Underweight/warning |
| `danger` | `#D32F2F` | Overweight/delete/error |
| `dangerDark` | `#B71C1C` | Obesity/critical |
| `disabled` | `#BDBDBD` | Disabled controls |

Seluruh hex harus didefinisikan terpusat di `app_colors.dart`.

---

# 4. Background & Surface

Default screen:

```text
#EEEEEE
```

Card:

```text
#FFFFFF
```

Struktur visual umum:

```text
Screen Background (#EEEEEE)
  └── White Card (#FFFFFF)
      └── Content
```

---

# 5. Spacing Scale

Gunakan 8-point system:

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

Rekomendasi:

```text
screen horizontal padding : 20–24
card internal padding     : 16–20
section gap               : 24
field gap                 : 12–16
```

---

# 6. Radius

```text
small control : 8
input         : 12
button        : 14–16
card          : 16
large modal   : 20
pill          : 999
```

---

# 7. Typography

Gunakan system/Material typography, default Roboto pada Android.

```text
H1          28sp Bold
H2          22sp SemiBold
H3/Card     16–18sp SemiBold
Body        14–16sp Regular
Caption     12–13sp Regular
Button      14–16sp SemiBold
Stopwatch   48–56sp Bold, tabular figures
```

Jangan gunakan terlalu banyak ukuran font unik.

---

# 8. Responsive Layout

Target minimum:

```text
360 × 640 logical px
```

Juga nyaman pada:

```text
393 × 852
411 × 915
```

Dilarang hardcode width screen.

Gunakan:

```text
SafeArea
LayoutBuilder
MediaQuery bila benar-benar perlu
Expanded
Flexible
SingleChildScrollView
```

---

# 9. AppBar

Default detail screen:

```text
┌──────────────────────────────┐
│ ←  Judul Halaman             │
└──────────────────────────────┘
```

Background gradient utama.

Text/icon putih.

Home root boleh memakai header custom daripada back AppBar.

---

# 10. Bottom Navigation

Menu:

```text
Home
Stopwatch
Panduan
Logout
```

Visual:

- container putih,
- upper corner rounded bila sesuai,
- shadow lembut,
- icon + label,
- tinggi 72–80 dp.

Selected:

```text
#006A9A atau gradient accent
```

Unselected:

```text
#9CA3AF
```

Logout:

```text
#D32F2F saat ditekan/di-highlight
```

Logout adalah action; jangan membuat empty logout tab.

---

# 11. Home Layout

Lima menu disusun vertikal.

```text
Header / greeting
↓
Daftar Anggota
↓
Kalkulator BMI
↓
Riwayat BMI
↓
Konversi Tanggal & Umur
↓
Kalender Nusantara
```

Home card:

```text
┌──────────────────────────────┐
│ [Icon]  Judul            >   │
│         Deskripsi pendek     │
└──────────────────────────────┘
```

Rekomendasi:

```text
height    84–96
radius    16
surface   white
shadow    low
```

---

# 12. Input Field

Gunakan filled/outlined field yang konsisten.

State:

```text
normal
focused
error
disabled
```

Error text tampil di bawah field.

Numeric field menggunakan keyboard numeric yang sesuai tetapi validation tetap dilakukan di logic layer.

---

# 13. Buttons

## Primary

Gradient brand.

Contoh:

```text
[ HITUNG BMI ]
```

## Secondary

White/surface + border primary.

## Destructive

Danger red.

Contoh:

```text
[ HAPUS ]
```

## Loading

Saat async:

```text
[ spinner  Menyimpan... ]
```

Button disabled untuk mencegah double submit.

---

# 14. BMI Result Visual State

## Normal

```text
background/accent: success #2E7D32
label: NORMAL
```

## Underweight

```text
accent: warning #ED6C02
label: KURANG BERAT BADAN
```

## Overweight

```text
background/accent: danger #D32F2F
label: OVERWEIGHT
```

Dapat memakai pulse/blink aman sekitar 700ms per fase.

## Obesity

```text
accent: dangerDark #B71C1C
label: OBESITAS
```

Informasi tidak boleh hanya mengandalkan warna; label kategori dan angka BMI wajib tampil.

Jika reduce motion aktif, gunakan state statis tanpa blink.

---

# 15. BMI History

Setiap item card menampilkan:

```text
Nama
Berat • Tinggi
BMI • Kategori
Tanggal
Action menu
```

Empty state:

```text
icon
Belum Ada Riwayat BMI
helper text
button Hitung BMI
```

---

# 16. Date Converter Layout

Urutan:

```text
Judul
Date picker
Optional time picker
Segment filter
Card Masehi
Card Hijriah
Card Weton
Card Saka Bali
Card Usia realtime
```

Jika filter bukan `Semua`, hanya card yang relevan tampil tetapi selected date tetap sama.

---

# 17. Stopwatch Layout

Elemen utama:

```text
siluet jam besar / low-opacity decoration
large elapsed time
primary Start/Pause/Continue button
secondary Reset button
```

Format angka harus mudah dibaca dan tidak bergeser saat digit berubah.

Gunakan tabular figures bila tersedia.

---

# 18. Panduan

Gunakan section accordion / `ExpansionTile`.

Setiap section:

```text
icon
judul
step-by-step singkat
```

Jangan menampilkan satu paragraf sangat panjang tanpa pemisahan.

---

# 19. Dialog

Gunakan dialog untuk destructive/irreversible actions:

```text
Hapus BMI
Logout
Keluar aplikasi
```

Urutan button:

```text
Batal
Destructive Action
```

Destructive action tidak boleh menjadi default focus tanpa alasan.

---

# 20. Snackbar

Success:

```text
Data berhasil disimpan.
```

Error:

```text
Data gagal disimpan. Silakan coba lagi.
```

Update:

```text
Data berhasil diperbarui.
```

Delete:

```text
Data berhasil dihapus.
```

---

# 21. Accessibility

Minimum touch target:

```text
48 × 48 dp
```

Contrast body text minimum target:

```text
4.5:1
```

Setiap status warna mempunyai text/icon alternatif.

Semua icon-only action penting memiliki semantic label/tooltip.

---

# 22. Design Token Implementation

File minimum:

```text
core/constants/app_colors.dart
core/constants/app_dimensions.dart
core/constants/app_strings.dart
```

Jangan tulis literal seperti ini di banyak screen:

```dart
Color(0xFF006A9A)
EdgeInsets.all(16)
```

jika token sudah tersedia.

---

# 23. Design Separation Rule

`DESIGN_SYSTEM.md` adalah sumber style visual. `COMPUTATION_LOGIC.md` adalah sumber logic domain.

AI agent dilarang memindahkan formula/algorithm ke dokumen atau file design hanya untuk mempermudah screen.
