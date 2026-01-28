import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:promoruta/gen/l10n/app_localizations.dart';
import 'package:promoruta/shared/providers/map_style_provider.dart';

/// Shows a bottom sheet for selecting map style
Future<void> showMapStylePicker(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) => const _MapStylePickerSheet(),
  );
}

class _MapStylePickerSheet extends ConsumerWidget {
  const _MapStylePickerSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final currentStyle = ref.watch(mapStyleProvider);

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          Container(
            width: 38,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              l10n.selectMapStyle,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 8),
          _StyleTile(
            style: MapStyle.streets,
            label: l10n.mapStyleStreets,
            icon: Icons.map_outlined,
            isSelected: currentStyle == MapStyle.streets,
            onTap: () {
              ref.read(mapStyleProvider.notifier).setStyle(MapStyle.streets);
              Navigator.pop(context);
            },
          ),
          _StyleTile(
            style: MapStyle.satellite,
            label: l10n.mapStyleSatellite,
            icon: Icons.satellite_alt,
            isSelected: currentStyle == MapStyle.satellite,
            onTap: () {
              ref.read(mapStyleProvider.notifier).setStyle(MapStyle.satellite);
              Navigator.pop(context);
            },
          ),
          _StyleTile(
            style: MapStyle.outdoors,
            label: l10n.mapStyleOutdoors,
            icon: Icons.terrain,
            isSelected: currentStyle == MapStyle.outdoors,
            onTap: () {
              ref.read(mapStyleProvider.notifier).setStyle(MapStyle.outdoors);
              Navigator.pop(context);
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _StyleTile extends StatelessWidget {
  const _StyleTile({
    required this.style,
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final MapStyle style;
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? theme.colorScheme.primary : null,
      ),
      title: Text(
        label,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          color: isSelected ? theme.colorScheme.primary : null,
        ),
      ),
      trailing: isSelected
          ? Icon(Icons.check, color: theme.colorScheme.primary)
          : null,
      onTap: onTap,
    );
  }
}
