import 'package:promoruta/core/core.dart';
import 'package:promoruta/features/auth/domain/repositories/auth_repository.dart';
import '../datasources/local/user_local_data_source.dart' as local_ds;
import '../datasources/remote/user_remote_data_source.dart' as remote_ds;
import '../../domain/repositories/user_repository.dart';

class UserRepositoryImpl implements UserRepository {
  final remote_ds.UserRemoteDataSource remoteDataSource;
  final local_ds.UserLocalDataSource localDataSource;
  final AuthLocalDataSource authLocalDataSource;

  UserRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.authLocalDataSource,
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

    // Get the current user to preserve auth data
    final currentUser = await authLocalDataSource.getUser();

    // Merge auth data from current user with remote user data
    final mergedUser = User(
      id: remoteUser.id,
      name: remoteUser.name,
      email: remoteUser.email,
      emailVerifiedAt: remoteUser.emailVerifiedAt,
      role: remoteUser.role,
      createdAt: remoteUser.createdAt,
      updatedAt: remoteUser.updatedAt,
      accessToken: currentUser?.accessToken,
      tokenExpiry: currentUser?.tokenExpiry,
      refreshToken: currentUser?.refreshToken,
      refreshExpiresIn: currentUser?.refreshExpiresIn,
      username: remoteUser.username,
      photoUrl: remoteUser.photoUrl,
    );

    // Save to local storage for future use
    await localDataSource.saveUser(mergedUser);

    return mergedUser;
  }
}
