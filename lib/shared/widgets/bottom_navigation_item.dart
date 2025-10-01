import 'package:flutter/material.dart';
import 'package:promoruta/core/constants/colors.dart';

class BottomNavigationItem extends StatelessWidget {
  final bool isSelected;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const BottomNavigationItem({
    super.key,
    required this.isSelected,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          splashColor: AppColors.secondary.withValues(alpha: .10),
          highlightColor: Colors.transparent,
          splashFactory: InkRipple.splashFactory,
          customBorder:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          radius: 28,
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon,
                    color: isSelected
                        ? AppColors.secondary
                        : AppColors.textPrimary),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: TextStyle(
                    color: isSelected
                        ? AppColors.secondary
                        : AppColors.textPrimary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}