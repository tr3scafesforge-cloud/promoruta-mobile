import 'package:dio/dio.dart';
import 'package:promoruta/core/core.dart';
import 'package:promoruta/core/utils/logger.dart';
import 'package:promoruta/features/auth/domain/repositories/auth_repository.dart';

/// Dio interceptor that handles automatic token refresh on 401 responses
class TokenRefreshInterceptor extends Interceptor {
  final AuthLocalDataSource _localDataSource;
  final Dio _dio;
  bool _isRefreshing = false;
  final List<({RequestOptions options, ErrorInterceptorHandler handler})> _requestQueue = [];

  TokenRefreshInterceptor({
    required AuthLocalDataSource localDataSource,
    required Dio dio,
  })  : _localDataSource = localDataSource,
        _dio = dio;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Add authorization header if user is logged in
    final user = await _localDataSource.getUser();
    if (user != null && user.accessToken != null) {
      options.headers['Authorization'] = 'Bearer ${user.accessToken}';
    }

    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    // Only handle 401 unauthorized errors
    if (err.response?.statusCode != 401) {
      return handler.next(err);
    }

    // Prevent infinite loops for auth endpoints
    if (err.requestOptions.path.contains('/auth/login') ||
        err.requestOptions.path.contains('/auth/refresh')) {
      return handler.next(err);
    }

    final user = await _localDataSource.getUser();
    if (user == null || user.refreshToken == null) {
      AppLogger.auth.e('No user or refresh token available');
      return handler.next(err);
    }

    // If already refreshing, queue the request
    if (_isRefreshing) {
      _requestQueue.add((options: err.requestOptions, handler: handler));
      return;
    }

    _isRefreshing = true;

    try {
      AppLogger.auth.i('Token expired, attempting refresh...');

      // Refresh the token
      final response = await _dio.post(
        '/auth/refresh',
        data: {'refresh_token': user.refreshToken},
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data;
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

        // Save the new token
        await _localDataSource.saveUser(refreshedUser);

        AppLogger.auth.i('Token refreshed successfully');

        // Retry the original request with new token
        err.requestOptions.headers['Authorization'] = 'Bearer ${refreshedUser.accessToken}';

        try {
          final retryResponse = await _dio.fetch(err.requestOptions);
          handler.resolve(retryResponse);

          // Process queued requests with new token
          _processQueue(refreshedUser.accessToken!);
        } catch (retryError) {
          handler.next(err);
          _clearQueue(err);
        }
      } else {
        AppLogger.auth.e('Token refresh failed: ${response.statusMessage}');
        handler.next(err);
        _clearQueue(err);
      }
    } on DioException catch (e) {
      AppLogger.auth.e('Token refresh error: ${e.message}');
      handler.next(err);
      _clearQueue(err);
    } catch (e) {
      AppLogger.auth.e('Unexpected error during token refresh: $e');
      handler.next(err);
      _clearQueue(err);
    } finally {
      _isRefreshing = false;
    }
  }

  /// Process all queued requests with the new access token
  void _processQueue(String newAccessToken) {
    for (final item in _requestQueue) {
      item.options.headers['Authorization'] = 'Bearer $newAccessToken';
      _dio.fetch(item.options).then(
        (response) => item.handler.resolve(response),
        onError: (error) {
          if (error is DioException) {
            item.handler.next(error);
          } else {
            item.handler.next(
              DioException(
                requestOptions: item.options,
                error: error,
              ),
            );
          }
        },
      );
    }
    _requestQueue.clear();
  }

  /// Clear the queue and reject all queued requests
  void _clearQueue(DioException error) {
    for (final item in _requestQueue) {
      item.handler.next(error);
    }
    _requestQueue.clear();
  }
}
