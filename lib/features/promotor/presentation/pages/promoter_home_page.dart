import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:promoruta/core/constants/colors.dart';
import 'package:promoruta/core/models/campaign.dart';
import 'package:promoruta/core/models/campaign_query_params.dart';
import 'package:promoruta/features/promotor/campaign_browsing/presentation/pages/promoter_campaign_details_page.dart';
import 'package:promoruta/features/promotor/presentation/pages/active_campaign_map_view.dart';
import 'package:promoruta/features/promotor/route_execution/domain/models/campaign_execution_state.dart';
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

class _ActiveCampaignCard extends ConsumerWidget {
  const _ActiveCampaignCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final executionState = ref.watch(campaignExecutionProvider);

    if (!executionState.hasActiveExecution || executionState.campaignId == null) {
      return const SizedBox.shrink();
    }

    final activeCampaigns = ref.watch(promoterActiveCampaignsProvider);
    Campaign? activeCampaign;
    final campaigns = activeCampaigns.valueOrNull;
    if (campaigns != null) {
      for (final campaign in campaigns) {
        if (campaign.id == executionState.campaignId) {
          activeCampaign = campaign;
          break;
        }
      }
    }

    final campaignName =
        executionState.campaignName ?? activeCampaign?.title ?? l10n.activeSingular;
    final location = activeCampaign?.zone;
    final payment = activeCampaign?.finalPrice ?? activeCampaign?.suggestedPrice;
    final statusColor = _statusColor(executionState.status);

    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Card(
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
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: statusColor.withValues(alpha: 0.12),
                    child: Icon(Icons.play_arrow_rounded, color: statusColor),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          campaignName,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          location ?? l10n.campaignInProgress,
                          style: Theme.of(context)
                              .textTheme
                              .labelMedium
                              ?.copyWith(color: Colors.grey[700]),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  if (payment != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '\$${payment.toStringAsFixed(2)}',
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
                children: [
                  Expanded(
                    child: _miniMetric(
                      Icons.speed_rounded,
                      executionState.formattedDistance,
                      l10n.distance,
                    ),
                  ),
                  Expanded(
                    child: _miniMetric(
                      Icons.timer_outlined,
                      executionState.formattedElapsedTime,
                      l10n.elapsedTime,
                    ),
                  ),
                  Expanded(
                    child: _miniMetric(
                      Icons.circle,
                      _statusText(l10n, executionState.status),
                      l10n.status,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              CustomButton(
                text: l10n.viewExecution,
                backgroundColor: AppColors.deepOrange,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ActiveCampaignMapView(
                        campaignId: executionState.campaignId!,
                        campaignName: campaignName,
                        location: location ?? '',
                        audioUrl: activeCampaign?.audioUrl,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _miniMetric(IconData icon, String value, String label) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey[700]),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                label,
                style: TextStyle(color: Colors.grey[700], fontSize: 11),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _statusText(AppLocalizations l10n, CampaignExecutionStatus status) {
    switch (status) {
      case CampaignExecutionStatus.active:
        return l10n.tracking;
      case CampaignExecutionStatus.paused:
        return l10n.paused;
      case CampaignExecutionStatus.starting:
        return l10n.starting;
      case CampaignExecutionStatus.completing:
        return l10n.completing;
      default:
        return l10n.campaignInProgress;
    }
  }

  Color _statusColor(CampaignExecutionStatus status) {
    switch (status) {
      case CampaignExecutionStatus.active:
        return AppColors.green;
      case CampaignExecutionStatus.paused:
        return Colors.orange;
      case CampaignExecutionStatus.starting:
      case CampaignExecutionStatus.completing:
        return AppColors.secondary;
      default:
        return AppColors.deepOrange;
    }
  }
}
