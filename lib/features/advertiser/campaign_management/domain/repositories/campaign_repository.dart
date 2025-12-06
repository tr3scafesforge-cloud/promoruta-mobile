import 'package:promoruta/core/models/campaign.dart';

/// Abstract repository for campaign operations
abstract class CampaignRepository {
  Future<List<Campaign>> getCampaigns();
  Future<Campaign> getCampaign(String id);
  Future<Campaign> createCampaign(Campaign campaign);
  Future<Campaign> updateCampaign(Campaign campaign);
  Future<void> deleteCampaign(String id);
}

/// Abstract local data source for campaigns
abstract class CampaignLocalDataSource {
  Future<void> saveCampaign(Campaign campaign);
  Future<void> saveCampaigns(List<Campaign> campaigns);
  Future<List<Campaign>> getCampaigns();
  Future<Campaign?> getCampaign(String id);
  Future<void> deleteCampaign(String id);
  Future<void> clearCampaigns();
}

/// Abstract remote data source for campaigns
abstract class CampaignRemoteDataSource {
  Future<List<Campaign>> getCampaigns();
  Future<Campaign> getCampaign(String id);
  Future<Campaign> createCampaign(Campaign campaign);
  Future<Campaign> updateCampaign(Campaign campaign);
  Future<void> deleteCampaign(String id);
}
