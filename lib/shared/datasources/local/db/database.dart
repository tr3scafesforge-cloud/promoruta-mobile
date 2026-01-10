import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:promoruta/core/core.dart';
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
  BoolColumn get twoFactorEnabled => boolean().withDefault(const Constant(false))();
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
  TextColumn get routeId => text().references(Routes, #id)();
  RealColumn get latitude => real()();
  RealColumn get longitude => real()();
  DateTimeColumn get timestamp => dateTime()();
  RealColumn get speed => real().nullable()();
  RealColumn get accuracy => real().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

// Database class
@DriftDatabase(tables: [Users, CampaignsEntity, Routes, GpsPoints])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 6;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (m) async {
        /// Create all tables
        m.createAll();
      },
      onUpgrade: (m, from, to) async {
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

        /// Use versioned schema approach for migrations from version 3 onwards
        await transaction(
          () => VersionedSchema.runMigrationSteps(
            migrator: m,
            from: from > 2 ? from : 3,
            to: to,
            steps: migrationSteps(
              from3To4: (Migrator m, Schema4 schema) async {
                await m.addColumn(schema.users, schema.users.name);
                await m.addColumn(schema.users, schema.users.emailVerifiedAt);
                await m.addColumn(schema.users, schema.users.updatedAt);
              },
              from4To5: (Migrator m, Schema5 schema) async {
                await m.addColumn(schema.users, schema.users.refreshExpiresIn);
                await m.addColumn(schema.users, schema.users.refreshToken);
              },
              from5To6: (Migrator m, Schema6 schema) async {
                await m.addColumn(schema.users, schema.users.twoFactorEnabled);
                await m.addColumn(schema.users, schema.users.twoFactorConfirmedAt);
              },
              
            ),
          ),
        );
      },
      beforeOpen: (details) async {
        /// Enable foreign_keys
        await customStatement('PRAGMA foreign_keys = ON');
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