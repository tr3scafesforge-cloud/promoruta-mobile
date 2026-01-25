import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:promoruta/gen/l10n/app_localizations.dart';
import 'package:promoruta/core/constants/colors.dart';
import 'package:promoruta/core/models/campaign.dart' as model;
import 'package:promoruta/features/promotor/presentation/pages/active_campaign_map_view.dart';
import 'package:promoruta/features/promotor/presentation/pages/completed_campaign_details_page.dart';
import 'package:promoruta/shared/providers/providers.dart';

class PromoterActivePage extends ConsumerStatefulWidget {
  const PromoterActivePage({super.key});

  @override
  ConsumerState<PromoterActivePage> createState() => _PromoterActivePageState();
}

class _PromoterActivePageState extends ConsumerState<PromoterActivePage> {
  int _selectedSegment = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final kpiStatsAsync = ref.watch(promoterKpiStatsProvider);
    final activeCampaignsAsync = ref.watch(promoterActiveCampaignsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Stats Cards
              _StatCard(
                title: l10n.activeJobsCount,
                value: activeCampaignsAsync.when(
                  loading: () => '-',
                  error: (_, __) => '-',
                  data: (campaigns) => campaigns.length.toString(),
                ),
                icon: Icons.access_time,
                iconColor: AppColors.secondary,
              ),
              const SizedBox(height: 12),
              _StatCard(
                title: l10n.earningsThisWeek,
                value: kpiStatsAsync.when(
                  loading: () => '-',
                  error: (_, __) => '-',
                  data: (stats) => '\$${stats.thisWeekEarnings.toStringAsFixed(2)}',
                ),
                icon: Icons.attach_money,
                iconColor: AppColors.green,
              ),
              const SizedBox(height: 12),
              _StatCard(
                title: l10n.distanceTraveled,
                value: kpiStatsAsync.when(
                  loading: () => '-',
                  error: (_, __) => '-',
                  data: (stats) => '${stats.totalDistanceKm.toStringAsFixed(1)} km',
                ),
                icon: Icons.route_outlined,
                iconColor: AppColors.secondary,
              ),
              const SizedBox(height: 24),

              // Segmented Control
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _SegmentButton(
                        label: l10n.inProgress,
                        isSelected: _selectedSegment == 0,
                        onTap: () => setState(() => _selectedSegment = 0),
                      ),
                    ),
                    Expanded(
                      child: _SegmentButton(
                        label: l10n.completedToday,
                        isSelected: _selectedSegment == 1,
                        onTap: () => setState(() => _selectedSegment = 1),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Content based on selected segment
              if (_selectedSegment == 0) _InProgressView(l10n: l10n),
              if (_selectedSegment == 1) _CompletedTodayView(l10n: l10n),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color iconColor;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.grayLightStroke,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }
}

class _SegmentButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _SegmentButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

class _InProgressView extends ConsumerWidget {
  final AppLocalizations l10n;

  const _InProgressView({required this.l10n});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final campaignsAsync = ref.watch(promoterActiveCampaignsProvider);
    final executionState = ref.watch(campaignExecutionProvider);

    return campaignsAsync.when(
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                size: 48,
                color: AppColors.textSecondary,
              ),
              const SizedBox(height: 16),
              Text(
                l10n.errorLoadingCampaigns,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => ref.refresh(promoterActiveCampaignsProvider),
                child: Text(l10n.retry),
              ),
            ],
          ),
        ),
      ),
      data: (campaigns) {
        if (campaigns.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.campaign_outlined,
                    size: 48,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.noActiveCampaigns,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        return Column(
          children: campaigns
              .map((campaign) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _ActiveCampaignCard(
                      campaign: campaign,
                      l10n: l10n,
                      isExecuting: executionState.campaignId == campaign.id,
                    ),
                  ))
              .toList(),
        );
      },
    );
  }
}

class _CompletedTodayView extends StatelessWidget {
  final AppLocalizations l10n;

  const _CompletedTodayView({required this.l10n});

  @override
  Widget build(BuildContext context) {
    final completedCampaigns = [
      CompletedCampaign(
        name: 'Promoción de Apertura de tienda',
        location: 'Montevideo shopping',
        earned: 250.00,
        completedAt: '11:30 AM',
        startTime: '09:30',
        endTime: '11:30 AM',
        rating: 4.0,
        comment: 'Servicio muy bueno',
      ),
    ];

    if (completedCampaigns.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(
            l10n.noCampaignsCompletedToday,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
        ),
      );
    }

    return Column(
      children: completedCampaigns
          .map((campaign) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _CompletedCampaignCard(campaign: campaign, l10n: l10n),
              ))
          .toList(),
    );
  }
}

class _ActiveCampaignCard extends StatelessWidget {
  final model.Campaign campaign;
  final AppLocalizations l10n;
  final bool isExecuting;

  const _ActiveCampaignCard({
    required this.campaign,
    required this.l10n,
    this.isExecuting = false,
  });

  String _formatTime(DateTime dateTime) {
    return DateFormat.jm().format(dateTime);
  }

  double _calculateProgress() {
    final now = DateTime.now();
    if (now.isBefore(campaign.startTime)) return 0.0;
    if (now.isAfter(campaign.endTime)) return 1.0;

    final totalDuration = campaign.endTime.difference(campaign.startTime).inMinutes;
    final elapsed = now.difference(campaign.startTime).inMinutes;
    return (elapsed / totalDuration).clamp(0.0, 1.0);
  }

  String _calculateTimeRemaining() {
    final now = DateTime.now();
    if (now.isAfter(campaign.endTime)) return '0m';

    final remaining = campaign.endTime.difference(now);
    if (remaining.inHours > 0) {
      return '${remaining.inHours}h ${remaining.inMinutes % 60}m';
    }
    return '${remaining.inMinutes}m';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final payment = campaign.finalPrice ?? campaign.suggestedPrice;
    final progress = _calculateProgress();
    final timeRemaining = _calculateTimeRemaining();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isExecuting ? AppColors.secondary : AppColors.grayLightStroke,
          width: isExecuting ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Campaign name and status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  campaign.title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isExecuting
                      ? AppColors.secondary.withValues(alpha: 0.1)
                      : AppColors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  isExecuting ? l10n.campaignInProgress : l10n.inProgressStatus,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isExecuting ? AppColors.secondary : AppColors.green,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Location
          Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                size: 16,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  campaign.zone,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 16),
              Icon(
                Icons.attach_money,
                size: 16,
                color: AppColors.textSecondary,
              ),
              Text(
                payment.toStringAsFixed(2),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Time and hours
          Row(
            children: [
              Icon(
                Icons.access_time,
                size: 16,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 4),
              Text(
                '${_formatTime(campaign.startTime)} - ${_formatTime(campaign.endTime)}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: 16),
              Icon(
                Icons.route_outlined,
                size: 16,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 4),
              Text(
                '${campaign.distance.toStringAsFixed(1)} km',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Progress section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.progress,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                l10n.timeRemaining(timeRemaining),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.grayLightStroke,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.secondary),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.percentageCompleted((progress * 100).toStringAsFixed(0)),
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ActiveCampaignMapView(
                          campaignId: campaign.id ?? '',
                          campaignName: campaign.title,
                          location: campaign.zone,
                          audioUrl: campaign.audioUrl,
                        ),
                      ),
                    );
                  },
                  icon: Icon(
                    isExecuting ? Icons.pause_circle_outline : Icons.play_circle_outline,
                    size: 20,
                  ),
                  label: Text(isExecuting ? l10n.viewExecution : l10n.startPromotion),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: isExecuting ? AppColors.secondary : AppColors.textPrimary,
                    side: BorderSide(
                      color: isExecuting ? AppColors.secondary : AppColors.grayLightStroke,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              OutlinedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ActiveCampaignMapView(
                        campaignId: campaign.id ?? '',
                        campaignName: campaign.title,
                        location: campaign.zone,
                        audioUrl: campaign.audioUrl,
                      ),
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textPrimary,
                  side: BorderSide(color: AppColors.grayLightStroke),
                  padding: const EdgeInsets.all(12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  minimumSize: const Size(48, 48),
                ),
                child: const Icon(Icons.map_outlined, size: 20),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CompletedCampaignCard extends StatelessWidget {
  final CompletedCampaign campaign;
  final AppLocalizations l10n;

  const _CompletedCampaignCard({
    required this.campaign,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.grayLightStroke,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Campaign name and status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  campaign.name,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.grayLightStroke,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  l10n.completedStatus,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Location
          Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                size: 16,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 4),
              Text(
                campaign.location,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Earned amount
          Row(
            children: [
              Icon(
                Icons.attach_money,
                size: 16,
                color: AppColors.green,
              ),
              const SizedBox(width: 4),
              Text(
                l10n.earned('\$${campaign.earned.toStringAsFixed(2)}'),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.green,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Completed time
          Row(
            children: [
              Icon(
                Icons.access_time,
                size: 16,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 4),
              Text(
                l10n.completedAt(campaign.completedAt),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // View details button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CompletedCampaignDetailsPage(
                      campaignName: campaign.name,
                      location: campaign.location,
                      startTime: campaign.startTime,
                      endTime: campaign.endTime,
                      earned: campaign.earned,
                      completedAt: campaign.completedAt,
                      rating: campaign.rating,
                      comment: campaign.comment,
                    ),
                  ),
                );
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textPrimary,
                side: BorderSide(color: AppColors.grayLightStroke),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(l10n.viewDetails),
            ),
          ),
        ],
      ),
    );
  }
}


class CompletedCampaign {
  final String name;
  final String location;
  final double earned;
  final String completedAt;
  final String startTime;
  final String endTime;
  final double rating;
  final String? comment;

  CompletedCampaign({
    required this.name,
    required this.location,
    required this.earned,
    required this.completedAt,
    required this.startTime,
    required this.endTime,
    required this.rating,
    this.comment,
  });
}
