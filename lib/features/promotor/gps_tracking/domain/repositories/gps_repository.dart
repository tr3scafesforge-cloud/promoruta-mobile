import 'package:promoruta/core/models/gps_point.dart';
import 'package:promoruta/core/models/route.dart' as route_model;

/// Abstract repository for GPS operations
abstract class GpsRepository {
  Future<void> saveRoute(route_model.Route route);
  Future<List<route_model.Route>> getRoutes();
  Future<route_model.Route?> getRoute(String id);
  Future<void> saveGpsPoint(GpsPoint point);
  Future<List<GpsPoint>> getGpsPoints(String routeId);
  Future<void> updateRoute(route_model.Route route);
  Future<void> deleteRoute(String id);
}

/// Abstract local data source for GPS
abstract class GpsLocalDataSource {
  Future<void> saveRoute(route_model.Route route);
  Future<List<route_model.Route>> getRoutes();
  Future<route_model.Route?> getRoute(String id);
  Future<void> saveGpsPoint(GpsPoint point);
  Future<List<GpsPoint>> getGpsPoints(String routeId);
  Future<void> updateRoute(route_model.Route route);
  Future<void> deleteRoute(String id);
}

/// Abstract remote data source for GPS
abstract class GpsRemoteDataSource {
  Future<void> uploadGpsPoints(String routeId, List<GpsPoint> points);
  Future<void> uploadRoute(route_model.Route route);
  Future<List<route_model.Route>> getRoutes();
  Future<List<GpsPoint>> getRoutePoints(String routeId);
}
