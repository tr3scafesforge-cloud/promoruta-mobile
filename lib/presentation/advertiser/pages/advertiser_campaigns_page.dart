import 'package:flutter/material.dart';
import 'package:promoruta/core/core.dart';
import 'package:promoruta/shared/shared.dart';

enum CampaignStatus { all, active, pending, completed }

class Campaign {
  final String title;
  final String subtitle; // e.g., "2 Promotores activos"
  final String location;
  final double distanceKm;
  final int completionPct; // 0..100
  final int audioSeconds;
  final double budget; // $
  final String dateRange; // formatted for UI
  final CampaignStatus status;

  const Campaign({
    required this.title,
    required this.subtitle,
    required this.location,
    required this.distanceKm,
    required this.completionPct,
    required this.audioSeconds,
    required this.budget,
    required this.dateRange,
    required this.status,
  });
}

class AdvertiserCampaignsPage extends StatefulWidget {
  const AdvertiserCampaignsPage({super.key});

  @override
  State<AdvertiserCampaignsPage> createState() =>
      _AdvertiserCampaignsPageState();
}

class _AdvertiserCampaignsPageState extends State<AdvertiserCampaignsPage> {
  final TextEditingController _searchCtrl = TextEditingController();
  CampaignStatus _selected = CampaignStatus.all;

  // Simple "extra filters" example – extend as you need
  double? _maxDistanceKm; // null = disabled
  double? _minBudget;

  static const _statuses = [
    CampaignStatus.all,
    CampaignStatus.active,
    CampaignStatus.pending,
    CampaignStatus.completed,
  ];
  final List<Campaign> _all = const [
    Campaign(
      title: 'Promoción Cafetería',
      subtitle: '2 Promotores activos',
      location: 'Punta Carretas',
      distanceKm: 2.4,
      completionPct: 68,
      audioSeconds: 45,
      budget: 48.20,
      dateRange: '2025-01-01 - 2025-01-02',
      status: CampaignStatus.active,
    ),
    Campaign(
      title: 'Apertura Tienda',
      subtitle: 'Promotores pendientes',
      location: 'Nuevo Centro',
      distanceKm: 2.4,
      completionPct: 0,
      audioSeconds: 45,
      budget: 2000.00,
      dateRange: '2025-01-01 - 2025-01-02',
      status: CampaignStatus.pending,
    ),
    Campaign(
      title: 'Promoción Agua',
      subtitle: 'Montevideo Shopping',
      location: 'Montevideo Shopping',
      distanceKm: 2.4,
      completionPct: 100,
      audioSeconds: 30,
      budget: 100.00,
      dateRange: '2025-01-01 - 2025-01-02',
      status: CampaignStatus.completed,
    ),
  ];

  List<Campaign> get _filtered {
    final q = _searchCtrl.text.trim().toLowerCase();

    return _all.where((c) {
      final byStatus = _selected == CampaignStatus.all || c.status == _selected;
      final bySearch = q.isEmpty ||
          c.title.toLowerCase().contains(q) ||
          c.location.toLowerCase().contains(q) ||
          c.subtitle.toLowerCase().contains(q);
      final byDistance =
          _maxDistanceKm == null || c.distanceKm <= _maxDistanceKm!;
      final byBudget = _minBudget == null || c.budget >= _minBudget!;
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

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          _SearchAndFilterBar(
            controller: _searchCtrl,
            onChanged: (_) => setState(() {}),
            onClear: () {
              _searchCtrl.clear();
              setState(() {});
            },
            onOpenFilters: _openFiltersSheet,
          ),
          const SizedBox(height: 12),
          MultiSwitch(
            options: const ['Todas', 'Activas', 'Pendientes', 'Completadas'],
            initialIndex: _statuses.indexOf(_selected),
            backgroundColor: AppColors.grayDarkStroke.withValues(alpha: .70),
            onChanged: (index) => setState(() => _selected = _statuses[index]),
          ),
          if (_hasAnyExtraFilter)
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
          ..._filtered.map((c) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _CampaignCard(campaign: c),
              )),
          if (_filtered.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 48),
              child: Center(
                child: Text(
                  'No hay campañas para los filtros seleccionados.',
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: Colors.grey[700]),
                ),
              ),
            ),
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

/// ————— Search + filter bar —————
class _SearchAndFilterBar extends StatelessWidget {
  const _SearchAndFilterBar({
    required this.controller,
    required this.onChanged,
    required this.onClear,
    required this.onOpenFilters,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;
  final VoidCallback onOpenFilters;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE7EBF0)),
            ),
            child: Row(
              children: [
                const SizedBox(width: 12),
                const Icon(Icons.search, size: 20, color: Colors.black54),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: controller,
                    onChanged: onChanged,
                    decoration: const InputDecoration(
                      hintText: 'Buscar campañas',
                      border: InputBorder.none,
                    ),
                  ),
                ),
                if (controller.text.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: onClear,
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        IconButton.filled(
          onPressed: onOpenFilters,
          style: IconButton.styleFrom(
            backgroundColor: Colors.white,
            side: const BorderSide(color: Color(0xFFE7EBF0)),
          ),
          icon: const Icon(Icons.filter_alt_outlined, color: Colors.black87),
          tooltip: 'Filtros',
        ),
      ],
    );
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
          child: const Text('Limpiar'),
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
  final Campaign campaign;

  @override
  Widget build(BuildContext context) {
    final badge = switch (campaign.status) {
      CampaignStatus.active =>
        _StatusBadge(text: 'Activa', color: const Color(0xFF11A192)),
      CampaignStatus.pending =>
        _StatusBadge(text: 'Pendiente', color: const Color(0xFFF6A723)),
      CampaignStatus.completed =>
        _StatusBadge(text: 'Completada', color: const Color(0xFF8893A2)),
      CampaignStatus.all => const SizedBox.shrink(),
    };

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE7EBF0)),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
              blurRadius: 6, color: Color(0x0F000000), offset: Offset(0, 2))
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
              campaign.subtitle,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Colors.grey[700]),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.place, size: 16, color: Colors.black54),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    campaign.location,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: Colors.black87),
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.calendar_today,
                    size: 16, color: Colors.black54),
                const SizedBox(width: 6),
                Text(
                  campaign.dateRange,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: Colors.black87),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _StatTile(
                    value: '${campaign.distanceKm.toStringAsFixed(1)}km',
                    label: 'Ruta'),
                _StatTile(
                    value: '${campaign.completionPct}%', label: 'Completado'),
                _StatTile(value: '${campaign.audioSeconds}s', label: 'Audio'),
                _StatTile(
                    value: '\$${campaign.budget.toStringAsFixed(2)}',
                    label: 'Presupuesto'),
              ],
            ),
          ],
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
    return SizedBox(
      width: 74,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
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
        color: color.withOpacity(0.12),
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
                TextButton(onPressed: onClear, child: const Text('Limpiar')),
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
