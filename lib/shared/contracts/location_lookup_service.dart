import 'package:latlong2/latlong.dart';

/// Shared contract for features that need foreground location lookup/tracking.
abstract class LocationLookupService {
  Future<LatLng?> getCurrentLocation();

  Future<bool> isLocationServiceEnabled();

  Future<bool> requestLocationPermission();

  Future<bool> hasLocationPermission();

  Stream<LatLng> get locationStream;

  Future<void> startTracking();

  Future<void> stopTracking();

  double calculateDistance(LatLng start, LatLng end);
}
