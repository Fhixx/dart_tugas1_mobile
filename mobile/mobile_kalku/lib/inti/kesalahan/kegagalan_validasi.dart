import '../errors/failure.dart';

/// Represents a validation failure for a specific field.
///
/// Contains the [field] that failed validation and a human‑readable [message].
class ValidationFailure extends Failure {
  final String field;

  ValidationFailure(this.field, String message) : super(message);

  @override
  String toString() => 'ValidationFailure on "$field": $message';
}
