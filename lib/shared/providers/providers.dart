import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:promoruta/shared/shared.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:promoruta/core/core.dart' as model;
import 'package:promoruta/core/models/config.dart';


// Database provider
final databaseProvider = Provider<AppDatabase>((ref) {
  final database = AppDatabase();
  ref.onDispose(() => database.close());
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
    orElse: () => const AppConfig(baseUrl: 'http://172.81.177.85/'), // Fallback
  );

  final dio = Dio(BaseOptions(
    baseUrl: config.baseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  // Add interceptors if needed
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

// Services
final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  final connectivity = ref.watch(connectivityProvider);
  final service = ConnectivityServiceImpl(connectivity);
  ref.onDispose(() => service.dispose());
  return service;
});

// Data Sources
final authLocalDataSourceProvider = Provider<AuthLocalDataSource>((ref) {
  final database = ref.watch(databaseProvider);
  return AuthLocalDataSourceImpl(database);
});

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  final dio = ref.watch(dioProvider);
  return AuthRemoteDataSourceImpl(dio: dio);
});

final campaignLocalDataSourceProvider = Provider<CampaignLocalDataSource>((ref) {
  final database = ref.watch(databaseProvider);
  return CampaignLocalDataSourceImpl(database);
});

final campaignRemoteDataSourceProvider = Provider<CampaignRemoteDataSource>((ref) {
  final dio = ref.watch(dioProvider);
  return CampaignRemoteDataSourceImpl(dio: dio);
});

final gpsLocalDataSourceProvider = Provider<GpsLocalDataSource>((ref) {
  final database = ref.watch(databaseProvider);
  return GpsLocalDataSourceImpl(database);
});

final gpsRemoteDataSourceProvider = Provider<GpsRemoteDataSource>((ref) {
  final dio = ref.watch(dioProvider);
  return GpsRemoteDataSourceImpl(dio: dio);
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

// Use Cases
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

final connectivityStatusProvider = StreamProvider<bool>((ref) {
  final connectivityService = ref.watch(connectivityServiceProvider);
  return connectivityService.connectivityStream;
});

// Theme provider
final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier();
});

// Locale provider
final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier();
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
      state = AsyncValue.data(user);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final user = await _repository.login(email, password);
      state = AsyncValue.data(user);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> logout() async {
    try {
      await _repository.logout();
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
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

  Future<void> loadCampaigns() async {
    state = const AsyncValue.loading();
    try {
      final campaigns = await _getCampaignsUseCase();
      state = AsyncValue.data(campaigns);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> createCampaign(model.Campaign campaign) async {
    try {
      final created = await _createCampaignUseCase(campaign);
      state = state.maybeWhen(
        data: (campaigns) => AsyncValue.data([...campaigns, created]),
        orElse: () => AsyncValue.data([created]),
      );
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> updateCampaign(model.Campaign campaign) async {
    try {
      final updated = await _updateCampaignUseCase(campaign);
      state = state.maybeWhen(
        data: (campaigns) => AsyncValue.data(
          campaigns.map((c) => c.id == updated.id ? updated : c).toList(),
        ),
        orElse: () => AsyncValue.data([updated]),
      );
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> deleteCampaign(String campaignId) async {
    try {
      await _deleteCampaignUseCase(campaignId);
      state = state.maybeWhen(
        data: (campaigns) => AsyncValue.data(
          campaigns.where((c) => c.id != campaignId).toList(),
        ),
        orElse: () => const AsyncValue.data([]),
      );
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}