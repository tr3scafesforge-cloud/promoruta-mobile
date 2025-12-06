import 'package:promoruta/core/core.dart';

abstract class UserRepository {
  Future<User> getUserById(String userId, {bool forceRefresh = false});
}

abstract class UserLocalDataSource {
  Future<void> saveUser(User user);
  Future<User?> getUser(String userId);
  Future<void> clearUser(String userId);
}

abstract class UserRemoteDataSource {
  Future<User> getUserById(String userId);
}
