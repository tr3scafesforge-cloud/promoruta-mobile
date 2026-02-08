/// GPS tracking configuration model
/// Allows parametrization of GPS tracking behavior for different scenarios
class GpsTrackingConfig {
  /// Number of GPS points to accumulate before syncing to backend
  final int batchSize;

  /// Interval in seconds between sync attempts
  final int syncIntervalSeconds;

  /// Minimum distance in meters between recorded points
  /// Points closer than this are filtered out to reduce noise
  final int distanceFilterMeters;

  /// Minimum speed in m/s to record a point
  /// Useful for filtering out GPS drift when stationary
  final double minSpeedMetersSec;

  const GpsTrackingConfig({
    this.batchSize = 20,
    this.syncIntervalSeconds = 60,
    this.distanceFilterMeters = 10,
    this.minSpeedMetersSec = 0.1,
  });

  /// Create a copy with modified fields
  GpsTrackingConfig copyWith({
    int? batchSize,
    int? syncIntervalSeconds,
    int? distanceFilterMeters,
    double? minSpeedMetersSec,
  }) {
    return GpsTrackingConfig(
      batchSize: batchSize ?? this.batchSize,
      syncIntervalSeconds: syncIntervalSeconds ?? this.syncIntervalSeconds,
      distanceFilterMeters: distanceFilterMeters ?? this.distanceFilterMeters,
      minSpeedMetersSec: minSpeedMetersSec ?? this.minSpeedMetersSec,
    );
  }

  @override
  String toString() =>
      'GpsTrackingConfig(batchSize: $batchSize, syncInterval: ${syncIntervalSeconds}s, distanceFilter: ${distanceFilterMeters}m, minSpeed: ${minSpeedMetersSec}m/s)';
}
