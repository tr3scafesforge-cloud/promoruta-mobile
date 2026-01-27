import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:promoruta/core/constants/colors.dart';
import 'package:promoruta/core/models/campaign.dart';
import 'package:promoruta/features/advertiser/campaign_management/domain/use_cases/campaign_use_cases.dart';
import 'package:promoruta/gen/l10n/app_localizations.dart';
import 'package:promoruta/shared/shared.dart';

// Provider for nearby campaigns (first 15)
final nearbyCampaignsProvider =
    FutureProvider.autoDispose<List<Campaign>>((ref) async {
  final getCampaignsUseCase = ref.watch(getCampaignsUseCaseProvider);
  return await getCampaignsUseCase(const GetCampaignsParams(perPage: 15));
});

class PromoterHomePage extends StatelessWidget {
  const PromoterHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _PromoterHomeContent();
  }
}

class _PromoterHomeContent extends ConsumerWidget {
  const _PromoterHomeContent();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final kpiStatsAsync = ref.watch(promoterKpiStatsProvider);
    final nearbyCampaignsAsync = ref.watch(nearbyCampaignsProvider);
    final l10n = AppLocalizations.of(context);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      children: [
        // KPI cards
        Row(
          children: [
            Expanded(
              child: kpiStatsAsync.when(
                loading: () => StatCard(
                  icon: Icons.attach_money_rounded,
                  value: '--',
                  labelTop: l10n.thisWeekLabelTop,
                  labelBottom: l10n.thisWeekLabelBottom,
                  iconColor: AppColors.deepOrange,
                  backgroundColor: AppColors.deepOrange,
                ),
                error: (error, stack) => StatCard(
                  icon: Icons.attach_money_rounded,
                  value: '\$0',
                  labelTop: l10n.thisWeekLabelTop,
                  labelBottom: l10n.thisWeekLabelBottom,
                  iconColor: AppColors.deepOrange,
                  backgroundColor: AppColors.deepOrange,
                ),
                data: (kpiStats) => StatCard(
                  icon: Icons.attach_money_rounded,
                  value: '\$${kpiStats.thisWeekEarnings.toStringAsFixed(0)}',
                  labelTop: l10n.thisWeekLabelTop,
                  labelBottom: l10n.thisWeekLabelBottom,
                  iconColor: AppColors.deepOrange,
                  backgroundColor: AppColors.deepOrange.withValues(alpha: .2),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: kpiStatsAsync.when(
                loading: () => StatCard(
                  icon: Icons.trending_up_rounded,
                  value: '--',
                  labelTop: l10n.thisMonthLabelTop,
                  labelBottom: l10n.thisMonthLabelBottom,
                  iconColor: AppColors.completedGreenColor,
                  backgroundColor: AppColors.completedGreenColor,
                ),
                error: (error, stack) => StatCard(
                  icon: Icons.trending_up_rounded,
                  value: '\$0',
                  labelTop: l10n.thisMonthLabelTop,
                  labelBottom: l10n.thisMonthLabelBottom,
                  iconColor: AppColors.completedGreenColor,
                  backgroundColor: AppColors.completedGreenColor,
                ),
                data: (kpiStats) => StatCard(
                  icon: Icons.trending_up_rounded,
                  value: '\$${kpiStats.thisMonthEarnings.toStringAsFixed(0)}',
                  labelTop: l10n.thisMonthLabelTop,
                  labelBottom: l10n.thisMonthLabelBottom,
                  iconColor: AppColors.completedGreenColor,
                  backgroundColor:
                      AppColors.completedGreenColor.withValues(alpha: .2),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Section header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(AppLocalizations.of(context).nearbyCampaigns,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    )),
            TextButton(
              onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Ver Mapa (WIP)')),
              ),
              child: Text(AppLocalizations.of(context).viewMap),
            ),
          ],
        ),

        // Nearby campaign cards
        nearbyCampaignsAsync.when(
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: CircularProgressIndicator(),
            ),
          ),
          error: (error, stack) => Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Text(
                'Error loading campaigns: $error',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ),
          data: (campaigns) {
            if (campaigns.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Text(
                    l10n.noCampaignsFound,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                ),
              );
            }

            return Column(
              children: [
                for (int i = 0; i < campaigns.length; i++) ...[
                  _NearbyCampaignCard(campaign: campaigns[i]),
                  if (i < campaigns.length - 1) const SizedBox(height: 12),
                ],
              ],
            );
          },
        ),

        const SizedBox(height: 16),

        // Active campaign
        const _ActiveCampaignCard(),
      ],
    );
  }
}

class _NearbyCampaignCard extends StatelessWidget {
  final Campaign campaign;

  const _NearbyCampaignCard({
    required this.campaign,
  });

  static const Color _accent = Color(0xFFFF7A1A);

  @override
  Widget build(BuildContext context) {
    // Calculate duration estimate (placeholder - could be enhanced with routing API)
    final durationMinutes =
        (campaign.distance * 15).round(); // Rough estimate: 15 min per km

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
                  child: Icon(Icons.campaign_rounded, color: Colors.black87),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(campaign.title,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  )),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(Icons.near_me_rounded,
                              size: 16, color: Colors.grey[700]),
                          const SizedBox(width: 4),
                          Text(
                              'A ${campaign.distance.toStringAsFixed(1)}km de distancia',
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
                    Text('\$${campaign.suggestedPrice.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                            )),
                    Text('Estimado',
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
                _miniMetric(Icons.alt_route_rounded,
                    '${campaign.distance.toStringAsFixed(1)}km', 'Ruta'),
                _miniMetric(
                    Icons.timer_outlined, '$durationMinutes min', 'Duración'),
                _miniMetric(Icons.graphic_eq_rounded,
                    '${campaign.audioDuration}s', 'Audio'),
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
                        const SnackBar(
                            content: Text('Aceptar promoción (WIP)')),
                      );
                    },
                    child: Text(
                      AppLocalizations.of(context).acceptPromotion,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
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
                  style: const TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 13)),
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
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
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
