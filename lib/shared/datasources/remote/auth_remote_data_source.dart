import 'package:dio/dio.dart';

import '../../../core/models/user.dart';
import '../../repositories/auth_repository.dart';

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio dio;

  AuthRemoteDataSourceImpl({
    required this.dio,
  });

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
        return User(
          id: data['id'],
          email: data['email'],
          role: data['role'],
          token: data['token'],
          username: data['username'],
          photoUrl: data['photoUrl'],
          createdAt: data['createdAt'] != null ? DateTime.parse(data['createdAt']) : null,
        );
      } else {
        throw Exception('Login failed: ${response.statusMessage}');
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
}