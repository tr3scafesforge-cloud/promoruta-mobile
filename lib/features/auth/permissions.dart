import 'package:flutter/material.dart';

class Permissions extends StatelessWidget {
  const Permissions({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Permisos y accesos',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontSize: 32,
                ),
          ),
          const SizedBox(height: 16),
          
          Text(
            'Actívá estos permisos para una mejor experiencia',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[600],
                  fontSize: 16,
                ),
          ),
          const SizedBox(height: 40),
          
          // Location Permission Card
          _PermissionCard(
            icon: Icons.location_on,
            iconColor: const Color(0xFF2196F3),
            backgroundColor: const Color(0xFFE3F2FD),
            title: 'Acceso a tu ubicación',
            subtitle: 'Indispensable para seguir la ruta y ver campañas cerca tuyo',
          ),
          const SizedBox(height: 20),
          
          // Notifications Permission Card
          _PermissionCard(
            icon: Icons.notifications,
            iconColor: const Color(0xFFFF9800),
            backgroundColor: const Color(0xFFFFF3E0),
            title: 'Notificaciones',
            subtitle: 'Seguí el estado de las campañas y no te pierdas lo que vaya surgiendo',
          ),
          const SizedBox(height: 20),
          
          // Microphone Permission Card
          _PermissionCard(
            icon: Icons.mic,
            iconColor: const Color(0xFF4CAF50),
            backgroundColor: const Color(0xFFE8F5E8),
            title: 'Permitir micrófono',
            subtitle: 'Grabar campañas de audio y reproducir contenido promocional',
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

  const _PermissionCard({
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
    required this.title,
    required this.subtitle,
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
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
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