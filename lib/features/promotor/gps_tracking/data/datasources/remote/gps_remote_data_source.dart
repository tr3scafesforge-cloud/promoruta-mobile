import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';

import 'package:promoruta/core/models/gps_point.dart';
import 'package:promoruta/core/models/route.dart' as route_model;
import 'package:promoruta/core/utils/logger.dart';
import '../../../domain/repositories/gps_repository.dart';

/// Response from GPS track upload
class GpsTrackUploadResponse {
  final int created;
  final int existing;
  final int total;
  final List<String> trackIds;

  GpsTrackUploadResponse({
    required this.created,
    required this.existing,
    required this.total,
    required this.trackIds,
  });

  factory GpsTrackUploadResponse.fromJson(Map<String, dynamic> json) {
    final tracks = json['tracks'] as List? ?? [];
    return GpsTrackUploadResponse(
      created: json['created'] ?? 0,
      existing: json['existing'] ?? 0,
      total: json['total'] ?? 0,
      trackIds: tracks.map((t) => t['id'] as String).toList(),
    );
  }
}

class GpsRemoteDataSourceImpl implements GpsRemoteDataSource {
  final Dio dio;
  final Uuid _uuid = const Uuid();

  GpsRemoteDataSourceImpl({
    required this.dio,
  });

  @override
  Future<void> uploadRoute(route_model.Route route) async {
    try {
      final response = await dio.post(
        'routes',
        data: {
          'id': route.id,
          'promoterId': route.promoterId,
          'campaignId': route.campaignId,
          'startTime': route.startTime.toIso8601String(),
          'endTime': route.endTime?.toIso8601String(),
          'isCompleted': route.isCompleted,
        },
      );

      if (response.statusCode != 201 && response.statusCode != 200) {
        throw Exception('Failed to upload route: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    }
  }

  @override
  Future<void> uploadGpsPoints(String routeId, List<GpsPoint> points) async {
    try {
      final pointsData = points
          .map((point) => {
                'id': point.id,
                'routeId': point.routeId,
                'latitude': point.latitude,
                'longitude': point.longitude,
                'timestamp': point.timestamp.toIso8601String(),
                'speed': point.speed,
                'accuracy': point.accuracy,
              })
          .toList();

      final response = await dio.post(
        'routes/$routeId/points',
        data: {'points': pointsData},
      );

      if (response.statusCode != 201 && response.statusCode != 200) {
        throw Exception(
            'Failed to upload GPS points: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    }
  }

  @override
  Future<List<route_model.Route>> getRoutes() async {
    try {
      final response = await dio.get('routes');

      if (response.statusCode == 200) {
        final data = response.data as List;
        return data
            .map((json) => route_model.Route(
                  id: json['id'],
                  promoterId: json['promoterId'],
                  campaignId: json['campaignId'],
                  startTime: DateTime.parse(json['startTime']),
                  endTime: json['endTime'] != null
                      ? DateTime.parse(json['endTime'])
                      : null,
                  points: [], // Points fetched separately
                  isCompleted: json['isCompleted'] ?? false,
                ))
            .toList();
      } else {
        throw Exception('Failed to fetch routes: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    }
  }

  @override
  Future<List<GpsPoint>> getRoutePoints(String routeId) async {
    try {
      final response = await dio.get('routes/$routeId/points');

      if (response.statusCode == 200) {
        final data = response.data as List;
        return data
            .map((json) => GpsPoint(
                  id: json['id'],
                  routeId: json['routeId'],
                  latitude: json['latitude'],
                  longitude: json['longitude'],
                  timestamp: DateTime.parse(json['timestamp']),
                  speed: json['speed'],
                  accuracy: json['accuracy'],
                ))
            .toList();
      } else {
        throw Exception(
            'Failed to fetch route points: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    }
  }

  /// Upload GPS tracks for a campaign execution
  ///
  /// Uses the /campaigns/{campaignId}/gps-tracks endpoint with batch support
  /// and idempotency keys to prevent duplicates.
  Future<GpsTrackUploadResponse> uploadCampaignGpsTracks(
    String campaignId,
    List<GpsPoint> points,
  ) async {
    if (points.isEmpty) {
      return GpsTrackUploadResponse(
        created: 0,
        existing: 0,
        total: 0,
        trackIds: [],
      );
    }

    try {
      // Group points into a single track with all coordinates
      final coordinates = points
          .map((point) => {
                'lat': point.latitude,
                'lng': point.longitude,
                'timestamp': point.timestamp.toIso8601String(),
              })
          .toList();

      // Use first point's ID as idempotency key for this batch
      final idempotencyKey = '${campaignId}_${points.first.id}';

      final trackData = {
        'tracks': [
          {
            'coordinates': coordinates,
            'recorded_at': DateTime.now().toIso8601String(),
            'idempotency_key': idempotencyKey,
          }
        ],
      };

      AppLogger.location.d(
        'Uploading ${points.length} GPS points for campaign $campaignId',
      );

      final response = await dio.post(
        'campaigns/$campaignId/gps-tracks',
        data: trackData,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final result = GpsTrackUploadResponse.fromJson(response.data);
        AppLogger.location.i(
          'GPS tracks uploaded: ${result.created} created, ${result.existing} existing',
        );
        return result;
      } else {
        throw Exception(
            'Failed to upload GPS tracks: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      AppLogger.location.e('Failed to upload GPS tracks: ${e.message}');
      throw Exception('Network error: ${e.message}');
    }
  }

  /// Get all GPS tracks for a campaign
  Future<List<Map<String, dynamic>>> getCampaignGpsTracks(
      String campaignId) async {
    try {
      final response = await dio.get('campaigns/$campaignId/gps-tracks');

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data);
      } else {
        throw Exception(
            'Failed to fetch GPS tracks: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    }
  }
}
