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
      RawValuesInsertable({
        'id': Variable<String>(user.id),
        'email': Variable<String>(user.email),
        'role': Variable<String>(user.role),
        'access_token': Variable<String>(user.accessToken),
        'token_expiry': Variable<DateTime>(user.tokenExpiry),
      }),
    );
  }

  @override
  Future<model.User?> getUser() async {
    final userRow = await db.select(db.users).getSingleOrNull();
    if (userRow == null) return null;

    return model.User.fromJson(userRow.toJson());
  }

  @override
  Future<void> clearUser() async {
    await db.delete(db.users).go();
  }
}