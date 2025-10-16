import 'package:dio/dio.dart';
import 'package:promoruta/core/core.dart';
import 'package:promoruta/core/utils/logger.dart';

import '../../repositories/auth_repository.dart';

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

        return User(
          id: userData['id'],
          email: userData['email'],
          role: UserRole.fromString(userData['role']),
          accessToken: data['access_token'],
          tokenExpiry: tokenExpiry,
          username: userData['name'],
          photoUrl: null, // API doesn't provide photoUrl
          createdAt: userData['created_at'] != null ? DateTime.parse(userData['created_at']) : null,
        );
      } else {
        throw Exception('Login failed: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    }
  }

  @override
  Future<User> refreshToken(String accessToken) async {
    try {
      final response = await dio.post(
        '/auth/refresh',
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
          },
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final userData = data['user'];
        final expiresIn = data['expires_in'] as int;
        final tokenExpiry = DateTime.now().add(Duration(seconds: expiresIn));

        final user = User(
          id: userData['id'],
          email: userData['email'],
          role: UserRole.fromString(userData['role']),
          accessToken: data['access_token'],
          tokenExpiry: tokenExpiry,
          username: userData['name'],
          photoUrl: null, // API doesn't provide photoUrl
          createdAt: userData['created_at'] != null ? DateTime.parse(userData['created_at']) : null,
        );

        // Update local storage with new token
        await _localDataSource.saveUser(user);

        return user;
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
      final user = await _localDataSource.getUser();
      final headers = <String, String>{};
      if (user?.accessToken != null) {
        headers['Authorization'] = 'Bearer ${user!.accessToken}';
      }

      await dio.post(
        '/auth/logout',
        options: Options(headers: headers),
      );
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    }
  }

  @override
  Future<void> changePassword(String currentPassword, String newPassword, String newPasswordConfirmation) async {
    try {
      final user = await _localDataSource.getUser();
      final headers = <String, String>{};
      if (user?.accessToken != null) {
        headers['Authorization'] = 'Bearer ${user!.accessToken}';
      }

      await dio.post(
        '/auth/change-password',
        data: {
          'current_password': currentPassword,
          'new_password': newPassword,
          'new_password_confirmation': newPasswordConfirmation,
        },
        options: Options(
          headers: {
            ...headers,
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
          case 401:
            throw Exception('Current password is incorrect. Please try again.');
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