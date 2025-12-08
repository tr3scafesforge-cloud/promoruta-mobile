import 'package:latlong2/latlong.dart';

class RouteModel {
  final List<LatLng> coordinates;
  final double distanceMeters;
  final double durationSeconds;
  final String geometry;
  final List<RouteStep> steps;

  RouteModel({
    required this.coordinates,
    required this.distanceMeters,
    required this.durationSeconds,
    required this.geometry,
    this.steps = const [],
  });

  double get distanceKm => distanceMeters / 1000;
  Duration get duration => Duration(seconds: durationSeconds.toInt());

  factory RouteModel.fromMapboxJson(Map<String, dynamic> json) {
    final route = json['routes'][0];
    final coordinates = _decodePolyline(route['geometry']);

    final steps = (route['legs'][0]['steps'] as List?)
            ?.map((step) => RouteStep.fromJson(step))
            .toList() ??
        [];

    return RouteModel(
      coordinates: coordinates,
      distanceMeters: route['distance'].toDouble(),
      durationSeconds: route['duration'].toDouble(),
      geometry: route['geometry'],
      steps: steps,
    );
  }

  factory RouteModel.fromOsrmJson(Map<String, dynamic> json) {
    final route = json['routes'][0];
    final coordinates = _decodePolyline(route['geometry']);

    final steps = (route['legs'][0]['steps'] as List?)
            ?.map((step) => RouteStep.fromOsrmJson(step))
            .toList() ??
        [];

    return RouteModel(
      coordinates: coordinates,
      distanceMeters: route['distance'].toDouble(),
      durationSeconds: route['duration'].toDouble(),
      geometry: route['geometry'],
      steps: steps,
    );
  }

  static List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> points = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      points.add(LatLng(lat / 1E5, lng / 1E5));
    }

    return points;
  }
}

class RouteStep {
  final String instruction;
  final double distanceMeters;
  final double durationSeconds;
  final LatLng location;

  RouteStep({
    required this.instruction,
    required this.distanceMeters,
    required this.durationSeconds,
    required this.location,
  });

  factory RouteStep.fromJson(Map<String, dynamic> json) {
    final maneuver = json['maneuver'];
    return RouteStep(
      instruction: json['maneuver']['instruction'] ?? '',
      distanceMeters: json['distance'].toDouble(),
      durationSeconds: json['duration'].toDouble(),
      location: LatLng(
        maneuver['location'][1],
        maneuver['location'][0],
      ),
    );
  }

  factory RouteStep.fromOsrmJson(Map<String, dynamic> json) {
    final maneuver = json['maneuver'];
    return RouteStep(
      instruction: json['name'] ?? maneuver['modifier'] ?? '',
      distanceMeters: json['distance'].toDouble(),
      durationSeconds: json['duration'].toDouble(),
      location: LatLng(
        maneuver['location'][1],
        maneuver['location'][0],
      ),
    );
  }
}
