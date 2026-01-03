import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:promoruta/core/constants/colors.dart';
import 'package:promoruta/gen/l10n/app_localizations.dart';
import '../providers/permission_provider.dart';
import '../widgets/permission_card.dart';

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
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              Text(
                AppLocalizations.of(context).permissionsSubtitle,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 24,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              Expanded(
                child: Column(
                  children: [
                    PermissionCard(
                      icon: Icons.location_on,
                      iconColor: AppColors.blueDark,
                      backgroundColor: AppColors.blueDark.withValues(alpha: 0.2),
                      title: AppLocalizations.of(context).locationTitle,
                      subtitle: AppLocalizations.of(context).locationSubtitle,
                      isGranted: permissionState.locationGranted,
                      onTap: () =>
                          permissionNotifier.requestLocationPermission(),
                    ),
                    const SizedBox(height: 20),
                    PermissionCard(
                      icon: Icons.notifications,
                      iconColor: AppColors.deepOrange,
                      backgroundColor: AppColors.deepOrange.withValues(alpha: 0.2),
                      title: AppLocalizations.of(context).notificationsTitle,
                      subtitle:
                          AppLocalizations.of(context).notificationsSubtitle,
                      isGranted: permissionState.notificationGranted,
                      onTap: () =>
                          permissionNotifier.requestNotificationPermission(),
                    ),
                    const SizedBox(height: 20),
                    PermissionCard(
                      icon: Icons.mic,
                      iconColor: AppColors.secondary,
                      backgroundColor: AppColors.secondary.withValues(alpha: 0.2),
                      title: AppLocalizations.of(context).microphoneTitle,
                      subtitle: AppLocalizations.of(context).microphoneSubtitle,
                      isGranted: permissionState.microphoneGranted,
                      onTap: () =>
                          permissionNotifier.requestMicrophonePermission(),
                    ),
                  ],
                ),
              ),

              // Bottom buttons
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24.0),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: permissionState.isLoading
                            ? null
                            : () async {
                                await permissionNotifier
                                    .requestAllPermissions();
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.blueDark,
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
                            : Text(
                                AppLocalizations.of(context)
                                    .allowAllPermissions,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 40),
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

