/// Sanitizer utilities for user input.
class Sanitizers {
  /// Sanitizes a username: trims whitespace and ensures consistent normalization.
  static String sanitizeUsername(String input) => input.trim();

  /// Sanitizes a name: trims whitespace and collapses repeated whitespace.
  /// Unicode characters are preserved natively by Dart strings.
  static String sanitizeName(String input) =>
      input.trim().replaceAll(RegExp(r'\s+'), ' ');

  /// Sanitizes a numeric string:
  /// - Trims whitespace
  /// - Supports Indonesian decimal comma by converting it to a dot.
  /// Does not attempt to "fix" inherently malformed strings (like multiple dots),
  /// leaving them to fail parsing later.
  static String sanitizeNumeric(String input) {
    return input.trim().replaceAll(',', '.');
  }
}
