import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../logika/perhitungan/perhitungan_umur.dart';
import '../../../logika/perhitungan/konversi_kalender_bali.dart';
import '../../../logika/perhitungan/konversi_hijriah.dart';
import '../../../logika/perhitungan/perhitungan_weton.dart';

/// Segment filter options for the Date Converter screen
/// (DESIGN_SYSTEM.md #16 / MENU_IMPLEMENTATION.md #11).
enum DateConverterFilter { semua, masehi, hijriah, weton, sakaBali }

/// Pengontrol (Controller) untuk layar Konversi Tanggal.
///
/// [selectedDateTime] merupakan sumber kebenaran tunggal (single source of truth)
/// (Sesuai MENU_IMPLEMENTATION.md #11) — semua kartu (Masehi/Hijriah/Weton/Saka
/// Bali/Usia) diturunkan dari variabel ini. Mengubah filter [filter] hanya
/// menentukan kartu mana yang terlihat; tindakan ini tidak pernah mengubah
/// tanggal yang dipilih.
///
/// Memiliki sebuah Timer 1-detik murni untuk memperbarui tampilan usia secara waktu nyata
/// (Sesuai COMPUTATION_LOGIC.md #6) — Timer tersebut sama sekali tidak memengaruhi
/// kalkulator itu sendiri, dan akan dibatalkan pada [dispose].
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
