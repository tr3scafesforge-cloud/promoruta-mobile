/// Campaign status enumeration
enum CampaignStatus { active, pending, completed, canceled, expired }

/// Basic campaign model.
class Campaign {
  final String id;
  final String title;
  final String description;
  final String advertiserId;
  final DateTime startDate;
  final DateTime endDate;
  final CampaignStatus status;

  const Campaign({
    required this.id,
    required this.title,
    required this.description,
    required this.advertiserId,
    required this.startDate,
    required this.endDate,
    required this.status,
  });

  // Add copyWith, fromJson, toJson as needed
}