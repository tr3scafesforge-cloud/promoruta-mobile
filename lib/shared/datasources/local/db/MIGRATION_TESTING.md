# Database Migration Testing Guide

This guide shows how to verify that your database migration from version 5 to 6 ran correctly.

## What Changed in Version 6

The migration adds two new columns to the `users` table:
- `two_factor_enabled` (BOOLEAN, default: false)
- `two_factor_confirmed_at` (DATETIME, nullable)

## Method 1: Check Logs (Easiest)

When you run your app after updating the schema version, you'll see migration logs in your console:

```
[DATABASE] Migrating database from version 5 to 6
[DATABASE] Migration 5→6: Adding 2FA columns to Users
[DATABASE] Database migration completed successfully
[DATABASE] Database upgraded from 5 to 6
```

If you see these logs, the migration ran successfully!

## Method 2: Programmatic Verification

Use the `DatabaseMigrationVerification` utility in your code:

```dart
import 'package:promoruta/shared/datasources/local/db/database.dart';
import 'package:promoruta/shared/datasources/local/db/database_migration_verification.dart';

// In your app initialization or a test
void verifyMigration() async {
  final db = AppDatabase();
  final verification = DatabaseMigrationVerification(db);

  // Run full verification
  await verification.verifyAllSchemas();

  // Check specific things
  final version = await verification.getSchemaVersion();
  print('Schema version: $version'); // Should be 6

  final isValid = await verification.verifyUsersTableSchema();
  print('Users table valid: $isValid'); // Should be true

  await verification.test2FAColumns();
}
```

## Method 3: Manual Database Inspection

### On Android:
1. Connect your device/emulator
2. Run: `adb shell`
3. Navigate to: `cd /data/data/com.yourpackage.promoruta/app_flutter`
4. Open SQLite: `sqlite3 promoruta_v2.db`
5. Check schema:
   ```sql
   .schema users
   PRAGMA user_version;
   SELECT two_factor_enabled, two_factor_confirmed_at FROM users;
   ```

### On iOS:
1. In Xcode, go to Window → Devices and Simulators
2. Select your device
3. Click the gear icon → Download Container
4. Navigate to `AppData/Documents/promoruta_v2.db`
5. Open with SQLite browser

### Using Android Studio's Database Inspector:
1. Run your app in debug mode
2. View → Tool Windows → App Inspection
3. Select Database Inspector tab
4. Select your app process
5. Browse the `users` table and verify the new columns exist

## Method 4: Force Migration Testing

To test the migration from scratch:

1. **Uninstall the app** to delete the old database
2. **Reinstall** the app - this will create a new database with schema v6
3. Check logs to verify it says "Database created with schema version 6"

To test migration from v5 to v6:

1. **Rollback your code** to schema version 5 (before adding 2FA)
2. **Run the app** to create v5 database
3. **Add some test data**
4. **Update to schema version 6** (current code)
5. **Run the app again** and check logs for migration messages

## Method 5: Unit Test

Create a test in `test/shared/datasources/local/db/database_migration_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:promoruta/shared/datasources/local/db/database.dart';

void main() {
  test('Database migration from v5 to v6 adds 2FA columns', () async {
    // Create in-memory database
    final db = AppDatabase.forTesting(NativeDatabase.memory());

    // Verify schema version
    final version = await db.customSelect('PRAGMA user_version').getSingle();
    expect(version.read<int>('user_version'), equals(6));

    // Verify 2FA columns exist
    final columns = await db.customSelect('PRAGMA table_info(users)').get();
    final columnNames = columns.map((c) => c.read<String>('name')).toList();

    expect(columnNames, contains('two_factor_enabled'));
    expect(columnNames, contains('two_factor_confirmed_at'));
  });
}
```

## Expected Results

After successful migration, you should see:

✓ Schema version: 6
✓ Users table has 15 columns (including `two_factor_enabled` and `two_factor_confirmed_at`)
✓ All 4 tables exist: `users`, `campaigns_entity`, `routes`, `gps_points`
✓ No error logs during app startup
✓ You can insert/update/query user records with 2FA fields

## Troubleshooting

### Migration didn't run
- Check if `schemaVersion` in `database.dart` is set to 6
- Verify the app was restarted after code changes
- Check for error logs in the console

### Columns missing
- Clear app data and reinstall
- Run verification script to see detailed errors
- Check if build_runner generated latest code: `dart run build_runner build`

### Schema version stuck
- Database file might be corrupted
- Uninstall app completely
- Clear all app data
- Reinstall

## Quick Checklist

- [ ] `schemaVersion` in `database.dart` is set to 6
- [ ] Migration logs appear in console when app starts
- [ ] No errors in logs
- [ ] Verification script passes
- [ ] Can read/write 2FA columns
- [ ] App functions normally
