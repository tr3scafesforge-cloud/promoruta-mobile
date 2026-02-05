import 'dart:async';

import 'package:dio/dio.dart';
import 'package:promoruta/core/core.dart';
import 'package:promoruta/core/utils/logger.dart';
import 'package:promoruta/features/auth/domain/repositories/auth_repository.dart';

/// Dio interceptor that handles automatic token refresh on 401 responses.
///
/// Uses an async lock pattern (via Completer) to ensure only one token refresh
/// occurs at a time, preventing race conditions when multiple concurrent
/// requests receive 401 responses.
class TokenRefreshInterceptor extends Interceptor {
  final AuthLocalDataSource _localDataSource;
  final Dio _dio;

  /// Completer that coordinates concurrent refresh requests.
  /// When set, a refresh is in progress and all new requests should wait on it.
  Completer<String?>? _refreshCompleter;

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
      AppLogger.auth
          .w('No access token available for request: ${options.path}');
    }

    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    AppLogger.auth.d(
        'Interceptor onError called for: ${err.requestOptions.path} - Status: ${err.response?.statusCode}');

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

    // Use async lock pattern: if refresh is in progress, wait for it
    if (_refreshCompleter != null) {
      AppLogger.auth.i('Token refresh already in progress, waiting...');
      final newToken = await _refreshCompleter!.future;
      if (newToken != null) {
        // Retry the original request with new token
        err.requestOptions.headers['Authorization'] = 'Bearer $newToken';
        try {
          final retryResponse = await _dio.fetch(err.requestOptions);
          return handler.resolve(retryResponse);
        } catch (retryError) {
          if (retryError is DioException) {
            return handler.next(retryError);
          }
          return handler.next(err);
        }
      } else {
        // Refresh failed, propagate original error
        return handler.next(err);
      }
    }

    // Start a new refresh - create completer before any async operations
    _refreshCompleter = Completer<String?>();
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

      AppLogger.auth
          .i('Refresh token response received: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = response.data;
        final expiresIn = data['expires_in'] as int;
        final tokenExpiry = DateTime.now().add(Duration(seconds: expiresIn));
        final refreshExpiresIn = data['refresh_expires_in'] != null
            ? DateTime.now()
                .add(Duration(seconds: data['refresh_expires_in'] as int))
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

        // Complete the refresh with new token - all waiting requests will proceed
        _refreshCompleter!.complete(refreshedUser.accessToken);
        _refreshCompleter = null;

        // Retry the original request with new token
        err.requestOptions.headers['Authorization'] =
            'Bearer ${refreshedUser.accessToken}';

        AppLogger.auth
            .i('Retrying original request: ${err.requestOptions.path}');

        try {
          final retryResponse = await _dio.fetch(err.requestOptions);
          AppLogger.auth.i('Retry successful: ${retryResponse.statusCode}');
          handler.resolve(retryResponse);
        } catch (retryError) {
          AppLogger.auth.e('Retry failed: $retryError');
          handler.next(err);
        }
      } else {
        AppLogger.auth.e('Token refresh failed: ${response.statusMessage}');
        _refreshCompleter!.complete(null);
        _refreshCompleter = null;
        handler.next(err);
      }
    } on DioException catch (e) {
      AppLogger.auth.e('Token refresh error: ${e.message}');
      _refreshCompleter!.complete(null);
      _refreshCompleter = null;
      handler.next(err);
    } catch (e) {
      AppLogger.auth.e('Unexpected error during token refresh: $e');
      _refreshCompleter!.complete(null);
      _refreshCompleter = null;
      handler.next(err);
    }
  }
}
