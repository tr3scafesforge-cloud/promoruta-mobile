import 'package:dio/dio.dart';
import 'package:promoruta/core/core.dart';
import 'package:promoruta/core/utils/logger.dart';

abstract class UserRemoteDataSource {
  Future<User> getUserById(String userId);
}

class UserRemoteDataSourceImpl implements UserRemoteDataSource {
  final Dio dio;

  UserRemoteDataSourceImpl({
    required this.dio,
  });

  @override
  Future<User> getUserById(String userId) async {
    try {
      final response = await dio.get(
        '/users/$userId',
        options: Options(
          headers: {
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        return User.fromJson(data);
      } else {
        throw Exception('Failed to get user: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      AppLogger.auth.e(
          'Get user by ID failed: ${e.response?.statusCode} - ${e.response?.data} - ${e.message}');

      if (e.response != null) {
        final statusCode = e.response!.statusCode;

        switch (statusCode) {
          case 404:
            throw Exception('User not found.');
          case 403:
            throw Exception(
                'Access denied. You do not have permission to view this user.');
          case 500:
            throw Exception('Server error. Please try again later.');
          default:
            throw Exception(
                'Unable to get user information. Please try again later.');
        }
      } else {
        // Network or other Dio errors
        throw Exception(
            'Network error. Please check your connection and try again.');
      }
    }
  }
}
