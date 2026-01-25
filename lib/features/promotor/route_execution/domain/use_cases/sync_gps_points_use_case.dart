import 'package:promoruta/core/utils/logger.dart';
import 'package:promoruta/features/promotor/gps_tracking/data/datasources/local/gps_local_data_source.dart';
import 'package:promoruta/features/promotor/gps_tracking/data/datasources/remote/gps_remote_data_source.dart';

/// Result of a GPS sync operation
class SyncResult {
  final int synced;
  final int failed;
  final String? errorMessage;

  const SyncResult({
    required this.synced,
    required this.failed,
    this.errorMessage,
  });

  bool get hasError => errorMessage != null;
  bool get isSuccess => synced > 0 && failed == 0;
}

/// Use case for syncing GPS points to the backend
class SyncGpsPointsUseCase {
  final GpsLocalDataSourceImpl _localDataSource;
  final GpsRemoteDataSourceImpl _remoteDataSource;

  SyncGpsPointsUseCase({
    required GpsLocalDataSourceImpl localDataSource,
    required GpsRemoteDataSourceImpl remoteDataSource,
  })  : _localDataSource = localDataSource,
        _remoteDataSource = remoteDataSource;

  /// Sync all unsynced GPS points for a campaign
  ///
  /// Returns a [SyncResult] with the number of points synced and any errors.
  Future<SyncResult> call(String campaignId) async {
    try {
      // Get unsynced points
      final unsyncedPoints = await _localDataSource.getUnsyncedCampaignPoints(campaignId);

      if (unsyncedPoints.isEmpty) {
        AppLogger.location.d('No unsynced points for campaign $campaignId');
        return const SyncResult(synced: 0, failed: 0);
      }

      AppLogger.location.i(
        'Syncing ${unsyncedPoints.length} GPS points for campaign $campaignId',
      );

      // Upload to backend
      final response = await _remoteDataSource.uploadCampaignGpsTracks(
        campaignId,
        unsyncedPoints,
      );

      // Mark as synced
      final pointIds = unsyncedPoints.map((p) => p.id).toList();
      await _localDataSource.markPointsAsSynced(pointIds);

      AppLogger.location.i(
        'Successfully synced ${response.total} GPS points (${response.created} new, ${response.existing} existing)',
      );

      return SyncResult(
        synced: response.total,
        failed: 0,
      );
    } catch (e) {
      AppLogger.location.e('Failed to sync GPS points: $e');
      return SyncResult(
        synced: 0,
        failed: 1,
        errorMessage: e.toString(),
      );
    }
  }

  /// Get the count of unsynced points for a campaign
  Future<int> getUnsyncedCount(String campaignId) async {
    return await _localDataSource.getUnsyncedPointCount(campaignId);
  }
}
