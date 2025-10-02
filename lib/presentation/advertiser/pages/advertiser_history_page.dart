import 'package:flutter/material.dart';
import 'package:promoruta/gen/l10n/app_localizations.dart';
import 'package:intl/intl.dart';

enum CampaignStatus { completed, canceled, expired }

class Campaign {
  final String title;
  final DateTime dateTime;
  final String location;
  final double distanceKm;
  final int durationSec;
  final int payUsd;
  final int peopleNeeded;
  final CampaignStatus status;

  const Campaign({
    required this.title,
    required this.dateTime,
    required this.location,
    required this.distanceKm,
    required this.durationSec,
    required this.payUsd,
    required this.peopleNeeded,
    required this.status,
  });
}

class AdvertiserHistoryPage extends StatefulWidget {
  const AdvertiserHistoryPage({super.key});

  @override
  State<AdvertiserHistoryPage> createState() => _AdvertiserHistoryPageState();
}

class _AdvertiserHistoryPageState extends State<AdvertiserHistoryPage> {
  final TextEditingController _search = TextEditingController();

  /// 0=todas, 1=completadas, 2=canceladas, 3=expiradas
  int _selectedFilter = 0;

  final _data = <Campaign>[
    Campaign(
      title: 'Promoción Agua',
      dateTime: DateTime(2025, 1, 1, 10, 50),
      location: 'Montevideo Shopping',
      distanceKm: 2.4,
      durationSec: 30,
      payUsd: 100,
      peopleNeeded: 100,
      status: CampaignStatus.completed,
    ),
    Campaign(
      title: 'Promoción Agua II',
      dateTime: DateTime(2025, 1, 1, 14, 50),
      location: 'Montevideo Shopping',
      distanceKm: 2.4,
      durationSec: 30,
      payUsd: 100,
      peopleNeeded: 0,
      status: CampaignStatus.canceled,
    ),
    Campaign(
      title: 'Promoción Agua III',
      dateTime: DateTime(2025, 1, 1, 9, 50),
      location: 'Montevideo Shopping',
      distanceKm: 2.4,
      durationSec: 30,
      payUsd: 100,
      peopleNeeded: 0,
      status: CampaignStatus.expired,
    ),
  ];

  List<Campaign> get _filtered {
    final q = _search.text.trim().toLowerCase();
    Iterable<Campaign> list = _data;

    // filter by chip
    switch (_selectedFilter) {
      case 1:
        list = list.where((c) => c.status == CampaignStatus.completed);
        break;
      case 2:
        list = list.where((c) => c.status == CampaignStatus.canceled);
        break;
      case 3:
        list = list.where((c) => c.status == CampaignStatus.expired);
        break;
      default:
        break; // todas
    }

    // filter by query
    if (q.isNotEmpty) {
      list = list.where((c) =>
          c.title.toLowerCase().contains(q) ||
          c.location.toLowerCase().contains(q));
    }
    return list.toList();
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
      color: const Color(0xFFF3F5F7),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: [
          // Search
          _SearchField(
            controller: _search,
            hint: 'Buscar campañas',
            onChanged: (_) => setState(() {}),
            onFilterTap: () => _openBottomFilters(context),
          ),

          const SizedBox(height: 12),
          // Cards
          for (final c in _filtered)
            _CampaignCard(
              campaign: c,
              dateFormatted: df.format(c.dateTime),
            ),
          if (_filtered.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 36),
              child: Center(
                child: Text(
                  'No se encontraron campañas',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: Colors.black54),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _openBottomFilters(BuildContext context) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => StatefulBuilder(
        builder: (context, setModal) => Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    Navigator.pop(context);
                    setState(() {}); // apply
                  },
                  child: const Text('Aplicar filtros'),
                ),
              ),
              TextButton(
                onPressed: () {
                  setModal(() => _selectedFilter = 0);
                },
                child: const Text('Limpiar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// --- UI PARTS ---

class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.controller,
    required this.hint,
    required this.onChanged,
    required this.onFilterTap,
  });

  final TextEditingController controller;
  final String hint;
  final ValueChanged<String> onChanged;
  final VoidCallback onFilterTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              boxShadow: const [
                BoxShadow(
                  blurRadius: 8,
                  spreadRadius: -2,
                  offset: Offset(0, 2),
                  color: Color(0x22000000),
                ),
              ],
            ),
            child: Row(
              children: [
                const SizedBox(width: 12),
                const Icon(Icons.search, size: 20, color: Colors.black45),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: controller,
                    onChanged: onChanged,
                    decoration: InputDecoration(
                      hintText: hint,
                      border: InputBorder.none,
                      isDense: true,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        Ink(
          decoration: const ShapeDecoration(
            color: Colors.white,
            shape: CircleBorder(),
            shadows: [
              BoxShadow(
                blurRadius: 8,
                spreadRadius: -2,
                offset: Offset(0, 2),
                color: Color(0x22000000),
              ),
            ],
          ),
          child: IconButton(
            onPressed: onFilterTap,
            icon: const Icon(Icons.tune),
          ),
        ),
      ],
    );
  }
}

class _CampaignCard extends StatelessWidget {
  const _CampaignCard({
    required this.campaign,
    required this.dateFormatted,
  });

  final Campaign campaign;
  final String dateFormatted;

  Color get _statusColor {
    switch (campaign.status) {
      case CampaignStatus.completed:
        return const Color(0xFF31C48D);
      case CampaignStatus.canceled:
        return const Color(0xFFE11D48);
      case CampaignStatus.expired:
        return const Color(0xFF9CA3AF);
    }
  }

  String get _statusLabel {
    switch (campaign.status) {
      case CampaignStatus.completed:
        return 'Completada';
      case CampaignStatus.canceled:
        return 'Cancelada';
      case CampaignStatus.expired:
        return 'Expirada';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            blurRadius: 10,
            spreadRadius: -3,
            offset: Offset(0, 2),
            color: Color(0x22000000),
          ),
        ],
      ),
      child: Row(
        children: [
          // Left status stripe
          Container(
            width: 6,
            height: 118,
            decoration: BoxDecoration(
              color: _statusColor,
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
                          color: _statusColor.withOpacity(.12),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.check_circle, size: 14),
                            const SizedBox(width: 4),
                            Text(
                              _statusLabel,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: _statusColor,
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
                      const Icon(Icons.event, size: 16, color: Colors.black54),
                      const SizedBox(width: 6),
                      Text(dateFormatted,
                          style: const TextStyle(color: Colors.black54)),
                      const SizedBox(width: 12),
                      const Icon(Icons.place_outlined,
                          size: 16, color: Colors.black54),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          campaign.location,
                          style: const TextStyle(color: Colors.black54),
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
                      CampaignStatus.completed => _ActionButton(
                          label: 'Ver Reporte',
                          color: const Color(0xFF31C48D),
                          onTap: () {},
                        ),
                      CampaignStatus.canceled => _ActionButton(
                          label: 'Duplicar',
                          color: const Color(0xFFE11D48),
                          onTap: () {},
                        ),
                      CampaignStatus.expired => _ActionButton(
                          label: 'Reactivar',
                          color: const Color(0xFF111827),
                          onTap: () {},
                        ),
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.black87),
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
      color: color.withOpacity(.1),
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
