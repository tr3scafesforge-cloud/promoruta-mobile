// Promoter Feature Providers
//
// This file contains providers specific to promoter features including
// GPS tracking, route execution, and promoter statistics.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:promoruta/core/models/promoter_kpi_stats.dart';
import 'package:promoruta/shared/providers/infrastructure_providers.dart';
import 'package:promoruta/shared/services/sync_service.dart';
import 'package:promoruta/shared/services/sync_service_impl.dart';
import 'package:promoruta/shared/services/location_service.dart';
import 'package:promoruta/features/auth/presentation/providers/auth_providers.dart';
import 'package:promoruta/features/promotor/gps_tracking/data/datasources/local/gps_local_data_source.dart';
import 'package:promoruta/features/promotor/gps_tracking/data/datasources/remote/gps_remote_data_source.dart';
import 'package:promoruta/features/promotor/gps_tracking/data/repositories/gps_repository_impl.dart';
import 'package:promoruta/features/promotor/gps_tracking/domain/repositories/gps_repository.dart';
import 'package:promoruta/features/promotor/data/datasources/remote/promoter_remote_data_source.dart';
import 'package:promoruta/features/promotor/data/repositories/promoter_repository_impl.dart';
import 'package:promoruta/features/promotor/domain/repositories/promoter_repository.dart';
import 'package:promoruta/features/promotor/route_execution/data/services/campaign_audio_service.dart';
import 'package:promoruta/features/promotor/route_execution/domain/models/campaign_execution_state.dart';
import 'package:promoruta/features/promotor/route_execution/presentation/providers/campaign_execution_notifier.dart';
import 'package:promoruta/features/promotor/route_execution/domain/use_cases/sync_gps_points_use_case.dart';

// Import campaign providers for sync service dependencies
import 'package:promoruta/features/advertiser/campaign_management/presentation/providers/campaign_providers.dart';

// ============ Data Sources ============

final gpsLocalDataSourceProvider = Provider<GpsLocalDataSource>((ref) {
  final database = ref.watch(databaseProvider);
  return GpsLocalDataSourceImpl(database);
});

final gpsRemoteDataSourceProvider = Provider<GpsRemoteDataSource>((ref) {
  final dio = ref.watch(dioProvider);
  return GpsRemoteDataSourceImpl(dio: dio);
});

final promoterRemoteDataSourceProvider =
    Provider<PromoterRemoteDataSource>((ref) {
  final dio = ref.watch(dioProvider);
  return PromoterRemoteDataSourceImpl(dio: dio);
});

// ============ Services ============

// Sync Service for offline data synchronization
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

// Campaign Audio Service Provider
final campaignAudioServiceProvider = Provider<CampaignAudioService>((ref) {
  final service = CampaignAudioService();
  ref.onDispose(() => service.dispose());
  return service;
});

// ============ Use Cases ============

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

final promoterRepositoryProvider = Provider<PromoterRepository>((ref) {
  final remoteDataSource = ref.watch(promoterRemoteDataSourceProvider);
  final connectivityService = ref.watch(connectivityServiceProvider);

  return PromoterRepositoryImpl(
    remoteDataSource,
    connectivityService,
  );
});

// ============ State Providers ============

// Campaign Execution State Provider
final campaignExecutionProvider =
    StateNotifierProvider<CampaignExecutionNotifier, CampaignExecutionState>(
        (ref) {
  final locationService = ref.watch(campaignLocationServiceProvider);
  final syncUseCase = ref.watch(syncGpsPointsUseCaseProvider);
  return CampaignExecutionNotifier(locationService, syncUseCase);
});

// Provider for promoter KPI stats from backend
final promoterKpiStatsProvider =
    FutureProvider.autoDispose<PromoterKpiStats>((ref) async {
  final repository = ref.watch(promoterRepositoryProvider);
  return await repository.getKpiStats();
});
