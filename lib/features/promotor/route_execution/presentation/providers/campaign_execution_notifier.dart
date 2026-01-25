import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import 'package:promoruta/core/utils/logger.dart';
import 'package:promoruta/shared/services/location_service.dart';
import 'package:promoruta/features/promotor/route_execution/domain/models/campaign_execution_state.dart';
import 'package:promoruta/features/promotor/route_execution/domain/use_cases/sync_gps_points_use_case.dart';

/// Notifier for managing campaign execution state
class CampaignExecutionNotifier extends StateNotifier<CampaignExecutionState> {
  final LocationService _locationService;
  final SyncGpsPointsUseCase _syncUseCase;
  final Uuid _uuid = const Uuid();

  StreamSubscription<Position>? _positionSubscription;
  Timer? _syncTimer;
  Timer? _elapsedTimeTimer;

  /// Batch size for triggering sync
  static const int _batchSyncThreshold = 20;

  /// Sync interval in seconds
  static const int _syncIntervalSeconds = 60;

  /// Minimum distance to record a new point (meters)
  static const double _minDistanceFilter = 5.0;

  /// Minimum speed to record a point (m/s) - filter out stationary GPS drift
  static const double _minSpeedFilter = 0.5;

  /// Persistence keys
  static const String _keyExecutionState = 'campaign_execution_state';
  static const String _keyAudioPosition = 'campaign_audio_position';

  CampaignExecutionNotifier(this._locationService, this._syncUseCase)
      : super(CampaignExecutionState.idle()) {
    _restoreState();
  }

  /// Restore persisted execution state on startup
  Future<void> _restoreState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final stateJson = prefs.getString(_keyExecutionState);

      if (stateJson != null) {
        final data = jsonDecode(stateJson) as Map<String, dynamic>;
        final campaignId = data['campaignId'] as String?;
        final campaignName = data['campaignName'] as String?;
        final startedAtStr = data['startedAt'] as String?;
        final distanceTraveled = (data['distanceTraveled'] as num?)?.toDouble() ?? 0.0;
        final pausedDurationMs = (data['pausedDurationMs'] as int?) ?? 0;
        final wasPaused = data['wasPaused'] as bool? ?? false;

        if (campaignId != null && startedAtStr != null) {
          final startedAt = DateTime.parse(startedAtStr);

          // Only restore if the campaign was started within the last 24 hours
          final elapsed = DateTime.now().difference(startedAt);
          if (elapsed.inHours < 24) {
            AppLogger.location.i('Restoring campaign execution: $campaignId');

            state = state.copyWith(
              status: wasPaused
                  ? CampaignExecutionStatus.paused
                  : CampaignExecutionStatus.active,
              campaignId: campaignId,
              campaignName: campaignName,
              startedAt: startedAt,
              distanceTraveled: distanceTraveled,
              totalPausedDuration: Duration(milliseconds: pausedDurationMs),
            );

            // If was active (not paused), restart tracking
            if (!wasPaused) {
              await _resumeAfterRestore();
            }
          } else {
            // Clear stale state
            await _clearPersistedState();
          }
        }
      }
    } catch (e) {
      AppLogger.location.e('Error restoring execution state: $e');
      await _clearPersistedState();
    }
  }

  /// Resume tracking after state restoration
  Future<void> _resumeAfterRestore() async {
    final permissionResult = await _locationService.requestPermission();
    if (permissionResult != LocationPermissionResult.granted) {
      // Mark as paused if we can't get permission
      state = state.copyWith(status: CampaignExecutionStatus.paused);
      await _persistState();
      return;
    }

    final trackingStarted = await _locationService.startTracking();
    if (!trackingStarted) {
      state = state.copyWith(status: CampaignExecutionStatus.paused);
      await _persistState();
      return;
    }

    _positionSubscription = _locationService.positionStream.listen(
      _onPositionUpdate,
      onError: (error) {
        AppLogger.location.e('Position stream error: $error');
      },
    );

    _startSyncTimer();
    _startElapsedTimeTimer();

    // Get current position
    final currentPosition = await _locationService.getCurrentPosition();
    if (currentPosition != null) {
      final point = ExecutionGpsPoint.fromPosition(currentPosition, _uuid.v4());
      state = state.copyWith(currentPosition: point);
    }
  }

  /// Persist current execution state
  Future<void> _persistState() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      if (state.campaignId != null && state.startedAt != null) {
        final data = {
          'campaignId': state.campaignId,
          'campaignName': state.campaignName,
          'startedAt': state.startedAt!.toIso8601String(),
          'distanceTraveled': state.distanceTraveled,
          'pausedDurationMs': state.totalPausedDuration.inMilliseconds,
          'wasPaused': state.status == CampaignExecutionStatus.paused,
        };
        await prefs.setString(_keyExecutionState, jsonEncode(data));
      }
    } catch (e) {
      AppLogger.location.e('Error persisting execution state: $e');
    }
  }

  /// Clear persisted state
  Future<void> _clearPersistedState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyExecutionState);
      await prefs.remove(_keyAudioPosition);
    } catch (e) {
      AppLogger.location.e('Error clearing persisted state: $e');
    }
  }

  /// Get persisted audio position for restoration
  static Future<Duration?> getPersistedAudioPosition() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final positionMs = prefs.getInt(_keyAudioPosition);
      if (positionMs != null) {
        return Duration(milliseconds: positionMs);
      }
    } catch (e) {
      AppLogger.location.e('Error getting audio position: $e');
    }
    return null;
  }

  /// Persist audio playback position
  static Future<void> persistAudioPosition(Duration position) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_keyAudioPosition, position.inMilliseconds);
    } catch (e) {
      AppLogger.location.e('Error persisting audio position: $e');
    }
  }

  /// Start campaign execution
  ///
  /// Returns true if execution started successfully
  Future<bool> startExecution({
    required String campaignId,
    required String campaignName,
  }) async {
    if (state.hasActiveExecution) {
      AppLogger.location.w('Cannot start: execution already in progress');
      return false;
    }

    state = state.copyWith(
      status: CampaignExecutionStatus.starting,
      campaignId: campaignId,
      campaignName: campaignName,
      clearError: true,
    );

    // Request location permission
    final permissionResult = await _locationService.requestPermission();

    if (permissionResult != LocationPermissionResult.granted) {
      state = state.copyWith(
        status: CampaignExecutionStatus.error,
        errorMessage: _getPermissionErrorMessage(permissionResult),
      );
      return false;
    }

    // Start location tracking
    final trackingStarted = await _locationService.startTracking();
    if (!trackingStarted) {
      state = state.copyWith(
        status: CampaignExecutionStatus.error,
        errorMessage: 'Failed to start location tracking',
      );
      return false;
    }

    // Subscribe to position updates
    _positionSubscription = _locationService.positionStream.listen(
      _onPositionUpdate,
      onError: (error) {
        AppLogger.location.e('Position stream error: $error');
      },
    );

    // Start sync timer
    _startSyncTimer();

    // Start elapsed time update timer (for UI)
    _startElapsedTimeTimer();

    // Get initial position
    final initialPosition = await _locationService.getCurrentPosition();
    ExecutionGpsPoint? initialPoint;
    if (initialPosition != null) {
      initialPoint = ExecutionGpsPoint.fromPosition(
        initialPosition,
        _uuid.v4(),
      );
    }

    state = state.copyWith(
      status: CampaignExecutionStatus.active,
      startedAt: DateTime.now(),
      pendingPoints: initialPoint != null ? [initialPoint] : [],
      allPoints: initialPoint != null ? [initialPoint] : [],
      currentPosition: initialPoint,
      distanceTraveled: 0.0,
    );

    // Persist state for recovery
    await _persistState();

    AppLogger.location.i('Campaign execution started: $campaignId');
    return true;
  }

  /// Pause campaign execution
  Future<void> pauseExecution() async {
    if (state.status != CampaignExecutionStatus.active) {
      return;
    }

    _locationService.pauseTracking();
    _syncTimer?.cancel();
    _elapsedTimeTimer?.cancel();

    state = state.copyWith(
      status: CampaignExecutionStatus.paused,
      pausedAt: DateTime.now(),
    );

    // Persist state for recovery
    await _persistState();

    AppLogger.location.i('Campaign execution paused');
  }

  /// Resume campaign execution
  Future<void> resumeExecution() async {
    if (state.status != CampaignExecutionStatus.paused) {
      return;
    }

    // Calculate pause duration
    final pauseDuration = state.pausedAt != null
        ? DateTime.now().difference(state.pausedAt!)
        : Duration.zero;

    _locationService.resumeTracking();
    _startSyncTimer();
    _startElapsedTimeTimer();

    state = state.copyWith(
      status: CampaignExecutionStatus.active,
      totalPausedDuration: state.totalPausedDuration + pauseDuration,
      clearPausedAt: true,
    );

    // Persist state for recovery
    await _persistState();

    AppLogger.location.i('Campaign execution resumed');
  }

  /// Complete campaign execution
  ///
  /// Returns the final execution summary
  Future<CampaignExecutionSummary> completeExecution() async {
    if (!state.hasActiveExecution) {
      throw Exception('No active execution to complete');
    }

    state = state.copyWith(status: CampaignExecutionStatus.completing);

    // Stop tracking
    _stopTracking();

    // Perform final sync
    await _syncPendingPoints();

    final summary = CampaignExecutionSummary(
      campaignId: state.campaignId!,
      campaignName: state.campaignName ?? '',
      startedAt: state.startedAt!,
      completedAt: DateTime.now(),
      totalDuration: state.elapsedTime,
      distanceTraveled: state.distanceTraveled,
      totalPoints: state.allPoints.length,
    );

    state = state.copyWith(status: CampaignExecutionStatus.completed);

    // Clear persisted state after completion
    await _clearPersistedState();

    AppLogger.location.i(
      'Campaign execution completed: ${summary.campaignId}, '
      'distance: ${summary.formattedDistance}, '
      'duration: ${summary.formattedDuration}',
    );

    return summary;
  }

  /// Cancel/abort campaign execution
  Future<void> cancelExecution() async {
    if (!state.hasActiveExecution) {
      return;
    }

    _stopTracking();

    // Clear persisted state
    await _clearPersistedState();

    state = CampaignExecutionState.idle();
    AppLogger.location.i('Campaign execution cancelled');
  }

  /// Reset to idle state (after viewing completed summary)
  Future<void> reset() async {
    await _clearPersistedState();
    state = CampaignExecutionState.idle();
  }

  /// Handle position update from location service
  void _onPositionUpdate(Position position) {
    if (state.status != CampaignExecutionStatus.active) {
      return;
    }

    final newPoint = ExecutionGpsPoint.fromPosition(position, _uuid.v4());

    // Apply filters to avoid GPS drift
    if (state.currentPosition != null) {
      final distance = LocationService.calculateDistance(
        state.currentPosition!.latitude,
        state.currentPosition!.longitude,
        newPoint.latitude,
        newPoint.longitude,
      );

      // Skip if moved less than minimum distance and speed is low
      if (distance < _minDistanceFilter &&
          (newPoint.speed ?? 0) < _minSpeedFilter) {
        return;
      }

      // Update total distance
      state = state.copyWith(
        distanceTraveled: state.distanceTraveled + distance,
      );
    }

    // Add point to lists
    final updatedPending = [...state.pendingPoints, newPoint];
    final updatedAll = [...state.allPoints, newPoint];

    state = state.copyWith(
      pendingPoints: updatedPending,
      allPoints: updatedAll,
      currentPosition: newPoint,
    );

    // Check if we should sync
    if (updatedPending.length >= _batchSyncThreshold) {
      _syncPendingPoints();
    }
  }

  /// Start the periodic sync timer
  void _startSyncTimer() {
    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(
      const Duration(seconds: _syncIntervalSeconds),
      (_) => _syncPendingPoints(),
    );
  }

  /// Start timer to refresh elapsed time in UI
  void _startElapsedTimeTimer() {
    _elapsedTimeTimer?.cancel();
    _elapsedTimeTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) {
        // Trigger state update to refresh elapsed time
        if (state.status == CampaignExecutionStatus.active) {
          // Create a new state reference to trigger UI update
          state = state.copyWith();
        }
      },
    );
  }

  /// Sync pending points to backend
  Future<void> _syncPendingPoints() async {
    if (state.pendingPoints.isEmpty || state.campaignId == null) {
      return;
    }

    final pointsToSync = List<ExecutionGpsPoint>.from(state.pendingPoints);

    AppLogger.location.d('Syncing ${pointsToSync.length} GPS points');

    try {
      // Sync to backend using the use case
      final result = await _syncUseCase.call(state.campaignId!);

      if (result.isSuccess || result.synced > 0) {
        // Mark points as synced locally
        final syncedPoints = pointsToSync
            .map((p) => p.copyWith(synced: true))
            .toList();

        // Update all points with synced status
        final updatedAllPoints = state.allPoints.map((point) {
          final synced = syncedPoints.firstWhere(
            (s) => s.id == point.id,
            orElse: () => point,
          );
          return synced;
        }).toList();

        state = state.copyWith(
          pendingPoints: [], // Clear pending after sync
          allPoints: updatedAllPoints,
        );
      } else if (result.hasError) {
        AppLogger.location.w('Sync failed, will retry: ${result.errorMessage}');
        // Keep points in pending for retry
      }
    } catch (e) {
      AppLogger.location.e('Sync error: $e');
      // Keep points in pending for retry
    }
  }

  /// Stop all tracking and timers
  void _stopTracking() {
    _positionSubscription?.cancel();
    _positionSubscription = null;

    _syncTimer?.cancel();
    _syncTimer = null;

    _elapsedTimeTimer?.cancel();
    _elapsedTimeTimer = null;

    _locationService.stopTracking();
  }

  /// Get error message for permission result
  String _getPermissionErrorMessage(LocationPermissionResult result) {
    switch (result) {
      case LocationPermissionResult.denied:
        return 'Location permission denied. Please grant permission to track your campaign route.';
      case LocationPermissionResult.deniedForever:
        return 'Location permission permanently denied. Please enable it in Settings.';
      case LocationPermissionResult.serviceDisabled:
        return 'Location services are disabled. Please enable them in Settings.';
      case LocationPermissionResult.granted:
        return '';
    }
  }

  @override
  void dispose() {
    _stopTracking();
    super.dispose();
  }
}

/// Summary of a completed campaign execution
class CampaignExecutionSummary {
  final String campaignId;
  final String campaignName;
  final DateTime startedAt;
  final DateTime completedAt;
  final Duration totalDuration;
  final double distanceTraveled;
  final int totalPoints;

  const CampaignExecutionSummary({
    required this.campaignId,
    required this.campaignName,
    required this.startedAt,
    required this.completedAt,
    required this.totalDuration,
    required this.distanceTraveled,
    required this.totalPoints,
  });

  /// Distance in kilometers
  double get distanceKm => distanceTraveled / 1000;

  /// Formatted duration as HH:MM:SS
  String get formattedDuration {
    final hours = totalDuration.inHours;
    final minutes = totalDuration.inMinutes.remainder(60);
    final seconds = totalDuration.inSeconds.remainder(60);
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Formatted distance
  String get formattedDistance {
    if (distanceTraveled < 1000) {
      return '${distanceTraveled.toStringAsFixed(0)} m';
    }
    return '${distanceKm.toStringAsFixed(2)} km';
  }
}
