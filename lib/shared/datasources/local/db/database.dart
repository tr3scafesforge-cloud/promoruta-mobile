import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:promoruta/core/core.dart';

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
  TextColumn get email => text()();
  TextColumn get role => text().map(const UserRoleConverter())();
  TextColumn get accessToken => text().nullable()();
  DateTimeColumn get tokenExpiry => dateTime().nullable()();
  TextColumn get username => text().nullable()();
  TextColumn get photoUrl => text().nullable()();
  DateTimeColumn get createdAt => dateTime().nullable()();

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
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onUpgrade: (migrator, from, to) async {
        if (from == 1) {
          // Migration from version 1 to 2: Add missing columns to Users table
          await migrator.addColumn(users, users.accessToken);
          await migrator.addColumn(users, users.tokenExpiry);
          await migrator.addColumn(users, users.username);
          await migrator.addColumn(users, users.photoUrl);
          await migrator.addColumn(users, users.createdAt);
        }
        if (from == 2) {
          await migrator.addColumn(users, users.username);
          await migrator.addColumn(users, users.photoUrl);
          await migrator.addColumn(users, users.createdAt);
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