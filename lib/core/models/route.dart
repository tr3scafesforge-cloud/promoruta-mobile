import 'gps_point.dart';

class Route {
  final String id;
  final String promoterId;
  final String campaignId;
  final DateTime startTime;
  final DateTime? endTime;
  final List<GpsPoint> points;
  final bool isCompleted;

  const Route({
    required this.id,
    required this.promoterId,
    required this.campaignId,
    required this.startTime,
    this.endTime,
    required this.points,
    required this.isCompleted,
  });

  // Add copyWith, fromJson, toJson as needed
}
