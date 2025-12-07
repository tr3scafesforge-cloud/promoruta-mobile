import 'dart:io';
import 'package:promoruta/core/core.dart' as model;
import 'package:promoruta/core/utils/logger.dart';
import 'package:promoruta/shared/shared.dart';
import '../../domain/repositories/campaign_repository.dart';

class CampaignRepositoryImpl implements CampaignRepository {
  final CampaignLocalDataSource _localDataSource;
  final CampaignRemoteDataSource _remoteDataSource;
  final ConnectivityService _connectivityService;
  final SyncService _syncService;

  CampaignRepositoryImpl(
    this._localDataSource,
    this._remoteDataSource,
    this._connectivityService,
    this._syncService,
  );

  @override
  Future<List<model.Campaign>> getCampaigns() async {
    final isConnected = await _connectivityService.isConnected;

    if (isConnected) {
      try {
        // Try remote first
        final remoteCampaigns = await _remoteDataSource.getCampaigns();

        // Try to update local cache, but don't fail if it errors
        try {
          await _localDataSource.saveCampaigns(remoteCampaigns);
        } catch (localError) {
          // Ignore local storage errors - we have remote data
          AppLogger.auth.w('Could not save to local cache: $localError');
        }

        return remoteCampaigns;
      } catch (remoteError) {
        // Remote failed, try local as fallback
        try {
          final localCampaigns = await _localDataSource.getCampaigns();
          return localCampaigns;
        } catch (localError) {
          // Both failed, rethrow remote error as it's more important
          rethrow;
        }
      }
    } else {
      // Offline: try local data
      try {
        return await _localDataSource.getCampaigns();
      } catch (e) {
        // Local data unavailable and offline
        throw Exception('No internet connection and local cache unavailable');
      }
    }
  }

  @override
  Future<model.Campaign> getCampaign(String id) async {
    final isConnected = await _connectivityService.isConnected;

    if (isConnected) {
      try {
        final remoteCampaign = await _remoteDataSource.getCampaign(id);

        // Try to update local cache, but don't fail if it errors
        try {
          await _localDataSource.saveCampaign(remoteCampaign);
        } catch (localError) {
          AppLogger.auth.w('Could not save to local cache: $localError');
        }

        return remoteCampaign;
      } catch (remoteError) {
        // Remote failed, try local as fallback
        try {
          final localCampaign = await _localDataSource.getCampaign(id);
          if (localCampaign != null) {
            return localCampaign;
          }
        } catch (localError) {
          // Ignore local error, rethrow remote error
        }
        rethrow;
      }
    } else {
      // Offline: try local data
      try {
        final localCampaign = await _localDataSource.getCampaign(id);
        if (localCampaign != null) {
          return localCampaign;
        }
        throw Exception('Campaign not found and no internet connection');
      } catch (e) {
        throw Exception('Campaign not found and no internet connection');
      }
    }
  }

  @override
  Future<model.Campaign> createCampaign(model.Campaign campaign, {File? audioFile}) async {
    final isConnected = await _connectivityService.isConnected;

    if (isConnected) {
      try {
        final createdCampaign = await _remoteDataSource.createCampaign(campaign, audioFile: audioFile);

        // Try to save locally, but don't fail if it errors
        try {
          await _localDataSource.saveCampaign(createdCampaign);
        } catch (localError) {
          AppLogger.auth.w('Could not save to local cache: $localError');
        }

        return createdCampaign;
      } catch (e) {
        // If remote fails, try save locally for later sync
        try {
          await _localDataSource.saveCampaign(campaign);
        } catch (localError) {
          AppLogger.auth.w('Could not save to local cache: $localError');
        }
        rethrow;
      }
    } else {
      // Offline: try save locally
      try {
        await _localDataSource.saveCampaign(campaign);
      } catch (localError) {
        AppLogger.auth.w('Could not save to local cache: $localError');
      }
      throw Exception('No internet connection. Campaign creation requires online access.');
    }
  }

  @override
  Future<model.Campaign> updateCampaign(model.Campaign campaign) async {
    final isConnected = await _connectivityService.isConnected;

    if (isConnected) {
      try {
        final updatedCampaign = await _remoteDataSource.updateCampaign(campaign);

        // Try to update local cache, but don't fail if it errors
        try {
          await _localDataSource.saveCampaign(updatedCampaign);
        } catch (localError) {
          AppLogger.auth.w('Could not save to local cache: $localError');
        }

        return updatedCampaign;
      } catch (e) {
        // If remote fails, try update locally
        try {
          await _localDataSource.saveCampaign(campaign);
        } catch (localError) {
          AppLogger.auth.w('Could not save to local cache: $localError');
        }
        rethrow;
      }
    } else {
      // Offline: try update locally
      try {
        await _localDataSource.saveCampaign(campaign);
      } catch (localError) {
        AppLogger.auth.w('Could not save to local cache: $localError');
      }
      throw Exception('No internet connection. Campaign update requires online access.');
    }
  }

  @override
  Future<void> deleteCampaign(String id) async {
    final isConnected = await _connectivityService.isConnected;

    if (isConnected) {
      try {
        await _remoteDataSource.deleteCampaign(id);

        // Try to remove from local, but don't fail if it errors
        try {
          await _localDataSource.deleteCampaign(id);
        } catch (localError) {
          AppLogger.auth.w('Could not delete from local cache: $localError');
        }
      } catch (e) {
        // If remote fails, try mark for deletion locally
        try {
          await _localDataSource.deleteCampaign(id);
        } catch (localError) {
          AppLogger.auth.w('Could not delete from local cache: $localError');
        }
        rethrow;
      }
    } else {
      // Offline: try delete locally
      try {
        await _localDataSource.deleteCampaign(id);
      } catch (localError) {
        AppLogger.auth.w('Could not delete from local cache: $localError');
      }
      throw Exception('No internet connection. Campaign deletion requires online access.');
    }
  }
}
