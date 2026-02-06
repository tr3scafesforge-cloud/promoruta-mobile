import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:promoruta/shared/services/sync_service.dart';
import 'package:promoruta/shared/services/sync_service_impl.dart';
import 'package:promoruta/features/profile/data/datasources/local/user_local_data_source.dart'
    as user_ds;
import 'package:promoruta/features/profile/data/datasources/remote/user_remote_data_source.dart'
    as user_remote_ds;
import 'package:promoruta/features/profile/data/repositories/user_repository_impl.dart';
import 'package:promoruta/features/profile/domain/repositories/user_repository.dart'
    hide UserLocalDataSource, UserRemoteDataSource;
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
import 'package:promoruta/features/promotor/data/datasources/remote/promoter_remote_data_source.dart';
import 'package:promoruta/features/promotor/data/repositories/promoter_repository_impl.dart';
import 'package:promoruta/features/promotor/domain/repositories/promoter_repository.dart';
import 'package:promoruta/core/models/promoter_kpi_stats.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:promoruta/core/core.dart' as model;
import 'package:promoruta/core/constants/colors.dart';
import 'package:promoruta/features/promotor/route_execution/data/services/campaign_audio_service.dart';
import 'package:promoruta/core/theme.dart';
import 'package:promoruta/app/routes/app_router.dart';
import 'package:promoruta/shared/services/notification_service.dart';
import 'package:promoruta/shared/services/overlay_notification_service.dart';
import 'package:promoruta/shared/services/route_service.dart';
import 'package:promoruta/shared/services/route_service_impl.dart';
import 'package:promoruta/shared/services/geocoding_service.dart';
import 'package:promoruta/shared/services/geocoding_service_impl.dart';
import 'package:promoruta/shared/services/location_service.dart';
import 'package:promoruta/shared/services/update_check_service.dart';
import 'package:promoruta/shared/services/update_check_service_impl.dart';
import 'package:promoruta/core/models/version_info.dart';
import 'package:promoruta/features/promotor/route_execution/domain/models/campaign_execution_state.dart';
import 'package:promoruta/features/promotor/route_execution/presentation/providers/campaign_execution_notifier.dart';
import 'package:promoruta/features/promotor/route_execution/domain/use_cases/sync_gps_points_use_case.dart';
import 'package:promoruta/features/advertiser/campaign_management/data/datasources/remote/advertiser_live_remote_data_source.dart';
import 'package:promoruta/features/advertiser/campaign_management/data/repositories/advertiser_live_repository_impl.dart';
import 'package:promoruta/features/advertiser/campaign_management/domain/repositories/advertiser_live_repository.dart';
import 'package:geolocator/geolocator.dart';

// Re-export infrastructure providers (database, dio, connectivity, logger, config)
export 'infrastructure_providers.dart';

// Re-export auth providers from feature layer
export 'package:promoruta/features/auth/presentation/providers/auth_providers.dart';

// Import infrastructure providers for use in this file
import 'package:promoruta/shared/providers/infrastructure_providers.dart';

// Import auth providers for use in this file
import 'package:promoruta/features/auth/presentation/providers/auth_providers.dart';

// ============ Services ============

final routeServiceProvider = Provider<RouteService>((ref) {
  final dio = ref.watch(dioProvider);
  final logger = ref.watch(loggerProvider);
  return RouteServiceImpl(dio: dio, logger: logger);
});

final geocodingServiceProvider = Provider<GeocodingService>((ref) {
  final logger = ref.watch(loggerProvider);
  return GeocodingServiceImpl(logger: logger);
});

// Location Service for GPS tracking during campaign execution
final campaignLocationServiceProvider = Provider<LocationService>((ref) {
  final service = LocationService();
  ref.onDispose(() => service.dispose());
  return service;
});

// Location stream provider for real-time position updates during campaign
final campaignLocationStreamProvider = StreamProvider<Position>((ref) {
  final locationService = ref.watch(campaignLocationServiceProvider);
  return locationService.positionStream;
});

// Campaign Execution State Provider
final campaignExecutionProvider =
    StateNotifierProvider<CampaignExecutionNotifier, CampaignExecutionState>(
        (ref) {
  final locationService = ref.watch(campaignLocationServiceProvider);
  final syncUseCase = ref.watch(syncGpsPointsUseCaseProvider);
  return CampaignExecutionNotifier(locationService, syncUseCase);
});

// Campaign Audio Service Provider
final campaignAudioServiceProvider = Provider<CampaignAudioService>((ref) {
  final service = CampaignAudioService();
  ref.onDispose(() => service.dispose());
  return service;
});

// ============ Data Sources ============

final campaignLocalDataSourceProvider =
    Provider<CampaignLocalDataSource>((ref) {
  final database = ref.watch(databaseProvider);
  return CampaignLocalDataSourceImpl(database);
});

final campaignRemoteDataSourceProvider =
    Provider<CampaignRemoteDataSource>((ref) {
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

final userLocalDataSourceProvider =
    Provider<user_ds.UserLocalDataSource>((ref) {
  final database = ref.watch(databaseProvider);
  return user_ds.UserLocalDataSourceImpl(database);
});

final userRemoteDataSourceProvider =
    Provider<user_remote_ds.UserRemoteDataSource>((ref) {
  final dio = ref.watch(dioProvider);
  return user_remote_ds.UserRemoteDataSourceImpl(dio: dio);
});

final mediaRemoteDataSourceProvider = Provider<MediaRemoteDataSource>((ref) {
  final dio = ref.watch(dioProvider);
  return MediaRemoteDataSourceImpl(dio: dio);
});

// ============ Sync Service ============

final syncServiceProvider = Provider<SyncService>((ref) {
  final connectivityService = ref.watch(connectivityServiceProvider);
  final authLocal = ref.watch(authLocalDataSourceProvider);
  final campaignLocal = ref.watch(campaignLocalDataSourceProvider);
  final campaignRemote = ref.watch(campaignRemoteDataSourceProvider);
  final gpsLocal = ref.watch(gpsLocalDataSourceProvider);
  final gpsRemote = ref.watch(gpsRemoteDataSourceProvider);

  return SyncServiceImpl(
    connectivityService,
    authLocal,
    campaignLocal,
    campaignRemote,
    gpsLocal,
    gpsRemote,
  );
});

// Sync GPS Points Use Case
final syncGpsPointsUseCaseProvider = Provider<SyncGpsPointsUseCase>((ref) {
  final gpsLocal =
      ref.watch(gpsLocalDataSourceProvider) as GpsLocalDataSourceImpl;
  final gpsRemote =
      ref.watch(gpsRemoteDataSourceProvider) as GpsRemoteDataSourceImpl;
  return SyncGpsPointsUseCase(
    localDataSource: gpsLocal,
    remoteDataSource: gpsRemote,
  );
});

// ============ Repositories ============

final campaignRepositoryProvider = Provider<CampaignRepository>((ref) {
  final localDataSource = ref.watch(campaignLocalDataSourceProvider);
  final remoteDataSource = ref.watch(campaignRemoteDataSourceProvider);
  final connectivityService = ref.watch(connectivityServiceProvider);

  return CampaignRepositoryImpl(
    localDataSource,
    remoteDataSource,
    connectivityService,
  );
});

final gpsRepositoryProvider = Provider<GpsRepository>((ref) {
  final localDataSource = ref.watch(gpsLocalDataSourceProvider);
  final connectivityService = ref.watch(connectivityServiceProvider);
  final syncService = ref.watch(syncServiceProvider);
  final authRepository = ref.watch(authRepositoryProvider);

  return GpsRepositoryImpl(
    localDataSource,
    connectivityService,
    syncService,
    authRepository,
  );
});

final promoterRemoteDataSourceProvider =
    Provider<PromoterRemoteDataSource>((ref) {
  final dio = ref.watch(dioProvider);
  return PromoterRemoteDataSourceImpl(dio: dio);
});

final promoterRepositoryProvider = Provider<PromoterRepository>((ref) {
  final remoteDataSource = ref.watch(promoterRemoteDataSourceProvider);
  final connectivityService = ref.watch(connectivityServiceProvider);

  return PromoterRepositoryImpl(
    remoteDataSource,
    connectivityService,
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

// Advertiser Live Repository
final advertiserLiveRemoteDataSourceProvider =
    Provider<AdvertiserLiveRemoteDataSource>((ref) {
  final dio = ref.watch(dioProvider);
  return AdvertiserLiveRemoteDataSourceImpl(dio: dio);
});

final advertiserLiveRepositoryProvider =
    Provider<AdvertiserLiveRepository>((ref) {
  final remoteDataSource = ref.watch(advertiserLiveRemoteDataSourceProvider);
  return AdvertiserLiveRepositoryImpl(remoteDataSource: remoteDataSource);
});

// ============ Campaign Use Cases ============

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

final cancelCampaignUseCaseProvider = Provider<CancelCampaignUseCase>((ref) {
  final repository = ref.watch(campaignRepositoryProvider);
  return CancelCampaignUseCase(repository);
});

// Provider for getting a single campaign by ID
final campaignByIdProvider = FutureProvider.autoDispose
    .family<model.Campaign?, String>((ref, campaignId) async {
  final getCampaignUseCase = ref.watch(getCampaignUseCaseProvider);
  return await getCampaignUseCase(campaignId);
});

// ============ State Notifiers for UI ============

final campaignsProvider =
    StateNotifierProvider<CampaignsNotifier, AsyncValue<List<model.Campaign>>>(
        (ref) {
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
final activeCampaignsProvider =
    FutureProvider.autoDispose<List<model.Campaign>>((ref) async {
  final getCampaignsUseCase = ref.watch(getCampaignsUseCaseProvider);
  return await getCampaignsUseCase(
      const GetCampaignsParams(status: 'in_progress'));
});

// Provider for promoter's active campaigns (accepted by current user, status = in_progress)
final promoterActiveCampaignsProvider =
    FutureProvider.autoDispose<List<model.Campaign>>((ref) async {
  final authState = ref.watch(authStateProvider);
  final getCampaignsUseCase = ref.watch(getCampaignsUseCaseProvider);

  final user = authState.valueOrNull;
  if (user == null) return [];

  // Fetch campaigns accepted by this promoter that are in progress
  return await getCampaignsUseCase(GetCampaignsParams(
    acceptedBy: user.id,
    status: 'in_progress',
  ));
});

// Provider for promoter's accepted campaigns (all statuses for history)
final promoterAcceptedCampaignsProvider =
    FutureProvider.autoDispose<List<model.Campaign>>((ref) async {
  final authState = ref.watch(authStateProvider);
  final getCampaignsUseCase = ref.watch(getCampaignsUseCaseProvider);

  final user = authState.valueOrNull;
  if (user == null) return [];

  // Fetch all campaigns accepted by this promoter
  return await getCampaignsUseCase(GetCampaignsParams(
    acceptedBy: user.id,
  ));
});

// Provider for advertiser KPI stats from backend
final kpiStatsProvider =
    FutureProvider.autoDispose<model.AdvertiserKpiStats>((ref) async {
  final repository = ref.watch(campaignRepositoryProvider);
  final result = await repository.getKpiStats();
  return result.fold(
    (stats) => stats,
    (error) => throw Exception(error.message),
  );
});

// Provider for promoter KPI stats from backend
final promoterKpiStatsProvider =
    FutureProvider.autoDispose<PromoterKpiStats>((ref) async {
  final repository = ref.watch(promoterRepositoryProvider);
  return await repository.getKpiStats();
});

// Provider for zones covered this week (calculated locally)
final zonesCoveredThisWeekProvider = Provider<int>((ref) {
  final campaignsAsync = ref.watch(campaignsProvider);

  return campaignsAsync.maybeWhen(
    data: (campaigns) {
      final now = DateTime.now();
      final weekStart = now.subtract(Duration(days: now.weekday - 1));
      final weekStartMidnight =
          DateTime(weekStart.year, weekStart.month, weekStart.day);

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
final themeModeProvider =
    StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier();
});

// Role-based theme providers
final lightThemeProvider = Provider<ThemeData>((ref) {
  final authState = ref.watch(authStateProvider);
  final seedColor = authState.maybeWhen(
    data: (user) => user?.role == model.UserRole.promoter
        ? AppColors.primary
        : AppColors.primary,
    orElse: () => AppColors.primary,
  );
  return AppTheme.lightTheme(seedColor);
});

final darkThemeProvider = Provider<ThemeData>((ref) {
  final authState = ref.watch(authStateProvider);
  final seedColor = authState.maybeWhen(
    data: (user) => user?.role == model.UserRole.promoter
        ? AppColors.primary
        : AppColors.primary,
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

// Update check service provider
final updateCheckServiceProvider = Provider<UpdateCheckService?>((ref) {
  final configAsync = ref.watch(configProvider);
  final logger = ref.watch(loggerProvider);

  return configAsync.maybeWhen(
    data: (config) {
      final versionCheckUrl = config.versionCheckUrl;
      if (versionCheckUrl == null || versionCheckUrl.isEmpty) {
        return null;
      }
      return UpdateCheckServiceImpl(
        versionCheckUrl: versionCheckUrl,
        logger: logger,
      );
    },
    orElse: () => null,
  );
});

// Update check provider - checks for updates asynchronously
final updateCheckProvider =
    FutureProvider.autoDispose<VersionInfo?>((ref) async {
  final service = ref.watch(updateCheckServiceProvider);
  if (service == null) {
    return null;
  }
  return await service.checkForUpdates();
});

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.light) {
    _loadThemeMode();
  }

  Future<void> _loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final themeModeString = prefs.getString('themeMode');
    if (themeModeString != null) {
      state = ThemeMode.values.firstWhere(
        (mode) => mode.toString() == themeModeString,
        orElse: () => ThemeMode.light,
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
  LocaleNotifier() : super(const Locale('es')) {
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

class CampaignsNotifier
    extends StateNotifier<AsyncValue<List<model.Campaign>>> {
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

  Future<void> createCampaign(model.Campaign campaign,
      {File? audioFile}) async {
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

final advertiserTabProvider =
    StateNotifierProvider<AdvertiserTabNotifier, int>((ref) {
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

final firstCampaignProvider =
    StateNotifierProvider<FirstCampaignNotifier, bool>((ref) {
  return FirstCampaignNotifier();
});
