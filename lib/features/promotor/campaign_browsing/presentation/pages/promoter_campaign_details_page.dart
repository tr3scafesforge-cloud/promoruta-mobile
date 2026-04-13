import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:promoruta/core/constants/app_shapes.dart';
import 'package:promoruta/core/constants/colors.dart';
import 'package:promoruta/core/models/campaign.dart';
import 'package:promoruta/core/models/campaign_bid.dart';
import 'package:promoruta/core/models/payment_status.dart';
import 'package:promoruta/gen/l10n/app_localizations.dart';
import 'package:promoruta/shared/shared.dart';
import 'package:promoruta/shared/services/notification_service.dart';
import 'package:promoruta/features/campaign_bidding/domain/use_cases/campaign_bidding_use_cases.dart';
import 'package:promoruta/features/promotor/presentation/pages/active_campaign_map_view.dart';

class PromoterCampaignDetailsPage extends ConsumerStatefulWidget {
  final String campaignId;

  const PromoterCampaignDetailsPage({
    super.key,
    required this.campaignId,
  });

  @override
  ConsumerState<PromoterCampaignDetailsPage> createState() =>
      _PromoterCampaignDetailsPageState();
}

class _PromoterCampaignDetailsPageState
    extends ConsumerState<PromoterCampaignDetailsPage> {
  bool _isSubmitting = false;
  Timer? _pollingTimer;
  Duration _pollingInterval = const Duration(seconds: 20);

  @override
  void initState() {
    super.initState();
    _startPolling(const Duration(seconds: 20));
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
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

  Future<_BidFormResult?> _showBidDialog(
      AppLocalizations l10n, CampaignBid? existing) async {
    return showDialog<_BidFormResult>(
      context: context,
      builder: (_) => _BidDialog(
        l10n: l10n,
        existing: existing,
      ),
    );
  }

  Future<void> _submitBid({
    required String campaignId,
    CampaignBid? existing,
  }) async {
    final l10n = AppLocalizations.of(context);
    final notificationService = ref.read(notificationServiceProvider);
    final result = await _showBidDialog(l10n, existing);
    if (result == null) return;

    setState(() => _isSubmitting = true);

    try {
      if (existing == null) {
        final createUseCase = ref.read(createBidUseCaseProvider);
        await createUseCase(CreateBidParams(
          campaignId: campaignId,
          proposedPrice: result.price,
          message: result.message,
        ));
      } else {
        final updateUseCase = ref.read(updateBidUseCaseProvider);
        await updateUseCase(UpdateBidParams(
          campaignId: campaignId,
          bidId: existing.id,
          proposedPrice: result.price,
          message: result.message,
        ));
      }

      ref.invalidate(campaignBidsProvider(campaignId));

      if (mounted) {
        notificationService.showToast(
          existing == null ? l10n.bidSubmittedToast : l10n.bidUpdatedToast,
          type: ToastType.success,
          context: context,
        );
      }
    } catch (e) {
      if (mounted) {
        notificationService.showToast(
          _formatErrorMessage(e),
          type: ToastType.error,
          context: context,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Future<void> _withdrawBid({
    required String campaignId,
    required String bidId,
  }) async {
    final l10n = AppLocalizations.of(context);
    final notificationService = ref.read(notificationServiceProvider);
    setState(() => _isSubmitting = true);
    try {
      final withdrawUseCase = ref.read(withdrawBidUseCaseProvider);
      await withdrawUseCase(WithdrawBidParams(
        campaignId: campaignId,
        bidId: bidId,
      ));

      ref.invalidate(campaignBidsProvider(campaignId));

      if (mounted) {
        notificationService.showToast(
          l10n.bidWithdrawnToast,
          type: ToastType.success,
          context: context,
        );
      }
    } catch (e) {
      if (mounted) {
        notificationService.showToast(
          _formatErrorMessage(e),
          type: ToastType.error,
          context: context,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final campaignAsync = ref.watch(campaignByIdProvider(widget.campaignId));
    final bidsAsync = ref.watch(campaignBidsProvider(widget.campaignId));
    final authState = ref.watch(authStateProvider);
    final user = authState.valueOrNull;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.campaignDetails),
      ),
      body: campaignAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child:
              Text(error.toString(), style: const TextStyle(color: Colors.red)),
        ),
        data: (campaign) {
          if (campaign == null) {
            return Center(child: Text(l10n.noCampaignsFound));
          }

          _updatePollingForStatus(campaign.status);

          final paymentStatus =
              campaign.paymentStatus ?? bidsAsync.valueOrNull?.paymentStatus;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppCard(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        campaign.title,
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        campaign.description ?? '',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(Icons.location_on,
                              size: 16, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Expanded(child: Text(campaign.zone)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _DetailRow(
                        label: l10n.suggestedPrice,
                        value:
                            '\$${campaign.suggestedPrice.toStringAsFixed(2)}',
                      ),
                      const SizedBox(height: 8),
                      _DetailRow(
                        label: l10n.bidDeadline,
                        value: DateFormat('MMM dd, yyyy HH:mm')
                            .format(campaign.bidDeadline),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Bid section
                AppCard(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  child: bidsAsync.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (error, _) => Text(
                      error.toString(),
                      style: const TextStyle(color: Colors.red),
                    ),
                    data: (summary) {
                      final ownBid = summary.bids.firstWhere(
                        (bid) => bid.promoterId == user?.id,
                        orElse: () => CampaignBid(
                          id: '',
                          promoterId: '',
                          proposedPrice: 0,
                          status: CampaignBidStatus.pending,
                        ),
                      );
                      final hasBid = ownBid.id.isNotEmpty;
                      final hasActiveBid =
                          hasBid && ownBid.status != CampaignBidStatus.withdrawn;
                      final canSubmitBid =
                          campaign.status == CampaignStatus.created;
                      final canWithdrawBid = hasBid &&
                          ownBid.status == CampaignBidStatus.pending &&
                          campaign.status == CampaignStatus.created;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.yourBid,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 12),
                          if (!hasBid)
                            Text(l10n.noBidYet)
                          else
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.proposedPriceValue(
                                      ownBid.proposedPrice.toStringAsFixed(2)),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  l10n.bidStatusValue(
                                    _getBidStatusLabel(
                                      ownBid.status,
                                      l10n,
                                      paymentStatus,
                                    ),
                                  ),
                                ),
                                if (ownBid.message != null &&
                                    ownBid.message!.isNotEmpty) ...[
                                  const SizedBox(height: 6),
                                  Text(ownBid.message!),
                                ],
                              ],
                            ),
                          const SizedBox(height: 12),
                          if (canSubmitBid)
                            Opacity(
                              opacity: _isSubmitting ? 0.7 : 1,
                              child: IgnorePointer(
                                ignoring: _isSubmitting,
                                child: CustomButton(
                                  text: hasActiveBid
                                      ? l10n.updateBid
                                      : l10n.placeBid,
                                  backgroundColor: AppColors.deepOrange,
                                  textColor: AppColors.primary,
                                  shrinkToFit: true,
                                  onPressed: () => _submitBid(
                                    campaignId: widget.campaignId,
                                    existing: hasActiveBid ? ownBid : null,
                                  ),
                                ),
                              ),
                            ),
                          if (canWithdrawBid) ...[
                            const SizedBox(height: 8),
                            Opacity(
                              opacity: _isSubmitting ? 0.7 : 1,
                              child: IgnorePointer(
                                ignoring: _isSubmitting,
                                child: CustomButton(
                                  text: l10n.withdrawBid,
                                  backgroundColor: Colors.white,
                                  textColor: Colors.black,
                                  isOutlined: true,
                                  outlineColor: Colors.grey[300]!,
                                  onPressed: () => _withdrawBid(
                                    campaignId: widget.campaignId,
                                    bidId: ownBid.id,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),

                if (campaign.status == CampaignStatus.accepted &&
                    paymentStatus == PaymentStatus.paid &&
                    campaign.acceptedBy?.id == user?.id)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ActiveCampaignMapView(
                              campaignId: campaign.id ?? '',
                              campaignName: campaign.title,
                              location: campaign.zone,
                              audioUrl: campaign.audioUrl,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondary,
                        foregroundColor: Colors.white,
                      ),
                      child: Text(l10n.startCampaign),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  bool _isTerminalStatus(CampaignStatus? status) {
    return status == CampaignStatus.completed ||
        status == CampaignStatus.canceled ||
        status == CampaignStatus.expired;
  }

  String _getBidStatusLabel(
    CampaignBidStatus status,
    AppLocalizations l10n,
    PaymentStatus? paymentStatus,
  ) {
    switch (status) {
      case CampaignBidStatus.pending:
        return l10n.pending;
      case CampaignBidStatus.accepted:
        return paymentStatus == PaymentStatus.paid
            ? l10n.statusReadyToStart
            : l10n.statusWaitingForPayment;
      case CampaignBidStatus.rejected:
        return l10n.statusCanceled;
      case CampaignBidStatus.withdrawn:
        return l10n.bidWithdrawn;
    }
  }

  String _formatErrorMessage(Object error) {
    final message = error.toString();
    const exceptionPrefix = 'Exception: ';
    if (message.startsWith(exceptionPrefix)) {
      return message.substring(exceptionPrefix.length);
    }
    return message;
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
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(color: Colors.grey[600]),
        ),
        Flexible(
          child: Text(
            value,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}

class _BidFormResult {
  final double price;
  final String message;

  const _BidFormResult({
    required this.price,
    required this.message,
  });
}

class _BidDialog extends StatefulWidget {
  final AppLocalizations l10n;
  final CampaignBid? existing;

  const _BidDialog({
    required this.l10n,
    required this.existing,
  });

  @override
  State<_BidDialog> createState() => _BidDialogState();
}

class _BidDialogState extends State<_BidDialog> {
  static final NumberFormat _uyCurrencyFormat = NumberFormat.currency(
    locale: 'es_UY',
    symbol: '',
    decimalDigits: 2,
  );

  late final TextEditingController _priceController;
  late final TextEditingController _messageController;

  InputDecoration _inputDecoration(String labelText) {
    const borderRadius = BorderRadius.all(Radius.circular(10));

    return InputDecoration(
      labelText: labelText,
      labelStyle: const TextStyle(color: AppColors.textSecondary),
      border: const OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: BorderSide(
          color: AppColors.greyUnknown,
          width: 1.2,
        ),
      ),
      enabledBorder: const OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: BorderSide(
          color: AppColors.greyUnknown,
          width: 1.2,
        ),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: BorderSide(
          color: AppColors.deepOrange,
          width: 1.8,
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _priceController = TextEditingController(
      text: widget.existing == null
          ? ''
          : _uyCurrencyFormat.format(widget.existing!.proposedPrice),
    );
    _messageController = TextEditingController(
      text: widget.existing?.message ?? '',
    );
  }

  @override
  void dispose() {
    _priceController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _submit() {
    final price = _parseUyCurrency(_priceController.text.trim());
    if (price == null || price <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(widget.l10n.invalidPrice)),
      );
      return;
    }

    Navigator.pop(
      context,
      _BidFormResult(
        price: price,
        message: _messageController.text.trim(),
      ),
    );
  }

  double? _parseUyCurrency(String value) {
    final normalizedValue = value
        .replaceAll('.', '')
        .replaceAll(',', '.')
        .replaceAll(RegExp(r'[^0-9.]'), '');

    if (normalizedValue.isEmpty) {
      return null;
    }

    return double.tryParse(normalizedValue);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: AppShapes.dialogRadius,
        side: const BorderSide(color: AppColors.grayDarkStroke),
      ),
      title: Text(
        widget.existing == null ? widget.l10n.placeBid : widget.l10n.updateBid,
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _priceController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [_BidUyCurrencyInputFormatter()],
              decoration: _inputDecoration(widget.l10n.proposedPrice),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _messageController,
              maxLines: 3,
              decoration: _inputDecoration(widget.l10n.messageOptional),
            ),
          ],
        ),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      actions: [
        SizedBox(
          width: double.maxFinite,
          child: Row(
            children: [
              Expanded(
                child: CustomButton.outlined(
                  text: widget.l10n.cancel,
                  backgroundColor: Colors.white,
                  outlineColor: AppColors.grayDarkStroke,
                  textColor: AppColors.textPrimary,
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CustomButton(
                  text:
                      widget.existing == null ? widget.l10n.submitBid : widget.l10n.save,
                  backgroundColor: AppColors.deepOrange,
                  textColor: AppColors.primary,
                  shrinkToFit: true,
                  onPressed: _submit,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _BidUyCurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digitsOnly = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    if (digitsOnly.isEmpty) {
      return const TextEditingValue();
    }

    final cents = int.parse(digitsOnly);
    final formattedValue = _BidDialogState._uyCurrencyFormat.format(cents / 100);

    return TextEditingValue(
      text: formattedValue,
      selection: TextSelection.collapsed(offset: formattedValue.length),
    );
  }
}
