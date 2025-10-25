import 'package:drift/drift.dart';

import '../../../core/models/user.dart' as model;
import 'db/database.dart';

abstract class UserLocalDataSource {
  Future<void> saveUser(model.User user);
  Future<model.User?> getUser(String userId);
  Future<void> clearUser(String userId);
}

class UserLocalDataSourceImpl implements UserLocalDataSource {
  final AppDatabase db;

  UserLocalDataSourceImpl(this.db);

  @override
  Future<void> saveUser(model.User user) async {
    await db.into(db.users).insertOnConflictUpdate(
      UsersCompanion(
        id: Value(user.id),
        name: Value(user.name),
        email: Value(user.email),
        emailVerifiedAt: Value(user.emailVerifiedAt),
        role: Value(user.role),
        createdAt: Value(user.createdAt),
        updatedAt: Value(user.updatedAt),
        accessToken: Value(user.accessToken),
        tokenExpiry: Value(user.tokenExpiry),
        username: Value(user.username),
        photoUrl: Value(user.photoUrl),
      ),
    );
  }

  @override
  Future<model.User?> getUser(String userId) async {
    final userRow = await (db.select(db.users)..where((tbl) => tbl.id.equals(userId))).getSingleOrNull();
    if (userRow == null) return null;

    return model.User(
      id: userRow.id,
      name: userRow.name!,
      email: userRow.email,
      emailVerifiedAt: userRow.emailVerifiedAt,
      role: userRow.role,
      createdAt: userRow.createdAt,
      updatedAt: userRow.updatedAt,
      accessToken: userRow.accessToken,
      tokenExpiry: userRow.tokenExpiry,
      username: userRow.username,
      photoUrl: userRow.photoUrl,
    );
  }

  @override
  Future<void> clearUser(String userId) async {
    await (db.delete(db.users)..where((tbl) => tbl.id.equals(userId))).go();
  }
}