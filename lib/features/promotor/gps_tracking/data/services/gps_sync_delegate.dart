import 'package:promoruta/core/utils/logger.dart';
import 'package:promoruta/features/promotor/gps_tracking/domain/repositories/gps_repository.dart';
import 'package:promoruta/shared/services/sync_domain_delegate.dart';

class GpsSyncDelegate implements SyncDomainDelegate {
  final GpsLocalDataSource _gpsLocalDataSource;
  final GpsRemoteDataSource _gpsRemoteDataSource;

  GpsSyncDelegate(this._gpsLocalDataSource, this._gpsRemoteDataSource);

  @override
  Future<void> sync() async {
    try {
      final pendingRoutes = await _gpsLocalDataSource.getPendingSyncRoutes();

      for (final route in pendingRoutes) {
        try {
          await _gpsRemoteDataSource.uploadRoute(route);
          await _gpsRemoteDataSource.uploadGpsPoints(route.id, route.points);
        } catch (e) {
          AppLogger.sync.e('Failed to sync route ${route.id}: $e');
        }
      }
    } catch (e) {
      AppLogger.sync.e('Failed to sync GPS routes: $e');
    }
  }

  @override
  Future<bool> hasPendingChanges() async {
    final pendingRoutes = await _gpsLocalDataSource.getPendingSyncRoutes();
    return pendingRoutes.isNotEmpty;
  }
}
