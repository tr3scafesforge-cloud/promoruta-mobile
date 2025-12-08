import 'package:latlong2/latlong.dart';
import '../models/route_model.dart';

abstract class RouteService {
  /// Get route from origin to destination using Mapbox Directions API
  Future<RouteModel?> getRoute({
    required LatLng origin,
    required LatLng destination,
    String profile = 'driving',
    bool alternatives = false,
  });

  /// Get route using OSRM (free alternative)
  Future<RouteModel?> getRouteOsrm({
    required LatLng origin,
    required LatLng destination,
    String profile = 'driving',
  });

  /// Optimize route for multiple waypoints (Traveling Salesman Problem)
  Future<RouteModel?> optimizeRoute({
    required List<LatLng> waypoints,
    LatLng? origin,
    LatLng? destination,
    String profile = 'driving',
  });
}
