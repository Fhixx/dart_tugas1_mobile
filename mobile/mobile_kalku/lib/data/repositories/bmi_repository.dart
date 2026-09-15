import 'package:sqflite/sqflite.dart';
import '../../core/errors/database_failure.dart';
import '../models/bmi_record.dart';

/// Repository for CRUD operations on the `bmi_records` table.
///
/// All queries are parameterized — never use string interpolation for
/// user-supplied values. Every query that accesses user-owned records
/// is scoped by [userId] to enforce data isolation.
///
/// The repository does NOT recalculate BMI; it persists already-validated,
/// already-calculated data from the domain/controller layer.
class BmiRepository {
  final Database _db;

  /// [_db] is injected to make the repository testable without relying on
  /// the singleton [DatabaseHelper].
  BmiRepository(this._db);

  // ── Create ─────────────────────────────────────────────────────────────────

  /// Inserts a new [BmiRecord] and returns the auto-generated row ID.
  ///
  /// Throws [DatabaseFailure] if the insert fails.
  Future<int> insert(BmiRecord record) async {
    try {
      final map = record.toMap()..remove('id'); // let SQLite auto-generate id
      return await _db.insert('bmi_records', map);
    } catch (e) {
      throw DatabaseFailure('Gagal menyimpan data BMI: $e');
    }
  }

  // ── Read ───────────────────────────────────────────────────────────────────

  /// Returns all BMI records belonging to [userId], ordered newest first.
  ///
  /// Returns an empty list if the user has no records.
  Future<List<BmiRecord>> getAllByUser(int userId) async {
    try {
      final maps = await _db.query(
        'bmi_records',
        where: 'user_id = ?',
        whereArgs: [userId],
        orderBy: 'created_at DESC',
      );
      return maps.map(BmiRecord.fromMap).toList();
    } catch (e) {
      throw DatabaseFailure('Gagal membaca data BMI: $e');
    }
  }

  /// Returns a single [BmiRecord] by [id] that belongs to [userId],
  /// or `null` if no matching record exists.
  ///
  /// The [userId] check enforces user-data isolation.
  Future<BmiRecord?> getById({required int id, required int userId}) async {
    try {
      final maps = await _db.query(
        'bmi_records',
        where: 'id = ? AND user_id = ?',
        whereArgs: [id, userId],
        limit: 1,
      );
      if (maps.isEmpty) return null;
      return BmiRecord.fromMap(maps.first);
    } catch (e) {
      throw DatabaseFailure('Gagal membaca data BMI: $e');
    }
  }

  // ── Update ─────────────────────────────────────────────────────────────────

  /// Updates an existing [BmiRecord] and returns the number of rows affected.
  ///
  /// Requires `record.id` and `record.userId` to be non-null.
  /// Only updates rows where both `id` AND `user_id` match to enforce isolation.
  /// [record.createdAt] is preserved; [record.updatedAt] is expected to be
  /// set by the caller before invoking this method.
  Future<int> update(BmiRecord record) async {
    assert(record.id != null, 'BmiRepository.update requires a non-null record.id');
    try {
      final map = record.toMap();
      return await _db.update(
        'bmi_records',
        map,
        where: 'id = ? AND user_id = ?',
        whereArgs: [record.id, record.userId],
      );
    } catch (e) {
      throw DatabaseFailure('Gagal memperbarui data BMI: $e');
    }
  }

  // ── Delete ─────────────────────────────────────────────────────────────────

  /// Deletes a single BMI record by [id] owned by [userId].
  ///
  /// Returns the number of rows deleted (0 if record not found or not owned).
  /// Does NOT delete user accounts, sessions, or other records.
  Future<int> deleteById({required int id, required int userId}) async {
    try {
      return await _db.delete(
        'bmi_records',
        where: 'id = ? AND user_id = ?',
        whereArgs: [id, userId],
      );
    } catch (e) {
      throw DatabaseFailure('Gagal menghapus data BMI: $e');
    }
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  /// Returns the total number of BMI records for [userId].
  Future<int> countByUser(int userId) async {
    try {
      final result = await _db.rawQuery(
        'SELECT COUNT(*) FROM bmi_records WHERE user_id = ?',
        [userId],
      );
      return Sqflite.firstIntValue(result) ?? 0;
    } catch (e) {
      throw DatabaseFailure('Gagal menghitung data BMI: $e');
    }
  }
}
