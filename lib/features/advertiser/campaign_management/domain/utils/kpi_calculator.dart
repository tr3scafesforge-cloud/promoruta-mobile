import 'package:promoruta/core/models/campaign.dart';

/// Utility class for calculating KPI metrics from campaign data
class KpiCalculator {
  /// Calculates the number of unique zones covered this week from campaigns
  static int calculateZonesCoveredThisWeek(List<Campaign> campaigns) {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekStartMidnight =
        DateTime(weekStart.year, weekStart.month, weekStart.day);

    // Filter campaigns that started this week
    final thisWeekCampaigns = campaigns.where((campaign) {
      final campaignStart = campaign.startTime;
      return campaignStart.isAfter(weekStartMidnight) ||
          campaignStart.isAtSameMomentAs(weekStartMidnight);
    });

    // Get unique zones
    final uniqueZones = <String>{};
    for (final campaign in thisWeekCampaigns) {
      uniqueZones.add(campaign.zone);
    }

    return uniqueZones.length;
  }

  /// Calculates the total investment from campaigns (fallback calculation)
  /// Note: This is a fallback. The authoritative source should be the backend.
  static double calculateTotalInvestment(List<Campaign> campaigns) {
    return campaigns.fold<double>(0.0, (total, campaign) {
      final price = campaign.finalPrice ?? campaign.suggestedPrice;
      return total + price;
    });
  }
}
