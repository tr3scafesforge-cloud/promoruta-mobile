import 'package:promoruta/core/utils/logger.dart';
import 'package:promoruta/shared/shared.dart';

class SyncServiceImpl implements SyncService {
  final ConnectivityService _connectivityService;
  final AuthLocalDataSource _authLocalDataSource;
  final AuthRemoteDataSource _authRemoteDataSource;
  final CampaignLocalDataSource _campaignLocalDataSource;
  final CampaignRemoteDataSource _campaignRemoteDataSource;
  final GpsLocalDataSource _gpsLocalDataSource;
  final GpsRemoteDataSource _gpsRemoteDataSource;

  SyncServiceImpl(
    this._connectivityService,
    this._authLocalDataSource,
    this._authRemoteDataSource,
    this._campaignLocalDataSource,
    this._campaignRemoteDataSource,
    this._gpsLocalDataSource,
    this._gpsRemoteDataSource,
  );

  @override
  Future<void> sync() async {
    if (!await _connectivityService.isConnected) {
      return; // No connectivity, skip sync
    }

    try {
      // Sync campaigns
      await _syncCampaigns();

      // Sync GPS routes
      await _syncGpsRoutes();

      // Auth sync if needed (e.g., refresh token)
      await _syncAuth();
    } catch (e) {
      // Log error, but don't throw to avoid breaking the app
      AppLogger.sync.e('Sync failed: $e');
    }
  }

  @override
  Future<bool> hasPendingChanges() async {
    // Check if there are completed routes to sync
    final pendingRoutes = await _gpsLocalDataSource.getPendingSyncRoutes();
    return pendingRoutes.isNotEmpty;
  }

  @override
  Future<void> syncDomain(String domain) async {
    if (!await _connectivityService.isConnected) {
      return;
    }

    switch (domain) {
      case 'auth':
        await _syncAuth();
        break;
      case 'campaigns':
        await _syncCampaigns();
        break;
      case 'gps':
        await _syncGpsRoutes();
        break;
      default:
        throw UnsupportedError('Unknown domain: $domain');
    }
  }

  Future<void> _syncAuth() async {
    // For auth, we might need to refresh token or sync user data
    // This is a placeholder - implement based on your auth requirements
    final user = await _authLocalDataSource.getUser();
    if (user != null && user.accessToken != null) {
      // Optionally validate token with server or refresh if near expiry
      final now = DateTime.now();
      if (user.tokenExpiry != null && user.tokenExpiry!.isBefore(now.add(Duration(minutes: 5)))) {
        // Token expires soon, could refresh here
        AppLogger.sync.i('Token expires soon, consider refreshing');
      }
    }
  }

  Future<void> _syncCampaigns() async {
    try {
      // Fetch latest campaigns from server
      final remoteCampaigns = await _campaignRemoteDataSource.getCampaigns();

      // Save to local storage
      await _campaignLocalDataSource.saveCampaigns(remoteCampaigns);
    } catch (e) {
      AppLogger.sync.e('Failed to sync campaigns: $e');
    }
  }

  Future<void> _syncGpsRoutes() async {
    try {
      // Get completed routes that need syncing
      final pendingRoutes = await _gpsLocalDataSource.getPendingSyncRoutes();

      for (final route in pendingRoutes) {
        try {
          // Upload route
          await _gpsRemoteDataSource.uploadRoute(route);

          // Upload GPS points
          await _gpsRemoteDataSource.uploadGpsPoints(route.id, route.points);

          // Mark as synced (you might want to add a synced flag to the model)
        } catch (e) {
          AppLogger.sync.e('Failed to sync route ${route.id}: $e');
        }
      }
    } catch (e) {
      AppLogger.sync.e('Failed to sync GPS routes: $e');
    }
  }
}