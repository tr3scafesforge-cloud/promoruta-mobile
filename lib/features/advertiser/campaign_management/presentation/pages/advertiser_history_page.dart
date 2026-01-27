import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:promoruta/core/core.dart';
import 'package:promoruta/gen/l10n/app_localizations.dart';
import '../models/campaign_ui.dart' as ui;
import '../../data/models/campaign_mappers.dart';
import 'package:promoruta/shared/widgets/advertiser_search_filter_bar.dart';
import 'package:promoruta/shared/shared.dart';
import 'package:intl/intl.dart';

class AdvertiserHistoryPage extends ConsumerStatefulWidget {
  const AdvertiserHistoryPage({super.key});

  @override
  ConsumerState<AdvertiserHistoryPage> createState() =>
      _AdvertiserHistoryPageState();
}

class _AdvertiserHistoryPageState extends ConsumerState<AdvertiserHistoryPage> {
  final TextEditingController _search = TextEditingController();

  /// 0=todas, 1=completadas, 2=canceladas, 3=expiradas
  int _selectedFilter = 0;

  List<ui.Campaign> get _filtered {
    final campaignsAsync = ref.watch(campaignsProvider);
    final q = _search.text.trim().toLowerCase();

    return campaignsAsync.maybeWhen(
      data: (campaigns) {
        Iterable<ui.Campaign> list = campaigns.map((c) => c.toUiModel());

        // filter by chip
        switch (_selectedFilter) {
          case 1:
            list = list.where((c) => c.status == ui.CampaignStatus.completed);
            break;
          case 2:
            list = list.where((c) => c.status == ui.CampaignStatus.canceled);
            break;
          case 3:
            list = list.where((c) => c.status == ui.CampaignStatus.expired);
            break;
          default:
            break; // todas
        }

        // filter by query
        if (q.isNotEmpty) {
          list = list.where((c) =>
              c.title.toLowerCase().contains(q) == true ||
              c.location.toLowerCase().contains(q) == true);
        }
        final result = list.toList();
        return result;
      },
      orElse: () {
        return <ui.Campaign>[];
      },
    );
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('d MMMM yyyy HH:mm', 'es');

    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: [
          // Search
          AdvertiserSearchFilterBar(
            controller: _search,
            hint: AppLocalizations.of(context).searchCampaigns,
            onChanged: (_) => setState(() {}),
            onFilterTap: () => _openBottomFilters(context),
          ),

          const SizedBox(height: 12),
          // Cards
          for (final c in _filtered)
            _CampaignCard(
              campaign: c,
              dateFormatted: df.format(c.dateTime!),
            ),
          if (_filtered.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 36),
              child: Center(
                child: Text(
                  AppLocalizations.of(context).noCampaignsFound,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _openBottomFilters(BuildContext context) {
    // temp selection used only inside the sheet
    int tempSelected =
        _selectedFilter; // 0=todos, 1=completada, 2=cancelada, 3=expirada

    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => StatefulBuilder(
        builder: (context, setModal) {
          return SizedBox(
            height: MediaQuery.of(context).size.height * 0.7,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text(AppLocalizations.of(context).status,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                            )),
                    const SizedBox(height: 12),

                    // 2x2 grid of options
                    GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        _StatusOptionCard(
                          label: AppLocalizations.of(context).completed,
                          icon: Icons.check_circle_outlined,
                          color: const Color(0xFF0F9D58), // green
                          selected: tempSelected == 1,
                          onTap: () => setModal(() => tempSelected = 1),
                        ),
                        _StatusOptionCard(
                          label: AppLocalizations.of(context).canceled,
                          icon: Icons.cancel_outlined,
                          color: const Color(0xFFD81B60), // magenta/red
                          selected: tempSelected == 2,
                          onTap: () => setModal(() => tempSelected = 2),
                        ),
                        _StatusOptionCard(
                          label: AppLocalizations.of(context).expired,
                          icon: Icons.access_time_outlined,
                          color: const Color(0xFF111827), // dark/gray
                          selected: tempSelected == 3,
                          onTap: () => setModal(() => tempSelected = 3),
                        ),
                        _StatusOptionCard(
                          label: AppLocalizations.of(context).all,
                          icon: Icons.all_inclusive,
                          color: const Color(
                              0xFF0FA4A3), // teal (filled look when selected)
                          filledOnSelect: true,
                          selected: tempSelected == 0,
                          onTap: () => setModal(() => tempSelected = 0),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Reset & Apply buttons
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.black87,
                          side: const BorderSide(color: Color(0xFFE5E7EB)),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: () => setModal(() => tempSelected = 0),
                        child: Text(
                          AppLocalizations.of(context).resetFilter,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF0FA4A3),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          // persist chosen value in the parent state
                          setState(() => _selectedFilter = tempSelected);
                        },
                        child: Text(
                          AppLocalizations.of(context).applyFilter,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _CampaignCard extends StatelessWidget {
  const _CampaignCard({
    required this.campaign,
    required this.dateFormatted,
  });

  final ui.Campaign campaign;
  final String dateFormatted;

  Color _statusColor(ThemeData theme) {
    switch (campaign.status) {
      case ui.CampaignStatus.completed:
        return AppColors.completedGreenColor;
      case ui.CampaignStatus.canceled:
        return AppColors.canceledRedColor;
      case ui.CampaignStatus.expired:
        return theme.brightness == Brightness.light
            ? AppColors.expiredColor
            : Colors.white;
      default:
        return Colors.grey;
    }
  }

  String _statusLabel(BuildContext context) {
    switch (campaign.status) {
      case ui.CampaignStatus.completed:
        return AppLocalizations.of(context).statusCompleted;
      case ui.CampaignStatus.canceled:
        return AppLocalizations.of(context).statusCanceled;
      case ui.CampaignStatus.expired:
        return AppLocalizations.of(context).statusExpired;
      default:
        return AppLocalizations.of(context).statusUnknown;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            blurRadius: 10,
            spreadRadius: -3,
            offset: const Offset(0, 2),
            color: theme.shadowColor.withValues(alpha: 0.13),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Left status stripe
            Container(
              width: 6,
              decoration: BoxDecoration(
                color: _statusColor(theme),
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(14),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title + status chip
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            campaign.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _statusColor(theme).withValues(
                              alpha: .12,
                            ),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.check_circle,
                                  size: 14, color: _statusColor(theme)),
                              const SizedBox(width: 4),
                              Text(
                                _statusLabel(context),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: _statusColor(theme),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    // Date + location
                    Row(
                      children: [
                        Icon(Icons.event,
                            size: 16,
                            color: theme.colorScheme.onSurfaceVariant),
                        const SizedBox(width: 6),
                        Text(dateFormatted,
                            style: TextStyle(
                                color: theme.colorScheme.onSurfaceVariant)),
                        const SizedBox(width: 12),
                        Icon(Icons.place_outlined,
                            size: 16,
                            color: theme.colorScheme.onSurfaceVariant),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            campaign.location,
                            style: TextStyle(
                                color: theme.colorScheme.onSurfaceVariant),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Metrics row
                    Row(
                      children: [
                        _Pill(
                            icon: Icons.near_me_outlined,
                            text: '${campaign.distanceKm}km'),
                        const SizedBox(width: 8),
                        _Pill(
                            icon: Icons.schedule,
                            text: '${campaign.durationSec}s'),
                        const SizedBox(width: 8),
                        _Pill(
                            icon: Icons.attach_money,
                            text: '\$${campaign.payUsd}'),
                        const SizedBox(width: 8),
                        _Pill(
                            icon: Icons.groups_outlined,
                            text: '${campaign.peopleNeeded}'),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // Actions
                    Align(
                      alignment: Alignment.centerLeft,
                      child: switch (campaign.status) {
                        ui.CampaignStatus.completed => _ActionButton(
                            label: AppLocalizations.of(context).viewReport,
                            color: const Color(0xFF31C48D),
                            onTap: () {},
                          ),
                        ui.CampaignStatus.canceled => _ActionButton(
                            label: AppLocalizations.of(context).duplicate,
                            color: const Color(0xFFE11D48),
                            onTap: () {},
                          ),
                        ui.CampaignStatus.expired => _ActionButton(
                            label: AppLocalizations.of(context).reactivate,
                            color: theme.brightness == Brightness.light
                                ? AppColors.expiredColor
                                : Colors.white,
                            onTap: () {},
                          ),
                        _ => const SizedBox.shrink(),
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: theme.colorScheme.onSurface),
          const SizedBox(width: 4),
          Text(text, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.color,
    required this.onTap,
  });

  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withValues(alpha: .1),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusOptionCard extends StatelessWidget {
  const _StatusOptionCard({
    required this.label,
    required this.icon,
    required this.color,
    required this.selected,
    required this.onTap,
    this.filledOnSelect = false,
  });

  final String label;
  final IconData icon;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  /// When true (use for "Todos"), the selected state shows a filled tile.
  final bool filledOnSelect;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(16);

    final bg = selected
        ? (filledOnSelect ? color : const Color(0xFFE6FFFA))
        : Colors.white;
    final fg =
        selected ? (filledOnSelect ? Colors.white : color) : Colors.black54;

    return Material(
      color: bg,
      borderRadius: borderRadius,
      child: InkWell(
        borderRadius: borderRadius,
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: borderRadius,
            border: Border.all(
              color:
                  selected && !filledOnSelect ? color : const Color(0xFFE5E7EB),
              width: selected && !filledOnSelect ? 2 : 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32, color: fg),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: fg,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
