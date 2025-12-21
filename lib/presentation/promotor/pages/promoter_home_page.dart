import 'package:flutter/material.dart';
import 'package:promoruta/core/constants/colors.dart';
import 'package:promoruta/gen/l10n/app_localizations.dart';

class PromoterHomePage extends StatelessWidget {
  const PromoterHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _PromoterHomeContent();
  }
}

class _PromoterHomeContent extends StatelessWidget {
  const _PromoterHomeContent();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      children: [
        // KPI cards
        Row(
          children: const [
            Expanded(
              child: _KpiCard(
                icon: Icons.attach_money_rounded,
                value: '\$284',
                top: 'Esta',
                bottom: 'semana',
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _KpiCard(
                icon: Icons.trending_up_rounded,
                value: '\$320',
                top: 'Este',
                bottom: 'mes',
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Section header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Campañas cerca tuyo',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    )),
            TextButton(
              onPressed: () =>
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Ver Mapa (WIP)')),
                  ),
              child: const Text('Ver Mapa'),
            ),
          ],
        ),

        // Nearby campaign cards
        const _NearbyCampaignCard(
          title: 'Promoción Cafetería Centro',
          amountRight: '\$18.00',
          amountRightSub: 'Estimado',
          distance: '1.4km',
          duration: '35 min',
          audio: '45s',
        ),
        const SizedBox(height: 12),
        const _NearbyCampaignCard(
          title: 'Promoción Cafetería',
          amountRight: '\$48.20',
          amountRightSub: 'Estimado',
          distance: '2.4km',
          duration: '35 min',
          audio: '45s',
        ),

        const SizedBox(height: 16),

        // Active campaign
        const _ActiveCampaignCard(),
      ],
    );
  }
}

class _KpiCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String top;
  final String bottom;

  const _KpiCard({
    required this.icon,
    required this.value,
    required this.top,
    required this.bottom,
  });

  static const Color _pill = Color(0xFFEFF7F5);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: _pill,
              child: Icon(icon, color: AppColors.primary),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 2),
            Text(top,
                style: Theme.of(context)
                    .textTheme
                    .labelMedium
                    ?.copyWith(color: Colors.grey[700])),
            Text(bottom,
                style: Theme.of(context)
                    .textTheme
                    .labelMedium
                    ?.copyWith(color: Colors.grey[700])),
          ],
        ),
      ),
    );
  }
}

class _NearbyCampaignCard extends StatelessWidget {
  final String title;
  final String amountRight;
  final String amountRightSub;
  final String distance;
  final String duration;
  final String audio;

  const _NearbyCampaignCard({
    required this.title,
    required this.amountRight,
    required this.amountRightSub,
    required this.distance,
    required this.duration,
    required this.audio,
  });

  static const Color _accent = Color(0xFFFF7A1A);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            // Header
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(
                  radius: 18,
                  backgroundColor: Color(0xFFEFF7F5),
                  child: Icon(Icons.local_cafe_rounded, color: Colors.black87),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              )),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(Icons.near_me_rounded,
                              size: 16, color: Colors.grey[700]),
                          const SizedBox(width: 4),
                          Text('A 0.8km de distancia',
                              style: Theme.of(context)
                                  .textTheme
                                  .labelMedium
                                  ?.copyWith(color: Colors.grey[700])),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(amountRight,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                            )),
                    Text(amountRightSub,
                        style: Theme.of(context)
                            .textTheme
                            .labelSmall
                            ?.copyWith(color: Colors.grey[700])),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Metrics
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _miniMetric(Icons.alt_route_rounded, distance, 'Ruta'),
                _miniMetric(Icons.timer_outlined, duration, 'Duración'),
                _miniMetric(Icons.graphic_eq_rounded, audio, 'Audio'),
              ],
            ),
            const SizedBox(height: 12),
            // Actions
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black87,
                      elevation: 0,
                      side: BorderSide(color: Colors.grey[300]!),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Preview (WIP)')),
                      );
                    },
                    child: Text(AppLocalizations.of(context).preview),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _accent,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Aceptar promoción (WIP)')),
                      );
                    },
                    child: Text(AppLocalizations.of(context).acceptPromotion),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _miniMetric(IconData icon, String value, String label) {
    return Expanded(
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey[700]),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
              Text(label,
                  style: TextStyle(color: Colors.grey[700], fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActiveCampaignCard extends StatelessWidget {
  const _ActiveCampaignCard();

  static const Color _accent = Color(0xFFFF7A1A);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                const CircleAvatar(
                  radius: 18,
                  backgroundColor: Color(0xFFE9F7EF),
                  child: Icon(Icons.play_arrow_rounded, color: Colors.green),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Campaña Activa',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              )),
                      Text('Especial de almuerzo del restaurante',
                          style: Theme.of(context)
                              .textTheme
                              .labelMedium
                              ?.copyWith(color: Colors.grey[700])),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('\$18.20',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                            )),
                    Text('Ganancias',
                        style: Theme.of(context)
                            .textTheme
                            .labelSmall
                            ?.copyWith(color: Colors.grey[700])),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Progress label
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('75% para completar la ruta',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: _accent,
                          fontWeight: FontWeight.w700,
                        )),
                Text('1.6/2.1km',
                    style: Theme.of(context)
                        .textTheme
                        .labelMedium
                        ?.copyWith(color: Colors.grey[700])),
              ],
            ),
            const SizedBox(height: 8),
            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: 0.75,
                minHeight: 10,
                backgroundColor: const Color(0xFFEDEDED),
                color: _accent,
              ),
            ),
            const SizedBox(height: 14),
            // CTA
            SizedBox(
              height: 44,
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _accent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Continuar ruta (WIP)')),
                  );
                },
                child: const Text('Continuar Ruta'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}