// Campaign Management Providers
//
// This file contains providers specific to campaign management features.

import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:promoruta/core/core.dart' as model;
import 'package:promoruta/core/utils/logger.dart';
import 'package:promoruta/shared/providers/infrastructure_providers.dart';
import 'package:promoruta/features/advertiser/campaign_creation/data/datasources/remote/media_remote_data_source.dart';
import 'package:promoruta/features/advertiser/campaign_creation/domain/repositories/media_repository.dart';
import 'package:promoruta/features/advertiser/campaign_management/data/datasources/local/campaign_local_data_source.dart';
import 'package:promoruta/features/advertiser/campaign_management/data/datasources/remote/campaign_remote_data_source.dart';
import 'package:promoruta/features/advertiser/campaign_management/data/repositories/campaign_repository_impl.dart';
import 'package:promoruta/features/advertiser/campaign_management/domain/repositories/campaign_repository.dart';
import 'package:promoruta/features/advertiser/campaign_management/domain/use_cases/campaign_use_cases.dart';
import 'package:promoruta/features/advertiser/campaign_management/data/datasources/remote/advertiser_live_remote_data_source.dart';
import 'package:promoruta/features/advertiser/campaign_management/data/repositories/advertiser_live_repository_impl.dart';
import 'package:promoruta/features/advertiser/campaign_management/domain/repositories/advertiser_live_repository.dart';
import 'package:promoruta/features/auth/presentation/providers/auth_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

final mediaRemoteDataSourceProvider = Provider<MediaRemoteDataSource>((ref) {
  final dio = ref.watch(dioProvider);
  return MediaRemoteDataSourceImpl(dio: dio);
});

final advertiserLiveRemoteDataSourceProvider =
    Provider<AdvertiserLiveRemoteDataSource>((ref) {
  final dio = ref.watch(dioProvider);
  return AdvertiserLiveRemoteDataSourceImpl(dio: dio);
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

final mediaRepositoryProvider = Provider<MediaRepository>((ref) {
  final remoteDataSource = ref.watch(mediaRemoteDataSourceProvider);

  return MediaRepositoryImpl(
    remoteDataSource: remoteDataSource,
  );
});

final advertiserLiveRepositoryProvider =
    Provider<AdvertiserLiveRepository>((ref) {
  final remoteDataSource = ref.watch(advertiserLiveRemoteDataSourceProvider);
  return AdvertiserLiveRepositoryImpl(remoteDataSource: remoteDataSource);
});

// ============ Use Cases ============

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

// ============ State Providers ============

// Provider for getting a single campaign by ID
final campaignByIdProvider = FutureProvider.autoDispose
    .family<model.Campaign?, String>((ref, campaignId) async {
  final getCampaignUseCase = ref.watch(getCampaignUseCaseProvider);
  return await getCampaignUseCase(campaignId);
});

// Campaign list notifier
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
// Note: keepAlive prevents re-fetching when navigating away and back to this tab
final activeCampaignsProvider =
    FutureProvider<List<model.Campaign>>((ref) async {
  final getCampaignsUseCase = ref.watch(getCampaignsUseCaseProvider);
  return await getCampaignsUseCase(
      const GetCampaignsParams(status: 'in_progress'));
});

// Provider for promoter's active campaigns (accepted by current user, status = in_progress)
// Note: keepAlive prevents re-fetching when navigating away and back to this tab
final promoterActiveCampaignsProvider =
    FutureProvider<List<model.Campaign>>((ref) async {
  final authState = ref.watch(authStateProvider);
  final getCampaignsUseCase = ref.watch(getCampaignsUseCaseProvider);

  final user = authState.valueOrNull;
  if (user == null) return [];

  return await getCampaignsUseCase(GetCampaignsParams(
    acceptedBy: user.id,
    status: 'in_progress',
  ));
});

// Provider for promoter's accepted campaigns (all statuses for history)
// Note: keepAlive prevents re-fetching when navigating away and back to this tab
final promoterAcceptedCampaignsProvider =
    FutureProvider<List<model.Campaign>>((ref) async {
  final authState = ref.watch(authStateProvider);
  final getCampaignsUseCase = ref.watch(getCampaignsUseCaseProvider);

  final user = authState.valueOrNull;
  if (user == null) return [];

  return await getCampaignsUseCase(GetCampaignsParams(
    acceptedBy: user.id,
  ));
});

// Provider for advertiser KPI stats from backend
// Note: keepAlive prevents re-fetching when navigating away and back to dashboard
final kpiStatsProvider =
    FutureProvider<model.AdvertiserKpiStats>((ref) async {
  final repository = ref.watch(campaignRepositoryProvider);
  final result = await repository.getKpiStats();
  return result.fold(
    (stats) => stats,
    (error) => throw Exception(error.message),
  );
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

      final thisWeekCampaigns = campaigns.where((campaign) {
        final campaignStart = campaign.startTime;
        return campaignStart.isAfter(weekStartMidnight) ||
            campaignStart.isAtSameMomentAs(weekStartMidnight);
      });

      final uniqueZones = <String>{};
      for (final campaign in thisWeekCampaigns) {
        uniqueZones.add(campaign.zone);
      }

      return uniqueZones.length;
    },
    orElse: () => 0,
  );
});

// ============ UI State ============

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

/// First campaign flag notifier
/// Tracks whether the user has created their first campaign
/// This flag is persisted in SharedPreferences and used to show onboarding UI
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
}

final firstCampaignProvider =
    StateNotifierProvider<FirstCampaignNotifier, bool>((ref) {
  return FirstCampaignNotifier();
});

// ============ Notifiers ============

/// CampaignsNotifier
///
/// Manages the list of campaigns with pagination support.
/// This is the single source of truth for campaign data in the advertiser flow.
///
/// Refresh triggers:
/// - Initial load: Called automatically in constructor via loadCampaigns()
/// - User filter: Call loadCampaigns() with new filter parameters (this resets pagination)
/// - Load more: Call loadMoreCampaigns() to append next page
/// - After campaign creation/update/deletion: Automatically updates in-memory list
///
/// Data persistence: The notifier keeps the full list in memory and manages pagination state.
/// When filters change, the pagination is reset (page=1) to avoid confusion.
class CampaignsNotifier
    extends StateNotifier<AsyncValue<List<model.Campaign>>> {
  final GetCampaignsUseCase _getCampaignsUseCase;
  final CreateCampaignUseCase _createCampaignUseCase;
  final UpdateCampaignUseCase _updateCampaignUseCase;
  final DeleteCampaignUseCase _deleteCampaignUseCase;

  int _currentPage = 1;
  int _pageSize = 10;
  bool _hasMoreCampaigns = true;
  String? _currentStatus;
  String? _currentZone;
  String? _currentCreatedBy;

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
    // Reset pagination state when reloading
    _currentPage = 1;
    _hasMoreCampaigns = true;
    _currentStatus = status;
    _currentZone = zone;
    _currentCreatedBy = createdBy;
    if (perPage != null) _pageSize = perPage;

    state = const AsyncValue.loading();
    try {
      final campaigns = await _getCampaignsUseCase(
        (status != null || zone != null || createdBy != null || perPage != null)
            ? GetCampaignsParams(
                status: status,
                zone: zone,
                createdBy: createdBy,
                page: _currentPage,
                perPage: perPage ?? _pageSize,
              )
            : GetCampaignsParams(
                page: _currentPage,
                perPage: _pageSize,
              ),
      );
      if (mounted) {
        state = AsyncValue.data(campaigns);
        // If we got fewer items than requested, we've reached the end
        _hasMoreCampaigns = campaigns.length >= _pageSize;
      }
    } catch (e, stack) {
      if (mounted) {
        state = AsyncValue.error(e, stack);
      }
    }
  }

  /// Load the next page of campaigns and append to existing list
  Future<void> loadMoreCampaigns() async {
    if (!_hasMoreCampaigns) return;

    try {
      // Only proceed if we have data state
      final currentList = state.maybeWhen(
        data: (list) => list,
        orElse: () => null,
      );

      if (currentList == null) return;

      _currentPage++;

      final nextCampaigns = await _getCampaignsUseCase(
        GetCampaignsParams(
          status: _currentStatus,
          zone: _currentZone,
          createdBy: _currentCreatedBy,
          page: _currentPage,
          perPage: _pageSize,
        ),
      );

      if (mounted) {
        if (nextCampaigns.isEmpty) {
          _hasMoreCampaigns = false;
        } else {
          // Append new campaigns to existing list
          state = AsyncValue.data([...currentList, ...nextCampaigns]);
          _hasMoreCampaigns = nextCampaigns.length >= _pageSize;
        }
      }
    } catch (e) {
      // Log error but keep existing data
      AppLogger.auth.e('Error loading more campaigns: $e');
    }
  }

  /// Check if there are more campaigns to load
  bool get hasMoreCampaigns => _hasMoreCampaigns;

  /// Get current page number
  int get currentPage => _currentPage;

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
