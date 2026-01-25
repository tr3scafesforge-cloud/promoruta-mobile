import '../models/live_campaign_models.dart';

/// Repository interface for advertiser live campaign tracking
abstract class AdvertiserLiveRepository {
  /// Get all live campaigns for the current advertiser
  ///
  /// Returns a list of campaigns that are currently being executed
  /// or are scheduled to be executed today.
  Future<List<LiveCampaign>> getLiveCampaigns();

  /// Get live data for a specific campaign
  Future<LiveCampaign?> getLiveCampaign(String campaignId);

  /// Get alerts for the advertiser's campaigns
  Future<List<CampaignAlert>> getAlerts({int? limit});

  /// Mark an alert as read
  Future<void> markAlertAsRead(String alertId);

  /// Mark all alerts as read
  Future<void> markAllAlertsAsRead();
}
