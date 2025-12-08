import 'package:latlong2/latlong.dart';

abstract class LocationService {
  /// Get current location
  Future<LatLng?> getCurrentLocation();

  /// Check if location services are enabled
  Future<bool> isLocationServiceEnabled();

  /// Request location permissions
  Future<bool> requestLocationPermission();

  /// Check location permission status
  Future<bool> hasLocationPermission();

  /// Stream of location updates
  Stream<LatLng> get locationStream;

  /// Start tracking location
  Future<void> startTracking();

  /// Stop tracking location
  Future<void> stopTracking();

  /// Calculate distance between two points in meters
  double calculateDistance(LatLng start, LatLng end);
}
