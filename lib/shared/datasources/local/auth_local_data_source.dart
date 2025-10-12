import 'package:drift/drift.dart';

import '../../../core/models/user.dart' as model;
import '../../repositories/auth_repository.dart';
import 'db/database.dart';

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final AppDatabase db;

  AuthLocalDataSourceImpl(this.db);

  @override
  Future<void> saveUser(model.User user) async {
    await db.into(db.users).insertOnConflictUpdate(
      UsersCompanion(
        id: Value(user.id),
        email: Value(user.email),
        role: Value(user.role),
        accessToken: Value(user.accessToken),
        tokenExpiry: Value(user.tokenExpiry),
        username: Value(user.username),
        photoUrl: Value(user.photoUrl),
        createdAt: Value(user.createdAt),
      ),
    );
  }

  @override
  Future<model.User?> getUser() async {
    final userRow = await db.select(db.users).getSingleOrNull();
    if (userRow == null) return null;

    return model.User(
      id: userRow.id,
      email: userRow.email,
      role: userRow.role,
      accessToken: userRow.accessToken,
      tokenExpiry: userRow.tokenExpiry,
      username: userRow.username,
      photoUrl: userRow.photoUrl,
      createdAt: userRow.createdAt,
    );
  }

  @override
  Future<void> clearUser() async {
    await db.delete(db.users).go();
  }
}