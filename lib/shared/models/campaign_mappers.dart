import 'package:promoruta/core/core.dart' as model;
import 'campaign_ui.dart' as ui;

/// Extension methods for converting between core and UI campaign models
extension CampaignMappers on model.Campaign {
  /// Convert core Campaign to UI Campaign
  ui.Campaign toUiModel() {
    return ui.Campaign(
      id: id,
      title: title,
      subtitle: description,
      location: 'Unknown Location', // Could be enhanced with location data
      distanceKm: 0.0, // Could be calculated based on user location
      status: isActive ? ui.CampaignStatus.active : ui.CampaignStatus.expired,
      dateTime: startDate,
      payUsd: 0, // Could be added to core model if needed
      peopleNeeded: 0, // Could be added to core model if needed
    );
  }
}

/// Extension methods for converting from UI to core models
extension UiCampaignMappers on ui.Campaign {
  /// Convert UI Campaign to core Campaign
  model.Campaign toCoreModel() {
    return model.Campaign(
      id: id,
      title: title,
      description: subtitle ?? '',
      advertiserId: '', // Would need to be provided from context
      startDate: dateTime ?? DateTime.now(),
      endDate: (dateTime ?? DateTime.now()).add(const Duration(days: 1)),
      isActive: status == ui.CampaignStatus.active,
    );
  }
}