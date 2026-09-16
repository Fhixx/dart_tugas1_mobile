import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'migrasi/migrasi_versi_1.dart';

/// Helper class that provides a singleton instance of the SQLite database.
///
/// The database is opened lazily on first access. On creation it runs the
/// version‑1 migration (`MigrationV1.up`). Future upgrades should be added in
/// `onUpgrade` following the same pattern.
class DatabaseHelper {
  static const _databaseName = 'nusafit.db';
  static const _databaseVersion = 1;

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;

  /// Returns the opened database, creating it if necessary.
  Future<Database> get database async {
    if (_database != null) return _database!;
    // lazily instantiate the db the first time it is accessed
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, _databaseName);
    // open the database, applying the migration on first creation
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: (Database db, int version) async {
        // Enable foreign keys for SQLite
        await db.execute('PRAGMA foreign_keys = ON');
        await MigrationV1.up(db);
      },
      onUpgrade: (Database db, int oldVersion, int newVersion) async {
        // Future migrations go here, e.g.:
        // if (oldVersion < 2) await MigrationV2.up(db);
      },
      onConfigure: (Database db) async {
        // Ensure foreign keys are enforced for all connections
        await db.execute('PRAGMA foreign_keys = ON');
      },
    );
  }

  /// Convenience method used by other helpers to obtain the database.
  static Future<Database> getDatabase() async => await instance.database;

  /// Closes and resets the database instance (for testing only).
  static Future<void> resetForTesting() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}
