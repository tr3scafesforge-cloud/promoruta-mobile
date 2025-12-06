/// Campaign model for UI display in advertiser pages.
enum CampaignStatus { all, active, pending, completed, canceled, expired }

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
}