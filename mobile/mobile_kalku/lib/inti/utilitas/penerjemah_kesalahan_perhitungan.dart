import '../../logika/perhitungan/kesalahan_perhitungan.dart';

/// Translates [CalculationError] into user-facing Indonesian copy.
/// COMPUTATION_LOGIC.md #16: "UI layer menerjemahkan ke Bahasa Indonesia."
String calculationErrorMessage(CalculationError error) {
  switch (error) {
    case CalculationError.invalidWeight:
      return 'Berat badan tidak valid.';
    case CalculationError.invalidHeight:
      return 'Tinggi badan tidak valid.';
    case CalculationError.invalidAge:
      return 'Umur melebihi batas maksimum (300 tahun).';
    case CalculationError.futureDate:
      return 'Tanggal berada di masa depan.';
    case CalculationError.unsupportedDateRange:
      return 'Tanggal berada di luar rentang yang didukung.';
  }
}
