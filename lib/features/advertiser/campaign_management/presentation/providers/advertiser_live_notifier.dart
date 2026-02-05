import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:promoruta/core/utils/logger.dart';
import 'package:promoruta/features/advertiser/campaign_management/domain/models/live_campaign_models.dart';
import 'package:promoruta/features/advertiser/campaign_management/domain/repositories/advertiser_live_repository.dart';
import 'package:promoruta/shared/constants/time_thresholds.dart';

/// Notifier for advertiser live view state
class AdvertiserLiveNotifier extends StateNotifier<AdvertiserLiveState> {
  final AdvertiserLiveRepository _repository;
  Timer? _pollingTimer;

  /// Tracks if a refresh request is currently in progress
  bool _isRefreshing = false;

  /// Tracks if a refresh was requested while another was in progress
  bool _pendingRefresh = false;

  AdvertiserLiveNotifier(this._repository) : super(const AdvertiserLiveState());

  /// Start polling for live data
  void startPolling() {
    AppLogger.location.i('Starting live campaign polling');
    // Initial fetch
    refresh();

    // Set up periodic polling
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(TimeThresholds.pollingInterval, (_) {
      refresh();
    });
  }

  /// Stop polling
  void stopPolling() {
    AppLogger.location.i('Stopping live campaign polling');
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  /// Refresh live data with request deduplication
  ///
  /// If a refresh is already in progress, queues a single pending refresh
  /// to execute after the current one completes. Multiple requests during
  /// an ongoing refresh are deduplicated to a single pending request.
  Future<void> refresh() async {
    // If already refreshing, mark that we need to refresh again when done
    if (_isRefreshing) {
      _pendingRefresh = true;
      return;
    }

    _isRefreshing = true;
    _pendingRefresh = false;

    try {
      state = state.copyWith(isLoading: state.campaigns.isEmpty);

      final campaigns = await _repository.getLiveCampaigns();
      final alerts = await _repository.getAlerts(limit: 50);

      // Detect new alerts and generate local alerts for status changes
      final newAlerts = _detectNewAlerts(state.campaigns, campaigns);
      final allAlerts = [...newAlerts, ...alerts];

      // Count unread alerts
      final unreadCount = allAlerts.where((a) => !a.isRead).length;

      state = state.copyWith(
        campaigns: campaigns,
        alerts: allAlerts,
        unreadAlertCount: unreadCount,
        isLoading: false,
        lastRefresh: DateTime.now(),
        clearError: true,
      );
    } catch (e) {
      AppLogger.location.e('Failed to refresh live campaigns: $e');
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load live campaigns',
      );
    } finally {
      _isRefreshing = false;

      // If a refresh was requested while we were refreshing, do it now
      if (_pendingRefresh) {
        refresh();
      }
    }
  }

  /// Detect new alerts based on campaign status changes
  List<CampaignAlert> _detectNewAlerts(
    List<LiveCampaign> oldCampaigns,
    List<LiveCampaign> newCampaigns,
  ) {
    final alerts = <CampaignAlert>[];
    final now = DateTime.now();

    for (final newCampaign in newCampaigns) {
      final oldCampaign =
          oldCampaigns.where((c) => c.id == newCampaign.id).firstOrNull;

      if (oldCampaign == null) continue;

      final oldStatus = oldCampaign.promoter?.status;
      final newStatus = newCampaign.promoter?.status;

      // Status changed
      if (oldStatus != newStatus && newStatus != null) {
        CampaignAlertType? alertType;
        String? message;

        switch (newStatus) {
          case PromoterExecutionStatus.active:
            if (oldStatus == PromoterExecutionStatus.paused) {
              alertType = CampaignAlertType.resumed;
              message =
                  '${newCampaign.promoter?.promoterName} resumed the campaign';
            } else {
              alertType = CampaignAlertType.started;
              message =
                  '${newCampaign.promoter?.promoterName} started the campaign';
            }
            break;
          case PromoterExecutionStatus.paused:
            alertType = CampaignAlertType.paused;
            message =
                '${newCampaign.promoter?.promoterName} paused the campaign';
            break;
          case PromoterExecutionStatus.completed:
            alertType = CampaignAlertType.completed;
            message =
                '${newCampaign.promoter?.promoterName} completed the campaign';
            break;
          case PromoterExecutionStatus.unknown:
            break;
        }

        if (alertType != null && message != null) {
          alerts.add(CampaignAlert(
            id: '${newCampaign.id}_${now.millisecondsSinceEpoch}',
            campaignId: newCampaign.id,
            campaignTitle: newCampaign.title,
            promoterName: newCampaign.promoter?.promoterName,
            type: alertType,
            message: message,
            createdAt: now,
            isRead: false,
          ));
        }
      }

      // Check for no signal
      final wasOnline =
          oldCampaign.promoter != null && !oldCampaign.promoter!.hasNoSignal;
      final isOffline = newCampaign.promoter?.hasNoSignal ?? false;

      if (wasOnline && isOffline) {
        alerts.add(CampaignAlert(
          id: '${newCampaign.id}_nosignal_${now.millisecondsSinceEpoch}',
          campaignId: newCampaign.id,
          campaignTitle: newCampaign.title,
          promoterName: newCampaign.promoter?.promoterName,
          type: CampaignAlertType.noSignal,
          message: 'No signal from ${newCampaign.promoter?.promoterName}',
          createdAt: now,
          isRead: false,
        ));
      }
    }

    return alerts;
  }

  /// Select a campaign to focus on
  void selectCampaign(String? campaignId) {
    state = state.copyWith(
      selectedCampaignId: campaignId,
      clearSelectedCampaign: campaignId == null,
    );
  }

  /// Toggle follow mode
  void toggleFollowMode() {
    state = state.copyWith(isFollowing: !state.isFollowing);
  }

  /// Set follow mode
  void setFollowMode(bool following) {
    state = state.copyWith(isFollowing: following);
  }

  /// Set filter
  void setFilter(LiveCampaignFilter filter) {
    state = state.copyWith(filter: filter);
  }

  /// Mark an alert as read
  Future<void> markAlertAsRead(String alertId) async {
    try {
      await _repository.markAlertAsRead(alertId);

      // Use index-based update instead of .map().toList() for efficiency
      final index = state.alerts.indexWhere((a) => a.id == alertId);
      if (index != -1) {
        final updatedAlerts = [...state.alerts];
        updatedAlerts[index] = updatedAlerts[index].copyWith(isRead: true);

        state = state.copyWith(
          alerts: updatedAlerts,
          unreadAlertCount: updatedAlerts.where((a) => !a.isRead).length,
        );
      }
    } catch (e) {
      AppLogger.location.e('Failed to mark alert as read: $e');
    }
  }

  /// Mark all alerts as read
  Future<void> markAllAlertsAsRead() async {
    try {
      await _repository.markAllAlertsAsRead();

      final updatedAlerts =
          state.alerts.map((alert) => alert.copyWith(isRead: true)).toList();

      state = state.copyWith(
        alerts: updatedAlerts,
        unreadAlertCount: 0,
      );
    } catch (e) {
      AppLogger.location.e('Failed to mark all alerts as read: $e');
    }
  }

  @override
  void dispose() {
    stopPolling();
    super.dispose();
  }
}
