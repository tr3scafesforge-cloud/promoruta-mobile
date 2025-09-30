// lib/utils/permission_helper.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:promoruta/gen/l10n/app_localizations.dart';
import 'package:promoruta/presentation/providers/permission_provider.dart';

class PermissionHelper {
  // Check if location permission is granted
  static Future<bool> hasLocationPermission() async {
    final status = await Permission.locationWhenInUse.status;
    return status.isGranted;
  }

  // Check if notification permission is granted
  static Future<bool> hasNotificationPermission() async {
    final status = await Permission.notification.status;
    return status.isGranted;
  }

  // Check if microphone permission is granted
  static Future<bool> hasMicrophonePermission() async {
    final status = await Permission.microphone.status;
    return status.isGranted;
  }

  // Show permission dialog if not granted
  static Future<bool> requestLocationWithDialog(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final permissionNotifier = ref.read(permissionNotifierProvider.notifier);
    final hasPermission = await hasLocationPermission();

    if (hasPermission) return true;

    if (!context.mounted) return false;

    final shouldRequest = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title:
            Text(AppLocalizations.of(context).locationPermissionRequiredTitle),
        content: Text(
          AppLocalizations.of(context).locationPermissionExplanation,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(AppLocalizations.of(context).cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(AppLocalizations.of(context).allow),
          ),
        ],
      ),
    );

    if (!context.mounted) return false;

    if (shouldRequest == true) {
      return await permissionNotifier.requestLocationPermission();
    }

    return false;
  }

  // Show settings dialog when permission is permanently denied
  static Future<void> showSettingsDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context).permissionDenied),
        content: Text(
          AppLocalizations.of(context).permissionPermanentlyDenied,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context).cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              openAppSettings();
            },
            child: Text(AppLocalizations.of(context).settings),
          ),
        ],
      ),
    );

    if (!context.mounted) return;
  }
}

// Extension to easily check permissions in any widget
extension PermissionStateExtension on PermissionState {
  String getLocationStatusText(BuildContext context) {
    if (locationGranted) return AppLocalizations.of(context).granted;
    return AppLocalizations.of(context).required;
  }

  String getNotificationStatusText(BuildContext context) {
    if (notificationGranted) return AppLocalizations.of(context).granted;
    return AppLocalizations.of(context).optional;
  }

  String getMicrophoneStatusText(BuildContext context) {
    if (microphoneGranted) return AppLocalizations.of(context).granted;
    return AppLocalizations.of(context).optional;
  }
}
