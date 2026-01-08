import 'dart:io';
import 'package:promoruta/core/models/campaign.dart';
import 'package:promoruta/core/models/advertiser_kpi_stats.dart';

/// Abstract repository for campaign operations
abstract class CampaignRepository {
  Future<List<Campaign>> getCampaigns({
    String? status,
    String? zone,
    String? createdBy,
    String? acceptedBy,
    bool? upcoming,
    DateTime? startTimeFrom,
    DateTime? startTimeTo,
    String? sortBy,
    String? sortOrder,
    double? lat,
    double? lng,
    double? radius,
    int? perPage,
  });
  Future<Campaign> getCampaign(String id);
  Future<Campaign> createCampaign(Campaign campaign, {File? audioFile});
  Future<Campaign> updateCampaign(Campaign campaign);
  Future<void> deleteCampaign(String id);
  Future<Campaign> cancelCampaign(String id, String reason);
  Future<AdvertiserKpiStats> getKpiStats();
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
  Future<List<Campaign>> getCampaigns({
    String? status,
    String? zone,
    String? createdBy,
    String? acceptedBy,
    bool? upcoming,
    DateTime? startTimeFrom,
    DateTime? startTimeTo,
    String? sortBy,
    String? sortOrder,
    double? lat,
    double? lng,
    double? radius,
    int? perPage,
  });
  Future<Campaign> getCampaign(String id);
  Future<Campaign> createCampaign(Campaign campaign, {File? audioFile});
  Future<Campaign> updateCampaign(Campaign campaign);
  Future<void> deleteCampaign(String id);
  Future<Campaign> cancelCampaign(String id, String reason);
  Future<AdvertiserKpiStats> getKpiStats();
}
