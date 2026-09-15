import 'app_exception.dart';

/// Abstract base class for failures that can be returned from services or repositories.
///
/// Subclasses should provide a user‑friendly [message] describing the failure.
abstract class Failure extends AppException {
  Failure(super.message);
}
