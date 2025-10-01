import 'package:flutter/material.dart';
import 'package:promoruta/core/constants/colors.dart';
import 'package:promoruta/gen/l10n/app_localizations.dart';

class AdvertiserHomeScreen extends StatefulWidget {
  const AdvertiserHomeScreen({super.key});

  @override
  State<AdvertiserHomeScreen> createState() => _AdvertiserHomeScreenState();
}

class _AdvertiserHomeScreenState extends State<AdvertiserHomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F5F7),
      appBar: AppBar(
        elevation: 0,
        centerTitle: false,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.goodMorning,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    )),
            const SizedBox(height: 2),
            Text(
              l10n.readyToCreateNextCampaign,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
      body: _currentIndex == 0
          ? _HomeContent(l10n: l10n)
          : _PlaceholderTab(index: _currentIndex, l10n: l10n),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.createCampaignWip)),
          );
        },
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.grey[600],
        type: BottomNavigationBarType.fixed,
        onTap: (i) {
          setState(() => _currentIndex = i);
        },
        items: [
          BottomNavigationBarItem(icon: const Icon(Icons.home_rounded), label: l10n.home),
          BottomNavigationBarItem(icon: const Icon(Icons.view_list_rounded), label: l10n.campaigns),
          BottomNavigationBarItem(icon: const Icon(Icons.podcasts_rounded), label: l10n.live),
          BottomNavigationBarItem(icon: const Icon(Icons.history_rounded), label: l10n.history),
          BottomNavigationBarItem(icon: const Icon(Icons.person_rounded), label: l10n.profile),
        ],
      ),
    );
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
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                icon: Icons.place_rounded,
                value: '12',
                labelTop: l10n.zonesCovered,
                labelBottom: l10n.thisWeek,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                icon: Icons.attach_money_rounded,
                value: '\$284',
                labelTop: l10n.investment,
                labelBottom: l10n.accumulated,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // First campaign card
        _CreateFirstCampaignCard(l10n: l10n),

        const SizedBox(height: 16),

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

  const _StatCard({
    required this.icon,
    required this.value,
    required this.labelTop,
    required this.labelBottom,
  });

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
              radius: 20,
              backgroundColor: const Color(0xFFF0F6F5),
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
            Text(
              labelTop,
              textAlign: TextAlign.center,
              style:
                  Theme.of(context).textTheme.labelMedium?.copyWith(color: Colors.grey[700]),
            ),
            Text(
              labelBottom,
              textAlign: TextAlign.center,
              style:
                  Theme.of(context).textTheme.labelMedium?.copyWith(color: Colors.grey[700]),
            ),
          ],
        ),
      ),
    );
  }
}

class _CreateFirstCampaignCard extends StatelessWidget {
  final AppLocalizations l10n;
  const _CreateFirstCampaignCard({required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5F1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.add, color: AppColors.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.createYourFirstCampaign,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          )),
                  const SizedBox(height: 4),
                  Text(
                    l10n.designAudioAdMarkRouteStartPromoting,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 40,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(l10n.startCampaignWip)),
                        );
                      },
                      child: Text(l10n.startCampaign),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
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
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
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
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              )),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
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
            style:
                Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.grey[700]),
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

class _PlaceholderTab extends StatelessWidget {
  final int index;
  final AppLocalizations l10n;
  const _PlaceholderTab({required this.index, required this.l10n});

  String get _label {
    switch (index) {
      case 1:
        return l10n.campaigns;
      case 2:
        return l10n.live;
      case 3:
        return l10n.history;
      case 4:
        return l10n.profile;
      default:
        return l10n.home;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('$_label${l10n.placeholderPending}',
          style: Theme.of(context).textTheme.titleMedium),
    );
  }
}
