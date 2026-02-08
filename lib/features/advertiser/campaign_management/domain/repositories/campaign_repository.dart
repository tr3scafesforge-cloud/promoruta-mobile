import 'dart:io';
import 'package:promoruta/core/models/campaign.dart';
import 'package:promoruta/core/models/advertiser_kpi_stats.dart';
import 'package:promoruta/core/models/result.dart';
import 'package:promoruta/core/models/app_error.dart';

/// Abstract repository for campaign operations.
///
/// Methods return [Result<T, AppError>] for type-safe error handling.
/// Use `.fold()` to handle success and failure cases.
abstract class CampaignRepository {
  Future<Result<List<Campaign>, AppError>> getCampaigns({
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
    int? page,
    int? perPage,
  });
  Future<Result<Campaign, AppError>> getCampaign(String id);
  Future<Result<Campaign, AppError>> createCampaign(Campaign campaign,
      {File? audioFile});
  Future<Result<Campaign, AppError>> updateCampaign(Campaign campaign);
  Future<Result<void, AppError>> deleteCampaign(String id);
  Future<Result<Campaign, AppError>> cancelCampaign(String id, String reason);
  Future<Result<AdvertiserKpiStats, AppError>> getKpiStats();
}

/// Abstract local data source for campaigns
abstract class CampaignLocalDataSource {
  Future<void> saveCampaign(Campaign campaign);
  Future<void> saveCampaigns(List<Campaign> campaigns);
  Future<List<Campaign>> getCampaigns();
  Future<Campaign?> getCampaign(String id);
  Future<void> deleteCampaign(String id);
  Future<void> clearCampaigns();
  Future<List<Campaign>> getCampaignsWithPagination({
    int page = 1,
    int pageSize = 10,
  });
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
    int? page,
    int? perPage,
  });
  Future<Campaign> getCampaign(String id);
  Future<Campaign> createCampaign(Campaign campaign, {File? audioFile});
  Future<Campaign> updateCampaign(Campaign campaign);
  Future<void> deleteCampaign(String id);
  Future<Campaign> cancelCampaign(String id, String reason);
  Future<AdvertiserKpiStats> getKpiStats();
}
