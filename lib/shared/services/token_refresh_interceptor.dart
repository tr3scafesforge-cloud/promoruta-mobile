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
      AppLogger.auth.d('Added auth token to request: ${options.path}');
    } else {
      AppLogger.auth.w('No access token available for request: ${options.path}');
    }

    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    AppLogger.auth.d('Interceptor onError called for: ${err.requestOptions.path} - Status: ${err.response?.statusCode}');

    // Only handle 401 unauthorized errors
    if (err.response?.statusCode != 401) {
      return handler.next(err);
    }

    AppLogger.auth.i('Detected 401 error for: ${err.requestOptions.path}');

    // Prevent infinite loops for auth endpoints
    if (err.requestOptions.path.contains('/auth/login') ||
        err.requestOptions.path.contains('/auth/refresh')) {
      AppLogger.auth.w('401 on auth endpoint, not attempting refresh');
      return handler.next(err);
    }

    final user = await _localDataSource.getUser();
    if (user == null || user.refreshToken == null) {
      AppLogger.auth.e('No user or refresh token available for token refresh');
      return handler.next(err);
    }

    AppLogger.auth.i('User found with refresh token, proceeding with refresh');

    // If already refreshing, queue the request
    if (_isRefreshing) {
      AppLogger.auth.i('Token refresh already in progress, queuing request');
      _requestQueue.add((options: err.requestOptions, handler: handler));
      return;
    }

    _isRefreshing = true;
    AppLogger.auth.i('Starting token refresh process...');

    try {
      // Create a new Dio instance without interceptors to avoid infinite loop
      final refreshDio = Dio(BaseOptions(
        baseUrl: _dio.options.baseUrl,
        connectTimeout: _dio.options.connectTimeout,
        receiveTimeout: _dio.options.receiveTimeout,
      ));

      AppLogger.auth.i('Calling refresh token endpoint...');

      // Refresh the token
      final response = await refreshDio.post(
        '/auth/refresh',
        data: {'refresh_token': user.refreshToken},
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      AppLogger.auth.i('Refresh token response received: ${response.statusCode}');

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

        AppLogger.auth.i('Token refreshed successfully, new token saved');

        // Retry the original request with new token
        err.requestOptions.headers['Authorization'] = 'Bearer ${refreshedUser.accessToken}';

        AppLogger.auth.i('Retrying original request: ${err.requestOptions.path}');

        try {
          final retryResponse = await _dio.fetch(err.requestOptions);
          AppLogger.auth.i('Retry successful: ${retryResponse.statusCode}');
          handler.resolve(retryResponse);

          // Process queued requests with new token
          AppLogger.auth.i('Processing ${_requestQueue.length} queued requests');
          _processQueue(refreshedUser.accessToken!);
        } catch (retryError) {
          AppLogger.auth.e('Retry failed: $retryError');
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
