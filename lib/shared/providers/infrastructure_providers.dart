// Infrastructure Providers
//
// This file contains core infrastructure providers that are shared across
// all features. These providers should have no feature-specific dependencies.

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:promoruta/core/models/config.dart';
import 'package:promoruta/shared/datasources/local/db/database.dart';
import 'package:promoruta/shared/services/config_service.dart';
import 'package:promoruta/shared/services/connectivity_service.dart';
import 'package:promoruta/shared/services/connectivity_service_impl.dart';
import 'package:promoruta/features/auth/data/datasources/local/auth_local_data_source.dart';
import 'package:promoruta/features/auth/domain/repositories/auth_repository.dart';
import 'package:promoruta/shared/services/token_refresh_interceptor.dart';
import 'package:promoruta/shared/models/gps_tracking_config.dart';

// ============ Database ============

final databaseProvider = Provider<AppDatabase>((ref) {
  final database = AppDatabase();
  return database;
});

// ============ Config ============

final configServiceProvider = Provider<ConfigService>((ref) {
  return ConfigServiceImpl();
});

final configProvider = FutureProvider<AppConfig>((ref) async {
  final configService = ref.watch(configServiceProvider);
  return await configService.getConfig();
});

// ============ Connectivity ============

final connectivityProvider = Provider<Connectivity>((ref) {
  return Connectivity();
});

final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  final connectivity = ref.watch(connectivityProvider);
  final service = ConnectivityServiceImpl(connectivity);
  ref.onDispose(() => service.dispose());
  return service;
});

final connectivityStatusProvider = StreamProvider<bool>((ref) {
  final connectivityService = ref.watch(connectivityServiceProvider);
  return connectivityService.connectivityStream;
});

// ============ Logger ============

final loggerProvider = Provider<Logger>((ref) {
  return Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      lineLength: 50,
      colors: true,
      printEmojis: true,
    ),
  );
});

// ============ Auth Data Source (Infrastructure level) ============
// This is defined here because Dio needs it for TokenRefreshInterceptor

final authLocalDataSourceProvider = Provider<AuthLocalDataSource>((ref) {
  final database = ref.watch(databaseProvider);
  return AuthLocalDataSourceImpl(database);
});

// ============ Dio (HTTP Client with auth interceptor) ============

final dioProvider = Provider<Dio>((ref) {
  final configAsync = ref.watch(configProvider);
  final config = configAsync.maybeWhen(
    data: (config) => config,
    orElse: () => const AppConfig(baseUrl: 'http://172.81.177.85/api/'),
  );

  final dio = Dio(BaseOptions(
    baseUrl: config.baseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  // Add token refresh interceptor
  final authLocalDataSource = ref.watch(authLocalDataSourceProvider);
  dio.interceptors.add(TokenRefreshInterceptor(
    localDataSource: authLocalDataSource,
    dio: dio,
  ));

  // Add logging interceptor
  dio.interceptors.add(LogInterceptor(
    request: true,
    requestHeader: true,
    requestBody: true,
    responseHeader: true,
    responseBody: true,
    error: true,
  ));

  return dio;
});

// ============ GPS Tracking Config ============

final gpsTrackingConfigProvider = Provider<GpsTrackingConfig>((ref) {
  // Default configuration that can be overridden based on app state or preferences
  // For high-frequency tracking (urban areas): lower batch size and distance filter
  // For low-frequency tracking (highways): higher batch size and distance filter
  return const GpsTrackingConfig(
    batchSize: 20,
    syncIntervalSeconds: 60,
    distanceFilterMeters: 10,
    minSpeedMetersSec: 0.1,
  );
});
