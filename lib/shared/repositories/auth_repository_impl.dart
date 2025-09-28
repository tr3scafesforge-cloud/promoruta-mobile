import 'package:dio/dio.dart';

import '../../core/models/user.dart' as model;
import '../datasources/local/auth_local_data_source.dart';
import '../datasources/remote/auth_remote_data_source.dart';
import '../services/connectivity_service.dart';
import 'auth_repository.dart';

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