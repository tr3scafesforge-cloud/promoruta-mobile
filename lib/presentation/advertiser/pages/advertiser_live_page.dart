import 'package:flutter/material.dart';
import 'package:promoruta/gen/l10n/app_localizations.dart';

class AdvertiserLivePage extends StatefulWidget {
  const AdvertiserLivePage({super.key});

  @override
  State<AdvertiserLivePage> createState() => _AdvertiserLivePageState();
}

class _AdvertiserLivePageState extends State<AdvertiserLivePage>
    with TickerProviderStateMixin {
  late final TabController _sheetTabs = TabController(length: 2, vsync: this);
  bool _following = false;

  @override
  void dispose() {
    _sheetTabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: Stack(
        children: [
          // --- MAP LAYER (swap with GoogleMap later) ---
          const _MapFullscreenPlaceholder(),

          // --- TOP BAR ---
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
              child: Row(
                children: [
                  _RoundIcon(
                    icon: Icons.arrow_back,
                    onTap: () => Navigator.maybePop(context),
                    background: theme.colorScheme.surface,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Row(
                      children: [
                        _LiveDot(label: l10n.liveLabel),
                        const Spacer(),
                        _ChipButton(
                          icon: Icons.layers_outlined,
                          label: l10n.layers,
                          onTap: () {}, // TODO: open layers menu
                        ),
                        const SizedBox(width: 8),
                        _ChipButton(
                          icon: Icons.access_time,
                          label: l10n.now,
                          onTap: () {}, // TODO: time/historic playback
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // --- FLOATING CONTROLS ---
          Positioned(
            right: 12,
            bottom: 110,
            child: Column(
              children: [
                _RoundFab(
                    icon: Icons.my_location, onPressed: () {/* recenter */}),
                const SizedBox(height: 8),
                _RoundFab(
                  icon: _following
                      ? Icons.center_focus_strong
                      : Icons.center_focus_weak,
                  onPressed: () => setState(() => _following = !_following),
                ),
                const SizedBox(height: 8),
                _RoundFab(icon: Icons.add, onPressed: () {/* zoom in */}),
                const SizedBox(height: 8),
                _RoundFab(icon: Icons.remove, onPressed: () {/* zoom out */}),
              ],
            ),
          ),

          // --- DRAGGABLE SHEET (Promoters / Alerts) ---
          DraggableScrollableSheet(
            initialChildSize: 0.22,
            minChildSize: 0.18,
            maxChildSize: 0.9,
            snap: true,
            snapSizes: const [0.22, 0.5, 0.9],
            builder: (context, controller) {
              return Material(
                color: theme.colorScheme.surface,
                elevation: 16,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    _Grabber(color: theme.colorScheme.outlineVariant),
                    const SizedBox(height: 4),
                    TabBar(
                      controller: _sheetTabs,
                      labelStyle: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                      tabs: [
                        Tab(text: l10n.activePromoters),
                        Tab(text: l10n.alerts),
                      ],
                    ),
                    Expanded(
                      child: TabBarView(
                        controller: _sheetTabs,
                        children: [
                          _PromotersList(scrollController: controller),
                          _AlertsList(scrollController: controller),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// --------------------------
// Sub-widgets & placeholders
// --------------------------

class _MapFullscreenPlaceholder extends StatelessWidget {
  const _MapFullscreenPlaceholder();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    return Container(
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: .25),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.location_on_outlined,
                size: 52, color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(height: 8),
            Text(
              l10n.realTimeLocation,
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              l10n.mapLocationRealTime,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PromotersList extends StatelessWidget {
  const _PromotersList({required this.scrollController});
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
      children: [
        // Filters / chips row
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _FilterChip(label: l10n.active, selected: true),
            _FilterChip(label: l10n.pending),
            _FilterChip(label: l10n.noSignal),
            const SizedBox(width: 8),
          ],
        ),
        const SizedBox(height: 12),
        // Example items
        _PromoterItem(
          name: 'Mati C.',
          place: 'Montevideo Shopping',
          online: true,
          signal: 4,
          onTap: () {
            // TODO: focus the map + follow
          },
        ),
        const SizedBox(height: 8),
        _PromoterItem(
          name: 'Carlos R',
          place: 'Nuevo Shopping',
          online: true,
          signal: 3,
        ),
        const SizedBox(height: 8),
        _PromoterItem(
          name: 'Diego M.',
          place: 'Portones',
          online: false,
          signal: 0,
        ),
        const SizedBox(height: 16),
        Text(
          '${l10n.lastUpdated} ${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _AlertsList extends StatelessWidget {
  const _AlertsList({required this.scrollController});
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
      children: [
        _AlertCard(
          title: 'Mati C',
          subtitle: l10n.startedRoute,
          icon: Icons.campaign_outlined,
        ),
        const SizedBox(height: 8),
        _AlertCard(
          title: 'Carlos R',
          subtitle: l10n.preparingForRoute,
          icon: Icons.directions_car_filled_outlined,
        ),
        const SizedBox(height: 8),
        _AlertCard(
          title: l10n.promoterOutOfZone,
          subtitle: l10n.promoterOutOfZoneMessage,
          icon: Icons.warning_amber_rounded,
          color: Colors.orange,
        ),
      ],
    );
  }
}

class _PromoterItem extends StatelessWidget {
  const _PromoterItem({
    required this.name,
    required this.place,
    required this.online,
    required this.signal,
    this.onTap,
  });

  final String name;
  final String place;
  final bool online;
  final int signal; // 0–4
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor = online ? Colors.green : theme.colorScheme.outline;

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.colorScheme.outlineVariant),
        ),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 40,
              decoration: BoxDecoration(
                color: statusColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      )),
                  const SizedBox(height: 2),
                  Text(place,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      )),
                ],
              ),
            ),
            Icon(Icons.network_cell,
                size: 18,
                color: signal == 0
                    ? theme.colorScheme.outline
                    : Colors.greenAccent.shade700),
            const SizedBox(width: 6),
            Icon(Icons.podcasts, size: 18, color: theme.colorScheme.primary),
          ],
        ),
      ),
    );
  }
}

class _AlertCard extends StatelessWidget {
  const _AlertCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    this.color,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final c = color ?? theme.colorScheme.onSurfaceVariant;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          Icon(icon, color: c),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    )),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    )),
              ],
            ),
          ),
          const Icon(Icons.chevron_right),
        ],
      ),
    );
  }
}

class _LiveDot extends StatelessWidget {
  const _LiveDot({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: Colors.green.withValues(
            alpha: .4,
          ),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // pulsing dot
          SizedBox(
            width: 10,
            height: 10,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(width: 6),
          Text(label,
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: Colors.green.shade800,
              )),
        ],
      ),
    );
  }
}

class _ChipButton extends StatelessWidget {
  const _ChipButton({
    required this.icon,
    required this.label,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: theme.colorScheme.outlineVariant),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: theme.colorScheme.onSurface),
            const SizedBox(width: 6),
            Text(label, style: theme.textTheme.labelLarge),
          ],
        ),
      ),
    );
  }
}

class _RoundFab extends StatelessWidget {
  const _RoundFab({required this.icon, required this.onPressed});
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return FloatingActionButton.small(
      onPressed: onPressed,
      heroTag: null,
      backgroundColor: theme.colorScheme.surface,
      shape: const CircleBorder(),
      child: Icon(icon, color: theme.colorScheme.onSurface),
    );
  }
}

class _RoundIcon extends StatelessWidget {
  const _RoundIcon({
    required this.icon,
    required this.onTap,
    required this.background,
  });

  final IconData icon;
  final VoidCallback onTap;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: onTap,
      radius: 24,
      child: Container(
        width: 40,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: background,
          shape: BoxShape.circle,
        ),
        child: Icon(icon),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.label, this.selected = false});
  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: selected
            ? theme.colorScheme.primary.withValues(
                alpha: .08,
              )
            : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: selected
              ? theme.colorScheme.primary.withValues(
                  alpha: .3,
                )
              : theme.colorScheme.outlineVariant,
        ),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelLarge?.copyWith(
          color: selected ? theme.colorScheme.primary : null,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _Grabber extends StatelessWidget {
  const _Grabber({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 4,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}
