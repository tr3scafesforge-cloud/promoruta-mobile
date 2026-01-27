import 'package:equatable/equatable.dart';
import 'package:geolocator/geolocator.dart';

/// Status of campaign execution
enum CampaignExecutionStatus {
  /// No active campaign execution
  idle,

  /// Starting campaign execution (requesting permissions, initializing)
  starting,

  /// Campaign is actively being executed with GPS tracking
  active,

  /// Campaign execution is temporarily paused
  paused,

  /// Campaign is being completed (syncing final data)
  completing,

  /// Campaign execution has been completed
  completed,

  /// Campaign execution failed or was cancelled
  error,
}

/// A GPS point collected during campaign execution
class ExecutionGpsPoint extends Equatable {
  final String id;
  final double latitude;
  final double longitude;
  final DateTime timestamp;
  final double? speed;
  final double? accuracy;
  final bool synced;

  const ExecutionGpsPoint({
    required this.id,
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    this.speed,
    this.accuracy,
    this.synced = false,
  });

  /// Create from Geolocator Position
  factory ExecutionGpsPoint.fromPosition(Position position, String id) {
    return ExecutionGpsPoint(
      id: id,
      latitude: position.latitude,
      longitude: position.longitude,
      timestamp: position.timestamp,
      speed: position.speed,
      accuracy: position.accuracy,
    );
  }

  ExecutionGpsPoint copyWith({
    String? id,
    double? latitude,
    double? longitude,
    DateTime? timestamp,
    double? speed,
    double? accuracy,
    bool? synced,
  }) {
    return ExecutionGpsPoint(
      id: id ?? this.id,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      timestamp: timestamp ?? this.timestamp,
      speed: speed ?? this.speed,
      accuracy: accuracy ?? this.accuracy,
      synced: synced ?? this.synced,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lat': latitude,
      'lng': longitude,
      'timestamp': timestamp.toIso8601String(),
      'speed': speed,
      'accuracy': accuracy,
    };
  }

  @override
  List<Object?> get props =>
      [id, latitude, longitude, timestamp, speed, accuracy, synced];
}

/// State of campaign execution
class CampaignExecutionState extends Equatable {
  /// Current execution status
  final CampaignExecutionStatus status;

  /// ID of the campaign being executed (null if idle)
  final String? campaignId;

  /// Name of the campaign being executed
  final String? campaignName;

  /// GPS points collected during this execution (pending sync)
  final List<ExecutionGpsPoint> pendingPoints;

  /// All GPS points collected (for drawing polyline)
  final List<ExecutionGpsPoint> allPoints;

  /// Time when execution started
  final DateTime? startedAt;

  /// Time when execution was paused (for calculating total active time)
  final DateTime? pausedAt;

  /// Total time spent in paused state (accumulated from multiple pauses)
  final Duration totalPausedDuration;

  /// Total distance traveled in meters
  final double distanceTraveled;

  /// Error message if status is error
  final String? errorMessage;

  /// Current position (most recent)
  final ExecutionGpsPoint? currentPosition;

  const CampaignExecutionState({
    this.status = CampaignExecutionStatus.idle,
    this.campaignId,
    this.campaignName,
    this.pendingPoints = const [],
    this.allPoints = const [],
    this.startedAt,
    this.pausedAt,
    this.totalPausedDuration = Duration.zero,
    this.distanceTraveled = 0.0,
    this.errorMessage,
    this.currentPosition,
  });

  /// Initial idle state
  factory CampaignExecutionState.idle() {
    return const CampaignExecutionState();
  }

  /// Whether tracking is currently active (not paused or idle)
  bool get isTrackingActive => status == CampaignExecutionStatus.active;

  /// Whether there's an active or paused execution
  bool get hasActiveExecution =>
      status == CampaignExecutionStatus.active ||
      status == CampaignExecutionStatus.paused ||
      status == CampaignExecutionStatus.starting ||
      status == CampaignExecutionStatus.completing;

  /// Calculate elapsed time (excluding paused time)
  Duration get elapsedTime {
    if (startedAt == null) return Duration.zero;

    final now = DateTime.now();
    final totalElapsed = now.difference(startedAt!);

    // If currently paused, add time spent in current pause
    if (status == CampaignExecutionStatus.paused && pausedAt != null) {
      final currentPauseDuration = now.difference(pausedAt!);
      return totalElapsed - totalPausedDuration - currentPauseDuration;
    }

    return totalElapsed - totalPausedDuration;
  }

  /// Distance traveled in kilometers
  double get distanceKm => distanceTraveled / 1000;

  /// Format elapsed time as HH:MM:SS
  String get formattedElapsedTime {
    final duration = elapsedTime;
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Format distance as string
  String get formattedDistance {
    if (distanceTraveled < 1000) {
      return '${distanceTraveled.toStringAsFixed(0)} m';
    }
    return '${distanceKm.toStringAsFixed(2)} km';
  }

  CampaignExecutionState copyWith({
    CampaignExecutionStatus? status,
    String? campaignId,
    String? campaignName,
    List<ExecutionGpsPoint>? pendingPoints,
    List<ExecutionGpsPoint>? allPoints,
    DateTime? startedAt,
    DateTime? pausedAt,
    Duration? totalPausedDuration,
    double? distanceTraveled,
    String? errorMessage,
    ExecutionGpsPoint? currentPosition,
    bool clearCampaignId = false,
    bool clearPausedAt = false,
    bool clearError = false,
  }) {
    return CampaignExecutionState(
      status: status ?? this.status,
      campaignId: clearCampaignId ? null : (campaignId ?? this.campaignId),
      campaignName:
          clearCampaignId ? null : (campaignName ?? this.campaignName),
      pendingPoints: pendingPoints ?? this.pendingPoints,
      allPoints: allPoints ?? this.allPoints,
      startedAt: startedAt ?? this.startedAt,
      pausedAt: clearPausedAt ? null : (pausedAt ?? this.pausedAt),
      totalPausedDuration: totalPausedDuration ?? this.totalPausedDuration,
      distanceTraveled: distanceTraveled ?? this.distanceTraveled,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      currentPosition: currentPosition ?? this.currentPosition,
    );
  }

  @override
  List<Object?> get props => [
        status,
        campaignId,
        campaignName,
        pendingPoints,
        allPoints,
        startedAt,
        pausedAt,
        totalPausedDuration,
        distanceTraveled,
        errorMessage,
        currentPosition,
      ];
}
