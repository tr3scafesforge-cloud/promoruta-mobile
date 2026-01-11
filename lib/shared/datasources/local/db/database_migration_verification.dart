import 'package:promoruta/core/utils/logger.dart';
import 'database.dart';

/// Utility class to verify database migrations
class DatabaseMigrationVerification {
  final AppDatabase db;

  DatabaseMigrationVerification(this.db);

  /// Verify the current schema version
  Future<int> getSchemaVersion() async {
    final result = await db.customSelect('PRAGMA user_version').get();
    final version = result.first.read<int>('user_version');
    AppLogger.database.i('Current database schema version: $version');
    return version;
  }

  /// Get all tables in the database
  Future<List<String>> getAllTables() async {
    final result = await db.customSelect(
      "SELECT name FROM sqlite_master WHERE type='table' ORDER BY name",
    ).get();

    final tables = result.map((row) => row.read<String>('name')).toList();
    AppLogger.database.i('Database tables: $tables');
    return tables;
  }

  /// Get all columns for a specific table
  Future<Map<String, String>> getTableColumns(String tableName) async {
    final result = await db.customSelect('PRAGMA table_info($tableName)').get();

    final columns = <String, String>{};
    for (final row in result) {
      final name = row.read<String>('name');
      final type = row.read<String>('type');
      columns[name] = type;
    }

    AppLogger.database.i('Columns in $tableName: $columns');
    return columns;
  }

  /// Verify that all expected columns exist in the Users table
  Future<bool> verifyUsersTableSchema() async {
    AppLogger.database.i('Verifying Users table schema...');

    final columns = await getTableColumns('users');

    // Expected columns in schema version 6
    final expectedColumns = [
      'id',
      'name',
      'email',
      'email_verified_at',
      'role',
      'created_at',
      'updated_at',
      'access_token',
      'token_expiry',
      'username',
      'photo_url',
      'refresh_expires_in',
      'refresh_token',
      'two_factor_enabled',        // Schema v6
      'two_factor_confirmed_at',   // Schema v6
    ];

    final missingColumns = <String>[];
    for (final expectedColumn in expectedColumns) {
      if (!columns.containsKey(expectedColumn)) {
        missingColumns.add(expectedColumn);
      }
    }

    if (missingColumns.isEmpty) {
      AppLogger.database.i('✓ All expected columns are present in Users table');
      return true;
    } else {
      AppLogger.database.e('✗ Missing columns in Users table: $missingColumns');
      return false;
    }
  }

  /// Verify all table schemas
  Future<void> verifyAllSchemas() async {
    AppLogger.database.i('=== DATABASE MIGRATION VERIFICATION ===');

    // Check schema version
    final version = await getSchemaVersion();
    if (version == 6) {
      AppLogger.database.i('✓ Schema version is correct (6)');
    } else {
      AppLogger.database.w('✗ Schema version is $version, expected 6');
    }

    // Check all tables exist
    final tables = await getAllTables();
    final expectedTables = ['users', 'campaigns_entity', 'routes', 'gps_points'];
    final missingTables = expectedTables.where((t) => !tables.contains(t)).toList();

    if (missingTables.isEmpty) {
      AppLogger.database.i('✓ All expected tables exist');
    } else {
      AppLogger.database.e('✗ Missing tables: $missingTables');
    }

    // Verify Users table schema
    await verifyUsersTableSchema();

    // Verify other tables
    await getTableColumns('campaigns_entity');
    await getTableColumns('routes');
    await getTableColumns('gps_points');

    AppLogger.database.i('=== VERIFICATION COMPLETE ===');
  }

  /// Test that 2FA columns can be read and written
  Future<void> test2FAColumns() async {
    AppLogger.database.i('Testing 2FA columns...');

    try {
      // Try to query the 2FA columns
      final result = await db.customSelect(
        'SELECT two_factor_enabled, two_factor_confirmed_at FROM users LIMIT 1',
      ).get();

      if (result.isEmpty) {
        AppLogger.database.i('✓ 2FA columns exist (no users to test with)');
      } else {
        final twoFactorEnabled = result.first.readNullable<int>('two_factor_enabled');
        final twoFactorConfirmedAt = result.first.readNullable<DateTime>('two_factor_confirmed_at');
        AppLogger.database.i('✓ 2FA columns can be read: enabled=$twoFactorEnabled, confirmedAt=$twoFactorConfirmedAt');
      }
    } catch (e) {
      AppLogger.database.e('✗ Error testing 2FA columns: $e');
    }
  }
}

/// Example usage in your app
///
/// ```dart
/// final db = AppDatabase();
/// final verification = DatabaseMigrationVerification(db);
///
/// // Run full verification
/// await verification.verifyAllSchemas();
///
/// // Or check specific things
/// final version = await verification.getSchemaVersion();
/// final isValid = await verification.verifyUsersTableSchema();
/// await verification.test2FAColumns();
/// ```
