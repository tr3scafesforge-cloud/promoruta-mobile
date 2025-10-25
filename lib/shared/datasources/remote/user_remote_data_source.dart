import 'package:dio/dio.dart';
import 'package:promoruta/core/core.dart';
import 'package:promoruta/core/utils/logger.dart';
import 'package:promoruta/shared/repositories/auth_repository.dart';

abstract class UserRemoteDataSource {
  Future<User> getUserById(String userId);
}

class UserRemoteDataSourceImpl implements UserRemoteDataSource {
  final Dio dio;
  final AuthLocalDataSource _localDataSource;

  UserRemoteDataSourceImpl({
    required this.dio,
    required AuthLocalDataSource localDataSource,
  }) : _localDataSource = localDataSource;

  /// Helper method to handle token refresh on 401 errors and retry the request
  Future<T> _handleRequestWithTokenRefresh<T>(
    Future<T> Function(Map<String, String> headers) request,
  ) async {
    final user = await _localDataSource.getUser();
    if (user == null) throw Exception('No user logged in');
    final headers = {'Authorization': 'Bearer ${user.accessToken}'};

    try {
      return await request(headers);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        try {
          // Import and use the auth remote data source for token refresh
          // This would need to be injected or accessed differently
          // For now, we'll throw an exception to indicate token refresh is needed
          AppLogger.auth.e('Token refresh failed: $e');
          throw Exception('Authentication failed. Please log in again.');
        } catch (refreshError) {
          AppLogger.auth.e('Token refresh failed: $refreshError');
          throw Exception('Authentication failed. Please log in again.');
        }
      } else {
        rethrow;
      }
    }
  }

  @override
  Future<User> getUserById(String userId) async {
    try {
      final response = await _handleRequestWithTokenRefresh((headers) async {
        return await dio.get(
          '/api/users/$userId',
          options: Options(
            headers: {
              ...headers,
              'Accept': 'application/json',
            },
          ),
        );
      });

      if (response.statusCode == 200) {
        final data = response.data;
        return User.fromJson(data);
      } else {
        throw Exception('Failed to get user: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      AppLogger.auth.e('Get user by ID failed: ${e.response?.statusCode} - ${e.response?.data} - ${e.message}');

      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final responseData = e.response!.data;

        switch (statusCode) {
          case 404:
            throw Exception('User not found.');
          case 403:
            throw Exception('Access denied. You do not have permission to view this user.');
          case 500:
            throw Exception('Server error. Please try again later.');
          default:
            throw Exception('Unable to get user information. Please try again later.');
        }
      } else {
        // Network or other Dio errors
        throw Exception('Network error. Please check your connection and try again.');
      }
    }
  }
}