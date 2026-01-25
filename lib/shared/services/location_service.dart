import 'dart:async';
import 'dart:io';

import 'package:geolocator/geolocator.dart';
import 'package:promoruta/core/utils/logger.dart';

/// Result of a location permission request
enum LocationPermissionResult {
  granted,
  denied,
  deniedForever,
  serviceDisabled,
}

/// Location service for GPS tracking during campaign execution.
///
/// Provides stream-based location updates with platform-specific settings
/// for Android and iOS devices.
class LocationService {
  StreamSubscription<Position>? _positionSubscription;
  final _positionController = StreamController<Position>.broadcast();

  /// Stream of position updates
  Stream<Position> get positionStream => _positionController.stream;

  /// Whether location tracking is currently active
  bool get isTracking => _positionSubscription != null;

  /// Check if location services are enabled on the device
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Get current location permission status
  Future<LocationPermission> getPermissionStatus() async {
    return await Geolocator.checkPermission();
  }

  /// Request location permission with platform-specific handling
  ///
  /// Returns the result of the permission request.
  Future<LocationPermissionResult> requestPermission() async {
    // Check if location services are enabled
    final serviceEnabled = await isLocationServiceEnabled();
    if (!serviceEnabled) {
      AppLogger.location.w('Location services are disabled');
      return LocationPermissionResult.serviceDisabled;
    }

    // Check current permission status
    var permission = await getPermissionStatus();

    if (permission == LocationPermission.denied) {
      // Request permission
      permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied) {
        AppLogger.location.w('Location permission denied');
        return LocationPermissionResult.denied;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      AppLogger.location.w('Location permission permanently denied');
      return LocationPermissionResult.deniedForever;
    }

    // On iOS 14+, check for precise/approximate accuracy
    if (Platform.isIOS) {
      final accuracy = await Geolocator.getLocationAccuracy();
      if (accuracy == LocationAccuracyStatus.reduced) {
        AppLogger.location.i('iOS: Reduced accuracy detected, requesting full accuracy');
        // Request temporary full accuracy for campaign tracking
        final fullAccuracy = await Geolocator.requestTemporaryFullAccuracy(
          purposeKey: 'CampaignTracking',
        );
        if (fullAccuracy == LocationAccuracyStatus.reduced) {
          AppLogger.location.w('iOS: Full accuracy not granted');
          // Still allow tracking but with reduced accuracy
        }
      }
    }

    AppLogger.location.i('Location permission granted');
    return LocationPermissionResult.granted;
  }

  /// Get current position once
  Future<Position?> getCurrentPosition() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: _getLocationSettings(),
      );
      return position;
    } catch (e) {
      AppLogger.location.e('Failed to get current position: $e');
      return null;
    }
  }

  /// Start continuous location tracking
  ///
  /// Location updates are emitted on [positionStream] based on:
  /// - Distance filter: 10 meters (triggers update when moved)
  /// - Time interval: Updates at least every 30 seconds as fallback
  Future<bool> startTracking() async {
    if (isTracking) {
      AppLogger.location.w('Location tracking already active');
      return true;
    }

    // Verify permissions first
    final permissionResult = await requestPermission();
    if (permissionResult != LocationPermissionResult.granted) {
      AppLogger.location.e('Cannot start tracking: permission not granted');
      return false;
    }

    try {
      AppLogger.location.i('Starting location tracking');

      _positionSubscription = Geolocator.getPositionStream(
        locationSettings: _getLocationSettings(),
      ).listen(
        (Position position) {
          AppLogger.location.d(
            'Position update: ${position.latitude}, ${position.longitude} '
            '(accuracy: ${position.accuracy}m, speed: ${position.speed}m/s)',
          );
          _positionController.add(position);
        },
        onError: (error) {
          AppLogger.location.e('Location stream error: $error');
        },
      );

      return true;
    } catch (e) {
      AppLogger.location.e('Failed to start location tracking: $e');
      return false;
    }
  }

  /// Stop location tracking
  void stopTracking() {
    if (!isTracking) {
      return;
    }

    AppLogger.location.i('Stopping location tracking');
    _positionSubscription?.cancel();
    _positionSubscription = null;
  }

  /// Pause location tracking (can be resumed)
  void pauseTracking() {
    if (_positionSubscription != null) {
      AppLogger.location.i('Pausing location tracking');
      _positionSubscription?.pause();
    }
  }

  /// Resume paused location tracking
  void resumeTracking() {
    if (_positionSubscription != null && _positionSubscription!.isPaused) {
      AppLogger.location.i('Resuming location tracking');
      _positionSubscription?.resume();
    }
  }

  /// Open device location settings
  Future<bool> openLocationSettings() async {
    return await Geolocator.openLocationSettings();
  }

  /// Open app settings (for permission management)
  Future<bool> openAppSettings() async {
    return await Geolocator.openAppSettings();
  }

  /// Get platform-specific location settings
  LocationSettings _getLocationSettings() {
    if (Platform.isAndroid) {
      return AndroidSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // meters
        intervalDuration: const Duration(seconds: 5), // minimum interval
        forceLocationManager: false,
        foregroundNotificationConfig: const ForegroundNotificationConfig(
          notificationTitle: 'Promoruta',
          notificationText: 'Tracking your campaign route',
          notificationIcon: AndroidResource(
            name: 'ic_notification',
            defType: 'drawable',
          ),
          enableWakeLock: true,
        ),
      );
    } else if (Platform.isIOS) {
      return AppleSettings(
        accuracy: LocationAccuracy.high,
        activityType: ActivityType.automotiveNavigation,
        distanceFilter: 10, // meters
        pauseLocationUpdatesAutomatically: false,
        showBackgroundLocationIndicator: true,
        allowBackgroundLocationUpdates: false, // v1: foreground only
      );
    } else {
      // Fallback for other platforms
      return const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      );
    }
  }

  /// Calculate distance between two positions in meters
  static double calculateDistance(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    return Geolocator.distanceBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
  }

  /// Dispose resources
  void dispose() {
    stopTracking();
    _positionController.close();
  }
}
