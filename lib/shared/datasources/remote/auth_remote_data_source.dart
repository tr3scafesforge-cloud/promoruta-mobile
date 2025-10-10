import 'package:dio/dio.dart';

import '../../../core/models/user.dart';
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
          role: userData['role'],
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
          role: userData['role'],
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
}