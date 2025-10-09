import 'package:flutter/material.dart';
import 'package:promoruta/gen/l10n/app_localizations.dart';

class PermissionCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;
  final String title;
  final String subtitle;
  final bool isGranted;
  final VoidCallback onTap;

  const PermissionCard({
    super.key,
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return InkWell(
      onTap: isGranted ? null : onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isGranted ? colorScheme.primaryContainer : colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: !isGranted
              ? Border.all(color: colorScheme.outline, width: 1)
              : isGranted
                  ? Border.all(color: colorScheme.primary, width: 1)
                  : null,
        ),
        child: Row(
          children: [
            // Icon container
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: isGranted ? colorScheme.primaryContainer : backgroundColor,
                borderRadius: BorderRadius.circular(28),
              ),
              child: Icon(
                isGranted ? Icons.check_circle : icon,
                color: isGranted ? colorScheme.primary : iconColor,
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
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: isGranted ? colorScheme.onPrimaryContainer : colorScheme.onSurface,
                          ),
                        ),
                      ),
                      if (!isGranted)
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: colorScheme.error,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.warning,
                            color: colorScheme.onError,
                            size: 12,
                          ),
                        ),
                      if (isGranted)
                        Icon(
                          Icons.check_circle,
                          color: colorScheme.primary,
                          size: 20,
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isGranted
                        ? AppLocalizations.of(context).permissionGranted
                        : subtitle,
                    style: textTheme.bodyMedium?.copyWith(
                      color: isGranted ? colorScheme.primary : colorScheme.onSurfaceVariant,
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