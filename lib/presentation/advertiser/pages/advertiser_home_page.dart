import 'package:flutter/material.dart';
import 'package:promoruta/core/constants/colors.dart';
import 'package:promoruta/gen/l10n/app_localizations.dart';
import 'package:promoruta/shared/widgets/app_card.dart';

class AdvertiserHomePage extends StatelessWidget {
  const AdvertiserHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return _HomeContent(l10n: l10n);
  }
}

class _HomeContent extends StatelessWidget {
  final AppLocalizations l10n;
  const _HomeContent({required this.l10n});

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
                value: '3',
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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(l10n.activeCampaigns,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    )),
            TextButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.seeAllWip)),
                );
              },
              child: Text(l10n.seeAll),
            ),
          ],
        ),

        // Campaign list
        _CampaignCard(
          icon: Icons.play_circle_fill_rounded,
          iconColor: Colors.teal,
          title: l10n.coffeeShopPromotion,
          statusChipLabel: l10n.active,
          statusChipColor: const Color(0xFFE6F4FF),
          rightAmount: '\$48.20',
          rightSubtitle: l10n.today,
          metrics: [
            _CampaignMetric(value: '2.4km', label: l10n.route),
            _CampaignMetric(value: '45s', label: l10n.audio),
            _CampaignMetric(value: '68%', label: l10n.completed),
          ],
          subtitle: l10n.twoActivePromoters,
        ),
        const SizedBox(height: 12),
        _CampaignCard(
          icon: Icons.schedule_rounded,
          iconColor: const Color(0xFFFFB74D),
          title: l10n.storeOpening,
          statusChipLabel: l10n.pending,
          statusChipColor: const Color(0xFFFFF3E0),
          rightAmount: '\$0.00',
          rightSubtitle: l10n.today,
          metrics: [
            _CampaignMetric(value: '1.8km', label: l10n.route),
            _CampaignMetric(value: '30s', label: l10n.audio),
            _CampaignMetric(value: '0%', label: l10n.completed),
          ],
          subtitle: l10n.waitingForPromoters,
        ),
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
                ?.copyWith(color: Colors.grey[700]),
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
          SizedBox(
            height: 35,
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.startCampaignWip)),
                );
              },
              child: Text(
                l10n.startCampaign,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class _CampaignCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String statusChipLabel;
  final Color statusChipColor;
  final String rightAmount;
  final String rightSubtitle;
  final List<_CampaignMetric> metrics;

  const _CampaignCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.statusChipLabel,
    required this.statusChipColor,
    required this.rightAmount,
    required this.rightSubtitle,
    required this.metrics,
  });

  @override
  Widget build(BuildContext context) {
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
                backgroundColor: statusChipColor,
                child: Icon(icon, color: iconColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
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
                            color: statusChipColor,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            statusChipLabel,
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(color: Colors.grey[800]),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          subtitle,
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
                    rightAmount,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  Text(rightSubtitle,
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
            children: metrics
                .map((m) => Expanded(
                      child: _MetricTile(value: m.value, label: m.label),
                    ))
                .toList(),
          ),
        ],
      ),
    );
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

class _CampaignMetric {
  final String value;
  final String label;
  const _CampaignMetric({required this.value, required this.label});
}
