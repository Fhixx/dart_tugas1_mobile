import 'package:flutter/foundation.dart';

import '../../../logika/perhitungan/konversi_kalender_bali.dart';
import '../../../logika/perhitungan/perhitungan_weton.dart';

/// Pengontrol (Controller) untuk layar Kalender Nusantara.
///
/// Berfokus pada detail Weton + Saka Bali (Sesuai MENU_IMPLEMENTATION.md #12).
/// Input tetap dalam format Masehi (Gregorian) — [selectedDate] adalah
/// sumber kebenaran tunggal (single source of truth).
/// Tidak ada Timer waktu nyata di sini (berbeda dengan fitur Usia pada
/// Konversi Tanggal); layar ini tidak memiliki parameter yang bergantung waktu secara realtime.
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
