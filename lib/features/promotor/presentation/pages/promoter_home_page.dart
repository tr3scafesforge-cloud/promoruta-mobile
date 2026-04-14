import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:promoruta/core/constants/colors.dart';
import 'package:promoruta/core/models/campaign.dart';
import 'package:promoruta/core/models/campaign_query_params.dart';
import 'package:promoruta/features/promotor/campaign_browsing/presentation/pages/promoter_campaign_details_page.dart';
import 'package:promoruta/gen/l10n/app_localizations.dart';
import 'package:promoruta/shared/shared.dart';

final promoterHomeLatestCampaignsProvider =
    FutureProvider.autoDispose<List<Campaign>>((ref) async {
  final getCampaignsUseCase = ref.watch(getCampaignsUseCaseProvider);
  final campaigns = await getCampaignsUseCase(const CampaignQueryParams(
    perPage: 15,
    sortBy: 'created_at',
    sortOrder: 'desc',
  ));

  return campaigns
      .where(
        (campaign) =>
            campaign.status == CampaignStatus.pending ||
            campaign.status == CampaignStatus.created,
      )
      .take(3)
      .toList();
});

class PromoterHomePage extends ConsumerWidget {
  const PromoterHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const _PromoterHomeContent();
  }
}

class _PromoterHomeContent extends ConsumerWidget {
  const _PromoterHomeContent();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final latestCampaignsAsync = ref.watch(promoterHomeLatestCampaignsProvider);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      children: [
        Row(
          children: [
            Expanded(
              child: StatCard(
                icon: Icons.attach_money_rounded,
                value: '\$284',
                labelTop: 'Esta',
                labelBottom: 'semana',
                iconColor: AppColors.deepOrange,
                backgroundColor: AppColors.deepOrange.withValues(alpha: .1),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatCard(
                icon: Icons.trending_up_rounded,
                value: '\$320',
                labelTop: 'Este',
                labelBottom: 'mes',
                iconColor: AppColors.green,
                backgroundColor: AppColors.green.withValues(alpha: .1),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.nearbyCampaignsTitle,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            TextButton(
              onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${l10n.viewOnMap} (WIP)')),
              ),
              child: Text(l10n.viewOnMap),
            ),
          ],
        ),
        latestCampaignsAsync.when(
          loading: () => const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (error, stack) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Text(
              l10n.noCampaignsFound,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ),
          data: (campaigns) {
            if (campaigns.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Text(
                  l10n.noCampaignsFound,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
              );
            }

            return Column(
              children: campaigns.asMap().entries.map((entry) {
                return Padding(
                  padding: EdgeInsets.only(
                    bottom: entry.key < campaigns.length - 1 ? 12 : 0,
                  ),
                  child: _NearbyCampaignCard(campaign: entry.value),
                );
              }).toList(),
            );
          },
        ),
        const SizedBox(height: 16),
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final durationMinutes =
        campaign.endTime.difference(campaign.startTime).inMinutes;

    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
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
                      Text(
                        campaign.title,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(Icons.near_me_rounded,
                              size: 16, color: Colors.grey[700]),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              campaign.zone,
                              style: Theme.of(context)
                                  .textTheme
                                  .labelMedium
                                  ?.copyWith(color: Colors.grey[700]),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '\$${campaign.suggestedPrice.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    Text(
                      l10n.suggestedPrice,
                      style: Theme.of(context)
                          .textTheme
                          .labelSmall
                          ?.copyWith(color: Colors.grey[700]),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _miniMetric(Icons.alt_route_rounded,
                    '${campaign.distance.toStringAsFixed(1)}km', l10n.route),
                _miniMetric(Icons.timer_outlined, '$durationMinutes min',
                    l10n.duration),
                _miniMetric(Icons.graphic_eq_rounded,
                    '${campaign.audioDuration}s', l10n.audio),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: l10n.preview,
                    backgroundColor: Colors.white,
                    textColor: Colors.grey[800]!,
                    isOutlined: true,
                    outlineColor: Colors.grey[300]!,
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('${l10n.preview} (WIP)')),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomButton(
                    text: l10n.placeBid,
                    backgroundColor: AppColors.deepOrange,
                    textColor: AppColors.primary,
                    shrinkToFit: true,
                    onPressed: () {
                      if (campaign.id == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(l10n.unknownError)),
                        );
                        return;
                      }

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PromoterCampaignDetailsPage(
                            campaignId: campaign.id!,
                          ),
                        ),
                      );
                    },
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
                      Text('Campana Activa',
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('75% para completar la ruta',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.deepOrange,
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
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: 0.75,
                minHeight: 10,
                backgroundColor: const Color(0xFFEDEDED),
                color: AppColors.deepOrange,
              ),
            ),
            const SizedBox(height: 14),
            CustomButton(
              text: 'Continuar Ruta',
              backgroundColor: AppColors.deepOrange,
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Continuar ruta (WIP)')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
