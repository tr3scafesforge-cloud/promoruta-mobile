// lib/utils/permission_helper.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
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

    // Show dialog explaining why we need the permission
    final shouldRequest = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permiso de ubicación requerido'),
        content: const Text(
          'Necesitamos acceso a tu ubicación para mostrarte campañas cerca de ti y ayudarte con la navegación.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Permitir'),
          ),
        ],
      ),
    );

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
        title: const Text('Permiso denegado'),
        content: const Text(
          'Los permisos han sido denegados permanentemente. Por favor, ve a configuración para habilitarlos.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              openAppSettings();
            },
            child: const Text('Configuración'),
          ),
        ],
      ),
    );
  }
}

// Extension to easily check permissions in any widget
extension PermissionStateExtension on PermissionState {
  String getLocationStatusText() {
    if (locationGranted) return 'Concedido';
    return 'Requerido';
  }

  String getNotificationStatusText() {
    if (notificationGranted) return 'Concedido';
    return 'Opcional';
  }

  String getMicrophoneStatusText() {
    if (microphoneGranted) return 'Concedido';
    return 'Opcional';
  }
}
