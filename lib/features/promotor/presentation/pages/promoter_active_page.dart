import 'package:flutter/material.dart';
import 'package:promoruta/gen/l10n/app_localizations.dart';
import 'package:promoruta/core/constants/colors.dart';
import 'package:promoruta/features/promotor/presentation/pages/active_campaign_map_view.dart';

class PromoterActivePage extends StatefulWidget {
  const PromoterActivePage({super.key});

  @override
  State<PromoterActivePage> createState() => _PromoterActivePageState();
}

class _PromoterActivePageState extends State<PromoterActivePage> {
  int _selectedSegment = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

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
                value: '2',
                icon: Icons.access_time,
                iconColor: AppColors.secondary,
              ),
              const SizedBox(height: 12),
              _StatCard(
                title: l10n.earningsToday,
                value: '\$129.99',
                icon: Icons.attach_money,
                iconColor: AppColors.green,
              ),
              const SizedBox(height: 12),
              _StatCard(
                title: l10n.hoursWorked,
                value: '5.2',
                icon: Icons.people_outline,
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

class _InProgressView extends StatelessWidget {
  final AppLocalizations l10n;

  const _InProgressView({required this.l10n});

  @override
  Widget build(BuildContext context) {
    final activeCampaigns = [
      ActiveCampaign(
        name: 'Promoción de Apertura de tienda',
        location: 'Montevideo shopping',
        payment: 250.00,
        startTime: '9:00 AM',
        endTime: '01:00 AM',
        hours: 4,
        progress: 0.65,
        timeRemaining: '24m',
      ),
    ];

    return Column(
      children: activeCampaigns
          .map((campaign) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _ActiveCampaignCard(campaign: campaign, l10n: l10n),
              ))
          .toList(),
    );
  }
}

class _CompletedTodayView extends StatelessWidget {
  final AppLocalizations l10n;

  const _CompletedTodayView({required this.l10n});

  @override
  Widget build(BuildContext context) {
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
}

class _ActiveCampaignCard extends StatelessWidget {
  final ActiveCampaign campaign;
  final AppLocalizations l10n;

  const _ActiveCampaignCard({
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
                  color: AppColors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  l10n.inProgressStatus,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.green,
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
              const SizedBox(width: 16),
              Icon(
                Icons.attach_money,
                size: 16,
                color: AppColors.textSecondary,
              ),
              Text(
                campaign.payment.toStringAsFixed(2),
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
                '${campaign.startTime} - ${campaign.endTime}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: 16),
              Icon(
                Icons.people_outline,
                size: 16,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 4),
              Text(
                l10n.hoursCount(campaign.hours.toString()),
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
                l10n.timeRemaining(campaign.timeRemaining),
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
              value: campaign.progress,
              backgroundColor: AppColors.grayLightStroke,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.secondary),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.percentageCompleted(
                (campaign.progress * 100).toStringAsFixed(0)),
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
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${l10n.pausePromotion} (WIP)')),
                    );
                  },
                  icon: const Icon(Icons.pause_circle_outline, size: 20),
                  label: Text(l10n.pausePromotion),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textPrimary,
                    side: BorderSide(color: AppColors.grayLightStroke),
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
                        campaignName: campaign.name,
                        location: campaign.location,
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

class ActiveCampaign {
  final String name;
  final String location;
  final double payment;
  final String startTime;
  final String endTime;
  final int hours;
  final double progress;
  final String timeRemaining;

  ActiveCampaign({
    required this.name,
    required this.location,
    required this.payment,
    required this.startTime,
    required this.endTime,
    required this.hours,
    required this.progress,
    required this.timeRemaining,
  });
}
