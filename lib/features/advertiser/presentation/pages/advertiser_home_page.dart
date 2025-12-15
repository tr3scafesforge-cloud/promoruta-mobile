import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:promoruta/core/constants/colors.dart';
import 'package:promoruta/gen/l10n/app_localizations.dart';
import 'package:promoruta/shared/shared.dart';
import 'package:promoruta/core/models/campaign.dart' as model;

class AdvertiserHomePage extends ConsumerWidget {
  const AdvertiserHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final activeCampaignsAsync = ref.watch(activeCampaignsProvider);

    return activeCampaignsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => _HomeContent(l10n: l10n, activeCampaigns: const []),
      data: (campaigns) => _HomeContent(l10n: l10n, activeCampaigns: campaigns),
    );
  }
}

class _HomeContent extends StatelessWidget {
  final AppLocalizations l10n;
  final List<model.Campaign> activeCampaigns;

  const _HomeContent({required this.l10n, required this.activeCampaigns});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      children: [
        // KPI cards
        Row(
          children: [
            Expanded(
              child: _StatCard(
                icon: Icons.trending_up_rounded,
                value: '${activeCampaigns.length}',
                labelTop: l10n.campaigns,
                labelBottom: l10n.active,
                iconColor: AppColors.blueDark,
                backgroundColor: AppColors.blueDark.withValues(alpha: .2),
              ),
            ),
            const SizedBox(width: 5),
            Expanded(
              child: _StatCard(
                icon: Icons.place_rounded,
                value: '12',
                labelTop: l10n.zonesCovered,
                labelBottom: l10n.thisWeek,
                iconColor: AppColors.green,
                backgroundColor: AppColors.green.withValues(alpha: .2),
              ),
            ),
            const SizedBox(width: 5),
            Expanded(
              child: _StatCard(
                icon: Icons.attach_money_rounded,
                value: '\$284',
                labelTop: l10n.investment,
                labelBottom: l10n.accumulated,
                iconColor: AppColors.secondary,
                backgroundColor: AppColors.secondary.withValues(alpha: .2),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        _CreateFirstCampaignCard(l10n: l10n),

        const SizedBox(height: 5),

        // Section header
        _SectionHeader(l10n: l10n),

        // Campaign list
        if (activeCampaigns.isEmpty)
          AppCard(
            padding: const EdgeInsets.all(20),
            child: Center(
              child: Text(
                l10n.noActiveCampaigns,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ),
          )
        else
          ...activeCampaigns.take(5).map((campaign) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _CampaignCard(
                  campaign: campaign,
                  l10n: l10n,
                ),
              )),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String labelTop;
  final String labelBottom;
  final Color? iconColor;
  final Color? backgroundColor;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.labelTop,
    required this.labelBottom,
    this.iconColor,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: backgroundColor ?? const Color(0xFFF0F6F5),
            child: Icon(
              icon,
              color: iconColor ?? AppColors.secondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 2),
          Text(
            labelTop,
            textAlign: TextAlign.center,
            maxLines: 1,
            style: Theme.of(context)
                .textTheme
                .labelMedium
                ?.copyWith(color: AppColors.textSecondary),
          ),
          Text(
            labelBottom,
            textAlign: TextAlign.center,
            maxLines: 1,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
        ],
      ),
    );
  }
}

class _CreateFirstCampaignCard extends StatelessWidget {
  final AppLocalizations l10n;
  const _CreateFirstCampaignCard({required this.l10n});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.createCampaignWip)),
                  );
                },
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withValues(alpha: .2),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Icon(Icons.add, color: AppColors.secondary, size: 28),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.createYourFirstCampaign,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.designAudioAdMarkRouteStartPromoting,
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: Colors.grey[700]),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ],
          ),
          CustomButton(
            text: l10n.startCampaign,
            backgroundColor: AppColors.secondary,
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.startCampaignWip)),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _CampaignCard extends StatelessWidget {
  final model.Campaign campaign;
  final AppLocalizations l10n;

  const _CampaignCard({
    required this.campaign,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(campaign.status);
    final statusLabel = _getStatusLabel(campaign.status, l10n);

    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          // Header row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: statusColor.withValues(alpha: .2),
                child: Icon(
                  Icons.play_circle_fill_rounded,
                  color: statusColor,
                ),
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
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: .2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            statusLabel,
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(color: Colors.grey[800]),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          campaign.zone,
                          style: Theme.of(context)
                              .textTheme
                              .labelMedium
                              ?.copyWith(color: Colors.grey[700]),
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
                    '\$${campaign.finalPrice?.toStringAsFixed(2) ?? campaign.suggestedPrice.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  Text(l10n.today,
                      style: Theme.of(context)
                          .textTheme
                          .labelSmall
                          ?.copyWith(color: Colors.grey[700])),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Metrics row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: _MetricTile(
                  value: '${campaign.distance.toStringAsFixed(1)}km',
                  label: l10n.route,
                ),
              ),
              Expanded(
                child: _MetricTile(
                  value: '${campaign.audioDuration}s',
                  label: l10n.audio,
                ),
              ),
              Expanded(
                child: _MetricTile(
                  value: '0%',
                  label: l10n.completed,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(model.CampaignStatus? status) {
    switch (status) {
      case model.CampaignStatus.active:
        return AppColors.activeCampaignColor;
      case model.CampaignStatus.pending:
        return AppColors.pendingOrangeColor;
      case model.CampaignStatus.completed:
        return AppColors.completedGreenColor;
      default:
        return AppColors.greyUnknown;
    }
  }

  String _getStatusLabel(model.CampaignStatus? status, AppLocalizations l10n) {
    switch (status) {
      case model.CampaignStatus.active:
        return l10n.active;
      case model.CampaignStatus.pending:
        return l10n.pending;
      case model.CampaignStatus.completed:
        return l10n.completed;
      default:
        return l10n.active;
    }
  }
}

class _MetricTile extends StatelessWidget {
  final String value;
  final String label;

  const _MetricTile({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: Theme.of(context)
                .textTheme
                .labelSmall
                ?.copyWith(color: Colors.grey[700]),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends ConsumerWidget {
  final AppLocalizations l10n;

  const _SectionHeader({required this.l10n});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(l10n.activeCampaigns,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                )),
        TextButton(
          onPressed: () {
            // Navigate to campaigns tab (index 1)
            ref.read(advertiserTabProvider.notifier).setTab(1);
          },
          child: Text(l10n.seeAll),
        ),
      ],
    );
  }
}

