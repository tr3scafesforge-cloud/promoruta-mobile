import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:promoruta/gen/l10n/app_localizations.dart';
import 'package:promoruta/presentation/providers/permission_provider.dart';

class Permissions extends ConsumerWidget {
  const Permissions({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final permissionState = ref.watch(permissionNotifierProvider);
    final permissionNotifier = ref.read(permissionNotifierProvider.notifier);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              Text(
                AppLocalizations.of(context).permissionsAccess,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      fontSize: 36,
                    ),
              ),
              const SizedBox(height: 16),
              
              Text(
                'Actívá estos permisos para una mejor experiencia',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey[600],
                      fontSize: 24,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              
              // Permission Cards
              Expanded(
                child: Column(
                  children: [
                    // Location Permission Card
                    _PermissionCard(
                      icon: Icons.location_on,
                      iconColor: const Color(0xFF2196F3),
                      backgroundColor: const Color(0xFFE3F2FD),
                      title: 'Acceso a tu ubicación',
                      subtitle: 'Indispensable para seguir la ruta y ver campañas cerca tuyo',
                      isGranted: permissionState.locationGranted,
                      onTap: () => permissionNotifier.requestLocationPermission(),
                    ),
                    const SizedBox(height: 20),
                    
                    // Notifications Permission Card
                    _PermissionCard(
                      icon: Icons.notifications,
                      iconColor: const Color(0xFFFF9800),
                      backgroundColor: const Color(0xFFFFF3E0),
                      title: 'Notificaciones',
                      subtitle: 'Seguí el estado de las campañas y no te pierdas lo que vaya surgiendo',
                      isGranted: permissionState.notificationGranted,
                      onTap: () => permissionNotifier.requestNotificationPermission(),
                    ),
                    const SizedBox(height: 20),
                    
                    // Microphone Permission Card
                    _PermissionCard(
                      icon: Icons.mic,
                      iconColor: const Color(0xFF4CAF50),
                      backgroundColor: const Color(0xFFE8F5E8),
                      title: 'Permitir micrófono',
                      subtitle: 'Grabar campañas de audio y reproducir contenido promocional',
                      isGranted: permissionState.microphoneGranted,
                      onTap: () => permissionNotifier.requestMicrophonePermission(),
                    ),
                  ],
                ),
              ),
              
              // Bottom buttons
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24.0),
                child: Column(
                  children: [
                    // Request All Permissions Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: permissionState.isLoading 
                          ? null 
                          : () async {
                              await permissionNotifier.requestAllPermissions();
                            },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2196F3),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: permissionState.isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Permitir todos los accesos',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    // Continue Button (only show if critical permissions are granted)
                    if (permissionState.allCriticalPermissionsGranted)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            // Navigate to next screen
                            context.go('/home'); // or wherever you want to go next
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4CAF50),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Continuar',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    
                    // Skip Button
                    const SizedBox(height: 40),
                    // TextButton(
                    //   onPressed: () {
                    //     context.go('/home'); // Allow user to skip
                    //   },
                    //   child: Text(
                    //     'Saltar por ahora',
                    //     style: TextStyle(
                    //       color: Colors.grey[600],
                    //       fontSize: 16,
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
              ),
            ],
          ),
        ),
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
  final VoidCallback onTap;

  const _PermissionCard({
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
    required this.title,
    required this.subtitle,
    required this.isGranted,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isGranted ? null : onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isGranted ? Colors.green[50] : Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: !isGranted
            ? Border.all(color: const Color(0xFFE1E7EF), width: 2)
            : isGranted 
              ? Border.all(color: Colors.green, width: 2)
              : null,
        ),
        child: Row(
          children: [
            // Icon container
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: isGranted ? Colors.green[100] : backgroundColor,
                borderRadius: BorderRadius.circular(28),
              ),
              child: Icon(
                isGranted ? Icons.check_circle : icon,
                color: isGranted ? Colors.green : iconColor,
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
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isGranted ? Colors.green[800] : Colors.black,
                          ),
                        ),
                      ),
                      if (!isGranted)
                        Container(
                          width: 20,
                          height: 20,
                          decoration: const BoxDecoration(
                            color: Color(0xFFFFA726),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.warning,
                            color: Colors.white,
                            size: 12,
                          ),
                        ),
                      if (isGranted)
                        const Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 20,
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isGranted ? 'Permiso concedido' : subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: isGranted ? Colors.green[600] : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
