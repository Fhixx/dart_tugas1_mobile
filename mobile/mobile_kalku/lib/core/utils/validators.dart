import 'sanitizers.dart';

/// Validation utilities for user input.
///
/// Each method returns a descriptive error string if validation fails,
/// or `null` if the input is valid.
class Validators {
  /// Validates a username:
  /// - required
  /// - length 3–32 after sanitization
  static String? validateUsername(String? input) {
    if (input == null || input.trim().isEmpty) {
      return 'Username is required';
    }
    final sanitized = Sanitizers.sanitizeUsername(input);
    if (sanitized.length < 3) {
      return 'Username must be at least 3 characters';
    }
    if (sanitized.length > 32) {
      return 'Username must be at most 32 characters';
    }
    return null;
  }

  /// Validates a password:
  /// - required
  /// - maximum 64 characters
  /// - "123" must remain valid
  static String? validatePassword(String? input) {
    if (input == null || input.isEmpty) {
      return 'Password is required';
    }
    if (input.length > 64) {
      return 'Password must be at most 64 characters';
    }
    return null;
  }

  /// Validates a name:
  /// - required
  /// - length 2–60
  /// - Unicode-friendly (handled naturally by Dart strings)
  static String? validateName(String? input) {
    if (input == null || input.trim().isEmpty) {
      return 'Name is required';
    }
    final sanitized = Sanitizers.sanitizeName(input);
    if (sanitized.length < 2) {
      return 'Name must be at least 2 characters';
    }
    if (sanitized.length > 60) {
      return 'Name must be at most 60 characters';
    }
    return null;
  }

  /// Validates age:
  /// - required
  /// - integer only (no decimals)
  /// - minimum 1
  /// - maximum 300
  static String? validateAge(String? input) {
    if (input == null || input.trim().isEmpty) {
      return 'Age is required';
    }
    // Reject decimals explicitly
    if (input.contains('.') || input.contains(',')) {
      return 'Age must be a whole number';
    }
    final age = int.tryParse(input.trim());
    if (age == null) {
      return 'Age must be a valid number';
    }
    if (age < 1) {
      return 'Age must be at least 1';
    }
    if (age > 300) {
      return 'Age must be at most 300';
    }
    return null;
  }

  /// Validates weight:
  /// - required
  /// - finite
  /// - > 0
  /// - <= 1000 kg
  /// - reject NaN, Infinity, -Infinity, negatives, zero
  static String? validateWeight(String? input) {
    if (input == null || input.trim().isEmpty) {
      return 'Weight is required';
    }
    final sanitized = Sanitizers.sanitizeNumeric(input);
    final weight = double.tryParse(sanitized);
    if (weight == null || weight.isNaN || weight.isInfinite) {
      return 'Weight must be a valid number';
    }
    if (weight <= 0) {
      return 'Weight must be greater than 0';
    }
    if (weight > 1000) {
      return 'Weight must be at most 1000 kg';
    }
    return null;
  }

  /// Validates height:
  /// - required
  /// - finite
  /// - > 0
  /// - <= 400 cm
  /// - reject NaN, Infinity, -Infinity, negatives, zero
  static String? validateHeight(String? input) {
    if (input == null || input.trim().isEmpty) {
      return 'Height is required';
    }
    final sanitized = Sanitizers.sanitizeNumeric(input);
    final height = double.tryParse(sanitized);
    if (height == null || height.isNaN || height.isInfinite) {
      return 'Height must be a valid number';
    }
    if (height <= 0) {
      return 'Height must be greater than 0';
    }
    if (height > 400) {
      return 'Height must be at most 400 cm';
    }
    return null;
  }
}
