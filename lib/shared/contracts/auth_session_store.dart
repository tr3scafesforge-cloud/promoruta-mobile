import 'package:promoruta/core/core.dart';

/// Shared contract for persisting the authenticated user session locally.
abstract class AuthSessionStore {
  Future<void> saveUser(User user);

  Future<User?> getUser();

  Future<void> clearUser();
}
