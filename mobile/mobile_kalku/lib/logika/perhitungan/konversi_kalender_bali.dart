import 'weton_calculator.dart' as weton;

/// 30 Wuku names, in canonical cycle order (Sinta -> Watugunung), cross-
/// checked against multiple independent published sources (Kompas.com,
/// detik.com, and academic/Hindu-education references all agree on this
/// order and these spellings).
const List<String> wukuCycle = [
  'Sinta',
  'Landep',
  'Ukir',
  'Kulantir',
  'Tolu',
  'Gumbreg',
  'Wariga',
  'Warigadean',
  'Julungwangi',
  'Sungsang',
  'Dungulan',
  'Kuningan',
  'Langkir',
  'Medangsia',
  'Pujut',
  'Pahang',
  'Krulut',
  'Mrakih',
  'Tambir',
  'Madangkungan',
  'Matal',
  'Uye',
  'Manail',
  'Prangbakat',
  'Bala',
  'Ugu',
  'Wayang',
  'Klawu',
  'Dukut',
  'Watugunung',
];

/// Reference epoch for the 210-day Wuku (Pawukon) cycle: 21 May 2000 =
/// day 1 of Wuku Sinta. This date is independently cited by multiple
/// Javanese/Balinese calendar references as the modern pawukon anchor —
/// see COMPUTATION_LOGIC.md #10 "Jangan menebak epoch". Do not change
/// without re-verifying against those sources.
final DateTime _wukuEpoch = DateTime(2000, 5, 21);

/// Result of a Saka Bali calendar lookup.
///
/// [wuku]/[pancawara]/[saptawara] are deterministic modulo-cycle values
/// and are verified (see epoch comments above and in weton_calculator.dart).
///
/// [sasih] (Balinese lunar month) and an exact [tahunSaka] year boundary
/// (which turns over at Nyepi, not on a fixed Gregorian date) require a
/// full Balinese lunisolar calendar algorithm. That has NOT been
/// implemented or verified against reference fixtures yet — per
/// COMPUTATION_LOGIC.md #10 ("Jika algoritma belum terverifikasi, tandai
/// feature sebagai incomplete daripada mengarang hasil"), those two
/// fields are intentionally left null rather than guessed from a naive
/// `gregorianYear - 78` offset.
class SakaCalendarResult {
  const SakaCalendarResult({
    required this.wuku,
    required this.wukuDayIndex,
    required this.pancawara,
    required this.saptawara,
    this.sasih,
    this.tahunSaka,
  });

  final String wuku;

  /// Day 1..7 within the current wuku week.
  final int wukuDayIndex;

  final String pancawara; // same cycle as Weton pasaran
  final String saptawara; // same cycle as Gregorian day name

  /// Not yet implemented — see class doc. Null until a verified lunisolar
  /// algorithm is added.
  final String? sasih;

  /// Not yet implemented — see class doc.
  final int? tahunSaka;

  /// True once [sasih] and [tahunSaka] are backed by a verified algorithm.
  /// Always false in this MVP — UI should show these as "Segera hadir" /
  /// incomplete rather than fabricated values.
  bool get isLunarDataComplete => sasih != null && tahunSaka != null;
}

/// Calculates the verified portion of the Saka Bali / Pawukon calendar
/// for a Gregorian [date]: Wuku, Pancawara, and Saptawara.
///
/// Pure function — no BuildContext/DB.
SakaCalendarResult calculateSakaCalendar(DateTime date) {
  final normalizedDate = DateTime(date.year, date.month, date.day);
  final normalizedEpoch =
      DateTime(_wukuEpoch.year, _wukuEpoch.month, _wukuEpoch.day);
  final diff = normalizedDate.difference(normalizedEpoch).inDays;

  final cycleLength = wukuCycle.length * 7; // 210
  var positionInCycle = diff % cycleLength;
  if (positionInCycle < 0) positionInCycle += cycleLength;

  final wukuIndex = positionInCycle ~/ 7;
  final dayIndexInWuku = positionInCycle % 7; // 0..6

  return SakaCalendarResult(
    wuku: wukuCycle[wukuIndex],
    wukuDayIndex: dayIndexInWuku + 1,
    pancawara: weton.pasaranForDate(date),
    saptawara: weton.dayNameForDate(date),
  );
}
