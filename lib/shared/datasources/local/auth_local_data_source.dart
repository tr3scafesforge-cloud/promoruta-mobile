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
        token: Value(user.token),
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
      token: userRow.token,
    );
  }

  @override
  Future<void> clearUser() async {
    await db.delete(db.users).go();
  }
}