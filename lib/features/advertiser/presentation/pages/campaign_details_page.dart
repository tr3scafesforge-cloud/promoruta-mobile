import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:promoruta/core/constants/colors.dart';
import 'package:promoruta/core/models/campaign.dart';
import 'package:promoruta/gen/l10n/app_localizations.dart';
import 'package:promoruta/shared/shared.dart';
import 'package:promoruta/features/advertiser/campaign_management/domain/use_cases/campaign_use_cases.dart';

class CampaignDetailsPage extends ConsumerStatefulWidget {
  final String campaignId;

  const CampaignDetailsPage({
    super.key,
    required this.campaignId,
  });

  @override
  ConsumerState<CampaignDetailsPage> createState() =>
      _CampaignDetailsPageState();
}

class _CampaignDetailsPageState extends ConsumerState<CampaignDetailsPage> {
  final _reasonController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _cancelCampaign(Campaign campaign) async {
    final l10n = AppLocalizations.of(context);

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.confirmCancellation),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.areYouSureCancelCampaign),
            const SizedBox(height: 16),
            TextField(
              controller: _reasonController,
              decoration: InputDecoration(
                labelText: l10n.cancelReason,
                hintText: l10n.enterCancellationReason,
                border: const OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              if (_reasonController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.reasonIsRequired)),
                );
                return;
              }
              Navigator.pop(context, true);
            },
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: Text(l10n.cancelCampaign),
          ),
        ],
      ),
    );

    if (confirmed != true) {
      _reasonController.clear();
      return;
    }

    setState(() => _isLoading = true);

    try {
      final cancelUseCase = ref.read(cancelCampaignUseCaseProvider);
      final cancelledCampaign = await cancelUseCase(CancelCampaignParams(
        campaignId: widget.campaignId,
        reason: _reasonController.text.trim(),
      ));

      // Update the campaigns list with the cancelled campaign
      final campaignsNotifier = ref.read(campaignsProvider.notifier);
      await campaignsNotifier.updateCampaign(cancelledCampaign);

      // Refresh providers to ensure all views are updated
      ref.invalidate(activeCampaignsProvider);
      ref.invalidate(campaignByIdProvider(widget.campaignId));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.campaignCancelled)),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
      _reasonController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final campaignAsync = ref.watch(campaignByIdProvider(widget.campaignId));

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.campaignDetails),
        backgroundColor: AppColors.blueDark,
        foregroundColor: Colors.white,
      ),
      body: campaignAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              error.toString(),
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        data: (campaign) {
          if (campaign == null) {
            return Center(child: Text(l10n.noActiveCampaigns));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Campaign title and status
                AppCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        campaign.title,
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: _getStatusColor(campaign.status)
                                  .withValues(alpha: .2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              _getStatusLabel(campaign.status, l10n),
                              style: Theme.of(context)
                                  .textTheme
                                  .labelLarge
                                  ?.copyWith(
                                    color: _getStatusColor(campaign.status),
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Campaign details
                AppCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _DetailRow(
                        label: l10n.coverageZone,
                        value: campaign.zone,
                      ),
                      const Divider(height: 24),
                      _DetailRow(
                        label: l10n.suggestedPrice,
                        value:
                            '\$${campaign.suggestedPrice.toStringAsFixed(2)}',
                      ),
                      if (campaign.finalPrice != null) ...[
                        const Divider(height: 24),
                        _DetailRow(
                          label: l10n.finalPrice,
                          value: '\$${campaign.finalPrice!.toStringAsFixed(2)}',
                        ),
                      ],
                      const Divider(height: 24),
                      _DetailRow(
                        label: l10n.route,
                        value: '${campaign.distance.toStringAsFixed(1)} km',
                      ),
                      const Divider(height: 24),
                      _DetailRow(
                        label: l10n.audio,
                        value: '${campaign.audioDuration}s',
                      ),
                      const Divider(height: 24),
                      _DetailRow(
                        label: l10n.bidDeadline,
                        value: DateFormat('MMM dd, yyyy HH:mm')
                            .format(campaign.bidDeadline),
                      ),
                      const Divider(height: 24),
                      _DetailRow(
                        label: l10n.startTime,
                        value: DateFormat('MMM dd, yyyy HH:mm')
                            .format(campaign.startTime),
                      ),
                      const Divider(height: 24),
                      _DetailRow(
                        label: l10n.endTime,
                        value: DateFormat('MMM dd, yyyy HH:mm')
                            .format(campaign.endTime),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Cancel button (only show for pending campaigns)
                if (campaign.status == CampaignStatus.pending)
                  SizedBox(
                    width: double.infinity,
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : CustomButton(
                            text: l10n.cancelCampaign,
                            backgroundColor: Colors.red,
                            onPressed: () => _cancelCampaign(campaign),
                          ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Color _getStatusColor(CampaignStatus? status) {
    switch (status) {
      case CampaignStatus.active:
        return AppColors.activeCampaignColor;
      case CampaignStatus.pending:
        return AppColors.pendingOrangeColor;
      case CampaignStatus.completed:
        return AppColors.completedGreenColor;
      case CampaignStatus.canceled:
        return Colors.red;
      default:
        return AppColors.greyUnknown;
    }
  }

  String _getStatusLabel(CampaignStatus? status, AppLocalizations l10n) {
    switch (status) {
      case CampaignStatus.active:
        return l10n.active;
      case CampaignStatus.pending:
        return l10n.pending;
      case CampaignStatus.completed:
        return l10n.completed;
      case CampaignStatus.canceled:
        return l10n.cancelled;
      default:
        return l10n.pending;
    }
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
        ),
        Flexible(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}
