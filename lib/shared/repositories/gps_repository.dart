import 'package:promoruta/core/core.dart';

/// Abstract repository for GPS tracking operations.
/// Handles route creation, point recording, and route management with offline support.
abstract class GpsRepository {
  /// Starts a new route for a campaign.
  Future<Route> startRoute(String campaignId);

  /// Adds a GPS point to the current route.
  Future<void> addGpsPoint(GpsPoint point);

  /// Ends the current route.
  Future<Route> endRoute(String routeId);

  /// Gets all routes for the current user.
  Future<List<Route>> getRoutes();

  /// Gets a specific route by ID.
  Future<Route?> getRoute(String id);

  /// Gets points for a specific route.
  Future<List<GpsPoint>> getRoutePoints(String routeId);

  /// Syncs pending routes and points when online.
  Future<void> syncRoutes();
}

/// Abstract local data source for GPS data.
/// Handles storing routes and points locally.
abstract class GpsLocalDataSource {
  /// Saves a route locally.
  Future<void> saveRoute(Route route);

  /// Retrieves all routes.
  Future<List<Route>> getRoutes();

  /// Retrieves a specific route.
  Future<Route?> getRoute(String id);

  /// Saves GPS points for a route.
  Future<void> saveGpsPoints(List<GpsPoint> points);

  /// Retrieves points for a route.
  Future<List<GpsPoint>> getGpsPoints(String routeId);

  /// Updates a route (e.g., mark as completed).
  Future<void> updateRoute(Route route);

  /// Gets routes that need syncing.
  Future<List<Route>> getPendingSyncRoutes();
}

/// Abstract remote data source for GPS data.
/// Handles uploading routes and points to the server.
abstract class GpsRemoteDataSource {
  /// Uploads a route to the server.
  Future<void> uploadRoute(Route route);

  /// Uploads GPS points for a route.
  Future<void> uploadGpsPoints(String routeId, List<GpsPoint> points);

  /// Fetches routes from server (for initial sync).
  Future<List<Route>> getRoutes();

  /// Fetches points for a route from server.
  Future<List<GpsPoint>> getRoutePoints(String routeId);
}