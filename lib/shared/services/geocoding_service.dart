import 'package:latlong2/latlong.dart';

abstract class GeocodingService {
  /// Reverse geocode coordinates to get address/street name
  Future<String?> reverseGeocode(LatLng coordinates);
}
