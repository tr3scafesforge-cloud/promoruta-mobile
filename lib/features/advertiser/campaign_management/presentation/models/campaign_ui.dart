import 'package:promoruta/core/models/campaign.dart' as backend;
import 'package:intl/intl.dart';

/// Campaign model for UI display in advertiser pages.
/// Matches backend statuses: pending, created, accepted, in_progress, completed, cancelled, expired
enum CampaignStatus {
  all,        // UI-only filter option
  active,     // Maps to in_progress in backend
  pending,    // Maps to pending + created in backend
  completed,  // Maps to completed in backend
  canceled,   // Maps to cancelled in backend
  expired     // Maps to expired in backend
}

class Campaign {
  final String id;
  final String title;
  final String? subtitle;
  final String location;
  final double distanceKm;
  final int? completionPct;
  final int? audioSeconds;
  final double? budget;
  final String? dateRange;
  final DateTime? dateTime;
  final int? durationSec;
  final int? payUsd;
  final int? peopleNeeded;
  final CampaignStatus status;

  const Campaign({
    required this.id,
    required this.title,
    this.subtitle,
    required this.location,
    required this.distanceKm,
    this.completionPct,
    this.audioSeconds,
    this.budget,
    this.dateRange,
    this.dateTime,
    this.durationSec,
    this.payUsd,
    this.peopleNeeded,
    required this.status,
  });

  /// Maps backend Campaign model to UI Campaign model
  factory Campaign.fromBackend(backend.Campaign backendCampaign) {
    return Campaign(
      id: backendCampaign.id ?? '',
      title: backendCampaign.title,
      subtitle: backendCampaign.description,
      location: backendCampaign.zone,
      distanceKm: backendCampaign.distance,
      completionPct: _calculateCompletionPercentage(backendCampaign),
      audioSeconds: backendCampaign.audioDuration,
      budget: backendCampaign.finalPrice ?? backendCampaign.suggestedPrice,
      dateRange: _formatDateRange(backendCampaign.startTime, backendCampaign.endTime),
      dateTime: backendCampaign.startTime,
      durationSec: backendCampaign.endTime.difference(backendCampaign.startTime).inSeconds,
      payUsd: (backendCampaign.finalPrice ?? backendCampaign.suggestedPrice).toInt(),
      peopleNeeded: null, // Not available in backend model
      status: _mapBackendStatus(backendCampaign.status),
    );
  }

  /// Maps backend CampaignStatus to UI CampaignStatus
  static CampaignStatus _mapBackendStatus(backend.CampaignStatus? status) {
    if (status == null) return CampaignStatus.pending;

    switch (status) {
      case backend.CampaignStatus.pending:
      case backend.CampaignStatus.created:
        return CampaignStatus.pending;
      case backend.CampaignStatus.active:
        return CampaignStatus.active;
      case backend.CampaignStatus.completed:
        return CampaignStatus.completed;
      case backend.CampaignStatus.canceled:
        return CampaignStatus.canceled;
      case backend.CampaignStatus.expired:
        return CampaignStatus.expired;
    }
  }

  /// Calculates completion percentage based on campaign dates
  static int _calculateCompletionPercentage(backend.Campaign campaign) {
    final now = DateTime.now();
    final start = campaign.startTime;
    final end = campaign.endTime;

    if (campaign.status == backend.CampaignStatus.completed) {
      return 100;
    }

    if (now.isBefore(start)) {
      return 0;
    }

    if (now.isAfter(end)) {
      return 100;
    }

    final totalDuration = end.difference(start).inSeconds;
    final elapsed = now.difference(start).inSeconds;
    return ((elapsed / totalDuration) * 100).round().clamp(0, 100);
  }

  /// Formats date range for display
  static String _formatDateRange(DateTime start, DateTime end) {
    final formatter = DateFormat('yyyy-MM-dd');
    return '${formatter.format(start)} - ${formatter.format(end)}';
  }
}