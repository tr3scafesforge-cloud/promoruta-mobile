import 'package:promoruta/core/utils/logger.dart';
import 'package:promoruta/features/advertiser/campaign_management/domain/repositories/campaign_repository.dart';
import 'package:promoruta/shared/services/sync_domain_delegate.dart';

class CampaignSyncDelegate implements SyncDomainDelegate {
  final CampaignLocalDataSource _campaignLocalDataSource;
  final CampaignRemoteDataSource _campaignRemoteDataSource;

  CampaignSyncDelegate(
    this._campaignLocalDataSource,
    this._campaignRemoteDataSource,
  );

  @override
  Future<void> sync() async {
    try {
      final remoteCampaigns = await _campaignRemoteDataSource.getCampaigns();
      await _campaignLocalDataSource.saveCampaigns(remoteCampaigns);
    } catch (e) {
      AppLogger.sync.e('Failed to sync campaigns: $e');
    }
  }

  @override
  Future<bool> hasPendingChanges() async => false;
}
