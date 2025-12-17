/// KPI statistics for advertiser dashboard
class AdvertiserKpiStats {
  final double totalInvestment;
  final int zonesCovered;
  final DateTime? lastUpdated;

  const AdvertiserKpiStats({
    required this.totalInvestment,
    required this.zonesCovered,
    this.lastUpdated,
  });

  factory AdvertiserKpiStats.fromJson(Map<String, dynamic> json) {
    return AdvertiserKpiStats(
      totalInvestment: json['total_investment'] is String
          ? double.parse(json['total_investment'] as String)
          : (json['total_investment'] as num).toDouble(),
      zonesCovered: json['zones_covered'] as int,
      lastUpdated: json['last_updated'] != null
          ? DateTime.parse(json['last_updated'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_investment': totalInvestment,
      'zones_covered': zonesCovered,
      if (lastUpdated != null) 'last_updated': lastUpdated!.toIso8601String(),
    };
  }

  AdvertiserKpiStats copyWith({
    double? totalInvestment,
    int? zonesCovered,
    DateTime? lastUpdated,
  }) {
    return AdvertiserKpiStats(
      totalInvestment: totalInvestment ?? this.totalInvestment,
      zonesCovered: zonesCovered ?? this.zonesCovered,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}
