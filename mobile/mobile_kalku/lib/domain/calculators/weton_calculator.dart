/// Result of a Weton (Javanese day + pasaran) calculation.
class WetonResult {
  const WetonResult({
    required this.dayName,
    required this.pasaran,
    required this.neptuDay,
    required this.neptuPasaran,
  });

  final String dayName;
  final String pasaran;
  int get totalNeptu => neptuDay + neptuPasaran;
  String get wetonLabel => '$dayName $pasaran';

  final int neptuDay;
  final int neptuPasaran;
}

/// Pancawara (5-day market cycle) names, in their canonical cycle order.
/// COMPUTATION_LOGIC.md #9.
const List<String> pasaranCycle = ['Legi', 'Pahing', 'Pon', 'Wage', 'Kliwon'];

const Map<String, int> _neptuDay = {
  'Minggu': 5,
  'Senin': 4,
  'Selasa': 3,
  'Rabu': 7,
  'Kamis': 8,
  'Jumat': 6,
  'Sabtu': 9,
};

const Map<String, int> _neptuPasaran = {
  'Legi': 5,
  'Pahing': 9,
  'Pon': 7,
  'Wage': 4,
  'Kliwon': 8,
};

/// Reference epoch for the pasaran cycle: 1 January 1970 = Kamis Wage.
/// Verified against two independent historical fixtures:
///  - 1 Jan 1970 = Kamis Wage (widely cited Unix-epoch weton fixture)
///  - 17 Aug 1945 (Indonesian Independence Day) = Jumat Legi (extensively
///    documented historical fact — Soekarno referenced "Jumat Legi" in the
///    Proclamation account)
/// Do not change this constant without re-verifying against fixtures —
/// see COMPUTATION_LOGIC.md #9 "Jangan menebak epoch".
final DateTime _pasaranEpoch = DateTime(1970, 1, 1);

/// Index of "Wage" within [pasaranCycle] — the pasaran of the epoch date.
const int _epochPasaranIndex = 3;

/// Returns the Gregorian day-of-week name in Indonesian (Minggu..Sabtu).
String dayNameForDate(DateTime date) {
  const mapping = {
    DateTime.monday: 'Senin',
    DateTime.tuesday: 'Selasa',
    DateTime.wednesday: 'Rabu',
    DateTime.thursday: 'Kamis',
    DateTime.friday: 'Jumat',
    DateTime.saturday: 'Sabtu',
    DateTime.sunday: 'Minggu',
  };
  return mapping[date.weekday]!;
}

/// Returns the pasaran (Pancawara) name for [date] using the verified
/// epoch above.
String pasaranForDate(DateTime date) {
  final normalizedDate = DateTime(date.year, date.month, date.day);
  final normalizedEpoch =
      DateTime(_pasaranEpoch.year, _pasaranEpoch.month, _pasaranEpoch.day);
  final diff = normalizedDate.difference(normalizedEpoch).inDays;
  final index = (diff + _epochPasaranIndex) % pasaranCycle.length;
  final safeIndex = index < 0 ? index + pasaranCycle.length : index;
  return pasaranCycle[safeIndex];
}

/// Calculates the Weton (day + pasaran + neptu) for a Gregorian [date].
///
/// Pure function — no BuildContext/DB. [date] is assumed to already be a
/// valid Gregorian `DateTime` (validated upstream).
WetonResult calculateWeton(DateTime date) {
  final dayName = dayNameForDate(date);
  final pasaran = pasaranForDate(date);
  return WetonResult(
    dayName: dayName,
    pasaran: pasaran,
    neptuDay: _neptuDay[dayName]!,
    neptuPasaran: _neptuPasaran[pasaran]!,
  );
}
