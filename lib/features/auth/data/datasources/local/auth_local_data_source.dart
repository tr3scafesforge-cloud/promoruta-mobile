import 'package:drift/drift.dart';

import '../../../../../core/models/user.dart' as model;
import '../../../../../shared/datasources/local/db/database.dart';
import '../../../domain/repositories/auth_repository.dart';

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final AppDatabase db;

  AuthLocalDataSourceImpl(this.db);

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
            refreshExpiresIn: Value(user.refreshExpiresIn!),
            refreshToken: Value(user.refreshToken!),
            twoFactorEnabled: Value(user.twoFactorEnabled),
            twoFactorConfirmedAt: Value(user.twoFactorConfirmedAt),
          ),
        );
  }

  @override
  Future<model.User?> getUser() async {
    final userRow = await db.select(db.users).getSingleOrNull();
    if (userRow == null) return null;

    return model.User(
      id: userRow.id,
      name: userRow.name,
      email: userRow.email,
      emailVerifiedAt: userRow.emailVerifiedAt,
      role: userRow.role,
      createdAt: userRow.createdAt,
      updatedAt: userRow.updatedAt,
      accessToken: userRow.accessToken,
      tokenExpiry: userRow.tokenExpiry,
      username: userRow.username,
      photoUrl: userRow.photoUrl,
      refreshExpiresIn: userRow.refreshExpiresIn,
      refreshToken: userRow.refreshToken,
      twoFactorEnabled: userRow.twoFactorEnabled,
      twoFactorConfirmedAt: userRow.twoFactorConfirmedAt,
    );
  }

  @override
  Future<void> clearUser() async {
    await db.delete(db.users).go();
  }
}
