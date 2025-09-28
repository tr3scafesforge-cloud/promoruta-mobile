import '../../core/models/campaign.dart';

/// Abstract repository for campaign operations.
/// Handles fetching, creating, and managing campaigns with offline support.
abstract class CampaignRepository {
  /// Fetches all campaigns for the current user.
  Future<List<Campaign>> getCampaigns();

  /// Fetches a specific campaign by ID.
  Future<Campaign?> getCampaign(String id);

  /// Creates a new campaign.
  Future<Campaign> createCampaign(Campaign campaign);

  /// Updates an existing campaign.
  Future<Campaign> updateCampaign(Campaign campaign);

  /// Deletes a campaign.
  Future<void> deleteCampaign(String id);
}

/// Abstract local data source for campaigns.
/// Handles caching campaigns locally.
abstract class CampaignLocalDataSource {
  /// Saves campaigns locally.
  Future<void> saveCampaigns(List<Campaign> campaigns);

  /// Retrieves cached campaigns.
  Future<List<Campaign>> getCampaigns();

  /// Saves a single campaign.
  Future<void> saveCampaign(Campaign campaign);

  /// Retrieves a specific campaign.
  Future<Campaign?> getCampaign(String id);

  /// Deletes a campaign locally.
  Future<void> deleteCampaign(String id);
}

/// Abstract remote data source for campaigns.
/// Handles API calls for campaign operations.
abstract class CampaignRemoteDataSource {
  /// Fetches campaigns from API.
  Future<List<Campaign>> getCampaigns();

  /// Fetches a specific campaign from API.
  Future<Campaign> getCampaign(String id);

  /// Creates campaign via API.
  Future<Campaign> createCampaign(Campaign campaign);

  /// Updates campaign via API.
  Future<Campaign> updateCampaign(Campaign campaign);

  /// Deletes campaign via API.
  Future<void> deleteCampaign(String id);
}