import 'package:flutter/material.dart';
import 'package:promoruta/core/constants/colors.dart';

class BottomNavigationItem extends StatelessWidget {
  final bool isSelected;
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? splashColor;
  final Color? selectedColor;
  final Color? unselectedColor;

  const BottomNavigationItem({
    super.key,
    required this.isSelected,
    required this.icon,
    required this.label,
    required this.onTap,
    this.splashColor,
    this.selectedColor = AppColors.secondary,
    this.unselectedColor = AppColors.textPrimary,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveSelectedColor = selectedColor ?? theme.colorScheme.primary;
    final effectiveUnselectedColor = unselectedColor ?? (theme.brightness == Brightness.dark
        ? Colors.white.withOpacity(0.7)
        : theme.colorScheme.onSurfaceVariant);

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          splashColor: splashColor ?? theme.colorScheme.primary.withValues(alpha: .10),
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
                Icon(
                  icon,
                  color: isSelected ? effectiveSelectedColor : effectiveUnselectedColor,
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: TextStyle(
                    color:  isSelected ? effectiveSelectedColor : effectiveUnselectedColor,
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
