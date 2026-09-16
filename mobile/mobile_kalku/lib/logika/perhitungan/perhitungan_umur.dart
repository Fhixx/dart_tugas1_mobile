import '../../inti/utilitas/utilitas_tanggal.dart' as du;
import 'kesalahan_perhitungan.dart';

/// Calendar-accurate age breakdown, normalized per COMPUTATION_LOGIC.md #4:
/// `bulan` in 0..11, `jam` in 0..23, `menit`/`detik` in 0..59.
class AgeResult {
  const AgeResult({
    required this.years,
    required this.months,
    required this.days,
    required this.hours,
    required this.minutes,
    required this.seconds,
    required this.totalDays,
    required this.totalHours,
    required this.totalMinutes,
    required this.totalSeconds,
  });

  final int years;
  final int months;
  final int days;
  final int hours;
  final int minutes;
  final int seconds;

  /// Total elapsed metrics (COMPUTATION_LOGIC.md #5). `totalMonths` is
  /// intentionally omitted — calendar months have variable length, so a
  /// precise total-months figure needs an explicit model that this MVP
  /// does not define yet.
  final int totalDays;
  final int totalHours;
  final int totalMinutes;
  final int totalSeconds;
}

/// Outcome wrapper so calculators never return a bare null on failure
/// (COMPUTATION_LOGIC.md #16 — typed failure, not a random string).
class AgeCalculationOutcome {
  const AgeCalculationOutcome.success(this.result)
      : error = null;

  const AgeCalculationOutcome.failure(this.error)
      : result = null;

  final AgeResult? result;
  final CalculationError? error;

  bool get isSuccess => result != null;
}

/// Calculates a calendar-accurate age from [birth] to [now].
///
/// Pure function — no `BuildContext`, no timer. The controller owns the
/// 1-second timer and calls this repeatedly with an updated `now`
/// (COMPUTATION_LOGIC.md #6).
///
/// Validation per COMPUTATION_LOGIC.md #4:
/// - `birth` must not be after `now` -> [CalculationError.futureDate]
/// - resulting age must be <= 300 years -> [CalculationError.invalidAge]
AgeCalculationOutcome calculateAge({
  required DateTime birth,
  required DateTime now,
}) {
  if (birth.isAfter(now)) {
    return const AgeCalculationOutcome.failure(CalculationError.futureDate);
  }

  var years = now.year - birth.year;
  var candidate = du.DateUtils.safeAddYears(birth, years);
  if (candidate.isAfter(now)) {
    years--;
    candidate = du.DateUtils.safeAddYears(birth, years);
  }

  if (years > 300) {
    return const AgeCalculationOutcome.failure(CalculationError.invalidAge);
  }

  var months = 0;
  while (months < 11) {
    final next = du.DateUtils.addMonths(candidate, 1);
    if (next.isAfter(now)) break;
    candidate = next;
    months++;
  }

  final remaining = now.difference(candidate);
  final days = remaining.inDays;
  final hours = remaining.inHours % 24;
  final minutes = remaining.inMinutes % 60;
  final seconds = remaining.inSeconds % 60;

  final totalElapsed = now.difference(birth);

  return AgeCalculationOutcome.success(
    AgeResult(
      years: years,
      months: months,
      days: days,
      hours: hours,
      minutes: minutes,
      seconds: seconds,
      totalDays: totalElapsed.inDays,
      totalHours: totalElapsed.inHours,
      totalMinutes: totalElapsed.inMinutes,
      totalSeconds: totalElapsed.inSeconds,
    ),
  );
}
