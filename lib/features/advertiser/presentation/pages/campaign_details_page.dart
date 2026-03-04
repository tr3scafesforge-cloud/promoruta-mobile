import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:promoruta/core/constants/colors.dart';
import 'package:promoruta/core/models/campaign.dart';
import 'package:promoruta/core/models/campaign_bid.dart';
import 'package:promoruta/core/models/payment_status.dart';
import 'package:promoruta/gen/l10n/app_localizations.dart';
import 'package:promoruta/shared/shared.dart';
import 'package:promoruta/shared/widgets/payment_webview_page.dart';
import 'package:promoruta/features/advertiser/campaign_management/domain/use_cases/campaign_use_cases.dart';
import 'package:promoruta/features/campaign_bidding/domain/use_cases/campaign_bidding_use_cases.dart';
import 'package:promoruta/features/advertiser/presentation/widgets/advertiser_app_bar.dart';

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
  Timer? _pollingTimer;
  Duration _pollingInterval = const Duration(seconds: 20);
  bool _isLoading = false;
  bool _isAccepting = false;

  @override
  void dispose() {
    _reasonController.dispose();
    _pollingTimer?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _startPolling(const Duration(seconds: 20));
  }

  void _startPolling(Duration interval) {
    _pollingInterval = interval;
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(interval, (_) {
      ref.invalidate(campaignByIdProvider(widget.campaignId));
      ref.invalidate(campaignBidsProvider(widget.campaignId));
    });
  }

  void _stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  void _updatePollingForStatus(CampaignStatus? status) {
    if (_isTerminalStatus(status)) {
      _stopPolling();
      return;
    }

    final nextInterval =
        status == CampaignStatus.inProgress || status == CampaignStatus.active
            ? const Duration(seconds: 45)
            : const Duration(seconds: 20);

    if (_pollingTimer == null || nextInterval != _pollingInterval) {
      _startPolling(nextInterval);
    }
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
    final bidsAsync = ref.watch(campaignBidsProvider(widget.campaignId));

    return Scaffold(
      appBar: AdvertiserAppBar(
        title: l10n.campaignDetails,
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

          _updatePollingForStatus(campaign.status);

          final paymentStatus =
              campaign.paymentStatus ?? bidsAsync.valueOrNull?.paymentStatus;

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
                              color: _getStatusColor(
                                      campaign.status, paymentStatus)
                                  .withValues(alpha: .2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              _getStatusLabel(
                                  campaign.status, paymentStatus, l10n),
                              style: Theme.of(context)
                                  .textTheme
                                  .labelLarge
                                  ?.copyWith(
                                    color: _getStatusColor(
                                        campaign.status, paymentStatus),
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

                // Bids section
                AppCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.bidsTitle,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 12),
                      bidsAsync.when(
                        loading: () =>
                            const Center(child: CircularProgressIndicator()),
                        error: (error, _) => Text(
                          error.toString(),
                          style: const TextStyle(color: Colors.red),
                        ),
                        data: (summary) {
                          if (summary.bids.isEmpty) {
                            return Text(l10n.noBidsYet);
                          }
                          return Column(
                            children: summary.bids
                                .map((bid) => _BidCard(
                                      bid: bid,
                                      onAccept: campaign.status ==
                                              CampaignStatus.created
                                          ? () => _acceptBid(
                                                bidId: bid.id,
                                                campaignId: campaign.id ?? '',
                                              )
                                          : null,
                                      isAccepting: _isAccepting,
                                      l10n: l10n,
                                    ))
                                .toList(),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Cancel button (hide for terminal statuses)
                if (!_isTerminalStatus(campaign.status))
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

  Color _getStatusColor(CampaignStatus? status, PaymentStatus? paymentStatus) {
    switch (status) {
      case CampaignStatus.inProgress:
      case CampaignStatus.active:
        return AppColors.activeCampaignColor;
      case CampaignStatus.accepted:
        return paymentStatus == PaymentStatus.paid
            ? AppColors.green
            : AppColors.pendingOrangeColor;
      case CampaignStatus.pending:
      case CampaignStatus.created:
        return AppColors.pendingOrangeColor;
      case CampaignStatus.completed:
        return AppColors.completedGreenColor;
      case CampaignStatus.canceled:
        return Colors.red;
      case CampaignStatus.expired:
        return AppColors.greyUnknown;
      default:
        return AppColors.greyUnknown;
    }
  }

  String _getStatusLabel(CampaignStatus? status, PaymentStatus? paymentStatus,
      AppLocalizations l10n) {
    switch (status) {
      case CampaignStatus.created:
        return l10n.statusOpenForBids;
      case CampaignStatus.accepted:
        return paymentStatus == PaymentStatus.paid
            ? l10n.statusReadyToStart
            : l10n.statusWaitingForPayment;
      case CampaignStatus.inProgress:
      case CampaignStatus.active:
        return l10n.inProgressStatus;
      case CampaignStatus.pending:
        return l10n.pending;
      case CampaignStatus.completed:
        return l10n.completed;
      case CampaignStatus.canceled:
        return l10n.cancelled;
      case CampaignStatus.expired:
        return l10n.expired;
      default:
        return l10n.pending;
    }
  }

  bool _isTerminalStatus(CampaignStatus? status) {
    return status == CampaignStatus.completed ||
        status == CampaignStatus.canceled ||
        status == CampaignStatus.expired;
  }

  Future<void> _acceptBid({
    required String bidId,
    required String campaignId,
  }) async {
    final l10n = AppLocalizations.of(context);
    setState(() => _isAccepting = true);
    try {
      final acceptUseCase = ref.read(acceptBidUseCaseProvider);
      final paymentInfo = await acceptUseCase(
        AcceptBidParams(campaignId: campaignId, bidId: bidId),
      );

      ref.invalidate(campaignByIdProvider(campaignId));
      ref.invalidate(campaignBidsProvider(campaignId));

      if (paymentInfo.checkoutUrl != null &&
          paymentInfo.checkoutUrl!.isNotEmpty) {
        final uri = Uri.tryParse(paymentInfo.checkoutUrl!);
        if (uri != null) {
          final launched =
              await launchUrl(uri, mode: LaunchMode.externalApplication);
          if (!launched && mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PaymentWebViewPage(checkoutUri: uri),
              ),
            );
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.paymentPendingNoCheckout)),
          );
        }
      }
    } catch (e) {
      ref.invalidate(campaignByIdProvider(campaignId));
      ref.invalidate(campaignBidsProvider(campaignId));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_mapAcceptBidErrorMessage(e, l10n))),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isAccepting = false);
      }
    }
  }

  String _mapAcceptBidErrorMessage(Object error, AppLocalizations l10n) {
    var message = error.toString().trim();

    if (message.startsWith('Exception:')) {
      message = message.replaceFirst('Exception:', '').trim();
    }

    if (message.startsWith('AuthError:')) {
      message = message.replaceFirst('AuthError:', '').trim();
    }

    final upper = message.toUpperCase();
    if (upper.contains('BID_WITHDRAWN')) {
      return l10n.bidWithdrawn;
    }

    if (upper.contains('BID_NOT_AVAILABLE')) {
      return l10n.bidNotAvailable;
    }

    return message.isNotEmpty ? message : l10n.unknownError;
  }
}

class _BidCard extends StatelessWidget {
  final CampaignBid bid;
  final VoidCallback? onAccept;
  final bool isAccepting;
  final AppLocalizations l10n;

  const _BidCard({
    required this.bid,
    required this.onAccept,
    required this.isAccepting,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final profile = bid.promoterProfile;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.grayLightStroke),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: AppColors.grayLightStroke,
                  backgroundImage: profile?.avatarUrl != null
                      ? NetworkImage(profile!.avatarUrl!)
                      : null,
                  child: profile?.avatarUrl == null
                      ? Text(
                          (profile?.name.isNotEmpty == true
                              ? profile!.name[0]
                              : '?'),
                        )
                      : null,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        profile?.name ?? l10n.promoter,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      Text(
                        l10n.promoterStats(
                          profile?.averageRating.toStringAsFixed(1) ?? '0.0',
                          profile?.completedCampaignsCount ?? 0,
                        ),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.grayLightStroke.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    bid.status.name,
                    style: const TextStyle(fontSize: 11),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              l10n.proposedPriceValue(bid.proposedPrice.toStringAsFixed(2)),
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            if (bid.message != null && bid.message!.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                bid.message!,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            if (onAccept != null) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isAccepting ? null : onAccept,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.activeCampaignColor,
                    foregroundColor: Colors.white,
                  ),
                  child: isAccepting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(l10n.acceptBid),
                ),
              ),
            ],
          ],
        ),
      ),
    );
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
