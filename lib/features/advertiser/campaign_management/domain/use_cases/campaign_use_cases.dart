import 'package:promoruta/core/models/campaign.dart';
import '../repositories/campaign_repository.dart';
import 'package:promoruta/core/core.dart' as model;
import 'package:promoruta/shared/shared.dart';

/// Use case for getting all campaigns
class GetCampaignsUseCase implements UseCaseNoParams<List<model.Campaign>> {
  final CampaignRepository _repository;

  GetCampaignsUseCase(this._repository);

  @override
  Future<List<model.Campaign>> call() async {
    return await _repository.getCampaigns();
  }
}

/// Use case for getting a specific campaign by ID
class GetCampaignUseCase implements UseCase<model.Campaign?, String> {
  final CampaignRepository _repository;

  GetCampaignUseCase(this._repository);

  @override
  Future<model.Campaign?> call(String campaignId) async {
    return await _repository.getCampaign(campaignId);
  }
}

/// Use case for creating a new campaign
class CreateCampaignUseCase implements UseCase<model.Campaign, model.Campaign> {
  final CampaignRepository _repository;

  CreateCampaignUseCase(this._repository);

  @override
  Future<model.Campaign> call(model.Campaign campaign) async {
    return await _repository.createCampaign(campaign);
  }
}

/// Use case for updating an existing campaign
class UpdateCampaignUseCase implements UseCase<model.Campaign, model.Campaign> {
  final CampaignRepository _repository;

  UpdateCampaignUseCase(this._repository);

  @override
  Future<model.Campaign> call(model.Campaign campaign) async {
    return await _repository.updateCampaign(campaign);
  }
}

/// Use case for deleting a campaign
class DeleteCampaignUseCase implements UseCaseVoid<String> {
  final CampaignRepository _repository;

  DeleteCampaignUseCase(this._repository);

  @override
  Future<void> call(String campaignId) async {
    return await _repository.deleteCampaign(campaignId);
  }
}