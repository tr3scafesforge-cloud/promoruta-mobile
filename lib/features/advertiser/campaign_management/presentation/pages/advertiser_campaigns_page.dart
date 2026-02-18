import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:promoruta/core/constants/colors.dart';
import 'package:promoruta/gen/l10n/app_localizations.dart';
import 'package:promoruta/shared/shared.dart';
import 'package:promoruta/app/routes/app_router.dart';
import '../models/campaign_ui.dart' as ui;
import 'package:promoruta/shared/widgets/advertiser_search_filter_bar.dart';
import 'package:promoruta/core/models/campaign.dart' as backend;

class AdvertiserCampaignsPage extends ConsumerStatefulWidget {
  const AdvertiserCampaignsPage({super.key});

  @override
  ConsumerState<AdvertiserCampaignsPage> createState() =>
      _AdvertiserCampaignsPageState();
}

class _AdvertiserCampaignsPageState
    extends ConsumerState<AdvertiserCampaignsPage> {
  final TextEditingController _searchCtrl = TextEditingController();
  ui.CampaignStatus _selected = ui.CampaignStatus.all;

  // Simple "extra filters" example – extend as you need
  double? _maxDistanceKm; // null = disabled
  double? _minBudget;

  static const _statuses = [
    ui.CampaignStatus.all,
    ui.CampaignStatus.active,
    ui.CampaignStatus.pending,
    ui.CampaignStatus.completed,
  ];

  @override
  void initState() {
    super.initState();
    // Load all campaigns on init (no status filter)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(campaignsProvider.notifier).loadCampaigns();
    });
  }

  List<ui.Campaign> _getFilteredCampaigns(
      List<backend.Campaign> backendCampaigns) {
    final q = _searchCtrl.text.trim().toLowerCase();

    // Convert backend campaigns to UI campaigns
    final uiCampaigns =
        backendCampaigns.map((bc) => ui.Campaign.fromBackend(bc)).toList();

    return uiCampaigns.where((c) {
      final byStatus =
          _selected == ui.CampaignStatus.all || c.status == _selected;
      final bySearch = q.isEmpty ||
          c.title.toLowerCase().contains(q) ||
          c.location.toLowerCase().contains(q) ||
          (c.subtitle?.toLowerCase().contains(q) ?? false);
      final byDistance =
          _maxDistanceKm == null || c.distanceKm <= _maxDistanceKm!;
      final byBudget =
          _minBudget == null || (c.budget != null && c.budget! >= _minBudget!);
      return byStatus && bySearch && byDistance && byBudget;
    }).toList();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final campaignsAsync = ref.watch(campaignsProvider);
    final isLoading = campaignsAsync.isLoading;

    final backendCampaigns = campaignsAsync.valueOrNull ?? [];
    final filtered =
        isLoading ? <ui.Campaign>[] : _getFilteredCampaigns(backendCampaigns);
    final l10n = AppLocalizations.of(context);
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          IgnorePointer(
            ignoring: isLoading,
            child: Opacity(
              opacity: isLoading ? 0.5 : 1.0,
              child: AdvertiserSearchFilterBar(
                controller: _searchCtrl,
                hint: AppLocalizations.of(context).searchCampaigns,
                onChanged: (_) => setState(() {}),
                onClear: () {
                  _searchCtrl.clear();
                  setState(() {});
                },
                onFilterTap: _openFiltersSheet,
              ),
            ),
          ),
          const SizedBox(height: 12),
          IgnorePointer(
            ignoring: isLoading,
            child: Opacity(
              opacity: isLoading ? 0.5 : 1.0,
              child: MultiSwitch(
                options: [
                  l10n.campaignFilterAll,
                  l10n.campaignFilterActive,
                  l10n.campaignFilterPending,
                  l10n.campaignFilterCompleted,
                ],
                initialIndex: _statuses.indexOf(_selected),
                onChanged: (index) =>
                    setState(() => _selected = _statuses[index]),
              ),
            ),
          ),
          if (_hasAnyExtraFilter && !isLoading)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: _ActiveFiltersBar(
                maxDistanceKm: _maxDistanceKm,
                minBudget: _minBudget,
                onClearAll: () {
                  setState(() {
                    _maxDistanceKm = null;
                    _minBudget = null;
                  });
                },
              ),
            ),
          const SizedBox(height: 10),
          if (isLoading)
            const Padding(
              padding: EdgeInsets.only(top: 100),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (campaignsAsync.hasError)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 48),
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    l10n.errorLoadingCampaigns,
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    campaignsAsync.error.toString(),
                    style: theme.textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () =>
                        ref.read(campaignsProvider.notifier).loadCampaigns(),
                    child: Text(l10n.retry),
                  ),
                ],
              ),
            )
          else ...[
            ...filtered.map((c) => AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder:
                      (Widget child, Animation<double> animation) =>
                          SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.1),
                      end: Offset.zero,
                    ).animate(animation),
                    child: FadeTransition(
                      opacity: animation,
                      child: child,
                    ),
                  ),
                  child: Padding(
                    key: ValueKey(c.id),
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _CampaignCard(campaign: c),
                  ),
                )),
            if (filtered.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 48),
                child: Center(
                  child: Text(
                    AppLocalizations.of(context).noCampaignsForSelectedFilters,
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(color: Colors.grey[700]),
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }

  bool get _hasAnyExtraFilter => _maxDistanceKm != null || _minBudget != null;

  Future<void> _openFiltersSheet() async {
    final result = await showModalBottomSheet<_FilterResult>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Colors.white,
      builder: (context) {
        return _FiltersSheet(
          initialMaxDistance: _maxDistanceKm,
          initialMinBudget: _minBudget,
        );
      },
    );

    if (result != null) {
      setState(() {
        _maxDistanceKm = result.maxDistanceKm;
        _minBudget = result.minBudget;
      });
    }
  }
}

/// ————— Active filters summary bar —————
class _ActiveFiltersBar extends StatelessWidget {
  const _ActiveFiltersBar({
    required this.maxDistanceKm,
    required this.minBudget,
    required this.onClearAll,
  });

  final double? maxDistanceKm;
  final double? minBudget;
  final VoidCallback onClearAll;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final chips = <Widget>[];

    if (maxDistanceKm != null) {
      chips.add(_SmallFilterChip(
        label: '≤ ${maxDistanceKm!.toStringAsFixed(1)} km',
      ));
    }
    if (minBudget != null) {
      chips.add(_SmallFilterChip(
        label: '≥ \$${minBudget!.toStringAsFixed(0)}',
      ));
    }

    return Row(
      children: [
        Wrap(spacing: 6, runSpacing: 6, children: chips),
        const Spacer(),
        TextButton(
          onPressed: onClearAll,
          child: Text(l10n.clear),
        ),
      ],
    );
  }
}

class _SmallFilterChip extends StatelessWidget {
  const _SmallFilterChip({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label),
      visualDensity: VisualDensity.compact,
      side: const BorderSide(color: Color(0xFFDCE3EA)),
      backgroundColor: Colors.white,
    );
  }
}

/// ————— Campaign card —————
class _CampaignCard extends StatelessWidget {
  const _CampaignCard({required this.campaign});
  final ui.Campaign campaign;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final badge = switch (campaign.status) {
      ui.CampaignStatus.active => _StatusBadge(
          text: l10n.nActive(0), color: AppColors.activeCampaignColor),
      ui.CampaignStatus.pending =>
        _StatusBadge(text: l10n.pending, color: AppColors.pendingOrangeColor),
      ui.CampaignStatus.completed => _StatusBadge(
          text: l10n.statusCompleted, color: AppColors.completedGreenColor),
      ui.CampaignStatus.canceled =>
        _StatusBadge(text: l10n.cancelled, color: Colors.red),
      ui.CampaignStatus.all => const SizedBox.shrink(),
      _ => const SizedBox.shrink(),
    };

    return GestureDetector(
      onTap: () {
        CampaignDetailsRoute(campaignId: campaign.id).push(context);
      },
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          border: Border.all(color: theme.colorScheme.outline),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                blurRadius: 6,
                color: theme.shadowColor.withValues(alpha: 0.06),
                offset: const Offset(0, 2))
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title + badge
              Row(
                children: [
                  Expanded(
                    child: Text(
                      campaign.title,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ),
                  badge,
                ],
              ),
              const SizedBox(height: 2),
              Text(
                campaign.subtitle ?? '',
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.place,
                      size: 16, color: theme.colorScheme.onSurfaceVariant),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      campaign.location,
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: theme.colorScheme.onSurface),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.calendar_today,
                      size: 16, color: theme.colorScheme.onSurfaceVariant),
                  const SizedBox(width: 6),
                  Text(
                    campaign.dateRange ?? '',
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: theme.colorScheme.onSurface),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _StatTile(
                      value: '${campaign.distanceKm.toStringAsFixed(1)}km',
                      label: l10n.route),
                  _StatTile(
                      value: '${campaign.completionPct}%', label: l10n.completed),
                  // _StatTile(value: '${campaign.audioSeconds}s', label: 'Audio'),
                  _StatTile(
                      value:
                          '\$${campaign.budget?.toStringAsFixed(2) ?? '0.00'}',
                      label: l10n.budget),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: 74,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 2),
          Text(label,
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.text, required this.color});
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

/// ————— Filters bottom sheet —————
class _FilterResult {
  final double? maxDistanceKm;
  final double? minBudget;
  const _FilterResult({this.maxDistanceKm, this.minBudget});
}

class _FiltersSheet extends StatefulWidget {
  const _FiltersSheet({this.initialMaxDistance, this.initialMinBudget});
  final double? initialMaxDistance;
  final double? initialMinBudget;

  @override
  State<_FiltersSheet> createState() => _FiltersSheetState();
}

class _FiltersSheetState extends State<_FiltersSheet> {
  double? _maxDistance;
  double? _minBudget;

  @override
  void initState() {
    super.initState();
    _maxDistance = widget.initialMaxDistance;
    _minBudget = widget.initialMinBudget;
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 8, 16, bottom + 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Filtros',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          _SliderTile(
            title: 'Distancia máxima (km)',
            value: _maxDistance?.toDouble(),
            min: 0,
            max: 10,
            divisions: 20,
            unitBuilder: (v) => '${v.toStringAsFixed(1)} km',
            onChanged: (v) => setState(() => _maxDistance = v),
            onClear: () => setState(() => _maxDistance = null),
          ),
          const SizedBox(height: 8),
          _SliderTile(
            title: 'Presupuesto mínimo (\$)',
            value: _minBudget?.toDouble(),
            min: 0,
            max: 3000,
            divisions: 30,
            unitBuilder: (v) => '\$${v.toStringAsFixed(0)}',
            onChanged: (v) => setState(() => _minBudget = v),
            onClear: () => setState(() => _minBudget = null),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: () => Navigator.pop(
                    context,
                    _FilterResult(
                        maxDistanceKm: _maxDistance, minBudget: _minBudget),
                  ),
                  style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF11A192)),
                  child: const Text('Aplicar'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _SliderTile extends StatelessWidget {
  const _SliderTile({
    required this.title,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.unitBuilder,
    required this.onChanged,
    required this.onClear,
  });

  final String title;
  final double? value;
  final double min;
  final double max;
  final int divisions;
  final String Function(double) unitBuilder;
  final ValueChanged<double?> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F9FB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5EBF1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                  child: Text(title,
                      style: const TextStyle(fontWeight: FontWeight.w600))),
              if (value != null)
                TextButton(onPressed: onClear, child: Text(l10n.clear)),
            ],
          ),
          if (value == null)
            Row(
              children: [
                const Icon(Icons.info_outline, size: 16),
                const SizedBox(width: 6),
                Text('Sin límite', style: TextStyle(color: Colors.grey[700])),
              ],
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Slider(
                  value: value!.clamp(min, max),
                  min: min,
                  max: max,
                  divisions: divisions,
                  label: unitBuilder(value!.clamp(min, max)),
                  onChanged: (v) => onChanged(v),
                ),
                Text(unitBuilder(value!.clamp(min, max))),
              ],
            ),
          if (value == null)
            Slider(
              value: min,
              min: min,
              max: max,
              divisions: divisions,
              onChanged: (v) => onChanged(v),
            ),
        ],
      ),
    );
  }
}
