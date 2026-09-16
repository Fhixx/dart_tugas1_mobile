import 'pengecualian_aplikasi.dart';

/// Represents a failure that occurs when interacting with the database.
class DatabaseFailure extends AppException {
  DatabaseFailure(super.message);
}
