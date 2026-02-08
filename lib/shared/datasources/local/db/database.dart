import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:promoruta/core/core.dart';
import 'package:promoruta/core/utils/logger.dart';
import 'package:drift/internal/versioned_schema.dart';

import 'db_migration.dart';
import 'entities/campaigns_entity.dart';

part 'database.g.dart';

// Type converters
class UserRoleConverter extends TypeConverter<UserRole, String> {
  const UserRoleConverter();

  @override
  UserRole fromSql(String fromDb) {
    return UserRole.fromString(fromDb);
  }

  @override
  String toSql(UserRole value) {
    return value.toStringValue();
  }
}

// Tables
class Users extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get email => text()();
  DateTimeColumn get emailVerifiedAt => dateTime().nullable()();
  TextColumn get role => text().map(const UserRoleConverter())();
  DateTimeColumn get createdAt => dateTime().nullable()();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  TextColumn get accessToken => text().nullable()();
  DateTimeColumn get tokenExpiry => dateTime().nullable()();
  TextColumn get username => text().nullable()();
  TextColumn get photoUrl => text().nullable()();
  DateTimeColumn get refreshExpiresIn => dateTime().nullable()();
  TextColumn get refreshToken => text().nullable()();
  BoolColumn get twoFactorEnabled =>
      boolean().withDefault(const Constant(false))();
  DateTimeColumn get twoFactorConfirmedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class Routes extends Table {
  TextColumn get id => text()();
  TextColumn get promoterId => text()();
  TextColumn get campaignId => text()();
  DateTimeColumn get startTime => dateTime()();
  DateTimeColumn get endTime => dateTime().nullable()();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

class GpsPoints extends Table {
  TextColumn get id => text()();
  TextColumn get routeId => text().references(Routes, #id).nullable()();
  TextColumn get campaignId =>
      text().nullable()(); // Campaign this point belongs to
  RealColumn get latitude => real()();
  RealColumn get longitude => real()();
  DateTimeColumn get timestamp => dateTime()();
  RealColumn get speed => real().nullable()();
  RealColumn get accuracy => real().nullable()();
  DateTimeColumn get syncedAt =>
      dateTime().nullable()(); // When synced to backend

  @override
  Set<Column> get primaryKey => {id};
}

// Database class
@DriftDatabase(tables: [Users, CampaignsEntity, Routes, GpsPoints])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 9;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (m) async {
        /// Create all tables
        AppLogger.database.i('Creating database schema version $schemaVersion');
        m.createAll();
      },
      onUpgrade: (m, from, to) async {
        AppLogger.database.i('Migrating database from version $from to $to');

        /// Run migration steps without foreign keys and re-enable them later
        /// (https://drift.simonbinder.eu/docs/advanced-features/migrations/#tips)
        await customStatement('PRAGMA foreign_keys = OFF');

        /// Handle migrations step by step for backward compatibility
        if (from <= 2) {
          // Handle legacy migrations 1->2 and 2->3 with direct column additions
          if (from == 1) {
            await transaction(() async {
              // Migration from version 1 to 2: Add missing columns to Users table
              await m.addColumn(users, users.accessToken);
              await m.addColumn(users, users.tokenExpiry);
              await m.addColumn(users, users.username);
              await m.addColumn(users, users.photoUrl);
              await m.addColumn(users, users.createdAt);

              // Create missing tables if they don't exist
              await m.createTable(campaignsEntity);
              await m.createTable(routes);
              await m.createTable(gpsPoints);
            });
          }
          if (from <= 2 && to > 2) {
            await transaction(() async {
              await m.addColumn(users, users.username);
              await m.addColumn(users, users.photoUrl);
              await m.addColumn(users, users.createdAt);

              // Create missing tables if they don't exist
              await m.createTable(campaignsEntity);
              await m.createTable(routes);
              await m.createTable(gpsPoints);
            });
          }
        }

        /// Use versioned schema approach for migrations from version 3 to 5
        if (from >= 3 && from < 5) {
          AppLogger.database.i(
              'Running versioned migrations from $from to ${to >= 5 ? 5 : to}');
          await transaction(
            () => VersionedSchema.runMigrationSteps(
              migrator: m,
              from: from,
              to: to >= 5 ? 5 : to,
              steps: migrationSteps(
                from3To4: (Migrator m, Schema4 schema) async {
                  AppLogger.database.i(
                      'Migration 3→4: Adding name, emailVerifiedAt, updatedAt to Users');
                  await m.addColumn(schema.users, schema.users.name);
                  await m.addColumn(schema.users, schema.users.emailVerifiedAt);
                  await m.addColumn(schema.users, schema.users.updatedAt);
                },
                from4To5: (Migrator m, Schema5 schema) async {
                  AppLogger.database.i(
                      'Migration 4→5: Adding refreshExpiresIn, refreshToken to Users');
                  await m.addColumn(
                      schema.users, schema.users.refreshExpiresIn);
                  await m.addColumn(schema.users, schema.users.refreshToken);
                },
              ),
            ),
          );
        }

        /// Handle migration from version 5 to 6 (add 2FA columns)
        if (from <= 5 && to >= 6) {
          AppLogger.database.i('Migration 5→6: Adding 2FA columns to Users');
          await transaction(() async {
            await m.addColumn(users, users.twoFactorEnabled);
            await m.addColumn(users, users.twoFactorConfirmedAt);
          });
        }

        /// Handle migration from version 6 to 7 (add GPS tracking columns)
        if (from <= 6 && to >= 7) {
          AppLogger.database
              .i('Migration 6→7: Adding campaignId and syncedAt to GpsPoints');
          await transaction(() async {
            // Check if gps_points table exists (may not exist for databases migrated from v3+)
            final gpsTableExists = await customSelect(
              "SELECT name FROM sqlite_master WHERE type='table' AND name='gps_points'",
            ).get();

            if (gpsTableExists.isEmpty) {
              // Check if routes table exists first (gps_points has FK to routes)
              final routesTableExists = await customSelect(
                "SELECT name FROM sqlite_master WHERE type='table' AND name='routes'",
              ).get();

              if (routesTableExists.isEmpty) {
                AppLogger.database.i('Creating missing routes table');
                await m.createTable(routes);
              }

              AppLogger.database.i('Creating missing gps_points table');
              await m.createTable(gpsPoints);
            } else {
              // Table exists, just add the new columns
              await m.addColumn(gpsPoints, gpsPoints.campaignId);
              await m.addColumn(gpsPoints, gpsPoints.syncedAt);
            }
          });
        }

        /// Handle migration from version 7 to 8 (rename campaign columns and add new fields)
        if (from <= 7 && to >= 8) {
          AppLogger.database.i(
              'Migration 7→8: Renaming campaign columns and adding zone/suggestedPrice');
          await transaction(() async {
            // Check if campaigns_entity table exists
            final campaignsTableExists = await customSelect(
              "SELECT name FROM sqlite_master WHERE type='table' AND name='campaigns_entity'",
            ).get();

            if (campaignsTableExists.isNotEmpty) {
              // SQLite doesn't support ALTER TABLE RENAME COLUMN in older versions
              // We need to recreate the table with the new schema
              // Step 1: Create new table with new column names
              await customStatement('''
                CREATE TABLE campaigns_entity_new (
                  id TEXT NOT NULL PRIMARY KEY,
                  title TEXT NOT NULL,
                  description TEXT NOT NULL,
                  created_by_id TEXT NOT NULL,
                  start_time INTEGER NOT NULL,
                  end_time INTEGER NOT NULL,
                  status TEXT NOT NULL DEFAULT 'active',
                  zone TEXT NOT NULL DEFAULT '',
                  suggested_price REAL NOT NULL DEFAULT 0.0
                )
              ''');

              // Step 2: Copy data from old table to new table
              await customStatement('''
                INSERT INTO campaigns_entity_new (id, title, description, created_by_id, start_time, end_time, status, zone, suggested_price)
                SELECT id, title, description, advertiser_id, start_date, end_date, status, '', 0.0
                FROM campaigns_entity
              ''');

              // Step 3: Drop old table
              await customStatement('DROP TABLE campaigns_entity');

              // Step 4: Rename new table to original name
              await customStatement(
                  'ALTER TABLE campaigns_entity_new RENAME TO campaigns_entity');

              AppLogger.database.i('Campaign table migration completed');
            } else {
              // Table doesn't exist, create it with new schema
              AppLogger.database.i('Creating campaigns_entity table with new schema');
              await m.createTable(campaignsEntity);
            }
          });
        }

        /// Handle migration from version 8 to 9 (add performance indexes)
        if (from <= 8 && to >= 9) {
          AppLogger.database.i('Migration 8→9: Adding performance indexes');
          await transaction(() async {
            try {
              // Indexes for GpsPoints table
              await customStatement(
                'CREATE INDEX IF NOT EXISTS idx_gps_points_route_id ON gps_points(route_id)',
              );
              await customStatement(
                'CREATE INDEX IF NOT EXISTS idx_gps_points_campaign_id ON gps_points(campaign_id)',
              );
              await customStatement(
                'CREATE INDEX IF NOT EXISTS idx_gps_points_synced_at ON gps_points(synced_at)',
              );
              await customStatement(
                'CREATE INDEX IF NOT EXISTS idx_gps_points_route_synced ON gps_points(route_id, synced_at)',
              );

              // Indexes for CampaignsEntity table
              await customStatement(
                'CREATE INDEX IF NOT EXISTS idx_campaigns_status ON campaigns_entity(status)',
              );
              await customStatement(
                'CREATE INDEX IF NOT EXISTS idx_campaigns_created ON campaigns_entity(created_by_id)',
              );

              AppLogger.database.i('Performance indexes created successfully');
            } catch (e) {
              AppLogger.database.w('Error creating indexes: $e');
              // Don't fail migration if indexes already exist
            }
          });
        }

        AppLogger.database.i('Database migration completed successfully');
      },
      beforeOpen: (details) async {
        /// Enable foreign_keys
        await customStatement('PRAGMA foreign_keys = ON');

        if (details.wasCreated) {
          AppLogger.database
              .i('Database created with schema version $schemaVersion');
        } else if (details.hadUpgrade) {
          AppLogger.database.i(
              'Database upgraded from ${details.versionBefore} to ${details.versionNow}');
        }
      },
    );
  }

  static LazyDatabase _openConnection() {
    return LazyDatabase(() async {
      final dbFolder = await getApplicationDocumentsDirectory();
      final file = File(p.join(dbFolder.path, 'promoruta_v2.db'));
      return NativeDatabase.createInBackground(file);
    });
  }
}
