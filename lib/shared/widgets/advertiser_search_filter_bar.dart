import 'package:flutter/material.dart';

class AdvertiserSearchFilterBar extends StatelessWidget {
  const AdvertiserSearchFilterBar({
    super.key,
    required this.controller,
    required this.hint,
    required this.onChanged,
    required this.onFilterTap,
    this.onClear,
  });

  final TextEditingController controller;
  final String hint;
  final ValueChanged<String> onChanged;
  final VoidCallback onFilterTap;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.colorScheme.outline),
            ),
            child: Row(
              children: [
                const SizedBox(width: 12),
                Icon(Icons.search, size: 20, color: theme.colorScheme.onSurfaceVariant),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: controller,
                    onChanged: onChanged,
                    decoration: InputDecoration(
                      hintText: hint,
                      border: InputBorder.none,
                    ),
                  ),
                ),
                if (onClear != null && controller.text.isNotEmpty)
                  IconButton(
                    icon: Icon(Icons.close, size: 18, color: theme.colorScheme.onSurfaceVariant),
                    onPressed: onClear,
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        IconButton.filled(
          onPressed: onFilterTap,
          style: IconButton.styleFrom(
            backgroundColor: theme.colorScheme.surface,
            side: BorderSide(color: theme.colorScheme.outline),
          ),
          icon: Icon(Icons.tune, color: theme.colorScheme.onSurface),
          tooltip: 'Filtros',
        ),
      ],
    );
  }
}