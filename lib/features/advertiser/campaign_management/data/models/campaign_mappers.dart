import 'package:promoruta/core/models/campaign.dart';
import 'package:promoruta/core/core.dart' as model;
import '../../presentation/models/campaign_ui.dart' as ui;

/// Extension methods for converting between core and UI campaign models
extension CampaignMappers on model.Campaign {
  /// Convert core Campaign to UI Campaign
  ui.Campaign toUiModel() {
    return ui.Campaign(
      id: id ?? '',
      title: title,
      subtitle: description,
      location: zone, // Use zone as location
      distanceKm: distance, // Use distance from core model
      status: _mapStatusToUi(status ?? model.CampaignStatus.pending),
      dateTime: startDate,
      payUsd: suggestedPrice.toInt(), // Use suggestedPrice as payment
      peopleNeeded: 0, // Could be added to core model if needed
    );
  }

  ui.CampaignStatus _mapStatusToUi(model.CampaignStatus status) {
    switch (status) {
      case model.CampaignStatus.active:
        return ui.CampaignStatus.active;
      case model.CampaignStatus.pending:
        return ui.CampaignStatus.pending;
      case model.CampaignStatus.completed:
        return ui.CampaignStatus.completed;
      case model.CampaignStatus.canceled:
        return ui.CampaignStatus.canceled;
      case model.CampaignStatus.expired:
        return ui.CampaignStatus.expired;
      case model.CampaignStatus.created:
        return ui.CampaignStatus.pending; // Map created to pending
    }
  }
}

/// Extension methods for converting from UI to core models
extension UiCampaignMappers on ui.Campaign {
  /// Convert UI Campaign to core Campaign
  model.Campaign toCoreModel() {
    final now = DateTime.now();
    final campaignDate = dateTime ?? now;

    return model.Campaign(
      id: id,
      title: title,
      description: subtitle ?? '',
      advertiserId: '', // Would need to be provided from context
      startDate: campaignDate,
      endDate: campaignDate.add(const Duration(days: 1)),
      status: _mapStatusToCore(status),
      zone: location,
      suggestedPrice: payUsd?.toDouble() ?? 0.0,
      bidDeadline: campaignDate.subtract(const Duration(hours: 2)),
      audioDuration: 30, // Default duration
      distance: distanceKm,
      routeCoordinates: [], // Empty route by default
      startTime: campaignDate,
      endTime: campaignDate.add(const Duration(days: 1)),
    );
  }

  model.CampaignStatus _mapStatusToCore(ui.CampaignStatus status) {
    switch (status) {
      case ui.CampaignStatus.active:
        return model.CampaignStatus.active;
      case ui.CampaignStatus.pending:
        return model.CampaignStatus.pending;
      case ui.CampaignStatus.completed:
        return model.CampaignStatus.completed;
      case ui.CampaignStatus.canceled:
        return model.CampaignStatus.canceled;
      case ui.CampaignStatus.expired:
        return model.CampaignStatus.expired;
      case ui.CampaignStatus.all:
        return model.CampaignStatus.active; // Default fallback
    }
  }
}