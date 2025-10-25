import 'package:promoruta/core/core.dart';
import 'package:promoruta/shared/datasources/local/user_local_data_source.dart';
import 'package:promoruta/shared/datasources/remote/user_remote_data_source.dart';

abstract class UserRepository {
  Future<User> getUserById(String userId, {bool forceRefresh = false});
}

class UserRepositoryImpl implements UserRepository {
  final UserRemoteDataSource remoteDataSource;
  final UserLocalDataSource localDataSource;

  UserRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<User> getUserById(String userId, {bool forceRefresh = false}) async {
    // Try to get from local storage first (unless force refresh is requested)
    if (!forceRefresh) {
      final localUser = await localDataSource.getUser(userId);
      if (localUser != null) {
        return localUser;
      }
    }

    // Fetch from remote API
    final remoteUser = await remoteDataSource.getUserById(userId);

    // Save to local storage for future use
    await localDataSource.saveUser(remoteUser);

    return remoteUser;
  }
}