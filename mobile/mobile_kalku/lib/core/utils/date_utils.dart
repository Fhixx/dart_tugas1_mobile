/// Shared date helpers used by domain calculators.
///
/// Pure functions only — no BuildContext, no I/O. See
/// COMPUTATION_LOGIC.md #4 (Leap-Day Rule) for the policy this
/// implements.
class DateUtils {
  DateUtils._();

  static bool isLeapYear(int year) {
    return (year % 4 == 0 && year % 100 != 0) || year % 400 == 0;
  }

  /// Adds [years] to [date], mapping 29 Feb -> 28 Feb when the target
  /// year is not a leap year (COMPUTATION_LOGIC.md #4 Leap-Day Rule).
  static DateTime safeAddYears(DateTime date, int years) {
    final targetYear = date.year + years;
    final isFeb29 = date.month == 2 && date.day == 29;
    final day = (isFeb29 && !isLeapYear(targetYear)) ? 28 : date.day;
    return DateTime(
      targetYear,
      date.month,
      day,
      date.hour,
      date.minute,
      date.second,
      date.millisecond,
      date.microsecond,
    );
  }

  static const List<String> indonesianMonthNames = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];

  /// Formats [date] as `"16 September 2026"` without the `intl` package
  /// (kept dependency-free until pubspec.yaml coordination with Dev 1).
  static String formatFullDate(DateTime date) {
    return '${date.day} ${indonesianMonthNames[date.month - 1]} ${date.year}';
  }

  /// Formats the time-of-day portion of [date] as `"HH:MM"`.
  static String formatTime(DateTime date) {
    String pad2(int value) => value.toString().padLeft(2, '0');
    return '${pad2(date.hour)}:${pad2(date.minute)}';
  }

  /// Adds [months] to [date], clamping the day-of-month to the target
  /// month's length (e.g. 31 Jan + 1 month -> 28/29 Feb).
  static DateTime addMonths(DateTime date, int months) {
    final totalMonths = (date.year * 12 + (date.month - 1)) + months;
    final year = totalMonths ~/ 12;
    final month = totalMonths % 12 + 1;
    final daysInTargetMonth = DateTime(year, month + 1, 0).day;
    final day = date.day > daysInTargetMonth ? daysInTargetMonth : date.day;
    return DateTime(
      year,
      month,
      day,
      date.hour,
      date.minute,
      date.second,
      date.millisecond,
      date.microsecond,
    );
  }
}
