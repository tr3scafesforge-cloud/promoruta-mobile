import 'package:flutter/material.dart';
import 'package:promoruta/core/constants/colors.dart';
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
    return InkWell(
      onTap: isGranted ? null : onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isGranted ? Colors.green[50] : AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: !isGranted
              ? Border.all(color: AppColors.grayStroke, width: 1)
              : isGranted
                  ? Border.all(color: Colors.green, width: 1)
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
                    isGranted
                        ? AppLocalizations.of(context).permissionGranted
                        : subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: isGranted ? Colors.green[600] : AppColors.textSecondary,
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