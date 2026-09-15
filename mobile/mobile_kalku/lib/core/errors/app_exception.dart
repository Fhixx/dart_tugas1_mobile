/// Base class for all custom exceptions in the project.
///
/// Extends the standard [Exception] class and provides a helpful
/// [message] property for debugging and error handling.
class AppException implements Exception {
  final String message;

  AppException(this.message);

  @override
  String toString() => 'AppException: $message';
}
