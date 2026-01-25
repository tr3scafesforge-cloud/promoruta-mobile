import '../models/live_campaign_models.dart';
import '../repositories/advertiser_live_repository.dart';

/// Use case for fetching live campaigns
class GetLiveCampaignsUseCase {
  final AdvertiserLiveRepository _repository;

  GetLiveCampaignsUseCase(this._repository);

  /// Execute the use case to get all live campaigns
  Future<List<LiveCampaign>> call() async {
    return _repository.getLiveCampaigns();
  }
}

/// Use case for fetching a specific live campaign
class GetLiveCampaignUseCase {
  final AdvertiserLiveRepository _repository;

  GetLiveCampaignUseCase(this._repository);

  /// Execute the use case to get a specific live campaign
  Future<LiveCampaign?> call(String campaignId) async {
    return _repository.getLiveCampaign(campaignId);
  }
}

/// Use case for fetching campaign alerts
class GetCampaignAlertsUseCase {
  final AdvertiserLiveRepository _repository;

  GetCampaignAlertsUseCase(this._repository);

  /// Execute the use case to get alerts
  Future<List<CampaignAlert>> call({int? limit}) async {
    return _repository.getAlerts(limit: limit);
  }
}

/// Use case for marking an alert as read
class MarkAlertAsReadUseCase {
  final AdvertiserLiveRepository _repository;

  MarkAlertAsReadUseCase(this._repository);

  /// Execute the use case to mark an alert as read
  Future<void> call(String alertId) async {
    return _repository.markAlertAsRead(alertId);
  }
}

/// Use case for marking all alerts as read
class MarkAllAlertsAsReadUseCase {
  final AdvertiserLiveRepository _repository;

  MarkAllAlertsAsReadUseCase(this._repository);

  /// Execute the use case to mark all alerts as read
  Future<void> call() async {
    return _repository.markAllAlertsAsRead();
  }
}
