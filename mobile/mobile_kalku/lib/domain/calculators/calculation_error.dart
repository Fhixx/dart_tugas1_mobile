/// Typed calculation failures shared across domain calculators.
///
/// See COMPUTATION_LOGIC.md #16. UI layer is responsible for translating
/// these into Bahasa Indonesia user-facing copy — never surface the enum
/// name directly to the user.
enum CalculationError {
  invalidWeight,
  invalidHeight,
  invalidAge,
  futureDate,
  unsupportedDateRange,
}
