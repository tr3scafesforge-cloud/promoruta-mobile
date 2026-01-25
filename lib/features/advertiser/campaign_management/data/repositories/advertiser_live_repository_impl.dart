import 'package:promoruta/features/advertiser/campaign_management/data/datasources/remote/advertiser_live_remote_data_source.dart';
import 'package:promoruta/features/advertiser/campaign_management/domain/models/live_campaign_models.dart';
import 'package:promoruta/features/advertiser/campaign_management/domain/repositories/advertiser_live_repository.dart';

/// Implementation of [AdvertiserLiveRepository]
class AdvertiserLiveRepositoryImpl implements AdvertiserLiveRepository {
  final AdvertiserLiveRemoteDataSource _remoteDataSource;

  AdvertiserLiveRepositoryImpl({
    required AdvertiserLiveRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  @override
  Future<List<LiveCampaign>> getLiveCampaigns() async {
    return _remoteDataSource.getLiveCampaigns();
  }

  @override
  Future<LiveCampaign?> getLiveCampaign(String campaignId) async {
    return _remoteDataSource.getLiveCampaign(campaignId);
  }

  @override
  Future<List<CampaignAlert>> getAlerts({int? limit}) async {
    return _remoteDataSource.getAlerts(limit: limit);
  }

  @override
  Future<void> markAlertAsRead(String alertId) async {
    return _remoteDataSource.markAlertAsRead(alertId);
  }

  @override
  Future<void> markAllAlertsAsRead() async {
    return _remoteDataSource.markAllAlertsAsRead();
  }
}
