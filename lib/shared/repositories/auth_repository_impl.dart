
import 'package:promoruta/core/core.dart' as model;
import 'package:promoruta/shared/shared.dart';


class AuthRepositoryImpl implements AuthRepository {
  final AuthLocalDataSource _localDataSource;
  final AuthRemoteDataSource _remoteDataSource;
  final ConnectivityService _connectivityService;

  AuthRepositoryImpl(
    this._localDataSource,
    this._remoteDataSource,
    this._connectivityService,
  );

  @override
  Future<model.User> login(String email, String password) async {
    final isConnected = await _connectivityService.isConnected;

    if (isConnected) {
      try {
        final user = await _remoteDataSource.login(email, password);
        await _localDataSource.saveUser(user);
        return user;
      } catch (e) {
        // If remote fails, try local if user exists
        final localUser = await _localDataSource.getUser();
        if (localUser != null) {
          return localUser;
        }
        rethrow;
      }
    } else {
      // Offline: check if user exists locally
      final localUser = await _localDataSource.getUser();
      if (localUser != null) {
        return localUser;
      }
      throw Exception('No internet connection and no cached user');
    }
  }

  @override
  Future<model.User> refreshToken(String accessToken) async {
    final isConnected = await _connectivityService.isConnected;

    if (isConnected) {
      try {
        final user = await _remoteDataSource.refreshToken(accessToken);
        await _localDataSource.saveUser(user);
        return user;
      } catch (e) {
        rethrow;
      }
    } else {
      throw Exception('No internet connection for token refresh');
    }
  }

  @override
  Future<model.User?> ensureValidToken() async {
    final user = await _localDataSource.getUser();
    if (user == null) return null;

    // Check if token is expired or will expire soon (within 5 minutes)
    final now = DateTime.now();
    final bufferTime = Duration(minutes: 5);

    if (user.tokenExpiry != null && user.tokenExpiry!.subtract(bufferTime).isBefore(now)) {
      // Token is expired or will expire soon, try to refresh
      final isConnected = await _connectivityService.isConnected;
      if (isConnected && user.accessToken != null) {
        try {
          final refreshedUser = await _remoteDataSource.refreshToken(user.accessToken!);
          await _localDataSource.saveUser(refreshedUser);
          return refreshedUser;
        } catch (e) {
          // Refresh failed, return current user (might still work for some requests)
          return user;
        }
      }
    }

    return user;
  }

  @override
  Future<void> logout() async {
    final isConnected = await _connectivityService.isConnected;

    if (isConnected) {
      try {
        await _remoteDataSource.logout();
      } catch (e) {
        // Continue with local logout even if remote fails
      }
    }

    await _localDataSource.clearUser();
  }

  @override
  Future<model.User?> getCurrentUser() async {
    return await _localDataSource.getUser();
  }

  @override
  Future<bool> isLoggedIn() async {
    final user = await _localDataSource.getUser();
    return user != null;
  }
}