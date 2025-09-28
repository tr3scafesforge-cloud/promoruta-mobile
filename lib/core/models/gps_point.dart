/// Basic GPS point model for route tracking.
class GpsPoint {
  final String id;
  final String routeId;
  final double latitude;
  final double longitude;
  final DateTime timestamp;
  final double? speed; // optional speed in m/s
  final double? accuracy; // optional accuracy in meters

  const GpsPoint({
    required this.id,
    required this.routeId,
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    this.speed,
    this.accuracy,
  });

  // Add copyWith, fromJson, toJson as needed
}

