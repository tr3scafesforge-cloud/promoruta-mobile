/// Basic campaign model.
class Campaign {
  final String id;
  final String title;
  final String description;
  final String advertiserId;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;

  const Campaign({
    required this.id,
    required this.title,
    required this.description,
    required this.advertiserId,
    required this.startDate,
    required this.endDate,
    required this.isActive,
  });

  // Add copyWith, fromJson, toJson as needed
}