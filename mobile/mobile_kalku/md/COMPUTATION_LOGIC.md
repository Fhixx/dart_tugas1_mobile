# NusaFit — Spesifikasi Logic Komputasi

Dokumen ini hanya membahas logic/domain computation. Tidak membahas warna, layout, widget, atau style UI.

---

# 1. Prinsip Umum

Semua calculator/converter harus:

- sebisa mungkin pure function,
- tidak bergantung pada `BuildContext`,
- tidak menulis database,
- tidak membuka dialog,
- tidak menampilkan snackbar,
- memiliki test fixture,
- mengembalikan object typed, bukan string gabungan jika data mempunyai banyak field.

Contoh:

```dart
class BmiResult {
  final double value;
  final BmiCategory category;
}
```

---

# 2. BMI

## Input

```text
weightKg : double
heightCm : double
```

## Validation

```text
weightKg > 0
weightKg <= 1000
heightCm > 0
heightCm <= 400
isFinite == true
```

Umur dan nama divalidasi di domain/form validator tetapi bukan bagian formula BMI.

Umur:

```text
1..300 integer
```

## Formula

```text
heightM = heightCm / 100
bmi = weightKg / (heightM * heightM)
```

Tidak boleh menghitung jika `heightM == 0`.

## Rounding

Nilai domain dapat mempertahankan precision penuh. Untuk display gunakan 2 desimal.

Rekomendasi:

```dart
double displayValue = double.parse(bmi.toStringAsFixed(2));
```

Jangan membulatkan berkali-kali di tengah kalkulasi.

## Category

```text
BMI < 18.5           → underweight
18.5 <= BMI < 25.0   → normal
25.0 <= BMI < 30.0   → overweight
BMI >= 30.0          → obesity
```

Gunakan enum:

```dart
enum BmiCategory {
  underweight,
  normal,
  overweight,
  obesity,
}
```

## Example

```text
weight = 70
height = 175 cm
heightM = 1.75
BMI = 70 / 3.0625
BMI = 22.857142...
display = 22.86
category = normal
```

---

# 3. Sanitization Numeric

Input string numeric:

1. `trim()`.
2. Jika locale Indonesia diizinkan, satu koma desimal dapat dinormalisasi menjadi titik.
3. Tolak multiple separator.
4. `double.tryParse()`.
5. cek `isFinite`.
6. range validation.

Input seperti berikut harus invalid:

```text
NaN
Infinity
-Infinity
1e999999
--10
12..5
abc
```

---

# 4. Penghitungan Usia Kalender

Tujuan display:

```text
tahun
bulan
hari
jam
menit
detik
```

Komponen harus ternormalisasi:

```text
bulan 0..11
jam   0..23
menit 0..59
detik 0..59
```

Jangan menampilkan bentuk seperti:

```text
22 tahun 19 bulan 122 hari
```

untuk representasi umur kalender.

## Input

```text
birthDateTime
nowDateTime
```

## Validation

```text
birthDateTime <= nowDateTime
umur kalender <= 300 tahun
```

## Algoritma yang Disarankan

Hitung komponen kalender dari besar ke kecil.

Pseudo:

```text
years = now.year - birth.year
candidate = addYears(birth, years)
if candidate > now:
    years--
    candidate = addYears(birth, years)

months = 0
while addMonths(candidate, 1) <= now and months < 11:
    candidate = addMonths(candidate, 1)
    months++

remaining = now - candidate
hari/jam/menit/detik diambil dari remaining duration
```

Karena panjang bulan berbeda, bulan tidak boleh dihitung dengan `days / 30`.

## Leap-Day Rule

Tanggal 29 Februari harus memiliki kebijakan eksplisit saat ditambah tahun non-kabisat.

Rekomendasi implementasi:

```text
29 Feb → 28 Feb pada tahun non-kabisat
```

Gunakan helper `safeAddYears` dan test fixture.

---

# 5. Total Elapsed Metrics

Selain umur kalender, boleh menyediakan nilai total:

```text
totalDays
totalHours
totalMinutes
totalSeconds
```

Gunakan `Duration` dari selisih timestamp jika timezone semantics sudah jelas.

Jangan menyebut `totalMonths` presisi tanpa mendefinisikan model bulan, karena bulan kalender memiliki panjang bervariasi. Jika dibutuhkan, definisikan sebagai jumlah month-boundary kalender yang dilalui.

---

# 6. Realtime Age

Controller memiliki timer 1 detik untuk memperbarui `now`.

Calculator tetap pure:

```dart
AgeResult calculateAge({
  required DateTime birth,
  required DateTime now,
});
```

Timer tidak berada di calculator.

Timer wajib dihentikan pada dispose.

---

# 7. Gregorian / Masehi

Gregorian adalah input default dan single source of truth.

Simpan input sebagai `DateTime` lokal yang valid.

Untuk date-only input, tentukan waktu default:

```text
00:00:00 local
```

Jika user memasukkan jam lahir, gunakan jam tersebut.

---

# 8. Hijriah

Konversi Hijriah harus menggunakan satu metode yang konsisten untuk seluruh aplikasi.

Output typed minimum:

```dart
class HijriDateResult {
  final int day;
  final int month;
  final int year;
  final String monthName;
}
```

Catatan requirement:

- hasil bersifat algoritmik/offline,
- dapat berbeda dari penetapan observasional,
- jangan mencampur dua library/metode pada screen berbeda.

## Validation

Input harus Gregorian valid dan berada dalam range library/algoritma.

Jika berada di luar range:

```text
return typed failure / unsupportedRange
```

bukan crash.

---

# 9. Weton Jawa

## Output

```text
dayName
pasaran
wetonLabel
neptuDay
neptuPasaran
totalNeptu
```

## Neptu Hari

```text
Minggu = 5
Senin  = 4
Selasa = 3
Rabu   = 7
Kamis  = 8
Jumat  = 6
Sabtu  = 9
```

## Neptu Pasaran

```text
Legi   = 5
Pahing = 9
Pon    = 7
Wage   = 4
Kliwon = 8
```

## Total

```text
totalNeptu = neptuDay + neptuPasaran
```

## Siklus Pasaran

```text
Legi
Pahing
Pon
Wage
Kliwon
```

Implementasi harus memilih epoch/reference date yang telah diverifikasi, lalu menghitung offset modulo 5.

**Jangan menebak epoch.** Simpan epoch sebagai constant yang disertai komentar sumber/fixture.

## Testing

Minimal 5–10 known-date fixtures dari referensi yang dipercaya, mencakup pergantian tahun dan leap day.

---

# 10. Kalender Saka Bali

Kalender Saka Bali lebih kompleks. Implementasi tidak boleh hanya melakukan:

```text
gregorianYear - 78
```

lalu menganggap hasil lengkap sebagai kalender Bali.

Output MVP minimum yang sudah diverifikasi:

```text
tahunSaka
sasih
tanggal/hari terkait
```

Jika implementasi mendukung:

```text
wuku
saptawara
pancawara
```

semua harus memiliki fixture validasi.

## Aturan agent

- Jangan membuat algoritma Saka Bali berdasarkan asumsi sendiri.
- Gunakan library/dataset/algoritma yang sumbernya dapat dijelaskan.
- Tambahkan test terhadap tanggal referensi.
- Jika algoritma belum terverifikasi, tandai feature sebagai incomplete daripada mengarang hasil.

---

# 11. Stopwatch

Stopwatch tidak boleh dihitung dengan menambah `+10 ms` setiap timer tick karena callback timer dapat terlambat.

Gunakan:

```dart
final Stopwatch stopwatch = Stopwatch();
```

atau elapsed source monotonic setara.

UI timer hanya merefresh display.

## State

```text
idle
running
paused
```

## Action

### Start

```text
idle → running
stopwatch.start()
```

### Pause

```text
running → paused
stopwatch.stop()
```

### Continue

```text
paused → running
stopwatch.start()
```

### Reset

```text
stopwatch.reset()
state → idle (atau paused zero; pilih satu dan konsisten)
```

Rekomendasi PRD:

```text
reset → idle, 00:00:00.00
```

## Display format

Dari elapsed milliseconds:

```text
hours       = ms ~/ 3600000
minutes     = (ms ~/ 60000) % 60
seconds     = (ms ~/ 1000) % 60
centisecond = (ms ~/ 10) % 100
```

Format:

```text
HH:MM:SS.CS
```

Pad setiap unit minimal 2 digit.

---

# 12. Password Hashing

Password bukan logic UI.

Flow:

```text
plain password
→ hash service + salt
→ stored hash
```

Login:

```text
input plain password
→ derive hash dengan salt user
→ constant-time-ish comparison bila library mendukung
```

Untuk project pendidikan, gunakan library crypto yang tersedia dan jangan membuat algoritma enkripsi/hash custom.

---

# 13. Session Logic

Session menyimpan minimum:

```text
userId
username
role
isLoggedIn
```

Password tidak disimpan.

Logout:

```text
clear session only
```

Data BMI tetap ada.

---

# 14. CRUD BMI

## Create

Input domain valid → calculate BMI → construct `BmiRecord` → insert.

## Read

Query by `user_id`, default urutan terbaru lebih dahulu.

## Update

Jika weight/height berubah:

```text
recalculate BMI
recalculate category
updatedAt = now
```

User tidak boleh mengirim nilai BMI manual ke repository update tanpa validasi calculator.

## Delete

Delete by record ID + ownership/user ID jika schema mengizinkan.

---

# 15. Timestamp

Gunakan ISO-8601 secara konsisten.

```dart
DateTime.now().toIso8601String()
```

Saat read:

```dart
DateTime.parse(value)
```

Jika app sepenuhnya local, tetap dokumentasikan apakah timestamp disimpan local atau UTC. Rekomendasi engineering: simpan UTC, render local.

```dart
DateTime.now().toUtc().toIso8601String()
```

---

# 16. Typed Failure

Calculator sebaiknya tidak mengembalikan string error acak.

Contoh:

```dart
enum CalculationError {
  invalidWeight,
  invalidHeight,
  invalidAge,
  futureDate,
  unsupportedDateRange,
}
```

UI layer menerjemahkan ke Bahasa Indonesia.

---

# 17. Unit Test Matrix Minimum

## BMI

```text
weight=70, height=175 → 22.86 normal
BMI exactly 18.5 → normal
BMI exactly 25.0 → overweight
BMI exactly 30.0 → obesity
weight=0 → invalid
weight=1000 → valid
weight>1000 → invalid
height=400 → valid
height>400 → invalid
```

## Age

```text
birth == now date/time → valid duration zero, tetapi DOB form dapat menerapkan age minimum sesuai konteks
future → invalid
>300 tahun → invalid
29 Feb leap handling
month boundary
end-of-month
```

## Stopwatch

```text
0ms → 00:00:00.00
1234ms → 00:00:01.23
60000ms → 00:01:00.00
3600000ms → 01:00:00.00
```

## Weton/Saka/Hijriah

Gunakan known-date fixtures yang disimpan bersama source test dan diberi sumber.
