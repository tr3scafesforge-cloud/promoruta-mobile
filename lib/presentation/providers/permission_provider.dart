import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

// Permission state model
class PermissionState {
  final bool locationGranted;
  final bool notificationGranted;
  final bool microphoneGranted;
  final bool isLoading;

  const PermissionState({
    this.locationGranted = false,
    this.notificationGranted = false,
    this.microphoneGranted = false,
    this.isLoading = false,
  });

  PermissionState copyWith({
    bool? locationGranted,
    bool? notificationGranted,
    bool? microphoneGranted,
    bool? isLoading,
  }) {
    return PermissionState(
      locationGranted: locationGranted ?? this.locationGranted,
      notificationGranted: notificationGranted ?? this.notificationGranted,
      microphoneGranted: microphoneGranted ?? this.microphoneGranted,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  // Check if all critical permissions are granted
  bool get allCriticalPermissionsGranted => locationGranted;
  
  // Check if all permissions are granted
  bool get allPermissionsGranted => 
      locationGranted && notificationGranted && microphoneGranted;
}

// Permission notifier
class PermissionNotifier extends StateNotifier<PermissionState> {
  PermissionNotifier() : super(const PermissionState()) {
    _checkCurrentPermissions();
  }

  // Check current permission status
  Future<void> _checkCurrentPermissions() async {
    state = state.copyWith(isLoading: true);
    
    try {
      final locationStatus = await Permission.locationWhenInUse.status;
      final notificationStatus = await Permission.notification.status;
      final microphoneStatus = await Permission.microphone.status;

      state = state.copyWith(
        locationGranted: locationStatus.isGranted,
        notificationGranted: notificationStatus.isGranted,
        microphoneGranted: microphoneStatus.isGranted,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  // Request location permission
  Future<bool> requestLocationPermission() async {
    try {
      final status = await Permission.locationWhenInUse.request();
      final isGranted = status.isGranted;
      
      state = state.copyWith(locationGranted: isGranted);
      return isGranted;
    } catch (e) {
      return false;
    }
  }

  // Request notification permission
  Future<bool> requestNotificationPermission() async {
    try {
      final status = await Permission.notification.request();
      final isGranted = status.isGranted;
      
      state = state.copyWith(notificationGranted: isGranted);
      return isGranted;
    } catch (e) {
      return false;
    }
  }

  // Request microphone permission
  Future<bool> requestMicrophonePermission() async {
    try {
      final status = await Permission.microphone.request();
      final isGranted = status.isGranted;
      
      state = state.copyWith(microphoneGranted: isGranted);
      return isGranted;
    } catch (e) {
      return false;
    }
  }

  // Request all permissions at once
  Future<void> requestAllPermissions() async {
    state = state.copyWith(isLoading: true);
    
    try {
      final permissions = await [
        Permission.locationWhenInUse,
        Permission.notification,
        Permission.microphone,
      ].request();

      state = state.copyWith(
        locationGranted: permissions[Permission.locationWhenInUse]?.isGranted ?? false,
        notificationGranted: permissions[Permission.notification]?.isGranted ?? false,
        microphoneGranted: permissions[Permission.microphone]?.isGranted ?? false,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  // Open app settings
  Future<void> openAppSettings() async {
    await openAppSettings();
  }

  // Refresh permission status
  Future<void> refreshPermissions() async {
    await _checkCurrentPermissions();
  }
}

// Provider
final permissionNotifierProvider = StateNotifierProvider<PermissionNotifier, PermissionState>(
  (ref) => PermissionNotifier(),
);