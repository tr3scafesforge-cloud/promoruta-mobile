import 'package:promoruta/core/core.dart' as model;
import 'package:promoruta/core/utils/logger.dart';
import 'package:promoruta/shared/services/connectivity_service.dart';

import '../../domain/repositories/auth_repository.dart';
import '../../domain/models/two_factor_models.dart';
import '../models/registration_models.dart';

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
        AppLogger.auth.e('Remote Auth failed: $e');
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

    if (user.tokenExpiry != null &&
        user.tokenExpiry!.subtract(bufferTime).isBefore(now)) {
      // Token is expired or will expire soon, try to refresh
      final isConnected = await _connectivityService.isConnected;
      if (isConnected && user.accessToken != null) {
        try {
          final refreshedUser =
              await _remoteDataSource.refreshToken(user.accessToken!);
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

  @override
  Future<void> changePassword(String currentPassword, String newPassword,
      String newPasswordConfirmation) async {
    final isConnected = await _connectivityService.isConnected;

    if (isConnected) {
      try {
        await _remoteDataSource.changePassword(
            currentPassword, newPassword, newPasswordConfirmation);
      } catch (e) {
        rethrow;
      }
    } else {
      throw Exception('No internet connection for password change');
    }
  }

  @override
  Future<String> requestPasswordResetCode(String email) async {
    final isConnected = await _connectivityService.isConnected;

    if (isConnected) {
      try {
        return await _remoteDataSource.requestPasswordResetCode(email);
      } catch (e) {
        rethrow;
      }
    } else {
      throw Exception(
          'No internet connection. Please check your connection and try again.');
    }
  }

  @override
  Future<String> resetPasswordWithCode({
    required String email,
    required String code,
    required String password,
    required String passwordConfirmation,
  }) async {
    final isConnected = await _connectivityService.isConnected;

    if (isConnected) {
      try {
        return await _remoteDataSource.resetPasswordWithCode(
          email: email,
          code: code,
          password: password,
          passwordConfirmation: passwordConfirmation,
        );
      } catch (e) {
        rethrow;
      }
    } else {
      throw Exception(
          'No internet connection. Please check your connection and try again.');
    }
  }

  // Two-Factor Authentication methods

  @override
  Future<TwoFactorEnableResponse> enable2FA() async {
    final isConnected = await _connectivityService.isConnected;

    if (isConnected) {
      try {
        return await _remoteDataSource.enable2FA();
      } catch (e) {
        rethrow;
      }
    } else {
      throw Exception(
          'No internet connection. Please check your connection and try again.');
    }
  }

  @override
  Future<TwoFactorConfirmResponse> confirm2FA(
      String secret, String code) async {
    final isConnected = await _connectivityService.isConnected;

    if (isConnected) {
      try {
        return await _remoteDataSource.confirm2FA(secret, code);
      } catch (e) {
        rethrow;
      }
    } else {
      throw Exception(
          'No internet connection. Please check your connection and try again.');
    }
  }

  @override
  Future<String> disable2FA(String password) async {
    final isConnected = await _connectivityService.isConnected;

    if (isConnected) {
      try {
        return await _remoteDataSource.disable2FA(password);
      } catch (e) {
        rethrow;
      }
    } else {
      throw Exception(
          'No internet connection. Please check your connection and try again.');
    }
  }

  @override
  Future<model.User> verify2FACode({
    required String email,
    required String password,
    String? code,
    String? recoveryCode,
  }) async {
    final isConnected = await _connectivityService.isConnected;

    if (isConnected) {
      try {
        final user = await _remoteDataSource.verify2FACode(
          email: email,
          password: password,
          code: code,
          recoveryCode: recoveryCode,
        );
        await _localDataSource.saveUser(user);
        return user;
      } catch (e) {
        rethrow;
      }
    } else {
      throw Exception('No internet connection. 2FA requires network access.');
    }
  }

  @override
  Future<RecoveryCodesResponse> getRecoveryCodes() async {
    final isConnected = await _connectivityService.isConnected;

    if (isConnected) {
      try {
        return await _remoteDataSource.getRecoveryCodes();
      } catch (e) {
        rethrow;
      }
    } else {
      throw Exception(
          'No internet connection. Please check your connection and try again.');
    }
  }

  @override
  Future<RecoveryCodesResponse> regenerateRecoveryCodes(String password) async {
    final isConnected = await _connectivityService.isConnected;

    if (isConnected) {
      try {
        return await _remoteDataSource.regenerateRecoveryCodes(password);
      } catch (e) {
        rethrow;
      }
    } else {
      throw Exception(
          'No internet connection. Please check your connection and try again.');
    }
  }

  // Registration methods

  @override
  Future<RegistrationResponse> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    required String role,
  }) async {
    final isConnected = await _connectivityService.isConnected;

    if (isConnected) {
      try {
        return await _remoteDataSource.register(
          name: name,
          email: email,
          password: password,
          passwordConfirmation: passwordConfirmation,
          role: role,
        );
      } catch (e) {
        rethrow;
      }
    } else {
      throw Exception(
          'No internet connection. Please check your connection and try again.');
    }
  }

  @override
  Future<model.User> verifyEmail({
    required String email,
    required String code,
  }) async {
    final isConnected = await _connectivityService.isConnected;

    if (isConnected) {
      try {
        final response = await _remoteDataSource.verifyEmail(
          email: email,
          code: code,
        );
        // Save the user after successful verification
        await _localDataSource.saveUser(response.user);
        return response.user;
      } catch (e) {
        rethrow;
      }
    } else {
      throw Exception(
          'No internet connection. Please check your connection and try again.');
    }
  }

  @override
  Future<String> resendVerificationCode(String email) async {
    final isConnected = await _connectivityService.isConnected;

    if (isConnected) {
      try {
        return await _remoteDataSource.resendVerificationCode(email);
      } catch (e) {
        rethrow;
      }
    } else {
      throw Exception(
          'No internet connection. Please check your connection and try again.');
    }
  }
}
