import 'dart:async';

import 'package:promoruta/core/core.dart';
import 'package:promoruta/shared/shared.dart' hide Route, GpsPoint;


class GpsRepositoryImpl implements GpsRepository {
  final GpsLocalDataSource _localDataSource;
  final ConnectivityService _connectivityService;
  final SyncService _syncService;

  GpsRepositoryImpl(
    this._localDataSource,
    this._connectivityService,
    this._syncService,
  );

  @override
  Future<Route> startRoute(String campaignId) async {
    // Get current user - assuming we have a way to get current user ID
    // For now, using a placeholder
    const promoterId = 'current_user_id'; // TODO: Get from auth repository

    final route = Route(
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
  Future<void> addGpsPoint(GpsPoint point) async {
    await _localDataSource.saveGpsPoints([point]);
  }

  @override
  Future<Route> endRoute(String routeId) async {
    final route = await _localDataSource.getRoute(routeId);
    if (route == null) {
      throw Exception('Route not found');
    }

    final updatedRoute = Route(
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
  Future<List<Route>> getRoutes() async {
    return await _localDataSource.getRoutes();
  }

  @override
  Future<Route?> getRoute(String id) async {
    return await _localDataSource.getRoute(id);
  }

  @override
  Future<List<GpsPoint>> getRoutePoints(String routeId) async {
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