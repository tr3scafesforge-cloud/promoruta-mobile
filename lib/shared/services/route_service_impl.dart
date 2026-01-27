import 'package:dio/dio.dart';
import 'package:latlong2/latlong.dart';
import 'package:logger/logger.dart';

import '../constants/env.dart';
import '../constants/map_constants.dart';
import '../models/route_model.dart';
import 'route_service.dart';

class RouteServiceImpl implements RouteService {
  final Dio _dio;
  final Logger _logger;

  RouteServiceImpl({
    required Dio dio,
    required Logger logger,
  })  : _dio = dio,
        _logger = logger;

  @override
  Future<RouteModel?> getRoute({
    required LatLng origin,
    required LatLng destination,
    String profile = 'driving',
    bool alternatives = false,
  }) async {
    try {
      final coordinates =
          '${origin.longitude},${origin.latitude};${destination.longitude},${destination.latitude}';

      final url =
          '${MapConstants.mapboxDirectionsApiBase}/mapbox/$profile/$coordinates';

      final response = await _dio.get(
        url,
        queryParameters: {
          'access_token': Env.mapboxAccessToken,
          'alternatives': alternatives,
          'geometries': 'polyline',
          'steps': true,
          'overview': 'full',
        },
      );

      if (response.statusCode == 200 && response.data['routes'].isNotEmpty) {
        return RouteModel.fromMapboxJson(response.data);
      }

      return null;
    } catch (e) {
      _logger.e('Error getting route from Mapbox: $e');
      // Fallback to OSRM if Mapbox fails
      return getRouteOsrm(
          origin: origin, destination: destination, profile: profile);
    }
  }

  @override
  Future<RouteModel?> getRouteOsrm({
    required LatLng origin,
    required LatLng destination,
    String profile = 'driving',
  }) async {
    try {
      // OSRM uses car/bike/foot instead of driving/cycling/walking
      final osrmProfile = _mapProfileToOsrm(profile);
      final coordinates =
          '${origin.longitude},${origin.latitude};${destination.longitude},${destination.latitude}';

      final url =
          '${MapConstants.osrmApiBase}/route/v1/$osrmProfile/$coordinates';

      final response = await _dio.get(
        url,
        queryParameters: {
          'overview': 'full',
          'geometries': 'polyline',
          'steps': true,
        },
      );

      if (response.statusCode == 200 && response.data['routes'].isNotEmpty) {
        return RouteModel.fromOsrmJson(response.data);
      }

      return null;
    } catch (e) {
      _logger.e('Error getting route from OSRM: $e');
      return null;
    }
  }

  @override
  Future<RouteModel?> optimizeRoute({
    required List<LatLng> waypoints,
    LatLng? origin,
    LatLng? destination,
    String profile = 'driving',
  }) async {
    try {
      // Build coordinates string
      final allPoints = <LatLng>[
        if (origin != null) origin,
        ...waypoints,
        if (destination != null) destination,
      ];

      final coordinates = allPoints
          .map((point) => '${point.longitude},${point.latitude}')
          .join(';');

      final url =
          '${MapConstants.mapboxDirectionsApiBase}/mapbox/$profile/$coordinates';

      // Mapbox Optimization API (requires optimization/ endpoint)
      // For MVP, we'll use the standard directions API
      // For true optimization, upgrade to: https://api.mapbox.com/optimized-trips/v1
      final response = await _dio.get(
        url,
        queryParameters: {
          'access_token': Env.mapboxAccessToken,
          'geometries': 'polyline',
          'steps': true,
          'overview': 'full',
        },
      );

      if (response.statusCode == 200 && response.data['routes'].isNotEmpty) {
        return RouteModel.fromMapboxJson(response.data);
      }

      return null;
    } catch (e) {
      _logger.e('Error optimizing route: $e');
      return null;
    }
  }

  String _mapProfileToOsrm(String profile) {
    switch (profile) {
      case 'driving':
        return 'car';
      case 'walking':
        return 'foot';
      case 'cycling':
        return 'bike';
      default:
        return 'car';
    }
  }
}
