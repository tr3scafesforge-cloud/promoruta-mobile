import 'dart:io';
import 'package:promoruta/core/core.dart' as model;
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
    // Always try local first for immediate response
    final localCampaigns = await _localDataSource.getCampaigns();

    final isConnected = await _connectivityService.isConnected;
    if (isConnected) {
      try {
        final remoteCampaigns = await _remoteDataSource.getCampaigns();
        // Update local cache
        await _localDataSource.saveCampaigns(remoteCampaigns);
        return remoteCampaigns;
      } catch (e) {
        // Return local data if remote fails
        return localCampaigns;
      }
    } else {
      // Offline: return cached data
      return localCampaigns;
    }
  }

  @override
  Future<model.Campaign> getCampaign(String id) async {
    // Try local first
    final localCampaign = await _localDataSource.getCampaign(id);

    final isConnected = await _connectivityService.isConnected;
    if (isConnected) {
      try {
        final remoteCampaign = await _remoteDataSource.getCampaign(id);
        // Update local cache
        await _localDataSource.saveCampaign(remoteCampaign);
        return remoteCampaign;
      } catch (e) {
        // Return local data if remote fails
        if (localCampaign != null) {
          return localCampaign;
        }
        rethrow;
      }
    } else {
      // Offline: return cached data
      if (localCampaign != null) {
        return localCampaign;
      }
      throw Exception('Campaign not found and no internet connection');
    }
  }

  @override
  Future<model.Campaign> createCampaign(model.Campaign campaign, {File? audioFile}) async {
    final isConnected = await _connectivityService.isConnected;

    if (isConnected) {
      try {
        final createdCampaign = await _remoteDataSource.createCampaign(campaign, audioFile: audioFile);
        // Save locally
        await _localDataSource.saveCampaign(createdCampaign);
        return createdCampaign;
      } catch (e) {
        // If remote fails, save locally for later sync
        await _localDataSource.saveCampaign(campaign);
        return campaign;
      }
    } else {
      // Offline: save locally
      await _localDataSource.saveCampaign(campaign);
      return campaign;
    }
  }

  @override
  Future<model.Campaign> updateCampaign(model.Campaign campaign) async {
    final isConnected = await _connectivityService.isConnected;

    if (isConnected) {
      try {
        final updatedCampaign = await _remoteDataSource.updateCampaign(campaign);
        // Update local cache
        await _localDataSource.saveCampaign(updatedCampaign);
        return updatedCampaign;
      } catch (e) {
        // If remote fails, update locally
        await _localDataSource.saveCampaign(campaign);
        return campaign;
      }
    } else {
      // Offline: update locally
      await _localDataSource.saveCampaign(campaign);
      return campaign;
    }
  }

  @override
  Future<void> deleteCampaign(String id) async {
    final isConnected = await _connectivityService.isConnected;

    if (isConnected) {
      try {
        await _remoteDataSource.deleteCampaign(id);
        // Remove from local
        await _localDataSource.deleteCampaign(id);
      } catch (e) {
        // If remote fails, mark for deletion locally
        // For simplicity, just remove locally
        await _localDataSource.deleteCampaign(id);
      }
    } else {
      // Offline: delete locally
      await _localDataSource.deleteCampaign(id);
    }
  }
}
