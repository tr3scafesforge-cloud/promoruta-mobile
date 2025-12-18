import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:promoruta/shared/shared.dart';
import 'package:promoruta/features/profile/data/datasources/local/user_local_data_source.dart' as user_ds;
import 'package:promoruta/features/profile/data/datasources/remote/user_remote_data_source.dart' as user_remote_ds;
import 'package:promoruta/features/profile/data/repositories/user_repository_impl.dart';
import 'package:promoruta/features/profile/domain/repositories/user_repository.dart' hide UserLocalDataSource, UserRemoteDataSource;
import 'package:promoruta/features/advertiser/campaign_creation/data/datasources/remote/media_remote_data_source.dart';
import 'package:promoruta/features/advertiser/campaign_creation/domain/repositories/media_repository.dart';
import 'package:promoruta/features/advertiser/campaign_management/data/datasources/local/campaign_local_data_source.dart';
import 'package:promoruta/features/advertiser/campaign_management/data/datasources/remote/campaign_remote_data_source.dart';
import 'package:promoruta/features/advertiser/campaign_management/data/repositories/campaign_repository_impl.dart';
import 'package:promoruta/features/advertiser/campaign_management/domain/repositories/campaign_repository.dart';
import 'package:promoruta/features/advertiser/campaign_management/domain/use_cases/campaign_use_cases.dart';
import 'package:promoruta/features/promotor/gps_tracking/data/datasources/local/gps_local_data_source.dart';
import 'package:promoruta/features/promotor/gps_tracking/data/datasources/remote/gps_remote_data_source.dart';
import 'package:promoruta/features/promotor/gps_tracking/data/repositories/gps_repository_impl.dart';
import 'package:promoruta/features/promotor/gps_tracking/domain/repositories/gps_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:promoruta/core/core.dart' as model;
import 'package:promoruta/core/models/config.dart';
import 'package:promoruta/core/constants/colors.dart';
import 'package:promoruta/core/theme.dart';
import 'package:promoruta/features/auth/data/datasources/local/auth_local_data_source.dart';
import 'package:promoruta/features/auth/data/datasources/remote/auth_remote_data_source.dart';
import 'package:promoruta/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:promoruta/features/auth/domain/repositories/auth_repository.dart';
import 'package:promoruta/features/auth/domain/use_cases/auth_use_cases.dart';
import 'package:promoruta/app/routes/app_router.dart';
import 'package:promoruta/shared/services/notification_service.dart';
import 'package:promoruta/shared/services/overlay_notification_service.dart';
import 'package:promoruta/shared/services/token_refresh_interceptor.dart';
import 'package:promoruta/shared/services/route_service.dart';
import 'package:promoruta/shared/services/route_service_impl.dart';
import 'package:promoruta/shared/services/geocoding_service.dart';
import 'package:promoruta/shared/services/geocoding_service_impl.dart';
import 'package:logger/logger.dart';


// Database provider
final databaseProvider = Provider<AppDatabase>((ref) {
  final database = AppDatabase();
  // Don't dispose in provider to avoid multiple database instances
  return database;
});

// Config service provider
final configServiceProvider = Provider<ConfigService>((ref) {
  // For now, no remote config URL - will use assets fallback
  // In production, you can set: remoteConfigUrl: 'https://your-config-server.com/config'
  return ConfigServiceImpl();
});

// Config provider
final configProvider = FutureProvider<AppConfig>((ref) async {
  final configService = ref.watch(configServiceProvider);
  return await configService.getConfig();
});

// Dio provider
final dioProvider = Provider<Dio>((ref) {
  // Wait for config to be loaded
  final configAsync = ref.watch(configProvider);
  final config = configAsync.maybeWhen(
    data: (config) => config,
    orElse: () =>
        const AppConfig(baseUrl: 'http://172.81.177.85/api/'), // Fallback
  );

  final dio = Dio(BaseOptions(
    baseUrl: config.baseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  // Add token refresh interceptor (must be added before logging interceptor)
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

// Connectivity provider
final connectivityProvider = Provider<Connectivity>((ref) {
  return Connectivity();
});

// Logger provider
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

// Services
final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  final connectivity = ref.watch(connectivityProvider);
  final service = ConnectivityServiceImpl(connectivity);
  ref.onDispose(() => service.dispose());
  return service;
});

final routeServiceProvider = Provider<RouteService>((ref) {
  final dio = ref.watch(dioProvider);
  final logger = ref.watch(loggerProvider);
  return RouteServiceImpl(dio: dio, logger: logger);
});

final geocodingServiceProvider = Provider<GeocodingService>((ref) {
  final dio = ref.watch(dioProvider);
  final logger = ref.watch(loggerProvider);
  return GeocodingServiceImpl(dio: dio, logger: logger);
});

// Data Sources
final authLocalDataSourceProvider = Provider<AuthLocalDataSource>((ref) {
  final database = ref.watch(databaseProvider);
  return AuthLocalDataSourceImpl(database);
});

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  final dio = ref.watch(dioProvider);
  final localDataSource = ref.watch(authLocalDataSourceProvider);
  return AuthRemoteDataSourceImpl(dio: dio, localDataSource: localDataSource);
});

final campaignLocalDataSourceProvider = Provider<CampaignLocalDataSource>((ref) {
  final database = ref.watch(databaseProvider);
  return CampaignLocalDataSourceImpl(database);
});

final campaignRemoteDataSourceProvider = Provider<CampaignRemoteDataSource>((ref) {
  final dio = ref.watch(dioProvider);
  final mediaDataSource = ref.watch(mediaRemoteDataSourceProvider);
  return CampaignRemoteDataSourceImpl(
    dio: dio,
    mediaDataSource: mediaDataSource,
  );
});

final gpsLocalDataSourceProvider = Provider<GpsLocalDataSource>((ref) {
  final database = ref.watch(databaseProvider);
  return GpsLocalDataSourceImpl(database);
});

final gpsRemoteDataSourceProvider = Provider<GpsRemoteDataSource>((ref) {
  final dio = ref.watch(dioProvider);
  return GpsRemoteDataSourceImpl(dio: dio);
});

final userLocalDataSourceProvider = Provider<user_ds.UserLocalDataSource>((ref) {
  final database = ref.watch(databaseProvider);
  return user_ds.UserLocalDataSourceImpl(database);
});

final userRemoteDataSourceProvider = Provider<user_remote_ds.UserRemoteDataSource>((ref) {
  final dio = ref.watch(dioProvider);
  return user_remote_ds.UserRemoteDataSourceImpl(dio: dio);
});

final mediaRemoteDataSourceProvider = Provider<MediaRemoteDataSource>((ref) {
  final dio = ref.watch(dioProvider);
  return MediaRemoteDataSourceImpl(dio: dio);
});

// Sync Service
final syncServiceProvider = Provider<SyncService>((ref) {
  final connectivityService = ref.watch(connectivityServiceProvider);
  final authLocal = ref.watch(authLocalDataSourceProvider);
  final authRemote = ref.watch(authRemoteDataSourceProvider);
  final campaignLocal = ref.watch(campaignLocalDataSourceProvider);
  final campaignRemote = ref.watch(campaignRemoteDataSourceProvider);
  final gpsLocal = ref.watch(gpsLocalDataSourceProvider);
  final gpsRemote = ref.watch(gpsRemoteDataSourceProvider);

  return SyncServiceImpl(
    connectivityService,
    authLocal,
    authRemote,
    campaignLocal,
    campaignRemote,
    gpsLocal,
    gpsRemote,
  );
});

// Repositories
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final localDataSource = ref.watch(authLocalDataSourceProvider);
  final remoteDataSource = ref.watch(authRemoteDataSourceProvider);
  final connectivityService = ref.watch(connectivityServiceProvider);

  return AuthRepositoryImpl(
    localDataSource,
    remoteDataSource,
    connectivityService,
  );
});

final campaignRepositoryProvider = Provider<CampaignRepository>((ref) {
  final localDataSource = ref.watch(campaignLocalDataSourceProvider);
  final remoteDataSource = ref.watch(campaignRemoteDataSourceProvider);
  final connectivityService = ref.watch(connectivityServiceProvider);
  final syncService = ref.watch(syncServiceProvider);

  return CampaignRepositoryImpl(
    localDataSource,
    remoteDataSource,
    connectivityService,
    syncService,
  );
});

final gpsRepositoryProvider = Provider<GpsRepository>((ref) {
  final localDataSource = ref.watch(gpsLocalDataSourceProvider);
  final connectivityService = ref.watch(connectivityServiceProvider);
  final syncService = ref.watch(syncServiceProvider);

  return GpsRepositoryImpl(
    localDataSource,
    connectivityService,
    syncService,
  );
});

final userRepositoryProvider = Provider<UserRepository>((ref) {
  final localDataSource = ref.watch(userLocalDataSourceProvider);
  final remoteDataSource = ref.watch(userRemoteDataSourceProvider);
  final authLocalDataSource = ref.watch(authLocalDataSourceProvider);

  return UserRepositoryImpl(
    remoteDataSource: remoteDataSource,
    localDataSource: localDataSource,
    authLocalDataSource: authLocalDataSource,
  );
});

final mediaRepositoryProvider = Provider<MediaRepository>((ref) {
  final remoteDataSource = ref.watch(mediaRemoteDataSourceProvider);

  return MediaRepositoryImpl(
    remoteDataSource: remoteDataSource,
  );
});

// Use Cases
final changePasswordUseCaseProvider = Provider<ChangePasswordUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return ChangePasswordUseCase(repository);
});

final getCampaignsUseCaseProvider = Provider<GetCampaignsUseCase>((ref) {
  final repository = ref.watch(campaignRepositoryProvider);
  return GetCampaignsUseCase(repository);
});

final getCampaignUseCaseProvider = Provider<GetCampaignUseCase>((ref) {
  final repository = ref.watch(campaignRepositoryProvider);
  return GetCampaignUseCase(repository);
});

final createCampaignUseCaseProvider = Provider<CreateCampaignUseCase>((ref) {
  final repository = ref.watch(campaignRepositoryProvider);
  return CreateCampaignUseCase(repository);
});

final updateCampaignUseCaseProvider = Provider<UpdateCampaignUseCase>((ref) {
  final repository = ref.watch(campaignRepositoryProvider);
  return UpdateCampaignUseCase(repository);
});

final deleteCampaignUseCaseProvider = Provider<DeleteCampaignUseCase>((ref) {
  final repository = ref.watch(campaignRepositoryProvider);
  return DeleteCampaignUseCase(repository);
});

// State Notifiers for UI
final authStateProvider = StateNotifierProvider<AuthNotifier, AsyncValue<model.User?>>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthNotifier(repository);
});

final campaignsProvider = StateNotifierProvider<CampaignsNotifier, AsyncValue<List<model.Campaign>>>((ref) {
  final getCampaignsUseCase = ref.watch(getCampaignsUseCaseProvider);
  final createCampaignUseCase = ref.watch(createCampaignUseCaseProvider);
  final updateCampaignUseCase = ref.watch(updateCampaignUseCaseProvider);
  final deleteCampaignUseCase = ref.watch(deleteCampaignUseCaseProvider);
  return CampaignsNotifier(
    getCampaignsUseCase,
    createCampaignUseCase,
    updateCampaignUseCase,
    deleteCampaignUseCase,
  );
});

// Provider for active campaigns (status = in_progress)
final activeCampaignsProvider = FutureProvider<List<model.Campaign>>((ref) async {
  final getCampaignsUseCase = ref.watch(getCampaignsUseCaseProvider);
  return await getCampaignsUseCase(const GetCampaignsParams(status: 'in_progress'));
});

// Provider for KPI stats from backend
final kpiStatsProvider = FutureProvider.autoDispose<model.AdvertiserKpiStats>((ref) async {
  final repository = ref.watch(campaignRepositoryProvider);
  return await repository.getKpiStats();
});

// Provider for zones covered this week (calculated locally)
final zonesCoveredThisWeekProvider = Provider<int>((ref) {
  final campaignsAsync = ref.watch(campaignsProvider);

  return campaignsAsync.maybeWhen(
    data: (campaigns) {
      final now = DateTime.now();
      final weekStart = now.subtract(Duration(days: now.weekday - 1));
      final weekStartMidnight = DateTime(weekStart.year, weekStart.month, weekStart.day);

      // Filter campaigns that started this week
      final thisWeekCampaigns = campaigns.where((campaign) {
        final campaignStart = campaign.startTime;
        return campaignStart.isAfter(weekStartMidnight) ||
               campaignStart.isAtSameMomentAs(weekStartMidnight);
      });

      // Get unique zones
      final uniqueZones = <String>{};
      for (final campaign in thisWeekCampaigns) {
        uniqueZones.add(campaign.zone);
      }

      return uniqueZones.length;
    },
    orElse: () => 0,
  );
});

final connectivityStatusProvider = StreamProvider<bool>((ref) {
  final connectivityService = ref.watch(connectivityServiceProvider);
  return connectivityService.connectivityStream;
});

// Theme provider
final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier();
});

// Role-based theme providers
final lightThemeProvider = Provider<ThemeData>((ref) {
  final authState = ref.watch(authStateProvider);
  final seedColor = authState.maybeWhen(
    data: (user) => user?.role == model.UserRole.promoter ? AppColors.primary : AppColors.primary,
    orElse: () => AppColors.primary,
  );
  return AppTheme.lightTheme(seedColor);
});

final darkThemeProvider = Provider<ThemeData>((ref) {
  final authState = ref.watch(authStateProvider);
  final seedColor = authState.maybeWhen(
    data: (user) => user?.role == model.UserRole.promoter ? AppColors.primary : AppColors.primary,
    orElse: () => AppColors.primary,
  );
  return AppTheme.darkTheme(seedColor);
});

// Locale provider
final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier();
});

// Notification service provider
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return OverlayNotificationService(AppRouter.navigatorKey);
});

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.system) {
    _loadThemeMode();
  }

  Future<void> _loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final themeModeString = prefs.getString('themeMode');
    if (themeModeString != null) {
      state = ThemeMode.values.firstWhere(
        (mode) => mode.toString() == themeModeString,
        orElse: () => ThemeMode.system,
      );
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('themeMode', mode.toString());
  }

  Future<void> toggleTheme() async {
    final newMode = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    await setThemeMode(newMode);
  }
}

class LocaleNotifier extends StateNotifier<Locale> {
  LocaleNotifier() : super(const Locale('en')) {
    _loadLocale();
  }

  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final localeString = prefs.getString('languageCode');
    if (localeString != null) {
      state = Locale(localeString);
    }
  }

  Future<void> setLocale(Locale locale) async {
    state = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('languageCode', locale.languageCode);
  }
}

class AuthNotifier extends StateNotifier<AsyncValue<model.User?>> {
  final AuthRepository _repository;

  AuthNotifier(this._repository) : super(const AsyncValue.loading()) {
    _loadUser();
  }

  Future<void> _loadUser() async {
    state = const AsyncValue.loading();
    try {
      final user = await _repository.getCurrentUser();
      if (mounted) {
        state = AsyncValue.data(user);
      }
    } catch (e, stack) {
      if (mounted) {
        state = AsyncValue.error(e, stack);
      }
    }
  }

  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final user = await _repository.login(email, password);
      if (mounted) {
        state = AsyncValue.data(user);
      }
    } catch (e, stack) {
      if (mounted) {
        state = AsyncValue.error(e, stack);
      }
    }
  }

  Future<void> logout() async {
    try {
      await _repository.logout();
      if (mounted) {
        state = const AsyncValue.data(null);
      }
    } catch (e, stack) {
      if (mounted) {
        state = AsyncValue.error(e, stack);
      }
    }
  }
}

class CampaignsNotifier extends StateNotifier<AsyncValue<List<model.Campaign>>> {
  final GetCampaignsUseCase _getCampaignsUseCase;
  final CreateCampaignUseCase _createCampaignUseCase;
  final UpdateCampaignUseCase _updateCampaignUseCase;
  final DeleteCampaignUseCase _deleteCampaignUseCase;

  CampaignsNotifier(
    this._getCampaignsUseCase,
    this._createCampaignUseCase,
    this._updateCampaignUseCase,
    this._deleteCampaignUseCase,
  ) : super(const AsyncValue.loading()) {
    loadCampaigns();
  }

  Future<void> loadCampaigns({
    String? status,
    String? zone,
    String? createdBy,
    int? perPage,
  }) async {
    state = const AsyncValue.loading();
    try {
      final campaigns = await _getCampaignsUseCase(
        (status != null || zone != null || createdBy != null || perPage != null)
            ? GetCampaignsParams(
                status: status,
                zone: zone,
                createdBy: createdBy,
                perPage: perPage,
              )
            : null,
      );
      if (mounted) {
        state = AsyncValue.data(campaigns);
      }
    } catch (e, stack) {
      if (mounted) {
        state = AsyncValue.error(e, stack);
      }
    }
  }

  Future<void> createCampaign(model.Campaign campaign, {File? audioFile}) async {
    try {
      final created = await _createCampaignUseCase(
        CreateCampaignParams(campaign: campaign, audioFile: audioFile),
      );
      if (mounted) {
        state = state.maybeWhen(
          data: (campaigns) => AsyncValue.data([...campaigns, created]),
          orElse: () => AsyncValue.data([created]),
        );
      }
    } catch (e, stack) {
      if (mounted) {
        state = AsyncValue.error(e, stack);
      }
    }
  }

  Future<void> updateCampaign(model.Campaign campaign) async {
    try {
      final updated = await _updateCampaignUseCase(campaign);
      if (mounted) {
        state = state.maybeWhen(
          data: (campaigns) => AsyncValue.data(
            campaigns.map((c) => c.id == updated.id ? updated : c).toList(),
          ),
          orElse: () => AsyncValue.data([updated]),
        );
      }
    } catch (e, stack) {
      if (mounted) {
        state = AsyncValue.error(e, stack);
      }
    }
  }

  Future<void> deleteCampaign(String campaignId) async {
    try {
      await _deleteCampaignUseCase(campaignId);
      if (mounted) {
        state = state.maybeWhen(
          data: (campaigns) => AsyncValue.data(
            campaigns.where((c) => c.id != campaignId).toList(),
          ),
          orElse: () => const AsyncValue.data([]),
        );
      }
    } catch (e, stack) {
      if (mounted) {
        state = AsyncValue.error(e, stack);
      }
    }
  }
}

// Advertiser tab navigation provider
class AdvertiserTabNotifier extends StateNotifier<int> {
  AdvertiserTabNotifier() : super(0);

  void setTab(int index) {
    state = index;
  }
}

final advertiserTabProvider = StateNotifierProvider<AdvertiserTabNotifier, int>((ref) {
  return AdvertiserTabNotifier();
});

// First campaign flag provider
class FirstCampaignNotifier extends StateNotifier<bool> {
  FirstCampaignNotifier() : super(false) {
    _loadFlag();
  }

  Future<void> _loadFlag() async {
    final prefs = await SharedPreferences.getInstance();
    final hasCreated = prefs.getBool('hasCreatedFirstCampaign') ?? false;
    if (mounted) {
      state = hasCreated;
    }
  }

  Future<void> markFirstCampaignCreated() async {
    state = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasCreatedFirstCampaign', true);
  }

  /// Syncs the flag with actual campaign data
  /// If user has campaigns but flag is false (e.g., after reinstall), set it to true
  Future<void> syncWithCampaigns(int totalCampaignCount) async {
    if (!state && totalCampaignCount > 0) {
      await markFirstCampaignCreated();
    }
  }
}

final firstCampaignProvider = StateNotifierProvider<FirstCampaignNotifier, bool>((ref) {
  return FirstCampaignNotifier();
});