import 'package:flutter/material.dart';
import 'package:promoruta/gen/l10n/app_localizations.dart';

class AdvertiserLivePage extends StatelessWidget {
  const AdvertiserLivePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF3F5F7),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _TopTabs(
                currentIndex: 1, // 0: Promotores Activos, 1: Live Map, 2: Alertas
                onTap: (i) {
                  // hook these up to your navigation / router
                  // e.g. context.go('/advertiser/active_promoters');
                },
                labels: [
                  'Promotores Activos', // “Promotores Activos”
                  'Live Map',
                  '“Alertas”', // “Alertas”
                ],
              ),
              const SizedBox(height: 16),
              _LiveCard(title: '📍 Localización en tiempo real'),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopTabs extends StatelessWidget {
  const _TopTabs({
    required this.currentIndex,
    required this.labels,
    this.onTap,
  });

  final int currentIndex;
  final List<String> labels;
  final ValueChanged<int>? onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(labels.length, (i) {
        final selected = i == currentIndex;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: i < labels.length - 1 ? 8 : 0),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => onTap?.call(i),
              child: Container(
                height: 38,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selected ? Colors.white : const Color(0xFFE9EDF1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: selected ? const Color(0xFFCBD5E1) : Colors.transparent,
                  ),
                  boxShadow: selected
                      ? [
                          BoxShadow(
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                            color: Colors.black.withOpacity(0.04),
                          )
                        ]
                      : null,
                ),
                child: Text(
                  labels[i],
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _LiveCard extends StatelessWidget {
  const _LiveCard({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(12);
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: borderRadius),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Row(
              children: [
                const Icon(Icons.place_outlined, size: 18, color: Colors.black87),
                const SizedBox(width: 6),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Map placeholder (swap with GoogleMap later)
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: const Color(0xFFF6F8FA),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: const _MapPlaceholder(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MapPlaceholder extends StatelessWidget {
  const _MapPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.location_on_outlined, size: 44, color: Colors.black54),
          const SizedBox(height: 8),
          Text(
            'Map Location in real time',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.black54,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ],
      ),
    );
  }
}
