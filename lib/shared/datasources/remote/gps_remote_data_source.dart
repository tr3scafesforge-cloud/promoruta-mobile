import 'package:dio/dio.dart';

import '../../../core/models/gps_point.dart';
import '../../../core/models/route.dart';
import '../../repositories/gps_repository.dart';

class GpsRemoteDataSourceImpl implements GpsRemoteDataSource {
  final Dio dio;

  GpsRemoteDataSourceImpl({
    required this.dio,
  });

  @override
  Future<void> uploadRoute(Route route) async {
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
      final pointsData = points.map((point) => {
        'id': point.id,
        'routeId': point.routeId,
        'latitude': point.latitude,
        'longitude': point.longitude,
        'timestamp': point.timestamp.toIso8601String(),
        'speed': point.speed,
        'accuracy': point.accuracy,
      }).toList();

      final response = await dio.post(
        'routes/$routeId/points',
        data: {'points': pointsData},
      );

      if (response.statusCode != 201 && response.statusCode != 200) {
        throw Exception('Failed to upload GPS points: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    }
  }

  @override
  Future<List<Route>> getRoutes() async {
    try {
      final response = await dio.get('routes');

      if (response.statusCode == 200) {
        final data = response.data as List;
        return data.map((json) => Route(
          id: json['id'],
          promoterId: json['promoterId'],
          campaignId: json['campaignId'],
          startTime: DateTime.parse(json['startTime']),
          endTime: json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
          points: [], // Points fetched separately
          isCompleted: json['isCompleted'] ?? false,
        )).toList();
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
        return data.map((json) => GpsPoint(
          id: json['id'],
          routeId: json['routeId'],
          latitude: json['latitude'],
          longitude: json['longitude'],
          timestamp: DateTime.parse(json['timestamp']),
          speed: json['speed'],
          accuracy: json['accuracy'],
        )).toList();
      } else {
        throw Exception('Failed to fetch route points: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    }
  }
}