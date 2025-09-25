import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:promoruta/core/constants/colors.dart';

class Permissions extends StatefulWidget {
  const Permissions({super.key});

  @override
  State<Permissions> createState() => _PermissionsState();
}

class _PermissionsState extends State<Permissions> {
  bool _locationGranted = false;
  bool _notificationGranted = false;
  bool _microphoneGranted = false;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    final locationStatus = await Permission.location.status;
    final notificationStatus = await Permission.notification.status;
    final microphoneStatus = await Permission.microphone.status;

    setState(() {
      _locationGranted = locationStatus.isGranted;
      _notificationGranted = notificationStatus.isGranted;
      _microphoneGranted = microphoneStatus.isGranted;
    });
  }

  Future<void> _requestLocation() async {
    final status = await Permission.location.request();
    setState(() {
      _locationGranted = status.isGranted;
    });
  }

  Future<void> _requestNotification() async {
    final status = await Permission.notification.request();
    setState(() {
      _notificationGranted = status.isGranted;
    });
  }

  Future<void> _requestMicrophone() async {
    final status = await Permission.microphone.request();
    setState(() {
      _microphoneGranted = status.isGranted;
    });
  }

  bool get _allPermissionsGranted =>
      _locationGranted && _notificationGranted && _microphoneGranted;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Permisos y accesos',
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontSize: 36,
                ),
          ),
          const SizedBox(height: 16),

          Text(
            'Actívá estos permisos para una mejor experiencia',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.w100,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),

          // Location Permission Card
          _PermissionCard(
            icon: Icons.location_on,
            iconColor: const Color(0xFF2196F3),
            backgroundColor: const Color(0xFFE3F2FD),
            title: 'Acceso a tu ubicación',
            subtitle:
                'Indispensable para seguir la ruta y ver campañas cerca tuyo',
            isGranted: _locationGranted,
            onPressed: _requestLocation,
          ),
          const SizedBox(height: 20),

          // Notifications Permission Card
          _PermissionCard(
            icon: Icons.notifications,
            iconColor: const Color(0xFFFF9800),
            backgroundColor: const Color(0xFFFFF3E0),
            title: 'Notificaciones',
            subtitle:
                'Seguí el estado de las campañas y no te pierdas lo que vaya surgiendo',
            isGranted: _notificationGranted,
            onPressed: _requestNotification,
          ),
          const SizedBox(height: 20),

          // Microphone Permission Card
          _PermissionCard(
            icon: Icons.mic,
            iconColor: const Color(0xFF4CAF50),
            backgroundColor: const Color(0xFFE8F5E8),
            title: 'Permitir micrófono',
            subtitle:
                'Grabar campañas de audio y reproducir contenido promocional',
            isGranted: _microphoneGranted,
            onPressed: _requestMicrophone,
            isDisabled: !_microphoneGranted, // Keep disabled until granted
          ),
          const SizedBox(height: 40),

          // Continue Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _allPermissionsGranted ? () {
                // Navigate to next screen or something
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('All permissions granted!')),
                );
              } : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Continuar',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PermissionCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;
  final String title;
  final String subtitle;
  final bool isGranted;
  final VoidCallback onPressed;
  final bool? isDisabled;

  const _PermissionCard({
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
    required this.title,
    required this.subtitle,
    required this.isGranted,
    required this.onPressed,
    this.isDisabled,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE1E7EF), width: 1),
      ),
      child: Row(
        children: [
          // Icon container
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(28),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),

          // Text content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                              fontSize: 16,
                            ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: (isDisabled ?? false) ? null : onPressed,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isGranted ? Colors.green : AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        textStyle: const TextStyle(fontSize: 14),
                      ),
                      child: Text(isGranted ? 'Concedido' : 'Permitir'),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
