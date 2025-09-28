import 'dart:async';

import '../../core/models/gps_point.dart' as model;
import '../../core/models/route.dart' as model_route;
import '../datasources/local/gps_local_data_source.dart';
import '../datasources/remote/gps_remote_data_source.dart';
import '../services/connectivity_service.dart';
import '../services/sync_service.dart';
import 'gps_repository.dart';

class GpsRepositoryImpl implements GpsRepository {
  final GpsLocalDataSource _localDataSource;
  final GpsRemoteDataSource _remoteDataSource;
  final ConnectivityService _connectivityService;
  final SyncService _syncService;

  GpsRepositoryImpl(
    this._localDataSource,
    this._remoteDataSource,
    this._connectivityService,
    this._syncService,
  );

  @override
  Future<model_route.Route> startRoute(String campaignId) async {
    // Get current user - assuming we have a way to get current user ID
    // For now, using a placeholder
    const promoterId = 'current_user_id'; // TODO: Get from auth repository

    final route = model_route.Route(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      promoterId: promoterId,
      campaignId: campaignId,
      startTime: DateTime.now(),
      points: [],
      isCompleted: false,
    );

    await _localDataSource.saveRoute(route);
    return route;
  }

  @override
  Future<void> addGpsPoint(model.GpsPoint point) async {
    await _localDataSource.saveGpsPoints([point]);
  }

  @override
  Future<model_route.Route> endRoute(String routeId) async {
    final route = await _localDataSource.getRoute(routeId);
    if (route == null) {
      throw Exception('Route not found');
    }

    final updatedRoute = model_route.Route(
      id: route.id,
      promoterId: route.promoterId,
      campaignId: route.campaignId,
      startTime: route.startTime,
      endTime: DateTime.now(),
      points: route.points,
      isCompleted: true,
    );

    await _localDataSource.updateRoute(updatedRoute);

    // Try to sync if online
    final isConnected = await _connectivityService.isConnected;
    if (isConnected) {
      try {
        await _syncService.syncDomain('gps');
      } catch (e) {
        // Sync failed, but route is saved locally
      }
    }

    return updatedRoute;
  }

  @override
  Future<List<model_route.Route>> getRoutes() async {
    return await _localDataSource.getRoutes();
  }

  @override
  Future<model_route.Route?> getRoute(String id) async {
    return await _localDataSource.getRoute(id);
  }

  @override
  Future<List<model.GpsPoint>> getRoutePoints(String routeId) async {
    return await _localDataSource.getGpsPoints(routeId);
  }

  @override
  Future<void> syncRoutes() async {
    final isConnected = await _connectivityService.isConnected;
    if (isConnected) {
      await _syncService.syncDomain('gps');
    }
  }
}