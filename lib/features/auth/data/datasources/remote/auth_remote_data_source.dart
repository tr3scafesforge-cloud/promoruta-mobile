import 'package:dio/dio.dart';
import 'package:promoruta/core/core.dart';
import 'package:promoruta/core/utils/logger.dart';

import '../../../domain/repositories/auth_repository.dart';

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio dio;
  final AuthLocalDataSource _localDataSource;

  AuthRemoteDataSourceImpl({
    required this.dio,
    required AuthLocalDataSource localDataSource,
  }) : _localDataSource = localDataSource;

  @override
  Future<User> login(String email, String password) async {
    try {
      final response = await dio.post(
        '/auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final userData = data['user'];
        final expiresIn = data['expires_in'] as int;
        final tokenExpiry = DateTime.now().add(Duration(seconds: expiresIn));
        final refreshExpiresIn = data['refresh_expires_in'] != null
            ? DateTime.now().add(Duration(seconds: data['refresh_expires_in'] as int))
            : null;

        return User(
          id: userData['id'],
          name: userData['name'],
          email: userData['email'],
          emailVerifiedAt: null, // API doesn't provide email_verified_at on login
          role: UserRole.fromString(userData['role']),
          createdAt: userData['created_at'] != null ? DateTime.parse(userData['created_at']) : null,
          updatedAt: null, // API doesn't provide updated_at on login
          accessToken: data['access_token'],
          tokenExpiry: tokenExpiry,
          refreshToken: data['refresh_token'],
          refreshExpiresIn: refreshExpiresIn,
          username: userData['name'],
          photoUrl: null, // API doesn't provide photoUrl
        );
      } else {
        throw Exception('Login failed: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    }
  }

  @override
  Future<User> refreshToken(String refreshToken) async {
    try {
      final response = await dio.post(
        '/auth/refresh',
        data: {
          'refresh_token': refreshToken,
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final user = await _localDataSource.getUser();
        if (user == null) throw Exception('No user logged in');
        final expiresIn = data['expires_in'] as int;
        final tokenExpiry = DateTime.now().add(Duration(seconds: expiresIn));
        final refreshExpiresIn = data['refresh_expires_in'] != null
            ? DateTime.now().add(Duration(seconds: data['refresh_expires_in'] as int))
            : null;

        final refreshedUser = User(
          id: user.id,
          name: user.name,
          email: user.email,
          emailVerifiedAt: user.emailVerifiedAt,
          role: user.role,
          createdAt: user.createdAt,
          updatedAt: user.updatedAt,
          accessToken: data['access_token'],
          tokenExpiry: tokenExpiry,
          refreshToken: data['refresh_token'],
          refreshExpiresIn: refreshExpiresIn,
          username: user.username,
          photoUrl: user.photoUrl,
        );

        // Update local storage with new token
        await _localDataSource.saveUser(refreshedUser);

        return refreshedUser;
      } else {
        throw Exception('Token refresh failed: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    }
  }

  @override
  Future<void> logout() async {
    try {
      await dio.post('/auth/logout');
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    }
  }

  @override
  Future<void> changePassword(String currentPassword, String newPassword, String newPasswordConfirmation) async {
    try {
      await dio.post(
        '/auth/change-password',
        data: {
          'current_password': currentPassword,
          'new_password': newPassword,
          'new_password_confirmation': newPasswordConfirmation,
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );
    } on DioException catch (e) {
      AppLogger.auth.e('Change password failed: ${e.response?.statusCode} - ${e.response?.data} - ${e.message}');

      // Handle different error codes with user-friendly messages
      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final responseData = e.response!.data;

        switch (statusCode) {
          case 422:
            // Handle validation errors
            if (responseData is Map && responseData.containsKey('errors')) {
              final errors = responseData['errors'] as Map?;
              if (errors != null && errors.isNotEmpty) {
                final firstError = errors.values.first;
                if (firstError is List && firstError.isNotEmpty) {
                  throw Exception(firstError.first.toString());
                }
              }
            }
            throw Exception('Invalid password format. Please check your input.');
          case 500:
            throw Exception('serverErrorPasswordChange');
          default:
            throw Exception('Unable to change password. Please try again later.');
        }
      } else {
        // Network or other Dio errors
        throw Exception('Network error. Please check your connection and try again.');
      }
    }
  }
}
