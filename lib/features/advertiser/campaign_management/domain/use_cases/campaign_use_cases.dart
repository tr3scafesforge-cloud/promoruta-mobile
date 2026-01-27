import 'dart:io';
import '../repositories/campaign_repository.dart';
import 'package:promoruta/core/core.dart' as model;
import 'package:promoruta/shared/shared.dart';

/// Parameters for getting campaigns
///
/// Available status values: pending, created, accepted, in_progress, completed, cancelled, expired
/// Sort by values: created_at, start_time, suggested_price
class GetCampaignsParams {
  final String? status;
  final String? zone;
  final String? createdBy;
  final String? acceptedBy;
  final bool? upcoming;
  final DateTime? startTimeFrom;
  final DateTime? startTimeTo;
  final String? sortBy;
  final String? sortOrder;
  final double? lat;
  final double? lng;
  final double? radius;
  final int? perPage;

  const GetCampaignsParams({
    this.status,
    this.zone,
    this.createdBy,
    this.acceptedBy,
    this.upcoming,
    this.startTimeFrom,
    this.startTimeTo,
    this.sortBy,
    this.sortOrder,
    this.lat,
    this.lng,
    this.radius,
    this.perPage,
  });
}

/// Use case for getting all campaigns
class GetCampaignsUseCase
    implements UseCase<List<model.Campaign>, GetCampaignsParams?> {
  final CampaignRepository _repository;

  GetCampaignsUseCase(this._repository);

  @override
  Future<List<model.Campaign>> call([GetCampaignsParams? params]) async {
    return await _repository.getCampaigns(
      status: params?.status,
      zone: params?.zone,
      createdBy: params?.createdBy,
      acceptedBy: params?.acceptedBy,
      upcoming: params?.upcoming,
      startTimeFrom: params?.startTimeFrom,
      startTimeTo: params?.startTimeTo,
      sortBy: params?.sortBy,
      sortOrder: params?.sortOrder,
      lat: params?.lat,
      lng: params?.lng,
      radius: params?.radius,
      perPage: params?.perPage,
    );
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

/// Parameters for creating a campaign
class CreateCampaignParams {
  final model.Campaign campaign;
  final File? audioFile;

  const CreateCampaignParams({
    required this.campaign,
    this.audioFile,
  });
}

/// Use case for creating a new campaign
class CreateCampaignUseCase
    implements UseCase<model.Campaign, CreateCampaignParams> {
  final CampaignRepository _repository;

  CreateCampaignUseCase(this._repository);

  @override
  Future<model.Campaign> call(CreateCampaignParams params) async {
    return await _repository.createCampaign(
      params.campaign,
      audioFile: params.audioFile,
    );
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

/// Parameters for cancelling a campaign
class CancelCampaignParams {
  final String campaignId;
  final String reason;

  const CancelCampaignParams({
    required this.campaignId,
    required this.reason,
  });
}

/// Use case for cancelling a campaign
class CancelCampaignUseCase
    implements UseCase<model.Campaign, CancelCampaignParams> {
  final CampaignRepository _repository;

  CancelCampaignUseCase(this._repository);

  @override
  Future<model.Campaign> call(CancelCampaignParams params) async {
    return await _repository.cancelCampaign(params.campaignId, params.reason);
  }
}
