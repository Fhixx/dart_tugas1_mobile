import 'package:flutter/foundation.dart';

import '../../../domain/calculators/bali_calendar_converter.dart';
import '../../../domain/calculators/weton_calculator.dart';

/// Controller for the Kalender Nusantara screen.
///
/// Focused on Weton + Saka Bali detail (MENU_IMPLEMENTATION.md #12).
/// Input stays Gregorian — [selectedDate] is the single source of truth.
/// No realtime timer here (unlike Date Converter's Usia card); this
/// screen has no time-dependent field.
class NusantaraCalendarController extends ChangeNotifier {
  NusantaraCalendarController({DateTime? initialDate})
      : selectedDate = initialDate ?? DateTime.now();

  DateTime selectedDate;

  void setSelectedDate(DateTime value) {
    selectedDate = DateTime(value.year, value.month, value.day);
    notifyListeners();
  }

  WetonResult get wetonResult => calculateWeton(selectedDate);

  SakaCalendarResult get sakaResult => calculateSakaCalendar(selectedDate);
}
