import 'package:dio/dio.dart';
import 'package:latlong2/latlong.dart';
import 'package:logger/logger.dart';

import '../constants/env.dart';
import 'geocoding_service.dart';

class GeocodingServiceImpl implements GeocodingService {
  final Dio _dio;
  final Logger _logger;

  GeocodingServiceImpl({
    required Dio dio,
    required Logger logger,
  })  : _dio = dio,
        _logger = logger;

  @override
  Future<String?> reverseGeocode(LatLng coordinates) async {
    try {
      // Mapbox Geocoding API (reverse geocoding)
      // https://docs.mapbox.com/api/search/geocoding/
      final url =
          'https://api.mapbox.com/geocoding/v5/mapbox.places/${coordinates.longitude},${coordinates.latitude}.json';

      // Create a separate Dio instance without baseUrl for external API calls
      final externalDio = Dio();

      final response = await externalDio.get(
        url,
        queryParameters: {
          'access_token': Env.mapboxAccessToken,
          'types': 'address', // Focus on street addresses
          'limit': 1,
        },
      );

      if (response.statusCode == 200 && response.data['features'].isNotEmpty) {
        final feature = response.data['features'][0];

        // Try to get the most specific address
        final placeName = feature['place_name'] as String?;
        final text = feature['text'] as String?;

        // Return the street name or place name
        if (text != null && text.isNotEmpty) {
          return text;
        } else if (placeName != null && placeName.isNotEmpty) {
          // Extract just the street name from full address
          final parts = placeName.split(',');
          return parts.first.trim();
        }
      }

      // Fallback to coordinates if geocoding fails
      return null;
    } catch (e) {
      _logger.w('Error reverse geocoding coordinates: $e');
      return null;
    }
  }
}
