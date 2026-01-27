import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

class MapConstants {
  // Map Style URLs
  static const String streetStyle = MapboxStyles.MAPBOX_STREETS;
  static const String satelliteStyle = MapboxStyles.SATELLITE_STREETS;
  static const String outdoorsStyle = MapboxStyles.OUTDOORS;

  // Default map settings
  static const double defaultZoom = 14.0;
  static const double minZoom = 10.0;
  static const double maxZoom = 20.0;

  // Default locations
  // Montevideo, Uruguay - City center
  static const double montevideoLat = -34.9011;
  static const double montevideoLng = -56.1645;

  // Routing settings
  static const String routingProfile = 'mapbox/driving';
  static const String routingProfileWalking = 'mapbox/walking';
  static const String routingProfileCycling = 'mapbox/cycling';

  // OSRM fallback endpoint (free public API)
  static const String osrmApiBase = 'https://router.project-osrm.org';

  // Mapbox Directions API
  static const String mapboxDirectionsApiBase =
      'https://api.mapbox.com/directions/v5';

  // Cache settings for offline maps
  static const int maxCacheSizeMB = 500;
  static const Duration cacheExpiration = Duration(days: 30);

  // Location tracking
  static const double locationUpdateDistanceFilter = 10.0; // meters
  static const Duration locationUpdateInterval = Duration(seconds: 5);

  // Route colors
  static const int routeColorPrimary = 0xFF0A9995;
  static const int routeColorAlternative = 0xFF6B7280;

  // Marker icons
  static const double markerSize = 40.0;
}
