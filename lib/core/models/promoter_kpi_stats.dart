/// KPI statistics for promoter dashboard
class PromoterKpiStats {
  final double thisWeekEarnings;
  final double thisMonthEarnings;
  final double totalEarnings;
  final int completedCampaigns;
  final double totalDistanceKm;
  final double averageRating;
  final DateTime? lastUpdated;

  const PromoterKpiStats({
    required this.thisWeekEarnings,
    required this.thisMonthEarnings,
    required this.totalEarnings,
    required this.completedCampaigns,
    required this.totalDistanceKm,
    required this.averageRating,
    this.lastUpdated,
  });

  factory PromoterKpiStats.fromJson(Map<String, dynamic> json) {
    return PromoterKpiStats(
      thisWeekEarnings: json['this_week_earnings'] is String
          ? double.parse(json['this_week_earnings'] as String)
          : (json['this_week_earnings'] as num).toDouble(),
      thisMonthEarnings: json['this_month_earnings'] is String
          ? double.parse(json['this_month_earnings'] as String)
          : (json['this_month_earnings'] as num).toDouble(),
      totalEarnings: json['total_earnings'] is String
          ? double.parse(json['total_earnings'] as String)
          : (json['total_earnings'] as num).toDouble(),
      completedCampaigns: json['completed_campaigns'] as int,
      totalDistanceKm: json['total_distance_km'] is String
          ? double.parse(json['total_distance_km'] as String)
          : (json['total_distance_km'] as num).toDouble(),
      averageRating: json['average_rating'] is String
          ? double.parse(json['average_rating'] as String)
          : (json['average_rating'] as num).toDouble(),
      lastUpdated: json['last_updated'] != null
          ? DateTime.parse(json['last_updated'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'this_week_earnings': thisWeekEarnings,
      'this_month_earnings': thisMonthEarnings,
      'total_earnings': totalEarnings,
      'completed_campaigns': completedCampaigns,
      'total_distance_km': totalDistanceKm,
      'average_rating': averageRating,
      if (lastUpdated != null) 'last_updated': lastUpdated!.toIso8601String(),
    };
  }

  PromoterKpiStats copyWith({
    double? thisWeekEarnings,
    double? thisMonthEarnings,
    double? totalEarnings,
    int? completedCampaigns,
    double? totalDistanceKm,
    double? averageRating,
    DateTime? lastUpdated,
  }) {
    return PromoterKpiStats(
      thisWeekEarnings: thisWeekEarnings ?? this.thisWeekEarnings,
      thisMonthEarnings: thisMonthEarnings ?? this.thisMonthEarnings,
      totalEarnings: totalEarnings ?? this.totalEarnings,
      completedCampaigns: completedCampaigns ?? this.completedCampaigns,
      totalDistanceKm: totalDistanceKm ?? this.totalDistanceKm,
      averageRating: averageRating ?? this.averageRating,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}
