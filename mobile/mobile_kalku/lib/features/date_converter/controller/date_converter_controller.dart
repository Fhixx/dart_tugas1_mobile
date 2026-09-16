import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../domain/calculators/age_calculator.dart';
import '../../../domain/calculators/bali_calendar_converter.dart';
import '../../../domain/calculators/hijri_converter.dart';
import '../../../domain/calculators/weton_calculator.dart';

/// Segment filter options for the Date Converter screen
/// (DESIGN_SYSTEM.md #16 / MENU_IMPLEMENTATION.md #11).
enum DateConverterFilter { semua, masehi, hijriah, weton, sakaBali }

/// Controller for the Date Converter screen.
///
/// [selectedDateTime] is the single source of truth
/// (MENU_IMPLEMENTATION.md #11) — every card (Masehi/Hijriah/Weton/Saka
/// Bali/Usia) is derived from it. Changing the segment [filter] only
/// changes which cards are visible; it never changes the selected date.
///
/// Owns a 1-second timer purely to refresh the realtime age display
/// (COMPUTATION_LOGIC.md #6) — the timer never touches the calculators
/// themselves, and is cancelled in [dispose].
class DateConverterController extends ChangeNotifier {
  DateConverterController({DateTime? initialDateTime})
      : selectedDateTime = initialDateTime ?? DateTime.now(),
        _now = DateTime.now() {
    _startAgeTicker();
  }

  DateTime selectedDateTime;
  DateConverterFilter filter = DateConverterFilter.semua;

  DateTime _now;
  Timer? _ageTicker;

  void setSelectedDateTime(DateTime value) {
    selectedDateTime = value;
    notifyListeners();
  }

  void setFilter(DateConverterFilter value) {
    if (filter == value) return;
    filter = value;
    notifyListeners();
  }

  bool isVisible(DateConverterFilter card) {
    return filter == DateConverterFilter.semua || filter == card;
  }

  AgeCalculationOutcome get ageOutcome =>
      calculateAge(birth: selectedDateTime, now: _now);

  HijriConversionOutcome get hijriOutcome => convertToHijri(selectedDateTime);

  WetonResult get wetonResult => calculateWeton(selectedDateTime);

  SakaCalendarResult get sakaResult => calculateSakaCalendar(selectedDateTime);

  void _startAgeTicker() {
    _ageTicker?.cancel();
    _ageTicker = Timer.periodic(const Duration(seconds: 1), (_) {
      _now = DateTime.now();
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _ageTicker?.cancel();
    super.dispose();
  }
}
